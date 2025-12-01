class QuizTheme {
  QuizTheme({
    required this.id,
    required this.name,
    this.description = '',
    this.kahootCount = 0,
  });

  final String id;
  final String name;
  final String description;
  final int kahootCount;
}
