import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/router.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';

/// Widget raíz de la aplicación Confident
/// Configura el router y los temas
class ConfidentApp extends StatelessWidget {
  const ConfidentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // Configuración básica
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // Router configuration (go_router)
      routerConfig: appRouter,

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
