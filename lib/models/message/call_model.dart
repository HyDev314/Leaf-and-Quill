class CallModel {
  final String callerId;
  final String callerName;
  final String callerPic;
  final String receiverId;
  final String receiverName;
  final String receiverPic;
  final String callId;
  final bool hasDialled;

  CallModel(
      {required this.callerId,
      required this.callerName,
      required this.callerPic,
      required this.receiverId,
      required this.receiverName,
      required this.receiverPic,
      required this.callId,
      required this.hasDialled});

  CallModel copyWith({
    String? callerId,
    String? callerName,
    String? callerPic,
    String? receiverId,
    String? receiverName,
    String? receiverPic,
    String? callId,
    bool? hasDialled,
  }) {
    return CallModel(
      callerId: callerId ?? this.callerId,
      callerName: callerName ?? this.callerName,
      callerPic: callerPic ?? this.callerPic,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      receiverPic: receiverPic ?? this.receiverPic,
      callId: callId ?? this.callId,
      hasDialled: hasDialled ?? this.hasDialled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'callerId': callerId,
      'callerName': callerName,
      'callerPic': callerPic,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'receiverPic': receiverPic,
      'callId': callId,
      'hasDialled': hasDialled,
    };
  }

  factory CallModel.fromMap(Map<String, dynamic> map) {
    return CallModel(
      callerId: map['callerId'] ?? '',
      callerName: map['callerName'] ?? '',
      callerPic: map['callerPic'] ?? '',
      receiverId: map['receiverId'] ?? '',
      receiverName: map['receiverName'] ?? '',
      receiverPic: map['receiverPic'] ?? '',
      callId: map['callId'] ?? '',
      hasDialled: map['hasDialled'] ?? false,
    );
  }
}
