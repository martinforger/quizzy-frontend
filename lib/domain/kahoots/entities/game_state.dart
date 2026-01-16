class GameState {
  GameState({
    this.attemptId,
    this.currentScore,
    this.currentSlide,
    this.totalSlides,
    this.lastPlayedAt,
  });

  final String? attemptId;
  final int? currentScore;
  final int? currentSlide;
  final int? totalSlides;
  final DateTime? lastPlayedAt;
}
