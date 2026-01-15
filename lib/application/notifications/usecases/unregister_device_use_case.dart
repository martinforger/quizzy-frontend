import 'package:quizzy/domain/notifications/repositories/notification_repository.dart';

class UnregisterDeviceUseCase {
  final NotificationRepository _repository;

  UnregisterDeviceUseCase(this._repository);

  Future<void> call({required String token, String? accessToken}) {
    return _repository.unregisterDevice(token: token, accessToken: accessToken);
  }
}
