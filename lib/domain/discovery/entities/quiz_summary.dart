class QuizSummary {
  QuizSummary({
    required this.id,
    required this.title,
    required this.author,
    required this.tag,
    this.thumbnailUrl = '',
    this.description,
    this.playCount,
  });

  final String id;
  final String title;
  final String author;
  final String tag;
  final String thumbnailUrl;
  final String? description;
  final int? playCount;
}
