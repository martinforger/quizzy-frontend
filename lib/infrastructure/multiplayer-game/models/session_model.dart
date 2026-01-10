import '../../../domain/multiplayer-game/entities/session_entity.dart';

/// Modelo para parsear la respuesta de creación de sesión.
class SessionModel extends SessionEntity {
  SessionModel({
    required super.sessionPin,
    required super.qrToken,
    required super.quizTitle,
    super.coverImageUrl,
    required super.theme,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      sessionPin: json['sessionPin'] as String,
      qrToken: json['qrToken'] as String,
      quizTitle: json['quizTitle'] as String,
      coverImageUrl: json['coverImageUrl'] as String?,
      theme: ThemeModel.fromJson(json['theme'] as Map<String, dynamic>),
    );
  }
}

/// Modelo para el tema de la sesión.
class ThemeModel extends ThemeEntity {
  ThemeModel({required super.id, required super.url, required super.name});

  factory ThemeModel.fromJson(Map<String, dynamic> json) {
    return ThemeModel(
      id: json['id'] as String,
      url: json['url'] as String,
      name: json['name'] as String,
    );
  }
}
