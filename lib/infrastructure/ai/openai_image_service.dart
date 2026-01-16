import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:quizzy/infrastructure/ai/openai_config.dart';

class OpenAiImageService {
  OpenAiImageService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<String> generateImageUrl({
    required String prompt,
    String model = 'dall-e-2',
    String size = '1024x1024',
  }) async {
    if (openAiApiKey.trim().isEmpty || openAiApiKey == 'REPLACE_ME') {
      throw Exception('OpenAI API key no configurada');
    }
    final uri = Uri.parse('https://api.openai.com/v1/images/generations');
    final body = json.encode({
      'model': model,
      'prompt': prompt,
      'size': size,
      'n': 1,
    });

    final response = await _client.post(
      uri,
      headers: {
        'Authorization': 'Bearer $openAiApiKey',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Error al generar imagen: ${response.body}');
    }

    final decoded = json.decode(response.body) as Map<String, dynamic>;
    final data = decoded['data'] as List<dynamic>? ?? <dynamic>[];
    if (data.isEmpty) {
      throw Exception('Respuesta sin imagen');
    }
    final first = data.first as Map<String, dynamic>;
    final url = first['url'] as String?;
    if (url != null && url.isNotEmpty) {
      return url;
    }
    final b64 = first['b64_json'] as String?;
    if (b64 != null && b64.isNotEmpty) {
      return 'data:image/png;base64,$b64';
    }
    throw Exception('Respuesta de imagen invalida');
  }
}
