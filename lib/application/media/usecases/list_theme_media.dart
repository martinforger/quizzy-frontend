import 'package:quizzy/domain/media/entities/media_asset.dart';
import 'package:quizzy/domain/media/repositories/media_repository.dart';

class ListThemeMediaUseCase {
  ListThemeMediaUseCase(this._repository);

  final MediaRepository _repository;

  Future<List<MediaAsset>> call() {
    return _repository.listThemeMedia();
  }
}
