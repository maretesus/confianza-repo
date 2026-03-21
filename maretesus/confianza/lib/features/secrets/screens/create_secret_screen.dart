// …importaciones…

class _CreateSecretScreenState extends ConsumerState<CreateSecretScreen> {
  // …campos…

  Future<void> _handleCreateSecret() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    String finalVideoUrl = _videoUrl ?? _videoUrlController.text;

    try {
      if (_selectedVideoFile != null && finalVideoUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subiendo video…')),
        );
        final uploadedUrl = await _mediaService.uploadVideo(_selectedVideoFile!);
        print('Upload result: $uploadedUrl');
        if (uploadedUrl == null || uploadedUrl.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo subir el video'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isLoading = false);
          return;
        }
        finalVideoUrl = uploadedUrl;
        print('Final video URL: $finalVideoUrl');
      }

      if (finalVideoUrl.isEmpty) {
        finalVideoUrl = 'https://picsum.photos/400/600?random=${DateTime.now().millisecond}';
      }

      final currentUserAsync = ref.read(currentUserProvider);
      final currentUser = currentUserAsync.maybeWhen(data: (u) => u, orElse: () => null);

      final newSecret = Secret(
        id: '',
        userId: currentUser?.uid,
        videoUrl: finalVideoUrl,
        title: _titleController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        category: _selectedCategory,
        likes: 0,
        comments: 0,
        createdAt: DateTime.now(),
        isAnonymous: _isAnonymous,
      );

      final newSecretId = await ref.read(secretsServiceProvider).createSecret(newSecret);
      if (!mounted) return;

      if (newSecretId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Secreto publicado')),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar el secreto'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, st) {
      print('Error en _handleCreateSecret: $e');
      print(st);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ocurrió un error inesperado'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // …resto de build() …
}