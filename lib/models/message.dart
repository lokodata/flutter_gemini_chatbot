class Message {
  String messageId;
  String chatId;
  Role role;
  StringBuffer message;
  List<String> imagesURLs;
  DateTime timeSent;

  // constructor
  Message({
    required this.messageId,
    required this.chatId,
    required this.role,
    required this.message,
    required this.imagesURLs,
    required this.timeSent,
  });

  // toMap
  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'chatId': chatId,
      'role': role.index,
      'message': message.toString(),
      'imagesURLs': imagesURLs,
      'timeSent': timeSent.toIso8601String(),
    };
  }

  // from map
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      messageId: map['messageId'],
      chatId: map['chatId'],
      role: Role.values[map['role']],
      message: StringBuffer(map['message']),
      imagesURLs: List<String>.from(map['imagesURLs']),
      timeSent: DateTime.parse(map['timeSent']),
    );
  }

  // copyWith
  Message copyWith({
    String? messageId,
    String? chatId,
    Role? role,
    StringBuffer? message,
    List<String>? imagesURLs,
    DateTime? timeSent,
  }) {
    return Message(
      messageId: messageId ?? this.messageId,
      chatId: chatId ?? this.chatId,
      role: role ?? this.role,
      message: message ?? this.message,
      imagesURLs: imagesURLs ?? this.imagesURLs,
      timeSent: timeSent ?? this.timeSent,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Message && other.messageId == messageId;
  }

  @override
  int get hashCode {
    return messageId.hashCode;
  }
}

enum Role {
  admin,
  user,
  assistant,
}
