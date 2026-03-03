import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/secrets/screens/feed_screen.dart';
import '../features/secrets/screens/create_secret_screen.dart';
import '../features/secrets/screens/my_secrets_screen.dart';
import '../features/secrets/screens/secret_detail_screen.dart';

/// Configuración de rutas de la aplicación usando go_router
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'feed',
      builder: (context, state) => const FeedScreen(),
    ),
    GoRoute(
      path: '/create-secret',
      name: 'create-secret',
      builder: (context, state) => const CreateSecretScreen(),
    ),
    GoRoute(
      path: '/my-secrets',
      name: 'my-secrets',
      builder: (context, state) => const MySecretsScreen(),
    ),
    GoRoute(
      path: '/secret/:id',
      name: 'secret-detail',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return SecretDetailScreen(secretId: id);
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Página no encontrada',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            state.uri.toString(),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('Volver al inicio'),
          ),
        ],
      ),
    ),
  ),
);
