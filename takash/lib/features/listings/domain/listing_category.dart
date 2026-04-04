/// İlan kategorileri
enum ListingCategory {
  electronics,
  clothing,
  books,
  furniture,
  sports,
  toys,
  other,
}

/// Türkçe label'lar için extension
extension ListingCategoryExtension on ListingCategory {
  String get label {
    switch (this) {
      case ListingCategory.electronics:
        return 'Elektronik';
      case ListingCategory.clothing:
        return 'Giyim';
      case ListingCategory.books:
        return 'Kitap';
      case ListingCategory.furniture:
        return 'Mobilya';
      case ListingCategory.sports:
        return 'Spor';
      case ListingCategory.toys:
        return 'Oyuncak';
      case ListingCategory.other:
        return 'Diğer';
    }
  }

  /// Kategori ikonu
  String get icon {
    switch (this) {
      case ListingCategory.electronics:
        return '📱';
      case ListingCategory.clothing:
        return '👕';
      case ListingCategory.books:
        return '📚';
      case ListingCategory.furniture:
        return '🪑';
      case ListingCategory.sports:
        return '⚽';
      case ListingCategory.toys:
        return '🧸';
      case ListingCategory.other:
        return '📦';
    }
  }
}

/// İlan durumu
enum ListingStatus {
  active,
  reserved,
  completed,
}

/// Türkçe label'lar için extension
extension ListingStatusExtension on ListingStatus {
  String get label {
    switch (this) {
      case ListingStatus.active:
        return 'Aktif';
      case ListingStatus.reserved:
        return 'Rezerve';
      case ListingStatus.completed:
        return 'Tamamlandı';
    }
  }
}
