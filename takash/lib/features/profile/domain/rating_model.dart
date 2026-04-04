import 'package:cloud_firestore/cloud_firestore.dart';

class RatingModel {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String listingId;
  final double score;
  final DateTime createdAt;

  RatingModel({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.listingId,
    required this.score,
    required this.createdAt,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json, String id) {
    return RatingModel(
      id: id,
      fromUserId: json['fromUserId'] ?? '',
      toUserId: json['toUserId'] ?? '',
      listingId: json['listingId'] ?? '',
      score: (json['score'] ?? 0.0).toDouble(),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'listingId': listingId,
      'score': score,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
