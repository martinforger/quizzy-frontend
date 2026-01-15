import 'package:quizzy/application/media/usecases/list_theme_media.dart';
import 'package:quizzy/application/media/usecases/upload_media.dart';
import 'package:quizzy/domain/media/entities/media_asset.dart';

class MediaController {
  MediaController({
    required this.uploadMediaUseCase,
    required this.listThemeMediaUseCase,
  });

  final UploadMediaUseCase uploadMediaUseCase;
  final ListThemeMediaUseCase listThemeMediaUseCase;

  Future<MediaAsset> upload({
    required List<int> bytes,
    required String filename,
    String? category,
  }) {
    return uploadMediaUseCase(
      bytes: bytes,
      filename: filename,
      category: category,
    );
  }

  Future<List<MediaAsset>> listThemes() {
    return listThemeMediaUseCase();
  }
}
