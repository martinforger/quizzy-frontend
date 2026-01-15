class ReportsPage<T> {
  ReportsPage({
    required this.results,
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
    required this.limit,
  });

  final List<T> results;
  final int totalItems;
  final int currentPage;
  final int totalPages;
  final int limit;
}
