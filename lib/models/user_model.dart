class UserModel {
  final String name;
  final String nameLowerCase;
  final String email;
  final String description;
  final String profilePic;
  final String banner;
  final String uid;
  final bool isAuthenticated;
  final List<String> friends;
  final List<String> groupId;

  UserModel(
      {required this.name,
      required this.nameLowerCase,
      required this.email,
      required this.description,
      required this.profilePic,
      required this.banner,
      required this.uid,
      required this.isAuthenticated,
      required this.friends,
      required this.groupId});

  UserModel copyWith({
    String? name,
    String? nameLowerCase,
    String? email,
    String? description,
    String? profilePic,
    String? banner,
    String? uid,
    bool? isAuthenticated,
    List<String>? friends,
    List<String>? groupId,
  }) {
    return UserModel(
      name: name ?? this.name,
      nameLowerCase: nameLowerCase ?? this.nameLowerCase,
      email: email ?? this.email,
      description: description ?? this.description,
      profilePic: profilePic ?? this.profilePic,
      banner: banner ?? this.banner,
      uid: uid ?? this.uid,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      friends: friends ?? this.friends,
      groupId: groupId ?? this.groupId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'nameLowerCase': nameLowerCase,
      'email': email,
      'description': description,
      'profilePic': profilePic,
      'banner': banner,
      'uid': uid,
      'isAuthenticated': isAuthenticated,
      'friends': friends,
      'groupId': groupId,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      nameLowerCase: map['nameLowerCase'] ?? '',
      email: map['email'] ?? '',
      description: map['description'] ?? '',
      profilePic: map['profilePic'] ?? '',
      banner: map['banner'] ?? '',
      uid: map['uid'] ?? '',
      isAuthenticated: map['isAuthenticated'] ?? false,
      friends: List<String>.from(map['friends']),
      groupId: List<String>.from(map['groupId']),
    );
  }
}
