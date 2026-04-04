/// String extension'ları
extension StringExtensions on String {
  // İlk harfi büyük yap
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  // Geçerli e-posta mi?
  bool get isValidEmail {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(this);
  }

  // Boşlukları temizle
  String get trimmed => trim();
}
