# 🔔 Skill: Faz 6 — Bildirimler & Son Dokunuşlar

> Bu skill dosyasını bildirimler ve UI iyileştirmeleri ile ilgili her sohbetin başına PROJECT_CONTEXT.md ile birlikte yapıştır.

---

## Bu Skill Ne İçin?

Firebase Cloud Messaging (FCM) push bildirimleri, flutter_local_notifications yerel bildirimleri, bildirim ekranı ve uygulama ayarlarını anlamak ve geliştirmek için.

**Durum:** ✅ Tamamlandı — Bildirimler ve ayarlar ekranı çalışıyor.

---

## 🗂️ Dosya Yapısı

```
lib/features/notifications/
├── data/
│   └── notification_service.dart          # FCM + Local Notifications (304 satır)
├── domain/
│   └── notification_model.dart            # Bildirim modeli (82 satır)
└── presentation/
    ├── notification_controller.dart       # Riverpod controller (96 satır)
    └── notification_screen.dart           # Bildirim listesi (166 satır)

lib/features/profile/
└── presentation/
    └── settings_screen.dart               # Ayarlar ekranı (261 satır)
```

---

## 📋 NotificationModel (82 satır)

```dart
class NotificationModel {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final String? relatedId;
  final bool isRead;
  final DateTime createdAt;
}

enum NotificationType {
  newMessage,       // Yeni mesaj
  newOffer,         // Yeni teklif
  tradeCompleted,   // Takas tamamlandı
  newRating,        // Yeni puanlama
  system,           // Sistem bildirimi
}
```

---

## 📁 NotificationService (304 satır)

### FCM Başlatma
```dart
class NotificationService {
  Future<void> initialize() {
    // 1. Android notification channel'ları oluştur (5 kanal)
    // 2. flutter_local_notifications plugin başlat
    // 3. FCM izinlerini al
    // 4. FCM token'ı kaydet
    // 5. Token refresh dinle
    // 6. Foreground mesajları dinle
  }
}
```

### Android Notification Kanalları
| Kanal ID | İsim | Öncelik |
|----------|------|---------|
| `chat_messages` | Sohbet Mesajları | High |
| `offers` | Teklif Bildirimleri | High |
| `trades` | Takas Bildirimleri | Default |
| `ratings` | Puanlama Bildirimleri | Default |
| `system` | Sistem Bildirimleri | Low |

### Token Yönetimi
```dart
Future<void> _saveToken()           // FCM token'ı Firestore'a kaydet
Future<void> _updateToken(String)   // Token yenilendiğinde güncelle
Future<void> deleteToken()          // Çıkış yaparken token'ı sil
```

**Firestore'da token saklama:**
```dart
users/{userId}
  - fcmTokens: string[]    // ArrayUnion ile ekleme, ArrayRemove ile silme
```

### Bildirim CRUD
```dart
Stream<List<NotificationModel>> getUserNotifications(String userId)  // limit 50
Future<void> markAsRead(String notificationId)
Future<void> markAllAsRead(String userId)
Future<void> deleteNotification(String notificationId)
Future<int> getUnreadCount(String userId)
```

---

## 🎮 NotificationController (96 satır)

```dart
@riverpod
class NotificationController extends _$NotificationController {
  FutureOr<void> build() {}
  Future<void> initialize()
  Future<void> markAsRead(String notificationId)
  Future<void> markAllAsRead()
  Future<void> deleteNotification(String notificationId)
  void handleForegroundNotification(NotificationModel notification)
  void handleNotificationTap(NotificationModel notification)
}

// Providers
final notificationServiceProvider = Provider((ref) => NotificationService());
final notificationControllerProvider = AsyncNotifierProvider<...>(NotificationController.new);
final userNotificationsProvider = StreamProvider.family<List<NotificationModel>, String>((ref, userId) => ...);
final unreadCountProvider = StreamProvider.family<int, String>((ref, userId) => ...);
```

---

## 🖥️ Ekranlar

### NotificationScreen (166 satır)
- Bildirim listesi (StreamBuilder)
- Tip bazlı ikonlar (mesaj/teklif/takas/puanlama/sistem)
- Okunmuş/okunmamış stil farklılığı
- Swipe-to-dismiss ile silme
- "Tümünü okundu işaretle" butonu

### SettingsScreen (261 satır)
- **Hesap:** Profil düzenleme, İlanlarım, Favorilerim
- **Görünüm:** Açık / Koyu / Sistem tema (radio buttons)
- **Bildirimler:** Bildirimler ekranına yönlendirme
- **Gizlilik:** Konum paylaşımı toggle
- **Destek:** Hakkında, Gizlilik Politikası, Kullanım Şartları (url_launcher)
- **Uygulama:** Versiyon bilgisi (package_info_plus)
- **Çıkış Yap**

---

## ☁️ Cloud Functions (5 fonksiyon)

1. **onNewMessage** — `chats/{chatId}/messages/{messageId}` onCreate → Alıcıya bildirim
2. **onNewOffer** — `offers/{offerId}` onCreate → İlan sahibine bildirim
3. **onTradeCompleted** — `listings/{listingId}` onUpdate (status → completed) → Katılımcılara bildirim
4. **onNewRating** — `ratings/{ratingId}` onCreate → Puanlanan kullanıcıya bildirim
5. **cleanupOldNotifications** — Her 24 saatte → Okunmuş + 30 günden eski bildirimleri sil

---

## 📊 Firestore Yapısı

```
notifications/{notificationId}
  - userId, type, title, body, relatedId, isRead, createdAt

users/{userId}
  - fcmTokens: string[]     // FCM device token'ları
```

---

## ⚠️ Önemli Notlar

1. **Background handler:** `@pragma('vm:entry-point')` ile işaretlenmiş.
2. **In-app bildirimler:** Firestore'da `notifications` koleksiyonunda saklanır.
3. **Token yönetimi:** `FieldValue.arrayUnion` ile ekleme, `FieldValue.arrayRemove` ile silme.
4. **5 Android channel:** Her bildirim tipi için ayrı kanal, farklı öncelikler.
5. **Cleanup:** Cloud Function her 24 saatte eski bildirimleri temizler.

---

## 🔧 Geliştirilmesi Gerekenler

- [ ] Bildirim yönlendirme (notification tap → ilgili ekran) tam implement edilmeli
- [ ] Bildirim sesleri özelleştirme
- [ ] Bildirim tercihleri (kullanıcı hangi bildirimleri almak istiyor)
- [ ] Badge count (app icon üzerinde okunmamış sayısı)

---

## 🤖 Yapay Zekadan İstek Örnekleri

```
"PROJECT_CONTEXT.md ve skill_faz6_notifications.md'ye göre,
notification_screen.dart'ta bildirim tıklandığında yönlendirme yap.
type'a göre: newMessage → ChatDetailScreen, newOffer → ListingDetailScreen."
```

```
"PROJECT_CONTEXT.md ve skill_faz6_notifications.md'ye göre,
settings_screen.dart'a bildirim tercihleri ekle.
Kullanıcı mesaj/teklif/takas/puanlama bildirimlerini ayrı ayrı aç/kapatabilsin."
```
