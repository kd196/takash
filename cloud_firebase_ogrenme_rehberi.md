# 🔥 Firebase & Backend Öğrenme Rehberi
## Takaş Projesi Geliştiricisi İçin Pratik Kılavuz

---

## Önce Şunu Bil

Backend öğrenmek için bilgisayar mühendisi olmak gerekmez.
Bu rehberdeki her şeyi **Takaş projesini geliştirirken** öğreneceksin.
Teori değil, pratikte öğrenme yaklaşımı.

---

## Backend Nedir? (Gerçekten Basit Anlatım)

Bir uygulamada iki taraf var:

```
FRONTEND (Flutter)          BACKEND (Firebase)
─────────────────           ──────────────────
Kullanıcının gördüğü   ←→   Verilerin saklandığı
Butonlar, ekranlar          Sunucular, veritabanı
Sen bunu yazıyorsun         Firebase bunu yönetiyor
```

Normalde backend yazmak için ayrı bir sunucu kurmak,
Node.js veya Python öğrenmek gerekir. **Firebase bunu sana hazır veriyor.**
Sen sadece nasıl kullanacağını öğreneceksin.

---

## Firebase Nedir? Ne İşe Yarar?

Firebase, Google'ın sunduğu bir "Backend as a Service" platformudur.
Yani backend'i Google kuruyor, sen sadece kullanıyorsun.

```
Firebase =
  Kullanıcı girişi (Auth)
  + Veritabanı (Firestore)
  + Dosya depolama (Storage)
  + Sunucusuz kod (Cloud Functions)
  + Bildirimler (Cloud Messaging)
  + Hata takibi (Crashlytics)
  + Kullanım analizi (Analytics)
```

Takaş için bunların hepsini kullanacaksın.

---

## BÖLÜM 1 — Firebase Authentication

### Ne İşe Yarar?
Kullanıcıların kim olduğunu doğrular.
"Bu kişi gerçekten bu e-posta adresinin sahibi mi?" sorusunu Firebase cevaplar.

### Nasıl Çalışır?
```
Kullanıcı giriş yapar
        ↓
Firebase kimliği doğrular
        ↓
Sana bir "User" nesnesi verir (uid, email, displayName)
        ↓
Bu uid'yi her yerde kullanırsın (Firestore, Storage)
```

### Takaş'ta Nerede Kullandık?
- `auth_repository.dart` → Firebase Auth ile konuşan dosya
- `signInWithEmail()`, `signInWithGoogle()` → Auth metodları
- `authStateChanges` → Kullanıcı giriş yapmış mı dinleyen stream

### Öğrenmek İçin Yap
1. Firebase konsolunda **Authentication → Users** sekmesini aç
2. Uygulamada bir hesap oluştur
3. Konsolda kullanıcının göründüğünü gözlemle
4. `uid` alanını not al — bu kullanıcının kimliği

### Kaynak
- Firebase Auth Flutter Docs: `firebase.flutter.dev/docs/auth/start`

---

## BÖLÜM 2 — Cloud Firestore

### Ne İşe Yarar?
Uygulamanın veritabanıdır. Kullanıcı profilleri, ilanlar, sohbetler burada saklanır.

### SQL Değil, NoSQL
Alışık olduğun Excel tablosu mantığı değil:

```
SQL (Tablo mantığı):          Firestore (Döküman mantığı):
─────────────────────         ──────────────────────────────
users tablosu                 users/ koleksiyonu
  id | name | email             userId123/ dökümanı
  1  | Ali  | ali@...             name: "Ali"
  2  | Ayşe | ayse@...            email: "ali@..."
                                userId456/ dökümanı
                                  name: "Ayşe"
```

### Temel Kavramlar

```
Koleksiyon (Collection)
└── Döküman (Document)
    ├── Alan (Field): değer
    ├── Alan: değer
    └── Alt Koleksiyon (Subcollection)
        └── Döküman
```

Takaş için:
```
users/                          → Kullanıcı koleksiyonu
  {userId}/                     → Bir kullanıcının dökümanı
    displayName: "Ali Yılmaz"
    email: "ali@mail.com"
    rating: 4.8

listings/                       → İlan koleksiyonu
  {listingId}/                  → Bir ilanın dökümanı
    title: "Bisiklet"
    ownerId: "{userId}"         → users koleksiyonuyla bağlantı
    geohash: "sxfgme42"
```

### 3 Temel İşlem

```dart
// 1. VERİ OKUMA (bir kez)
final doc = await firestore.collection('users').doc(userId).get();
final name = doc.data()['displayName'];

// 2. VERİ OKUMA (gerçek zamanlı — değişince otomatik güncellenir)
firestore.collection('listings').snapshots().listen((snapshot) {
  // Her değişiklikte bu çalışır
});

// 3. VERİ YAZMA
await firestore.collection('users').doc(userId).set({
  'displayName': 'Ali',
  'email': 'ali@mail.com',
});
```

