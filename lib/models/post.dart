class Post {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String? location;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.location,
    required this.createdAt,
  });

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      description: map['description'],
      location: map['location'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
} 