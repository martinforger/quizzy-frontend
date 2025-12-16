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
  String? _currentQuizId;

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

  Future<void> checkSavedGame(String? currentQuizId) async {
    try {
      if (currentQuizId == null) {
        emit(GameInitial(hasSavedAttempt: false));
        return;
      }
      final session = await _manageLocalAttemptUseCase.getGameSession(
        currentQuizId,
      );
      if (session != null && session['attemptId'] != null) {
        emit(GameInitial(hasSavedAttempt: true));
      } else {
        emit(GameInitial(hasSavedAttempt: false));
      }
    } catch (e) {
      emit(GameInitial(hasSavedAttempt: false));
    }
  }

  /// 1. Iniciar Juego
  Future<void> startGame(String kahootId) async {
    try {
      emit(GameLoading());
      _currentQuizId = kahootId;

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

  Future<void> resumeGame(String quizId) async {
    try {
      emit(GameLoading());
      _currentQuizId = quizId;
      final attemptId = await _manageLocalAttemptUseCase.getAttemptId(quizId);

      if (attemptId == null) {
        emit(GameError("No saved game found"));
        return;
      }

      _currentAttemptId = attemptId;
      final attempt = await _getAttemptStateUseCase(attemptId);

      // Check if game is already completed
      if (attempt.state == "COMPLETED") {
        await loadSummary();
        return;
      }

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
        // Fallback: if no slide but not marked completed, try summary or error
        emit(GameError("No active question in saved game."));
      }
    } catch (e) {
      emit(GameError(e.toString()));
    }
  }

  void exitGame() {
    emit(GameInitial());
    checkSavedGame(_currentQuizId);
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
      if (_currentQuizId != null) {
        await _manageLocalAttemptUseCase.saveGameSession(
          quizId: _currentQuizId!,
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
      if (_currentQuizId != null) {
        await _manageLocalAttemptUseCase.clearAttemptId(_currentQuizId!);
      }
      emit(GameFinished(summary));
    } catch (e) {
      emit(GameError(e.toString()));
    }
  }
}
