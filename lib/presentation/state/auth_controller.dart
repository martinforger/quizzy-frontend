import 'package:quizzy/application/auth/usecases/confirm_password_reset_use_case.dart';
import 'package:quizzy/application/auth/usecases/login_use_case.dart';
import 'package:quizzy/application/auth/usecases/logout_use_case.dart';
import 'package:quizzy/application/auth/usecases/register_use_case.dart';
import 'package:quizzy/application/auth/usecases/request_password_reset_use_case.dart';
import 'package:quizzy/application/notifications/usecases/register_device_use_case.dart';
import 'package:quizzy/application/notifications/usecases/unregister_device_use_case.dart';
import 'package:quizzy/domain/auth/entities/user.dart';
import 'package:quizzy/infrastructure/notifications/services/push_notification_service.dart';
import 'dart:io';

class AuthController {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final RequestPasswordResetUseCase requestPasswordResetUseCase;
  final ConfirmPasswordResetUseCase confirmPasswordResetUseCase;

  // Notification dependencies
  final RegisterDeviceUseCase registerDeviceUseCase;
  final UnregisterDeviceUseCase unregisterDeviceUseCase;
  final PushNotificationService pushNotificationService;

  AuthController({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.requestPasswordResetUseCase,
    required this.confirmPasswordResetUseCase,
    required this.registerDeviceUseCase,
    required this.unregisterDeviceUseCase,
    required this.pushNotificationService,
  });

  Future<String> login(String username, String password) async {
    final token = await loginUseCase(username: username, password: password);
    
    // Register device for push notifications
    _registerDeviceToken(token);
    
    return token;
  }

  Future<(User, String)> register(String name, String username, String email, String password, String userType) async {
    final result = await registerUseCase(
      name: name,
      username: username,
      email: email,
      password: password,
      userType: userType,
    );
    
    // Register device for push notifications
    _registerDeviceToken(result.$2);
    
    return result;
  }

  Future<void> _registerDeviceToken(String accessToken) async {
    try {
      final fcmToken = await pushNotificationService.getToken();
      if (fcmToken != null) {
        String deviceType = 'android';
        if (Platform.isIOS) deviceType = 'ios';
        // Add other platforms if needed

        await registerDeviceUseCase(
          token: fcmToken,
          deviceType: deviceType,
          accessToken: accessToken,
        );
      }
    } catch (e) {
      print('Failed to register device token: $e');
    }
  }

  Future<void> logout() async {
    try {
      // Unregister token before logout (best effort)
      final fcmToken = await pushNotificationService.getToken();
      if (fcmToken != null) {
        await unregisterDeviceUseCase(token: fcmToken);
      }
    } catch (e) {
      print('Failed to unregister device token: $e');
    }

    return logoutUseCase();
  }

  Future<void> requestPasswordReset(String email) {
    return requestPasswordResetUseCase(email: email);
  }

  Future<void> confirmPasswordReset(String token, String newPassword) {
    return confirmPasswordResetUseCase(resetToken: token, newPassword: newPassword);
  }
}
