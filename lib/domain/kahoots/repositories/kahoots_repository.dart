import 'package:quizzy/domain/kahoots/entities/kahoot.dart';

abstract class KahootsRepository {
  Future<Kahoot> createKahoot(Kahoot kahoot);
  Future<Kahoot> updateKahoot(Kahoot kahoot);
  Future<Kahoot> getKahoot(String kahootId);
  Future<Kahoot> inspectKahoot(String kahootId);
  Future<void> deleteKahoot(String kahootId);
}
