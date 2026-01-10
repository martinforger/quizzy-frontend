import 'dart:convert';
import 'package:http/http.dart' as http;
import '../backend_config.dart';
import 'game_remote_data_source.dart';

/// Implementación HTTP real de [GameRemoteDataSource].
///
/// Se conecta al backend configurado en [BackendSettings] para realizar
/// las operaciones del juego solitario. Soporta cambio dinámico de backend.
class HttpGameService implements GameRemoteDataSource {
  final http.Client httpClient;

  /// Token de acceso para autenticación.
  /// Debe ser establecido antes de hacer llamadas a la API.
  String? accessToken;

  HttpGameService({required this.httpClient, this.accessToken});

  /// Construye la URL completa usando el backend activo.
  String _buildUrl(String endpoint) => '${BackendSettings.baseUrl}$endpoint';

  /// Construye los headers comunes incluyendo autenticación.
  Map<String, String> _buildHeaders() {
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (accessToken != null && accessToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    return headers;
  }

  /// H5.1 - Iniciar un Nuevo Kahoot en Modo Solitario
  ///
  /// POST /attempts
  /// Body: {kahootId: uuid}
  /// Response: {attemptId, firstSlide: {...}}
  @override
  Future<Map<String, dynamic>> startNewAttempt(String kahootId) async {
    final response = await httpClient.post(
      Uri.parse(_buildUrl('/attempts')),
      headers: _buildHeaders(),
      body: jsonEncode({'kahootId': kahootId}),
    );

    if (response.statusCode == 401) {
      throw Exception('401 Unauthorized: Usuario no autenticado');
    }

    if (response.statusCode == 404) {
      throw Exception(
        '404 Not Found: El Kahoot no existe o no es accesible para el usuario',
      );
    }

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Error al iniciar intento: ${response.statusCode} - ${response.body}',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// H5.2 - Obtener el Estado Actual del Intento/Próxima Pregunta
  ///
  /// GET /attempts/:attemptId
  /// Response: {attemptId, state, currentScore, nextSlide: {...}}
  ///
  /// Usar este endpoint para reanudar un kahoot singleplayer pausado.
  @override
  Future<Map<String, dynamic>> getAttemptState(String attemptId) async {
    final response = await httpClient.get(
      Uri.parse(_buildUrl('/attempts/$attemptId')),
      headers: _buildHeaders(),
    );

    if (response.statusCode == 404) {
      throw Exception(
        '404 Not Found: Intento no existe o no pertenece al usuario',
      );
    }

    if (response.statusCode != 200) {
      throw Exception(
        'Error al obtener estado: ${response.statusCode} - ${response.body}',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// H5.3 - Enviar respuesta de un slide y avanzar
  ///
  /// POST /attempts/:attemptId/answer
  /// Body: {slideId, answerIndex: [], timeElapsedSeconds}
  /// Response: {wasCorrect, pointsEarned, updatedScore, attemptState, nextSlide}
  @override
  Future<Map<String, dynamic>> submitAnswer(
    String attemptId,
    Map<String, dynamic> body,
  ) async {
    // Adaptar el body al formato esperado por la API real
    // La API espera "answerIndex" (array), el repositorio envía "answerIndexes"
    final apiBody = {
      'slideId': body['slideId'],
      'answerIndex': body['answerIndexes'] ?? body['answerIndex'] ?? [],
      'timeElapsedSeconds': body['timeElapsedSeconds'],
    };

    final response = await httpClient.post(
      Uri.parse(_buildUrl('/attempts/$attemptId/answer')),
      headers: _buildHeaders(),
      body: jsonEncode(apiBody),
    );

    if (response.statusCode == 400) {
      throw Exception(
        '400 Bad Request: Slide ya respondida o estado no IN_PROGRESS',
      );
    }

    if (response.statusCode == 404) {
      throw Exception(
        '404 Not Found: Intento no existe o no pertenece al usuario',
      );
    }

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Error al enviar respuesta: ${response.statusCode} - ${response.body}',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// H5.4 - Obtener resumen del intento realizado
  ///
  /// GET /attempts/:attemptId/summary
  /// Response: {attemptId, finalScore, totalCorrect, totalQuestions, accuracyPercentage}
  @override
  Future<Map<String, dynamic>> getAttemptSummary(String attemptId) async {
    final response = await httpClient.get(
      Uri.parse(_buildUrl('/attempts/$attemptId/summary')),
      headers: _buildHeaders(),
    );

    if (response.statusCode == 400) {
      throw Exception('400 Bad Request: El intento no ha sido completado');
    }

    if (response.statusCode == 404) {
      throw Exception(
        '404 Not Found: Intento no existe o no pertenece al usuario',
      );
    }

    if (response.statusCode != 200) {
      throw Exception(
        'Error al obtener resumen: ${response.statusCode} - ${response.body}',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Establece el token de acceso para autenticación.
  void setAccessToken(String token) {
    accessToken = token;
  }

  /// Limpia el token de acceso (para logout).
  void clearAccessToken() {
    accessToken = null;
  }
}
