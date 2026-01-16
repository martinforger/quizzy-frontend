import 'package:quizzy/domain/library/entities/library_item.dart';
import 'package:quizzy/domain/library/repositories/i_library_repository.dart';

class MockLibraryRepository implements ILibraryRepository {
  final List<LibraryItem> _mockItems = [
    LibraryItem(
      id: '1',
      title: 'General Knowledge Quiz',
      description: 'Test your general knowledge with these questions.',
      coverImageId: 'https://images.unsplash.com/photo-1606326608606-aa0b62935f2b?q=80&w=200&auto=format&fit=crop',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      playCount: 150,
      author: LibraryAuthor(id: 'user1', name: 'User 1'),
      status: 'published',
      visibility: 'public',
      themeId: 'standard',
    ),
    LibraryItem(
      id: '2',
      title: 'Mathematics Challenge',
      description: 'A hard quiz for math lovers.',
      coverImageId: 'https://images.unsplash.com/photo-1596495578065-6e0763fa1178?q=80&w=200&auto=format&fit=crop',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      playCount: 32,
      author: LibraryAuthor(id: 'user1', name: 'User 1'),
      status: 'draft',
      visibility: 'private',
      themeId: 'standard',
    ),
    LibraryItem(
      id: '3',
      title: 'Flutter Basics',
      coverImageId: 'https://images.unsplash.com/photo-1617042375876-a13e36732a04?q=80&w=200&auto=format&fit=crop',
      description: 'Learn the basics of the Flutter framework.',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      playCount: 1200,
      author: LibraryAuthor(id: 'user2', name: 'Flutter Dev'),
      status: 'published',
      visibility: 'public',
      themeId: 'standard',
    ),
  ];

  @override
  Future<LibraryResponse> getCompleted(LibraryQueryParams params) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return LibraryResponse(
      data: _mockItems.take(2).toList(),
      pagination: LibraryPagination(
        page: params.page,
        limit: params.limit,
        totalCount: 2,
        totalPages: 1,
      ),
    );
  }

  @override
  Future<LibraryResponse> getFavorites(LibraryQueryParams params) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return LibraryResponse(
      data: [_mockItems[2]],
      pagination: LibraryPagination(
        page: params.page,
        limit: params.limit,
        totalCount: 1,
        totalPages: 1,
      ),
    );
  }

  @override
  Future<LibraryResponse> getInProgress(LibraryQueryParams params) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return LibraryResponse(
      data: [_mockItems[0]],
      pagination: LibraryPagination(
        page: params.page,
        limit: params.limit,
        totalCount: 1,
        totalPages: 1,
      ),
    );
  }

  @override
  Future<LibraryResponse> getMyCreations(LibraryQueryParams params) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return LibraryResponse(
      data: _mockItems
          .where((item) => item.author?.id == 'user1') // Mocking current user items
          .toList(),
      pagination: LibraryPagination(
        page: params.page,
        limit: params.limit,
        totalCount: 2,
        totalPages: 1,
      ),
    );
  }

  @override
  Future<void> markAsFavorite(String kahootId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // In a real mock, you'd update a local list here
  }

  @override
  Future<void> unmarkAsFavorite(String kahootId) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
