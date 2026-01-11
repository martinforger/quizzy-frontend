import 'package:quizzy/domain/notifications/entities/notification_item.dart';

abstract class NotificationRepository {
  Future<void> registerDevice({
    required String token,
    required String deviceType,
  });

  Future<void> unregisterDevice({
    required String token,
  });

  Future<List<NotificationItem>> getNotifications({
    int limit = 20,
    int page = 1,
  });

  Future<NotificationItem> markAsRead(String id);
}
