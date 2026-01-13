import 'package:flutter_test/flutter_test.dart';
import 'package:quizzy/application/kahoots/usecases/create_kahoot.dart';
import 'package:quizzy/domain/kahoots/entities/kahoot.dart';
import 'package:quizzy/domain/kahoots/repositories/kahoots_repository.dart';

import '../../helpers/kahoot_builder.dart';
import '../../helpers/kahoot_mother.dart';

// Mock Manual
class MockKahootsRepository implements KahootsRepository {
  var createKahootCalled = false;
  Kahoot? lastCreatedKahoot;

  @override
  Future<Kahoot> createKahoot(Kahoot kahoot) async {
    createKahootCalled = true;
    lastCreatedKahoot = kahoot;
    return kahoot;
  }

  @override
  Future<void> deleteKahoot(String kahootId) async {}

  @override
  Future<Kahoot> getKahoot(String kahootId) async => KahootMother.random();

  @override
  Future<Kahoot> inspectKahoot(String kahootId) async => KahootMother.random();

  @override
  Future<Kahoot> updateKahoot(Kahoot kahoot) async => kahoot;
}

void main() {
  late CreateKahootUseCase useCase;
  late MockKahootsRepository mockRepository;

  setUp(() {
    mockRepository = MockKahootsRepository();
    useCase = CreateKahootUseCase(mockRepository);
  });

  group('CreateKahootUseCase (Test Limpio con Object Mother y Builder)', () {
    test('debería crear un kahoot publicado exitosamente', () async {
      // Arrange (Preparar - Usando Object Mother)
      final kahoot = KahootMother.published();

      // Act (Actuar)
      final result = await useCase(kahoot);

      // Assert (Verificar)
      expect(mockRepository.createKahootCalled, isTrue);
      expect(result.status, 'published');
      expect(result.visibility, 'public');
    });

    test('debería crear un borrador de kahoot con título personalizado usando Builder', () async {
      // Arrange (Preparar - Usando Builder)
      final kahoot = KahootBuilder()
          .withStatus('draft')
          .withTitle('Mi Borrador Personalizado')
          .build();

      // Act (Actuar)
      final result = await useCase(kahoot);

      // Assert (Verificar)
      expect(result.title, 'Mi Borrador Personalizado');
      expect(result.status, 'draft');
    });
  });
}
