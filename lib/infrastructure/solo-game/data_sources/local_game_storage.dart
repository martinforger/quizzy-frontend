import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalGameStorage {
  static const _keySession = 'current_game_session';

  Future<void> saveSession({
    required String quizId,
    required String attemptId,
    required int currentQuestionIndex,
    required int totalQuestions,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode({
      'quizId': quizId,
      'attemptId': attemptId,
      'currentQuestionIndex': currentQuestionIndex,
      'totalQuestions': totalQuestions,
    });
    await prefs.setString(_keySession, jsonString);
  }

  Future<Map<String, dynamic>?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keySession);
    if (jsonString != null) {
      return jsonDecode(jsonString);
    }
    return null;
  }

  // Deprecated shim if needed, or update consumers
  Future<String?> getAttemptId() async {
    final session = await getSession();
    return session?['attemptId'];
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySession);
  }
}
