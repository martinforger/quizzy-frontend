import 'package:flutter/material.dart';

import 'package:quizzy/application/discovery/usecases/get_categories.dart';
import 'package:quizzy/application/discovery/usecases/get_featured_quizzes.dart';
import 'package:quizzy/application/solo-game/useCases/start_attempt_use_case.dart';
import 'package:quizzy/application/solo-game/useCases/submit_answer_use_case.dart';
import 'package:quizzy/application/solo-game/useCases/get_summary_use_case.dart';
import 'package:quizzy/application/kahoots/usecases/create_slide.dart';
import 'package:quizzy/application/kahoots/usecases/delete_slide.dart';
import 'package:quizzy/application/kahoots/usecases/duplicate_slide.dart';
import 'package:quizzy/application/kahoots/usecases/get_slide.dart';
import 'package:quizzy/application/kahoots/usecases/list_slides.dart';
import 'package:quizzy/application/kahoots/usecases/update_slide.dart';
import 'package:quizzy/infrastructure/discovery/repositories_impl/http_discovery_repository.dart';
import 'package:quizzy/infrastructure/solo-game/data_sources/mock_game_service.dart';
import 'package:quizzy/infrastructure/solo-game/repositories/game_repository_impl.dart';
import 'package:quizzy/infrastructure/kahoots/repositories_impl/http_slides_repository.dart';
import 'package:quizzy/application/discovery/usecases/get_themes.dart';
import 'package:quizzy/application/discovery/usecases/search_quizzes.dart';
import 'package:quizzy/presentation/screens/shell/shell_screen.dart';
import 'package:quizzy/infrastructure/solo-game/data_sources/local_game_storage.dart';
import 'package:quizzy/application/solo-game/useCases/manage_local_attempt_use_case.dart';
import 'package:quizzy/application/solo-game/useCases/get_attempt_state_use_case.dart';

import 'package:quizzy/presentation/state/discovery_controller.dart';
import 'package:quizzy/presentation/state/slide_controller.dart';
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

    // Game Dependencies
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

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quizzy',
      theme: AppTheme.build(),
      home: ShellScreen(
        discoveryController: discoveryController,
        startAttemptUseCase: startAttemptUseCase,
        submitAnswerUseCase: submitAnswerUseCase,
        getSummaryUseCase: getSummaryUseCase,
        slideController: slideController,
        manageLocalAttemptUseCase: manageLocalAttemptUseCase,
        getAttemptStateUseCase: getAttemptStateUseCase,
      ),
    );
  }
}
