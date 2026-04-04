# Faz 4: Sohbet Sistemi Teknik Tasarım ve Mimari

Bu döküman, Takash uygulamasının Stream Chat SDK kullanılarak geliştirilecek olan sohbet sisteminin teknik altyapısını tanımlar.

## 1. Teknoloji Yığını
- **SDK:** `stream_chat_flutter` (v6.x+)
- **Backend:** Firebase Cloud Functions (Node.js)
- **State Management:** Riverpod
- **Güvenlik:** Firebase Auth tabanlı JWT Token üretimi

## 2. Kimlik Doğrulama Akışı (Token Management)
Stream Chat, istemci tarafında güvenli bir bağlantı için bir `User Token` gerektirir. Bu token'ın istemci tarafında üretilmesi (Secret Key sızıntısı riski nedeniyle) yasaktır.
1. Flutter uygulaması, Firebase Auth üzerinden `User ID` alır.
2. Uygulama, `getStreamToken` adlı Firebase Cloud Function'ı çağırır.
3. Cloud Function, sunucu tarafında `STREAM_API_SECRET` kullanarak bu kullanıcı için bir token üretir ve döner.
4. Flutter uygulaması, dönen token ile `StreamChatClient.connectUser()` metodunu çalıştırır.

## 3. Kanal ve Mesajlaşma Yapısı
- **Kanal Tipi:** `messaging` (Standart 1-1 DM).
- **Kanal ID Stratejisi:** İki kullanıcı arasındaki kanal ID'si, `generateChannelId(uid1, uid2)` fonksiyonu ile alfabetik olarak sıralanmış UID'lerin birleşimi olacaktır. Bu, aynı iki kişi arasında her zaman tek bir kanal olmasını garanti eder.
- **İlan İlişkisi:** İlk aşamada saf DM (iki kişi arası) olarak kurgulanacaktır.

## 4. State Management (Riverpod)
- `streamChatClientProvider`: Singleton `StreamChatClient` örneği.
- `streamChatConnectionProvider`: Bağlantı durumunu (loading, connected, error) yöneten FutureProvider.
- `chatChannelProvider(channelId)`: Belirli bir kanalın verilerini yöneten Provider.

## 5. Güvenlik ve Gizlilik
- API Secret asla Flutter koduna dahil edilmeyecektir.
- `.env` dosyası sadece API Key içerecektir.
- Firebase Cloud Functions üzerinden sadece yetkilendirilmiş (Auth olmuş) kullanıcılar token talep edebilecektir.
