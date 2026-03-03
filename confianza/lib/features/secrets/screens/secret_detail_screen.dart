import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/secret.dart';
import '../models/comment.dart';
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

          final anonymousId = anonymousIdAsync.maybeWhen(
            data: (id) => id,
            orElse: () => null,
          );

          // Usar ID del usuario autenticado o ID anónimo
          final userId = currentUser?.uid ?? anonymousId;
          final isLiked = userId != null &&
              secret.likedByUserIds.contains(userId);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen/Video del secreto
                Container(
                  width: double.infinity,
                  height: 300,
                  color: Colors.grey[300],
                  child: Image.network(
                    secret.videoUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) =>
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
                                if (userId != null) {
                                  if (isLiked) {
                                    ref.read(
                                      unlikeSecretProvider(
                                        (secretId, userId),
                                      ).future,
                                    );
                                  } else {
                                    ref.read(
                                      likeSecretProvider(
                                        (secretId, userId),
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
                      const SizedBox(height: 32),

                      // SECCIÓN DE COMENTARIOS
                      Text(
                        'Comentarios',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),

                      // Lista de comentarios
                      _buildCommentsList(secretId, ref, context),
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

  Widget _buildCommentsList(String secretId, WidgetRef ref, BuildContext context) {
    return ref.watch(commentsProvider(secretId)).when(
      data: (comments) {
        if (comments.isEmpty) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    'Aún no hay comentarios',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildAddCommentForm(secretId, ref, context),
            ],
          );
        }

        return Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                return _buildCommentCard(comment, context);
              },
            ),
            const SizedBox(height: 24),
            _buildAddCommentForm(secretId, ref, context),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }

  Widget _buildCommentCard(Comment comment, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[800]!),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Usuario y fecha
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  comment.isAnonymous ? 'Anónimo' : comment.userId,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.grey[300],
                  ),
                ),
                Text(
                  _formatDate(comment.createdAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Texto del comentario
            Text(
              comment.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCommentForm(String secretId, WidgetRef ref, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'Agregar comentario',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        _AddCommentWidget(secretId: secretId),
      ],
    );
  }
}

/// Widget separado para el formulario de comentarios
class _AddCommentWidget extends ConsumerStatefulWidget {
  final String secretId;

  const _AddCommentWidget({required this.secretId});

  @override
  ConsumerState<_AddCommentWidget> createState() => _AddCommentWidgetState();
}

class _AddCommentWidgetState extends ConsumerState<_AddCommentWidget> {
  final _commentController = TextEditingController();
  bool _isAnonymous = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    if (_commentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El comentario no puede estar vacío')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUserAsync = ref.read(currentUserProvider);
      final currentUser = currentUserAsync.maybeWhen(
        data: (user) => user,
        orElse: () => null,
      );

      final comment = Comment(
        id: '', // Firestore generará el ID
        secretId: widget.secretId,
        userId: currentUser?.uid ?? 'anonymous',
        text: _commentController.text,
        createdAt: DateTime.now(),
        isAnonymous: _isAnonymous,
      );

      await ref.read(
        addCommentProvider((widget.secretId, comment)).future,
      );

      _commentController.clear();
      setState(() => _isAnonymous = true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comentario agregado'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Input de comentario
        TextField(
          controller: _commentController,
          minLines: 2,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Escribe tu comentario...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 12),

        // Checkbox de anónimo y botón
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Checkbox(
                    value: _isAnonymous,
                    onChanged: (value) {
                      setState(() => _isAnonymous = value ?? true);
                    },
                  ),
                  const Text('Anónimo'),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _submitComment,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              label: const Text('Enviar'),
            ),
          ],
        ),
      ],
    );
  }
}
