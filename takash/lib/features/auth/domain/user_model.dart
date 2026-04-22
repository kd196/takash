import 'package:cloud_firestore/cloud_firestore.dart';

/// Kullanıcı veri modeli
class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final String? bannerUrl;
  final String? bio;
  final double rating;
  final int ratingCount;
  final int completedTradesCount;
  final DateTime createdAt;
  final int totalImageCount;
  final bool isLocationShared;
  final String profileVisibility;

  UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.bannerUrl,
    this.bio,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.completedTradesCount = 0,
    required this.createdAt,
    this.totalImageCount = 0,
    this.isLocationShared = true,
    this.profileVisibility = 'public',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      displayName: json['displayName'] ?? '',
      email: json['email'] ?? '',
      photoUrl: json['photoUrl'],
      bannerUrl: json['bannerUrl'],
      bio: json['bio'],
      rating: (json['rating'] ?? 0.0).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
      completedTradesCount: json['completedTradesCount'] ?? 0,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      totalImageCount: json['totalImageCount'] ?? 0,
      isLocationShared: json['isLocationShared'] ?? true,
      profileVisibility: json['profileVisibility'] ?? 'public',
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
      'bannerUrl': bannerUrl,
      'bio': bio,
      'rating': rating,
      'ratingCount': ratingCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? displayName,
    String? photoUrl,
    String? bannerUrl,
    String? bio,
    double? rating,
    int? ratingCount,
    int? completedTradesCount,
    int? totalImageCount,
    bool? isLocationShared,
    String? profileVisibility,
  }) {
    return UserModel(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      bio: bio ?? this.bio,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      completedTradesCount: completedTradesCount ?? this.completedTradesCount,
      createdAt: createdAt,
      totalImageCount: totalImageCount ?? this.totalImageCount,
      isLocationShared: isLocationShared ?? this.isLocationShared,
      profileVisibility: profileVisibility ?? this.profileVisibility,
    );
  }
}
