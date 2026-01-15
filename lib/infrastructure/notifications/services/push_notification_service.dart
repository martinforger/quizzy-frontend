import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../../firebase_options.dart';

// Top-level function for background handling
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Handling a background message ${message.messageId}');
  } catch (e) {
    print('CRITICAL: Error handling background message: $e');
  }
}

class PushNotificationService {
  // Lazy initialization to prevent native crashes during instantiation
  FirebaseMessaging? _firebaseMessagingInstance;
  FirebaseMessaging get _firebaseMessaging => _firebaseMessagingInstance ??= FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Ensure instance is ready
    final _ = _firebaseMessaging;
    // 1. Request Permission
    await _requestPermission();

    // 2. Set background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3. Foreground handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      try {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');

        if (message.notification != null) {
          print('Message also contained a notification: ${message.notification}');
        }
      } catch (e) {
        print('Error handling foreground message: $e');
      }
    });

    // SUSCRIPCIÓN A TEMAS (Nuevo):
    // Protegemos esto con try-catch para que no cierre la app si falla
    try {
      await _firebaseMessaging.subscribeToTopic('novedades');
    } catch (e) {
      print('Warning: Failed to subscribe to topic: $e');
    }

    // Obtener token en segundo plano (sin await) para evitar bloqueos
    getToken();
  }

  Future<void> _requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
  }

  String? _lastPrintToken;

  Future<String?> getToken() async {
    try {
      // Get the token
      String? token = await _firebaseMessaging.getToken();
      if (kDebugMode && token != _lastPrintToken) {
        print('FCM Token: $token');
        _lastPrintToken = token;
      }
      return token;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  Stream<String> get onTokenRefresh => _firebaseMessaging.onTokenRefresh;
}
