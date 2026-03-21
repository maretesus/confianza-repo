import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/secret.dart';
import '../providers/secrets_providers.dart';
import '../../auth/providers/auth_providers.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import 'edit_secret_screen.dart';

/// Pantalla que muestra los secretos del usuario actual
class MySecretsScreen extends ConsumerWidget {
  const MySecretsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Secretos'),
        centerTitle: true,
      ),
      body: currentUserAsync.when(
        loading: () => const LoadingWidget(message: 'Cargando tus secretos...'),
        error: (error, stack) => ErrorStateWidget(
          message: 'Error: $error',
          onRetry: () => ref.invalidate(currentUserProvider),
        ),
        data: (currentUser) {
          if (currentUser == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Debes iniciar sesión para ver tus secretos'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Volver'),
                  ),
                ],
              ),
            );
          }

          // Obtener secretos del usuario actual
          final userSecretsAsync = ref.watch(
            userSecretsProvider(currentUser.uid),
          );

          return userSecretsAsync.when(
            loading: () => const LoadingWidget(
              message: 'Cargando tus secretos...',
            ),
            error: (error, stack) => ErrorStateWidget(
              message: 'Error: $error',
              onRetry: () => ref.invalidate(
                userSecretsProvider(currentUser.uid),
              ),
            ),
            data: (secrets) {
              if (secrets.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.note_add,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No has compartido secretos aún',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Comparte tu primer secreto y aparecerá aquí',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Compartir Secreto'),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(userSecretsProvider(currentUser.uid));
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: secrets.length,
                  itemBuilder: (context, index) {
                    final secret = secrets[index];
                    return _MySecretCard(secret: secret);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Card para mostrar un secreto del usuario con opciones de editar/eliminar
class _MySecretCard extends ConsumerWidget {
  final Secret secret;

  const _MySecretCard({required this.secret});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);
    
    return currentUserAsync.when(
      error: (error, stack) => Center(child: Text('Error: $error')),
      loading: () => const SizedBox.shrink(),
      data: (currentUser) {
        final isLiked = currentUser != null && secret.likedByUserIds.contains(currentUser.uid);
        
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Column(
            children: [
              // Imagen/Video
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  image: DecorationImage(
                    image: NetworkImage(secret.videoUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    // Overlay oscuro
                    Container(
                      color: Colors.black.withOpacity(0.3),
                    ),
                    // Categoría badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(secret.category),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          secret.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Contenido
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      secret.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    if (secret.description != null)
                      Text(
                        secret.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 12),
                    // Stats
                    Row(
                      children: [
                        // Botón de Like
                        GestureDetector(
                          onTap: () => _handleLike(context, ref, currentUser?.uid),
                          child: Row(
                            children: [
                              Icon(
                                isLiked ? Icons.favorite : Icons.favorite_border,
                                size: 16,
                                color: isLiked ? Colors.red.shade400 : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${secret.likes}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.comment,
                          size: 16,
                          color: Colors.blue.shade400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${secret.comments}',
                          style: const TextStyle(fontSize: 13),
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(secret.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Botones de acción
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => EditSecretScreen(secret: secret),
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit, size: 16),
                            label: const Text('Editar'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showDeleteDialog(context, ref),
                            icon: const Icon(Icons.delete, size: 16),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),
                            label: const Text('Eliminar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  void _handleLike(BuildContext context, WidgetRef ref, String? userId) {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para dar likes')),
      );
      return;
    }

    if (secret.likedByUserIds.contains(userId)) {
      // Ya dio like, quitar like
      ref.read(unlikeSecretProvider((secret.id, userId)));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Like removido')),
      );
    } else {
      // No ha dado like, dar like
      ref.read(likeSecretProvider((secret.id, userId)));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Like agregado')),
      );
    }
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar secreto'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este secreto? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref.read(deleteSecretProvider(secret.id).future);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Secreto eliminado'),
                  backgroundColor: Colors.green,
                ),
              );
              // Invalidar para recargar lista
              final currentUserAsync = ref.read(currentUserProvider);
              final currentUser = currentUserAsync.maybeWhen(
                data: (user) => user,
                orElse: () => null,
              );
              if (currentUser != null) {
                ref.invalidate(userSecretsProvider(currentUser.uid));
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'LOVE': Colors.pink,
      'FAMILY': Colors.orange,
      'FRIENDSHIP': Colors.green,
      'WEIRD': Colors.purple,
      'HOT': Colors.red,
      'SCHOOL': Colors.blue,
      'WORK': Colors.teal,
      'HEALTH': Colors.amber,
      'OTHER': Colors.grey,
    };
    return colors[category] ?? Colors.grey;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays}d';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
