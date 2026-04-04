# 🔒 Skill: Güvenlik Kuralları (Firestore & Storage)

> Bu skill dosyasını güvenlik kuralları ile ilgili her sohbetin başına PROJECT_CONTEXT.md ile birlikte yapıştır.

---

## Bu Skill Ne İçin?

Firebase Firestore ve Cloud Storage güvenlik kurallarını tanımlamak, kullanıcı yetkilendirmesini ayarlamak ve veri erişim kontrollerini sağlamak için.

---

## 🚨 Temel İlkeler

- Herkes okuyabilir → Herkes kendi verisini yazabilir
- Hassas veriler korunmalı
- Dosya boyutu ve türü sınırlandırılmalı
- Ratings değiştirilemez olmalı

---

## 📋 Firestore Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // === USERS ===
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }

    // === LISTINGS ===
    match /listings/{listingId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null &&
        request.resource.data.ownerId == request.auth.uid;
      allow update, delete: if request.auth != null &&
        resource.data.ownerId == request.auth.uid;
    }

    // === CHATS ===
    match /chats/{chatId} {
      allow read, write: if request.auth != null &&
        request.auth.uid in resource.data.participants;
      allow create: if request.auth != null &&
        request.auth.uid in request.resource.data.participants;
    }

    // === MESSAGES (subcollection) ===
    match /chats/{chatId}/messages/{messageId} {
      allow read: if request.auth != null &&
        request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participants;
      allow create: if request.auth != null &&
        request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participants &&
        request.resource.data.senderId == request.auth.uid;
      allow update, delete: if request.auth != null &&
        request.auth.uid == resource.data.senderId;
    }

    // === RATINGS ===
    match /ratings/{ratingId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null &&
        request.resource.data.fromUserId == request.auth.uid;
      allow update, delete: if false;  // Değiştirilemez!
    }

    // === NOTIFICATIONS ===
    match /notifications/{notificationId} {
      allow read: if request.auth != null &&
        resource.data.userId == request.auth.uid;
      allow write: if request.auth != null &&
        resource.data.userId == request.auth.uid;
    }

    // === FAVORITES (subcollection) ===
    match /users/{userId}/favorites/{listingId} {
      allow read, write: if request.auth != null &&
        request.auth.uid == userId;
    }
  }
}
```

---

## 📦 Storage Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {

    function isValidImage() {
      return request.resource.contentType.matches('image/.*');
    }

    function isValidSize() {
      return request.resource.size < 5 * 1024 * 1024;  // 5MB
    }

    // Profil fotoğrafları
    match /profile_photos/{userId}/{fileName} {
      allow read: if true;
      allow write: if request.auth.uid == userId &&
        isValidImage() && isValidSize();
    }

    // İlan fotoğrafları
    match /listings/{listingId}/{fileName} {
      allow read: if true;
      allow write: if request.auth != null &&
        isValidImage() && isValidSize() &&
        firestore.get(/databases/(default)/documents/listings/$(listingId))
          .data.ownerId == request.auth.uid;
    }

    // Chat medya
    match /chat_media/{chatId}/{fileName} {
      allow read, write: if request.auth != null &&
        isValidImage() && isValidSize() &&
        request.auth.uid in firestore.get(/databases/(default)/documents/chats/$(chatId)).data.participants;
    }
  }
}
```

---

## 🧪 Test Etme

```bash
# Emulator başlat
firebase emulators:start --only firestore

# Test çalıştır
firebase emulators:exec --only firestore "flutter test"
```

---

## 🚀 Deploy

```bash
firebase deploy --only firestore:rules,storage
```

---

## ✅ Güvenlik Kontrol Listesi

- [ ] Tüm koleksiyonlarda kurallar tanımlandı
- [ ] Kullanıcı sadece kendi verisini yazabilir
- [ ] Chat'e sadece katılımcılar erişebilir
- [ ] Ratings değiştirilemez (allow update, delete: if false)
- [ ] Dosya boyutu sınırlandırıldı (5MB)
- [ ] Sadece image/* türlerine izin verildi
- [ ] Emulator ile test edildi
- [ ] Production'a deploy edildi

---

## 🤖 Yapay Zekadan İstek Örnekleri

```
"PROJECT_CONTEXT.md ve skill_security_rules.md'ye göre,
offers koleksiyonu için güvenlik kuralları ekle.
Teklifi sadece teklifi veren ve ilan sahibi okuyabilmeli."
```

```
"PROJECT_CONTEXT.md ve skill_security_rules.md'ye göre,
storage rules'da chat_media için dosya boyutunu 3MB'a düşür
ve sadece jpeg/png/webp formatlarına izin ver."
```
