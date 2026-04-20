enum ListingCategory {
  electronics,
  clothing,
  books,
  furniture,
  sports,
  toys,
  home,
  automotive,
  other,
}

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
      case ListingCategory.home:
        return 'Ev';
      case ListingCategory.automotive:
        return 'Otomotiv';
      case ListingCategory.other:
        return 'Diğer';
    }
  }

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
      case ListingCategory.home:
        return '🏠';
      case ListingCategory.automotive:
        return '🚗';
      case ListingCategory.other:
        return '📦';
    }
  }
}

enum ListingStatus {
  active,
  traded,
  cancelled,
}

extension ListingStatusExtension on ListingStatus {
  String get label {
    switch (this) {
      case ListingStatus.active:
        return 'Aktif';
      case ListingStatus.traded:
        return 'Takaslandı';
      case ListingStatus.cancelled:
        return 'İptal';
    }
  }

  String get icon {
    switch (this) {
      case ListingStatus.active:
        return '✅';
      case ListingStatus.traded:
        return '🔄';
      case ListingStatus.cancelled:
        return '❌';
    }
  }
}
