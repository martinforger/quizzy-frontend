import 'package:quizzy/domain/kahoots/entities/kahoot_question.dart';

class Kahoot {
  Kahoot({
    this.id,
    this.title,
    this.description,
    this.coverImageId,
    this.visibility,
    this.themeId,
    this.authorId,
    this.category,
    this.status,
    this.createdAt,
    this.playCount,
    this.questions = const [],
  });

  final String? id;
  final String? title;
  final String? description;
  final String? coverImageId;
  final String? visibility; // public | private
  final String? themeId;
  final String? authorId;
  final String? category;
  final String? status; // draft | published
  final DateTime? createdAt;
  final int? playCount;
  final List<KahootQuestion> questions;
}
