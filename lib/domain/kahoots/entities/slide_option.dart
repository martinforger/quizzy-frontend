class SlideOption {
  SlideOption({
    required this.text,
    required this.isCorrect,
    this.mediaUrlAnswer,
  });

  final String text;
  final bool isCorrect;
  final String? mediaUrlAnswer;
}
