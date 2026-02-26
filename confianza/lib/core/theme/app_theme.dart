import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Tema centralizado de la aplicación
/// Facilita mantener consistencia visual y hacer cambios globales
class AppTheme {
  AppTheme._(); // Constructor privado

  // ==================== COLOR SCHEMES ====================

  static ColorScheme get lightColorScheme {
    return ColorScheme.fromSeed(
      seedColor: const Color(AppConstants.primaryColorValue),
      brightness: Brightness.light,
    );
  }

  static ColorScheme get darkColorScheme {
    return ColorScheme.fromSeed(
      seedColor: const Color(AppConstants.primaryColorValue),
      brightness: Brightness.dark,
    );
  }

  // ==================== TEMA CLARO ====================

  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: lightColorScheme,
      useMaterial3: true,
      
      // AppBar
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: lightColorScheme.surface,
        foregroundColor: lightColorScheme.onSurface,
        titleTextStyle: TextStyle(
          color: lightColorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingM,
          vertical: AppConstants.spacingS,
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: const Color(AppConstants.primaryColorValue),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
        ),
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: lightColorScheme.surfaceContainerHighest,
        labelStyle: TextStyle(
          color: lightColorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingM,
          vertical: AppConstants.spacingS,
        ),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusS),
        ),
      ),

      // Icon Button
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: lightColorScheme.onSurface,
        ),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: lightColorScheme.outlineVariant,
        space: 1,
        thickness: 1,
      ),
    );
  }

  // ==================== TEMA OSCURO ====================

  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: darkColorScheme,
      useMaterial3: true,
      
      // AppBar
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: darkColorScheme.surface,
        foregroundColor: darkColorScheme.onSurface,
        titleTextStyle: TextStyle(
          color: darkColorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingM,
          vertical: AppConstants.spacingS,
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: const Color(AppConstants.primaryColorValue),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
        ),
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: darkColorScheme.surfaceContainerHighest,
        labelStyle: TextStyle(
          color: darkColorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingM,
          vertical: AppConstants.spacingS,
        ),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusS),
        ),
      ),

      // Icon Button
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: darkColorScheme.onSurface,
        ),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: darkColorScheme.outlineVariant,
        space: 1,
        thickness: 1,
      ),
    );
  }

  // ==================== COLORES DE CATEGORÍAS ====================

  static Color getCategoryColor(String category, {required bool isDark}) {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    
    switch (category.toUpperCase()) {
      case AppConstants.categoryLove:
        return brightness == Brightness.light 
            ? Colors.pink.shade100 
            : Colors.pink.shade900;
      
      case AppConstants.categoryFamily:
        return brightness == Brightness.light 
            ? Colors.green.shade100 
            : Colors.green.shade900;
      
      case AppConstants.categoryFriendship:
        return brightness == Brightness.light 
            ? Colors.blue.shade100 
            : Colors.blue.shade900;
      
      case AppConstants.categoryHot:
        return brightness == Brightness.light 
            ? Colors.orange.shade100 
            : Colors.orange.shade900;
      
      case AppConstants.categoryWeird:
        return brightness == Brightness.light 
            ? Colors.purple.shade100 
            : Colors.purple.shade900;
      
      default:
        return brightness == Brightness.light 
            ? Colors.grey.shade200 
            : Colors.grey.shade800;
    }
  }

  // ==================== TEXT STYLES COMUNES ====================

  static TextStyle get headlineStyle => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get titleStyle => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get bodyStyle => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static TextStyle get captionStyle => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );
}
