import 'package:cloud_firestore/cloud_firestore.dart';

/// Kullanıcı veri modeli
class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final String? bio;
  final double rating;
  final int ratingCount;
  final DateTime createdAt;
  final int totalImageCount;

  UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.bio,
    this.rating = 0.0,
    this.ratingCount = 0,
    required this.createdAt,
    this.totalImageCount = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      displayName: json['displayName'] ?? '',
      email: json['email'] ?? '',
      photoUrl: json['photoUrl'],
      bio: json['bio'],
      rating: (json['rating'] ?? 0.0).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      totalImageCount: json['totalImageCount'] ?? 0,
    );
  }

  /// Profil kaydederken veya güncellerken kullanılan metot
  /// totalImageCount alanını dahil etmiyoruz ki yanlışlıkla 0 yazılmasın
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'bio': bio,
      'rating': rating,
      'ratingCount': ratingCount,
      'createdAt': Timestamp.fromDate(createdAt),
      // totalImageCount buraya eklenmiyor!
    };
  }

  UserModel copyWith({
    String? displayName,
    String? photoUrl,
    String? bio,
    double? rating,
    int? ratingCount,
    int? totalImageCount,
  }) {
    return UserModel(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      createdAt: createdAt,
      totalImageCount: totalImageCount ?? this.totalImageCount,
    );
  }
}
