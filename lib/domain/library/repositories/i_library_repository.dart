import 'package:quizzy/domain/library/entities/library_item.dart';

abstract class ILibraryRepository {
  Future<LibraryResponse> getMyCreations(LibraryQueryParams params);
  
  Future<LibraryResponse> getFavorites(LibraryQueryParams params);
  
  Future<void> markAsFavorite(String kahootId);
  
  Future<void> unmarkAsFavorite(String kahootId);
  
  Future<LibraryResponse> getInProgress(LibraryQueryParams params);
  
  Future<LibraryResponse> getCompleted(LibraryQueryParams params);
}
