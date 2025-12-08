import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quizzy/application/discovery/usecases/get_categories.dart';
import 'package:quizzy/application/discovery/usecases/get_featured_quizzes.dart';
import 'package:quizzy/application/discovery/usecases/get_themes.dart';
import 'package:quizzy/application/discovery/usecases/search_quizzes.dart';
import 'package:quizzy/application/solo-game/useCases/get_summary_use_case.dart';
import 'package:quizzy/application/solo-game/useCases/start_attempt_use_case.dart';
import 'package:quizzy/application/solo-game/useCases/submit_answer_use_case.dart';
import 'package:quizzy/infrastructure/discovery/repositories_impl/http_discovery_repository.dart';
import 'package:quizzy/infrastructure/solo-game/data_sources/mock_game_service.dart';
import 'package:quizzy/infrastructure/solo-game/repositories/game_repository_impl.dart';
import 'package:quizzy/presentation/screens/shell/shell_screen.dart';
import 'package:quizzy/presentation/state/discovery_controller.dart';
import 'package:quizzy/presentation/theme/app_theme.dart';

class QuizzyApp extends StatelessWidget {
  const QuizzyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const mockBaseUrl = String.fromEnvironment(
      'MOCK_BASE_URL',
      defaultValue: 'https://quizzy-backend-0wh2.onrender.com/api/',
    );

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

    final gameService = MockGameService();
    final gameRepository = GameRepositoryImpl(gameService);
    final startAttemptUseCase = StartAttemptUseCase(gameRepository);
    final submitAnswerUseCase = SubmitAnswerUseCase(gameRepository);
    final getSummaryUseCase = GetSummaryUseCase(gameRepository);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quizzy',
      theme: AppTheme.build(),
      home: ShellScreen(
        discoveryController: discoveryController,
        startAttemptUseCase: startAttemptUseCase,
        submitAnswerUseCase: submitAnswerUseCase,
        getSummaryUseCase: getSummaryUseCase,
      ),
    );
  }
}
