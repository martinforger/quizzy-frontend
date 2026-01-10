/// Representa una sesión multijugador creada por el host.
class SessionEntity {
  final String sessionPin;
  final String qrToken;
  final String quizTitle;
  final String? coverImageUrl;
  final ThemeEntity theme;

  SessionEntity({
    required this.sessionPin,
    required this.qrToken,
    required this.quizTitle,
    this.coverImageUrl,
    required this.theme,
  });
}

/// Tema visual de la partida.
class ThemeEntity {
  final String id;
  final String url;
  final String name;

  ThemeEntity({required this.id, required this.url, required this.name});
}
