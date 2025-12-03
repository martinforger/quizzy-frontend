import 'package:flutter/material.dart';

import 'package:quizzy/application/discovery/usecases/get_categories.dart';
import 'package:quizzy/application/discovery/usecases/get_featured_quizzes.dart';
import 'package:quizzy/application/discovery/usecases/get_themes.dart';
import 'package:quizzy/application/discovery/usecases/search_quizzes.dart';
import 'package:quizzy/infrastructure/discovery/repositories_impl/http_discovery_repository.dart';
import 'package:quizzy/presentation/screens/shell/shell_screen.dart';
import 'package:quizzy/presentation/screens/splash/splash_screen.dart';
import 'package:quizzy/presentation/state/discovery_controller.dart';
import 'package:quizzy/presentation/theme/app_theme.dart';
import 'package:http/http.dart' as http;

class QuizzyApp extends StatelessWidget {
  const QuizzyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Base URL del mock server. Ajusta con la IP de tu maquina para emuladores/dispositivos.
    const mockBaseUrl = String.fromEnvironment(
      'MOCK_BASE_URL',
      defaultValue: 'http://10.0.2.2:8080',
    );

    // Inyecta repositorio y casos de uso para mantener la arquitectura hexagonal.
    final discoveryRepository = HttpDiscoveryRepository(
      client: http.Client(),
      baseUrl: mockBaseUrl,
    );
    final discoveryController = DiscoveryController(
      getCategoriesUseCase: GetCategoriesUseCase(discoveryRepository),
      getFeaturedQuizzesUseCase: GetFeaturedQuizzesUseCase(discoveryRepository),
      searchQuizzesUseCase: SearchQuizzesUseCase(discoveryRepository),
      getThemesUseCase: GetThemesUseCase(discoveryRepository),
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
