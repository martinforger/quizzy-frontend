import 'dart:async';
import 'dart:math';
import 'package:quizzy/infrastructure/solo-game/data_sources/game_remote_data_source.dart';

enum MockQustionType { QUIZZ, TRUE_FALSE }

class _MockAttemptSession {
  final String attemptId;
  final String quizId;
  final List<Map<String, dynamic>> slides;
  int currentSlideIndex = 0;
  int currentScore = 0;
  int correctAnswersCount = 0;
  bool isCompleted = false;

  _MockAttemptSession({
    required this.attemptId,
    required this.quizId,
    required this.slides,
  });
}

class MockGameService implements GameRemoteDataSource {
  // Estado interno: Mapa de attemptId -> Session
  final Map<String, _MockAttemptSession> _sessions = {};

  // Simulacion de latencia
  final Duration _latency = const Duration(seconds: 1);

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
        "timeLimitSeconds": 10,
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
        "timeLimitSeconds": 10,
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
        "timeLimitSeconds": 10,
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
        "timeLimitSeconds": 10,
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
        "timeLimitSeconds": 10,
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
        "timeLimitSeconds": 10,
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
        "timeLimitSeconds": 10,
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
        "timeLimitSeconds": 10,
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
        "timeLimitSeconds": 10,
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
        "timeLimitSeconds": 10,
        "mediaID": null,
        "options": [
          {"index": "1", "text": "Verdadero", "mediaID": null},
          {"index": "2", "text": "Falso", "mediaID": null},
        ],
        "correctIndex": ["1"],
      },
    ],
  };

  // H5.1 Iniciar nuevo kahoot
  @override
  Future<Map<String, dynamic>> startNewAttempt(String kahootId) async {
    await Future.delayed(_latency);

    if (!_quizzes.containsKey(kahootId)) {
      throw Exception("404 Not Found: Quiz no encontrado");
    }

    final attemptId = "attemt-${DateTime.now().millisecondsSinceEpoch}";
    final slides = _quizzes[kahootId]!;

    _sessions[attemptId] = _MockAttemptSession(
      attemptId: attemptId,
      quizId: kahootId,
      slides: slides,
    );

    final firstSlide = Map<String, dynamic>.from(slides.first);
    firstSlide.remove("correctIndex");

    return {
      "attemptId": attemptId,
      "firstSlide": firstSlide,
      "currentQuestionIndex": 0,
      "totalQuestions": slides.length,
    };
  }

  // H5.2 Obtener el estado del intento y proxima pregunta
  @override
  Future<Map<String, dynamic>> getAttemptState(String attemptId) async {
    await Future.delayed(_latency);

    if (!_sessions.containsKey(attemptId)) {
      throw Exception("404 Not Found: Intento no encontrado");
    }

    final session = _sessions[attemptId]!;

    Map<String, dynamic>? nextSlideData;

    if (!session.isCompleted &&
        session.currentSlideIndex < session.slides.length) {
      nextSlideData = Map<String, dynamic>.from(
        session.slides[session.currentSlideIndex],
      );
      nextSlideData.remove("correctIndex");
    }

    return {
      "attemptId": session.attemptId,
      "state": session.isCompleted ? "COMPLETED" : "IN_PROGRESS",
      "currentScore": session.currentScore,
      "nextSlide": session.isCompleted ? null : nextSlideData,
      "currentQuestionIndex": session.currentSlideIndex,
      "totalQuestions": session.slides.length,
    };
  }

  // H5.3 Enviar respuesto de un slide y avanzar
  @override
  Future<Map<String, dynamic>> submitAnswer(
    String attemptId,
    Map<String, dynamic> body,
  ) async {
    await Future.delayed(_latency);

    if (!_sessions.containsKey(attemptId)) {
      throw Exception("404 Not Found: Intento no encontrado");
    }

    final session = _sessions[attemptId]!;

    if (session.isCompleted) {
      throw Exception("400 Bad Request: El juego ya ha terminado");
    }

    final String slideId = body["slideId"];
    final List<dynamic> answerIndexes = body["answerIndexes"];

    final currentSlideConfig = session.slides[session.currentSlideIndex];

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
      session.currentScore += pointsEarned;
      session.correctAnswersCount++;
    }

    session.currentSlideIndex++;

    if (session.currentSlideIndex >= session.slides.length) {
      session.isCompleted = true;
    }

    Map<String, dynamic>? nextSlideData;
    if (!session.isCompleted) {
      nextSlideData = Map<String, dynamic>.from(
        session.slides[session.currentSlideIndex],
      );
      nextSlideData.remove("correctIndex");
    }

    return {
      "wasCorrect": isCorrect,
      "pointsEarned": pointsEarned,
      "updatedScore": session.currentScore,
      "attemptState": session.isCompleted ? "COMPLETED" : "IN_PROGRESS",
      "nextSlide":
          nextSlideData, // Si es null, el front sabe que debe pedir el summary
      "currentQuestionIndex": session.currentSlideIndex,
      "totalQuestions": session.slides.length,
    };
  }

  // H5.4 Obtener resumen del intento
  @override
  Future<Map<String, dynamic>> getAttemptSummary(String attemptId) async {
    await Future.delayed(_latency);

    if (!_sessions.containsKey(attemptId)) {
      throw Exception("404 Not Found: Intento no encontrado");
    }

    final session = _sessions[attemptId]!;

    if (!session.isCompleted) {
      throw Exception("400 Bad Request: El juego no ha terminado");
    }

    int totalQuestions = session.slides.length;
    double accuracy = (totalQuestions > 0)
        ? (session.correctAnswersCount / totalQuestions) * 100
        : 0.0;

    return {
      "attemptId": session.attemptId,
      "finalScore": session.currentScore,
      "totalCorrect": session.correctAnswersCount,
      "totalQuestions": totalQuestions,
      "accuracyPercentage": accuracy.round(), // Devuelve entero ej: 80
    };
  }
}
