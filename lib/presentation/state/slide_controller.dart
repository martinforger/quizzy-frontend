import 'package:quizzy/application/kahoots/usecases/create_slide.dart';
import 'package:quizzy/application/kahoots/usecases/delete_slide.dart';
import 'package:quizzy/application/kahoots/usecases/duplicate_slide.dart';
import 'package:quizzy/application/kahoots/usecases/get_slide.dart';
import 'package:quizzy/application/kahoots/usecases/list_slides.dart';
import 'package:quizzy/application/kahoots/usecases/update_slide.dart';
import 'package:quizzy/domain/kahoots/entities/slide.dart';

class SlideController {
  SlideController({
    required this.listSlidesUseCase,
    required this.getSlideUseCase,
    required this.createSlideUseCase,
    required this.updateSlideUseCase,
    required this.duplicateSlideUseCase,
    required this.deleteSlideUseCase,
  });

  final ListSlidesUseCase listSlidesUseCase;
  final GetSlideUseCase getSlideUseCase;
  final CreateSlideUseCase createSlideUseCase;
  final UpdateSlideUseCase updateSlideUseCase;
  final DuplicateSlideUseCase duplicateSlideUseCase;
  final DeleteSlideUseCase deleteSlideUseCase;

  Future<List<Slide>> listSlides(String kahootId) => listSlidesUseCase(kahootId);
  Future<Slide> getSlide(String kahootId, String slideId) => getSlideUseCase(kahootId, slideId);
  Future<Slide> createSlide(String kahootId, Slide slide) => createSlideUseCase(kahootId, slide);
  Future<Slide> updateSlide(String kahootId, Slide slide) => updateSlideUseCase(kahootId, slide);
  Future<Slide> duplicateSlide(String kahootId, String slideId) => duplicateSlideUseCase(kahootId, slideId);
  Future<void> deleteSlide(String kahootId, String slideId) => deleteSlideUseCase(kahootId, slideId);
}
