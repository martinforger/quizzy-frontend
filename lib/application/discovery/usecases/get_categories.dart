import 'package:quizzy/domain/discovery/entities/category.dart';
import 'package:quizzy/domain/discovery/repositories/discovery_repository.dart';

class GetCategoriesUseCase {
  GetCategoriesUseCase(this.repository);

  final DiscoveryRepository repository;

  // Ejecuta el flujo para obtener la lista de categor?as.
  Future<List<Category>> call() {
    return repository.getCategories();
  }
}
