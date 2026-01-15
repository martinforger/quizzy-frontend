import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'infrastructure/core/authenticated_http_client.dart';

// Import Data Sources
import 'infrastructure/solo-game/data_sources/http_game_service.dart';
import 'infrastructure/solo-game/data_sources/local_game_storage.dart';
import 'infrastructure/multiplayer-game/data_sources/multiplayer_session_http_service.dart';
import 'infrastructure/multiplayer-game/data_sources/multiplayer_socket_service.dart';
import 'infrastructure/auth/repositories_impl/http_auth_repository.dart';

// Import Repositories
import 'domain/solo-game/repositories/game_repository.dart';
import 'infrastructure/solo-game/repositories/game_repository_impl.dart';
import 'domain/multiplayer-game/repositories/multiplayer_game_repository.dart';
import 'infrastructure/multiplayer-game/repositories/multiplayer_game_repository_impl.dart';
import 'domain/auth/repositories/auth_repository.dart';
import 'domain/library/repositories/i_library_repository.dart';
import 'infrastructure/library/repositories/http_library_repository.dart';

// Import Use Cases - Multiplayer
import 'application/multiplayer-game/usecases/create_session_use_case.dart';
import 'application/multiplayer-game/usecases/get_session_pin_use_case.dart';
import 'application/multiplayer-game/usecases/connect_to_session_use_case.dart';
import 'application/multiplayer-game/usecases/join_as_player_use_case.dart';
import 'application/multiplayer-game/usecases/start_game_use_case.dart';
import 'application/multiplayer-game/usecases/submit_answer_use_case.dart';
import 'application/multiplayer-game/usecases/next_phase_use_case.dart';
import 'application/multiplayer-game/usecases/end_session_use_case.dart';

// Import Use Cases - Solo Game
import 'application/solo-game/useCases/start_attempt_use_case.dart';
import 'application/solo-game/useCases/submit_answer_use_case.dart';
import 'application/solo-game/useCases/get_summary_use_case.dart';
import 'application/solo-game/useCases/manage_local_attempt_use_case.dart';
import 'application/solo-game/useCases/get_attempt_state_use_case.dart';

// Import Use Cases - Auth
import 'application/auth/usecases/login_use_case.dart';
import 'application/auth/usecases/register_use_case.dart';
import 'application/auth/usecases/logout_use_case.dart';
import 'application/auth/usecases/request_password_reset_use_case.dart';
import 'application/auth/usecases/confirm_password_reset_use_case.dart';

// Import Use Cases - Library
import 'application/library/usecases/get_my_creations.dart';
import 'application/library/usecases/get_favorites.dart';
import 'application/library/usecases/mark_as_favorite.dart';
import 'application/library/usecases/unmark_as_favorite.dart';
import 'application/library/usecases/get_in_progress.dart';
import 'application/library/usecases/get_completed.dart';

// Import Notifications
import 'domain/notifications/repositories/notification_repository.dart';
import 'infrastructure/notifications/repositories_impl/http_notification_repository.dart';
import 'infrastructure/notifications/repositories_impl/mock_notification_repository.dart';
import 'application/notifications/usecases/register_device_use_case.dart';
import 'application/notifications/usecases/unregister_device_use_case.dart';
import 'application/notifications/usecases/get_notifications_use_case.dart';
import 'application/notifications/usecases/mark_notification_read_use_case.dart';

// Import Cubits/Controllers
import 'presentation/bloc/multiplayer/multiplayer_game_cubit.dart';
import 'presentation/bloc/game_cubit.dart';
import 'presentation/bloc/library/library_cubit.dart';
import 'presentation/bloc/notifications/notifications_cubit.dart';
import 'presentation/state/auth_controller.dart';

