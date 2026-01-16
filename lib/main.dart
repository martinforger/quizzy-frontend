import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'infrastructure/notifications/services/push_notification_service.dart';
import 'firebase_options.dart';

import 'presentation/app.dart';
import 'injection_container.dart' as di;

void main() async {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } catch (e) {
        print('Firebase initialization failed: $e');
      }

      await di.init();

      // Initialize PushNotificationService safely
      try {
        print('Initializing Push Notification Service...');
        final pushService = di.getIt<PushNotificationService>();
        await pushService.initialize();
        print('Push Notification Service initialized.');
      } catch (e) {
        print('Error initializing Push Notification Service: $e');
      }

      final sharedPreferences = await SharedPreferences.getInstance();
      runApp(QuizzyApp(sharedPreferences: sharedPreferences));
    },
    (error, stack) {
      print('CRITICAL APP ERROR detected by runZonedGuarded: $error');
      print(stack);
    },
  );
}
