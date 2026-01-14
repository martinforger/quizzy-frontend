import 'package:quizzy/domain/notifications/entities/notification_item.dart';
import 'package:quizzy/domain/notifications/repositories/notification_repository.dart';

class MockNotificationRepository implements NotificationRepository {
  // Simular una lista local de notificaciones
  final List<NotificationItem> _mockNotifications = [
    NotificationItem(
      id: '1',
      type: 'quiz_assigned',
      message: 'Te han asignado el Quizz: "Matemáticas Básicas"',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      resourceId: 'quiz_123',
    ),
    NotificationItem(
      id: '2',
      type: 'alert',
      message: '¡Bienvenido a Quizzy! Empieza tu racha hoy.',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    NotificationItem(
      id: '3',
      type: 'quiz_completed',
      message: 'Completaste "Historia del Arte" con 100% de aciertos.',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      resourceId: 'quiz_456',
    ),
  ];

  @override
  Future<List<NotificationItem>> getNotifications({int limit = 20, int page = 1}) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 800));
    return _mockNotifications;
  }

  @override
  Future<NotificationItem> markAsRead(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _mockNotifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      final old = _mockNotifications[index];
      final upadted = NotificationItem(
        id: old.id,
        type: old.type,
        message: old.message,
        isRead: true, // Mark as read
        createdAt: old.createdAt,
        resourceId: old.resourceId,
      );
      _mockNotifications[index] = upadted;
      return upadted;
    }
    throw Exception('Notification not found');
  }

  @override
  Future<void> registerDevice({
    required String token,
    required String deviceType,
    required String accessToken,
  }) async {
    print('MOCK: Device registered with token: $token');
  }

  @override
  Future<void> unregisterDevice({
    required String token,
    String? accessToken,
  }) async {
    print('MOCK: Device unregistered');
  }
}
