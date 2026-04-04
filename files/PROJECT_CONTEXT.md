# 🔁 Takaş — Proje Bağlam Dosyası
> Bu dosyayı her yeni yapay zeka sohbetinin BAŞINA yapıştır.

---

## 📌 Proje Özeti
**Takaş**, konum tabanlı bir mobil takas platformudur. Kullanıcılar mahallelerindeki insanlarla para kullanmadan eşya ve yetenek takası yaparlar.

- **Hedef Kitle:** 18–40 yaş arası, sürdürülebilirliğe duyarlı şehirli kullanıcılar
- **Platform:** Android (fiziksel cihaz ile test)
- **Geliştirici Seviyesi:** Başlangıç — yapay zeka yardımıyla geliştiriliyor

---

## ⚙️ Teknoloji Yığını

| Katman | Teknoloji | Versiyon |
|--------|-----------|----------|
| Framework | Flutter | 3.x (SDK >=3.4.0) |
| State Mgmt | Riverpod + riverpod_generator | 2.6.1 |
| Navigation | GoRouter | 14.6.1 |
| Auth | Firebase Auth + Google Sign-In | 5.3.1 |
| Database | Cloud Firestore | 5.4.4 |
| Storage | Firebase Storage | 12.3.4 |
| Messaging | Firebase Cloud Messaging | 15.1.3 |
| Crash | Firebase Crashlytics | 4.1.3 |
| Analytics | Firebase Analytics | 11.3.3 |
| Maps | Mapbox Maps SDK | 2.4.0 |
| Location | Geolocator + geoflutterfire_plus | 13.0.2 + 0.0.17 |
| Chat | **Firestore (Stream Chat KULLANILMIYOR)** | — |
| UI | Material 3 + Google Fonts (Plus Jakarta Sans) | — |
| Utils | image_picker, cached_network_image, intl, uuid, shared_preferences, flutter_dotenv, flutter_local_notifications, google_fonts, share_plus, url_launcher, package_info_plus | — |

---

## 📁 Dosya Yapısı (56 dosya)

```
lib/
├── main.dart
├── firebase_options.dart
├── app/
│   ├── router.dart (236 satır)
│   └── theme.dart (138 satır)
├── core/
│   ├── providers.dart (29 satır)
│   ├── constants/app_constants.dart, api_keys.dart
│   ├── utils/helpers.dart, validators.dart
│   ├── extensions/string_extensions.dart
│   ├── services/settings_service.dart
│   └── providers/theme_provider.dart
├── features/
│   ├── auth/ (6 dosya + 1 generated)
│   ├── listings/ (10 dosya)
│   ├── chat/ (5 dosya)
│   ├── map/ (4 dosya, 2 STUB)
│   ├── profile/ (7 dosya + 1 generated, 1 STUB)
│   ├── notifications/ (4 dosya)
│   └── onboarding/ (1 dosya)
└── shared/
    ├── widgets/ (5 shared widget)
    ├── services/ (2 servis)
    └── models/base_model.dart (STUB)
```

---

## 🗄️ Firestore Koleksiyon Yapısı

```
users/{userId}
  - uid, displayName, email, photoUrl, bio
  - rating (0-5), ratingCount
  - totalImageCount (chat resim limiti: 3)
  - fcmTokens: string[]
  - createdAt

listings/{listingId}
  - id, ownerId, title, description, category
  - imageUrls: string[]
  - wantedItem
  - location: GeoPoint, geohash: string
  - status: active/reserved/completed
  - createdAt

chats/{chatId}
  - id (uid1_uid2), participants, participantDetails
  - lastMessage, lastMessageAt, unreadCounts: map
  - imageCount, listingId, listingTitle

chats/{chatId}/messages/{messageId}
  - senderId, text, imageUrl, type, isRead, createdAt

ratings/{ratingId}
  - fromUserId, toUserId, listingId, score, createdAt

notifications/{notificationId}
  - userId, type, title, body, relatedId, isRead, createdAt

users/{userId}/favorites/{listingId}
  - (ListingModel kopyası)
```

---

## 📱 Ekranlar & Navigasyon

```
Onboarding → Login/Register → Ana Sayfa (5 Tab)
  ├── 🏠 Keşfet     → HomeScreen → ListingDetailScreen
  ├── 🗺️ Harita     → MapScreen
  ├── ➕ İlan Ver   → CreateListingScreen
  ├── 💬 Sohbetler  → ChatListScreen → ChatDetailScreen
  └── 👤 Profil     → ProfileScreen → EditProfile / MyListings / Favorites

Ek Route'lar: /user/:id, /edit-profile, /notifications, /settings, /edit-listing/:id
```

---

## 🚦 Geliştirme Aşamaları

| Faz | Ad | Durum |
|-----|-----|-------|
| Faz 1 | Temel Altyapı & Auth | ✅ Tamamlandı |
| Faz 2 | İlan Yönetimi | ✅ Tamamlandı (planın ötesinde) |
| Faz 3 | Konum & Harita | ⚠️ Kısmen (MapScreen çalışıyor, controller STUB) |
| Faz 4 | Chat Sistemi | ✅ Tamamlandı (Firestore-based) |
| Faz 5 | Puanlama & Güven | ✅ Tamamlandı (inline puanlama) |
| Faz 6 | Bildirimler & Polish | ✅ Tamamlandı |
| Faz 7 | Test & Beta | ❌ Başlanmadı |

---

## ☁️ Cloud Functions (5 fonksiyon)

1. **onNewMessage** — Mesaj bildirimi
2. **onNewOffer** — Teklif bildirimi
3. **onTradeCompleted** — Takas tamamlandı bildirimi
4. **onNewRating** — Puanlama bildirimi
5. **cleanupOldNotifications** — 30 günden eski okunmuş bildirimleri sil

---

## ⚠️ Önemli Kurallar

1. State yönetimi için **sadece Riverpod** kullanılacak
2. Geofencing için **geoflutterfire_plus** kullanılıyor
3. Her özellik `features/` altında kendi klasöründe (clean architecture)
4. Türkçe yorum satırları, değişken isimleri İngilizce
5. **Stream Chat kullanılmıyor** — Chat saf Firestore ile çalışıyor
6. Sadece **Android** platformu aktif
7. Riverpod generator kullanılıyor — `dart run build_runner watch`
