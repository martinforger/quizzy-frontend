import 'package:quizzy/domain/notifications/entities/notification_item.dart';

abstract class NotificationRepository {
  Future<void> registerDevice({
    required String token,
    required String deviceType,
    required String accessToken,
  });

  Future<void> unregisterDevice({
    required String token,
    String? accessToken,
  });

  Future<List<NotificationItem>> getNotifications({
    int limit = 20,
    int page = 1,
  });

  Future<NotificationItem> markAsRead(String id);
}
