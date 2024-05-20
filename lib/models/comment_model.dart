class CommentModel {
  final String id;
  final String text;
  final String image;
  final DateTime createdAt;
  final String postId;
  final String userId;
  final bool isDeleted;

  CommentModel(
      {required this.id,
      required this.text,
      required this.image,
      required this.createdAt,
      required this.postId,
      required this.userId,
      required this.isDeleted});

  CommentModel copyWith({
    String? id,
    String? text,
    String? image,
    DateTime? createdAt,
    String? postId,
    String? userId,
    bool? isDeleted,
  }) {
    return CommentModel(
      id: id ?? this.id,
      text: text ?? this.text,
      image: image ?? this.image,
      createdAt: createdAt ?? this.createdAt,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'image': image,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'postId': postId,
      'userId': userId,
      'isDeleted': isDeleted,
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      image: map['image'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      postId: map['postId'] ?? '',
      userId: map['userId'] ?? '',
      isDeleted: map['isDeleted'] ?? false,
    );
  }
}
