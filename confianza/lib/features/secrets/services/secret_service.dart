import '../models/secret.dart';

/// Servicio para manejar operaciones con secretos
/// FASE 1: Retorna datos mock para testing sin Firebase
class SecretService {
  // Datos mock para desarrollo y testing
  final List<Secret> _mockSecrets = [
    Secret(
      id: '1',
      userId: 'user_001',
      videoUrl: 'https://picsum.photos/400/600',
      title: 'Mi primer secreto',
      description: 'Siempre tuve miedo de contar esto pero aquí va...',
      category: 'LOVE',
      likes: 124,
      comments: 23,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isAnonymous: true,
    ),
    Secret(
      id: '2',
      userId: 'user_002',
      videoUrl: 'https://picsum.photos/400/601',
      title: 'Confesión familiar',
      description: 'Algo que nunca le dije a mi familia',
      category: 'FAMILY',
      likes: 89,
      comments: 45,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      isAnonymous: true,
    ),
    Secret(
      id: '3',
      userId: 'user_003',
      videoUrl: 'https://picsum.photos/400/602',
      title: 'Historia de amistad',
      description: 'Mi mejor amigo no sabe esto sobre mí',
      category: 'FRIENDSHIP',
      likes: 203,
      comments: 67,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isAnonymous: true,
    ),
    Secret(
      id: '4',
      userId: 'user_004',
      videoUrl: 'https://picsum.photos/400/603',
      title: 'Algo muy extraño',
      description: 'Esto me pasó y nadie me cree',
      category: 'WEIRD',
      likes: 456,
      comments: 189,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      isAnonymous: true,
    ),
    Secret(
      id: '5',
      userId: 'user_005',
      videoUrl: 'https://picsum.photos/400/604',
      title: 'Confesión hot 🔥',
      description: null,
      category: 'HOT',
      likes: 789,
      comments: 234,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      isAnonymous: true,
    ),
  ];

  /// Obtiene todos los secretos
  Future<List<Secret>> getSecrets() async {
    // Simula latencia de red
    await Future.delayed(const Duration(seconds: 1));
    return List.from(_mockSecrets);
  }

  /// Obtiene un secreto por ID
  Future<Secret?> getSecretById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _mockSecrets.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Crea un nuevo secreto
  Future<void> createSecret(Secret secret) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockSecrets.insert(0, secret);
  }

  /// Actualiza un secreto existente
  Future<void> updateSecret(Secret secret) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _mockSecrets.indexWhere((s) => s.id == secret.id);
    if (index != -1) {
      _mockSecrets[index] = secret;
    }
  }

  /// Elimina un secreto
  Future<void> deleteSecret(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockSecrets.removeWhere((s) => s.id == id);
  }

  /// Da like a un secreto
  Future<void> likeSecret(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _mockSecrets.indexWhere((s) => s.id == id);
    if (index != -1) {
      _mockSecrets[index] = _mockSecrets[index].copyWith(
        likes: _mockSecrets[index].likes + 1,
      );
    }
  }

  /// Obtiene secretos por categoría
  Future<List<Secret>> getSecretsByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockSecrets
        .where((s) => s.category.toUpperCase() == category.toUpperCase())
        .toList();
  }
}
