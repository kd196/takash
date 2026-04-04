# 🏗️ Skill: Faz 1 — Temel Altyapı & Auth

> Bu skill dosyasını Faz 1 (altyapı, auth, tema, navigation) ile ilgili her sohbetin başına PROJECT_CONTEXT.md ile birlikte yapıştır.

---

## Bu Skill Ne İçin?

Projenin temel altyapısını, Firebase entegrasyonunu, authentication sistemini, tema yapısını, navigation routing'i ve global provider'ları anlamak ve bu katman üzerinde değişiklik yapmak için.

**Durum:** ✅ Tamamlandı — Production hazır.

---

## 📦 Mevcut Paketler (pubspec.yaml)

```yaml
# State Management
flutter_riverpod: ^2.6.1
riverpod_annotation: ^2.6.1

# Navigation
go_router: ^14.6.1

# Firebase
firebase_core: ^3.6.0
firebase_auth: ^5.3.1
google_sign_in: ^6.2.1
cloud_firestore: ^5.4.4
firebase_storage: ^12.3.4
firebase_messaging: ^15.1.3
cloud_functions: ^5.1.3
firebase_crashlytics: ^4.1.3
firebase_analytics: ^11.3.3

# Mapbox & Location
mapbox_maps_flutter: ^2.4.0
geolocator: ^13.0.2
geoflutterfire_plus: ^0.0.17

# Chat (NOT KULLANILMIYOR — Firestore ile chat yapılıyor)
stream_chat_flutter: ^9.2.0

# Utilities
image_picker: ^1.1.2
image_cropper: ^8.0.2
cached_network_image: ^3.4.1
intl: ^0.19.0
uuid: ^4.5.1
permission_handler: ^11.3.1
flutter_dotenv: ^5.2.1
shared_preferences: ^2.3.3
flutter_native_splash: ^2.4.1
flutter_local_notifications: ^17.2.3
google_fonts: ^6.2.1
share_plus: ^12.0.1
url_launcher: ^6.3.0
package_info_plus: ^9.0.0

dev_dependencies:
  flutter_lints: ^6.0.0
  riverpod_generator: ^2.6.2
  build_runner: ^2.4.13
```

**SDK:** `>=3.4.0 <4.0.0` | **Platform:** Android (fiziksel cihaz ile test)

---

## 🗂️ Proje Yapısı (Gerçek Durum)

```
lib/
├── main.dart                                    # Entry point — Firebase, Mapbox, Crashlytics init
├── firebase_options.dart                        # FlutterFire CLI generated
├── app/
│   ├── router.dart                              # GoRouter — 5 tab StatefulShellRoute
│   └── theme.dart                               # Material 3 — Light/Dark tema
├── core/
│   ├── providers.dart                           # Global Firebase instance providers
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── api_keys.dart
│   ├── utils/
│   │   ├── helpers.dart
│   │   └── validators.dart
│   ├── extensions/
│   │   └── string_extensions.dart
│   ├── services/
│   │   └── settings_service.dart
│   └── providers/
│       └── theme_provider.dart
├── features/
│   ├── auth/
│   │   ├── data/auth_repository.dart
│   │   ├── domain/user_model.dart
│   │   └── presentation/
│   │       ├── auth_controller.dart
│   │       ├── auth_controller.g.dart
│   │       ├── login_screen.dart
│   │       └── register_screen.dart
│   ├── listings/                                # Faz 2'de detaylı
│   ├── chat/                                    # Faz 4'te detaylı
│   ├── map/                                     # Faz 3'te detaylı
│   ├── profile/                                 # Faz 5'te detaylı
│   ├── notifications/                           # Faz 6'da detaylı
│   └── onboarding/presentation/onboarding_screen.dart
└── shared/
    ├── widgets/
    │   ├── custom_button.dart
    │   ├── custom_text_field.dart
    │   ├── loading_indicator.dart
    │   ├── error_state_widget.dart
    │   └── empty_state_widget.dart
    ├── services/
    │   ├── firebase_service.dart
    │   └── storage_service.dart
    └── models/base_model.dart                   # STUB
```

---

## 🔧 main.dart — Başlatma Sırası

1. `WidgetsFlutterBinding.ensureInitialized()`
2. `dotenv.load()` — `.env` dosyasından MAPBOX_ACCESS_TOKEN, STREAM_API_KEY
3. `MapboxOptions.setAccessToken()` — Mapbox token ayarla
4. `Firebase.initializeApp()` — Firebase başlat
5. `FirebaseMessaging.onBackgroundMessage()` — Background mesaj handler
6. `FlutterError.onError` → Crashlytics'e yönlendir
7. `PlatformDispatcher.instance.onError` → Crashlytics'e yönlendir
8. `ProviderScope` içinde `TakashApp` çalıştır

**Önemli:** `TakashApp` içinde `themeMode` `ref.watch(themeModeProvider)` ile dinamik.

---

## 🎨 Tema Sistemi (Material 3)

**Marka Renkleri:**
- `primaryColor`: `0xFF2E7D32` — Koyu Yeşil (Doğa ve Güven)
- `secondaryColor`: `0xFFFFB300` — Turuncu (Takas/Aksiyon vurgusu)
- `errorColor`: `0xFFD32F2F` — Kırmızı

**Font:** `GoogleFonts.plusJakartaSans` — Tüm text'lerde kullanılıyor

