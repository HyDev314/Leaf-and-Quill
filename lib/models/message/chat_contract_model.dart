class ChatContractModel {
  final String name;
  final String profilePic;
  final String contactId;
  final DateTime timeSent;
  final String lastMessage;

  ChatContractModel(
      {required this.name,
      required this.profilePic,
      required this.contactId,
      required this.timeSent,
      required this.lastMessage});

  ChatContractModel copyWith({
    String? name,
    String? profilePic,
    String? contactId,
    DateTime? timeSent,
    String? lastMessage,
  }) {
    return ChatContractModel(
      name: name ?? this.name,
      profilePic: profilePic ?? this.profilePic,
      contactId: contactId ?? this.contactId,
      timeSent: timeSent ?? this.timeSent,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'profilePic': profilePic,
      'contactId': contactId,
      'timeSent': timeSent.millisecondsSinceEpoch,
      'lastMessage': lastMessage,
    };
  }

  factory ChatContractModel.fromMap(Map<String, dynamic> map) {
    return ChatContractModel(
      name: map['name'] ?? '',
      profilePic: map['profilePic'] ?? '',
      contactId: map['contactId'] ?? '',
      timeSent: DateTime.fromMillisecondsSinceEpoch(map['timeSent']),
      lastMessage: map['lastMessage'] ?? '',
    );
  }
}
