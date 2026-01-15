import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizzy/injection_container.dart';
import 'package:http/http.dart' as http;
import 'package:quizzy/application/discovery/usecases/get_categories.dart';
import 'package:quizzy/application/discovery/usecases/get_featured_quizzes.dart';
import 'package:quizzy/application/discovery/usecases/get_themes.dart';
import 'package:quizzy/application/discovery/usecases/search_quizzes.dart';
import 'package:quizzy/application/kahoots/usecases/create_kahoot.dart';
import 'package:quizzy/application/kahoots/usecases/delete_kahoot.dart';
import 'package:quizzy/application/kahoots/usecases/get_kahoot.dart';
import 'package:quizzy/application/kahoots/usecases/update_kahoot.dart';
import 'package:quizzy/application/kahoots/usecases/inspect_kahoot.dart';
import 'package:quizzy/application/media/usecases/list_theme_media.dart';
import 'package:quizzy/application/media/usecases/upload_media.dart';
import 'package:quizzy/application/reports/usecases/get_multiplayer_result.dart';
import 'package:quizzy/application/reports/usecases/get_my_results.dart';
import 'package:quizzy/application/reports/usecases/get_session_report.dart';
import 'package:quizzy/application/reports/usecases/get_singleplayer_result.dart';
import 'package:quizzy/application/solo-game/useCases/get_summary_use_case.dart';
import 'package:quizzy/application/solo-game/useCases/start_attempt_use_case.dart';
import 'package:quizzy/application/solo-game/useCases/submit_answer_use_case.dart';
import 'package:quizzy/application/solo-game/useCases/manage_local_attempt_use_case.dart';
import 'package:quizzy/application/solo-game/useCases/get_attempt_state_use_case.dart';
import 'package:quizzy/infrastructure/auth/repositories_impl/http_auth_repository.dart';
import 'package:quizzy/infrastructure/auth/repositories_impl/http_profile_repository.dart';
import 'package:quizzy/infrastructure/auth/repositories_impl/mock_auth_repository.dart';
import 'package:quizzy/infrastructure/auth/repositories_impl/mock_profile_repository.dart';
import 'package:quizzy/infrastructure/discovery/repositories_impl/http_discovery_repository.dart';
import 'package:quizzy/infrastructure/kahoots/repositories_impl/http_kahoots_repository.dart';
import 'package:quizzy/infrastructure/media/http_media_repository.dart';
import 'package:quizzy/infrastructure/reports/http_reports_repository.dart';
import 'package:quizzy/infrastructure/solo-game/data_sources/mock_game_service.dart';
import 'package:quizzy/infrastructure/solo-game/data_sources/local_game_storage.dart';
import 'package:quizzy/application/library/usecases/get_completed.dart';
import 'package:quizzy/application/library/usecases/get_favorites.dart';
import 'package:quizzy/application/library/usecases/get_in_progress.dart';
import 'package:quizzy/application/library/usecases/get_my_creations.dart';
import 'package:quizzy/application/library/usecases/mark_as_favorite.dart';
import 'package:quizzy/application/library/usecases/unmark_as_favorite.dart';
import 'package:quizzy/infrastructure/library/repositories/http_library_repository.dart';
import 'package:quizzy/infrastructure/library/repositories/mock_library_repository.dart';
import 'package:quizzy/presentation/bloc/library/library_cubit.dart';
import 'package:quizzy/infrastructure/solo-game/data_sources/http_game_service.dart';
import 'package:quizzy/presentation/bloc/multiplayer/multiplayer_game_cubit.dart';
import 'package:quizzy/infrastructure/solo-game/repositories/game_repository_impl.dart';
import 'package:quizzy/infrastructure/solo-game/data_sources/local_game_storage.dart';
import 'package:quizzy/presentation/screens/shell/shell_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:quizzy/presentation/state/auth_controller.dart';
import 'package:quizzy/presentation/state/discovery_controller.dart';
import 'package:quizzy/presentation/state/kahoot_controller.dart';
import 'package:quizzy/presentation/state/media_controller.dart';
import 'package:quizzy/presentation/state/profile_controller.dart';
import 'package:quizzy/presentation/state/reports_controller.dart';
import 'package:quizzy/presentation/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quizzy/application/auth/usecases/login_use_case.dart';
import 'package:quizzy/application/auth/usecases/register_use_case.dart';
import 'package:quizzy/application/auth/usecases/logout_use_case.dart';
import 'package:quizzy/application/auth/usecases/request_password_reset_use_case.dart';
import 'package:quizzy/application/auth/usecases/confirm_password_reset_use_case.dart';
import 'package:quizzy/application/auth/usecases/get_profile_use_case.dart';
import 'package:quizzy/application/auth/usecases/update_profile_use_case.dart';
import 'package:quizzy/application/auth/usecases/update_password_use_case.dart';

