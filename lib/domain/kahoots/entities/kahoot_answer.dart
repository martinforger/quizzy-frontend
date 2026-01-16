class KahootAnswer {
  KahootAnswer({
    this.id,
    this.text,
    this.mediaId,
    required this.isCorrect,
  });

  final String? id;
  final String? text;
  final String? mediaId;
  final bool isCorrect;
}
