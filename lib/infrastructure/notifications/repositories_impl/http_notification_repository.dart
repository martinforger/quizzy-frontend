import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quizzy/domain/notifications/entities/notification_item.dart';
import 'package:quizzy/domain/notifications/repositories/notification_repository.dart';
import 'package:quizzy/infrastructure/core/backend_config.dart';
import 'package:quizzy/infrastructure/notifications/dtos/notification_dto.dart';

class HttpNotificationRepository implements NotificationRepository {
  final http.Client client;

  HttpNotificationRepository({required this.client});

  Uri _resolve(String path) => Uri.parse('${BackendSettings.baseUrl}/$path');

  @override
  Future<void> registerDevice({
    required String token,
    required String deviceType,
    required String accessToken,
  }) async {
    final uri = _resolve('notifications/register-device');
    final response = await client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'token': token,
        'deviceType': deviceType,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to register device: ${response.statusCode}');
    }
  }

  @override
  Future<void> unregisterDevice({
    required String token,
    String? accessToken,
  }) async {
    final uri = _resolve('notifications/unregister-device');
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    final response = await client.delete(
      uri,
      headers: headers,
      body: jsonEncode({
        'token': token,
      }),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to unregister device: ${response.statusCode}');
    }
  }

  @override
  Future<List<NotificationItem>> getNotifications({
    int limit = 20,
    int page = 1,
  }) async {
    final uri = _resolve('notifications').replace(queryParameters: {
      'limit': limit.toString(),
      'page': page.toString(),
    });

    final response = await client.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList
          .map((json) => NotificationDto.fromJson(json).toDomain())
          .toList();
    } else {
      throw Exception('Failed to fetch notifications: ${response.statusCode}');
    }
  }

  @override
  Future<NotificationItem> markAsRead(String id) async {
    final uri = _resolve('notifications/$id');
    final response = await client.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'isRead': true}),
    );

    if (response.statusCode == 200) {
      return NotificationDto.fromJson(jsonDecode(response.body)).toDomain();
    } else {
      throw Exception(
          'Failed to mark notification as read: ${response.statusCode}');
    }
  }
}
