# Güvenlik Nasıl Uygulanmalı - Takaş Projesi

## Giriş

Takaş gibi konum tabanlı bir takas platformu geliştirirken güvenlik en önemli konulardan biridir. Kullanıcı verilerinin korunması, uygulamanın bütünlüğü ve kullanıcıların mahremiyeti açısından güvenlik planlaması çok dikkatli yapılmalıdır.

## Güvenlik Katmanları

### 1. Kimlik Doğrulama (Authentication)

- Firebase Auth kullanarak güçlü kimlik doğrulama mekanizması kurulmalı
- Email/şifre, telefon numarası ve Google ile oturum açma yöntemleri desteklenmeli
- Güçlü şifre politikaları uygulanmalı
- Oturum süreleri sınırlı tutulmalı
- Kötü niyetli oturum açma denemelerine karşı koruma sağlanmalı

### 2. Yetkilendirme (Authorization)

- Kullanıcıların sadece kendilerine ait verileri görmesi sağlanmalı
- Anonim kullanıcıların uygulamaya erişimi sınırlandırılmalı
- Admin yetkileri çok dikkatli tanımlanmalı
- Rollere göre farklı erişim seviyeleri tanımlanmalı

### 3. Firestore Güvenlik Kuralları

#### Temel Kurallar
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Kullanıcı koleksiyonu
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // İlan koleksiyonu
    match /listings/{listingId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && 
        request.auth.uid == resource.data.userId;
      allow update: if request.auth != null && 
        request.auth.uid == resource.data.userId;
      allow delete: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
    
    // Sohbet koleksiyonu
    match /chats/{chatId} {
      allow read, write: if request.auth != null &&
        (request.auth.uid == resource.data.participant1 || 
         request.auth.uid == resource.data.participant2);
    }
  }
}
```

### 4. Firebase Storage Güvenliği

- Kullanıcıların sadece kendi yükledikleri dosyalara erişebilmesi
- Genel erişime açık dosyalar için ayrı kurallar
- Profil fotoğrafları gibi genel erişime açık dosyalar için salt okunur erişim

#### Örnek Storage Kuralları
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Profil fotoğrafları - salt okunur
    match /profiles/{userId}/{imageFile} {
      allow read: if true;  // Herkes görebilir
      allow write: if request.auth != null && request.auth.uid == userId;  // Sadece kullanıcı kendi fotoğrafını yükleyebilir
    }
    
    // İlan görselleri - sadece ilan sahibi değiştirebilir
    match /listings/{userId}/{listingId}/{imageFile} {
      allow read: if request.auth != null;  // Sadece giriş yapmış kullanıcılar görebilir
      allow write: if request.auth != null && request.auth.uid == userId;  // Sadece kullanıcı kendi ilan resimlerini yükleyebilir
    }
  }
}
```

### 5. API Anahtarları ve Gizli Bilgiler

- API anahtarları asla kod içinde sabit yazılmamalı
- .env dosyaları kullanılarak gizli bilgiler korunmalı
- .gitignore dosyasında .env gibi dosyalar mutlaka yer almalı

### 6. Konum Verileri Güvenliği

- Kullanıcı konum verileri hassas bilgidir ve korunmalıdır
- Konum verileri sadece ilgili kullanıcıya özel işlevler için kullanılmalı
- Harita üzerinde gösterimde konumun genellenmiş hali gösterilmeli

### 7. Mesajlaşma Güvenliği

- Sohbet mesajları sadece ilgili kullanıcılar tarafından okunabilmeli
- Mesaj geçmişi güvenli şekilde saklanmalı
- Medya içerikleri de güvenli kanallarla aktarılmalı

### 8. Günlük Kaydı (Logging) ve İzleme

- Hassas işlemler için loglama yapılmalı
- Anormal davranışlar tespit edilmeli
- Crashlytics gibi araçlarla hatalar izlenebilmeli

## Uygulama Zamanlaması

### Geliştirme Aşamasında
- Güvenlik kuralları baştan planlanmalı
- Temel yetkilendirme erken aşamada uygulanmalı
- Test ortamında güvenlik açıkları tespit edilmeli

### Beta Aşamasında
- Gerçek kullanıcı verileriyle test yapılmalı
- Güvenlik açıkları için dış kaynaklı testler yapılmalı
- Açıklar hızlıca kapatılmalı

### Canlı Aşamada
- Sürekli izleme sistemleri etkinleştirilmeli
- Düzenli güvenlik denetimleri yapılmalı
- Güncelleme politikaları hızlıca uygulanmalı

## En İyi Uygulamalar

- Minimum izin ilkesi: Kullanıcıya sadece ihtiyacı olan izinleri ver
- Veri şifreleme: Hassas veriler cihazda ve iletim sırasında şifrelenmiş olmalı
- Düzenli güvenlik denetimleri: Kod ve yapılar düzenli olarak güvenlik açısından incelenmeli
- Eğitim: Geliştirici ekibin güvenlik farkındalığı artırılmalı

## Sonuç

Güvenlik sadece bir kez yapılan bir işlem değil, sürekli olarak takip edilmesi gereken bir süreçtir. Takaş gibi topluluk bazlı bir platformda kullanıcı güveni uygulama başarısını doğrudan etkilediği için güvenlik planlaması baştan sona her aşamada göz önünde bulundurulmalıdır.