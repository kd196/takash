# Takaş — Tam Proje Referansı

> Bu dosya `SKILL.md`'nin devamıdır. Yeni özellik geliştirme, mimari karar veya
> model/provider referansı gerektiğinde buraya bak.

---

## Tüm Screen'ler

### Auth
| Screen | Dosya | Ne Yapar |
|--------|-------|----------|
| LoginScreen | `features/auth/presentation/login_screen.dart` | Email/şifre + Google giriş |
| RegisterScreen | `features/auth/presentation/register_screen.dart` | Kayıt ol |
| OnboardingScreen | `features/onboarding/presentation/onboarding_screen.dart` | Uygulama tanıtımı |

### Ana (Bottom Nav)
| Screen | Dosya |
|--------|-------|
| HomeScreen | `features/listings/presentation/home_screen.dart` |
| MapScreen | `features/map/presentation/map_screen.dart` |
| CreateListingScreen | `features/listings/presentation/create_listing_screen.dart` |
| ChatListScreen | `features/chat/presentation/chat_list_screen.dart` |
| ProfileScreen | `features/profile/presentation/profile_screen.dart` |

### İlan
| Screen | Dosya |
|--------|-------|
| ListingDetailScreen | `features/listings/presentation/listing_detail_screen.dart` |
| EditListingScreen | `features/listings/presentation/edit_listing_screen.dart` |
| MyListingsScreen | `features/listings/presentation/my_listings_screen.dart` |
| FavoritesScreen | `features/listings/presentation/favorites_screen.dart` |

### Profil
| Screen | Dosya |
|--------|-------|
| EditProfileScreen | `features/profile/presentation/edit_profile_screen.dart` |
| PublicProfileScreen | `features/profile/presentation/public_profile_screen.dart` |
| SettingsScreen | `features/profile/presentation/settings_screen.dart` |
| ChangeEmailScreen | `features/profile/presentation/change_email_screen.dart` |
| ChangePasswordScreen | `features/profile/presentation/change_password_screen.dart` |
| RatingScreen | `features/profile/presentation/rating_screen.dart` |

### Diğer
| Screen | Dosya |
|--------|-------|
| ChatDetailScreen | `features/chat/presentation/chat_detail_screen.dart` |
| NotificationScreen | `features/notifications/presentation/notification_screen.dart` |

---

## Veri Modelleri (Tüm Alanlar)

### UserModel
```dart
// features/auth/domain/user_model.dart
uid: String
email: String?
displayName: String
photoUrl: String?
bio: String?
location: GeoPoint?
createdAt: DateTime
ratingAverage: double
totalRatings: int
favorites: List<String>  // listing ID'leri
```

### ListingModel
```dart
// features/listings/domain/listing_model.dart
id: String
ownerId: String
title: String
description: String
category: ListingCategory  // enum
wantedItem: String
imageUrls: List<String>
location: GeoPoint?
geohash: String?
status: ListingStatus      // active | traded | cancelled
createdAt: DateTime
updatedAt: DateTime
```

### ChatModel
```dart
// features/chat/domain/chat_model.dart
id: String
participants: List<String>         // userId'ler
lastMessage: String
lastMessageTime: DateTime
unreadCounts: Map<String, int>     // {userId: count}
listingId: String?
listingTitle: String?
```

### MessageModel
```dart
// features/chat/domain/message_model.dart
id: String
chatId: String
senderId: String
type: MessageType  // text | image
content: String
imageUrl: String?
createdAt: DateTime
readBy: Map<String, bool>
```

### RatingModel
```dart
// features/profile/domain/rating_model.dart
id: String
raterId: String
ratedUserId: String
rating: int  // 1-5
comment: String?
createdAt: DateTime
```

### Enum'lar
```dart
ListingCategory: electronics, clothing, books, furniture, sports, toys, home, automotive, other
ListingStatus: active, traded, cancelled
MessageType: text, image
```

---

## Repository Metodları

### AuthRepository
```dart
signInWithEmail(String email, String password)
registerWithEmail({required email, required password, required displayName})
signInWithGoogle()
signOut()
```

### ListingRepository
```dart
getAllActiveListings() → Stream<List<ListingModel>>
getNearbyListings(GeoPoint center, double radiusInKm)
getUserListings(String userId)
getListingById(String listingId)
createListing({title, description, category, wantedItem, imageFiles, location})
updateListing(ListingModel listing)
deleteListing(String listingId)
toggleFavorite(String userId, ListingModel listing)
isFavorite(String userId, String listingId) → bool
getUserFavorites(String userId)
```

### ChatRepository
```dart
getUserChats(String userId) → Stream<List<ChatModel>>
getMessages(String chatId) → Stream<List<MessageModel>>
createOrGetChat(UserModel currentUser, UserModel otherUser, {listingId?, listingTitle?})
sendMessage(String chatId, String text, String userId)
sendImageMessage(String chatId, File imageFile, String userId)
deleteMessage(String chatId, MessageModel message)
markAsRead(String chatId, String userId)
```

### ProfileRepository
```dart
getUserProfile(String userId)
updateProfile(UserModel user)
getUserRatings(String userId)
addRating(String userId, RatingModel rating)
```

### LocationService
```dart
getCurrentLocation() → Future<GeoPoint>
getLastKnownLocation() → GeoPoint?
checkPermission() → LocationPermission
requestPermission() → Future<LocationPermission>
```

---

## Tüm Provider'lar

```dart
// Core
authStateProvider           // Firebase auth stream
userDataProvider(id)        // Firestore user doc
themeModeProvider           // light/dark
localeProvider              // tr/en
routerProvider              // GoRouter instance

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
storageServiceProvider
```

---

## Custom Widget'lar

```
shared/widgets/
  CustomButton          → Özelleştirilmiş buton
  CustomTextField       → Özelleştirilmiş text field
  EmptyStateWidget      → Boş durum
  ErrorStateWidget      → Hata durumu
  LoadingIndicator      → Yükleniyor

features/listings/presentation/widgets/
  ListingCard           → Ana liste kartı
  ManageListingCard     → Benim ilanlarım kartı
  FilterSheet           → Kategori/filtre bottom sheet
```

---

## Firebase Storage Path'leri

```
profile_photos/{userId}/photo.jpg
listing_images/{listingId}/image_{index}.jpg
chat_images/{chatId}/{messageId}.jpg
```

---

## Bilinen Geçmiş Sorunlar (Çözüldü)

| Sorun | Çözüm |
|-------|-------|
| `CardTheme` API değişikliği (Flutter 3.x) | Yeni CardTheme API kullanıldı |
| Firebase Storage Blaze plan gerekliliği | Blaze planına geçildi |
| Firestore composite index | Index oluşturuldu |
| İkinci user Auth/Firestore uyumsuzluğu | Düzeltildi |
| Hero widget GlobalKey çakışması | Derin navigasyonda çözüldü |
| Proje dizininde Türkçe karakter (path encoding) | Dizin yeniden adlandırıldı |
| Arch Linux OOM (build sırasında) | Swap + Gradle JVM memory limit ayarlandı |

---

## Proje İstatistikleri

- Dart dosyası: 70+
- Feature: 7
- Screen: 20+
- Model: 8+
- Provider: 25+
- Repository: 6+
- Bağımlılık paketi: 40+
