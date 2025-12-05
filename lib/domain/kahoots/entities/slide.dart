import 'package:quizzy/domain/kahoots/entities/slide_option.dart';

enum SlideType {
  quizSingle,
  quizMultiple,
  trueFalse,
  shortAnswer,
  poll,
  slide,
}

class Slide {
  Slide({
    required this.id,
    required this.kahootId,
    required this.position,
    required this.type,
    required this.text,
    this.timeLimitSeconds,
    this.points,
    this.mediaUrlQuestion,
    this.options = const [],
    this.shortAnswerCorrectText = const [],
  });

  final String id;
  final String kahootId;
  final int position;
  final SlideType type;
  final String text;
  final int? timeLimitSeconds;
  final int? points;
  final String? mediaUrlQuestion;
  final List<SlideOption> options;
  final List<String> shortAnswerCorrectText;
}