### Öğrenmek İçin Yap
1. Firebase konsolunda **Firestore Database** sekmesini aç
2. Uygulamada profil oluştur
3. Konsolda `users` koleksiyonunda dökümanın göründüğünü gözlemle
4. Bir alanı konsoldan elle değiştir, uygulamada değiştiğini gör

### Güvenlik Kuralları (Faz 7'de yazacaksın)
```javascript
// Şu an test mode: herkes okuyup yazabilir (sadece geliştirme için)
// Faz 7'de şöyle olacak:
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      // Sadece kendi profilini yazabilirsin
      allow write: if request.auth.uid == userId;
      // Herkes okuyabilir
      allow read: if request.auth != null;
    }
  }
}
```

### Kaynak
- Firestore Flutter Docs: `firebase.flutter.dev/docs/firestore/start`

---

## BÖLÜM 3 — Firebase Storage

### Ne İşe Yarar?
Fotoğraf ve dosyaları saklar. İlan fotoğrafları, profil resimleri burada tutulur.

### Nasıl Çalışır?
```
Kullanıcı fotoğraf seçer (image_picker)
        ↓
Flutter dosyayı Storage'a yükler
        ↓
Storage bir URL verir (https://firebasestorage.googleapis.com/...)
        ↓
Bu URL'i Firestore'daki ilana kaydedersin
        ↓
Uygulama bu URL'den fotoğrafı gösterir (cached_network_image)
```

### Dosya Yapısı
```
Firebase Storage:
  listings/
    {listingId}/
      image_0.jpg
      image_1.jpg
  users/
    {userId}/
      profile.jpg
```

### Temel Kod
```dart
// Dosyayı yükle
final ref = storage.ref('listings/$listingId/image_0.jpg');
await ref.putFile(imageFile);

// URL'i al
final url = await ref.getDownloadURL();

// Bu URL'i Firestore'a kaydet
await firestore.collection('listings').doc(listingId).update({
  'imageUrls': FieldValue.arrayUnion([url]),
});
```

### Öğrenmek İçin Yap
1. Konsolda **Storage** sekmesini aç
2. Uygulamada profil fotoğrafı yükle
3. Konsolda `users/` klasöründe dosyanın göründüğünü gözlemle
4. Dosyaya tıkla, URL'i kopyala, tarayıcıda aç

---

## BÖLÜM 4 — Cloud Functions

### Ne İşe Yarar?
Sunucuda çalışan küçük kod parçaları. Flutter'da yapamayacağın şeyleri burada yaparsın.

### Neden Gerekli?
Bazı işlemler güvenlik nedeniyle telefonda yapılamaz:
- Stream Chat için **gizli API key** ile token üretmek
- Kullanıcı puanını **manipüle edilemez** şekilde hesaplamak
- Ödeme işlemleri (ilerideki özellikler)

### Takaş'ta Kullanacakların

```javascript
// 1. Stream Chat Token Üretimi
exports.getStreamToken = functions.https.onCall(async (data, context) => {
  // Kullanıcı kimliğini doğrula
  if (!context.auth) throw new Error('Giriş yapılmamış');
  
  // Gizli key ile token üret (bu key telefonda olmaz)
  const token = streamClient.createToken(context.auth.uid);
  return { token };
});

// 2. Ortalama Puan Hesaplama
exports.onRatingCreated = functions.firestore
  .document('ratings/{ratingId}')
  .onCreate(async (snap) => {
    // Yeni puan eklenince kullanıcının ortalamasını güncelle
    // Bu Flutter'da yapılsaydı manipüle edilebilirdi
  });
```

### Nasıl Deploy Edilir?
```bash
cd functions/
npm install
firebase deploy --only functions
```

### Öğrenmek İçin Yap
1. Firebase konsolunda **Functions** sekmesini aç
2. Faz 4'te `getStreamToken` fonksiyonunu deploy et
3. Konsolda **Logs** sekmesinden fonksiyonun çalıştığını gözlemle

---

## BÖLÜM 5 — Firebase Cloud Messaging (FCM)

### Ne İşe Yarar?
Push bildirimler gönderir. "Yeni mesajınız var" bildirimi FCM ile gelir.

### Nasıl Çalışır?
```
Kullanıcı A mesaj gönderir
        ↓
Cloud Function tetiklenir
        ↓
Function, Kullanıcı B'nin FCM token'ına bildirim gönderir
        ↓
Kullanıcı B'nin telefonunda bildirim görünür
```

