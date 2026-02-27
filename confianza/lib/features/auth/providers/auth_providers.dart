import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

// ==================== PROVIDER DE SERVICIO ====================

/// Provider del servicio de autenticación
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// ==================== PROVIDERS DE AUTENTICACIÓN ====================

/// Stream del estado de autenticación de Firebase
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Provider del usuario actual autenticado (AppUser)
/// Reactivo: se actualiza cuando cambia el estado de autenticación
final currentUserProvider = StreamProvider<AppUser?>((ref) async* {
  final authService = ref.watch(authServiceProvider);
  
  // Escuchar cambios en el stream de autenticación del servicio
  await for (final user in authService.authStateChanges) {
    if (user == null) {
      yield null;
    } else {
      final appUser = await authService.getUserProfile(user.uid);
      yield appUser;
    }
  }
});

// ==================== PROVIDERS DE ACCIONES ====================

/// Provider para registrar un nuevo usuario
final signUpProvider = FutureProvider.autoDispose.family<AppUser?, ({String email, String password})>(
  (ref, params) async {
    final authService = ref.read(authServiceProvider);
    return authService.signUp(
      email: params.email,
      password: params.password,
    );
  },
);

/// Provider para iniciar sesión
final signInProvider = FutureProvider.autoDispose.family<AppUser?, ({String email, String password})>(
  (ref, params) async {
    final authService = ref.read(authServiceProvider);
    return authService.signIn(
      email: params.email,
      password: params.password,
    );
  },
);

/// Provider para cerrar sesión
final signOutProvider = FutureProvider.autoDispose<void>((ref) async {
  final authService = ref.read(authServiceProvider);
  await authService.signOut();
  
  // Invalida el provider de usuario actual
  ref.invalidate(currentUserProvider);
});
