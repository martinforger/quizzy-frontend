import 'package:quizzy/application/kahoots/usecases/create_kahoot.dart';
import 'package:quizzy/application/kahoots/usecases/delete_kahoot.dart';
import 'package:quizzy/application/kahoots/usecases/get_kahoot.dart';
import 'package:quizzy/application/kahoots/usecases/update_kahoot.dart';
import 'package:quizzy/domain/kahoots/entities/kahoot.dart';

class KahootController {
  KahootController({
    required this.createKahootUseCase,
    required this.updateKahootUseCase,
    required this.getKahootUseCase,
    required this.deleteKahootUseCase,
  });

  final CreateKahootUseCase createKahootUseCase;
  final UpdateKahootUseCase updateKahootUseCase;
  final GetKahootUseCase getKahootUseCase;
  final DeleteKahootUseCase deleteKahootUseCase;

  Future<Kahoot> create(Kahoot kahoot) => createKahootUseCase(kahoot);
  Future<Kahoot> update(Kahoot kahoot) => updateKahootUseCase(kahoot);
  Future<Kahoot> fetch(String kahootId) => getKahootUseCase(kahootId);
  Future<void> delete(String kahootId) => deleteKahootUseCase(kahootId);
}
