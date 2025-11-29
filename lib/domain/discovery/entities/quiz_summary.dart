class QuizSummary {
  QuizSummary({
    required this.id,
    required this.title,
    required this.author,
    required this.tag,
    this.thumbnailUrl = '',
  });

  final String id;
  final String title;
  final String author;
  final String tag;
  final String thumbnailUrl;
}
