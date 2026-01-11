import 'package:quizzy/domain/notifications/repositories/notification_repository.dart';

class RegisterDeviceUseCase {
  final NotificationRepository _repository;

  RegisterDeviceUseCase(this._repository);

  Future<void> call({required String token, required String deviceType}) {
    return _repository.registerDevice(token: token, deviceType: deviceType);
  }
}
