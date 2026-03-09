import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'features/auth/providers/anonymous_user_provider.dart';

/// Widget raíz de la aplicación Confident
/// Configura el router y los temas
class ConfidentApp extends ConsumerWidget {
  const ConfidentApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Inicializar ID anónimo del usuario
    final anonymousId = ref.watch(anonymousUserIdProvider);

    // Una vez que se carga el ID anónimo, guardarlo en el provider sincrónico
    anonymousId.whenData((id) {
      ref.read(anonymousUserIdSyncProvider.notifier).state = id;
    });

    // Obtener el router con la lógica de redirección
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      // Configuración básica
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // Router configuration (go_router)
      routerConfig: router,

      // Temas
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Sigue el sistema

      // Configuraciones adicionales
      builder: (context, child) {
        // Aquí puedes agregar wrappers globales
        // Por ejemplo: para manejar orientación, etc.
        return MediaQuery(
          // Asegura que el texto no se escale demasiado
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2)),
          ),
          child: child!,
        );
      },
    );
  }
}
