import 'package:cloud_firestore/cloud_firestore.dart';

enum OfferStatus { pending, accepted, declined, completed }

/// Sohbet odası modeli — Firestore chats koleksiyonu ile uyumlu
class ChatModel {
  final String id;
  final List<String> participants;
  final Map<String, dynamic> participantDetails;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int imageCount;
  final Map<String, int> imageCountPerUser;
  final String? listingId;
  final String? listingTitle;
  final String? listingThumbnailUrl;
  final Map<String, int> unreadCounts;
  final OfferStatus offerStatus;
  final String? offerListingId;
  final String? targetListingId;
  final String? offerSenderId;
  final DateTime? offerUpdatedAt;
  final List<String> hiddenFor;

  ChatModel({
    required this.id,
    required this.participants,
    required this.participantDetails,
    required this.lastMessage,
    required this.lastMessageAt,
    this.imageCount = 0,
    this.imageCountPerUser = const {},
    this.listingId,
    this.listingTitle,
    this.listingThumbnailUrl,
    this.unreadCounts = const {},
    this.offerStatus = OfferStatus.pending,
    this.offerListingId,
    this.targetListingId,
    this.offerSenderId,
    this.offerUpdatedAt,
    this.hiddenFor = const [],
  });

  factory ChatModel.fromJson(Map<String, dynamic> json, String id) {
    final offerStatusStr = json['offerStatus'] as String?;
    OfferStatus offerStatus = OfferStatus.pending;
    if (offerStatusStr != null) {
      offerStatus = OfferStatus.values.firstWhere(
        (e) => e.name == offerStatusStr,
        orElse: () => OfferStatus.pending,
      );
    }

    return ChatModel(
      id: id,
      participants: List<String>.from(json['participants'] ?? []),
      participantDetails:
          Map<String, dynamic>.from(json['participantDetails'] ?? {}),
      lastMessage: json['lastMessage'] ?? '',
      lastMessageAt: (json['lastMessageAt'] as Timestamp).toDate(),
      imageCount: json['imageCount'] ?? 0,
      imageCountPerUser: json['imageCountPerUser'] != null
          ? Map<String, int>.from(json['imageCountPerUser'])
          : {},
      listingId: json['listingId'],
      listingTitle: json['listingTitle'],
      listingThumbnailUrl: json['listingThumbnailUrl'],
      unreadCounts: json['unreadCounts'] != null
          ? Map<String, int>.from(json['unreadCounts'])
          : {},
      offerStatus: offerStatus,
      offerListingId: json['offerListingId'],
      targetListingId: json['targetListingId'],
      offerSenderId: json['offerSenderId'],
      offerUpdatedAt: json['offerUpdatedAt'] != null
          ? (json['offerUpdatedAt'] as Timestamp).toDate()
          : null,
      hiddenFor: List<String>.from(json['hiddenFor'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'participants': participants,
      'participantDetails': participantDetails,
      'lastMessage': lastMessage,
      'lastMessageAt': Timestamp.fromDate(lastMessageAt),
      'imageCount': imageCount,
      'imageCountPerUser': imageCountPerUser,
      'listingId': listingId,
      'listingTitle': listingTitle,
      'listingThumbnailUrl': listingThumbnailUrl,
      'unreadCounts': unreadCounts,
      'offerStatus': offerStatus.name,
      'offerListingId': offerListingId,
      'targetListingId': targetListingId,
      'offerSenderId': offerSenderId,
      'offerUpdatedAt':
          offerUpdatedAt != null ? Timestamp.fromDate(offerUpdatedAt!) : null,
      'hiddenFor': hiddenFor,
    };
  }

  ChatModel copyWith({
    String? lastMessage,
    DateTime? lastMessageAt,
    int? imageCount,
    Map<String, int>? imageCountPerUser,
    String? listingId,
    String? listingTitle,
    String? listingThumbnailUrl,
    Map<String, int>? unreadCounts,
    OfferStatus? offerStatus,
    String? offerListingId,
    String? targetListingId,
    String? offerSenderId,
    DateTime? offerUpdatedAt,
    List<String>? hiddenFor,
  }) {
    return ChatModel(
      id: id,
      participants: participants,
      participantDetails: participantDetails,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      imageCount: imageCount ?? this.imageCount,
      imageCountPerUser: imageCountPerUser ?? this.imageCountPerUser,
      listingId: listingId ?? this.listingId,
      listingTitle: listingTitle ?? this.listingTitle,
      listingThumbnailUrl: listingThumbnailUrl ?? this.listingThumbnailUrl,
      unreadCounts: unreadCounts ?? this.unreadCounts,
      offerStatus: offerStatus ?? this.offerStatus,
      offerListingId: offerListingId ?? this.offerListingId,
      targetListingId: targetListingId ?? this.targetListingId,
      offerSenderId: offerSenderId ?? this.offerSenderId,
      offerUpdatedAt: offerUpdatedAt ?? this.offerUpdatedAt,
      hiddenFor: hiddenFor ?? this.hiddenFor,
    );
  }
}
