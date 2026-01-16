class QuizSummary {
  QuizSummary({
    required this.id,
    required this.title,
    required this.author,
    required this.tag,
    this.thumbnailUrl = '',
    this.description,
    this.playCount,
    this.isFavorite = false,
  });

  final String id;
  final String title;
  final String author;
  final String tag;
  final String thumbnailUrl;
  final String? description;
  final int? playCount;
  final bool isFavorite;

  QuizSummary copyWith({
    String? id,
    String? title,
    String? author,
    String? tag,
    String? thumbnailUrl,
    String? description,
    int? playCount,
    bool? isFavorite,
  }) {
    return QuizSummary(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      tag: tag ?? this.tag,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      description: description ?? this.description,
      playCount: playCount ?? this.playCount,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
