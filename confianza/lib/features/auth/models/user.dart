/// Modelo de usuario en Firestore
class AppUser {
  final String uid;
  final String username; // Anónimo por defecto
  final String email;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.username,
    required this.email,
    required this.createdAt,
  });

  /// Convierte el modelo a Map (para Firestore)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Crea un AppUser desde un Map (desde Firestore)
  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      username: map['username'] as String? ?? 'Anónimo',
      email: map['email'] as String,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
