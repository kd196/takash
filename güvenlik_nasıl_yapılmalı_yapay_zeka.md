# Güvenlik Nasıl Uygulanmalı - Yapay Zeka Talimatları - Takaş Projesi

## Giriş

Bu belge, Takaş konum tabanlı takas platformu için güvenlik uygulamaları hakkında yapay zekaya rehberlik etmek amacıyla hazırlanmıştır. Güvenlik uygulamaları, kullanıcı verilerinin korunması, uygulama bütünlüğü ve mahremiyet açısından kritik öneme sahiptir.

## Güvenlik Katmanları ve Uygulama Yönergeleri

### 1. Kimlik Doğrulama (Authentication) Katmanı

Kodlama sırasında şu yönergeleri izle:
- Firebase Auth servisini kullanarak kullanıcı kimlik doğrulama mekanizmasını kur
- Email/şifre, telefon numarası ve Google ile oturum açma yöntemlerini sağla
- Şifre doğrulama kuralları için minimum 6 karakter, büyük/küçük harf ve sayı içermelidir
- Kullanıcı girişi yapıldığında oturum süresini sınırla (örneğin 1 saat)
- Yanlış giriş denemeleri için rate limiting uygula

### 2. Yetkilendirme (Authorization) Katmanı

Kodlama sırasında şu yönergeleri izle:
- Kullanıcılar sadece kendi verilerine erişebilsin
- Firestore'da kullanıcı verileri kullanıcı ID'sine göre filtrelenmeli
- Anonim kullanıcılar için sadece sınırlı erişim verilmeli
- Admin rolleri için ayrı koleksiyon ve kurallar tanımla

### 3. Firestore Güvenlik Kuralları

Kurallar şu şekilde uygulanmalı:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Kullanıcı koleksiyonu - kullanıcı sadece kendi verisini görebilir
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // İlan koleksiyonu - sadece ilan sahibi değiştirebilir
    match /listings/{listingId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && 
        request.auth.uid == request.resource.data.userId;
      allow update: if request.auth != null && 
        request.auth.uid == resource.data.userId;
      allow delete: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
    
    // Sohbet koleksiyonu - sadece sohbete katılan kullanıcılar erişebilir
    match /chats/{chatId} {
      allow read, write: if request.auth != null &&
        (request.auth.uid == resource.data.participant1 || 
         request.auth.uid == resource.data.participant2);
    }
    
    // Yorum koleksiyonu - sadece ilgili kullanıcı ve ilan sahibi erişebilir
    match /listings/{listingId}/comments/{commentId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
  }
}
```

### 4. Firebase Storage Güvenliği

Kodlama sırasında şu yönergeleri izle:
- Kullanıcıların sadece kendi dosyalarına erişmesini sağla
- Genel erişim gerektiren dosyalar için salt okunur erişim tanımla
- Upload işlemlerinde dosya tipi kontrolü yap

#### Örnek Storage Kuralları
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Profil fotoğrafları - herkes görebilir ama sadece kullanıcı kendi yükleyebilir
    match /profiles/{userId}/{imageFile} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // İlan görselleri - sadece giriş yapmış kullanıcılar görebilir, sadece ilan sahibi değiştirebilir
    match /listings/{userId}/{listingId}/{imageFile} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Sohbet medya dosyaları - sadece sohbetteki kullanıcılar erişebilir
    match /chat_media/{chatId}/{userId}/{mediaFile} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 5. API Anahtarları ve Gizli Bilgiler

Kodlama sırasında şu yönergeleri izle:
- API anahtarlarını asla kodun içine sabit olarak yazma
- .env dosyası kullanarak gizli bilgileri sakla
- .gitignore dosyasına .env ve benzeri gizli dosyaları ekle
- Firebase yapılandırma verilerini .env dosyasında tut

### 6. Konum Verileri Güvenliği

Kodlama sırasında şu yönergeleri izle:
- Kullanıcı konum verilerini hassas bilgi olarak değerlendir
- Konum verilerini genelleştirerek depola (örneğin sadece mahalle veya ilçe seviyesinde)
- Konum verilerini şifreleyerek sakla
- Harita üzerinde gösterimde konumun yaklaşık koordinatlarını göster

### 7. Mesajlaşma Güvenliği

Kodlama sırasında şu yönergeleri izle:
- Sohbet mesajlarını Firestore'da sadece ilgili kullanıcılar erişebilecek şekilde yapılandır
- Medya içeriklerini Firebase Storage'da kullanıcı bazlı erişim izinleriyle sakla
- Mesaj geçmişini güvenli şekilde temizleme fonksiyonları sağla

### 8. Günlük Kaydı (Logging) ve İzleme

Kodlama sırasında şu yönergeleri izle:
- Kritik işlemler için Firebase Analytics ile loglama yap
- Hata takibi için Firebase Crashlytics entegrasyonu sağla
- Anormal davranışları tespit edecek algoritmalar geliştir

## Kodlama Örnekleri

### Güvenli Kullanıcı Yetkilendirme Servisi
```dart
class SecureAuthService {
  final FirebaseAuth _auth;
  
  SecureAuthService(this._auth);
  
  // Kullanıcının giriş yapmış olup olmadığını kontrol et
  bool isAuthenticated() {
    return _auth.currentUser != null;
  }
  
  // Kullanıcının kendi verisine erişip erişemeyeceğini kontrol et
  bool canAccessUserData(String userId) {
    final currentUser = _auth.currentUser;
    return currentUser != null && currentUser.uid == userId;
  }
}
```

### Güvenli Firestore Erişimi
```dart
class SecureFirestoreService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  
  SecureFirestoreService(this._firestore, this._auth);
  
  // Kullanıcı kendi ilanlarını alabilsin
  Future<List<DocumentSnapshot>> getUserListings() async {
    final userId = _auth.currentUser!.uid;
    final snapshot = await _firestore
        .collection('listings')
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs;
  }
  
  // Genel ilanları al (herkes görebilir)
  Future<List<DocumentSnapshot>> getAllListings() async {
    final snapshot = await _firestore
        .collection('listings')
        .get();
    return snapshot.docs;
  }
}
```

## Test ve Doğrulama Yönergeleri

Kodlama sırasında şu yönergeleri izle:
- Yetkilendirme kontrolleri için unit testleri yaz
- Anonim kullanıcılar için erişim engeli testi yap
- Farklı kullanıcılar için veri izolasyon testi yap
- Storage erişim kontrolleri için integration testleri yaz

## Hata Ayıklama ve Güvenlik Açığı Tespiti

- Firebase Console üzerinden güvenlik kuralları simülasyonları yap
- Hatalı erişim denemelerini logla ve analiz et
- Güvenlik açıklarını tespit etmek için渗透测试 (penetration testing) araçları kullan

## Sonuç

Güvenlik, Takaş uygulamasının temel taşlarından biridir. Kullanıcı güvenini kazanmak ve verileri korumak için yukarıdaki yönergelerin kodlama sürecinin başından sonuna kadar uygulanması kritik öneme sahiptir. Yapay zeka olarak, güvenlik odaklı kodlama yaparken bu yönergeleri dikkate almalısın.