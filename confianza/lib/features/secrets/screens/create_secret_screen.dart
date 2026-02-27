import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/secret.dart';
import '../providers/secrets_providers.dart';
import '../../auth/providers/auth_providers.dart';

/// Pantalla para crear un nuevo secreto
class CreateSecretScreen extends ConsumerStatefulWidget {
  const CreateSecretScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateSecretScreen> createState() => _CreateSecretScreenState();
}

class _CreateSecretScreenState extends ConsumerState<CreateSecretScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _videoUrlController = TextEditingController();
  
  String _selectedCategory = 'LOVE';
  bool _isAnonymous = true;
  bool _isLoading = false;

  final List<String> _categories = [
    'LOVE',
    'FAMILY',
    'FRIENDSHIP',
    'WEIRD',
    'HOT',
    'SCHOOL',
    'WORK',
    'HEALTH',
    'OTHER',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _videoUrlController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateSecret() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Obtener usuario actual (puede estar null)
      final currentUserAsync = ref.read(currentUserProvider);
      final currentUser = currentUserAsync.maybeWhen(
        data: (user) => user,
        orElse: () => null,
      );

      // Crear objeto Secret
      // Si no hay usuario autenticado, userId será null (completamente anónimo)
      final newSecret = Secret(
        id: '', // Firestore generará el ID
        userId: currentUser?.uid, // Null si no está autenticado
        videoUrl: _videoUrlController.text.isEmpty
            ? 'https://picsum.photos/400/600?random=${DateTime.now().millisecond}'
            : _videoUrlController.text,
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

      // Guardar en Firestore usando el provider
      final newSecretId = await ref.read(
        createSecretProvider(newSecret).future,
      );

      if (!mounted) return;

      if (newSecretId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Secreto guardado exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Limpiar formulario
        _titleController.clear();
        _descriptionController.clear();
        _videoUrlController.clear();
        setState(() => _selectedCategory = 'LOVE');

        // Volver a pantalla anterior después de 2 segundos
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar el secreto'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compartir un Secreto'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Instrucción
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tu secreto será guardado en la nube de forma segura',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Título del secreto
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Título del secreto *',
                  hintText: 'Ej: Mi primer secreto',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.edit),
                ),
                maxLength: 100,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un título';
                  }
                  if (value.length < 3) {
                    return 'El título debe tener al menos 3 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Descripción
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Descripción (opcional)',
                  hintText: 'Cuenta más detalles sobre tu secreto...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.description),
                ),
                maxLines: 4,
                maxLength: 500,
              ),
              const SizedBox(height: 16),

              // Categoría
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Categoría *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.category),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // URL de video (opcional)
              TextFormField(
                controller: _videoUrlController,
                decoration: InputDecoration(
                  labelText: 'URL de video (opcional)',
                  hintText: 'https://example.com/video.mp4',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.link),
                  helperText:
                      'Si no pones URL, se usará una imagen aleatoria',
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 20),

              // Switch anónimo
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Mantener anónimo',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _isAnonymous
                                  ? 'Tu nombre no será visible'
                                  : 'Tu nombre será visible',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isAnonymous,
                        onChanged: (value) {
                          setState(() => _isAnonymous = value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Botón guardar
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleCreateSecret,
                  icon: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(
                              Colors.white.withOpacity(0.7),
                            ),
                          ),
                        )
                      : const Icon(Icons.cloud_upload),
                  label: Text(
                    _isLoading ? 'Guardando...' : 'Guardar en la nube',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Botón cancelar
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
