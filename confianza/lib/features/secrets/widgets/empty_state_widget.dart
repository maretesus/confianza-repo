import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

/// Widget reutilizable para mostrar estado vacío
/// Se usa cuando no hay datos para mostrar
class EmptyStateWidget extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final Widget? action;
  final String? illustrationAsset;

  const EmptyStateWidget({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    this.action,
    this.illustrationAsset,
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
            // Ilustración o icono
            if (illustrationAsset != null)
              Image.asset(
                illustrationAsset!,
                width: 200,
                height: 200,
              )
            else
              Icon(
                icon ?? Icons.inbox_outlined,
                size: 120,
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
            
            const SizedBox(height: AppConstants.spacingL),

            // Título
            Text(
              title ?? AppConstants.emptyStateTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            // Subtítulo
            if (subtitle != null) ...[
              const SizedBox(height: AppConstants.spacingM),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // Acción (botón personalizado)
            if (action != null) ...[
              const SizedBox(height: AppConstants.spacingL),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty state específico para secretos
class EmptySecretsWidget extends StatelessWidget {
  final VoidCallback? onCreateSecret;

  const EmptySecretsWidget({
    super.key,
    this.onCreateSecret,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.lock_open_outlined,
      title: AppConstants.emptyStateTitle,
      subtitle: AppConstants.emptyStateSubtitle,
      action: onCreateSecret != null
          ? ElevatedButton.icon(
              onPressed: onCreateSecret,
              icon: const Icon(Icons.add),
              label: const Text(AppConstants.fabText),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingL,
                  vertical: AppConstants.spacingM,
                ),
              ),
            )
          : null,
    );
  }
}

/// Empty state para búsqueda sin resultados
class EmptySearchWidget extends StatelessWidget {
  final String searchQuery;
  final VoidCallback? onClearSearch;

  const EmptySearchWidget({
    super.key,
    required this.searchQuery,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: 'No se encontraron resultados',
      subtitle: 'No hay secretos que coincidan con "$searchQuery"',
      action: onClearSearch != null
          ? TextButton.icon(
              onPressed: onClearSearch,
              icon: const Icon(Icons.clear),
              label: const Text('Limpiar búsqueda'),
            )
          : null,
    );
  }
}

/// Empty state para categoría sin secretos
class EmptyCategoryWidget extends StatelessWidget {
  final String category;
  final VoidCallback? onViewAll;

  const EmptyCategoryWidget({
    super.key,
    required this.category,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.category_outlined,
      title: 'Sin secretos en $category',
      subtitle: 'Aún no hay secretos en esta categoría',
      action: onViewAll != null
          ? TextButton.icon(
              onPressed: onViewAll,
              icon: const Icon(Icons.grid_view),
              label: const Text('Ver todos'),
            )
          : null,
    );
  }
}
