import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalGameStorage {
  static const _keySessions = 'saved_game_sessions';

  Future<void> saveSession({
    required String quizId,
    required String attemptId,
    required int currentQuestionIndex,
    required int totalQuestions,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final allSessions = await getAllSessions();

    allSessions[quizId] = {
      'quizId': quizId,
      'attemptId': attemptId,
      'currentQuestionIndex': currentQuestionIndex,
      'totalQuestions': totalQuestions,
    };

    await prefs.setString(_keySessions, jsonEncode(allSessions));
  }

  Future<Map<String, dynamic>?> getSession(String quizId) async {
    final allSessions = await getAllSessions();
    return allSessions[quizId];
  }

  Future<Map<String, Map<String, dynamic>>> getAllSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keySessions);
    if (jsonString != null) {
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      // Ensure typing
      return decoded.map(
        (key, value) => MapEntry(key, value as Map<String, dynamic>),
      );
    }
    return {};
  }

  // Deprecated usage removed or adapted
  Future<String?> getAttemptId(String quizId) async {
    final session = await getSession(quizId);
    return session?['attemptId'];
  }

  Future<void> clearSession(String quizId) async {
    final prefs = await SharedPreferences.getInstance();
    final allSessions = await getAllSessions();
    if (allSessions.containsKey(quizId)) {
      allSessions.remove(quizId);
      await prefs.setString(_keySessions, jsonEncode(allSessions));
    }
  }
}
