import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/secret.dart';

/// Servicio para manejar operaciones con secretos en Firestore
class SecretService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Guarda una referencia a la colección de secretos
  CollectionReference<Map<String, dynamic>> get _secretsCollection =>
      _firestore.collection('secrets');

  /// Obtiene todos los secretos desde Firestore
  /// Ordenados por fecha más reciente primero
  Future<List<Secret>> getSecrets() async {
    try {
      final snapshot = await _secretsCollection
          .orderBy('createdAt', descending: true)
          .limit(100) // Limita a 100 para mejor rendimiento
          .get();

      return snapshot.docs
          .map((doc) => Secret.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error obteniendo secretos: $e');
      return [];
    }
  }

  /// Obtiene un secreto específico por ID
  Future<Secret?> getSecretById(String id) async {
    try {
      final doc = await _secretsCollection.doc(id).get();
      if (!doc.exists) return null;

      return Secret.fromMap(doc.data() as Map<String, dynamic>, id);
    } catch (e) {
      print('Error obteniendo secreto: $e');
      return null;
    }
  }

  /// Stream de todos los secretos (para actualización en tiempo real)
  Stream<List<Secret>> getSecretsStream() {
    return _secretsCollection
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Secret.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Stream de secretos por categoría
  Stream<List<Secret>> getSecretsByCategory(String category) {
    return _secretsCollection
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Secret.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Crea un nuevo secreto en Firestore
  Future<String?> createSecret(Secret secret) async {
    try {
      // Asegurar que likedByUserIds está inicializado
      final secretToSave = secret.copyWith(likedByUserIds: []);
      final docRef = await _secretsCollection.add(secretToSave.toMap());
      return docRef.id;
    } catch (e) {
      print('Error creando secreto: $e');
      return null;
    }
  }

  /// Actualiza un secreto existente
  Future<void> updateSecret(Secret secret) async {
    try {
      await _secretsCollection.doc(secret.id).update(secret.toMap());
    } catch (e) {
      print('Error actualizando secreto: $e');
    }
  }

  /// Elimina un secreto
  Future<void> deleteSecret(String id) async {
    try {
      await _secretsCollection.doc(id).delete();
    } catch (e) {
      print('Error eliminando secreto: $e');
    }
  }

  /// Da like a un secreto para un usuario específico
  /// Si el usuario ya dio like, no hace nada (idempotente)
  Future<void> likeSecret(String secretId, String userId) async {
    try {
      final doc = await _secretsCollection.doc(secretId).get();
      if (!doc.exists) return;

      final likedByUserIds = List<String>.from(doc.get('likedByUserIds') as List? ?? []);
      
      // Si el usuario ya dio like, no hacer nada (toggle)
      if (likedByUserIds.contains(userId)) {
        return;
      }

      // Agregar usuario a la lista de likes
      likedByUserIds.add(userId);
      
      await _secretsCollection.doc(secretId).update({
        'likedByUserIds': likedByUserIds,
        'likes': likedByUserIds.length, // Actualizar contador
      });
    } catch (e) {
      print('Error dando like: $e');
    }
  }

  /// Quita el like de un secreto para un usuario específico
  Future<void> unlikeSecret(String secretId, String userId) async {
    try {
      final doc = await _secretsCollection.doc(secretId).get();
      if (!doc.exists) return;

      final likedByUserIds = List<String>.from(doc.get('likedByUserIds') as List? ?? []);
      
      // Remover usuario de la lista de likes
      likedByUserIds.remove(userId);
      
      await _secretsCollection.doc(secretId).update({
        'likedByUserIds': likedByUserIds,
        'likes': likedByUserIds.length, // Actualizar contador
      });
    } catch (e) {
      print('Error removiendo like: $e');
    }
  }

  /// Obtiene secretos de un usuario específico
  Stream<List<Secret>> getUserSecrets(String userId) {
    return _secretsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Secret.fromMap(doc.data(), doc.id))
            .toList());
  }
}
