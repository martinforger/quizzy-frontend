import 'package:quizzy/domain/kahoots/entities/game_state.dart';
import 'package:quizzy/domain/kahoots/entities/kahoot.dart';
import 'package:quizzy/domain/kahoots/entities/kahoot_question.dart';

class KahootBuilder {
  String? _id;
  String? _title;
  String? _description;
  String? _coverImageId;
  String? _visibility; // public | private
  String? _themeId;
  String? _authorId;
  String? _authorName;
  String? _category;
  String? _status; // draft | published
  DateTime? _createdAt;
  int? _playCount;
  bool? _isInProgress;
  bool? _isCompleted;
  bool? _isFavorite;
  GameState? _gameState;
  List<KahootQuestion> _questions = [];

  KahootBuilder() {
    _id = "default-id";
    _title = "Default Title";
    _description = "Default Description";
    _visibility = "public";
    _status = "draft";
    _createdAt = DateTime.now();
    _playCount = 0;
    _isInProgress = false;
    _isCompleted = false;
    _isFavorite = false;
  }

  KahootBuilder withId(String id) {
    _id = id;
    return this;
  }

  KahootBuilder withTitle(String title) {
    _title = title;
    return this;
  }

  KahootBuilder withDescription(String description) {
    _description = description;
    return this;
  }

  KahootBuilder withStatus(String status) {
    _status = status;
    return this;
  }

  KahootBuilder withVisibility(String visibility) {
    _visibility = visibility;
    return this;
  }

  KahootBuilder withQuestions(List<KahootQuestion> questions) {
    _questions = questions;
    return this;
  }

  Kahoot build() {
    return Kahoot(
      id: _id,
      title: _title,
      description: _description,
      coverImageId: _coverImageId,
      visibility: _visibility,
      themeId: _themeId,
      authorId: _authorId,
      authorName: _authorName,
      category: _category,
      status: _status,
      createdAt: _createdAt,
      playCount: _playCount,
      isInProgress: _isInProgress,
      isCompleted: _isCompleted,
      isFavorite: _isFavorite,
      gameState: _gameState,
      questions: _questions,
    );
  }
}
