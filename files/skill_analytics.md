# 📊 Skill: Analitik & Kullanıcı Takibi

> Bu skill dosyasını analitik ile ilgili her sohbetin başına PROJECT_CONTEXT.md ile birlikte yapıştır.

---

## Bu Skill Ne İçin?

Firebase Analytics entegrasyonu ve kullanıcı etkinliklerini izlemek için.

---

## 📦 Paketler

```yaml
firebase_analytics: ^11.3.3
```

---

## 📈 Mevcut Durum

`firebase_analytics` paketi pubspec.yaml'da var ama **henüz implement edilmedi**.

---

## 🔧 Önerilen Yapı

```
lib/core/analytics/
├── analytics_service.dart    # Merkezi AnalyticsService
├── analytics_events.dart     # Event tanımları
└── analytics_observer.dart   # Navigation observer (opsiyonel)
```

### AnalyticsService
```dart
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> setUserId(String? userId)
  Future<void> logEvent({required String name, Map<String, dynamic>? parameters})
  Future<void> logScreenView({required String screenName})
}
```

### Event Tanımları
```dart
class AnalyticsEvents {
  // Auth
  static const String signUp = 'sign_up';
  static const String login = 'login';
  static const String logout = 'logout';

  // Listing
  static const String createListing = 'create_listing';
  static const String viewListing = 'view_listing';
  static const String deleteListing = 'delete_listing';
  static const String favoriteListing = 'favorite_listing';

  // Chat
  static const String startChat = 'start_chat';
  static const String sendMessage = 'send_message';
  static const String sendImage = 'send_image';

  // Trade
  static const String completeTrade = 'complete_trade';
  static const String rateUser = 'rate_user';

  // Map
  static const String viewMap = 'view_map';
  static const String searchNearby = 'search_nearby';
}
```

---

## 📊 İzlenecek Metrikler

| Metrik | Açıklama |
|--------|----------|
| DAU | Günlük aktif kullanıcı |
| MAU | Aylık aktif kullanıcı |
| Retention | Kullanıcı tutma oranı |
| Crash-free | Crash'sız kullanıcı % |
| Screen Views | Ekran görüntüleme |
| Conversion | İlan oluşturma → Chat → Takas oranı |

---

## 🧪 Debug Mode

```bash
# Android
adb shell setprop debug.firebase.analytics.app com.takash.app
```

---

## ✅ Analytics Kontrol Listesi

- [ ] Firebase Analytics paketi eklendi (✅ var)
- [ ] AnalyticsService oluşturuldu
- [ ] Event tanımları oluşturuldu
- [ ] Auth event'leri loglanıyor
- [ ] Listing event'leri loglanıyor
- [ ] Chat event'leri loglanıyor
- [ ] Kullanıcı ID'si ayarlanıyor
- [ ] Screen view tracking

---

## 🤖 Yapay Zekadan İstek Örnekleri

```
"PROJECT_CONTEXT.md ve skill_analytics.md'ye göre,
AnalyticsService sınıfını oluştur ve main.dart'ta initialize et."
```

```
"PROJECT_CONTEXT.md ve skill_analytics.md'ye göre,
create_listing_screen.dart'a analytics event'leri ekle.
create_listing ve image_upload event'leri loglansın."
```
