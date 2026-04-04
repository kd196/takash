import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image, offer }

/// Mesaj modeli — Firestore messages alt koleksiyonu ile uyumlu
class MessageModel {
  final String id;
  final String senderId;
  final String text;
  final String? imageUrl;
  final MessageType type;
  final DateTime createdAt;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    this.imageUrl,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json, String id) {
    return MessageModel(
      id: id,
      senderId: json['senderId'] ?? '',
      text: json['text'] ?? '',
      imageUrl: json['imageUrl'],
      type: MessageType.values.firstWhere(
        (e) => e.name == (json['type'] ?? 'text'),
        orElse: () => MessageType.text,
      ),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'text': text,
      'imageUrl': imageUrl,
      'type': type.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
    };
  }
}
