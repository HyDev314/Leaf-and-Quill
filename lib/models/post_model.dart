class PostModel {
  final String id;
  final String title;
  final String link;
  final String image;
  final String description;
  final String communityId;
  final List<String> upvotes;
  final List<String> downvotes;
  final int commentCount;
  final String uid;
  final String type;
  final DateTime createdAt;
  final bool isDeleted;

  PostModel(
      {required this.id,
      required this.title,
      required this.link,
      required this.image,
      required this.description,
      required this.communityId,
      required this.upvotes,
      required this.downvotes,
      required this.commentCount,
      required this.uid,
      required this.type,
      required this.createdAt,
      required this.isDeleted});

  PostModel copyWith({
    String? id,
    String? title,
    String? link,
    String? image,
    String? description,
    String? communityId,
    List<String>? upvotes,
    List<String>? downvotes,
    int? commentCount,
    String? uid,
    String? type,
    DateTime? createdAt,
    bool? isDeleted,
  }) {
    return PostModel(
      id: id ?? this.id,
      title: title ?? this.title,
      link: link ?? this.link,
      image: image ?? this.image,
      description: description ?? this.description,
      communityId: communityId ?? this.communityId,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      commentCount: commentCount ?? this.commentCount,
      uid: uid ?? this.uid,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'link': link,
      'image': image,
      'description': description,
      'communityId': communityId,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'commentCount': commentCount,
      'uid': uid,
      'type': type,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'isDeleted': isDeleted,
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      link: map['link'] ?? '',
      image: map['image'] ?? '',
      description: map['description'] ?? '',
      communityId: map['communityId'] ?? '',
      upvotes: List<String>.from(map['upvotes']),
      downvotes: List<String>.from(map['downvotes']),
      commentCount: map['commentCount']?.toInt() ?? 0,
      uid: map['uid'] ?? '',
      type: map['type'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      isDeleted: map['isDeleted'] ?? false,
    );
  }
}
