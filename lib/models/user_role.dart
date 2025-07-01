class UserRole {
  final String userId;
  final String role;

  UserRole({required this.userId, required this.role});

  factory UserRole.fromMap(Map<String, dynamic> map) {
    return UserRole(
      userId: map['user_id'],
      role: map['role'],
    );
  }
} 