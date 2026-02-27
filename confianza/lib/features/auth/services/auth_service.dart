import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

/// Servicio para manejar autenticación con Firebase Auth
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Obtiene el usuario actual autenticado
  User? get currentUser => _firebaseAuth.currentUser;

  /// Stream de cambios de autenticación
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Registra un nuevo usuario con email y contraseña
  Future<AppUser?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) return null;

      // Crear documento del usuario en Firestore
      final appUser = AppUser(
        uid: user.uid,
        username: 'Anónimo_${user.uid.substring(0, 8)}',
        email: email,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.uid).set(appUser.toMap());

      return appUser;
    } on FirebaseAuthException catch (e) {
      print('Error en registro: ${e.message}');
      return null;
    }
  }

  /// Inicia sesión con email y contraseña
  Future<AppUser?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) return null;

      // Obtener datos del usuario desde Firestore
      return await getUserProfile(user.uid);
    } on FirebaseAuthException catch (e) {
      print('Error en login: ${e.message}');
      return null;
    }
  }

  /// Obtiene el perfil del usuario desde Firestore
  Future<AppUser?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;

      return AppUser.fromMap(doc.data() as Map<String, dynamic>, uid);
    } catch (e) {
      print('Error obteniendo perfil: $e');
      return null;
    }
  }

  /// Cierra la sesión actual
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
