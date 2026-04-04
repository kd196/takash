# 🛡️ Skill: Hata Yönetimi & Logging

> Bu skill dosyasını hata yönetimi ile ilgili her sohbetin başına PROJECT_CONTEXT.md ile birlikte yapıştır.

---

## Bu Skill Ne İçin?

Try-catch yapısının standartlaştırılması, Firebase Crashlytics entegrasyonu ve kullanıcı dostu hata mesajları oluşturmak için.

---

## 📦 Paketler

```yaml
firebase_crashlytics: ^4.1.3
logger: ^2.5.0
```

---

## 🔥 Crashlytics Kurulumu (main.dart)

```dart
void main() async {
  // ... init işlemleri ...

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const ProviderScope(child: TakashApp()));
}
```

---

## 📝 Mevcut Hata Yönetimi Pattern'i

### AuthController Pattern
```dart
Future<void> signInWithEmail(String email, String password) async {
  state = const AsyncLoading();
  state = await AsyncValue.guard(() =>
    ref.read(authRepositoryProvider).signInWithEmail(email, password)
  );
}
```

### UI'da Hata Gösterimi (LoginScreen)
```dart
if (mounted && ref.read(authControllerProvider).hasError) {
  final error = ref.read(authControllerProvider).error;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Giriş hatası: ${error.toString()}')),
  );
}
```

---

## ⚠️ Mevcut Eksikler

1. **Merkezi ErrorHandler sınıfı yok** — Her controller kendi hatasını yönetiyor
2. **AppLogger sınıfı yok** — `print()` kullanılıyor (notification_service.dart'ta görüldü)
3. **Özel exception sınıfları yok** — FirebaseException'lar doğrudan yakalanıyor
4. **Failure modelleri yok** — Either<Failure, T> pattern'i kullanılmıyor
5. **Türkçe hata mesajları** — Firebase error code'ları Türkçe'ye çevrilmiyor

---

## 🔧 Önerilen Yapı

```
lib/core/errors/
├── exceptions.dart     # AppException, AuthException, NetworkException, DatabaseException
├── failures.dart       # Failure, AuthFailure, NetworkFailure, DatabaseFailure
└── error_handler.dart  # ErrorHandler.handleException()

lib/core/utils/
└── logger.dart         # AppLogger (Crashlytics entegreli)
```

### Türkçe Hata Mesajları
```dart
final errorMessages = {
  'user-not-found': 'Kullanıcı bulunamadı',
  'wrong-password': 'Yanlış şifre',
  'email-already-in-use': 'Bu e-posta zaten kullanılıyor',
  'invalid-email': 'Geçersiz e-posta adresi',
  'weak-password': 'Şifre çok zayıf',
  'network-request-failed': 'İnternet bağlantısı yok',
};
```

---

## ✅ Hata Yönetimi Kontrol Listesi

- [ ] Tüm repository metodları try-catch içinde
- [ ] Hatalar Failure'a dönüştürülüyor
- [ ] Crashlytics entegre (✅ main.dart'ta var)
- [ ] Kullanıcı dostu mesajlar var
- [ ] Logger kullanılıyor (❌ şu anda print() kullanılıyor)
- [ ] Türkçe hata mesajları

---

## 🤖 Yapay Zekadan İstek Örnekleri

```
"PROJECT_CONTEXT.md ve skill_error_handling.md'ye göre,
core/errors/ klasörünü oluştur.
AppException, AuthException, NetworkException sınıflarını yaz."
```

```
"PROJECT_CONTEXT.md ve skill_error_handling.md'ye göre,
auth_controller.dart'taki hata yönetimini iyileştir.
FirebaseAuthException'ları Türkçe mesajlara çevir."
```
