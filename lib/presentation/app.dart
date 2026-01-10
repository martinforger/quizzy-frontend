import 'package:flutter/foundation.dart';
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
import 'package:quizzy/application/solo-game/useCases/manage_local_attempt_use_case.dart';
import 'package:quizzy/application/solo-game/useCases/get_attempt_state_use_case.dart';
import 'package:quizzy/infrastructure/auth/repositories_impl/http_auth_repository.dart';
import 'package:quizzy/infrastructure/auth/repositories_impl/http_profile_repository.dart';
import 'package:quizzy/infrastructure/auth/repositories_impl/mock_auth_repository.dart';
import 'package:quizzy/infrastructure/auth/repositories_impl/mock_profile_repository.dart';
import 'package:quizzy/infrastructure/discovery/repositories_impl/http_discovery_repository.dart';
import 'package:quizzy/infrastructure/kahoots/repositories_impl/http_kahoots_repository.dart';
import 'package:quizzy/infrastructure/solo-game/data_sources/http_game_service.dart';
import 'package:quizzy/infrastructure/solo-game/data_sources/local_game_storage.dart';
import 'package:quizzy/infrastructure/solo-game/repositories/game_repository_impl.dart';
import 'package:quizzy/presentation/screens/shell/shell_screen.dart';
import 'package:quizzy/presentation/state/auth_controller.dart';
import 'package:quizzy/presentation/state/discovery_controller.dart';
import 'package:quizzy/presentation/state/kahoot_controller.dart';
import 'package:quizzy/presentation/state/profile_controller.dart';
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

    final discoveryRepository = HttpDiscoveryRepository(client: http.Client());
    final discoveryController = DiscoveryController(
      getCategoriesUseCase: GetCategoriesUseCase(discoveryRepository),
      getFeaturedQuizzesUseCase: GetFeaturedQuizzesUseCase(discoveryRepository),
      searchQuizzesUseCase: SearchQuizzesUseCase(discoveryRepository),
      getThemesUseCase: GetThemesUseCase(discoveryRepository),
    );

    final gameService = HttpGameService(httpClient: http.Client());
    final localGameStorage = LocalGameStorage();
    final gameRepository = GameRepositoryImpl(gameService, localGameStorage);
    final startAttemptUseCase = StartAttemptUseCase(gameRepository);
    final submitAnswerUseCase = SubmitAnswerUseCase(gameRepository);
    final getSummaryUseCase = GetSummaryUseCase(gameRepository);
    final manageLocalAttemptUseCase = ManageLocalAttemptUseCase(gameRepository);
    final getAttemptStateUseCase = GetAttemptStateUseCase(gameRepository);

    final kahootsRepository = HttpKahootsRepository(client: http.Client());
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
              profileController: profileController,
              authController: authController,
              defaultKahootAuthorId: defaultAuthorId,
              defaultKahootThemeId: defaultThemeId,
              onLogout: _onLogout,
            ),
    );
  }
}
