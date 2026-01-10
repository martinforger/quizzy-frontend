import 'package:quizzy/application/kahoots/usecases/create_kahoot.dart';
import 'package:quizzy/application/kahoots/usecases/delete_kahoot.dart';
import 'package:quizzy/application/kahoots/usecases/get_kahoot.dart';
import 'package:quizzy/application/kahoots/usecases/update_kahoot.dart';
import 'package:quizzy/domain/kahoots/entities/kahoot.dart';
import 'package:quizzy/application/kahoots/usecases/inspect_kahoot.dart';

class KahootController {
  KahootController({
    required this.createKahootUseCase,
    required this.updateKahootUseCase,
    required this.getKahootUseCase,
    required this.deleteKahootUseCase,
    required this.inspectKahootUseCase,
  });

  final CreateKahootUseCase createKahootUseCase;
  final UpdateKahootUseCase updateKahootUseCase;
  final GetKahootUseCase getKahootUseCase;
  final DeleteKahootUseCase deleteKahootUseCase;
  final InspectKahootUseCase inspectKahootUseCase;

  Future<Kahoot> create(Kahoot kahoot) => createKahootUseCase(kahoot);
  Future<Kahoot> update(Kahoot kahoot) => updateKahootUseCase(kahoot);
  Future<Kahoot> fetch(String kahootId) => getKahootUseCase(kahootId);
  Future<Kahoot> inspect(String kahootId) => inspectKahootUseCase(kahootId);
  Future<void> delete(String kahootId) => deleteKahootUseCase(kahootId);
}
