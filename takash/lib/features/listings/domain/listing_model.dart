import 'package:cloud_firestore/cloud_firestore.dart';
import 'listing_category.dart';

class ListingModel {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final ListingCategory category;
  final List<String> imageUrls;
  final String wantedItem;
  final GeoPoint? location;
  final String? geohash;
  final ListingStatus status;
  final ListingCondition condition;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ListingModel({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrls,
    required this.wantedItem,
    this.location,
    this.geohash,
    this.status = ListingStatus.active,
    this.condition = ListingCondition.good,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'category': category.name,
      'imageUrls': imageUrls,
      'wantedItem': wantedItem,
      'location': location,
      'geohash': geohash,
      'status': status.name,
      'condition': condition.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    final conditionStr = json['condition'] as String?;
    ListingCondition condition = ListingCondition.good;
    if (conditionStr != null) {
      condition = ListingCondition.values.firstWhere(
        (e) => e.name == conditionStr,
        orElse: () => ListingCondition.good,
      );
    }

    return ListingModel(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: ListingCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ListingCategory.other,
      ),
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      wantedItem: json['wantedItem'] as String? ?? '',
      location: json['location'] as GeoPoint?,
      geohash: json['geohash'] as String?,
      status: ListingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ListingStatus.active,
      ),
      condition: condition,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  ListingModel copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? description,
    ListingCategory? category,
    List<String>? imageUrls,
    String? wantedItem,
    GeoPoint? location,
    String? geohash,
    ListingStatus? status,
    ListingCondition? condition,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ListingModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      imageUrls: imageUrls ?? this.imageUrls,
      wantedItem: wantedItem ?? this.wantedItem,
      location: location ?? this.location,
      geohash: geohash ?? this.geohash,
      status: status ?? this.status,
      condition: condition ?? this.condition,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
