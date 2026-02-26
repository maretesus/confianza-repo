/// Constantes globales de la aplicación Confident
class AppConstants {
  AppConstants._(); // Constructor privado para clase estática

  // ==================== INFORMACIÓN DE LA APP ====================
  static const String appName = 'Confident';
  static const String appTagline = 'Comparte tus secretos de forma anónima';

  // ==================== COLORES ====================
  static const int primaryColorValue = 0xFF00A8E1; // Cyan de tu logo
  static const int secondaryColorValue = 0xFF9B59B6; // Púrpura

  // ==================== CATEGORÍAS ====================
  static const String categoryLove = 'LOVE';
  static const String categoryFamily = 'FAMILY';
  static const String categoryFriendship = 'FRIENDSHIP';
  static const String categoryHot = 'HOT';
  static const String categoryWeird = 'WEIRD';

  static const List<String> allCategories = [
    categoryLove,
    categoryFamily,
    categoryFriendship,
    categoryHot,
    categoryWeird,
  ];

  static const Map<String, String> categoryEmojis = {
    categoryLove: '💗',
    categoryFamily: '👨‍👩‍👧',
    categoryFriendship: '👥',
    categoryHot: '🔥',
    categoryWeird: '👽',
  };

  // ==================== ANIMACIONES ====================
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  // ==================== ESPACIADOS ====================
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  // ==================== BORDES ====================
  static const double borderRadiusS = 8.0;
  static const double borderRadiusM = 12.0;
  static const double borderRadiusL = 16.0;
  static const double borderRadiusXL = 24.0;

  // ==================== TAMAÑOS ====================
  static const double iconSizeS = 20.0;
  static const double iconSizeM = 24.0;
  static const double iconSizeL = 32.0;
  static const double iconSizeXL = 48.0;

  // ==================== LÍMITES ====================
  static const int maxSecretTitleLength = 100;
  static const int maxSecretDescriptionLength = 500;
  static const int maxVideoLengthMinutes = 10;

  // ==================== TIEMPOS ====================
  static const Duration snackbarDuration = Duration(seconds: 3);
  static const Duration loadingTimeout = Duration(seconds: 30);

  // ==================== TEXTOS ====================
  static const String emptyStateTitle = 'No hay secretos todavía';
  static const String emptyStateSubtitle = 'Sé el primero en compartir';
  static const String errorStateTitle = 'Algo salió mal';
  static const String errorStateButton = 'Reintentar';
  static const String loadingMessage = 'Cargando secretos...';
  static const String refreshMessage = 'Actualizando...';
  static const String fabText = 'Cuenta tu secreto';
}
