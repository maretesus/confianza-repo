/// Ejemplo de cómo usar AuthProviders en la UI
/// 
/// Este archivo muestra patrones comunes para usar autenticación en Flutter

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/providers/auth_providers.dart';
import 'features/auth/models/user.dart';

/// ============== EJEMPLO 1: Verificar si usuario está autenticado ==============

class AuthGuardExample extends ConsumerWidget {
  const AuthGuardExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observa el estado de autenticación
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          // No autenticado → mostrar login
          return const LoginScreenExample();
        } else {
          // Autenticado → mostrar contenido principal
          return const HomeScreenExample();
        }
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
    );
  }
}

/// ============== EJEMPLO 2: Pantalla de Login ==============

class LoginScreenExample extends ConsumerStatefulWidget {
  const LoginScreenExample({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreenExample> createState() =>
      _LoginScreenExampleState();
}

class _LoginScreenExampleState extends ConsumerState<LoginScreenExample> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() async {
    final email = emailController.text;
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor llena ambos campos')),
      );
      return;
    }

    // Aquí es donde se ejecuta el login con Firebase
    final result = await ref.read(
      signInProvider(
        (email: email, password: password),
      ).future,
    );

    if (!mounted) return;

    if (result != null) {
      // Login exitoso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Bienvenido!')),
      );
    } else {
      // Error en login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email o contraseña incorrectos')),
      );
    }
  }

  void _handleSignUp() async {
    final email = emailController.text;
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor llena ambos campos')),
      );
      return;
    }

    // Aquí es donde se ejecuta el registro con Firebase
    final result = await ref.read(
      signUpProvider(
        (email: email, password: password),
      ).future,
    );

    if (!mounted) return;

    if (result != null) {
      // Registro exitoso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Cuenta creada! Bienvenido a Confianza')),
      );
    } else {
      // Error en registro
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al crear cuenta. Intenta outro email')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confianza - Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleSignIn,
                    child: const Text('Iniciar Sesión'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Registrarse'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ============== EJEMPLO 3: Página Principal con Usuario ==============

class HomeScreenExample extends ConsumerWidget {
  const HomeScreenExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtiene los datos del usuario actual
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confianza - Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Cierra sesión
              await ref.read(signOutProvider.future);
            },
          ),
        ],
      ),
      body: currentUserAsync.when(
        data: (user) => user == null
            ? const Center(child: Text('No hay usuario'))
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.account_circle, size: 100),
                    const SizedBox(height: 16),
                    Text(
                      'Hola, ${user.username}',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user.email,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Error: $err'),
        ),
      ),
    );
  }
}

/// ============== EJEMPLO 4: Usar autenticación en Provider ==============

// En tus providers, accede al usuario actual así:
// final myFeatureProvider = Provider((ref) async {
//   final currentUser = await ref.watch(currentUserProvider.future);
//   if (currentUser == null) return null;
//   // Usa currentUser.uid para hacer queries a Firestore
// });

/// ============== EJEMPLO 5: En secretsProviders.dart ==============

// Ya implementado: userSecretsProvider que obtiene secretos del usuario autenticado:
//
// final userSecretsProvider = StreamProvider.autoDispose.family<List<Secret>, String>(
//   (ref, userId) {
//     final secretService = ref.watch(secretServiceProvider);
//     return secretService.getUserSecrets(userId);
//   },
// );
//
// USO EN WIDGET:
//
// final currentUser = await ref.watch(currentUserProvider.future);
// if (currentUser != null) {
//   final mySecrets = ref.watch(userSecretsProvider(currentUser.uid));
//   // Ahora tienes los secretos del usuario en tiempo real
// }
