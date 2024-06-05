class CommunityModel {
  final String id;
  final String name;
  final String nameLowerCase;
  final String banner;
  final String avatar;
  final String description;
  final List<String> members;
  final String admin;
  final List<String> mods;
  final bool isDeleted;

  CommunityModel(
      {required this.id,
      required this.name,
      required this.nameLowerCase,
      required this.banner,
      required this.avatar,
      required this.description,
      required this.members,
      required this.admin,
      required this.mods,
      required this.isDeleted});

  CommunityModel copyWith({
    String? id,
    String? name,
    String? nameLowerCase,
    String? banner,
    String? avatar,
    String? description,
    List<String>? members,
    String? admin,
    List<String>? mods,
    bool? isDeleted,
  }) {
    return CommunityModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameLowerCase: nameLowerCase ?? this.nameLowerCase,
      banner: banner ?? this.banner,
      avatar: avatar ?? this.avatar,
      description: description ?? this.description,
      members: members ?? this.members,
      admin: admin ?? this.admin,
      mods: mods ?? this.mods,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  String toString() {
    return 'CommunityModel(id: $id, name: $name, nameLowerCase: $nameLowerCase, banner: $banner, avatar: $avatar, description: $description, members: $members, admin: $admin, mods: $mods, isDeleted: $isDeleted)';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'nameLowerCase': nameLowerCase,
      'banner': banner,
      'avatar': avatar,
      'description': description,
      'members': members,
      'admin': admin,
      'mods': mods,
      'isDeleted': isDeleted,
    };
  }

  factory CommunityModel.fromMap(Map<String, dynamic> map) {
    return CommunityModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      nameLowerCase: map['nameLowerCase'] ?? '',
      banner: map['banner'] ?? '',
      avatar: map['avatar'] ?? '',
      description: map['description'] ?? '',
      members: List<String>.from(map['members']),
      admin: map['admin'] ?? '',
      mods: List<String>.from(map['mods']),
      isDeleted: map['isDeleted'] ?? false,
    );
  }
}
