import '../../../domain/solo-game/repositories/game_repository.dart';
import '../../../domain/solo-game/entities/attempt_entity.dart';
import '../../../domain/solo-game/entities/summary_entity.dart';
import '../data_sources/game_remote_data_source.dart';
import '../models/attempt_model.dart';
import '../models/summary_model.dart';

class GameRepositoryImpl implements GameRepository {
  final GameRemoteDataSource _remoteDataSource;

  GameRepositoryImpl(this._remoteDataSource);

  @override
  Future<AttemptEntity> startNewAttempt(String kahootId) async {
    try {
      final response = await _remoteDataSource.startNewAttempt(kahootId);
      return AttemptModel.fromJson(response);
    } catch (e) {
      throw Exception("Repository Error (Start): $e");
    }
  }

  @override
  Future<AttemptEntity> getAttemptState(String attemptId) async {
    try {
      final response = await _remoteDataSource.getAttemptState(attemptId);
      return AttemptModel.fromJson(response);
    } catch (e) {
      throw Exception("Repository Error (GetState): $e");
    }
  }

  @override
  Future<AttemptEntity> submitAnswer({
    required String attemptId,
    required String slideId,
    required List<int> answerIndices,
    required int timeElapsed,
  }) async {
    try {
      final body = {
        "slideId": slideId,
        "answerIndex": answerIndices,
        "timeElapsedSeconds": timeElapsed,
      };

      final response = await _remoteDataSource.submitAnswer(attemptId, body);
      return AttemptModel.fromJson(response);
    } catch (e) {
      throw Exception("Repository Error (Submit): $e");
    }
  }

  @override
  Future<SummaryEntity> getSummary(String attemptId) async {
    try {
      final response = await _remoteDataSource.getAttemptSummary(attemptId);
      return SummaryModel.fromJson(response);
    } catch (e) {
      throw Exception("Repository Error (Summary): $e");
    }
  }
}
