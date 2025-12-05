class SlideEntity {
  final String slideId;
  final String questionType;
  final String questionText;
  final int timeLimitSeconds;
  final String? mediaUrl;
  final List<OptionEntity> options;

  SlideEntity({
    required this.slideId,
    required this.questionType,
    required this.questionText,
    required this.timeLimitSeconds,
    this.mediaUrl,
    required this.options,
  });
}

class OptionEntity {
  final String index;
  final String? text;
  final String? mediaUrl;

  OptionEntity({required this.index, this.text, this.mediaUrl});
}
