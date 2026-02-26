import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

/// Widget reutilizable para mostrar estado de carga
/// Consistente en toda la app
class LoadingWidget extends StatelessWidget {
  final String? message;
  final double? size;

  const LoadingWidget({
    super.key,
    this.message,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size ?? AppConstants.iconSizeXL,
            height: size ?? AppConstants.iconSizeXL,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: AppConstants.spacingL),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget de loading inline (más pequeño)
/// Para usar dentro de botones u otros widgets
class LoadingIndicatorSmall extends StatelessWidget {
  final Color? color;

  const LoadingIndicatorSmall({
    super.key,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppConstants.iconSizeS,
      height: AppConstants.iconSizeS,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

/// Widget de loading para shimmer effect (futuro)
/// Por ahora usa el loading normal
class LoadingShimmer extends StatelessWidget {
  const LoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoadingWidget(
      message: AppConstants.loadingMessage,
    );
  }
}