import 'package:quizzy/infrastructure/core/authenticated_http_client.dart';
import 'package:quizzy/infrastructure/core/backend_config.dart';

import 'package:quizzy/presentation/screens/auth/login_screen.dart';
import 'package:quizzy/presentation/screens/splash/splash_screen.dart';

class QuizzyApp extends StatefulWidget {
  const QuizzyApp({super.key, required this.sharedPreferences});

  final SharedPreferences sharedPreferences;

  @override
  State<QuizzyApp> createState() => _QuizzyAppState();
}

class _QuizzyAppState extends State<QuizzyApp> {
  bool _showSplash = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() {
    // Simple check if token exists (you might want to validate it properly)
    final token = widget.sharedPreferences.getString('accessToken');
    setState(() {
      _isAuthenticated = token != null && token.isNotEmpty;
    });
  }

  void _onSplashComplete() {
    setState(() {
      _showSplash = false;
    });
  }

  void _onLoginSuccess() {
    setState(() {
      _isAuthenticated = true;
    });
  }

  void _onLogout() {
    setState(() {
      _isAuthenticated = false;
    });
  }

  String _getBaseUrl() {
    const envUrl = String.fromEnvironment('MOCK_BASE_URL');
    if (envUrl.isNotEmpty) return envUrl;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/';
    }
    return 'http://127.0.0.1:3000/';
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
      'Using Backend: ${BackendSettings.currentEnvName} -> ${BackendSettings.baseUrl}',
    );

    // Use this flag to switch between real backend and mock repositories for development

    const bool useMockRepositories = false;

    final baseClient = http.Client();
    final authenticatedClient = AuthenticatedHttpClient(
      baseClient,
      widget.sharedPreferences,
    );

    // AuthRepository: Uses BackendSettings.baseUrl dynamically
    final authRepository = useMockRepositories
        ? MockAuthRepository()
        : HttpAuthRepository(
            client: authenticatedClient,
            sharedPreferences: widget.sharedPreferences,
          );
    final authController = AuthController(
      loginUseCase: LoginUseCase(authRepository),
      registerUseCase: RegisterUseCase(authRepository),
      logoutUseCase: LogoutUseCase(authRepository),
      requestPasswordResetUseCase: RequestPasswordResetUseCase(authRepository),
      confirmPasswordResetUseCase: ConfirmPasswordResetUseCase(authRepository),
    );

    // ProfileRepository: Uses BackendSettings.baseUrl dynamically
    final profileRepository = useMockRepositories
        ? MockProfileRepository()
        : HttpProfileRepository(client: authenticatedClient);
    final profileController = ProfileController(
      getProfileUseCase: GetProfileUseCase(profileRepository),
      updateProfileUseCase: UpdateProfileUseCase(profileRepository),
      updatePasswordUseCase: UpdatePasswordUseCase(profileRepository),
    );
    // Discovery uses authenticated client for endpoints that may require auth
    final discoveryRepository = HttpDiscoveryRepository(
      client: authenticatedClient,
    );

    // Library Repository
    final libraryRepository = HttpLibraryRepository(
      client: authenticatedClient,
    );

    final markAsFavoriteUseCase = MarkAsFavoriteUseCase(libraryRepository);
    final unmarkAsFavoriteUseCase = UnmarkAsFavoriteUseCase(libraryRepository);

    final libraryCubit = LibraryCubit(
      getMyCreationsUseCase: GetMyCreationsUseCase(libraryRepository),
      getFavoritesUseCase: GetFavoritesUseCase(libraryRepository),
      getInProgressUseCase: GetInProgressUseCase(libraryRepository),
      getCompletedUseCase: GetCompletedUseCase(libraryRepository),
      markAsFavoriteUseCase: markAsFavoriteUseCase,
      unmarkAsFavoriteUseCase: unmarkAsFavoriteUseCase,
    );

    final discoveryController = DiscoveryController(
      getCategoriesUseCase: GetCategoriesUseCase(discoveryRepository),
      getFeaturedQuizzesUseCase: GetFeaturedQuizzesUseCase(discoveryRepository),
      searchQuizzesUseCase: SearchQuizzesUseCase(discoveryRepository),
      getThemesUseCase: GetThemesUseCase(discoveryRepository),
      markAsFavoriteUseCase: markAsFavoriteUseCase,
      unmarkAsFavoriteUseCase: unmarkAsFavoriteUseCase,
    );

    // Game service needs authenticated client for /attempts endpoints
    final gameService = HttpGameService(httpClient: authenticatedClient);
    final localGameStorage = LocalGameStorage();
    final gameRepository = GameRepositoryImpl(gameService, localGameStorage);
    final startAttemptUseCase = StartAttemptUseCase(gameRepository);
    final submitAnswerUseCase = SubmitAnswerUseCase(gameRepository);
    final getSummaryUseCase = GetSummaryUseCase(gameRepository);
    final manageLocalAttemptUseCase = ManageLocalAttemptUseCase(gameRepository);
    final getAttemptStateUseCase = GetAttemptStateUseCase(gameRepository);

    // Kahoots also needs authenticated client for CRUD operations
    final kahootsRepository = HttpKahootsRepository(
      client: authenticatedClient,
    );
    final kahootController = KahootController(
      createKahootUseCase: CreateKahootUseCase(kahootsRepository),
      updateKahootUseCase: UpdateKahootUseCase(kahootsRepository),
      getKahootUseCase: GetKahootUseCase(kahootsRepository),
      deleteKahootUseCase: DeleteKahootUseCase(kahootsRepository),
      inspectKahootUseCase: InspectKahootUseCase(kahootsRepository),
    );

    // Media (epica 3)
    final mediaRepository = HttpMediaRepository(client: authenticatedClient);
    final mediaController = MediaController(
      uploadMediaUseCase: UploadMediaUseCase(mediaRepository),
      listThemeMediaUseCase: ListThemeMediaUseCase(mediaRepository),
    );

    // Reports (epica 10)
    final reportsRepository = HttpReportsRepository(
      client: authenticatedClient,
    );
    final reportsController = ReportsController(
      getSessionReportUseCase: GetSessionReportUseCase(reportsRepository),
      getMultiplayerResultUseCase: GetMultiplayerResultUseCase(
        reportsRepository,
      ),
      getSingleplayerResultUseCase: GetSingleplayerResultUseCase(
        reportsRepository,
      ),
      getMyResultsUseCase: GetMyResultsUseCase(reportsRepository),
    );

    const defaultAuthorId = String.fromEnvironment(
      'DEFAULT_AUTHOR_ID',
      defaultValue: 'bd64df91-e362-4f32-96c2-5ed08c0ce843',
    );
    const defaultThemeId = String.fromEnvironment(
      'DEFAULT_THEME_ID',
      defaultValue: '8911c649-5db0-453d-8e1a-23331ffa40b9',
    );

    return BlocProvider(
      create: (_) => getIt<MultiplayerGameCubit>(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Quizzy',
        theme: AppTheme.build(),
        home: _showSplash
            ? SplashScreen(onAnimationComplete: _onSplashComplete)
            : !_isAuthenticated
            ? LoginScreen(
                authController: authController,
                onLoginSuccess: _onLoginSuccess,
              )
            : ShellScreen(
                discoveryController: discoveryController,
                startAttemptUseCase: startAttemptUseCase,
                submitAnswerUseCase: submitAnswerUseCase,
                getSummaryUseCase: getSummaryUseCase,
                manageLocalAttemptUseCase: manageLocalAttemptUseCase,
                getAttemptStateUseCase: getAttemptStateUseCase,
                kahootController: kahootController,
                mediaController: mediaController,
                reportsController: reportsController,
                libraryCubit: libraryCubit,
                profileController: profileController,
                authController: authController,
                defaultKahootAuthorId: defaultAuthorId,
                defaultKahootThemeId: defaultThemeId,
                onLogout: _onLogout,
              ),
      ),
    );
  }
}
