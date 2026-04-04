# 💬 Skill: Faz 4 — Sohbet Sistemi (Firestore-based)

> Bu skill dosyasını chat ile ilgili her sohbetin başına PROJECT_CONTEXT.md ile birlikte yapıştır.

---

## Bu Skill Ne İçin?

Firestore tabanlı gerçek zamanlı mesajlaşma sistemi, sohbet listesi, mesaj gönderme/alma, resim paylaşımı ve takas tamamlama akışını anlamak ve geliştirmek için.

**Durum:** ✅ Tamamlandı — Stream Chat yerine saf Firestore ile implement edilmiş.

---

## ⚠️ ÖNEMLİ: Stream Chat KULLANILMIYOR

`stream_chat_flutter` paketi pubspec.yaml'da var ama **hiçbir yerde import edilmiyor**. Chat sistemi tamamen **Firestore** ile çalışıyor. Bu, maliyet tasarrufu için yapılan bir tercih.

---

## 🗂️ Dosya Yapısı

```
lib/features/chat/
├── data/
│   └── chat_repository.dart           # Firestore chat operasyonları (195 satır)
├── domain/
│   ├── chat_model.dart                # Sohbet modeli (76 satır)
│   └── message_model.dart             # Mesaj modeli (50 satır)
└── presentation/
    ├── chat_controller.dart            # Riverpod providers (96 satır)
    ├── chat_list_screen.dart           # Sohbet listesi (123 satır)
    └── chat_detail_screen.dart         # Mesajlaşma ekranı (683 satır)
```

---

## 📋 ChatModel (76 satır)

```dart
class ChatModel {
  final String id;                       // uid1_uid2 (alfabetik sıralı)
  final List<String> participants;       // [uid1, uid2]
  final Map<String, Map<String, dynamic>> participantDetails;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final Map<String, int> unreadCounts;   // {uid: count}
  final int imageCount;
  final String? listingId;
  final String? listingTitle;
}
```

**Chat ID üretimi:** İki UID alfabetik sıralanır ve `_` ile birleştirilir. Aynı iki kullanıcı arasında her zaman aynı chat ID.

---

## 📋 MessageModel (50 satır)

```dart
class MessageModel {
  final String id;
  final String senderId;
  final String text;
  final String? imageUrl;
  final MessageType type;    // text, image, offer, system
  final bool isRead;
  final DateTime createdAt;
}

enum MessageType { text, image, offer, system }
```

---

## 📁 ChatRepository (195 satır)

### Sohbet Yönetimi
```dart
String generateChatId(String uid1, String uid2)
Future<ChatModel> createOrGetChat({currentUser, otherUser, listingId, listingTitle})
Stream<List<ChatModel>> getUserChats(String userId)
```

### Mesaj İşlemleri
```dart
Stream<List<MessageModel>> getMessages(String chatId)
Future<void> sendMessage(chatId, text, senderId, {type})
Future<void> sendImageMessage(chatId, imageFile, senderId)  // MAX 3 RESIM!
Future<void> deleteMessage(chatId, message)                  // Resim silinirse sayaçtan düşer
Future<void> markAsRead(chatId, userId)
```

### Resim Limiti Mekanizması
```dart
final totalImageCount = userDoc.data()?['totalImageCount'] ?? 0;
if (totalImageCount >= 3) {
  throw Exception('📸 Hesap başına resim sınırına ulaştınız (Max 3).');
}
```

**Batch işlem:** Mesaj gönderimi Firestore batch ile yapılır — mesaj kaydet + sohbet güncelle + unreadCount artır tek işlemde.

---

## 🎮 ChatController (96 satır)

```dart
@riverpod
class ChatController extends _$ChatController {
  FutureOr<void> build() {}
  Future<void> startChat(otherUser, listingId, listingTitle)
  Future<void> sendTextMessage(chatId, text)
  Future<void> sendImageMessage(chatId, imageFile)
  Future<void> deleteMessage(chatId, message)
  Future<void> markAsRead(chatId)
}

// Providers
final chatRepositoryProvider = Provider((ref) => ChatRepository());
final userChatsProvider = StreamProvider.family<List<ChatModel>, String>((ref, userId) => ...);
final chatMessagesProvider = StreamProvider.family<List<MessageModel>, String>((ref, chatId) => ...);
final unreadCountProvider = StreamProvider.family<int, String>((ref, userId) => ...);
```

---

## 🖥️ Ekranlar

### ChatListScreen (123 satır)
- Kullanıcının tüm sohbetlerini listeler
- Her sohbet: Avatar, son mesaj, ilan başlığı, okunmamış badge
- `lastMessageAt`'e göre sıralı

### ChatDetailScreen (683 satır) — EN BÜYÜK DOSYA
- Mesaj baloncukları (gönderen/alıcı sağda/solda)
- Metin mesajı gönderme
- Resim gönderme (image_picker + crop)
- Resim önizleme (tam ekran)
- Mesaj seçenekleri (sil/kopyala — long press)
- **Takas Tamamlama Akışı:** İlan sahibi "Takası Bitir" → karşı taraf onay → `ListingStatus.completed` → `_showRatingDialog`

---

## 📊 Firestore Yapısı

```
chats/{chatId}
  - id (uid1_uid2), participants, participantDetails
  - lastMessage, lastMessageAt, unreadCounts: map
  - imageCount, listingId, listingTitle

chats/{chatId}/messages/{messageId}
  - senderId, text, imageUrl, type, isRead, createdAt

users/{userId}
  - totalImageCount: number         # Global resim limiti (max 3)
```

---

## ⚠️ Önemli Notlar

1. **Stream Chat YOK** — Saf Firestore kullanılıyor.
2. **Resim limiti:** Hesap başına 3 resim. Premium özellik olarak planlanıyor.
3. **Chat ID deterministik:** Aynı iki kullanıcı her zaman aynı chat ID'yi alır.
4. **Mesajlar alt koleksiyon:** `chats/{chatId}/messages/` şeklinde.
5. **Rating chat içinde:** `ChatDetailScreen` içinde `_showRatingDialog` ile puanlama yapılıyor.
6. **Cloud Functions:** `onNewMessage` fonksiyonu mesaj bildirimi gönderiyor.

---

## 🤖 Yapay Zekadan İstek Örnekleri

```
"PROJECT_CONTEXT.md ve skill_faz4_chat.md'ye göre,
chat_detail_screen.dart'a 'yazıyor...' göstergesi ekle.
Firestore'da typing indicator için bir alan kullan."
```

```
"PROJECT_CONTEXT.md ve skill_faz4_chat.md'ye göre,
chat_repository.dart'a mesaj düzenleme (edit) özelliği ekle.
Sadece kendi mesajlarını ve sadece 15 dakika içinde düzenleyebilsin."
```

```
"PROJECT_CONTEXT.md ve skill_faz4_chat.md'ye göre,
chat_list_screen.dart'a sohbet silme özelliği ekle.
Long press ile silme onayı göster."
```
