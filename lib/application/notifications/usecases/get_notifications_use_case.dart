import 'package:quizzy/domain/notifications/entities/notification_item.dart';
import 'package:quizzy/domain/notifications/repositories/notification_repository.dart';

class GetNotificationsUseCase {
  final NotificationRepository _repository;

  GetNotificationsUseCase(this._repository);

  Future<List<NotificationItem>> call({int limit = 20, int page = 1}) {
    return _repository.getNotifications(limit: limit, page: page);
  }
}
