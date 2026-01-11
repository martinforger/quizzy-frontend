import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'infrastructure/notifications/services/push_notification_service.dart';
import 'firebase_options.dart';

import 'presentation/app.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Firebase initialization failed: $e');
  }

  await di.init();
  
  // Initialize PushNotificationService to set up listeners
  final pushService = di.getIt<PushNotificationService>();
  await pushService.initialize();

  final sharedPreferences = await SharedPreferences.getInstance();
  runApp(QuizzyApp(sharedPreferences: sharedPreferences));
}
