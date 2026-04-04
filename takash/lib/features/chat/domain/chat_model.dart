import 'package:cloud_firestore/cloud_firestore.dart';

/// Sohbet odası modeli — Firestore chats koleksiyonu ile uyumlu
class ChatModel {
  final String id;
  final List<String> participants;
  final Map<String, dynamic> participantDetails;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int imageCount;
  final String? listingId;
  final String? listingTitle;
  final Map<String, int> unreadCounts;

  ChatModel({
    required this.id,
    required this.participants,
    required this.participantDetails,
    required this.lastMessage,
    required this.lastMessageAt,
    this.imageCount = 0,
    this.listingId,
    this.listingTitle,
    this.unreadCounts = const {},
  });

  factory ChatModel.fromJson(Map<String, dynamic> json, String id) {
    return ChatModel(
      id: id,
      participants: List<String>.from(json['participants'] ?? []),
      participantDetails: Map<String, dynamic>.from(json['participantDetails'] ?? {}),
      lastMessage: json['lastMessage'] ?? '',
      lastMessageAt: (json['lastMessageAt'] as Timestamp).toDate(),
      imageCount: json['imageCount'] ?? 0,
      listingId: json['listingId'],
      listingTitle: json['listingTitle'],
      unreadCounts: json['unreadCounts'] != null
          ? Map<String, int>.from(json['unreadCounts'])
          : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'participants': participants,
      'participantDetails': participantDetails,
      'lastMessage': lastMessage,
      'lastMessageAt': Timestamp.fromDate(lastMessageAt),
      'imageCount': imageCount,
      'listingId': listingId,
      'listingTitle': listingTitle,
      'unreadCounts': unreadCounts,
    };
  }

  ChatModel copyWith({
    String? lastMessage,
    DateTime? lastMessageAt,
    int? imageCount,
    String? listingId,
    String? listingTitle,
    Map<String, int>? unreadCounts,
  }) {
    return ChatModel(
      id: id,
      participants: participants,
      participantDetails: participantDetails,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      imageCount: imageCount ?? this.imageCount,
      listingId: listingId ?? this.listingId,
      listingTitle: listingTitle ?? this.listingTitle,
      unreadCounts: unreadCounts ?? this.unreadCounts,
    );
  }
}
