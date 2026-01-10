import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:quizzy/domain/kahoots/entities/kahoot.dart';
import 'package:quizzy/domain/kahoots/entities/kahoot_question.dart';
import 'package:quizzy/infrastructure/kahoots/repositories_impl/http_kahoots_repository.dart';

void main() {
  group('HttpKahootsRepository', () {
    test(
      'inspectKahoot maps JSON correctly with author object and game state',
      () async {
        final mockResponse = {
          "id": "123",
          "title": "Test Kahoot",
          "author": {"id": "author-uuid", "name": "Author Name"},
          "gameState": {
            "attemptId": "attempt-1",
            "currentScore": 100,
            "currentSlide": 5,
            "totalSlides": 10,
            "lastPlayedAt": "2023-01-01T12:00:00Z",
          },
          "isInProgress": true,
          "isCompleted": false,
          "isFavorite": true,
        };

        final client = MockClient((request) async {
          if (request.url.path.endsWith('/kahoots/inspect/123')) {
            return http.Response(jsonEncode(mockResponse), 200);
          }
          return http.Response('Not Found', 404);
        });

        final repository = HttpKahootsRepository(client: client);
        final kahoot = await repository.inspectKahoot('123');

        expect(kahoot.id, '123');
        expect(kahoot.title, 'Test Kahoot');
        expect(kahoot.authorId, 'author-uuid');
        expect(kahoot.authorName, 'Author Name');
        expect(kahoot.isInProgress, true);
        expect(kahoot.isFavorite, true);
        expect(kahoot.gameState, isNotNull);
        expect(kahoot.gameState?.attemptId, 'attempt-1');
        expect(kahoot.gameState?.currentScore, 100);
        expect(kahoot.gameState?.currentSlide, 5);
        expect(kahoot.gameState?.totalSlides, 10);
      },
    );

    test('createKahoot serializes all fields correctly', () async {
      final kahoot = Kahoot(
        title: 'New Kahoot',
        description: 'Desc',
        authorId: 'auth-1',
        themeId: 'theme-1',
        visibility: 'public',
        questions: [KahootQuestion(type: 'quiz', points: null, answers: [])],
      );

      var capturedBody = '';

      final client = MockClient((request) async {
        if (request.url.path.endsWith('/kahoots') && request.method == 'POST') {
          capturedBody = request.body;
          return http.Response(
            jsonEncode({'id': 'new-id', ...jsonDecode(request.body)}),
            201,
          );
        }
        return http.Response('Error', 400);
      });

      final repository = HttpKahootsRepository(client: client);
      await repository.createKahoot(kahoot);

      final bodyJson = jsonDecode(capturedBody);
      expect(bodyJson['title'], 'New Kahoot');
      expect(bodyJson['description'], 'Desc');
      expect(bodyJson.containsKey('authorId'), false);
      expect(bodyJson['visibility'], 'Public');
      expect(
        bodyJson['status'],
        'Draft',
      ); // Kahoot default construction has null status, or user provided?
      // Wait, let's check the test setup.
      // In the test:
      // final kahoot = Kahoot(..., visibility: 'public', ...);
      // It doesn't set status, so status is null?
      // But _toJson looks at kahoot.status. If null, (null == 'published') is false -> 'Draft'.
      // So status should be 'Draft'.

      final questions = bodyJson['questions'] as List;
      expect(questions[0]['points'], 1000);
      expect(questions[0]['type'], 'single');
    });

    test('updateKahoot serializes correctly without id in body', () async {
      final kahoot = Kahoot(
        id: 'kahoot-123',
        title: 'Updated Kahoot',
        description: 'New Desc',
        authorId: 'auth-1',
        themeId: 'theme-1',
        visibility: 'private',
        questions: [],
      );

      var capturedBody = '';

      final client = MockClient((request) async {
        if (request.url.path.endsWith('/kahoots/kahoot-123') &&
            request.method == 'PUT') {
          capturedBody = request.body;
          return http.Response(
            jsonEncode({'id': 'kahoot-123', ...jsonDecode(request.body)}),
            200,
          );
        }
        return http.Response('Error', 400);
      });

      final repository = HttpKahootsRepository(client: client);
      await repository.updateKahoot(kahoot);

      final bodyJson = jsonDecode(capturedBody);
      expect(bodyJson['title'], 'Updated Kahoot');
      expect(bodyJson.containsKey('id'), false); // Critical assertion
      expect(bodyJson['visibility'], 'Private');
    });
  });
}
