abstract class GameRemoteDataSource {
  /// H5.1
  Future<Map<String, dynamic>> startNewAttempt(String kahootId);

  /// H5.2
  Future<Map<String, dynamic>> getAttemptState(String attemptId);

  /// H5.3
  Future<Map<String, dynamic>> submitAnswer(
    String attemptId,
    Map<String, dynamic> body,
  );

  /// H5.4
  Future<Map<String, dynamic>> getAttemptSummary(String attemptId);
}
