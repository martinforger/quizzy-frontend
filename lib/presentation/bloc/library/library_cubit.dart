import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quizzy/application/library/usecases/get_completed.dart';
import 'package:quizzy/application/library/usecases/get_favorites.dart';
import 'package:quizzy/application/library/usecases/get_in_progress.dart';
import 'package:quizzy/application/library/usecases/get_my_creations.dart';
import 'package:quizzy/application/library/usecases/mark_as_favorite.dart';
import 'package:quizzy/application/library/usecases/unmark_as_favorite.dart';
import 'package:quizzy/domain/library/entities/library_item.dart';

part 'library_state.dart';

class LibraryCubit extends Cubit<LibraryState> {
  LibraryCubit({
    required this.getMyCreationsUseCase,
    required this.getFavoritesUseCase,
    required this.getInProgressUseCase,
    required this.getCompletedUseCase,
    required this.markAsFavoriteUseCase,
    required this.unmarkAsFavoriteUseCase,
  }) : super(const LibraryState());

  final GetMyCreationsUseCase getMyCreationsUseCase;
  final GetFavoritesUseCase getFavoritesUseCase;
  final GetInProgressUseCase getInProgressUseCase;
  final GetCompletedUseCase getCompletedUseCase;
  final MarkAsFavoriteUseCase markAsFavoriteUseCase;
  final UnmarkAsFavoriteUseCase unmarkAsFavoriteUseCase;

  Future<void> loadMyCreations({int page = 1}) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final response = await getMyCreationsUseCase(
        LibraryQueryParams(page: page, orderBy: 'createdAt', order: 'desc'),
      );
      emit(state.copyWith(
        isLoading: false,
        creations: response.data,
        
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadFavorites({int page = 1}) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final response = await getFavoritesUseCase(
        LibraryQueryParams(page: page),
      );
      emit(state.copyWith(
        isLoading: false,
        favorites: response.data,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadInProgress({int page = 1}) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final response = await getInProgressUseCase(
        LibraryQueryParams(page: page),
      );
      emit(state.copyWith(
        isLoading: false,
        inProgress: response.data,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadCompleted({int page = 1}) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final response = await getCompletedUseCase(
        LibraryQueryParams(page: page),
      );
      emit(state.copyWith(
        isLoading: false,
        completed: response.data,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> toggleFavorite(String kahootId, bool isAlreadyFavorite) async {
    try {
      if (isAlreadyFavorite) {
        await unmarkAsFavoriteUseCase(kahootId);
      } else {
        await markAsFavoriteUseCase(kahootId);
      }
      // Reload favorites if we are on that tab? 
      // Or just let the UI handle it. 
      // For now, let's reload favorites to be safe if we toggled.
      // But we might be in 'Discovery' or somewhere else. 
      // If we are in the library, we probably want to update the list.
      // Given the complexity of keeping state sync, let's just trigger a reload of favorites
      // if we have them loaded.
      if (state.favorites.isNotEmpty) {
        loadFavorites(); 
      }
    } catch (e) {
      // Handle error (maybe show snackbar via listener)
      print('Error toggling favorite: $e');
    }
  }
}
