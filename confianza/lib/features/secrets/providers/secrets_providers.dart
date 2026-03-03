import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/secret.dart';
import '../models/comment.dart';
import '../services/secret_service.dart';
import '../../auth/providers/auth_providers.dart';

// ==================== PROVIDERS DE SERVICIOS ====================

/// Provider del servicio de secretos
final secretServiceProvider = Provider<SecretService>((ref) {
  return SecretService();
});

// ==================== PROVIDERS DE DATOS (STREAMS EN TIEMPO REAL) ====================

/// Provider Stream que obtiene todos los secretos en tiempo real desde Firestore
final secretsProvider = StreamProvider.autoDispose<List<Secret>>((ref) {
  final secretService = ref.watch(secretServiceProvider);
  return secretService.getSecretsStream();
});

/// Provider Stream que obtiene secretos por categoría
final secretsByCategoryProvider = StreamProvider.autoDispose.family<List<Secret>, String>(
  (ref, category) {
    final secretService = ref.watch(secretServiceProvider);
    return secretService.getSecretsByCategory(category);
  },
);

/// Provider que obtiene un secreto específico por ID (Future)
final secretByIdProvider = FutureProvider.autoDispose.family<Secret?, String>(
  (ref, secretId) async {
    final secretService = ref.watch(secretServiceProvider);
    return secretService.getSecretById(secretId);
  },
);

// ==================== PROVIDERS DE ESTADO ====================

/// Provider para filtro de categoría actual
final selectedCategoryProvider = StateProvider<String?>((ref) {
  return null; // null = todas las categorías
});

/// Provider que retorna secretos filtrados según categoría seleccionada
/// Usa streams para actualizaciones en tiempo real
final filteredSecretsProvider = StreamProvider.autoDispose<List<Secret>>((ref) {
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final secretService = ref.watch(secretServiceProvider);
  
  if (selectedCategory == null) {
    // Si no hay categoría seleccionada, mostrar todos
    return secretService.getSecretsStream();
  } else {
    // Si hay categoría, filtrar
    return secretService.getSecretsByCategory(selectedCategory);
  }
});

// ==================== PROVIDERS DE ACCIONES ====================

/// Provider para dar like a un secreto
/// Parámetro: (secretId, userId)
final likeSecretProvider = FutureProvider.autoDispose.family<void, (String, String)>(
  (ref, params) async {
    final secretService = ref.read(secretServiceProvider);
    await secretService.likeSecret(params.$1, params.$2);
    // Los streams se actualizan automáticamente en Firestore
  },
);

/// Provider para quitar like a un secreto
/// Parámetro: (secretId, userId)
final unlikeSecretProvider = FutureProvider.autoDispose.family<void, (String, String)>(
  (ref, params) async {
    final secretService = ref.read(secretServiceProvider);
    await secretService.unlikeSecret(params.$1, params.$2);
    // Los streams se actualizan automáticamente en Firestore
  },
);

/// Provider para crear un nuevo secreto
final createSecretProvider = FutureProvider.autoDispose.family<String?, Secret>(
  (ref, secret) async {
    final secretService = ref.read(secretServiceProvider);
    final newSecretId = await secretService.createSecret(secret);
    // Refrescar los providers de secretos para que se actualicen inmediatamente
    if (newSecretId != null) {
      ref.refresh(secretsProvider);
      ref.refresh(filteredSecretsProvider);
    }
    return newSecretId;
  },
);

/// Provider para actualizar un secreto existente
final updateSecretProvider = FutureProvider.autoDispose.family<void, Secret>(
  (ref, secret) async {
    final secretService = ref.read(secretServiceProvider);
    await secretService.updateSecret(secret);
  },
);

/// Provider para eliminar un secreto
final deleteSecretProvider = FutureProvider.autoDispose.family<void, String>(
  (ref, secretId) async {
    final secretService = ref.read(secretServiceProvider);
    await secretService.deleteSecret(secretId);
  },
);

/// Provider para obtener secretos del usuario actual
final userSecretsProvider = StreamProvider.autoDispose.family<List<Secret>, String>(
  (ref, userId) {
    final secretService = ref.watch(secretServiceProvider);
    return secretService.getUserSecrets(userId);
  },
);

// ==================== PROVIDERS DE UI STATE ====================

/// Provider para controlar si se está mostrando el modo búsqueda
final isSearchModeProvider = StateProvider<bool>((ref) {
  return false;
});

/// Provider para el texto de búsqueda
final searchQueryProvider = StateProvider<String>((ref) {
  return '';
});

/// Provider que filtra secretos por búsqueda
final searchedSecretsProvider = FutureProvider.autoDispose<List<Secret>>((ref) async {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  
  // Esperar a que filteredSecretsProvider devuelva datos
  final secretsAsync = await ref.watch(filteredSecretsProvider.future);
  
  if (query.isEmpty) {
    return secretsAsync;
  }
  
  return secretsAsync.where((secret) {
    return secret.title.toLowerCase().contains(query) ||
           (secret.description?.toLowerCase().contains(query) ?? false);
  }).toList();
});

// ==================== PROVIDERS DE COMENTARIOS ====================

/// Provider Stream que obtiene comentarios de un secreto específico
final commentsProvider = StreamProvider.autoDispose.family<List<Comment>, String>(
  (ref, secretId) {
    final secretService = ref.watch(secretServiceProvider);
    return secretService.getCommentsStream(secretId);
  },
);

/// Provider para agregar un comentario a un secreto
final addCommentProvider = FutureProvider.autoDispose.family<void, (String, Comment)>(
  (ref, params) async {
    final secretService = ref.read(secretServiceProvider);
    await secretService.addComment(params.$1, params.$2);
    // Refrescar comentarios del secreto
    ref.refresh(commentsProvider(params.$1));
  },
);

