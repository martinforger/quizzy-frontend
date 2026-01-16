part of 'library_cubit.dart';

class LibraryState extends Equatable {
  const LibraryState({
    this.creations = const [],
    this.favorites = const [],
    this.inProgress = const [],
    this.completed = const [],
    this.isLoading = false,
    this.error,
  });

  final List<LibraryItem> creations;
  final List<LibraryItem> favorites;
  final List<LibraryItem> inProgress;
  final List<LibraryItem> completed;
  final bool isLoading;
  final String? error;

  LibraryState copyWith({
    List<LibraryItem>? creations,
    List<LibraryItem>? favorites,
    List<LibraryItem>? inProgress,
    List<LibraryItem>? completed,
    bool? isLoading,
    String? error,
  }) {
    return LibraryState(
      creations: creations ?? this.creations,
      favorites: favorites ?? this.favorites,
      inProgress: inProgress ?? this.inProgress,
      completed: completed ?? this.completed,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [creations, favorites, inProgress, completed, isLoading, error];
}
