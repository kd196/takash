# 02 — Proje Mimarisi: Clean Architecture ve Takaş'ın Yapısı

---

## İçindekiler

1. [Yazılım Mimarisi Nedir?](#1-yazılım-mimarisi-nedir)
2. [Clean Architecture Nedir?](#2-clean-architecture-nedir)
3. [Takaş'ta Uygulanan Mimari](#3-takaşta-uygulanan-mimari)
4. [Klasör Yapısı Turu](#4-klasör-yapısı-turu)
5. [pubspec.yaml Dosyası](#5-pubspecyaml-dosyası)
6. [.env Dosyası ve Gizli Anahtarlar](#6-env-dosyası-ve-gizli-anahtarlar)

---

## 1. Yazılım Mimarisi Nedir?

### 1.1 Neden Düzenli Kod Yazmalıyız?

Bir uygulama düşünelim. Bu uygulamanın içinde kullanıcılar kayıt olur, giriş yapar, fotoğraf yükler, mesajlaşır, haritada konum görür ve bildirim alır. Bunların hepsini tek bir dosyanın içine yazdığınızı hayal edin. Başlangıçta her şey çalışır gibi görünür. Ama proje büyüdükçe şu sorunlarla karşılaşırsınız:

- **Bir şeyi değiştirdiğinizde başka bir yer bozulur.** Mesajlaşma koduna dokundunuz, harita özelliği çalışmamaya başladı.
- **Aynı kodu defalarca yazarsınız.** "Kullanıcı adını al" kodunu 15 farklı yere kopyalamış olursunuz.
- **Hata bulmak imkansızlaşır.** "Bu hata nereden geliyor?" diye saatlerce ararsınız.
- **Yeni bir geliştirici ekibe katıldığında hiçbir şey anlamaz.** 5000 satırlık bir dosyanın içinde kaybolur.

İşte **yazılım mimarisi**, bu sorunları önlemek için vardır. Yazılım mimarisi, kodunuzu mantıksal parçalara bölmek, her parçaya net bir sorumluluk vermek ve bu parçaların birbiriyle nasıl konuşacağını belirlemektir.

Bunu günlük hayata benzetelim:

Bir hastane düşünelim. Hastanede acil serviste doktorlar vardır, ameliyathane vardır, eczane vardır, laboratuvar vardır, idari ofis vardır. Her birimin kendi görevi vardır:

- **Acil servis:** Hastaları ilk karşılar, durumu değerlendirir.
- **Laboratuvar:** Kan tahlili yapar, sonuçları raporlar.
- **Eczane:** İlaçları hazırlar ve dağıtır.
- **İdari ofis:** Randevuları, faturaları yönetir.

Hiçbir birim diğerinin işini yapmaz. Laboratuvar ameliyat yapmaz. Eczane kan tahlili yapmaz. Ama aralarında iletişim vardır: Acil servis laboratuvara kan tahlili gönderir, sonuçları alır. Doktor eczaneye reçete yollar.

Yazılım mimarisi de böyledir: Kodunuzu, her biri tek bir işten sorumlu olan birimlere bölersiniz.

### 1.2 Spaghetti Code (Makarna Kod) Nedir?

"Spaghetti code", organize edilmemiş, düzensiz, iç içe geçmiş koda verilen isimdir. Tıpkı bir tabak makarna gibi — ipler birbirine dolanmıştır, bir ucu çektiğinizde nereye gideceğini bilemezsiniz.

Spaghetti code'un özellikleri:

- **Hiçbir ayrım yoktur.** Veritabanı kodu, arayüz kodu, iş mantığı kodu hepsi aynı dosyanın içindedir.
- **Her şey her şeyi bilir.** Butona tıklandığında çağrılan fonksiyon, doğrudan veritabanına SQL sorgusu yazar. Veritabanı yapısı değiştiğinde butonun kodunu değiştirmeniz gerekir.
- **Tekrar eden kod her yerdedir.** Aynı "tarih formatla" kodu 20 farklı yerde kopyalanmıştır.
- **Test yazılamaz.** Her şey birbirine bağlı olduğu için bir parçayı yalıtıp test edemezsiniz.

Örnek bir spaghetti code (Takaş'ta nasıl OLMAZ):

```dart
// KÖTÜ ÖRNEK — Asla böyle yazmayın!
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        // Firebase'e doğrudan bağlanıyor
        final credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        
        // Firestore'a doğrudan sorgu atılıyor
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user!.uid)
            .get();
        
        // İş mantığı UI'ın içinde
        if (doc.exists) {
          if (doc.data()!['rating'] > 4.0) {
            Navigator.push(context, 
              MaterialPageRoute(builder: (_) => PremiumHomeScreen()));
          } else {
            Navigator.push(context, 
              MaterialPageRoute(builder: (_) => NormalHomeScreen()));
          }
        }
      },
      child: Text('Giriş Yap'),
    );
  }
}
```

Bu yaklaşım neden kötü?

1. UI (ekran) kodu, doğrudan Firebase'e bağlı. Firebase'den başka bir veritabanına geçmek isterseniz tüm ekranları yeniden yazarsınız.
2. İş mantığı ("rating > 4.0") ekranın içinde. Bu kurallar değiştiğinde 10 farklı ekranı güncellemeniz gerekir.
3. Test edilemez. Ekranı açmadan bu kodu test edemezsiniz.
4. Navigasyon (sayfa geçişi) doğrudan yazılmış. Yeni bir sayfa eklemek büyük düzenleme gerektirir.

### 1.3 İyi Mimarinin Sağladığı Faydalar

Takaş'ta uyguladığımız mimarinin bize sağladığı faydalar:

| Fayda | Açıklama |
|---|---|
| **Bakım kolaylığı** | Mesajlaşma modülünde bir hata varsa, sadece `features/chat/` klasörüne bakarsınız. |
| **Yeniden kullanılabilirlik** | `CustomButton` bileşenini bir kez yazdık, 30 farklı ekranda kullanıyoruz. |
| **Test edilebilirlik** | Repository'yi test ederken Firebase'e gerçekten bağlanmanıza gerek yok, sahte (mock) veri kullanabilirsiniz. |
| **Ekip çalışması** | Bir geliştirici chat özelliği üstündeyken, diğeri listings üstünde çalışabilir. Dosyalar çakışmaz. |
| **Ölçeklenebilirlik** | Yeni bir özellik (örneğin "değerlendirmeler") eklemek isterseniz, yeni bir `features/rating/` klasörü açarsınız, mevcut koda dokunmazsınız. |

---

## 2. Clean Architecture Nedir?

### 2.1 Robert C. Martin ve Temel Prensip

Clean Architecture, 2012 yılında **Robert C. Martin** (namıdiğer "Uncle Bob") tarafından tanımlanmış bir yazılım mimari yaklaşımıdır. Uncle Bob, 40 yılı aşkın yazılım deneyimiyle, iyi yazılımın değişen teknolojilere karşı dayanıklı olması gerektiğini savunur.

Temel fikir çok basittir:

> **İş mantığınız (business logic), kullandığınız framework'lere, veritabanlarına veya dış servislere BAĞLI OLMAMALIDIR.**

Bunu bir soğan benzetmesiyle açıklar. Soğanın merkezinde en önemli şey vardır (iş mantığı). Dış katmanlara doğru gittikçe daha az önemli şeyler gelir (framework'ler, veritabanları, arayüz). **İç katman, dış katmanı bilir ama dış katman iç katmanı bilmez.** Yani:

- İş mantığı, Firebase kullandığınızı bilmez. Yarın Firebase yerine başka bir veritabanına geçseniz bile iş mantığı değişmez.
- Ekranlar (UI), iş mantığını bilir ama veritabanını bilmez.
- Veritabanı kodu, iş mantığını bilir ama ekranları bilmez.

### 2.2 Clean Architecture'ın Katmanları

Clean Architecture, temel olarak 3 katman tanımlar:

```
┌──────────────────────────────────────────────────┐
│              PRESENTATION (Sunum Katmanı)          │
│         Kullanıcının gördüğü, etkileşime girdiği  │
│         şeyler: Ekranlar, butonlar, formlar       │
│                                                    │
│   ┌────────────────────────────────────────────┐   │
│   │          DOMAIN (İş Mantığı Katmanı)        │   │
│   │    Uygulamanın kalbi: Modeller, kurallar,   │   │
│   │    entity'ler. Hiçbir dış sisteme bağlı değil│   │
│   │                                              │   │
│   │   ┌────────────────────────────────────┐     │   │
│   │   │     DATA (Veri Katmanı)             │     │   │
│   │   │   Dış sistemlerle iletişim:         │     │   │
│   │   │   Firebase, API, cihaz sensörleri   │     │   │
│   │   └────────────────────────────────────┘     │   │
│   └────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────┘
```

Her katmanın sorumluluğu:

| Katman | Sorumluluk | Ne bilir? | Ne bilmez? |
|---|---|---|---|
| **Presentation** | Ekranları çizmek, kullanıcı etkileşimini yönetmek | Domain katmanını | Data katmanını, Firebase'i |
| **Domain** | Veri yapılarını tanımlamak, iş kurallarını tutmak | Kendi veri modellerini | Firebase'i, UI'ı, http kütüphanesini |
| **Data** | Veriyi dış dünyadan almak/kaydetmek | Domain modellerini, Firebase'i | Ekranları, UI'ı |

### 2.3 Bağımlılık Kuralı (Dependency Rule)

Clean Architecture'ın en kritik kuralı:

> **Bağımlılık her zaman içe doğrudur. Dış katman → iç katman. Asla tersi olmaz.**

Bu ne demek?

- **Presentation katmanı**, Domain katmanını kullanabilir (içe doğru).
- **Presentation katmanı**, Data katmanını DOĞRUDAN kullanamaz (dışa doğru yasak).
- **Data katmanı**, Domain katmanını kullanabilir (içe doğru).
- **Domain katmanı**, Presentation veya Data katmanını ASLA kullanamaz.

Takaş'ta bunu şu şekilde uyguluyoruz:

```
Ekran (LoginScreen)
    ↓ çağırır
Controller (AuthController)
    ↓ çağırır
Repository (AuthRepository)
    ↓ çağırır
Firebase (FirebaseAuth, FirebaseFirestore)
```

Akış yukarıdan aşağı doğrudur. Ekran Firebase'in varlığından haberdar değildir. Sadece Controller'ı çağırır. Controller da Repository'yi çağırır. Repository Firebase ile konuşur.

---

## 3. Takaş'ta Uygulanan Mimari

### 3.1 Genel Bakış

Takaş projesinde Clean Architecture'ın her feature (özellik) için 3 katmanlı yapısını uyguluyoruz. Takaş'ın 7 ana özelliği (feature) var:

| Feature | Açıklama |
|---|---|
| `auth` | Kullanıcı kaydı, giriş, Google ile giriş |
| `listings` | İlan oluşturma, listeleme, arama, favoriler |
| `map` | Harita görüntüsü, konum bazlı ilan filtreleme |
| `chat` | Kullanıcılar arası mesajlaşma |
| `profile` | Profil düzenleme, ayarlar, puanlama |
| `notifications` | Bildirim alma, okuma, silme |
| `onboarding` | İlk kullanım rehberi |

Her feature'ın içinde 3 klasör bulunur:

```
features/
├── auth/
│   ├── data/           ← Firebase ile konuşan katman
│   ├── domain/         ← Veri modelleri (UserModel)
│   └── presentation/   ← Ekranlar + Controller'lar
├── listings/
│   ├── data/
│   ├── domain/
│   └── presentation/
├── chat/
│   ├── data/
│   ├── domain/
│   └── presentation/
└── ... (diğer feature'lar aynı yapıda)
```

### 3.2 data/ Katmanı — Dış Dünyayla İletişim

**Sorumluluk:** Veriyi dış kaynaklardan (Firebase, API, cihaz sensörleri) almak ve kaydetmek.

Data katmanı, uygulamanızın dış dünyayla konuştuğu tek yerdir. Burada:

- Firebase Authentication ile kullanıcı girişi yapılır
- Cloud Firestore'a veri yazılır ve oradan okunur
- Firebase Storage'a fotoğraf yüklenir
- Cihazın GPS'inden konum alınır
- Bildirim servisine bağlanılır

Takaş'taki data katmanı dosyaları:

| Dosya | Açıklama |
|---|---|
| `auth/data/auth_repository.dart` | Kullanıcı giriş/kayıt işlemleri |
| `listings/data/listing_repository.dart` | İlan CRUD işlemleri ve favoriler |
| `chat/data/chat_repository.dart` | Sohbet ve mesaj işlemleri |
| `map/data/location_service.dart` | GPS konum alma |
| `notifications/data/notification_service.dart` | Bildirim servisi |
| `profile/data/profile_repository.dart` | Profil güncelleme |
| `profile/data/rating_repository.dart` | Kullanıcı puanlama |

Repository, Türkçe'de "depo" veya "saklayıcı" demektir. Yazılımda ise **veriye erişmek için kullandığımız bir arayüzdür**. Repository'nin amacı, verinin nereden geldiğini (Firebase mi? localStorage mı? bir API mi?) gizlemektir.

**Örnek:** `auth_repository.dart` dosyasının tam içeriği ve satır satır açıklaması:

```dart
// auth_repository.dart — Satır 1-146
import 'dart:developer' as developer;           // 1: Hata ayıklama loglaması için
import 'package:cloud_firestore/cloud_firestore.dart'; // 2: Firestore veritabanı
import 'package:flutter/services.dart';          // 3: Platform hataları için
import 'package:firebase_auth/firebase_auth.dart'; // 4: Firebase kimlik doğrulama
import 'package:google_sign_in/google_sign_in.dart'; // 5: Google ile giriş
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 6: State yönetimi
import '../domain/user_model.dart';              // 7: Kullanıcı veri modeli (domain katmanı)
import '../../../core/providers.dart';           // 8: Merkezi Firebase provider'ları

// 9-15: Riverpod provider — AuthRepository'nin bir örneğini oluşturur
// ref.watch(firebaseAuthProvider) → FirebaseAuth instance'ını verir
// ref.watch(firestoreProvider) → FirebaseFirestore instance'ını verir
// Böylece repository Firebase instance'larını dışarıdan alır (dependency injection)
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    auth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
  );
});

// 17-25: AuthRepository sınıfı — Kullanıcı kimlik işlemlerinin tümü burada
class AuthRepository {
  final FirebaseAuth _auth;       // Firebase Authentication referansı
  final FirebaseFirestore _firestore; // Firestore veritabanı referansı

  // Constructor — FirebaseAuth ve FirebaseFirestore dışarıdan verilir
  // Bu sayede test ederken sahte (mock) versiyonlar verebiliriz
  AuthRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;

  // 27: Kullanıcı oturum durumunu dinleyen stream
  // Kullanıcı giriş yapınca User, çıkış yapınca null döner
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 29: Şu an oturum açmış kullanıcıyı döner (null olabilir)
  User? get currentUser => _auth.currentUser;

  // 31-51: E-posta + şifre ile giriş yapma fonksiyonu
  Future<UserCredential> signInWithEmail(String email, String password) async {
    // Firebase Authentication'a giriş isteği gönder
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Kullanıcı Firestore'da kayıtlı mı kontrol et
    // İlk kez giriş yapıyorsa profil oluştur
    if (credential.user != null) {
      final doc =
          await _firestore.collection('users').doc(credential.user!.uid).get();

      if (!doc.exists) {
        // Firestore'da kullanıcı yoksa oluştur
        // displayName olarak e-postanın @ öncesini kullan
        await _saveUserToFirestore(
          credential.user!,
          credential.user!.displayName ?? email.split('@').first,
        );
      }
    }

    return credential; // Giriş bilgilerini döndür
  }

  // 53-68: E-posta + şifre ile kayıt olma fonksiyonu
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    // Firebase'de yeni hesap oluştur
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Firestore'da kullanıcı profilini oluştur
    if (credential.user != null) {
      await _saveUserToFirestore(credential.user!, displayName);
    }

    return credential;
  }

  // 70-112: Google hesabı ile giriş yapma fonksiyonu
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Google hesap seçme ekranını aç
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null; // Kullanıcı iptal etti

      // Google'dan kimlik doğrulama token'larını al
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw Exception('idToken null');
      }

      // Google token'larını Firebase credential'a çevir
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase ile Google hesabını bağla
      final userCredential = await _auth.signInWithCredential(credential);

      // Firestore'da profil var mı kontrol et, yoksa oluştur
      if (userCredential.user != null) {
        final doc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (!doc.exists) {
          await _saveUserToFirestore(
            userCredential.user!,
            userCredential.user!.displayName ?? 'Kullanıcı',
          );
        }
      }

      return userCredential;
    } catch (e, stack) {
      developer.log('=== GOOGLE SIGN-IN ERROR ===');
      developer.log('Error: $e');
      developer.log('Stack: $stack');
      rethrow; // Hatayı yukarı fırlat, controller yakalasın
    }
  }

  // 114-117: Çıkış yapma
  Future<void> signOut() async {
    await GoogleSignIn().signOut();  // Google oturumunu kapat
    await _auth.signOut();           // Firebase oturumunu kapat
  }

  // 119-137: Firestore'a kullanıcı kaydetme (özel fonksiyon)
  Future<void> _saveUserToFirestore(User user, String displayName) async {
    final Map<String, dynamic> data = {
      'uid': user.uid,                          // Kullanıcı ID
      'displayName': displayName,               // Görünen isim
      'email': user.email ?? '',                 // E-posta
      'photoUrl': user.photoURL,                 // Profil fotoğrafı URL
      'createdAt': FieldValue.serverTimestamp(), // Sunucu zamanı
    };

    final userRef = _firestore.collection('users').doc(user.uid);
    final doc = await userRef.get();

    // Sadece ilk kayıtta totalImageCount = 0 olsun
    if (!doc.exists) {
      data['totalImageCount'] = 0;
    }

    // set + merge: Belge varsa güncelle, yoksa oluştur
    await userRef.set(data, SetOptions(merge: true));
  }

  // 139-145: Belirli bir kullanıcının verisini getirme
  Future<UserModel?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromJson(doc.data()!); // Firestore'dan modele dönüştür
    }
    return null;
  }
}
```

**Neden Repository Pattern kullanıyoruz?**

Repository'nin en büyük avantajı **soyutlamadır** (abstraction). Controller şunu bilir:

> "Ben `signInWithEmail` fonksiyonunu çağıracağım, bana `UserCredential` dönecek."

Controller, arka planda Firebase mi kullanılıyor, bir REST API mi, yoksa yerel bir dosya mı bilmez. Bu sayede:

1. **Firebase'den başka bir şeye geçmek kolaylaşır.** Yarın Supabase'e geçmek isterseniz, sadece Repository'yi değiştirirsiniz. Controller ve ekranlar dokunulmaz.
2. **Test yazmak kolaylaşır.** Test ortamında sahte bir Repository oluşturursunuz. Gerçek Firebase'e bağlanmaya gerek kalmaz.
3. **Kod tekrarı azalır.** "Kullanıcı getir" kodu tek bir yerdedir (Repository'de), 10 farklı ekrandan burası çağrılır.

### 3.3 domain/ Katmanı — Veri Yapıları ve İş Kuralları

**Sorumluluk:** Uygulamanın kalbini oluşturan veri yapılarını (modeller) ve iş kurallarını tanımlamak.

Domain katmanı, **hiçbir dış sisteme bağımlı olmayan** en saf katmandır. Firebase'i bilmez, UI'ı bilmez, internet bağlantısını bilmez. Sadece "bir kullanıcı nasıldır?", "bir ilan nasıldır?", "bir mesaj nasıldır?" sorularına cevap verir.

Domain katmanı dosyaları:

| Dosya | Açıklama |
|---|---|
| `auth/domain/user_model.dart` | Kullanıcı veri yapısı |
| `listings/domain/listing_model.dart` | İlan veri yapısı |
| `listings/domain/listing_category.dart` | Kategori ve durum tanımları |
| `chat/domain/chat_model.dart` | Sohbet odası veri yapısı |
| `chat/domain/message_model.dart` | Mesaj veri yapısı |
| `map/domain/geo_point_model.dart` | Konum veri yapısı |
| `notifications/domain/notification_model.dart` | Bildirim veri yapısı |
| `profile/domain/rating_model.dart` | Değerlendirme veri yapısı |

**Örnek:** `user_model.dart` — Kullanıcı veri modeli

```dart
// user_model.dart — Satır 1-77
import 'package:cloud_firestore/cloud_firestore.dart';

/// UserModel — Bir kullanıcının tüm bilgilerini tutan veri yapısı
/// Bu sınıf, Firestore'dan gelen ham veriyi (Map) Dart nesnesine dönüştürür
/// ve Dart nesnesini tekrar Firestore'a gönderilecek ham veriye çevirir.
class UserModel {
  final String uid;           // Firebase Authentication kullanıcı ID'si (benzersiz)
  final String displayName;   // Kullanıcının görünen adı ("Ahmet Yılmaz")
  final String email;         // Kullanıcının e-posta adresi
  final String? photoUrl;     // Profil fotoğrafı URL'si (null olabilir = fotoğraf yok)
  final String? bio;          // Kullanıcının kendini tanıttığı yazı (null olabilir)
  final double rating;        // Ortalama puanı (0.0 - 5.0 arası)
  final int ratingCount;      // Kaç kişinin puan verdiği
  final DateTime createdAt;   // Hesabın oluşturulma tarihi
  final int totalImageCount;  // Sohbette gönderdiği toplam resim sayısı

  // Constructor — Yeni bir UserModel nesnesi oluşturur
  // required olan alanlar zorunludur, diğerleri varsayılan değere sahiptir
  UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.bio,
    this.rating = 0.0,       // Varsayılan: 0 puan
    this.ratingCount = 0,    // Varsayılan: 0 değerlendirme
    required this.createdAt,
    this.totalImageCount = 0, // Varsayılan: 0 resim
  });

  // fromJson — Firestore'dan gelen Map verisini UserModel'e dönüştürür
  // Firestore'dan veri geldiğinde bu fonksiyon çağrılır
  // "fromJson" ismi gelenekseldir; aslında Map<String, dynamic> → UserModel dönüşümü yapar
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',                    // Yoksa boş string
      displayName: json['displayName'] ?? '',
      email: json['email'] ?? '',
      photoUrl: json['photoUrl'],                // Null kalabilir
      bio: json['bio'],                          // Null kalabilir
      rating: (json['rating'] ?? 0.0).toDouble(), // Sayıyı double'a çevir
      ratingCount: json['ratingCount'] ?? 0,
      createdAt: (json['createdAt'] as Timestamp).toDate(), // Firestore Timestamp → DateTime
      totalImageCount: json['totalImageCount'] ?? 0,
    );
  }

  // toJson — UserModel nesnesini Firestore'a kaydedilecek Map'e dönüştürür
  // DİKKAT: totalImageCount burada YOK!
  // Neden? Çünkü bu alan sadece repository tarafından yönetilir
  // Yanlışlıkla 0 olarak üzerine yazılmasını önlemek için hariç tutuldu
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'bio': bio,
      'rating': rating,
      'ratingCount': ratingCount,
      'createdAt': Timestamp.fromDate(createdAt),
      // totalImageCount buraya eklenmiyor!
    };
  }

  // copyWith — Mevcut nesnenin kopyasını belirli alanları değiştirerek oluşturur
  // Orijinal nesneyi değiştirmez, yeni bir nesne döner (immutable pattern)
  // Kullanım: final updated = user.copyWith(displayName: "Yeni İsim");
  UserModel copyWith({
    String? displayName,
    String? photoUrl,
    String? bio,
    double? rating,
    int? ratingCount,
    int? totalImageCount,
  }) {
    return UserModel(
      uid: uid,                                // uid değişmez
      displayName: displayName ?? this.displayName, // Yeni değer verilmişse onu kullan
      email: email,                             // email değişmez
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      createdAt: createdAt,                     // createdAt değişmez
      totalImageCount: totalImageCount ?? this.totalImageCount,
    );
  }
}
```

**Model neden önemli?**

Firestores'dan veri şu formatta gelir:

```dart
{
  'uid': 'abc123',
  'displayName': 'Ahmet',
  'email': 'ahmet@email.com',
  'rating': 4.5,
  'ratingCount': 12,
  'createdAt': Timestamp(seconds=1234567890),
}
```

Bu ham veriyle çalışmak tehlikelidir:

- `json['uid']` yazarken typo yapabilirsiniz (`json['uidd']` yazarsanız null alırsınız, hata almassınız ama uygulama yanlış çalışır).
- `json['rating']` bir `int` mi `double` mı bilemezsiniz.
- Timestamp'i DateTime'a dönüştürmeyi unutabilirsiniz.

Model sınıfı bu sorunları çözer. Bir kez `UserModel` tanımlarsınız, sonra her yerde güvenle kullanırsınız:

```dart
// Model kullanımı:
final user = UserModel.fromJson(firestoreData);
print(user.displayName);  // Tip güvenli, hata yapma ihtimali yok
print(user.rating);        // Kesinlikle double
```

**Örnek:** `listing_model.dart` — İlan veri modeli

```dart
// listing_model.dart — Satır 1-100
import 'package:cloud_firestore/cloud_firestore.dart';
import 'listing_category.dart';

/// ListingModel — Bir takas ilanının tüm bilgilerini tutan veri yapısı
class ListingModel {
  final String id;                // İlanın benzersiz ID'si (UUID)
  final String ownerId;           // İlanı oluşturan kullanıcının ID'si
  final String title;             // İlan başlığı ("iPhone 13 Takas")
  final String description;       // Detaylı açıklama
  final ListingCategory category; // Kategori (enum: electronics, clothing...)
  final List<String> imageUrls;   // Fotoğraf URL'leri listesi
  final String wantedItem;        // "Karşılığında ne istiyorum"
  final GeoPoint? location;       // Konum koordinatları (enlem/boylam)
  final String? geohash;          // Konum bazlı arama için hash kodu
  final ListingStatus status;     // Aktif, Rezerve, Tamamlandı
  final DateTime createdAt;       // Oluşturulma tarihi

  ListingModel({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrls,
    required this.wantedItem,
    this.location,
    this.geohash,
    this.status = ListingStatus.active,  // Varsayılan: aktif
    required this.createdAt,
  });

  // toJson — Modeli Firestore'a kaydedilecek Map'e çevirir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'category': category.name,       // Enum → string ("electronics")
      'imageUrls': imageUrls,
      'wantedItem': wantedItem,
      'location': location,
      'geohash': geohash,
      'status': status.name,           // Enum → string ("active")
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // fromJson — Firestore verisini ListingModel'e dönüştürür
  factory ListingModel.fromJson(Map<String, dynamic> json) {
    return ListingModel(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: ListingCategory.values.firstWhere(
        (e) => e.name == json['category'],  // String → enum
        orElse: () => ListingCategory.other, // Bilinmeyen kategori = "Diğer"
      ),
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      wantedItem: json['wantedItem'] as String? ?? '',
      location: json['location'] as GeoPoint?,
      geohash: json['geohash'] as String?,
      status: ListingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ListingStatus.active,
      ),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  // copyWith — Nesnenin değiştirilmiş bir kopyasını oluşturur
  ListingModel copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? description,
    ListingCategory? category,
    List<String>? imageUrls,
    String? wantedItem,
    GeoPoint? location,
    String? geohash,
    ListingStatus? status,
    DateTime? createdAt,
  }) {
    return ListingModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      imageUrls: imageUrls ?? this.imageUrls,
      wantedItem: wantedItem ?? this.wantedItem,
      location: location ?? this.location,
      geohash: geohash ?? this.geohash,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
```

**Örnek:** `listing_category.dart` — Enum tanımları

```dart
// listing_category.dart — Satır 1-73

/// İlan kategorileri — Bir ilan hangi kategoriye ait olabilir?
/// enum = numaralandırma: Sabit bir değerler listesidir
/// Kullanıcı serbest metin girmez, listeden seçer
enum ListingCategory {
  electronics,  // Elektronik
  clothing,     // Giyim
  books,        // Kitap
  furniture,    // Mobilya
  sports,       // Spor
  toys,         // Oyuncak
  other,        // Diğer
}

// Extension — Enum değerlerine ek özellikler kazandırır
// Dart'ta enum'lar sadece isim taşır. Extension ile Türkçe etiket ve ikon ekliyoruz
extension ListingCategoryExtension on ListingCategory {
  // Kategori adının Türkçe karşılığı
  String get label {
    switch (this) {
      case ListingCategory.electronics: return 'Elektronik';
      case ListingCategory.clothing:    return 'Giyim';
      case ListingCategory.books:       return 'Kitap';
      case ListingCategory.furniture:   return 'Mobilya';
      case ListingCategory.sports:      return 'Spor';
      case ListingCategory.toys:        return 'Oyuncak';
      case ListingCategory.other:       return 'Diğer';
    }
  }

  // Kategori ikonu (emoji)
  String get icon {
    switch (this) {
      case ListingCategory.electronics: return '📱';
      case ListingCategory.clothing:    return '👕';
      case ListingCategory.books:       return '📚';
      case ListingCategory.furniture:   return '🪑';
      case ListingCategory.sports:      return '⚽';
      case ListingCategory.toys:        return '🧸';
      case ListingCategory.other:       return '📦';
    }
  }
}

/// İlan durumu — Bir ilan hangi aşamada olabilir?
enum ListingStatus {
  active,     // Aktif — Herkes görebilir, teklif alabilir
  reserved,   // Rezerve — Birisi ile anlaşıldı, başka teklif almaz
  completed,  // Tamamlandı — Takas gerçekleşti
}

extension ListingStatusExtension on ListingStatus {
  String get label {
    switch (this) {
      case ListingStatus.active:     return 'Aktif';
      case ListingStatus.reserved:   return 'Rezerve';
      case ListingStatus.completed:  return 'Tamamlandı';
    }
  }
}
```

### 3.4 presentation/ Katmanı — UI ve State Yönetimi

**Sorumluluk:** Kullanıcının gördüğü ekranları çizmek, kullanıcı etkileşimini yakalamak ve state'i (uygulamanın o anki durumunu) yönetmek.

Presentation katmanı iki parçadan oluşur:

1. **Screens (Ekranlar):** Kullanıcının gördüğü arayüz. Örneğin `login_screen.dart`, `home_screen.dart`.
2. **Controllers (Denetleyiciler):** Ekran ile Repository arasında köprü kurar. Kullanıcı butona basınca Controller tetiklenir, Controller Repository'yi çağırır, sonuç geldiğinde ekranı günceller.

**Neden Controller'a ihtiyacımız var?**

Ekran (Screen) sadece "görüntü"den sorumludur. Butonun nerede duracağına, rengin ne olacağına, yazı tipinin büyük mü küçük mü olacağına karar verir. Ama "giriş yap" butonuna basıldığında ne olacağını Controller belirler.

Controller'ın görevleri:
- **State yönetimi:** Giriş yapılıyor → loading göster → başarılı → ana sayfaya yönlendir.
- **Hata yönetimi:** Giriş başarısız → hata mesajı göster.
- **Repository ile iletişim:** Repository'deki fonksiyonları çağırır.

Takaş'ta state yönetimi için **Riverpod** kullanıyoruz.

**Örnek:** `auth_controller.dart` — Kimlik denetleyicisi

```dart
// auth_controller.dart — Satır 1-48
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/auth_repository.dart';

part 'auth_controller.g.dart';  // Kod üretici tarafından otomatik oluşturulur

// @riverpod annotation'ı → Riverpod'un kod üreticisine bu sınıfı
// otomatik olarak bir provider'a dönüştürmesini söyler
@riverpod
class AuthController extends _$AuthController {
  // build() → Controller'ın ilk durumu
  // FutureOr<void> = Henüz bir işlem yok, boş başlat
  @override
  FutureOr<void> build() {
    // Initial build
  }

  // E-posta ile giriş
  // state = AsyncLoading → Ekran "yükleniyor" gösterebilir
  // AsyncValue.guard → Hata olursa otomatik yakalar, state'i AsyncError yapar
  // ref.read(authRepositoryProvider) → AuthRepository'ye erişir
  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => 
      ref.read(authRepositoryProvider).signInWithEmail(email, password)
    );
  }

  // E-posta ile kayıt
  Future<void> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => 
      ref.read(authRepositoryProvider).registerWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      )
    );
  }

  // Google ile giriş
  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => 
      ref.read(authRepositoryProvider).signInWithGoogle()
    );
  }

  // Çıkış
  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => 
      ref.read(authRepositoryProvider).signOut()
    );
  }
}
```

**State nedir? "AsyncLoading", "AsyncValue.guard" ne demek?**

State, uygulamanın o anki durumudur. Giriş ekranında 3 durum olabilir:

1. **Boşta (idle):** Henüz bir işlem yapılmıyor. Form boş, buton aktif.
2. **Yükleniyor (loading):** Kullanıcı "Giriş Yap" butonuna bastı. Sunucuyla iletişim halinde. Buton spinning gösteriyor.
3. **Sonuç (success veya error):** Giriş başarılı oldu veya hata verdi.

Riverpod bu 3 durumu `AsyncValue` ile yönetir:

```
AsyncLoading()  → Yükleniyor
AsyncData(null) → Başarılı (veri var)
AsyncError(...) → Hata oldu
```

`AsyncValue.guard(...)`, try-catch yazmanıza gerek kalmadan hataları otomatik yakalar:

```dart
// AsyncValue.guard olmadan (manuel):
state = const AsyncLoading();
try {
  await ref.read(authRepositoryProvider).signInWithEmail(email, password);
  state = const AsyncData(null);
} catch (e) {
  state = AsyncError(e, StackTrace.current);
}

// AsyncValue.guard ile (otomatik):
state = const AsyncLoading();
state = await AsyncValue.guard(() => 
  ref.read(authRepositoryProvider).signInWithEmail(email, password)
);
```

### 3.5 Neden Bu Ayrım Var? Özet

```
┌─────────────────────────────────────────────────────────────────┐
│                        Takaş Mimarisi                            │
│                                                                  │
│  Kullanıcı butona basar                                          │
│        ↓                                                         │
│  ┌─────────────────┐                                            │
│  │   SCREEN        │  "Giriş Yap" butonuna basıldığında         │
│  │   (login_screen)│   controller.signInWithEmail() çağırır     │
│  └────────┬────────┘                                            │
│           ↓                                                      │
│  ┌─────────────────┐                                            │
│  │   CONTROLLER     │  State'i yönetir (loading/success/error)  │
│  │ (auth_controller)│  Repository'yi çağırır                    │
│  └────────┬────────┘                                            │
│           ↓                                                      │
│  ┌─────────────────┐                                            │
│  │   REPOSITORY     │  Firebase ile konuşur                      │
│  │(auth_repository) │  FirebaseAuth.signInWithEmailAndPassword()│
│  └────────┬────────┘                                            │
│           ↓                                                      │
│  ┌─────────────────┐                                            │
│  │    FIREBASE      │  Google'ın sunucuları                      │
│  └─────────────────┘                                            │
│                                                                  │
│  ←─── VERİ GERİ DÖNER ───→                                      │
│                                                                  │
│  Firebase → Repository → Controller → Screen güncellenir         │
└─────────────────────────────────────────────────────────────────┘
```

Her katmanın tek bir sorumluluğu vardır:

| Katman | Sorumluluk | Firebase bilir mi? | UI bilir mi? |
|---|---|---|---|
| Screen | Ekranı çizmek | HAYIR | EVET (kendi ekranını) |
| Controller | State yönetmek, Repository'yi çağırmak | HAYIR | HAYIR |
| Repository | Firebase ile konuşmak | EVET | HAYIR |
| Model | Veri yapısını tanımlamak | HAYIR | HAYIR |

---

## 4. Klasör Yapısı Turu

### 4.1 Genel Yapı

Takaş projesinin `lib/` klasörü şu şekilde organize edilmiştir:

```
lib/
├── app/                    ← Uygulama genel yapılandırması
│   ├── router.dart         ← Sayfa yönlendirme (go_router)
│   └── theme.dart          ← Açık/Koyu tema tanımları
│
├── core/                   ← Tüm feature'ların kullandığı ortak kod
│   ├── constants/          ← Sabitler (API key'ler, limitler)
│   │   ├── api_keys.dart
│   │   └── app_constants.dart
│   ├── extensions/         ← Dart tipi genişletmeleri
│   │   └── string_extensions.dart
│   ├── providers/          ← Temel provider'lar (tema)
│   │   └── theme_provider.dart
│   ├── providers.dart      ← Merkezi Firebase provider'ları
│   ├── services/           ← Temel servisler (ayarlar)
│   │   └── settings_service.dart
│   └── utils/              ← Yardımcı fonksiyonlar
│       ├── helpers.dart
│       └── validators.dart
│
├── features/               ← Özellik bazlı klasörler (ana iş mantığı)
│   ├── auth/               ← Kimlik doğrulama
│   │   ├── data/
│   │   │   └── auth_repository.dart
│   │   ├── domain/
│   │   │   └── user_model.dart
│   │   └── presentation/
│   │       ├── auth_controller.dart
│   │       ├── login_screen.dart
│   │       └── register_screen.dart
│   ├── chat/
│   │   ├── data/
│   │   │   └── chat_repository.dart
│   │   ├── domain/
│   │   │   ├── chat_model.dart
│   │   │   └── message_model.dart
│   │   └── presentation/
│   │       ├── chat_controller.dart
│   │       ├── chat_list_screen.dart
│   │       └── chat_detail_screen.dart
│   ├── listings/
│   │   ├── data/
│   │   │   └── listing_repository.dart
│   │   ├── domain/
│   │   │   ├── listing_model.dart
│   │   │   └── listing_category.dart
│   │   └── presentation/
│   │       ├── listings_controller.dart
│   │       ├── home_screen.dart
│   │       ├── create_listing_screen.dart
│   │       ├── edit_listing_screen.dart
│   │       ├── listing_detail_screen.dart
│   │       ├── my_listings_screen.dart
│   │       ├── favorites_screen.dart
│   │       └── widgets/
│   │           ├── listing_card.dart
│   │           ├── manage_listing_card.dart
│   │           └── filter_sheet.dart
│   ├── map/
│   │   ├── data/
│   │   │   └── location_service.dart
│   │   ├── domain/
│   │   │   └── geo_point_model.dart
│   │   └── presentation/
│   │       ├── map_controller.dart
│   │       └── map_screen.dart
│   ├── notifications/
│   │   ├── data/
│   │   │   └── notification_service.dart
│   │   ├── domain/
│   │   │   └── notification_model.dart
│   │   └── presentation/
│   │       ├── notification_controller.dart
│   │       └── notification_screen.dart
│   ├── onboarding/
│   │   └── presentation/
│   │       └── onboarding_screen.dart
│   └── profile/
│       ├── data/
│       │   ├── profile_repository.dart
│       │   └── rating_repository.dart
│       ├── domain/
│       │   └── rating_model.dart
│       └── presentation/
│           ├── profile_controller.dart
│           ├── profile_screen.dart
│           ├── public_profile_screen.dart
│           ├── edit_profile_screen.dart
│           ├── settings_screen.dart
│           ├── change_email_screen.dart
│           ├── change_password_screen.dart
│           └── rating_screen.dart
│
├── shared/                 ← Birden çok feature'ın kullandığı paylaşımlı kod
│   ├── models/
│   │   └── base_model.dart
│   ├── services/
│   │   ├── firebase_service.dart
│   │   └── storage_service.dart
│   └── widgets/
│       ├── custom_button.dart
│       ├── custom_text_field.dart
│       ├── loading_indicator.dart
│       ├── error_state_widget.dart
│       └── empty_state_widget.dart
│
├── firebase_options.dart   ← Firebase yapılandırma (otomatik üretildi)
└── main.dart               ← Uygulamanın başlangıç noktası
```

### 4.2 core/ Klasörü — Ortak Kodlar

`core/` klasörü, **tüm feature'ların ihtiyaç duyduğu ortak kodları** barındırır. Her feature'ın kendi içinde sadece o feature'a özel kodlar vardır. Ama tüm feature'ların ortak ihtiyaç duyduğu şeyler `core/`'a konur.

Bunu hastane benzetmesiyle düşünelim: Her servisin (acil, ameliyathane, poliklinik) kendi uzmanları ve araçları vardır. Ama koridorlar, elektrik sistemi, su tesisatı tüm servislere ortaktır. İşte `core/` da uygulamanın "ortak altyapısı"dır.

#### 4.2.1 core/constants/api_keys.dart — API Anahtarları

```dart
// api_keys.dart — Satır 1-12
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// ApiKeys sınıfı — API anahtarlarını .env dosyasından okur
/// Neden ayrı bir sınıf? Çünkü API anahtarlarına ihtiyaç duyan her dosya
/// dotenv.env['MAPBOX_ACCESS_TOKEN'] yazmak yerine ApiKeys.mapboxToken yazabilir
/// Daha temiz, daha güvenli, tek noktadan yönetim
class ApiKeys {
  // static get → Sınıf örneği oluşturmadan erişilebilir
  // ApiKeys.mapboxToken şeklinde kullanılır
  static String get mapboxToken {
    // dotenv.env['MAPBOX_ACCESS_TOKEN'] → .env dosyasındaki değeri okur
    // ?? '' → Değer yoksa boş string döner (null hatası önleme)
    return dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
  }

  static String get streamApiKey {
    return dotenv.env['STREAM_API_KEY'] ?? '';
  }
}
```

#### 4.2.2 core/constants/app_constants.dart — Uygulama Sabitleri

```dart
// app_constants.dart — Satır 1-18

/// AppConstants — Uygulama genelinde kullanılan sabit değerler
/// Neden sabitleri ayrı bir dosyaya koyuyoruz?
/// Çünkü "max fotoğraf 5" kuralı 10 farklı yerde kullanılıyor olabilir
/// Yarın bu limiti 8'e çıkarmak isterseniz, sadece bu dosyayı değiştirirsiniz
/// Her yerde "5" yazmış olsaydınız, 10 farklı dosyayı bulup değiştirmeniz gerekirdi
class AppConstants {
  // static const → Derleme zamanında belirlenen değiştirilemez değerler
  // Bellekte tek kopya tutulur, her erişim aynı değeri verir

  // Geofencing yarıçapları (kilometre cinsinden)
  static const double defaultRadiusKm = 10.0;  // Varsayılan arama yarıçapı
  static const double minRadiusKm = 1.0;       // En küçük yarıçap
  static const double maxRadiusKm = 50.0;      // En büyük yarıçap

  // İlan limitleri
  static const int maxListingImages = 5;        // Bir ilanda en fazla 5 fotoğraf
  static const int maxTitleLength = 100;        // Başlık en fazla 100 karakter
  static const int maxDescriptionLength = 500;  // Açıklama en fazla 500 karakter

  // Pagination (sayfalama) — Bir seferde kaç ilan yüklensin?
  static const int listingsPerPage = 20;

  // Profil fotoğrafı boyutu (byte cinsinden)
  // 5 * 1024 * 1024 = 5 MB (megabayt)
  // 1 KB = 1024 byte, 1 MB = 1024 KB
  static const int maxProfilePhotoSize = 5 * 1024 * 1024; // 5MB
}
```

#### 4.2.3 core/utils/helpers.dart — Yardımcı Fonksiyonlar

```dart
// helpers.dart — Satır 1-53
import 'package:intl/intl.dart';                    // Tarih/sayı formatlama
import 'package:geolocator/geolocator.dart';        // Konum hesaplamaları
import 'package:cloud_firestore/cloud_firestore.dart'; // GeoPoint tipi

/// Helpers — Uygulamanın her yerinden çağrılan yardımcı fonksiyonlar
/// Her fonksiyon static'dir, sınıf örneği oluşturmadan kullanılabilir
class Helpers {

  // İki koordinat arası mesafeyi hesaplar (kilometre cinsinden)
  // p1 = Birinci nokta (ör: kullanıcının konumu)
  // p2 = İkinci nokta (ör: ilanın konumu)
  // Geolocator.distanceBetween → metre cinsinden mesafe verir
  // / 1000 → kilometreye çevirir
  static double calculateDistance(GeoPoint p1, GeoPoint p2) {
    return Geolocator.distanceBetween(
      p1.latitude, p1.longitude,
      p2.latitude, p2.longitude,
    ) / 1000;
  }

  // Zamanı sadece saat:dakika olarak formatlar
  // Örnek: DateTime(2024, 1, 15, 14, 30) → "14:30"
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date); // HH = 24 saat, mm = dakika
  }

  // Tarihi Türkçe olarak formatlar
  // Örnek: DateTime(2024, 1, 15) → "15 Oca 2024"
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'tr_TR').format(date);
    // dd = gün (2 hane), MMM = ay ismi (kısa), yyyy = yıl (4 hane)
    // 'tr_TR' = Türkçe locale (Ocak, Şubat, Mart...)
  }

  // Zaman farkını insan dostu formatta verir
  // Örnek çıktılar: "Az önce", "5 dakika önce", "2 saat önce", "3 gün önce"
  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime); // Farkı hesapla

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} yıl önce';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} ay önce';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} gün önce';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} saat önce';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} dakika önce';
    } else {
      return 'Az önce'; // 1 dakikadan az
    }
  }

  // Mesafeyi insan dostu formatta verir
  // 800 metre → "800 m"
  // 2.5 kilometre → "2.5 km"
  static String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      // 1 km'den küçükse metreye çevir
      return '${(distanceInKm * 1000).round()} m';
    }
    return '${distanceInKm.toStringAsFixed(1)} km'; // 1 ondalık basamak
  }
}
```

#### 4.2.4 core/utils/validators.dart — Form Doğrulama

```dart
// validators.dart — Satır 1-61

/// Validators — Form alanlarını doğrulama (validation) fonksiyonları
/// Her fonksiyon: null dönerse geçerli, String dönerse hata mesajı
/// Flutter'ın TextFormField widget'ı bu formatı bekler
class Validators {

  // E-posta doğrulama
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-posta adresi gerekli';           // Boş bırakılamaz
    }
    // Regex (düzenli ifade) ile e-posta formatı kontrolü
    // ^ = başlangıç, $ = bitiş
    // [a-zA-Z0-9._%+-]+ = kullanıcı adı kısmı (harf, rakam, nokta, vb.)
    // @ = @ işareti zorunlu
    // [a-zA-Z0-9.-]+ = domain adı (gmail, hotmail, vb.)
    // \. = nokta zorunlu
    // [a-zA-Z]{2,}$ = TLD uzantısı (com, org, vb. en az 2 harf)
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Geçerli bir e-posta adresi girin';
    }
    return null; // Geçerli
  }

  // Şifre doğrulama
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre gerekli';
    }
    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalı';  // Firebase'in minimum şartı
    }
    return null;
  }

  // İsim doğrulama
  static String? displayName(String? value) {
    if (value == null || value.isEmpty) {
      return 'İsim gerekli';
    }
    if (value.length < 2) {
      return 'İsim en az 2 karakter olmalı';
    }
    return null;
  }

  // İlan başlığı doğrulama
  static String? listingTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Başlık gerekli';
    }
    if (value.length < 3) {
      return 'Başlık en az 3 karakter olmalı';
    }
    if (value.length > 100) {
      return 'Başlık en fazla 100 karakter olabilir';  // AppConstants.maxTitleLength
    }
    return null;
  }

  // İlan açıklaması doğrulama
  static String? listingDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Açıklama gerekli';
    }
    if (value.length < 10) {
      return 'Açıklama en az 10 karakter olmalı';
    }
    return null;
  }
}
```

#### 4.2.5 core/providers.dart — Merkezi Firebase Provider'ları

```dart
// providers.dart — Satır 1-20
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Provider nedir?
// Provider, uygulamanın her yerinden erişilebilen bir "değer" sağlayıcıdır.
// Bir kez oluşturulur, her yerde aynı instance kullanılır (singleton gibi)

// FirebaseAuth instance'ını sağlayan provider
// Her yerde FirebaseAuth.instance yazmak yerine ref.watch(firebaseAuthProvider) kullanılır
// Test ederken sahte FirebaseAuth verebiliriz
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// FirebaseFirestore instance'ını sağlayan provider
final firestoreProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseFirestore.instance;
});

// FirebaseStorage instance'ını sağlayan provider
final storageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

// Kullanıcı oturum durumunu dinleyen Stream provider
// Kullanıcı giriş yapınca User, çıkış yapınca null yayınlar (emit)
// authStateProvider.value → şu anki oturum durumu
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});
```

Bu dosya neden önemli? Çünkü tüm repository'ler Firebase instance'larını buradan alır:

```dart
// auth_repository.dart içinde:
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    auth: ref.watch(firebaseAuthProvider),      // ← core/providers.dart'tan geliyor
    firestore: ref.watch(firestoreProvider),     // ← core/providers.dart'tan geliyor
  );
});
```

#### 4.2.6 core/providers/theme_provider.dart — Tema Yönetimi

```dart
// theme_provider.dart — Satır 1-30
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/settings_service.dart';

// SettingsService'in bir örneğini sağlayan provider
final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

// Tema modu provider'ı (Açık / Koyu / Sistem)
// StateNotifierProvider: State değiştiğinde dinleyenleri bilgilendirir
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref.read(settingsServiceProvider));
});

// ThemeModeNotifier — Tema modunu yöneten sınıf
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SettingsService _service;

  ThemeModeNotifier(this._service) : super(ThemeMode.system) {
    // Başlangıçta kaydedilmiş tema modunu yükle
    _loadInitialTheme();
  }

  // SharedPreferences'tan kaydedilmiş tema ayarını oku
  Future<void> _loadInitialTheme() async {
    final mode = await _service.getThemeMode();
    state = mode; // State'i güncelle → UI otomatik yenilenir
  }

  // Tema modunu değiştir ve kalıcı olarak kaydet
  Future<void> setThemeMode(ThemeMode mode) async {
    await _service.setThemeMode(mode); // SharedPreferences'a kaydet
    state = mode;                       // State'i güncelle → UI yenilenir
  }
}
```

#### 4.2.7 core/services/settings_service.dart — Ayar Servisi

```dart
// settings_service.dart — Satır 1-64
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

/// SettingsService — Kullanıcı tercihlerini kalıcı olarak saklar
/// SharedPreferences = Android'de SharedPreferences, iOS'ta NSUserDefaults
/// Anahtar-değer (key-value) çiftleri şeklinde basit veri saklar
/// Uygulama kapatılsa bile veriler korunur
class SettingsService {
  // Anahtar isimleri — SharedPreferences'ta veriyi bulmak için kullanılır
  static const _themeModeKey = 'theme_mode';
  static const _notificationsKey = 'notifications_enabled';
  static const _locationSharingKey = 'location_sharing';
  static const _profileVisibilityKey = 'profile_visibility';

  // SharedPreferences instance'ını asenkron olarak al
  // Her fonksiyonda await SharedPreferences.getInstance() yazmamak için
  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // Tema modunu oku
  Future<ThemeMode> getThemeMode() async {
    final prefs = await _prefs;
    final value = prefs.getString(_themeModeKey) ?? 'system'; // Varsayılan: sistem
    switch (value) {
      case 'light': return ThemeMode.light;
      case 'dark':  return ThemeMode.dark;
      default:      return ThemeMode.system;
    }
  }

  // Tema modunu kaydet
  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await _prefs;
    final value = mode == ThemeMode.light
        ? 'light'
        : mode == ThemeMode.dark
            ? 'dark'
            : 'system';
    await prefs.setString(_themeModeKey, value);
  }

  // Bildirimler açık mı?
  Future<bool> getNotificationsEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_notificationsKey) ?? true; // Varsayılan: açık
  }

  Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_notificationsKey, value);
  }

  // Konum paylaşımı açık mı?
  Future<bool> getLocationSharing() async {
    final prefs = await _prefs;
    return prefs.getBool(_locationSharingKey) ?? true;
  }

  Future<void> setLocationSharing(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_locationSharingKey, value);
  }

  // Profil görünürlüğü
  Future<String> getProfileVisibility() async {
    final prefs = await _prefs;
    return prefs.getString(_profileVisibilityKey) ?? 'public'; // Varsayılan: herkese açık
  }

  Future<void> setProfileVisibility(String value) async {
    final prefs = await _prefs;
    await prefs.setString(_profileVisibilityKey, value);
  }
}
```

#### 4.2.8 core/extensions/string_extensions.dart — String Genişletmeleri

```dart
// string_extensions.dart — Satır 1-16

/// Extension — Dart'taki bir tipe yeni fonksiyonlar ekler
/// String tipine .capitalize, .isValidEmail gibi fonksiyonlar kazandırır
/// Kullanım: "merhaba".capitalize → "Merhaba"
extension StringExtensions on String {
  // İlk harfi büyük yap
  String get capitalize {
    if (isEmpty) return this;               // Boş string → değiştirme
    return '${this[0].toUpperCase()}${substring(1)}'; // İlk harf büyük + geri kalanı
  }

  // Geçerli e-posta mı?
  bool get isValidEmail {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(this);
  }

  // Başındaki ve sonundaki boşlukları temizle
  String get trimmed => trim();
}
```

### 4.3 shared/ Klasörü — Yeniden Kullanılabilir Bileşenler

`shared/` klasörü, **birden çok feature tarafından kullanılan paylaşımlı kodları** barındırır. `core/` ile farkı: `core/` altyapısal kodlar (provider'lar, sabitler, yardımcılar) içerirken, `shared/` doğrudan UI bileşenleri ve genel servisler içerir.

#### 4.3.1 shared/widgets/custom_button.dart — Özel Buton

```dart
// custom_button.dart — Satır 1-59
import 'package:flutter/material.dart';

/// CustomButton — Uygulamanın her yerinde kullanılan özelleştirilebilir buton
/// Neden var? Flutter'ın varsayılan ElevatedButton her yerde aynı görünür
/// Ama biz her butonda: yükleme durumu, ikon, outlined modu istiyoruz
/// Bu ortak davranışları tek bir widget'ta topladık
class CustomButton extends StatelessWidget {
  final String text;           // Buton metni ("Giriş Yap", "Kaydet")
  final VoidCallback? onPressed; // Tıklanınca çağrılacak fonksiyon (null = devre dışı)
  final bool isLoading;        // Yükleniyor mu? (true ise spinner göster)
  final bool isOutlined;       // Outlined stil mi? (true = sadece kenarlık)
  final IconData? icon;        // İkon (null = ikon yok)
  final double? width;         // Genişlik (null = tam genişlik)

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    // Butonun içeriğini oluştur
    final buttonChild = isLoading
        ? const SizedBox(
            height: 20, width: 20,
            // Yükleniyor → dönen çember göster
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[  // İkon varsa göster
                Icon(icon, size: 20),
                const SizedBox(width: 8), // İkon ile metin arası boşluk
              ],
              Text(text),             // Buton metni
            ],
          );

    // Outlined mı yoksa dolu buton mu?
    if (isOutlined) {
      return SizedBox(
        width: width ?? double.infinity, // null ise tam genişlik
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed, // Yükleniyorsa tıklanamaz
          child: buttonChild,
        ),
      );
    }

    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: buttonChild,
      ),
    );
  }
}
```

**Kullanım örnekleri:**

```dart
// Basit buton:
CustomButton(text: 'Giriş Yap', onPressed: () => ...)

// Yükleniyor butonu:
CustomButton(text: 'Giriş Yap', isLoading: true)

// İkonlu buton:
CustomButton(text: 'Google ile Giriş', icon: Icons.g_mobiledata, onPressed: () => ...)

// Outlined buton:
CustomButton(text: 'Vazgeç', isOutlined: true, onPressed: () => ...)
```

#### 4.3.2 shared/widgets/loading_indicator.dart — Yükleme Göstergesi

```dart
// loading_indicator.dart — Satır 1-31
import 'package:flutter/material.dart';

/// LoadingIndicator — Veri yüklenirken gösterilen merkezi dönen çember
/// Opsiyonel olarak bir mesaj gösterir ("İlanlar yükleniyor...")
class LoadingIndicator extends StatelessWidget {
  final String? message; // Opsiyonel mesaj (null = sadece spinner)

  const LoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Dönen çember — Uygulamanın tema rengini alır
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          if (message != null) ...[ // Mesaj varsa göster
            const SizedBox(height: 16),    // Çember ile mesaj arası boşluk
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
```

#### 4.3.3 shared/widgets/error_state_widget.dart — Hata Durumu Widget'ı

```dart
// error_state_widget.dart — Satır 1-43
import 'package:flutter/material.dart';

/// ErrorStateWidget — Bir hata olduğunda gösterilen ekran
/// Kırmızı ünlem ikonu + hata mesajı + "Tekrar Dene" butonu
class ErrorStateWidget extends StatelessWidget {
  final String message;         // Hata mesajı ("İnternet bağlantısı yok")
  final String? actionLabel;    // Buton metni (varsayılan: "Tekrar Dene")
  final VoidCallback? onRetry;  // Tekrar dene fonksiyonu

  const ErrorStateWidget({
    super.key,
    required this.message,
    this.actionLabel = 'Tekrar Dene',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Kırmızı ünlem ikonu
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            // Hata mesajı
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            // Tekrar dene butonu (onRetry null değilse göster)
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

#### 4.3.4 shared/widgets/empty_state_widget.dart — Boş Durum Widget'ı

```dart
// empty_state_widget.dart — Satır 1-61
import 'package:flutter/material.dart';

/// EmptyStateWidget — Veri olmadığında gösterilen ekran
/// "Henüz hiç ilanın yok" gibi mesajlar için
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;           // Büyük ikon (ör: Icons.inbox)
  final String title;            // Başlık ("Henüz ilanın yok")
  final String? subtitle;        // Alt başlık ("İlk ilanını oluştur")
  final String? actionLabel;     // Buton metni ("İlan Oluştur")
  final VoidCallback? onAction;  // Buton fonksiyonu

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Büyük ikon (soluk renk)
            Icon(icon, size: 80, color: colorScheme.outline),
            const SizedBox(height: 16),
            // Başlık
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            // Opsiyonel alt başlık
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            // Opsiyonel aksiyon butonu
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

#### 4.3.5 shared/widgets/custom_text_field.dart — Özel Metin Alanı

```dart
// custom_text_field.dart — Satır 1-47
import 'package:flutter/material.dart';

/// CustomTextField — Uygulamanın her yerinde kullanılan özelleştirilebilir metin alanı
/// Tüm formlardaki giriş alanları (e-posta, şifre, başlık, açıklama) bu widget'ı kullanır
class CustomTextField extends StatelessWidget {
  final String label;                           // Alan etiketi ("E-posta")
  final String? hint;                           // İpucu metni ("ornek@email.com")
  final TextEditingController? controller;      // Metni kontrol eden nesne
  final String? Function(String?)? validator;   // Doğrulama fonksiyonu (Validators.email)
  final bool obscureText;                       // Şifre gizleme (true = ****)
  final TextInputType keyboardType;             // Klavye tipi (email, number, text)
  final int maxLines;                           // Satır sayısı (1 = tek satır, 5 = çok satır)
  final IconData? prefixIcon;                   // Sol taraftaki ikon
  final Widget? suffixIcon;                     // Sağ taraftaki widget (göz ikonu, vb.)
  final bool enabled;                           // Düzenlenebilir mi?

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,      // Validators.email gibi fonksiyonları bağlar
      obscureText: obscureText,   // Şifre alanları için true
      keyboardType: keyboardType, // E-posta alanları için TextInputType.emailAddress
      maxLines: maxLines,         // Açıklama alanları için 5
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
```

#### 4.3.6 shared/services/firebase_service.dart — Firebase Servisi

```dart
// firebase_service.dart — Satır 1-29
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// FirebaseService — Firebase servislerine merkezi erişim noktası
/// Singleton pattern: Uygulama boyunca tek bir instance oluşturulur
/// Neden? FirebaseAuth.instance her yerde yazmak yerine
/// FirebaseService().auth şeklinde erişmek daha temiz
class FirebaseService {
  // Singleton — Private constructor + factory
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;  // Her zaman aynı instance'ı ver
  FirebaseService._internal();              // Private constructor (dışarıdan new ile oluşturulamaz)

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  // Şu anki kullanıcı (null olabilir)
  User? get currentUser => auth.currentUser;

  // Oturum değişikliklerini dinle
  Stream<User?> get authStateChanges => auth.authStateChanges();

  // Çıkış yap
  Future<void> signOut() async {
    await auth.signOut();
  }

  // E-posta doğrulanmış mı?
  Future<bool> isEmailVerified() async {
    return currentUser?.emailVerified ?? false;
  }

  // Kullanıcı bilgilerini yenile
  Future<void> refreshUser() async {
    await currentUser?.reload();
  }
}
```

#### 4.3.7 shared/services/storage_service.dart — Depolama Servisi

```dart
// storage_service.dart — Satır 1-42
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

/// StorageService — Firebase Storage'a dosya yükleme/silme işlemleri
/// Singleton pattern ile tek instance
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Tek dosya yükle
  // path: Storage'daki konum ("profile_photos/user123.jpg")
  // file: Yüklenecek dosya
  // contentType: Dosya tipi ("image/jpeg")
  // Dönen değer: Yüklenen dosyanın indirilebilir URL'si
  Future<String> uploadFile(String path, File file,
      {String? contentType}) async {
    final ref = _storage.ref().child(path);
    final metadata =
        contentType != null ? SettableMetadata(contentType: contentType) : null;

    final uploadTask = await ref.putFile(file, metadata);
    return await uploadTask.ref.getDownloadURL(); // URL'yi al
  }

  // Birden fazla dosya yükle
  Future<List<String>> uploadMultipleFiles(
    String path,
    List<File> files, {
    String? contentType,
  }) async {
    final urls = <String>[];
    for (int i = 0; i < files.length; i++) {
      // Benzersiz dosya adı: timestamp + index
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i';
      final url = await uploadFile('$path/$fileName', files[i],
          contentType: contentType);
      urls.add(url);
    }
    return urls;
  }

  // Dosya sil
  Future<void> deleteFile(String path) async {
    final ref = _storage.ref().child(path);
    await ref.delete();
  }

  // Storage referansı al (daha ileri işlemler için)
  Reference ref(String path) => _storage.ref().child(path);
}
```

### 4.4 features/ Klasörü — Feature-Based Organizasyon

Takaş'ta kod, **özellik bazlı (feature-based)** organize edilmiştir. Her feature, birbirinden bağımsız bir modüldür. Bu yaklaşımın avantajları:

1. **Yeni geliştirici:** "Chat özelliğinde hata var" denirse, direkt `features/chat/` klasörüne gider. 100 dosya arasında kaybolmaz.
2. **Yeni özellik ekleme:** "Değerlendirme sistemi ekleyelim" denirse, yeni bir `features/rating/` klasörü açılır. Diğer feature'lara dokunulmaz.
3. **Ekip çalışması:** Ali `auth/` üstünde çalışırken, Ayşe `listings/` üstünde çalışabilir. Git çakışması olasılığı düşer.

Her feature'ın 3 alt klasörü vardır (Clean Architecture'ın 3 katmanı):

```
features/xyz/
├── data/            ← Repository: Firebase/API ile konuşan katman
│   └── xyz_repository.dart
├── domain/          ← Model: Veri yapıları, enum'lar
│   └── xyz_model.dart
└── presentation/    ← Screen + Controller: UI ve state yönetimi
    ├── xyz_controller.dart
    ├── xyz_screen.dart
    └── widgets/     ← Sadece bu feature'a özel widget'lar
        └── xyz_card.dart
```

**Her feature'ın dosyaları ve sayıları:**

| Feature | data/ | domain/ | presentation/ | Toplam |
|---|---|---|---|---|
| auth | 1 (auth_repository) | 1 (user_model) | 3 (controller, login, register) | 5 |
| listings | 1 (listing_repository) | 2 (model, category) | 8 (controller + 5 screen + 3 widget) | 11 |
| chat | 1 (chat_repository) | 2 (chat_model, message_model) | 3 (controller, list, detail) | 6 |
| map | 1 (location_service) | 1 (geo_point_model) | 2 (controller, screen) | 4 |
| notifications | 1 (notification_service) | 1 (notification_model) | 2 (controller, screen) | 4 |
| profile | 2 (profile_repo, rating_repo) | 1 (rating_model) | 8 (controller + 7 screen) | 11 |
| onboarding | 0 | 0 | 1 (onboarding_screen) | 1 |

### 4.5 app/ Klasörü — Uygulama Yapılandırması

`app/` klasörü, uygulamanın genel yapılandırmasını barındırır. Feature'lara özgü değildir; tüm uygulama için geçerlidir.

#### 4.5.1 app/router.dart — Sayfa Yönlendirme

Takaş'ta sayfa yönlendirme (navigation) için **go_router** paketi kullanılır. `router.dart`, uygulamanın tüm sayfa haritasını (route'larını) tanımlar.

```dart
// router.dart (basitleştirilmiş yapı)
// Satır 27-169

// routerProvider → Uygulamanın router'ını sağlar
// ref.watch(authStateProvider) → Kullanıcı giriş durumu değiştiğinde router'ı yeniden oluşturur
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/onboarding',  // Uygulama açıldığında ilk gösterilecek sayfa

    // redirect → Her sayfa geçişinde çalışan kontrol fonksiyonu
    // Kullanıcı giriş yapmamışsa korumalı sayfalara erişemez
    redirect: (context, state) async {
      final prefs = await SharedPreferences.getInstance();
      final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
      final isLoggedIn = authState.value != null;

      // Mantık:
      // 1. Onboarding tamamlanmamışsa → onboarding sayfasına yönlendir
      // 2. Onboarding tamamlanmış ama onboarding sayfasındaysa → login'e yönlendir
      // 3. Giriş yapmamış ve korumalı sayfadaysa → login'e yönlendir
      // 4. Giriş yapmış ve login/register sayfasındaysa → ana sayfaya yönlendir
      // 5. Diğer durumlarda → istenen sayfaya git (null döner = yönlendirme yok)

      if (!onboardingCompleted) return '/onboarding';
      if (onboardingCompleted && isOnboarding) return '/login';
      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/';
      return null;
    },

    // routes → Uygulamanın tüm sayfa yolları
    routes: [
      GoRoute(path: '/onboarding', builder: ...),  // İlk kullanım rehberi
      GoRoute(path: '/login', builder: ...),        // Giriş ekranı
      GoRoute(path: '/register', builder: ...),     // Kayıt ekranı
      GoRoute(path: '/user/:id', builder: ...),     // Başka kullanıcının profili
      GoRoute(path: '/notifications', builder: ...),// Bildirimler
      GoRoute(path: '/settings', builder: ...),     // Ayarlar

      // StatefulShellRoute — Alt navigasyon (Bottom Navigation Bar)
      // 5 sekmeli yapı: Keşfet, Harita, Oluştur, Sohbet, Profil
      StatefulShellRoute.indexedStack(
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/', ...)]),          // Keşfet
          StatefulShellBranch(routes: [GoRoute(path: '/map', ...)]),       // Harita
          StatefulShellBranch(routes: [GoRoute(path: '/create-listing', ...)]), // Oluştur
          StatefulShellBranch(routes: [GoRoute(path: '/chats', ...)]),     // Sohbet
          StatefulShellBranch(routes: [GoRoute(path: '/profile', ...)]),   // Profil
        ],
      ),

      // Diğer sayfalar
      GoRoute(path: '/edit-listing/:id', ...),    // İlan düzenle (:id = parametre)
      GoRoute(path: '/chat/:id', ...),            // Sohbet detayı
      GoRoute(path: '/change-email', ...),        // E-posta değiştir
      GoRoute(path: '/change-password', ...),     // Şifre değiştir
    ],
  );
});
```

**`:id` notasyonu ne demek?**

`/listing/:id` şeklindeki yollar, dinamik parametrelerdir. `:id` yerine herhangi bir değer gelebilir:

- `/listing/abc123` → `abc123` ID'li ilanın detay sayfası
- `/listing/xyz789` → `xyz789` ID'li ilanın detay sayfası

Koddan erişim:

```dart
// İlan detayına git:
context.go('/listing/abc123');

// Detay ekranında ID'yi al:
final id = state.pathParameters['id']!; // "abc123"
```

#### 4.5.2 app/theme.dart — Tema Tanımları

`theme.dart`, uygulamanın tüm görsel stilini tanımlar: renkler, yazı tipleri, buton stilleri, kart stilleri vb.

```dart
// theme.dart — Satır 1-333 (basitleştirilmiş)

class AppTheme {
  // Uygulama renkleri — Hex kodu ile tanımlanır
  // #1B8C3A → Koyu yeşil (ana renk - takas'in yeşili)
  // Renkler neden ayrı tanımlanır? 20 farklı yerde Color(0xFF1B8C3A) yazmak yerine
  // AppTheme.primary yazabiliriz. Renk değişince tek yerden değiştirilir.
  static const Color primary = Color(0xFF1B8C3A);       // Ana yeşil
  static const Color primaryDark = Color(0xFF14692D);   // Koyu yeşil
  static const Color primaryLight = Color(0xFFE8F5E9);  // Açık yeşil
  static const Color accent = Color(0xFFFFB300);         // Altın sarısı (vurgu)
  static const Color textPrimary = Color(0xFF1A1A2E);   // Ana metin rengi
  static const Color error = Color(0xFFEF4444);          // Hata rengi (kırmızı)

  // Açık tema
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,                          // Material 3 kullan
      colorScheme: ColorScheme(primary: primary, ...), // Renk paleti
      textTheme: GoogleFonts.interTextTheme(),      // Yazı tipi: Inter
      appBarTheme: AppBarTheme(...),                // Üst bar stili
      cardTheme: CardThemeData(...),                // Kart stili
      elevatedButtonTheme: ElevatedButtonThemeData(...), // Buton stili
      inputDecorationTheme: InputDecorationTheme(...),   // Metin alanı stili
      // ... ve daha fazla bileşen stili
    );
  }

  // Koyu tema — Kullanıcı "karanlık mod" açtığında bu kullanılır
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(primary: Color(0xFF4ADE80), ...), // Daha parlak yeşil
      scaffoldBackgroundColor: Color(0xFF0F172A),                 // Koyu arka plan
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: Colors.white,   // Beyaz metin
        displayColor: Colors.white,
      ),
      // ...
    );
  }
}
```

### 4.6 main.dart — Uygulamanın Başlangıç Noktası

`main.dart`, Flutter uygulamasının çalışmaya başladığı dosyadır. Bir uygulamanın "ana giriş kapısı" gibidir.

```dart
// main.dart — Satır 1-87

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'core/providers/theme_provider.dart';
import 'features/notifications/data/notification_service.dart';

// Arka planda gelen bildirimleri yakalayan fonksiyon
// @pragma('vm:entry-point') → Bu fonksiyonun ağaç budamasından (tree shaking)
// korunması gerektiğini söyler. Uygulama kapalıyken de çalışabilir.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

// main() → Uygulamanın başlangıç fonksiyonu
// async → Çünkü birçok asenkron işlem var (Firebase başlatma, .env yükleme)
void main() async {
  // 1. Flutter binding'ini başlat — Flutter engine'in hazır olmasını sağlar
  // Bu satır olmadan async işlemler çalışmaz
  WidgetsFlutterBinding.ensureInitialized();

  // 2. .env dosyasını yükle — API anahtarlarını oku
  await dotenv.load(fileName: ".env");

  // 3. Mapbox token'ı ayarla
  String mapboxToken = dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
  MapboxOptions.setAccessToken(mapboxToken);

  // 4. Firebase'i başlat — Tüm Firebase servisleri bunu gerektirir
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 5. Türkçe tarih formatlamayı başlat
  await initializeDateFormatting('tr_TR', null);

  // 6. Arka plan bildirim dinleyicisini kaydet
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 7. Hata takibi (Crashlytics) — Uygulama çökerse Firebase'e rapor gönder
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // 8. Uygulamayı çalıştır
  // ProviderScope → Riverpod'un çalışması için gerekli sarmalayıcı
  runApp(
    const ProviderScope(
      child: TakashApp(),
    ),
  );
}

// TakashApp — Uygulamanın kök widget'ı
class TakashApp extends ConsumerStatefulWidget {
  const TakashApp({super.key});

  @override
  ConsumerState<TakashApp> createState() => _TakashAppState();
}

class _TakashAppState extends ConsumerState<TakashApp> {
  @override
  void initState() {
    super.initState();
    // Uygulama açıldıktan hemen sonra bildirim servisini başlat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationServiceProvider).initialize();
    });

    // Kullanıcı giriş/çıkış yaptığında bildirim servisini güncelle
    FirebaseAuth.instance.authStateChanges().listen((user) {
      ref.read(notificationServiceProvider).onUserChanged(user);
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);  // Router'ı dinle

    return MaterialApp.router(
      title: 'Takaş',
      theme: AppTheme.lightTheme,                    // Açık tema
      darkTheme: AppTheme.darkTheme,                 // Koyu tema
      themeMode: ref.watch(themeModeProvider),       // Hangi tema? (kullanıcı seçimi)
      routerConfig: router,                          // Sayfa yönlendirme
      debugShowCheckedModeBanner: false,             // Debug banner'ı gizle
    );
  }
}
```

**Başlangıç sırası (adım adım):**

```
1. WidgetsFlutterBinding.ensureInitialized()
   → Flutter engine'i hazır et

2. dotenv.load(fileName: ".env")
   → .env dosyasını oku, API anahtarlarını yükle

3. MapboxOptions.setAccessToken(mapboxToken)
   → Mapbox harita token'ını ayarla

4. Firebase.initializeApp()
   → Firebase servislerini başlat (Auth, Firestore, Storage, Messaging)

5. initializeDateFormatting('tr_TR')
   → Türkçe tarih formatlamayı hazırla

6. FirebaseMessaging.onBackgroundMessage()
   → Arka planda bildirim dinleyicisini kaydet

7. Crashlytics ayarları
   → Hata raporlamayı aktif et

8. runApp(ProviderScope(child: TakashApp()))
   → Uygulamayı çalıştır
```

---

## 5. pubspec.yaml Dosyası

### 5.1 pubspec.yaml Nedir?

`pubspec.yaml`, Flutter projenizin **kimlik kartı ve ayar dosyasıdır**. Bir projenin adını, versiyonunu, kullandığı dış paketleri ve varlıklarını (assets) tanımlar.

"pubspec" = **Pub**lic **Spec**ification (Genel Tanımlama)

"yaml" = **Y**AML **A**in't **M**arkup **L**anguage — İnsan tarafından okunabilir bir yapılandırma dosyası formatı.

### 5.2 Dosyanın Tam İçeriği ve Açıklaması

```yaml
# pubspec.yaml — Satır 1-77

# Uygulamanın adı — Paket ve import isimlerinde kullanılır
# import 'package:takash/core/providers.dart'; → "takash" kısmı buradan gelir
name: takash

# Uygulamanın kısa açıklaması
description: "Takaş - Konum tabanlı takas platformu"

# Paketi pub.dev'e yayınlama — 'none' = yayınlama (özel proje)
publish_to: 'none'

# Versiyon numarası: 1.0.0+1
# 1.0.0 = Semantik versiyon (major.minor.patch)
# +1 = Build numarası (her güncelleme artırılır)
version: 1.0.0+1

# Dart SDK versiyon kısıtlaması
# >=3.4.0 → En az Dart 3.4.0 gerektirir
# <4.0.0 → Dart 4.0.0'dan büyük versiyonlarla çalışmaz
environment:
  sdk: '>=3.4.0 <4.0.0'
```

### 5.3 dependencies — Çalışma Zamanı Bağımlılıkları

**dependencies**, uygulamanızın çalışması için gereken dış paketlerdir. Bu paketler, uygulamanızın bir parçası olarak derlenir ve kullanıcıya gider.

```yaml
dependencies:
  flutter:
    sdk: flutter              # Flutter framework'ünün kendisi

  cupertino_icons: ^1.0.8    # iOS tarzı ikonlar

  # ─── State Management (Durum Yönetimi) ───
  flutter_riverpod: ^2.6.1   # Riverpod — Uygulama durumunu yönetir
                              # Neden? Kullanıcı giriş yaptı mı? Hangi ekrandayız?
                              # Veri yükleniyor mu? Bu soruların cevabını Riverpod tutar
  riverpod_annotation: ^2.6.1 # Riverpod kod üretici için annotation'lar

  # ─── Navigation (Sayfa Yönlendirme) ───
  go_router: ^14.6.1         # GoRouter — Sayfalar arası geçişi yönetir
                              # Neden? Flutter'ın varsayılan Navigator'ı karmaşık
                              # GoRouter ile '/login', '/profile/edit' gibi yollar tanımlarız

  # ─── Firebase ───
  firebase_core: ^3.6.0       # Firebase çekirdeği — Diğer Firebase paketlerinin çalışması için gerekli
  firebase_auth: ^5.3.1       # Kimlik doğrulama — E-posta/şifre, Google ile giriş
  google_sign_in: ^6.2.1      # Google hesabı ile giriş yapma
  cloud_firestore: ^5.4.4     # Veritabanı — NoSQL bulut veritabanı (kullanıcılar, ilanlar, mesajlar)
  firebase_storage: ^12.3.4   # Dosya depolama — Fotoğrafları saklar
  firebase_messaging: ^15.1.3 # Bildirimler — Push notification gönderme/alma
  cloud_functions: ^5.1.3     # Sunucu tarafı fonksiyonlar — Firebase'de çalışan arka plan kodu
  firebase_crashlytics: ^4.1.3 # Hata takibi — Uygulama çökerse rapor gönderir
  firebase_analytics: ^11.3.3 # Kullanım analizi — Kullanıcı davranışlarını izler

  # ─── Harita ───
  mapbox_maps_flutter: ^2.4.0 # Mapbox harita — Konum bazlı ilan gösterimi
  geolocator: ^13.0.2         # Konum servisi — GPS'ten koordinat alır
  geoflutterfire_plus: ^0.0.17 # Geofencing — "Bana 5 km içindeki ilanları göster" sorgusu

  # ─── Chat (Sohbet) ───
  stream_chat_flutter: ^9.2.0 # Stream Chat — Gerçek zamanlı sohbet arayüzü

  # ─── Araçlar (Utilities) ───
  image_picker: ^1.1.2        # Fotoğraf seçme — Galeriden veya kameradan fotoğraf alır
  image_cropper: ^8.0.2       # Fotoğraf kırpma — Seçilen fotoğrafı kırpar
  cached_network_image: ^3.4.1 # Görsel önbellekleme — İndirilen fotoğrafları cache'ler
  intl: ^0.19.0               # Uluslararasılaştırma — Tarih/sayı formatlama, Türkçe dil desteği
  uuid: ^4.5.1                # Benzersiz ID üretici — Her ilan, mesaj için benzersiz ID
  permission_handler: ^11.3.1 # İzin yönetimi — Kamera, konum, bildirim izinleri
  flutter_dotenv: ^5.2.1      # .env dosyası okuma — Gizli API anahtarlarını yükler
  shared_preferences: ^2.3.3  # Basit veri saklama — Tema tercihi, onboarding durumu
  flutter_native_splash: ^2.4.1 # Açılış ekranı — Uygulama açılırken gösterilen logo ekranı
  flutter_local_notifications: ^17.2.3 # Yerel bildirimler — Uygulama içinde bildirim gösterme
  google_fonts: ^6.2.1        # Google Fonts — Inter yazı tipini kullanır
  share_plus: ^12.0.1         # Paylaşma — İlanı WhatsApp, SMS ile paylaşma
  url_launcher: ^6.3.0        # URL açma — Harici tarayıcıda link açma
  package_info_plus: ^9.0.0   # Paket bilgisi — Uygulama versiyonunu gösterme
```

### 5.4 dev_dependencies — Geliştirme Bağımlılıkları

**dev_dependencies**, sadece geliştirme sırasında kullanılan paketlerdir. Bunlar uygulamanın bir parçası olarak derlenmez, kullanıcıya gitmez.

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter              # Flutter test framework'ü

  flutter_lints: ^6.0.0      # Kod kalite kuralları — Uyarı ve hataları gösterir
                              # "Kullanılmayan değişken", "Eksik return" gibi

  riverpod_generator: ^2.6.2  # Riverpod kod üretici — Controller sınıflarından
                               # provider dosyalarını otomatik oluşturur (.g.dart)

  build_runner: ^2.4.13       # Kod üretici çalıştırıcı — 'dart run build_runner build' komutuyla
                               # .g.dart dosyalarını üretir

  mockito: ^5.4.4             # Mock nesne oluşturucu — Test ederken sahte servisler oluşturur
                              # Örnek: Sahte FirebaseAuth, sahte FirebaseFirestore

  fake_cloud_firestore: ^3.1.0 # Sahte Firestore — Test ortamında gerçek veritabanı yerine
                                # bellekte çalışan sahte Firestore

  firebase_auth_mocks: ^0.14.0 # Sahte FirebaseAuth — Test için
```

### 5.5 Flutter Assets

```yaml
flutter:
  uses-material-design: true   # Material Design ikonlarını kullan

  assets:
    - .env                      # .env dosyasını uygulama asset'i olarak dahil et
                                # Bu olmadan dotenv.load() çalışmaz

# Açılış ekranı (Splash screen) ayarları
flutter_native_splash:
  color: "#4CAF50"             # Açılış rengi (yeşil)
  color_dark: "#1A1A2E"        # Karanlık mod açılış rengi (koyu mavi)
  android_12:
    color: "#4CAF50"            # Android 12+ için açılış rengi
    color_dark: "#1A1A2E"
```

### 5.6 Her Dependency'nin Projedeki Rolü — Görsel Özet

```
Takaş Uygulaması
│
├── 🎨 ARAYÜZ
│   ├── flutter (framework)
│   ├── cupertino_icons (iOS ikonları)
│   ├── google_fonts (Inter yazı tipi)
│   └── cached_network_image (hızlı fotoğraf yükleme)
│
├── 🧠 DURUM YÖNETİMİ
│   ├── flutter_riverpod (state yönetimi)
│   └── riverpod_annotation (kod üretici)
│
├── 🔀 SAYFA YÖNLENDİRME
│   └── go_router
│
├── 🔥 FIREBASE
│   ├── firebase_core (çekirdek)
│   ├── firebase_auth (giriş/kayıt)
│   ├── google_sign_in (Google girişi)
│   ├── cloud_firestore (veritabanı)
│   ├── firebase_storage (dosya depolama)
│   ├── firebase_messaging (push bildirim)
│   ├── cloud_functions (sunucu fonksiyonları)
│   ├── firebase_crashlytics (hata takibi)
│   └── firebase_analytics (kullanım analizi)
│
├── 🗺️ HARİTA & KONUM
│   ├── mapbox_maps_flutter (harita)
│   ├── geolocator (GPS)
│   └── geoflutterfire_plus (konum bazlı sorgu)
│
├── 💬 SOHBET
│   └── stream_chat_flutter
│
├── 📸 MEDYA
│   ├── image_picker (fotoğraf seçme)
│   └── image_cropper (kırpma)
│
├── 🔧 ARAÇLAR
│   ├── intl (tarih/sayı format)
│   ├── uuid (benzersiz ID)
│   ├── permission_handler (izinler)
│   ├── flutter_dotenv (.env okuma)
│   ├── shared_preferences (ayar saklama)
│   ├── share_plus (paylaşma)
│   ├── url_launcher (link açma)
│   └── package_info_plus (versiyon bilgisi)
│
├── 🔔 BİLDİRİM
│   └── flutter_local_notifications
│
└── 🚀 AÇILIŞ
    └── flutter_native_splash
```

---

## 6. .env Dosyası ve Gizli Anahtarlar

### 6.1 .env Dosyası Nedir?

`.env` (environment variables = ortam değişkenleri), uygulamanızın gizli anahtarlarını sakladığı bir dosyadır. Takaş'taki `.env` dosyasının içeriği:

```
MAPBOX_ACCESS_TOKEN=pk.your_token_here
STREAM_API_KEY=your_stream_api_key
GOOGLE_SERVER_CLIENT_ID=your_client_id_here
```

### 6.2 Neden API Key'ler Kodda Değil .env'de?

API anahtarları (API keys), bir hizmete (Mapbox, Google, Stream) erişim sağlayan gizli şifrelerdir. Bu anahtarları kodun içine yazmak **çok tehlikelidir**:

1. **Güvenlik riski:** Kodunuz GitHub'a push'landığında, tüm dünyaya açık olur. Kötü niyetli biri API anahtarınızı bulursa sizin adınıza harita kullanabilir, mesaj gönderebilir, sizin faturanıza yansıtır.

2. **Farklı ortamlar:** Geliştirme (development) ve üretim (production) için farklı API anahtarları kullanabilirsiniz. `.env.dev` ve `.env.prod` gibi ayrı dosyalarla bunu yönetirsiniz.

3. **Ekip çalışması:** Her geliştiricinin kendi API anahtarı olabilir. Herkes kendi `.env` dosyasını kullanır, kodda ortak bir değer yoktur.

**Yanlış kullanım (ASLA BÖYLE YAPMAYIN):**

```dart
// KÖTÜ — API anahtarı doğrudan kodda
const mapboxToken = 'pk.eyJ1Ijoia2FkaXIxOTYi...';

// Bu kod GitHub'a push'lanırsa,
// tüm dünyaya açık hale gelir!
```

**Doğru kullanım:**

```dart
// İYİ — API anahtarı .env'den okunuyor
final mapboxToken = dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
```

### 6.3 flutter_dotenv Nasıl Çalışır?

`flutter_dotenv` paketi, `.env` dosyasını okuyup belleğe yükleyen bir araçtır. 3 adımda çalışır:

**Adım 1: pubspec.yaml'da .env dosyasını asset olarak tanımlayın**

```yaml
flutter:
  assets:
    - .env    # .env dosyasını uygulama paketine dahil et
```

Bu olmadan Flutter, `.env` dosyasını uygulama paketine (APK/IPA) koymaz ve dosyayı bulamaz.

**Adım 2: main.dart'ta .env dosyasını yükleyin**

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env dosyasını oku ve belleğe yükle
  await dotenv.load(fileName: ".env");

  // Artık dotenv.env['ANAHTAR'] ile değerlere erişebilirsiniz
  runApp(MyApp());
}
```

`dotenv.load()` çağrıldığında şunlar olur:
1. Flutter, uygulama paketindeki `.env` dosyasını bulur.
2. Dosyayı satır satır okur.
3. Her satırı `ANAHTAR=DEĞER` formatında ayrıştırır (parse).
4. Bir Map (sözlük) yapısında belleğe kaydeder.

**Adım 3: Kodda API anahtarlarına erişin**

```dart
// Herhangi bir dosyada:
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Doğrudan erişim:
String token = dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';

// Veya ApiKeys sınıfı üzerinden (Takaş'ta yaptığımız gibi):
String token = ApiKeys.mapboxToken;
```

### 6.4 ApiKeys Sınıfı — Merkezi API Anahtar Yönetimi

Takaş'ta API anahtarlarına erişimi merkezi bir sınıf üzerinden yapıyoruz:

```dart
// core/constants/api_keys.dart — Satır 1-12
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiKeys {
  // static get → Nesne oluşturmadan doğrudan erişim
  // dotenv.env['MAPBOX_ACCESS_TOKEN'] → .env'deki değeri okur
  // ?? '' → Anahtar bulunamazsa boş string döner (crash önleme)
  static String get mapboxToken {
    return dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
  }

  static String get streamApiKey {
    return dotenv.env['STREAM_API_KEY'] ?? '';
  }
}
```

**Neden doğrudan `dotenv.env[...]` yerine `ApiKeys` sınıfı kullanıyoruz?**

1. **Tek noktadan yönetim:** API anahtarına erişen 10 farklı dosya olsun. Anahtarın ismini değiştirmek isterseniz sadece `ApiKeys` sınıfını değiştirirsiniz.
2. **Tip güvenliği:** `ApiKeys.mapboxToken` yazınca Flutter'ın otomatik tamamlama özelliği çalışır. `dotenv.env['MAPBOX_ACCES_TOKEN']` yazarsanız (typo ile) sessizce boş string döner ve saatlerce debug edersiniz.
3. **Okunabilirlik:** `ApiKeys.mapboxToken` → "API anahtarına erişiyorum" çok açık. `dotenv.env['MAPBOX_ACCESS_TOKEN']` → "bellekteki bir Map'ten değer okuyorum" daha az açık.

### 6.5 .gitignore ve .env Güvenliği

`.env` dosyası **asla** Git'e commit edilmemelidir. `.gitignore` dosyasında şu satır olmalıdır:

```
.env
```

Bu satır, Git'in `.env` dosyasını görmezden gelmesini sağlar. `git add .` yaptığınızda `.env` eklenmez.

**Peki ekip arkadaşlarıma .env şablonunu nasıl iletirim?**

Genellikle `.env.example` adında bir şablon dosya oluşturulur:

```
# .env.example — Anahtar isimlerini içerir, değerler boştur
MAPBOX_ACCESS_TOKEN=your_mapbox_token_here
STREAM_API_KEY=your_stream_api_key_here
GOOGLE_SERVER_CLIENT_ID=your_google_client_id_here
```

Bu dosya Git'e commit edilir. Yeni bir geliştirici projeyi klonladığında:

1. `.env.example` dosyasını kopyalar → `.env` olarak yeniden adlandırır.
2. `your_mapbox_token_here` yazan yerlere kendi anahtarlarını yazar.
3. Uygulamayı çalıştırır.

> **Not:** Takaş projesinde `.env` dosyası şu anda Git'te bulunmaktadır çünkü henüz geliştirme aşamasındadır ve anahtarlar test amaçlıdır. Üretim (production) ortamına geçmeden önce `.env` mutlaka `.gitignore`'a eklenmelidir.

---

## Özet — Takaş Mimarisi Bir Bakışta

```
Takaş Flutter Projesi
│
├── 📱 lib/main.dart → Uygulamanın başlangıç noktası
│
├── 🏗️ lib/app/ → Genel yapılandırma
│   ├── router.dart → Sayfa yolları (go_router)
│   └── theme.dart → Açık/koyu tema
│
├── 🔧 lib/core/ → Ortak altyapı
│   ├── constants/ → Sabitler (API key'ler, limitler)
│   ├── extensions/ → Dart tipi genişletmeleri
│   ├── providers.dart → Firebase instance provider'ları
│   ├── providers/ → Tema provider'ı
│   ├── services/ → Ayar servisi
│   └── utils/ → Yardımcılar ve doğrulayıcılar
│
├── 🧩 lib/features/ → Özellik bazlı modüller (Clean Architecture)
│   ├── auth/ → Kimlik (data → domain → presentation)
│   ├── listings/ → İlanlar (data → domain → presentation)
│   ├── chat/ → Sohbet (data → domain → presentation)
│   ├── map/ → Harita (data → domain → presentation)
│   ├── notifications/ → Bildirim (data → domain → presentation)
│   ├── profile/ → Profil (data → domain → presentation)
│   └── onboarding/ → Rehber (presentation)
│
├── 🤝 lib/shared/ → Paylaşımlı bileşenler
│   ├── models/ → Temel model
│   ├── services/ → Firebase ve Storage servisleri
│   └── widgets/ → Ortak UI bileşenleri (buton, text field, loading, error, empty)
│
├── 🔑 .env → Gizli API anahtarları
├── 📋 pubspec.yaml → Paket tanımları
└── 🔥 firebase_options.dart → Firebase yapılandırması
```

**Veri akışı (kullanıcı butona bastığında):**

```
Kullanıcı "Giriş Yap" butonuna basar
    ↓
LoginScreen (presentation) → authController.signInWithEmail()
    ↓
AuthController (presentation) → state = AsyncLoading
    ↓
AuthRepository (data) → FirebaseAuth.signInWithEmailAndPassword()
    ↓
Firebase (dış dünya) → Kullanıcı doğrulanır
    ↓
AuthRepository → UserCredential döner
    ↓
AuthController → state = AsyncData (başarılı) veya AsyncError (hata)
    ↓
LoginScreen → Başarılıysa ana sayfaya yönlendir, hata ise mesaj göster
```

**Her katmanın bir sorumluluğu vardır ve sadece onu bilir. Bu, Takaş'ın sürdürülebilir, test edilebilir ve ölçeklenebilir bir proje olmasını sağlar.**
