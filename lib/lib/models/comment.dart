class Comment {
  final int id;
  final int paintingId;
  final String? userId;
  final String userEmail;
  final String text;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.paintingId,
    required this.userId,
    required this.userEmail,
    required this.text,
    required this.createdAt,
  });

  factory Comment.fromMap(Map<String, dynamic> m) => Comment(
        id: m['id'] as int,
        paintingId: m['painting_id'] as int,
        userId: m['user_id'] as String?,
        userEmail: (m['user_email'] as String?) ?? 'Anonymous',
        text: m['text'] as String,
        createdAt: DateTime.parse(m['created_at'] as String),
      );
}
