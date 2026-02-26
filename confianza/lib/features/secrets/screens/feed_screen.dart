import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/secrets_providers.dart';
import '../widgets/secret_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/empty_state_widget.dart';

/// Pantalla principal que muestra el feed de secretos
/// Usa Riverpod para manejo de estado
class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Configurar listeners si es necesario
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Aquí se puede implementar infinite scroll en el futuro
    // Por ahora solo detectamos cuando llegamos al final
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8) {
      // TODO: Cargar más secretos
    }
  }

  @override
  Widget build(BuildContext context) {
    final secretsAsync = ref.watch(secretsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(secretsAsync, selectedCategory),
      floatingActionButton: _buildFAB(context),
    );
  }

  /// Construye el AppBar con búsqueda y filtros
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppBar(
      title: Image.asset(
  'assets/images/logo.png',
  height: 32, // Ajustá el tamaño que quieras
  fit: BoxFit.contain,
),
      centerTitle: true,
      actions: [
        // Botón de búsqueda
        IconButton(
          icon: const Icon(Icons.search),
          tooltip: 'Buscar',
          onPressed: () => _showSearchBottomSheet(context),
        ),
        
        // Botón de filtro
        IconButton(
          icon: const Icon(Icons.filter_list),
          tooltip: 'Filtrar por categoría',
          onPressed: () => _showFilterBottomSheet(context),
        ),
      ],
    );
  }

  /// Construye el cuerpo de la pantalla según el estado
  Widget _buildBody(
    AsyncValue<List> secretsAsync,
    String? selectedCategory,
  ) {
    return secretsAsync.when(
      // Estado de carga
      loading: () => const LoadingWidget(
        message: AppConstants.loadingMessage,
      ),

      // Estado de error
      error: (error, stack) => ErrorStateWidget(
        message: error.toString(),
        onRetry: () => ref.invalidate(secretsProvider),
      ),

      // Estado con datos
      data: (secrets) {
        // Si no hay secretos
        if (secrets.isEmpty) {
          return selectedCategory != null
              ? EmptyCategoryWidget(
                  category: selectedCategory,
                  onViewAll: () {
                    ref.read(selectedCategoryProvider.notifier).state = null;
                  },
                )
              : EmptySecretsWidget(
                  onCreateSecret: _handleCreateSecret,
                );
        }

        // Mostrar lista de secretos
        return _buildSecretsList(secrets);
      },
    );
  }

  /// Construye la lista de secretos con pull-to-refresh
  Widget _buildSecretsList(List secrets) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.spacingM,
        ),
        itemCount: secrets.length,
        itemBuilder: (context, index) {
          final secret = secrets[index];
          return SecretCard(
            secret: secret,
            onTap: () => _handleSecretTap(secret.id),
            onLike: () => _handleLike(secret.id),
            onComment: () => _handleComment(secret.id),
          );
        },
      ),
    );
  }

  /// Construye el Floating Action Button
  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: _handleCreateSecret,
      icon: const Icon(Icons.add),
      label: const Text(AppConstants.fabText),
    );
  }

  // ==================== MANEJADORES DE EVENTOS ====================

  /// Maneja el pull-to-refresh
  Future<void> _handleRefresh() async {
    ref.invalidate(secretsProvider);
    await ref.read(secretsProvider.future);
  }

  /// Maneja tap en un secreto
  void _handleSecretTap(String secretId) {
    // TODO: Navegar a pantalla de detalle
    _showSnackBar('Ver secreto: $secretId');
  }

  /// Maneja dar like
  void _handleLike(String secretId) {
    _showSnackBar('Like agregado');
    // TODO: Implementar like real cuando esté Firebase
  }

  /// Maneja comentar
  void _handleComment(String secretId) {
    // TODO: Navegar a comentarios
    _showSnackBar('Abrir comentarios: $secretId');
  }

  /// Maneja crear nuevo secreto
  void _handleCreateSecret() {
    // TODO: Navegar a pantalla de grabación
    _showSnackBar('Próximamente: Grabar secreto');
  }

  /// Muestra BottomSheet de búsqueda
  void _showSearchBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _buildSearchSheet(),
    );
  }

  /// Construye el BottomSheet de búsqueda
  Widget _buildSearchSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          child: Column(
            children: [
              // Handle visual
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Campo de búsqueda
              TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Buscar secretos...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (query) {
                  // TODO: Implementar búsqueda
                },
              ),
              
              const SizedBox(height: AppConstants.spacingM),
              
              // Resultados
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: const [
                    ListTile(
                      title: Text('Búsqueda próximamente'),
                      subtitle: Text('Esta función estará disponible pronto'),
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

  /// Muestra BottomSheet de filtros
  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildFilterSheet(),
    );
  }

  /// Construye el BottomSheet de filtros
  Widget _buildFilterSheet() {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtrar por categoría',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppConstants.spacingL),
          
          // Botón "Todas"
          _buildCategoryChip(
            context,
            label: 'Todas',
            isSelected: selectedCategory == null,
            onTap: () {
              ref.read(selectedCategoryProvider.notifier).state = null;
              Navigator.pop(context);
            },
          ),
          
          const SizedBox(height: AppConstants.spacingS),
          
          // Chips de categorías
          Wrap(
            spacing: AppConstants.spacingS,
            runSpacing: AppConstants.spacingS,
            children: AppConstants.allCategories.map((category) {
              final emoji = AppConstants.categoryEmojis[category] ?? '';
              return _buildCategoryChip(
                context,
                label: '$emoji $category',
                isSelected: selectedCategory == category,
                onTap: () {
                  ref.read(selectedCategoryProvider.notifier).state = category;
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Construye un chip de categoría para el filtro
  Widget _buildCategoryChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingM,
          vertical: AppConstants.spacingM,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  /// Muestra un snackbar
  void _showSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: AppConstants.snackbarDuration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
