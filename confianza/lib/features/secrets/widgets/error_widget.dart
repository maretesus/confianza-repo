import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

/// Widget reutilizable para mostrar errores
/// Muestra icono, mensaje y botón de reintentar
class ErrorStateWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback? onRetry;
  final IconData? icon;

  const ErrorStateWidget({
    super.key,
    this.title,
    this.message,
    this.onRetry,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono de error
            Icon(
              icon ?? Icons.error_outline,
              size: 80,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: AppConstants.spacingL),

            // Título
            Text(
              title ?? AppConstants.errorStateTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Mensaje de error (si existe)
            if (message != null) ...[
              const SizedBox(height: AppConstants.spacingM),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // Botón de reintentar
            if (onRetry != null) ...[
              const SizedBox(height: AppConstants.spacingL),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text(AppConstants.errorStateButton),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingL,
                    vertical: AppConstants.spacingM,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget de error compacto (para usar en cards pequeños)
class ErrorStateCompact extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorStateCompact({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            color: theme.colorScheme.error,
            size: AppConstants.iconSizeL,
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            message,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppConstants.spacingS),
            TextButton(
              onPressed: onRetry,
              child: const Text(AppConstants.errorStateButton),
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget para mostrar errores de conexión
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorWidget({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorStateWidget(
      icon: Icons.wifi_off,
      title: 'Sin conexión',
      message: 'Verificá tu conexión a internet y volvé a intentar',
      onRetry: onRetry,
    );
  }
}
