import 'package:flutter/material.dart';

import 'package:quizzy/application/discovery/usecases/get_categories.dart';
import 'package:quizzy/application/discovery/usecases/get_featured_quizzes.dart';
import 'package:quizzy/infrastructure/discovery/repositories_impl/mock_discovery_repository.dart';
import 'package:quizzy/presentation/screens/shell/shell_screen.dart';
import 'package:quizzy/presentation/screens/splash/splash_screen.dart';
import 'package:quizzy/presentation/state/discovery_controller.dart';

const _primaryOrange = Color(0xFFFF7A00);
const _teal = Color(0xFF1DD8D2);
const _surfaceDark = Color(0xFF141116);
const _cardDark = Color(0xFF1E1B21);

class QuizzyApp extends StatelessWidget {
  const QuizzyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Inyecta repositorio y casos de uso para mantener la arquitectura hexagonal.
    final discoveryRepository = MockDiscoveryRepository();
    final discoveryController = DiscoveryController(
      getCategoriesUseCase: GetCategoriesUseCase(discoveryRepository),
      getFeaturedQuizzesUseCase: GetFeaturedQuizzesUseCase(discoveryRepository),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quizzy',
      theme: _buildTheme(),
      home: SplashScreen(
        nextScreen: ShellScreen(discoveryController: discoveryController),
      ),
    );
  }

  // Construye el tema principal de la app.
  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _surfaceDark,
      colorScheme: ColorScheme.dark(
        primary: _primaryOrange,
        secondary: _teal,
        background: _surfaceDark,
        surface: _cardDark,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontWeight: FontWeight.w700, fontSize: 24),
        titleMedium: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        bodyMedium: TextStyle(fontSize: 14),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _surfaceDark,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primaryOrange,
        foregroundColor: Colors.white,
        shape: StadiumBorder(),
      ),
    );
  }
}
