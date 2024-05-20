class NotificationModel {
  final String id;
  final String uid;
  final String commentId;
  final DateTime createdAt;
  final bool isRead;
  final bool isDeleted;

  NotificationModel(
      {required this.id,
      required this.uid,
      required this.commentId,
      required this.createdAt,
      required this.isRead,
      required this.isDeleted});

  NotificationModel copyWith({
    String? id,
    String? uid,
    String? commentId,
    DateTime? createdAt,
    bool? isRead,
    bool? isDeleted,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      commentId: commentId ?? this.commentId,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'commentId': commentId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isRead': isRead,
      'isDeleted': isDeleted,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      uid: map['uid'] ?? '',
      commentId: map['commentId'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      isRead: map['isRead'] ?? false,
      isDeleted: map['isDeleted'] ?? false,
    );
  }
}
