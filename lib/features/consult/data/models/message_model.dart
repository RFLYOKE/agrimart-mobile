class MessageModel {
  final String id;
  final String senderId;
  final String content;
  final String type; // text, image, document
  final DateTime sentAt;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.content,
    required this.type,
    required this.sentAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      senderId: json['sender_id'] ?? '',
      content: json['content'] ?? '',
      type: json['type'] ?? 'text',
      sentAt: json['sent_at'] != null 
          ? DateTime.parse(json['sent_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'content': content,
      'type': type,
      'sent_at': sentAt.toIso8601String(),
    };
  }
}
