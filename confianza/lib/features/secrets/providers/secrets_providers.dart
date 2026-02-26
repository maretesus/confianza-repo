import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/secret.dart';
import '../services/secret_service.dart';

// ==================== PROVIDERS DE SERVICIOS ====================

/// Provider del servicio de secretos
/// Este provider es inmutable y siempre retorna la misma instancia
final secretServiceProvider = Provider<SecretService>((ref) {
  return SecretService();
});

// ==================== PROVIDERS DE DATOS ====================

/// Provider que obtiene todos los secretos
/// Usa FutureProvider para manejar estados async automáticamente
/// AutoDispose: se limpia automáticamente cuando no se usa
final secretsProvider = FutureProvider.autoDispose<List<Secret>>((ref) async {
  final secretService = ref.watch(secretServiceProvider);
  return secretService.getSecrets();
});

/// Provider que obtiene secretos por categoría
/// Recibe la categoría como parámetro
final secretsByCategoryProvider = FutureProvider.autoDispose.family<List<Secret>, String>(
  (ref, category) async {
    final secretService = ref.watch(secretServiceProvider);
    return secretService.getSecretsByCategory(category);
  },
);

/// Provider que obtiene un secreto específico por ID
/// Útil para la pantalla de detalle
final secretByIdProvider = FutureProvider.autoDispose.family<Secret?, String>(
  (ref, secretId) async {
    final secretService = ref.watch(secretServiceProvider);
    return secretService.getSecretById(secretId);
  },
);

// ==================== PROVIDERS DE ESTADO ====================

/// Provider para filtro de categoría actual
/// StateProvider permite cambiar el valor desde la UI
final selectedCategoryProvider = StateProvider<String?>((ref) {
  return null; // null = todas las categorías
});

/// Provider que retorna secretos filtrados según categoría seleccionada
/// Este es un provider "computed" - se actualiza automáticamente
final filteredSecretsProvider = FutureProvider.autoDispose<List<Secret>>((ref) async {
  final selectedCategory = ref.watch(selectedCategoryProvider);
  
  if (selectedCategory == null) {
    // Si no hay categoría seleccionada, mostrar todos
    return ref.watch(secretsProvider.future);
  } else {
    // Si hay categoría, filtrar
    return ref.watch(secretsByCategoryProvider(selectedCategory).future);
  }
});

// ==================== PROVIDERS DE ACCIONES ====================

/// Provider para dar like a un secreto
/// No retorna datos, solo ejecuta la acción
final likeSecretProvider = Provider.autoDispose.family<Future<void>, String>(
  (ref, secretId) async {
    final secretService = ref.read(secretServiceProvider);
    await secretService.likeSecret(secretId);
    
    // Invalida el provider de secretos para que se recarguen
    ref.invalidate(secretsProvider);
    ref.invalidate(secretByIdProvider(secretId));
  },
);

/// Provider para crear un nuevo secreto
final createSecretProvider = Provider.autoDispose.family<Future<void>, Secret>(
  (ref, secret) async {
    final secretService = ref.read(secretServiceProvider);
    await secretService.createSecret(secret);
    
    // Invalida el provider de secretos para que se recarguen
    ref.invalidate(secretsProvider);
  },
);

/// Provider para eliminar un secreto
final deleteSecretProvider = Provider.autoDispose.family<Future<void>, String>(
  (ref, secretId) async {
    final secretService = ref.read(secretServiceProvider);
    await secretService.deleteSecret(secretId);
    
    // Invalida el provider de secretos para que se recarguen
    ref.invalidate(secretsProvider);
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
  final secrets = await ref.watch(filteredSecretsProvider.future);
  
  if (query.isEmpty) {
    return secrets;
  }
  
  return secrets.where((secret) {
    return secret.title.toLowerCase().contains(query) ||
           (secret.description?.toLowerCase().contains(query) ?? false);
  }).toList();
});
