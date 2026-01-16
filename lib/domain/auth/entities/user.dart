class User {
  final String id;
  final String name;
  final String username;
  final String email;
  final String userType;
  final String state;
  final bool isPremium;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.userType,
    required this.state,
    required this.isPremium,
    required this.createdAt,
  });
}
