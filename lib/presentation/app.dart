import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quizzy/application/discovery/usecases/get_categories.dart';
import 'package:quizzy/application/discovery/usecases/get_featured_quizzes.dart';
import 'package:quizzy/application/discovery/usecases/get_themes.dart';
import 'package:quizzy/application/discovery/usecases/search_quizzes.dart';
import 'package:quizzy/application/kahoots/usecases/create_kahoot.dart';
import 'package:quizzy/application/kahoots/usecases/delete_kahoot.dart';
import 'package:quizzy/application/kahoots/usecases/get_kahoot.dart';
import 'package:quizzy/application/kahoots/usecases/update_kahoot.dart';
import 'package:quizzy/application/solo-game/useCases/get_summary_use_case.dart';
import 'package:quizzy/application/solo-game/useCases/start_attempt_use_case.dart';
import 'package:quizzy/application/solo-game/useCases/submit_answer_use_case.dart';
import 'package:quizzy/infrastructure/discovery/repositories_impl/http_discovery_repository.dart';
import 'package:quizzy/infrastructure/kahoots/repositories_impl/http_kahoots_repository.dart';
import 'package:quizzy/infrastructure/solo-game/data_sources/mock_game_service.dart';
import 'package:quizzy/infrastructure/solo-game/repositories/game_repository_impl.dart';
import 'package:quizzy/presentation/screens/shell/shell_screen.dart';
import 'package:quizzy/presentation/state/discovery_controller.dart';
import 'package:quizzy/presentation/state/kahoot_controller.dart';
import 'package:quizzy/presentation/theme/app_theme.dart';

class QuizzyApp extends StatelessWidget {
  const QuizzyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const mockBaseUrl = String.fromEnvironment(
      'MOCK_BASE_URL',
      defaultValue: 'http://10.0.2.2:3000/',
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
    final localGameStorage = LocalGameStorage();
    final gameRepository = GameRepositoryImpl(gameService, localGameStorage);
    final startAttemptUseCase = StartAttemptUseCase(gameRepository);
    final submitAnswerUseCase = SubmitAnswerUseCase(gameRepository);
    final getSummaryUseCase = GetSummaryUseCase(gameRepository);
    final manageLocalAttemptUseCase = ManageLocalAttemptUseCase(gameRepository);
    final getAttemptStateUseCase = GetAttemptStateUseCase(gameRepository);

    // Slides (épica 3)
    final slidesRepository = HttpSlidesRepository(
      client: http.Client(),
      baseUrl: mockBaseUrl,
    );
    final slideController = SlideController(
      listSlidesUseCase: ListSlidesUseCase(slidesRepository),
      getSlideUseCase: GetSlideUseCase(slidesRepository),
      createSlideUseCase: CreateSlideUseCase(slidesRepository),
      updateSlideUseCase: UpdateSlideUseCase(slidesRepository),
      duplicateSlideUseCase: DuplicateSlideUseCase(slidesRepository),
      deleteSlideUseCase: DeleteSlideUseCase(slidesRepository),
    );

    final kahootsRepository = HttpKahootsRepository(
      client: http.Client(),
      baseUrl: mockBaseUrl,
    );
    final kahootController = KahootController(
      createKahootUseCase: CreateKahootUseCase(kahootsRepository),
      updateKahootUseCase: UpdateKahootUseCase(kahootsRepository),
      getKahootUseCase: GetKahootUseCase(kahootsRepository),
      deleteKahootUseCase: DeleteKahootUseCase(kahootsRepository),
    );

    const defaultAuthorId = String.fromEnvironment(
      'DEFAULT_AUTHOR_ID',
      defaultValue: 'bd64df91-e362-4f32-96c2-5ed08c0ce843',
    );
    const defaultThemeId = String.fromEnvironment(
      'DEFAULT_THEME_ID',
      defaultValue: '8911c649-5db0-453d-8e1a-23331ffa40b9',
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quizzy',
      theme: AppTheme.build(),
      home: ShellScreen(
        discoveryController: discoveryController,
        startAttemptUseCase: startAttemptUseCase,
        submitAnswerUseCase: submitAnswerUseCase,
        getSummaryUseCase: getSummaryUseCase,
        kahootController: kahootController,
        defaultKahootAuthorId: defaultAuthorId,
        defaultKahootThemeId: defaultThemeId,
      ),
    );
  }
}
