class MediaAsset {
  MediaAsset({
    required this.assetId,
    required this.url,
    this.name,
    this.category,
    this.format,
    this.size,
    this.mimeType,
  });

  final String assetId;
  final String url;
  final String? name;
  final String? category;
  final String? format;
  final int? size;
  final String? mimeType;
}
