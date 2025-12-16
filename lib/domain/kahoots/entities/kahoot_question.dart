import 'package:quizzy/domain/kahoots/entities/kahoot_answer.dart';

class KahootQuestion {
  KahootQuestion({
    this.id,
    this.text,
    this.mediaId,
    this.type,
    this.timeLimit,
    this.points,
    this.answers = const [],
  });

  final String? id;
  final String? text;
  final String? mediaId;
  final String? type;
  final int? timeLimit;
  final int? points;
  final List<KahootAnswer> answers;
}
