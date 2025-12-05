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
  // Datos de prueba (kahoots)
  final Map<String, List<Map<String, dynamic>>> _quizzes = {
    "kahoot-demo-id": [
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
        "correctIndex": ["2"],
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
    ],
    "quiz-design-patterns": [
      {
        "slideId": "dp-001",
        "questionType": "QUIZ",
        "questionText":
            "¿Qué patrón de diseño pertenece a la categoría Creacional?",
        "timeLimitSeconds": 30,
        "mediaID": null,
        "options": [
          {"index": "1", "text": "Observer", "mediaID": null},
          {"index": "2", "text": "Singleton", "mediaID": null},
          {"index": "3", "text": "Adapter", "mediaID": null},
          {"index": "4", "text": "Strategy", "mediaID": null},
        ],
        "correctIndex": ["2"],
      },
      {
        "slideId": "dp-002",
        "questionType": "QUIZ",
        "questionText":
            "¿Cuál es el propósito principal del patrón Factory Method?",
        "timeLimitSeconds": 45,
        "mediaID": null,
        "options": [
          {
            "index": "1",
            "text": "Crear objetos sin especificar la clase exacta",
            "mediaID": null,
          },
          {
            "index": "2",
            "text": "Asegurar que una clase tenga una única instancia",
            "mediaID": null,
          },
          {
            "index": "3",
            "text": "Convertir la interfaz de una clase en otra",
            "mediaID": null,
          },
          {
            "index": "4",
            "text": "Definir una familia de algoritmos",
            "mediaID": null,
          },
        ],
        "correctIndex": ["1"],
      },
      {
        "slideId": "dp-003",
        "questionType": "QUIZ",
        "questionText":
            "¿Qué patrón se utiliza para notificar cambios a múltiples objetos?",
        "timeLimitSeconds": 30,
        "mediaID": null,
        "options": [
          {"index": "1", "text": "Command", "mediaID": null},
          {"index": "2", "text": "Observer", "mediaID": null},
          {"index": "3", "text": "Iterator", "mediaID": null},
          {"index": "4", "text": "State", "mediaID": null},
        ],
        "correctIndex": ["2"],
      },
      {
        "slideId": "dp-004",
        "questionType": "QUIZ",
        "questionText":
            "El patrón Adapter permite que clases con interfaces incompatibles trabajen juntas.",
        "timeLimitSeconds": 20,
        "mediaID": null,
        "options": [
          {"index": "1", "text": "Verdadero", "mediaID": null},
          {"index": "2", "text": "Falso", "mediaID": null},
        ],
        "correctIndex": ["1"],
      },
      {
        "slideId": "dp-005",
        "questionType": "QUIZ",
        "questionText":
            "¿Qué patrón estructural se usa para añadir responsabilidades a objetos dinámicamente?",
        "timeLimitSeconds": 40,
        "mediaID": null,
        "options": [
          {"index": "1", "text": "Facade", "mediaID": null},
          {"index": "2", "text": "Decorator", "mediaID": null},
          {"index": "3", "text": "Proxy", "mediaID": null},
          {"index": "4", "text": "Composite", "mediaID": null},
        ],
        "correctIndex": ["2"],
      },
      {
        "slideId": "dp-006",
        "questionType": "QUIZ",
        "questionText": "¿Cuál de estos NO es un patrón de comportamiento?",
        "timeLimitSeconds": 30,
        "mediaID": null,
        "options": [
          {"index": "1", "text": "Memento", "mediaID": null},
          {"index": "2", "text": "Mediator", "mediaID": null},
          {"index": "3", "text": "Builder", "mediaID": null},
          {"index": "4", "text": "Visitor", "mediaID": null},
        ],
        "correctIndex": ["3"],
      },
      {
        "slideId": "dp-007",
        "questionType": "QUIZ",
        "questionText":
            "El patrón Singleton es considerado un anti-patrón por algunos desarrolladores.",
        "timeLimitSeconds": 20,
        "mediaID": null,
        "options": [
          {"index": "1", "text": "Verdadero", "mediaID": null},
          {"index": "2", "text": "Falso", "mediaID": null},
        ],
        "correctIndex": ["1"],
      },
      {
        "slideId": "dp-008",
        "questionType": "QUIZ",
        "questionText":
            "¿Qué patrón se utiliza para encapsular una petición como un objeto?",
        "timeLimitSeconds": 35,
        "mediaID": null,
        "options": [
          {"index": "1", "text": "Command", "mediaID": null},
          {"index": "2", "text": "Chain of Responsibility", "mediaID": null},
          {"index": "3", "text": "Template Method", "mediaID": null},
          {"index": "4", "text": "Strategy", "mediaID": null},
        ],
        "correctIndex": ["1"],
      },
      {
        "slideId": "dp-009",
        "questionType": "QUIZ",
        "questionText":
            "¿Qué patrón provee una interfaz unificada para un conjunto de interfaces en un subsistema?",
        "timeLimitSeconds": 30,
        "mediaID": null,
        "options": [
          {"index": "1", "text": "Bridge", "mediaID": null},
          {"index": "2", "text": "Flyweight", "mediaID": null},
          {"index": "3", "text": "Facade", "mediaID": null},
          {"index": "4", "text": "Proxy", "mediaID": null},
        ],
        "correctIndex": ["3"],
      },
      {
        "slideId": "dp-010",
        "questionType": "QUIZ",
        "questionText":
            "El patrón Strategy permite intercambiar algoritmos en tiempo de ejecución.",
        "timeLimitSeconds": 25,
        "mediaID": null,
        "options": [
          {"index": "1", "text": "Verdadero", "mediaID": null},
          {"index": "2", "text": "Falso", "mediaID": null},
        ],
        "correctIndex": ["1"],
      },
    ],
  };

  List<Map<String, dynamic>> _currentSlides = [];

  // H5.1 Iniciar nuevo kahoot
  @override
  Future<Map<String, dynamic>> startNewAttempt(String kahootId) async {
    await Future.delayed(_latency);

    if (!_quizzes.containsKey(kahootId)) {
      throw Exception("404 Not Found: Quiz no encontrado");
    }

    _currentSlides = _quizzes[kahootId]!;
    _currentAttemptId = "attemt-${DateTime.now().millisecondsSinceEpoch}";
    _currentSlideIndex = 0;
    _currentScore = 0;
    _correctAnswersCount = 0;
    _isCompleted = false;

    final firstSlide = Map<String, dynamic>.from(_currentSlides.first);
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

    if (!_isCompleted && _currentSlideIndex < _currentSlides.length) {
      nextSlideData = Map<String, dynamic>.from(
        _currentSlides[_currentSlideIndex],
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

    final currentSlideConfig = _currentSlides[_currentSlideIndex];

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

    if (_currentSlideIndex >= _currentSlides.length) {
      _isCompleted = true;
    }

    Map<String, dynamic>? nextSlideData;
    if (!_isCompleted) {
      nextSlideData = Map<String, dynamic>.from(
        _currentSlides[_currentSlideIndex],
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

    int totalQuestions = _currentSlides.length;
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
