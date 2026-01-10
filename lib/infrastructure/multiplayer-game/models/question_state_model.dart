import '../../../domain/multiplayer-game/entities/multiplayer_slide_entity.dart';
import '../../../domain/solo-game/entities/slide_entity.dart';

/// Modelo para parsear question_started.
class MultiplayerQuestionModel extends MultiplayerQuestionEntity {
  MultiplayerQuestionModel({
    required super.state,
    required super.currentSlideData,
    required super.position,
    super.timeRemainingMs,
    super.hasAnswered,
  });

  factory MultiplayerQuestionModel.fromJson(Map<String, dynamic> json) {
    final slideData = json['currentSlideData'] as Map<String, dynamic>;

    return MultiplayerQuestionModel(
      state: json['state'] as String? ?? 'question',
      currentSlideData: SlideEntityModel.fromJson(slideData),
      position: slideData['position'] as int? ?? 1,
      timeRemainingMs: json['timeRemainingMs'] as int?,
      hasAnswered: json['hasAnswered'] as bool?,
    );
  }
}

/// Modelo para convertir slide data del socket a SlideEntity.
class SlideEntityModel extends SlideEntity {
  SlideEntityModel({
    required super.slideId,
    required super.questionType,
    required super.questionText,
    required super.timeLimitSeconds,
    super.mediaUrl,
    required super.options,
  });

  factory SlideEntityModel.fromJson(Map<String, dynamic> json) {
    final optionsList =
        (json['options'] as List<dynamic>?)
            ?.map((o) => OptionEntityModel.fromJson(o as Map<String, dynamic>))
            .toList() ??
        [];

    return SlideEntityModel(
      slideId: json['id'] as String,
      questionType: json['slideType'] as String? ?? 'QUIZ',
      questionText: json['questionText'] as String? ?? '',
      timeLimitSeconds: json['timeLimitSeconds'] as int? ?? 20,
      mediaUrl: json['slideImageURL'] as String?,
      options: optionsList,
    );
  }
}

/// Modelo para opciones de respuesta.
class OptionEntityModel extends OptionEntity {
  OptionEntityModel({required super.index, super.text, super.mediaUrl});

  factory OptionEntityModel.fromJson(Map<String, dynamic> json) {
    return OptionEntityModel(
      index: json['index']?.toString() ?? '0',
      text: json['text'] as String?,
      mediaUrl: json['mediaURL'] as String?,
    );
  }
}

/// Modelo para player_answer_confirmation.
class AnswerConfirmationModel extends AnswerConfirmationEntity {
  AnswerConfirmationModel({required super.received, required super.questionId});

  factory AnswerConfirmationModel.fromJson(Map<String, dynamic> json) {
    return AnswerConfirmationModel(
      received: true,
      questionId: json['questionId'] as String? ?? '',
    );
  }
}
