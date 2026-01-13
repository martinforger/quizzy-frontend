import 'package:quizzy/domain/media/entities/media_asset.dart';

abstract class MediaRepository {
  Future<MediaAsset> uploadMedia({
    required List<int> bytes,
    required String filename,
    String? category,
  });

  Future<List<MediaAsset>> listThemeMedia();
}
