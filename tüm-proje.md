# Takaş Projesi - Tam Dökümantasyon

## İçindekiler

1. [Proje Hakkında](#1-proje-hakkında)
2. [Mimari Ağaç](#2-mimari-ağaç)
3. [Tech Stack](#3-tech-stack)
4. [Screen'ler ve Özellikler](#4-screenler-ve-özellikler)
5. [Feature'lar ve Fonksiyonlar](#5-featurelar-ve-fonksiyonlar)
6. [Veri Modelleri](#6-veri-modelleri)
7. [Provider'lar](#7-providerlar)

---

## 1. Proje Hakkında

- **Proje Adı**: Takaş
- **Açıklama**: Takaş - Konum tabanlı takas platformu
- **Versiyon**: 1.0.0+1
- **SDK**: >=3.4.0 <4.0.0
- **Platform**: Flutter (iOS, Android, Web, macOS, Linux, Windows)

---

## 2. Mimari Ağaç

```
takash/
├── lib/
│   ├── main.dart                    # Uygulama giriş noktası
│   ├── firebase_options.dart         # Firebase konfigürasyonu
│   │
│   ├── app/
│   │   ├── theme.dart               # Tema yapılandırması (Light/Dark)
│   │   └── router.dart             # Router yapılandırması (go_router)
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── api_keys.dart
│   │   │   └── app_constants.dart
│   │   ├── extensions/
│   │   │   └── string_extensions.dart
│   │   ├── providers/
│   │   │   ├── theme_provider.dart
│   │   │   ├── locale_provider.dart
│   │   │   └── (diğer provider'lar)
│   │   ├── services/
│   │   │   └── settings_service.dart
│   │   └── utils/
│   │       ├── helpers.dart
│   │       └── validators.dart
│   │
│   ├── features/
│   │   ├── auth/                 # Kimlik doğrulama
│   │   │   ├── data/
│   │   │   │   └── auth_repository.dart
│   │   │   ├── domain/
│   │   │   │   └── user_model.dart
│   │   │   └── presentation/
│   │   │       ├── auth_controller.dart
│   │   │       ├── login_screen.dart
│   │   │       └── register_screen.dart
│   │   │
│   │   ├── chat/                  # Sohbet
│   │   │   ├── data/
│   │   │   │   └── chat_repository.dart
│   │   │   ├── domain/
│   │   │   │   ├── chat_model.dart
│   │   │   │   └── message_model.dart
│   │   │   └── presentation/
│   │   │       ├── chat_controller.dart
│   │   │       ├── chat_list_screen.dart
│   │   │       └── chat_detail_screen.dart
│   │   │
│   │   ├── listings/             # İlanlar
│   │   │   ├── data/
│   │   │   │   └── listing_repository.dart
│   │   │   ├── domain/
│   │   │   │   ├── listing_model.dart
│   │   │   │   ├── listing_category.dart
│   │   │   │   └── (diğer modeller)
│   │   │   └── presentation/
│   │   │       ├── listings_controller.dart
│   │   │       ├── home_screen.dart
│   │   │       ├── create_listing_screen.dart
│   │   │       ├── edit_listing_screen.dart
│   │   │       ├── listing_detail_screen.dart
│   │   │       ├── my_listings_screen.dart
│   │   │       ├── favorites_screen.dart
│   │   │       └── widgets/
│   │   │           ├── listing_card.dart
│   │   │           ├── manage_listing_card.dart
│   │   │           └── filter_sheet.dart
│   │   │
│   │   ├── map/                  # Harita
│   │   │   ├��─ data/
│   │   │   │   └── location_service.dart
│   │   │   ├── domain/
│   │   │   │   └── geo_point_model.dart
│   │   │   └── presentation/
│   │   │       ├── map_controller.dart
│   │   │       └── map_screen.dart
│   │   │
│   │   ├── notifications/         # Bildirimler
│   │   │   ├── data/
│   │   │   │   └── notification_service.dart
│   │   │   ├── domain/
│   │   │   │   └── notification_model.dart
│   │   │   └── presentation/
│   │   │       ├── notification_controller.dart
│   │   │       └── notification_screen.dart
│   │   │
│   │   ├── onboarding/            # Uygulama tanıtımı
│   │   │   └── presentation/
│   │   │       └── onboarding_screen.dart
│   │   │
│   │   └── profile/              # Profil
│   │       ├── data/
│   │       │   ├── profile_repository.dart
│   │       │   └── rating_repository.dart
│   │       ├── domain/
│   │       │   └── rating_model.dart
│   │       └── presentation/
│   │           ├── profile_controller.dart
│   │           ├── profile_screen.dart
│   │           ├── edit_profile_screen.dart
│   │           ├── public_profile_screen.dart
│   │           ├── settings_screen.dart
│   │           ├── change_email_screen.dart
│   │           ├── change_password_screen.dart
│   │           └── rating_screen.dart
│   │
│   ├── shared/
│   │   ├── widgets/
│   │   │   ├── custom_button.dart
│   │   │   ├── custom_text_field.dart
│   │   │   ├── empty_state_widget.dart
│   │   │   ├── error_state_widget.dart
│   │   │   └── loading_indicator.dart
│   │   ├── models/
│   │   │   └── base_model.dart
│   │   └── services/
│   │       ├── firebase_service.dart
│   │       └── storage_service.dart
│   │
│   └── l10n/
│       ├── app_localizations.dart
│       ├── app_localizations_tr.dart
│       └── app_localizations_en.dart
│
├── pubspec.yaml                    # Bağımlılıklar
├── firebase.json                # Firebase konfigürasyonu
└── (.env, android/, ios/, vs.)
```

---

## 3. Tech Stack

### 3.1 State Management
| Paket | Versiyon | Kullanım Yeri |
|-------|---------|---------------|
| flutter_riverpod | ^2.6.1 | Global state management |
| riverpod_annotation | ^2.6.1 | Code generation |
| riverpod_generator | ^2.6.2 | Dev dependencies |

### 3.2 Navigation
| Paket | Versiyon | Kullanım Yeri |
|-------|---------|---------------|
| go_router | ^14.6.1 | lib/app/router.dart |

### 3.3 Firebase
| Paket | Versiyon | Kullanım Yeri |
|-------|---------|---------------|
| firebase_core | ^3.6.0 | lib/main.dart |
| firebase_auth | ^5.3.1 | Kimlik doğrulama |
| google_sign_in | ^6.2.1 | Google ile giriş |
| cloud_firestore | ^5.4.4 | Firestore veritabanı |
| firebase_storage | ^12.3.4 | Dosya depolama |
| firebase_messaging | ^15.1.3 | Push bildirimleri |
| cloud_functions | ^5.1.3 | Server-side fonksiyonlar |
| firebase_crashlytics | ^4.1.3 | Hata takibi |
| firebase_analytics | ^11.3.3 | Analitik |

### 3.4 Maps & Location
| Paket | Versiyon | Kullanım Yeri |
|-------|---------|---------------|
| mapbox_maps_flutter | ^2.4.0 | Harita gösterimi |
| geolocator | ^13.0.2 | Konum alma |
| geoflutterfire_plus | ^0.0.17 | Geo-fencing |

### 3.5 Chat
| Paket | Versiyon | Kullanım Yeri |
|-------|---------|---------------|
| stream_chat_flutter | ^9.2.0 | Sohbet sistemi |

### 3.6 Utilities
| Paket | Versiyon | Kullanım Alanı |
|-------|---------|---------------|
| image_picker | ^1.1.2 | Fotoğraf seçimi |
| image_cropper | ^8.0.2 | Fotoğraf kırpma |
| cached_network_image | ^3.4.1 | Resim önbellekleme |
| intl | ^0.19.0 | Lokalizasyon |
| uuid | ^4.5.1 | Benzersiz ID |
| permission_handler | ^11.3.1 | İzin yönetimi |
| flutter_dotenv | ^5.2.1 | .env dosyası |
| shared_preferences | ^2.3.3 | Yerel depolama |
| flutter_native_splash | ^2.4.1 | Splash ekranı |
| flutter_local_notifications | ^17.2.3 | Yerel bildirimler |
| google_fonts | ^6.2.1 | Yazı tipleri |
| share_plus | ^12.0.1 | Paylaşım |
| url_launcher | ^6.3.0 | URL açma |
| package_info_plus | ^9.0.0 | Paket bilgisi |

---

## 4. Screen'ler ve Özellikler

### 4.1 Auth Screen'leri

| Screen | Dosya | Özellikler |
|--------|------|------------|
| **LoginScreen** | `features/auth/presentation/login_screen.dart` | Email/şifre girişi, Google ile giriş, Şifremi unuttum |
| **RegisterScreen** | `features/auth/presentation/register_screen.dart` | Email/kayıt, Display name, Google ile kayıt |
| **OnboardingScreen** | `features/onboarding/presentation/onboarding_screen.dart` | Uygulama tanıtımı, Slider, Başla butonu |

**Kod Bloğu (LoginScreen):**
- `AuthController.signInWithEmail()` - Email ile giriş
- `AuthController.signInWithGoogle()` - Google ile giriş
- `AuthController.signOut()` - Çıkış

### 4.2 Ana Screen'ler (Bottom Navigation)

| Screen | Dosya | Özellikler |
|--------|------|------------|
| **HomeScreen** | `features/listings/presentation/home_screen.dart` | İlan listesi, Arama, Filtreleme, Kategoriler |
| **MapScreen** | `features/map/presentation/map_screen.dart` | Mapbox haritası, Konum bazlı ilanlar |
| **CreateListingScreen** | `features/listings/presentation/create_listing_screen.dart` | Yeni ilan oluşturma, Fotoğraf yükleme |
| **ChatListScreen** | `features/chat/presentation/chat_list_screen.dart` | Sohbet listesi, Okunmamış badge |
| **ProfileScreen** | `features/profile/presentation/profile_screen.dart` | Profil görüntüleme, Düzenleme, Çıkış |

**Kod Bloğu (HomeScreen - ListingsController):**
```dart
// Stream Providers
allListingsProvider         // Tüm aktif ilanlar
nearbyListingsProvider      // Yakındaki ilanlar
userListingsProvider       // Kullanıcının ilanları
filteredListingsProvider   // Filtrelenmiş ilanlar
userFavoritesProvider     // Favori ilanlar

// Controller Fonksiyonları
createListingControllerProvider.createListing()    // İlan oluştur
createListingControllerProvider.updateListing()  // İlan güncelle
createListingControllerProvider.deleteListing() // İlan sil
createListingControllerProvider.toggleFavorite() // Favori ekle/kaldır
```

### 4.3 İlan Screen'leri

| Screen | Dosya | Özellikler |
|--------|------|------------|
| **ListingDetailScreen** | `features/listings/presentation/listing_detail_screen.dart` | İlan detayı, Fotoğraflar, Favori, Sohbet başlat |
| **EditListingScreen** | `features/listings/presentation/edit_listing_screen.dart` | İlan düzenleme |
| **MyListingsScreen** | `features/listings/presentation/my_listings_screen.dart` | Benim ilanlarım |
| **FavoritesScreen** | `features/listings/presentation/favorites_screen.dart` | Favori ilanlar |

**Listing Detail Özellikleri:**
- Image carousel (cached_network_image)
- Kategori gösterimi
- Konum haritası
- Favori butonu
- Paylaş butonu (share_plus)
- İlan sahibi profil linki
- Sohbet başlat butonu

### 4.4 Sohbet Screen'leri

| Screen | Dosya | Özellikler |
|--------|------|------------|
| **ChatListScreen** | `features/chat/presentation/chat_list_screen.dart` | Tüm sohbetler listesi |
| **ChatDetailScreen** | `features/chat/presentation/chat_detail_screen.dart` | Mesajlar, Resim gönderme |

**Kod Bloğu (ChatController):**
```dart
chatControllerProvider.startChat()           // Sohbet başlat
chatControllerProvider.sendTextMessage()   // Metin mesajı
chatControllerProvider.sendImageMessage()   // Resim mesajı
chatControllerProvider.deleteMessage()     // Mesaj sil
chatControllerProvider.markMessagesAsRead() // Okundu işaretle
```

### 4.5 Profil Screen'leri

| Screen | Dosya | Özellikler |
|--------|------|------------|
| **ProfileScreen** | `features/profile/presentation/profile_screen.dart` | Profil ana sayfası |
| **EditProfileScreen** | `features/profile/presentation/edit_profile_screen.dart` | Profil düzenleme |
| **PublicProfileScreen** | `features/profile/presentation/public_profile_screen.dart` | Herkese açık profil |
| **SettingsScreen** | `features/profile/presentation/settings_screen.dart` | Ayarlar |
| **ChangeEmailScreen** | `features/profile/presentation/change_email_screen.dart` | Email değiştir |
| **ChangePasswordScreen** | `features/profile/presentation/change_password_screen.dart` | Şifre değiştir |
| **RatingScreen** | `features/profile/presentation/rating_screen.dart` | Puanlama |

**Profile Özellikleri:**
- Profil fotoğrafı (Firebase Storage)
- Display name, Bio
- Konum bilgisi
- Puan ortalaması
- İlan sayısı
- Değerlendirmeler

### 4.6 Diğer Screen'ler

| Screen | Dosya | Özellikler |
|--------|------|------------|
| **NotificationScreen** | `features/notifications/presentation/notification_screen.dart` | Bildirimler |
| **MainScreen** | `lib/app/router.dart` (satır 171) | Bottom navigation bar |

---

## 5. Feature'lar ve Fonksiyonlar

### 5.1 Auth Feature

**Data Layer - AuthRepository:**
```dart
signInWithEmail(String email, String password)
registerWithEmail({required String email, required String password, required String displayName})
signInWithGoogle()
signOut()
```

**Domain Layer - UserModel:**
```dart
- uid: String
- email: String?
- displayName: String
- photoUrl: String?
- bio: String?
- location: GeoPoint?
- createdAt: DateTime
- ratingAverage: double
- totalRatings: int
```

### 5.2 Listings Feature

**Data Layer - ListingRepository:**
```dart
getAllActiveListings() -> Stream<List<ListingModel>>
getNearbyListings(GeoPoint center, double radiusInKm)
getUserListings(String userId)
getListingById(String listingId)
createListing(...)
updateListing(ListingModel listing)
deleteListing(String listingId)
toggleFavorite(String userId, ListingModel listing)
isFavorite(String userId, String listingId)
getUserFavorites(String userId)
```

**Domain Layer - ListingModel:**
```dart
- id: String
- ownerId: String
- title: String
- description: String
- category: ListingCategory
- wantedItem: String
- imageUrls: List<String>
- location: GeoPoint?
- geohash: String?
- status: ListingStatus (active, traded, cancelled)
- createdAt: DateTime
- updatedAt: DateTime
```

**ListingCategory Enum:**
```dart
electronics      // Elektronik
clothing         // Giyim
books            // Kitaplar
furniture        // Mobilya
sports           // Spor
toys             // Oyuncaklar
home             // Ev
automotive       // Otomotiv
other            // Diğer
```

### 5.3 Chat Feature

**Data Layer - ChatRepository:**
```dart
getUserChats(String userId) -> Stream<List<ChatModel>>
getMessages(String chatId) -> Stream<List<MessageModel>>
createOrGetChat(UserModel currentUser, UserModel otherUser, {String? listingId, String? listingTitle})
sendMessage(String chatId, String text, String userId)
sendImageMessage(String chatId, File imageFile, String userId)
deleteMessage(String chatId, MessageModel message)
markAsRead(String chatId, String userId)
```

**Domain Layer - MessageModel:**
```dart
- id: String
- chatId: String
- senderId: String
- type: MessageType (text, image)
- content: String
- imageUrl: String?
- createdAt: DateTime
- readBy: Map<String, bool>
```

### 5.4 Map Feature

**Data Layer - LocationService:**
```dart
getCurrentLocation() -> Future<GeoPoint>
getLastKnownLocation() -> GeoPoint?
checkPermission() -> LocationPermission
requestPermission() -> Future<LocationPermission>
```

### 5.5 Notifications Feature

**Data Layer - NotificationService:**
```dart
initialize()
onUserChanged(User? user)
requestPermission() -> Future<bool>
getToken() -> String?
```

### 5.6 Profile Feature

**Data Layer - ProfileRepository:**
```dart
getUserProfile(String userId)
updateProfile(UserModel user)
getUserRatings(String userId)
addRating(String userId, RatingModel rating)
```

**Domain Layer - RatingModel:**
```dart
- id: String
- raterId: String
- ratedUserId: String
- rating: int (1-5)
- comment: String?
- createdAt: DateTime
```

---

## 6. Veri Modelleri

### 6.1 Temel Modeller

| Model | Dosya | Alanlar |
|-------|------|--------|
| UserModel | `features/auth/domain/user_model.dart` | uid, email, displayName, photoUrl, bio, location, ratingAverage |
| ListingModel | `features/listings/domain/listing_model.dart` | id, ownerId, title, description, category, wantedItem, imageUrls, location |
| ChatModel | `features/chat/domain/chat_model.dart` | id, participants, lastMessage, unreadCounts, listingId |
| MessageModel | `features/chat/domain/message_model.dart` | id, chatId, senderId, type, content, imageUrl, readBy |
| GeoPointModel | `features/map/domain/geo_point_model.dart` | latitude, longitude |
| NotificationModel | `features/notifications/domain/notification_model.dart` | id, title, body, data, createdAt |
| RatingModel | `features/profile/domain/rating_model.dart` | id, raterId, ratedUserId, rating, comment |
| ListingCategory | `features/listings/domain/listing_category.dart` | Enum (electronics, clothing, books, ...) |
| ListingStatus | `features/listings/domain/listing_model.dart` | Enum (active, traded, cancelled) |

### 6.2 Base Model

```dart
// lib/shared/models/base_model.dart
abstract class BaseModel {
  String get id;
  Map<String, dynamic> toJson();
  static T fromJson<T extends BaseModel>(Map<String, dynamic> json);
}
```

---

## 7. Provider'lar

### 7.1 Core Provider'lar

```dart
// lib/core/providers.dart
authStateProvider           // Firebase auth state
userDataProvider(id)       // Kullanıcı verileri
themeModeProvider          // Tema modu (light/dark)
localeProvider             // Dil ayarı
routerProvider             // GoRouter instance
```

### 7.2 Feature Provider'ları

```dart
// Auth
authRepositoryProvider
authControllerProvider

// Listings
allListingsProvider
nearbyListingsProvider
userListingsProvider(id)
singleListingProvider(id)
isFavoriteProvider(listingId)
userFavoritesProvider
filteredListingsProvider
searchQueryProvider
categoryFilterProvider
createListingControllerProvider

// Chat
chatRepositoryProvider
userChatsProvider
chatMessagesProvider(chatId)
unreadCountProvider
chatControllerProvider

// Map
locationServiceProvider
userLocationProvider

// Notifications
notificationServiceProvider

// Profile
profileRepositoryProvider
ratingRepositoryProvider
```

### 7.3 Repository Provider'ları

```dart
authRepositoryProvider
listingRepositoryProvider
chatRepositoryProvider
profileRepositoryProvider
ratingRepositoryProvider
locationServiceProvider
notificationServiceProvider
storageServiceProvider
```

---

## 8. Tema Yapılandırması

### 8.1 Renkler (Light Theme)

| Renk | Hex | Kullanım |
|-----|-----|----------|
| primary | #1B8C3A | Ana renk |
| primaryDark | #14692D | Koyu ana renk |
| primaryLight | #E8F5E9 | Açık ana renk |
| accent | #FFB300 | Vurgu rengi |
| surfaceLight | #F8FAF8 | Arka plan |
| textPrimary | #1A1A2E | Birincil metin |
| textSecondary | #6B7280 | İkincil metin |
| textTertiary | #9CA3AF | Üçüncül metin |
| error | #EF4444 | Hata |
| success | #22C55E | Başarı |

### 8.2 Dark Theme Renkleri

| Renk | Hex | Kullanım |
|-----|-----|----------|
| primary | #4ADE80 | Ana renk |
| surface | #111827 | Arka plan |
| inverseSurface | #F9FAFB | Ters yüzey |

### 8.3 Typography

- **Font**: Google Fonts Inter
- **Boyutlar**: 28/22/20/18/16/14/12/11
- **Ağırlıklar**: 400/500/600/700/800

---

## 9. Router Yapılandırması

### 9.1 Rotalar

```
/onboarding          -> OnboardingScreen
/login              -> LoginScreen
/register          -> RegisterScreen
/user/:id           -> PublicProfileScreen(userId)
/notifications     -> NotificationScreen
/settings          -> SettingsScreen
/                   -> MainScreen (index 0: HomeScreen)
/map                -> MainScreen (index 1: MapScreen)
/create-listing     -> MainScreen (index 2: CreateListingScreen)
/chats              -> MainScreen (index 3: ChatListScreen)
/profile            -> MainScreen (index 4: ProfileScreen)
/listing/:id        -> ListingDetailScreen
/edit-listing/:id  -> EditListingScreen
/chat/:id           -> ChatDetailScreen
/profile/edit      -> EditProfileScreen
/profile/my-listings -> MyListingsScreen
/profile/favorites -> FavoritesScreen
/change-email      -> ChangeEmailScreen
/change-password  -> ChangePasswordScreen
```

### 9.2 Middleware (Redirect Logic)

```dart
// 1. Onboarding tamamlanmadıysa -> /onboarding
// 2. Onboarding tamam, ama giriş yapılmadıysa -> /login
// 3. Giriş yapılmış, auth route'a gidiliyorsa -> /
// 4. Değilse -> null (izin verilen rotaya git)
```

---

## 10. Firebase Yapılandırması

### 10.1 Collections

```
users/
  {userId}/
    - uid
    - email
    - displayName
    - photoUrl
    - bio
    - location (geo_point)
    - createdAt
    - ratingAverage
    - totalRatings
    - favorites[]

listings/
  {listingId}/
    - id
    - ownerId
    - title
    - description
    - category
    - wantedItem
    - imageUrls[]
    - location (geo_point)
    - geohash
    - status
    - createdAt
    - updatedAt

chats/
  {chatId}/
    - id
    - participants[]
    - lastMessage
    - lastMessageTime
    - unreadCounts{userId: count}
    - listingId
    - listingTitle

messages/
  {chatId}/
    {messageId}/
      - id
      - chatId
      - senderId
      - type
      - content
      - imageUrl
      - createdAt
      - readBy{userId: bool}

ratings/
  {ratingId}/
    - id
    - raterId
    - ratedUserId
    - rating
    - comment
    - createdAt
```

### 10.2 Storage Buckets

```
profile_photos/{userId}/photo.jpg
listing_images/{listingId}/image_{index}.jpg
chat_images/{chatId}/{messageId}.jpg
```

---

## 11. Kullanılan Widget'lar

### 11.1 Custom Widget'lar

| Widget | Dosya | Açıklama |
|--------|------|----------|
| CustomButton | `shared/widgets/custom_button.dart` | Özelleştirilmiş buton |
| CustomTextField | `shared/widgets/custom_text_field.dart` | Özelleştirilmiş text field |
| EmptyStateWidget | `shared/widgets/empty_state_widget.dart` | Boş durum widget'ı |
| ErrorStateWidget | `shared/widgets/error_state_widget.dart` | Hata durum widget'ı |
| LoadingIndicator | `shared/widgets/loading_indicator.dart` | Yükleniyor göstergesi |
| ListingCard | `features/listings/presentation/widgets/listing_card.dart` | İlan kartı |
| ManageListingCard | `features/listings/presentation/widgets/manage_listing_card.dart` | Yönetim ilan kartı |
| FilterSheet | `features/listings/presentation/widgets/filter_sheet.dart` | Filtre sayfası |

### 11.2 Material 3 Widget'ları

- Scaffold
- AppBar
- BottomNavigationBar
- Card
- ElevatedButton
- OutlinedButton
- TextButton
- InputDecoration
- Chip
- BottomSheet
- Dialog
- SnackBar
- FloatingActionButton

---

## 12. Özet İstatistikler

- **Toplam Dart Dosyası**: 70+
- **Feature Sayısı**: 7 (auth, chat, listings, map, notifications, onboarding, profile)
- **Screen Sayısı**: 20+
- **Model Sayısı**: 8+
- **Provider Sayısı**: 25+
- **Repository Sayısı**: 6+

---

## 13. Bağımlılıklar Ağacı

```
takash ( Flutter App )
├── Dependencies (40+ packages)
│   ├── flutter_riverpod (State Management)
│   ├── go_router (Navigation)
│   ├── firebase_* (Firebase Services)
│   ├── mapbox_maps_flutter (Maps)
│   ├── stream_chat_flutter (Chat)
│   └── [Diğer utilities]
│
├── Dev Dependencies
│   ├── flutter_test
│   ├── riverpod_generator
│   ├── build_runner
│   ├── mockito
│   ├── fake_cloud_firestore
│   └── firebase_auth_mocks
│
└── Build Dependencies
    ├── flutter_lint
    └── integration_test
```