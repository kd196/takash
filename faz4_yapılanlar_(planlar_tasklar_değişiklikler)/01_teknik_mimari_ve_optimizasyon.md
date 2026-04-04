# Faz 4: Firestore Sohbet Sistemi — Teknik Tasarım ve Mimari

## 📌 Hedef ve Yaklaşım
Mevcut Firebase altyapısını (Firestore + Storage) kullanarak, ekstra maliyet gerektirmeyen, yüksek performanslı ve sürdürülebilir bir sohbet sistemi kurmak.

## 🏗️ Veri Mimarisi

### 1. Chats Koleksiyonu (`chats/{chatId}`)
- `participants`: `List<String>` [uid1, uid2]
- `participantDetails`: `Map` {uid: {name, photo}} (Hızlı listeleme için)
- `lastMessage`: `String`
- `lastMessageAt`: `Timestamp`
- `imageCount`: `int` (Ücretsiz sürüm için 3 resim sınırı)
- `listingId`: `String?` (Opsiyonel ilan referansı)

### 2. Messages Alt Koleksiyonu (`chats/{chatId}/messages/{messageId}`)
- `senderId`: `String`
- `text`: `String`
- `imageUrl`: `String?`
- `type`: `String` (text, image, offer)
- `createdAt`: `Timestamp`
- `isRead`: `bool`

## 🚀 Optimizasyon ve Sınırlandırmalar
- **Resim Boyutu:** Maksimum 1024px genişlik/yükseklik.
- **Sıkıştırma:** %70 kalite (JPEG).
- **Limit:** Sohbet başına maksimum 3 adet resim gönderimi (Premium hazırlık).
- **ID Üretimi:** `chatId = uid1_uid2` (UID'ler alfabetik sıralanır).

## 🛠️ Teknoloji Yığını
- **Veritabanı:** Cloud Firestore (Real-time snapshots).
- **Depolama:** Firebase Storage.
- **State:** Riverpod (StreamProvider).