### FCM Token Nedir?
Her cihazın kendine özel bir adresi. Şöyle bir şey:
```
dAelk3m...X9pQ:APA91bH...  (çok uzun bir string)
```

Bu token'ı Firestore'daki kullanıcı dökümanında saklamalısın.

### Takaş'ta Faz 6'da Yapacakların
- Kullanıcı giriş yapınca FCM token'ını Firestore'a kaydet
- Cloud Function: yeni mesaj gelince bildirim gönder
- Cloud Function: yeni teklif gelince bildirim gönder

---

## BÖLÜM 6 — Genel Backend Mantığı

### API Nedir?
Uygulamanın dış dünyayla konuşma şekli.
Firebase bir API'dır — Flutter onunla konuşur.

### Asenkron Programlama (async/await)
Firebase işlemleri zaman alır (internet bağlantısı lazım).
Bu yüzden `async/await` kullanırsın:

```dart
// YANLIŞ — sonucu beklemeden devam eder
final user = firestore.collection('users').doc(id).get();

// DOĞRU — sonucu bekler, sonra devam eder
final user = await firestore.collection('users').doc(id).get();
```

### Stream vs Future

```dart
// Future: Bir kez veri getirir, biter
Future<UserModel> getUser(String id) async {
  final doc = await firestore.collection('users').doc(id).get();
  return UserModel.fromJson(doc.data()!);
}

// Stream: Sürekli dinler, değişince bildirir
Stream<UserModel> watchUser(String id) {
  return firestore.collection('users').doc(id).snapshots()
    .map((doc) => UserModel.fromJson(doc.data()!));
}
```

**Takaş'ta kural:**
- İlan listesi → `Stream` (gerçek zamanlı)
- Kullanıcı profili → `Future` (bir kez)
- Chat → Stream Chat SDK halleder

---

## BÖLÜM 7 — Öğrenme Yol Haritası

### Seviye 1 — Şu An (Faz 1-2)
- [ ] Firebase konsolunu rahatça gezip anlıyorum
- [ ] Firestore'da döküman oluşturup okuyabiliyorum
- [ ] Storage'a dosya yükleyip URL alabiliyor musun
- [ ] Auth ile kullanıcı oluşturup giriş yaptırabiliyorum

### Seviye 2 — Orta (Faz 3-4)
- [ ] Geohash mantığını anlıyorum
- [ ] Stream vs Future farkını biliyorum
- [ ] Cloud Functions yazmayı anlıyorum
- [ ] Stream Chat SDK'yı entegre edebildim

### Seviye 3 — İleri (Faz 5-7)
- [ ] Firestore güvenlik kuralları yazabiliyorum
- [ ] Cloud Functions deploy edebiliyorum
- [ ] FCM ile bildirim gönderebiliyorum
- [ ] Firebase Analytics'i okuyabiliyorum

---

## Pratik Öğrenme Yöntemi

### Her Faz Sonrası Yap
1. Firebase konsolunu aç
2. O fazda oluşturduğun verileri konsolda bul
3. Bir veriyi elle değiştir, uygulamayı gözlemle
4. Ne değişti, neden değişti — not al

### Soru Sormayı Öğren
Yapay zekaya şöyle sorular sor:
```
"Firestore'da şu kodu yazdım: [kod]
Bu kod ne yapıyor? Neden bu şekilde yazdık?
Başka nasıl yazılabilirdi?"
```

Kodu körü körüne kopyalama. Her satırı anlamaya çalış.

### Hata Aldığında
```
1. Hata mesajını tam oku (genelde cevap içinde)
2. Firebase konsolunu aç, Logs sekmesine bak
3. Sonra yapay zekaya hata mesajını yapıştır
```

---

## Firebase Konsol Kısayolları

| Ne Yapmak İstiyorum | Nereye Gideyim |
|---|---|
| Kullanıcıları görmek | Authentication → Users |
| Verileri görmek/değiştirmek | Firestore → Data |
| Fotoğrafları görmek | Storage → Files |
| Sunucu kodlarını görmek | Functions → Dashboard |
| Hataları görmek | Functions → Logs |
| Bildirimleri görmek | Messaging |
| Uygulama çökmelerini görmek | Crashlytics |
| Kullanım istatistikleri | Analytics |

---

## Önemli Hatırlatmalar

> **Güvenlik Kuralları:** Şu an "test mode"dasın, herkes veritabanına yazabilir.
> Bu sadece geliştirme için kabul edilebilir. Faz 7'de mutlaka güvenlik kuralları yaz.

> **Maliyet:** Firebase ücretsiz limitleri geliştirme için fazlasıyla yeterli.
> Aylık $5 bütçe alarmı kurduğundan emin ol.

> **Yedekleme:** Firestore otomatik yedek almaz (ücretsiz planda).
> Kritik veriler için export almayı unutma.