**Light Tema:**
- `ColorScheme.fromSeed(seedColor: primaryColor, secondary: secondaryColor)`
- Card: elevation 0, 16px radius, `#EEEEEE` kenarlık
- Button: 12px radius, bold text
- Input: `Colors.grey[50]` fill, 12px radius

**Dark Tema:**
- `ColorScheme.fromSeed(seedColor: primaryColor, brightness: Brightness.dark)`
- Card: 16px radius, `#333333` kenarlık

---

## 🧭 GoRouter Navigation

**Redirect Mantığı:**
1. Onboarding tamamlanmamışsa → `/onboarding`
2. Onboarding tamamlanmış + onboarding route'unda → `/login`
3. Giriş yapmamış + auth route'u değilse → `/login`
4. Giriş yapmış + auth route'unda → `/` (Keşfet)

**Route Yapısı:**
```
/onboarding          → OnboardingScreen
/login               → LoginScreen
/register            → RegisterScreen
/user/:id            → PublicProfileScreen
/edit-profile        → EditProfileScreen
/notifications       → NotificationScreen
/favorites           → FavoritesScreen
/settings            → SettingsScreen
/edit-listing/:id    → EditListingScreen

StatefulShellRoute (5 tab):
  [0] /              → HomeScreen → listing/:id → ListingDetailScreen
  [1] /map           → MapScreen
  [2] /create-listing → CreateListingScreen
  [3] /chats         → ChatListScreen → :id → ChatDetailScreen
  [4] /profile       → ProfileScreen → edit/my-listings/favorites
```

---

## 🔐 Auth — Kullanıcı Doğrulama

### UserModel (77 satır)
```dart
class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final String? bio;
  final double rating;           // ortalama puan
  final int ratingCount;         // toplam değerlendirme
  final DateTime createdAt;
  final int totalImageCount;     // chat'te gönderilen toplam resim (limit: 3)
}
```

**Önemli:** `toJson()` metodu `totalImageCount` alanını dahil ETMEZ — yanlışlıkla 0 yazılmasını önler.

### AuthRepository (134 satır)
```dart
class AuthRepository {
  Stream<User?> get authStateChanges
  User? get currentUser
  Future<UserCredential> signInWithEmail(email, password)
  Future<UserCredential> registerWithEmail(email, password, displayName)
  Future<UserCredential?> signInWithGoogle()
  Future<void> signOut()
  Future<UserModel?> getUserData(uid)
}
```

**_saveUserToFirestore mantığı:**
- İlk girişte `totalImageCount: 0` set edilir
- Sonraki girişlerde `merge: true` ile sadece mevcut alanlar güncellenir

### AuthController (48 satır)
```dart
@riverpod
class AuthController extends _$AuthController {
  FutureOr<void> build() {}
  Future<void> signInWithEmail(email, password)
  Future<void> registerWithEmail(email, password, displayName)
  Future<void> signInWithGoogle()
  Future<void> signOut()
}
```

**Pattern:** Tüm metodlar `AsyncValue.guard()` ile state yönetir.

### Global Providers (29 satır)
```dart
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
final storageProvider = Provider<FirebaseStorage>((ref) => FirebaseStorage.instance);
final authStateProvider = StreamProvider<User?>((ref) => ref.watch(firebaseAuthProvider).authStateChanges());
```

---

## 🌍 Environment Variables

```bash
# .env (git'e eklenmez)
MAPBOX_ACCESS_TOKEN=pk.your_mapbox_token
STREAM_API_KEY=your_stream_api_key
```

---

## 📱 Onboarding

4 sayfalık PageView: Takas → Konum → Sohbet → Puanlama
`SharedPreferences` ile `onboarding_completed` flag'i saklanır.

---

## 🛠️ Shared Widgets

| Widget | Açıklama |
|--------|----------|
| `CustomButton` | ElevatedButton wrapper, loading state |
| `CustomTextField` | TextFormField wrapper, validator desteği |
| `LoadingIndicator` | Centered CircularProgressIndicator |
| `ErrorStateWidget` | Hata durumu + retry butonu |
| `EmptyStateWidget` | Boş durum + ikon + mesaj |

---

## ⚠️ Önemli Notlar

1. **Stream Chat kullanılmıyor!** `stream_chat_flutter` pubspec.yaml'da var ama hiçbir yerde import edilmiyor. Chat sistemi **saf Firestore** ile çalışıyor.
2. **Sadece Android** aktif. Fiziksel cihaz ile test ediliyor.
3. **Riverpod generator** kullanılıyor — `.g.dart` dosyası üretiyor.
4. **Crashlytics** aktif — tüm fatal hatalar otomatik kaydediliyor.
5. **Theme provider** dinamik — kullanıcı light/dark/system seçebiliyor.

---

## 🤖 Yapay Zekadan İstek Örnekleri

```
"PROJECT_CONTEXT.md ve skill_faz1_infrastructure.md'ye göre,
auth_repository.dart'a telefon numarası ile giriş ekle.
Mevcut yapıyı bozmadan, signInWithPhone ve verifyPhoneNumber metodlarını ekle."
```

```
"PROJECT_CONTEXT.md ve skill_faz1_infrastructure.md'ye göre,
router.dart'a yeni bir '/help' route'u ekle. Auth gerektirmesin."
```
