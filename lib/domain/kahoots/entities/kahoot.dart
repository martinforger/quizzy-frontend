import 'package:quizzy/domain/kahoots/entities/game_state.dart';
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
    this.authorName,
    this.category,
    this.status,
    this.createdAt,
    this.playCount,
    this.isInProgress,
    this.isCompleted,
    this.isFavorite,
    this.gameState,
    this.questions = const [],
  });

  final String? id;
  final String? title;
  final String? description;
  final String? coverImageId;
  final String? visibility; // public | private
  final String? themeId;
  final String? authorId;
  final String? authorName;
  final String? category;
  final String? status; // draft | published
  final DateTime? createdAt;
  final int? playCount;
  final bool? isInProgress;
  final bool? isCompleted;
  final bool? isFavorite;
  final GameState? gameState;
  final List<KahootQuestion> questions;
}
