import 'package:bloc/bloc.dart';
import '../../../application/solo-game/useCases/submit_answer_use_case.dart';
import '../../../application/solo-game/useCases/start_attempt_use_case.dart';
import '../../../application/solo-game/useCases/get_summary_use_case.dart'; // Asumiendo que lo creaste
import 'game_state.dart';

class GameCubit extends Cubit<GameState> {
  // Inyectamos los Casos de Uso (NO el repositorio directamente)
  final StartAttemptUseCase _startAttemptUseCase;
  final SubmitAnswerUseCase _submitAnswerUseCase;
  final GetSummaryUseCase _getSummaryUseCase;

  // Variables temporales para mantener estado entre emit
  String? _currentAttemptId;

  GameCubit({
    required StartAttemptUseCase startAttemptUseCase,
    required SubmitAnswerUseCase submitAnswerUseCase,
    required GetSummaryUseCase getSummaryUseCase,
  }) : _startAttemptUseCase = startAttemptUseCase,
       _submitAnswerUseCase = submitAnswerUseCase,
       _getSummaryUseCase = getSummaryUseCase,
       super(GameInitial());

  /// 1. Iniciar Juego
  Future<void> startGame(String kahootId) async {
    try {
      emit(GameLoading());

      final attempt = await _startAttemptUseCase(kahootId);
      _currentAttemptId = attempt.attemptId;

      if (attempt.firstSlide != null) {
        emit(
          GameInProgress(
            attemptId: attempt.attemptId,
            currentSlide: attempt.firstSlide!,
            currentScore: attempt.currentScore,
          ),
        );
      } else {
        emit(GameError("El Kahoot no tiene preguntas"));
      }
    } catch (e) {
      emit(GameError(e.toString()));
    }
  }

  /// 2. Enviar Respuesta
  Future<void> submitAnswer(String slideId, List<int> answers, int time) async {
    if (_currentAttemptId == null) return;

    try {
      emit(GameLoading());

      final result = await _submitAnswerUseCase(
        attemptId: _currentAttemptId!,
        slideId: slideId,
        answerIndices: answers,
        timeElapsed: time,
      );

      // Mostramos feedback (Verde/Rojo)
      emit(
        GameAnswerFeedback(
          wasCorrect: result.wasCorrect ?? false,
          pointsEarned: result.pointsEarned ?? 0,
          totalScore: result.currentScore,
          nextSlide: result.nextSlide,
        ),
      );

      // Aquí la UI decide:
      // Si nextSlide != null -> Espera 3 segs y llama a nextQuestion()
      // Si nextSlide == null -> Llama a loadSummary()
    } catch (e) {
      emit(GameError(e.toString()));
    }
  }

  /// 3. Avanzar a la siguiente pregunta (Llamado por la UI tras ver el feedback)
  void nextQuestion(dynamic nextSlideData) {
    // En Clean Architecture puro, 'nextSlideData' debería ser SlideEntity
    // Reconstruimos el estado InProgress con la nueva data
    if (state is GameAnswerFeedback) {
      final feedbackState = state as GameAnswerFeedback;
      if (feedbackState.nextSlide != null) {
        emit(
          GameInProgress(
            attemptId: _currentAttemptId!,
            currentSlide: feedbackState.nextSlide!,
            currentScore: feedbackState.totalScore,
          ),
        );
      }
    }
  }

  Future<void> loadSummary() async {
    if (_currentAttemptId == null) return;
    try {
      emit(GameLoading());
      final summary = await _getSummaryUseCase(_currentAttemptId!);
      emit(GameFinished(summary));
    } catch (e) {
      emit(GameError(e.toString()));
    }
  }
}
