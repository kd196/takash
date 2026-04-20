---
name: takas-project-context
description: >
  Takaş projesine dair tam bağlam ve mimari bilgisi. Yeni bir AI oturumu
  başlatıldığında, projeyle ilgili herhangi bir görev verilmeden ÖNCE bu
  skill'i oku. Flutter, Firebase, Riverpod, Mapbox ve Stream Chat içeren
  konum tabanlı bir takas uygulamasıdır. Kod yazma, hata ayıklama, yeni
  özellik ekleme, refactoring veya mimari karar verme görevlerinde bu
  skill'i tetikle.
---

# Takaş — Proje Bağlam Skill'i

## Bu Skill'i Nasıl Kullanacaksın

1. Bu dosyayı oku (zaten yapıyorsun ✓)
2. Görevin karmaşıklığına göre referans dosyasını da oku:
   - Hızlı bir kod düzeltmesi → sadece bu dosya yeterli
   - Yeni özellik / mimari karar → `references/full-context.md` dosyasını da oku
3. Kullanıcıdan ek bağlam isteme — önce buradaki bilgiyle devam et

---

## Projeye Genel Bakış

**Takaş**, Türkiye pazarına yönelik, konum tabanlı eşya/beceri takas platformudur.
- **Platform**: Flutter (öncelik: Android — geliştiricinin Mac'i yok)
- **Durum**: 7 geliştirme fazı tamamlandı, Play Store'a gönderim aşamasında
- **Geliştirici**: Tek kişilik ekip (Junior Flutter dev + CEO)
- **Geliştirme ortamı**: Arch Linux

---

## Kritik Kurallar (Bunları Asla İhlal Etme)

| Kural | Açıklama |
|-------|----------|
| ❌ Windows build | Windows build girişimi yapma, öneride bulunma |
| ❌ macOS / iOS build | Mac yok — iOS hedefleme |
| ✅ Android öncelik | Her zaman Android-first düşün |
| ✅ Arch Linux uyumu | Build komutları Arch Linux'a uygun olmalı |
| ✅ Mevcut paketlere bağlı kal | `pubspec.yaml`'daki versiyonları değiştirme |
| ✅ Riverpod pattern | State management'ta her zaman Riverpod kullan |
| ✅ GoRouter | Navigation için her zaman GoRouter kullan |

---

## Tech Stack (Özet)

```
State:       flutter_riverpod ^2.6.1 + riverpod_annotation
Navigation:  go_router ^14.6.1
Backend:     Firebase (Auth, Firestore, Storage, Functions, FCM, Crashlytics, Analytics)
Harita:      mapbox_maps_flutter ^2.4.0 + geolocator + geoflutterfire_plus
Chat:        stream_chat_flutter ^9.2.0
Font:        Google Fonts Inter
```

---

## Mimari Pattern

Proje **feature-first clean architecture** kullanıyor:

```
features/{feature}/
  data/          → Repository (Firebase işlemleri)
  domain/        → Model sınıfları
  presentation/  → Controller (Riverpod) + Screen'ler + Widget'lar
```

**7 Feature**: `auth`, `chat`, `listings`, `map`, `notifications`, `onboarding`, `profile`

**Shared katmanı**: `shared/widgets/`, `shared/models/`, `shared/services/`

---

## Firestore Koleksiyonları

```
users/{userId}          → UserModel
listings/{listingId}    → ListingModel (geohash ile konum indexi)
chats/{chatId}          → ChatModel
messages/{chatId}/{msgId} → MessageModel
ratings/{ratingId}      → RatingModel
```

---

## Router (Rotalar Özeti)

```
/                   → HomeScreen (listings)
/map                → MapScreen
/create-listing     → CreateListingScreen
/chats              → ChatListScreen
/profile            → ProfileScreen
/listing/:id        → ListingDetailScreen
/chat/:id           → ChatDetailScreen
/user/:id           → PublicProfileScreen
/login, /register, /onboarding → Auth flow
```

**Redirect mantığı**: onboarding → login → app (sırasıyla kontrol edilir)

---

## Kritik Provider'lar

```dart
// Core
authStateProvider, userDataProvider(id), routerProvider

// Listings
allListingsProvider, nearbyListingsProvider, filteredListingsProvider
createListingControllerProvider

// Chat
userChatsProvider, chatMessagesProvider(chatId), unreadCountProvider

// Map
userLocationProvider
```

---

## Tema Renkleri

| Token | Light | Dark |
|-------|-------|------|
| primary | #1B8C3A | #4ADE80 |
| accent | #FFB300 | — |
| background | #F8FAF8 | #111827 |
| error | #EF4444 | — |

---

## Daha Fazla Detay İçin

`references/full-context.md` dosyasını oku — tüm model alanları, tüm repository metodları,
tüm provider listesi ve widget katalogu burada.