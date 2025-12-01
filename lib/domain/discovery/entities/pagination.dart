class Pagination {
  const Pagination({
    required this.page,
    required this.limit,
    required this.totalCount,
    required this.totalPages,
  });

  final int page;
  final int limit;
  final int totalCount;
  final int totalPages;
}
