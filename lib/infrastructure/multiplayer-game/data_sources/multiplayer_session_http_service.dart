import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/backend_config.dart';

/// Servicio HTTP para endpoints REST de sesiones multijugador.
class MultiplayerSessionHttpService {
  final http.Client httpClient;

  MultiplayerSessionHttpService({required this.httpClient});

  /// Construye la URL completa usando el backend activo.
  String _buildUrl(String endpoint) => '${BackendSettings.baseUrl}$endpoint';

  /// Construye los headers comunes.
  Map<String, String> _buildHeaders() {
    return <String, String>{'Content-Type': 'application/json'};
  }

  /// H4.1 - Crear una nueva sesión multijugador.
  /// POST /multiplayer-sessions
  ///
  /// El host crea una sala de juego (Lobby) a partir de un Kahoot existente.
  Future<Map<String, dynamic>> createSession(String kahootId) async {
    final url = _buildUrl('/multiplayer-sessions');
    final body = jsonEncode({'kahootId': kahootId});

    debugPrint('🎮 [MultiplayerHttp] POST $url');
    debugPrint('🎮 [MultiplayerHttp] Body: $body');

    final response = await httpClient.post(
      Uri.parse(url),
      headers: _buildHeaders(),
      body: body,
    );

    debugPrint('🎮 [MultiplayerHttp] Response Status: ${response.statusCode}');
    debugPrint('🎮 [MultiplayerHttp] Response Body: ${response.body}');

    if (response.statusCode == 401) {
      throw Exception(
        '401 Unauthorized: Usuario no tiene permisos para crear sesión con este Kahoot',
      );
    }

    if (response.statusCode == 404) {
      throw Exception('404 Not Found: El Kahoot no existe');
    }

    if (response.statusCode == 500) {
      // Según la API, ante error 500 por generación de PIN, reintentar silenciosamente
      final errorBody = response.body;
      if (errorBody.contains('generar número aleatorio') ||
          errorBody.contains('PIN')) {
        throw RetryableSessionException('Error generando PIN, reintentar');
      }
      throw Exception('500 Internal Server Error: ${response.body}');
    }

    if (response.statusCode != 201) {
      throw Exception(
        'Error al crear sesión: ${response.statusCode} - ${response.body}',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// H4.3 - Obtener PIN de sesión por token QR.
  /// GET /multiplayer-sessions/qr-token/:qrToken
  ///
  /// Permite obtener el sessionPin al escanear un código QR.
  Future<String> getSessionPinByQrToken(String qrToken) async {
    final url = _buildUrl('/multiplayer-sessions/qr-token/$qrToken');

    debugPrint('🎮 [MultiplayerHttp] GET $url');

    final response = await httpClient.get(
      Uri.parse(url),
      headers: _buildHeaders(),
    );

    debugPrint('🎮 [MultiplayerHttp] Response Status: ${response.statusCode}');
    debugPrint('🎮 [MultiplayerHttp] Response Body: ${response.body}');

    if (response.statusCode == 404) {
      throw Exception(
        '404 Not Found: El código QR no está asociado a una sesión activa',
      );
    }

    if (response.statusCode != 200) {
      throw Exception(
        'Error al obtener PIN: ${response.statusCode} - ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['sessionPin'] as String;
  }
}

/// Excepción para errores que se pueden reintentar.
class RetryableSessionException implements Exception {
  final String message;
  RetryableSessionException(this.message);

  @override
  String toString() => message;
}
