// lib/models/chat_message_model.dart

class ChatMessageModel {
  final String messageId;
  final String tripId;
  final String senderId;
  final String senderName;
  final String? senderAvatarUrl;
  final String text;
  final DateTime sentAt;
  final bool isRead;

  const ChatMessageModel({
    required this.messageId,
    required this.tripId,
    required this.senderId,
    required this.senderName,
    this.senderAvatarUrl,
    required this.text,
    required this.sentAt,
    this.isRead = false,
  });

  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      messageId: map['messageId'] as String,
      tripId: map['tripId'] as String,
      senderId: map['senderId'] as String,
      senderName: map['senderName'] as String,
      senderAvatarUrl: map['senderAvatarUrl'] as String?,
      text: map['text'] as String,
      sentAt: DateTime.fromMillisecondsSinceEpoch(map['sentAt'] as int),
      isRead: (map['isRead'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'messageId': messageId,
        'tripId': tripId,
        'senderId': senderId,
        'senderName': senderName,
        'senderAvatarUrl': senderAvatarUrl,
        'text': text,
        'sentAt': sentAt.millisecondsSinceEpoch,
        'isRead': isRead,
      };
}
