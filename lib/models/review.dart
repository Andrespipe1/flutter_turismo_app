class Review {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final int? rating;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    this.rating,
    required this.createdAt,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'],
      postId: map['post_id'],
      userId: map['user_id'],
      content: map['content'],
      rating: map['rating'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
} 