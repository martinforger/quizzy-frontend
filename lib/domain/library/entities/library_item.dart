enum LibraryItemType {
  creation,
  favorite,
  inProgress,
  completed,
}

class LibraryAuthor {
  final String id;
  final String name;

  LibraryAuthor({required this.id, required this.name});
}

class LibraryItem {
  final String id;
  final String? title;
  final String? description;
  final String? coverImageId;
  final String? visibility; // public | private
  final String? themeId;
  final LibraryAuthor? author;
  final DateTime? createdAt;
  final int? playCount;
  final String? category;
  final String? status; // draft | published
  
  // Specific to In-Progress / Completed
  final String? gameId;
  final String? gameType; // multiplayer | singleplayer

  LibraryItem({
    required this.id,
    this.title,
    this.description,
    this.coverImageId,
    this.visibility,
    this.themeId,
    this.author,
    this.createdAt,
    this.playCount,
    this.category,
    this.status,
    this.gameId,
    this.gameType,
  });
}

class LibraryPagination {
  final int page;
  final int limit;
  final int totalCount;
  final int totalPages;

  LibraryPagination({
    required this.page,
    required this.limit,
    required this.totalCount,
    required this.totalPages,
  });
}

class LibraryResponse {
  final List<LibraryItem> data;
  final LibraryPagination pagination;

  LibraryResponse({required this.data, required this.pagination});
}

class LibraryQueryParams {
  final int page;
  final int limit;
  final String status; // draft | published | all
  final String visibility; // public | private | all
  final String orderBy; // createdAt | title | likesCount
  final String order; // asc | desc
  final List<String> categories;
  final String? q;

  LibraryQueryParams({
    this.page = 1,
    this.limit = 20,
    this.status = 'all',
    this.visibility = 'all',
    this.orderBy = 'createdAt',
    this.order = 'asc',
    this.categories = const [],
    this.q,
  });
}
