import 'package:flutter/material.dart';

import 'package:quizzy/application/discovery/usecases/get_categories.dart';
import 'package:quizzy/application/discovery/usecases/get_featured_quizzes.dart';
import 'package:quizzy/application/solo-game/useCases/start_attempt_use_case.dart';
import 'package:quizzy/application/solo-game/useCases/submit_answer_use_case.dart';
import 'package:quizzy/application/solo-game/useCases/get_summary_use_case.dart';
import 'package:quizzy/infrastructure/discovery/repositories_impl/mock_discovery_repository.dart';
import 'package:quizzy/infrastructure/solo-game/data_sources/mock_game_service.dart';
import 'package:quizzy/infrastructure/solo-game/repositories/game_repository_impl.dart';
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

    // Game Dependencies
    final gameService = MockGameService();
    final gameRepository = GameRepositoryImpl(gameService);
    final startAttemptUseCase = StartAttemptUseCase(gameRepository);
    final submitAnswerUseCase = SubmitAnswerUseCase(gameRepository);
    final getSummaryUseCase = GetSummaryUseCase(gameRepository);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quizzy',
      theme: AppTheme.build(),
      home: SplashScreen(
        nextScreen: ShellScreen(
          discoveryController: discoveryController,
          startAttemptUseCase: startAttemptUseCase,
          submitAnswerUseCase: submitAnswerUseCase,
          getSummaryUseCase: getSummaryUseCase,
        ),
      ),
    );
  }
}
