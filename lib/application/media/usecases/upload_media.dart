import 'package:quizzy/domain/media/entities/media_asset.dart';
import 'package:quizzy/domain/media/repositories/media_repository.dart';

class UploadMediaUseCase {
  UploadMediaUseCase(this._repository);

  final MediaRepository _repository;

  Future<MediaAsset> call({
    required List<int> bytes,
    required String filename,
    String? category,
  }) {
    return _repository.uploadMedia(
      bytes: bytes,
      filename: filename,
      category: category,
    );
  }
}