import 'infrastructure/notifications/services/push_notification_service.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);
  getIt.registerLazySingleton(() => http.Client());

  // Firebase / Push Notifications
  getIt.registerLazySingleton(() => PushNotificationService());

  // Core
  getIt.registerLazySingleton<AuthenticatedHttpClient>(
    () => AuthenticatedHttpClient(getIt(), getIt()),
  );

  // Data Sources
  getIt.registerLazySingleton<HttpGameService>(
    () => HttpGameService(
      httpClient: getIt<AuthenticatedHttpClient>(),
      accessToken:
          null, // Access token handled by AuthenticatedHttpClient usually, or set manually
    ),
  );

  getIt.registerLazySingleton<LocalGameStorage>(() => LocalGameStorage());

  getIt.registerLazySingleton<MultiplayerSessionHttpService>(
    () => MultiplayerSessionHttpService(
      httpClient: getIt<AuthenticatedHttpClient>(),
    ),
  );
  getIt.registerLazySingleton<MultiplayerSocketService>(
    () => MultiplayerSocketService(),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => HttpAuthRepository(
      client: getIt<AuthenticatedHttpClient>(),
      sharedPreferences: getIt(),
    ),
  );

  getIt.registerLazySingleton<GameRepository>(
    () =>
        GameRepositoryImpl(getIt<HttpGameService>(), getIt<LocalGameStorage>()),
  );

  getIt.registerLazySingleton<MultiplayerGameRepository>(
    () => MultiplayerGameRepositoryImpl(
      getIt<MultiplayerSessionHttpService>(),
      getIt<MultiplayerSocketService>(),
    ),
  );

  getIt.registerLazySingleton<ILibraryRepository>(
    () => HttpLibraryRepository(client: getIt<AuthenticatedHttpClient>()),
  );

  getIt.registerLazySingleton<NotificationRepository>(
    // Usamos Mock para pruebas independientes del backend
    // () => MockNotificationRepository(),
    () => HttpNotificationRepository(client: getIt<AuthenticatedHttpClient>()),
  );

  // Use Cases - Multiplayer
  getIt.registerLazySingleton(() => CreateMultiplayerSessionUseCase(getIt()));
  getIt.registerLazySingleton(() => GetSessionPinByQrTokenUseCase(getIt()));
  getIt.registerLazySingleton(() => ConnectToSessionUseCase(getIt()));
  getIt.registerLazySingleton(() => JoinAsPlayerUseCase(getIt()));
  getIt.registerLazySingleton(() => StartMultiplayerGameUseCase(getIt()));
  getIt.registerLazySingleton(() => SubmitMultiplayerAnswerUseCase(getIt()));
  getIt.registerLazySingleton(() => NextPhaseUseCase(getIt()));
  getIt.registerLazySingleton(() => EndSessionUseCase(getIt()));

  // Use Cases - Solo Game
  getIt.registerLazySingleton(() => StartAttemptUseCase(getIt()));
  getIt.registerLazySingleton(() => SubmitAnswerUseCase(getIt()));
  getIt.registerLazySingleton(() => GetSummaryUseCase(getIt()));
  getIt.registerLazySingleton(() => ManageLocalAttemptUseCase(getIt()));
  getIt.registerLazySingleton(() => GetAttemptStateUseCase(getIt()));

  // Use Cases - Auth
  getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt()));
  getIt.registerLazySingleton(() => RequestPasswordResetUseCase(getIt()));
  getIt.registerLazySingleton(() => ConfirmPasswordResetUseCase(getIt()));

  // Use Cases - Library
  getIt.registerLazySingleton(() => GetMyCreationsUseCase(getIt()));
  getIt.registerLazySingleton(() => GetFavoritesUseCase(getIt()));
  getIt.registerLazySingleton(() => MarkAsFavoriteUseCase(getIt()));
  getIt.registerLazySingleton(() => UnmarkAsFavoriteUseCase(getIt()));
  getIt.registerLazySingleton(() => GetInProgressUseCase(getIt()));
  getIt.registerLazySingleton(() => GetCompletedUseCase(getIt()));

  // Use Cases - Notifications
  getIt.registerLazySingleton(() => RegisterDeviceUseCase(getIt()));
  getIt.registerLazySingleton(() => UnregisterDeviceUseCase(getIt()));
  getIt.registerLazySingleton(() => GetNotificationsUseCase(getIt()));
  getIt.registerLazySingleton(() => MarkNotificationReadUseCase(getIt()));

  // Cubits / Controllers
  getIt.registerFactory(
    () => AuthController(
      loginUseCase: getIt(),
      registerUseCase: getIt(),
      logoutUseCase: getIt(),
      requestPasswordResetUseCase: getIt(),
      confirmPasswordResetUseCase: getIt(),
      registerDeviceUseCase: getIt(),
      unregisterDeviceUseCase: getIt(),
      pushNotificationService: getIt(),
    ),
  );

  getIt.registerFactory(
    () => GameCubit(
      startAttemptUseCase: getIt(),
      submitAnswerUseCase: getIt(),
      getSummaryUseCase: getIt(),
      manageLocalAttemptUseCase: getIt(),
      getAttemptStateUseCase: getIt(),
    ),
  );

  getIt.registerFactory(
    () => LibraryCubit(
      getMyCreationsUseCase: getIt(),
      getFavoritesUseCase: getIt(),
      getInProgressUseCase: getIt(),
      getCompletedUseCase: getIt(),
      markAsFavoriteUseCase: getIt(),
      unmarkAsFavoriteUseCase: getIt(),
    ),
  );

  getIt.registerFactory(
    () => MultiplayerGameCubit(
      createSessionUseCase: getIt(),
      getSessionPinUseCase: getIt(),
      connectUseCase: getIt(),
      joinAsPlayerUseCase: getIt(),
      startGameUseCase: getIt(),
      submitAnswerUseCase: getIt(),
      nextPhaseUseCase: getIt(),
      endSessionUseCase: getIt(),
      repository: getIt(),
    ),
  );

  getIt.registerFactory(
    () => NotificationsCubit(
      getNotificationsUseCase: getIt(),
      markNotificationReadUseCase: getIt(),
      authRepository: getIt(),
    ),
  );
}
