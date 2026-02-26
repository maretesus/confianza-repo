import 'package:flutter/material.dart';
import '../models/secret.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

/// Widget que muestra una tarjeta con información de un secreto
/// Diseño mejorado con animaciones y mejor UX
class SecretCard extends StatefulWidget {
  final Secret secret;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final bool isLiked;

  const SecretCard({
    super.key,
    required this.secret,
    this.onTap,
    this.onLike,
    this.onComment,
    this.isLiked = false,
  });

  @override
  State<SecretCard> createState() => _SecretCardState();
}

class _SecretCardState extends State<SecretCard> 
    with SingleTickerProviderStateMixin {
  late AnimationController _likeAnimationController;
  late Animation<double> _likeAnimation;

  @override
  void initState() {
    super.initState();
    _likeAnimationController = AnimationController(
      duration: AppConstants.fastAnimation,
      vsync: this,
    );
    _likeAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _likeAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    super.dispose();
  }

  void _handleLike() {
    _likeAnimationController.forward().then((_) {
      _likeAnimationController.reverse();
    });
    widget.onLike?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header: Título y Categoría
              _buildHeader(theme, isDark),

              // Descripción
              if (widget.secret.description != null) ...[
                const SizedBox(height: AppConstants.spacingM),
                _buildDescription(theme),
              ],

              const SizedBox(height: AppConstants.spacingM),

              // Footer: Stats y Tiempo
              _buildFooter(theme),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye el header con título y categoría
  Widget _buildHeader(ThemeData theme, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título
        Expanded(
          child: Text(
            widget.secret.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        
        const SizedBox(width: AppConstants.spacingS),
        
        // Chip de categoría
        _buildCategoryChip(theme, isDark),
      ],
    );
  }

  /// Construye el chip de categoría con emoji
  Widget _buildCategoryChip(ThemeData theme, bool isDark) {
    final emoji = AppConstants.categoryEmojis[widget.secret.category] ?? '📝';
    final color = AppTheme.getCategoryColor(widget.secret.category, isDark: isDark);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingM,
        vertical: AppConstants.spacingS,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: AppConstants.spacingXS),
          Text(
            widget.secret.category,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye la descripción
  Widget _buildDescription(ThemeData theme) {
    return Text(
      widget.secret.description!,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        height: 1.4,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Construye el footer con stats y tiempo
  Widget _buildFooter(ThemeData theme) {
    return Row(
      children: [
        // Botón de like
        _buildLikeButton(theme),
        
        const SizedBox(width: AppConstants.spacingL),
        
        // Botón de comentarios
        _buildCommentButton(theme),
        
        const Spacer(),
        
        // Timestamp
        _buildTimestamp(theme),
      ],
    );
  }

  /// Construye el botón de like con animación
  Widget _buildLikeButton(ThemeData theme) {
    return InkWell(
      onTap: _handleLike,
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusS),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingS,
          vertical: AppConstants.spacingXS,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _likeAnimation,
              child: Icon(
                widget.isLiked ? Icons.favorite : Icons.favorite_border,
                size: AppConstants.iconSizeS,
                color: widget.isLiked 
                    ? Colors.red 
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppConstants.spacingXS),
            Text(
              _formatCount(widget.secret.likes),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye el botón de comentarios
  Widget _buildCommentButton(ThemeData theme) {
    return InkWell(
      onTap: widget.onComment ?? widget.onTap,
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusS),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingS,
          vertical: AppConstants.spacingXS,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: AppConstants.iconSizeS,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: AppConstants.spacingXS),
            Text(
              _formatCount(widget.secret.comments),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye el timestamp
  Widget _buildTimestamp(ThemeData theme) {
    return Text(
      _formatTimestamp(widget.secret.createdAt),
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontSize: 12,
      ),
    );
  }

  /// Formatea números grandes (ej: 1.2K, 3.5M)
  String _formatCount(int count) {
    if (count < 1000) {
      return count.toString();
    } else if (count < 1000000) {
      final k = count / 1000;
      return '${k.toStringAsFixed(k >= 10 ? 0 : 1)}K';
    } else {
      final m = count / 1000000;
      return '${m.toStringAsFixed(m >= 10 ? 0 : 1)}M';
    }
  }

  /// Formatea el timestamp de forma relativa
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}sem';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}m';
    } else {
      return '${(difference.inDays / 365).floor()}a';
    }
  }
}

/// Versión compacta del secret card (para listas densas)
class SecretCardCompact extends StatelessWidget {
  final Secret secret;
  final VoidCallback? onTap;

  const SecretCardCompact({
    super.key,
    required this.secret,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingM,
        vertical: AppConstants.spacingXS,
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(
          secret.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          secret.description ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${secret.likes}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
