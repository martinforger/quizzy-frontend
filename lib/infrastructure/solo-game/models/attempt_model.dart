import '../../../domain/solo-game/entities/attempt_entity.dart';
import 'slide_model.dart'; // Asegúrate de tener este archivo creado también

class AttemptModel extends AttemptEntity {
  AttemptModel({
    required super.attemptId,
    required super.state,
    required super.currentScore,
    SlideModel? firstSlide,
    SlideModel? nextSlide,
    super.wasCorrect,
    super.pointsEarned,
    super.currentQuestionIndex = 0,
    super.totalQuestions = 0,
  }) : super(
         firstSlide: firstSlide,
         nextSlide: nextSlide,
       );

  factory AttemptModel.fromJson(Map<String, dynamic> json) {
    return AttemptModel(
      attemptId: json['attemptId'] ?? '',
      // La API a veces puede devolver 'state' o 'attemptState', manejamos ambos.
      state: json['state'] ?? json['attemptState'] ?? 'UNKNOWN',

      // Aseguramos que sea int, manejando posibles nulos o tipos numéricos
      currentScore: (json['currentScore'] ?? json['updatedScore'] ?? 0) as int,

      currentQuestionIndex: (json['currentQuestionIndex'] ?? 0) as int,
      totalQuestions: (json['totalQuestions'] ?? 0) as int,

      // Parseo recursivo: Si existe 'firstSlide', lo convertimos usando SlideModel
      firstSlide: json['firstSlide'] != null
          ? SlideModel.fromJson(json['firstSlide'])
          : null,

      // Parseo recursivo: Si existe 'nextSlide', lo convertimos usando SlideModel
      nextSlide: json['nextSlide'] != null
          ? SlideModel.fromJson(json['nextSlide'])
          : null,

      // Campos específicos de la respuesta H5.3 (pueden ser nulos)
      wasCorrect: json['wasCorrect'],
      pointsEarned: json['pointsEarned'],
    );
  }
}
