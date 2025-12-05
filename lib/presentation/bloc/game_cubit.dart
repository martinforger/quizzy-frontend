import 'package:bloc/bloc.dart';
import '../../../application/solo-game/useCases/submit_answer_use_case.dart';
import '../../../application/solo-game/useCases/start_attempt_use_case.dart';
import '../../../application/solo-game/useCases/get_summary_use_case.dart';
import 'game_state.dart';
import '../../../application/solo-game/useCases/manage_local_attempt_use_case.dart';
import '../../../application/solo-game/useCases/get_attempt_state_use_case.dart';

class GameCubit extends Cubit<GameState> {
  final StartAttemptUseCase _startAttemptUseCase;
  final SubmitAnswerUseCase _submitAnswerUseCase;
  final GetSummaryUseCase _getSummaryUseCase;

  final ManageLocalAttemptUseCase _manageLocalAttemptUseCase;
  final GetAttemptStateUseCase _getAttemptStateUseCase;

  String? _currentAttemptId;

  GameCubit({
    required StartAttemptUseCase startAttemptUseCase,
    required SubmitAnswerUseCase submitAnswerUseCase,
    required GetSummaryUseCase getSummaryUseCase,
    required ManageLocalAttemptUseCase manageLocalAttemptUseCase,
    required GetAttemptStateUseCase getAttemptStateUseCase,
  }) : _startAttemptUseCase = startAttemptUseCase,
       _submitAnswerUseCase = submitAnswerUseCase,
       _getSummaryUseCase = getSummaryUseCase,
       _manageLocalAttemptUseCase = manageLocalAttemptUseCase,
       _getAttemptStateUseCase = getAttemptStateUseCase,
       super(GameInitial());

  Future<void> checkSavedGame() async {
    try {
      final attemptId = await _manageLocalAttemptUseCase.getAttemptId();
      if (attemptId != null && attemptId.isNotEmpty) {
        emit(GameInitial(hasSavedAttempt: true));
      } else {
        emit(GameInitial(hasSavedAttempt: false));
      }
    } catch (e) {
      // Si falla, asumimos que no hay saved game
      emit(GameInitial(hasSavedAttempt: false));
    }
  }

  /// 1. Iniciar Juego
  Future<void> startGame(String kahootId) async {
    try {
      emit(GameLoading());

      final attempt = await _startAttemptUseCase(kahootId);
      _currentAttemptId = attempt.attemptId;

      await _manageLocalAttemptUseCase.saveGameSession(
        quizId: kahootId,
        attemptId: _currentAttemptId!,
        currentQuestionIndex: attempt.currentQuestionIndex,
        totalQuestions: attempt.totalQuestions,
      );

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

  Future<void> resumeGame() async {
    try {
      emit(GameLoading());
      final attemptId = await _manageLocalAttemptUseCase.getAttemptId();

      if (attemptId == null) {
        emit(GameError("No saved game found"));
        return;
      }

      _currentAttemptId = attemptId;
      final attempt = await _getAttemptStateUseCase(attemptId);

      final currentSlide = attempt.firstSlide ?? attempt.nextSlide;

      if (currentSlide != null) {
        emit(
          GameInProgress(
            attemptId: attempt.attemptId,
            currentSlide: currentSlide,
            currentScore: attempt.currentScore,
            currentQuestionIndex: attempt.currentQuestionIndex,
          ),
        );
      } else {
        emit(GameError("No active question in saved game."));
      }
    } catch (e) {
      emit(GameError(e.toString()));
    }
  }

  void exitGame() {
    emit(GameInitial());
    checkSavedGame();
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

      // Update progress locally
      // We need quizId. Let's fetch the existing session to get it.
      final existingSession = await _manageLocalAttemptUseCase.getGameSession();
      if (existingSession != null && existingSession['quizId'] != null) {
        await _manageLocalAttemptUseCase.saveGameSession(
          quizId: existingSession['quizId'], // Preserve quizId
          attemptId: _currentAttemptId!,
          currentQuestionIndex: result.currentQuestionIndex,
          totalQuestions: result.totalQuestions,
        );
      }
    } catch (e) {
      emit(GameError(e.toString()));
    }
  }

  /// 3. Avanzar a la siguiente pregunta (Llamado por la UI tras ver el feedback)
  void nextQuestion(dynamic nextSlideData) {
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
      // Limpiamos el save local al terminar
      await _manageLocalAttemptUseCase.clearAttemptId();
      emit(GameFinished(summary));
    } catch (e) {
      emit(GameError(e.toString()));
    }
  }
}
