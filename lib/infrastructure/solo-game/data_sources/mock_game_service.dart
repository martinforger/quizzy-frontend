import 'dart:async';
import 'dart:math';
import 'package:quizzy/infrastructure/solo-game/data_sources/game_remote_data_source.dart';

enum MockQustionType { QUIZZ, TRUE_FALSE }

class MockGameService implements GameRemoteDataSource {
  // Estado interno
  String? _currentAttemptId;
  int _currentSlideIndex = 0;
  int _currentScore = 0;
  int _correctAnswersCount = 0;
  bool _isCompleted = false;

  // Simulacion de latencia
  final Duration _latency = const Duration(seconds: 1);

  // Datos de prueba (kahoots)
  final List<Map<String, dynamic>> _mockSlides = [
    {
      "slideId": "slide-001",
      "questionType": "QUIZ",
      "questionText": "¿Cuál es la capital de Francia?",
      "timeLimitSeconds": 30,
      "mediaID":
          "https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&q=80&w=1000",
      "options": [
        {"index": "1", "text": "Madrid", "mediaID": null},
        {
          "index": "2",
          "text": "París",
          "mediaID": null,
        }, // Correcta (lógica interna)
        {"index": "3", "text": "Londres", "mediaID": null},
        {"index": "4", "text": "Berlín", "mediaID": null},
      ],
      "correctIndex": [
        "2",
      ], // Esto NO se envía al front, es para validación interna del mock
    },
    {
      "slideId": "slide-002",
      "questionType": "QUIZ",
      "questionText": "¿Qué animal aparece en la imagen?",
      "timeLimitSeconds": 20,
      "mediaID":
          "https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&q=80&w=1000", // Perro
      "options": [
        {"index": "1", "text": "Gato", "mediaID": null},
        {"index": "2", "text": "Perro", "mediaID": null}, // Correcta
      ],
      "correctIndex": ["2"],
    },
    {
      "slideId": "slide-003",
      "questionType": "TRUE_FALSE",
      "questionText": "Flutter es desarrollado por Google.",
      "timeLimitSeconds": 10,
      "mediaID": null,
      "options": [
        {"index": "1", "text": "Verdadero", "mediaID": null}, // Correcta
        {"index": "2", "text": "Falso", "mediaID": null},
      ],
      "correctIndex": ["1"],
    },
  ];

  // H5.1 Iniciar nuevo kahoot
  @override
  Future<Map<String, dynamic>> startNewAttempt(String kahootId) async {
    await Future.delayed(_latency);

    _currentAttemptId = "attemt-${DateTime.now().millisecondsSinceEpoch}";
    _currentSlideIndex = 0;
    _currentScore = 0;
    _correctAnswersCount = 0;
    _isCompleted = false;

    final firstSlide = Map<String, dynamic>.from(_mockSlides.first);
    firstSlide.remove("correctIndex");

    return {"attemptId": _currentAttemptId, "firstSlide": firstSlide};
  }

  // H5.2 Obtener el estado del intento y proxima pregunta
  @override
  Future<Map<String, dynamic>> getAttemptState(String attemptId) async {
    await Future.delayed(_latency);

    if (attemptId != _currentAttemptId) {
      throw Exception("404 Not Found: Intento no encontrado");
    }

    Map<String, dynamic>? nextSlideData;

    if (!_isCompleted && _currentSlideIndex < _mockSlides.length) {
      nextSlideData = Map<String, dynamic>.from(
        _mockSlides[_currentSlideIndex],
      );
      nextSlideData.remove("correctIndex");
    }

    return {
      "attemptId": _currentAttemptId,
      "state": _isCompleted ? "COMPLETED" : "IN_PROGRESS",
      "currentScore": _currentScore,
      "nextSlide": _isCompleted ? null : nextSlideData,
    };
  }

  // H5.3 Enviar respuesto de un slide y avanzar
  @override
  Future<Map<String, dynamic>> submitAnswer(
    String attemptId,
    Map<String, dynamic> body,
  ) async {
    await Future.delayed(_latency);

    if (attemptId != _currentAttemptId) {
      throw Exception("404 Not Found: Intento no encontrado");
    }

    if (_isCompleted) {
      throw Exception("400 Bad Request: El juego ya ha terminado");
    }

    final String slideId = body["slideId"];
    final List<dynamic> answerIndexes = body["answerIndexes"];

    final currentSlideConfig = _mockSlides[_currentSlideIndex];

    if (currentSlideConfig['slideId'] != slideId) {
      throw Exception("400 Bad Request: Slide id no coincide con el actual");
    }

    final List<String> correctIndexes = currentSlideConfig['correctIndex'];

    bool isCorrect = false;
    if (answerIndexes.length == correctIndexes.length) {
      final userAns = answerIndexes.map((e) => e.toString()).toSet();
      final correctAns = correctIndexes.map((e) => e.toString()).toSet();

      isCorrect = userAns.containsAll(correctAns);
    }

    int pointsEarned = 0;
    if (isCorrect) {
      pointsEarned = 1000 - (Random().nextInt(200));
      _currentScore += pointsEarned;
      _correctAnswersCount++;
    }

    _currentSlideIndex++;

    if (_currentSlideIndex >= _mockSlides.length) {
      _isCompleted = true;
    }

    Map<String, dynamic>? nextSlideData;
    if (!_isCompleted) {
      nextSlideData = Map<String, dynamic>.from(
        _mockSlides[_currentSlideIndex],
      );
      nextSlideData.remove("correctIndex");
    }

    return {
      "wasCorrect": isCorrect,
      "pointsEarned": pointsEarned,
      "updatedScore": _currentScore,
      "attemptState": _isCompleted ? "COMPLETED" : "IN_PROGRESS",
      "nextSlide":
          nextSlideData, // Si es null, el front sabe que debe pedir el summary
    };
  }

  // H5.4 Obtener resumen del intento
  @override
  Future<Map<String, dynamic>> getAttemptSummary(String attemptId) async {
    await Future.delayed(_latency);

    if (attemptId != _currentAttemptId) {
      throw Exception("404 Not Found: Intento no encontrado");
    }

    if (!_isCompleted) {
      throw Exception("400 Bad Request: El juego no ha terminado");
    }

    int totalQuestions = _mockSlides.length;
    double accuracy = (totalQuestions > 0)
        ? (_correctAnswersCount / totalQuestions) * 100
        : 0.0;

    return {
      "attemptId": _currentAttemptId,
      "finalScore": _currentScore,
      "totalCorrect": _correctAnswersCount,
      "totalQuestions": totalQuestions,
      "accuracyPercentage": accuracy.round(), // Devuelve entero ej: 80
    };
  }
}
