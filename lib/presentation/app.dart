import 'package:flutter/material.dart';

import 'package:quizzy/application/discovery/usecases/get_categories.dart';
import 'package:quizzy/application/discovery/usecases/get_featured_quizzes.dart';
import 'package:quizzy/infrastructure/discovery/repositories_impl/mock_discovery_repository.dart';
import 'package:quizzy/presentation/screens/shell/shell_screen.dart';
import 'package:quizzy/presentation/screens/splash/splash_screen.dart';
import 'package:quizzy/presentation/state/discovery_controller.dart';
import 'package:quizzy/presentation/theme/app_theme.dart';

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
      theme: AppTheme.build(),
      home: SplashScreen(
        nextScreen: ShellScreen(discoveryController: discoveryController),
      ),
    );
  }
}
