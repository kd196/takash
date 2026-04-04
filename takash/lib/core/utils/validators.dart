/// Form validasyon fonksiyonları
class Validators {
  // E-posta validasyonu
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-posta adresi gerekli';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Geçerli bir e-posta adresi girin';
    }
    return null;
  }

  // Şifre validasyonu
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre gerekli';
    }
    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalı';
    }
    return null;
  }

  // İsim validasyonu
  static String? displayName(String? value) {
    if (value == null || value.isEmpty) {
      return 'İsim gerekli';
    }
    if (value.length < 2) {
      return 'İsim en az 2 karakter olmalı';
    }
    return null;
  }

  // İlan başlığı
  static String? listingTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Başlık gerekli';
    }
    if (value.length < 3) {
      return 'Başlık en az 3 karakter olmalı';
    }
    if (value.length > 100) {
      return 'Başlık en fazla 100 karakter olabilir';
    }
    return null;
  }

  // İlan açıklaması
  static String? listingDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Açıklama gerekli';
    }
    if (value.length < 10) {
      return 'Açıklama en az 10 karakter olmalı';
    }
    return null;
  }
}
