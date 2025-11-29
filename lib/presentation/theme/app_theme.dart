import 'package:flutter/material.dart';

/// Tokens de UI reutilizables para colores, radios, sombras y tema.
class AppColors {
  static const primary = Color(0xFFFF7A00);
  static const surface = Color(0xFF141116);
  static const card = Color(0xFF1E1B21);
  static const accentTeal = Color(0xFF1DD8D2);
  static const textMuted = Color(0xFFCCCCCC);
  static const border = Color(0xFF2C2830);
}

class AppSpacing {
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s18 = 18;
  static const double s24 = 24;
}

class AppRadii {
  static const double card = 18;
  static const double pill = 20;
  static const double fab = 28;
}

class AppShadows {
  static List<BoxShadow> medium = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.18),
      blurRadius: 16,
      offset: const Offset(0, 12),
    ),
  ];

  static List<BoxShadow> soft = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 10,
      offset: const Offset(0, 8),
    ),
  ];
}

/// Construye el tema global de la aplicacion siguiendo buenas practicas.
class AppTheme {
  static ThemeData build() {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      brightness: Brightness.dark,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.surface,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accentTeal,
        surface: AppColors.surface,
        brightness: Brightness.dark,
      ),
      textTheme: base.textTheme.copyWith(
        headlineMedium: const TextStyle(fontWeight: FontWeight.w700, fontSize: 24),
        titleMedium: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        bodyMedium: const TextStyle(fontSize: 14, color: AppColors.textMuted),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      cardColor: AppColors.card,
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: StadiumBorder(),
        elevation: 4,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.white70,
        showUnselectedLabels: true,
      ),
    );
  }
}
