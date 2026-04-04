# 🧪 Skill: Faz 7 — Test & Beta

> Bu skill dosyasını test ve beta süreçleri ile ilgili her sohbetin başına PROJECT_CONTEXT.md ile birlikte yapıştır.

---

## Bu Skill Ne İçin?

Flutter'da unit test, widget test, entegrasyon test yazma, GitHub Actions CI/CD kurulumu ve Firebase Test Lab ile test süreçlerini yönetmek için.

**Durum:** ❌ Başlanmadı — Sadece `test/widget_test.dart` varsayılan dosyası var.

---

## 📦 Gerekli Paketler

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  build_runner: ^2.4.13
  fake_cloud_firestore: ^3.1.0
  firebase_auth_mocks: ^0.14.0
  integration_test:
    sdk: flutter
```

---

## 📁 Önerilen Test Yapısı

```
test/
├── unit/
│   ├── repositories/
│   │   ├── auth_repository_test.dart
│   │   ├── listing_repository_test.dart
│   │   ├── chat_repository_test.dart
│   │   └── rating_repository_test.dart
│   ├── models/
│   │   ├── user_model_test.dart
│   │   ├── listing_model_test.dart
│   │   ├── chat_model_test.dart
│   │   └── message_model_test.dart
│   └── services/
│       └── notification_service_test.dart
├── widget/
│   ├── login_screen_test.dart
│   ├── listing_card_test.dart
│   ├── home_screen_test.dart
│   └── chat_detail_screen_test.dart
└── mocks/
    ├── mock_auth_repository.dart
    ├── mock_firestore.dart
    └── mock_storage.dart

integration_test/
├── app_test.dart
└── driver.dart
```

---

## 🧪 Unit Test Örneği

### Model Testi
```dart
void main() {
  test('UserModel fromJson ve toJson uyumlu olmalı', () {
    final user = UserModel(
      uid: 'test-uid',
      displayName: 'Test User',
      email: 'test@test.com',
      rating: 4.5,
      ratingCount: 10,
      createdAt: DateTime(2024, 1, 1),
      totalImageCount: 2,
    );

    final json = user.toJson();
    final parsed = UserModel.fromJson(json);

    expect(parsed.uid, user.uid);
    expect(parsed.displayName, user.displayName);
    expect(parsed.email, user.email);
    expect(parsed.rating, user.rating);
    expect(parsed.ratingCount, user.ratingCount);
  });
}
```

### Repository Testi (Fake Firestore)
```dart
void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late ListingRepository repository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = ListingRepository(
      firestore: fakeFirestore,
      storage: MockFirebaseStorage(),
    );
  });

  test('İlan oluşturulabilmeli', () async {
    final listingId = await repository.createListing(
      ownerId: 'user-1',
      title: 'Test İlan',
      description: 'Test açıklama',
      category: ListingCategory.electronics,
      wantedItem: 'Kitap',
      images: [],
      createdAt: DateTime.now(),
    );

    final doc = await fakeFirestore.collection('listings').doc(listingId).get();
    expect(doc.exists, true);
    expect(doc.data()!['title'], 'Test İlan');
  });
}
```

---

## 🎨 Widget Test Örneği

```dart
void main() {
  testWidgets('E-posta ve şifre alanları görünmeli', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp(home: LoginScreen())),
    );

    expect(find.text('E-posta'), findsOneWidget);
    expect(find.text('Şifre'), findsOneWidget);
    expect(find.text('Giriş Yap'), findsOneWidget);
  });
}
```

---

## 🚀 GitHub Actions CI/CD

```yaml
name: Flutter CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage

  build-android:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v4
        with:
          name: apk
          path: build/app/outputs/flutter-apk/app-release.apk
```

---

## 📊 Test Komutları

```bash
# Tüm testler
flutter test

# Coverage ile
flutter test --coverage

# Belirli dosya
flutter test test/unit/auth_test.dart

# Integration test
flutter test integration_test/app_test.dart

# Analyze (lint)
flutter analyze
```

---

## ✅ Test Kontrol Listesi

- [ ] Model testleri yazıldı (fromJson/toJson uyumluluk)
- [ ] Repository testleri yazıldı (CRUD operasyonları)
- [ ] Widget testleri yazıldı (ekran render + interaksiyon)
- [ ] Integration test'ler eklendi (user flow)
- [ ] GitHub Actions workflow oluşturuldu
- [ ] Coverage > %80
- [ ] Firebase Test Lab ile cihaz testleri yapıldı

---

## 🤖 Yapay Zekadan İstek Örnekleri

```
"PROJECT_CONTEXT.md ve skill_faz7_testing.md'ye göre,
AuthRepository için unit test yaz.
fake_cloud_firestore ve firebase_auth_mocks kullan."
```

```
"PROJECT_CONTEXT.md ve skill_faz7_testing.md'ye göre,
ListingCard widget'ı için widget test yaz."
```

```
"PROJECT_CONTEXT.md ve skill_faz7_testing.md'ye göre,
GitHub Actions workflow dosyası oluştur."
```
