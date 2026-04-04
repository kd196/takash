# Faz 4: Uygulama Adımları ve Task Listesi

Sohbet sisteminin entegrasyonu aşağıdaki sıralı adımlarla gerçekleştirilecektir.

## 🟩 Adım 1: Bağımlılıklar ve Yapılandırma
- [ ] `pubspec.yaml` dosyasına gerekli paketlerin eklenmesi:
    - `stream_chat_flutter`
    - `cloud_functions`
- [ ] `.env` dosyasına `STREAM_API_KEY` eklenmesi.
- [ ] Android tarafında `minSdkVersion` (21+) kontrolü.

## 🟦 Adım 2: Firebase Cloud Functions (Token Server)
- [ ] Firebase CLI ile `functions` klasörünün başlatılması.
- [ ] `getStreamToken` fonksiyonunun yazılması (Node.js).
- [ ] `STREAM_API_SECRET` anahtarının Firebase ortam değişkenlerine eklenmesi.
- [ ] Fonksiyonun deploy edilmesi.

## 🟨 Adım 3: Stream Chat Client ve Bağlantı Mantığı
- [ ] `ChatRepository` oluşturulması.
- [ ] Riverpod `chatClientProvider` tanımlanması.
- [ ] Uygulama açılışında veya login sonrası `connectUser` mantığının kurulması.

## 🟧 Adım 4: Kullanıcı Arayüzü (UI) Entegrasyonu
- [ ] **Sohbet Listesi Sayfası:** Tüm aktif konuşmaların listelenmesi.
- [ ] **Mesajlaşma Sayfası:** Birebir mesajlaşma, resim gönderimi.
- [ ] **Teklif Ver Butonu:** İlan detayından sohbete geçiş mantığı (Kanal oluşturma/bulma).
- [ ] **Navigasyon:** BottomNavBar'a "Mesajlar" ikonu eklenmesi.

## 🟥 Adım 5: Test ve İyileştirme
- [ ] Mesaj bildirimleri (Push Notifications) hazırlığı.
- [ ] Boş mesaj listesi durumu ve hata yönetimi.
- [ ] Profil fotoğraflarının ve isimlerin Stream ile senkronizasyonu.
