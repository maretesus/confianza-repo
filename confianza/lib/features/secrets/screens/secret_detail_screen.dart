import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/secret.dart';
import '../providers/secrets_providers.dart';
import '../../auth/providers/auth_providers.dart';
import '../../auth/providers/anonymous_user_provider.dart';

/// Pantalla que muestra el detalle de un secreto
class SecretDetailScreen extends ConsumerWidget {
  final String secretId;

  const SecretDetailScreen({
    super.key,
    required this.secretId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtener el secreto específico
    final secretAsync = ref.watch(secretByIdProvider(secretId));
    final currentUserAsync = ref.watch(currentUserProvider);
    final anonymousIdAsync = ref.watch(anonymousUserIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle'),
        centerTitle: true,
        elevation: 0,
      ),
      body: secretAsync.when(
        data: (secret) {
          if (secret == null) {
            return const Center(
              child: Text('Secreto no encontrado'),
            );
          }

          final currentUser = currentUserAsync.maybeWhen(
            data: (user) => user,
            orElse: () => null,
          );

          final currentUserId = currentUser?.uid;
          final isLiked = currentUserId != null &&
              secret.likedByUserIds.contains(currentUserId);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen/Video del secreto
                Container(
                  width: double.infinity,
                  height: 300,
                  color: Colors.grey[300],
                  child: CachedNetworkImage(
                    imageUrl: secret.videoUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.broken_image),
                  ),
                ),

                // Contenido del secreto
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      Text(
                        secret.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Categoría y anónimo
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              secret.category,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[800],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (secret.isAnonymous) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Anónimo',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Descripción
                      if (secret.description != null &&
                          secret.description!.isNotEmpty) ...[
                        Text(
                          'Descripción',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          secret.description!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Stats (likes y comentarios)
                      Row(
                        children: [
                          // Likes
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (currentUserId != null) {
                                  if (isLiked) {
                                    ref.read(
                                      unlikeSecretProvider(
                                        (secretId, currentUserId),
                                      ).future,
                                    );
                                  } else {
                                    ref.read(
                                      likeSecretProvider(
                                        (secretId, currentUserId),
                                      ).future,
                                    );
                                  }
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isLiked
                                      ? Colors.red[100]
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isLiked
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: isLiked
                                          ? Colors.red
                                          : Colors.grey[600],
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${secret.likes}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isLiked
                                            ? Colors.red
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Comentarios
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.comment_outlined,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${secret.comments}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Fecha de creación
                      Text(
                        'Publicado: ${_formatDate(secret.createdAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Hace unos momentos';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} horas';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
