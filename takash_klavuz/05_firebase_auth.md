# 05 — Firebase Authentication: Takaš Projesinde Kullanıcı Kimlik Doğrulama

---

## İçindekiler

1. [Firebase Nedir?](#1-firebase-nedir)
2. [Firebase Console ve CLI](#2-firebase-console-ve-cli)
3. [Firebase Auth Nedir?](#3-firebase-auth-nedir)
4. [E-posta / Şifre ile Kayıt ve Giriş](#4-e-posta--şifre-ile-kayıt-ve-giriş)
5. [Google Sign-In](#5-google-sign-in)
6. [Token (ID Token, Access Token)](#6-token-id-token-access-token)
7. [Auth Repository — Tam Dosya İçeriği](#7-auth-repository--tam-dosya-i̇çeriği)
8. [User Model — Tam Dosya İçeriği](#8-user-model--tam-dosya-i̇çeriği)
9. [Auth Controller — Tam Dosya İçeriği](#9-auth-controller--tam-dosya-i̇çeriği)
10. [Login Screen — Tam Dosya İçeriği](#10-login-screen--tam-dosya-i̇çeriği)
11. [Register Screen — Tam Dosya İçeriği](#11-register-screen--tam-dosya-i̇çeriği)
12. [Change Email Screen — Tam Dosya İçeriği](#12-change-email-screen--tam-dosya-i̇çeriği)
13. [Change Password Screen — Tam Dosya İçeriği](#13-change-password-screen--tam-dosya-i̇çeriği)

---

## 1. Firebase Nedir?

### 1.1 Google Cloud Ekosistemi

Google Cloud Platform (GCP), Google'ın bulut bilişim hizmetleridir. Sunucular, veritabanları,
makine öğrenmesi modelleri, depolama alanları ve daha birçok hizmet sunar. Ancak GCP'yi
doğrudan kullanmak karmaşık olabilir: sunucu yapılandırması, ağ ayarları, güvenlik grupları,
load balancer'lar gibi birçok altyapı detayıyla ilgilenmeniz gerekir.

Firebase ise Google Cloud'un **üstüne inşa edilmiş** bir platformdur. Altyapı detaylarını
tamamen gizler ve size sadece "şunu yap" demenizi sağlar. Örneğin:

- "Bir veritabanı oluştur" dersiniz, Firebase Realtime Database veya Firestore hazır.
- "Kullanıcı girişi yap" dersiniz, Firebase Authentication hazır.
- "Bir dosya yükle" dersiniz, Firebase Storage hazır.
- "Bir bildirim gönder" dersiniz, Firebase Cloud Messaging hazır.

### 1.2 BaaS (Backend as a Service) Kavramı

Geleneksel mobil uygulama geliştirmede şöyle bir süreç izlenir:

```
[Mobil Uygulama] ←→ [Kendi Sunucunuz (Node.js, Python, Java vb.)] ←→ [Veritabanı (MySQL, PostgreSQL)]
```

Bu modelde sizin bir sunucu yazmanız, dağıtmanız (deploy), ölçeklendirmeniz (scale),
güvenliğini sağlamanız ve bakımını yapmanız gerekir.

**BaaS** modelinde ise:

```
[Mobil Uygulama] ←→ [Firebase (Google'ın Sunucuları)]
```

Firebase sizin için sunucu işlevini görür. Sadece Firebase SDK'ını uygulamanıza eklersiniz
ve doğrudan Firebase ile iletişim kurarsınız. Kendi sunucunza ihtiyacınız yoktur.

**BaaS'ın avantajları:**
- Sunucu yönetimi yoktur
- Otomatik ölçeklenme (milyonlarca kullanıcı bile olsa)
- Yüksek kullanılabilirlik (%99.95 uptime)
- Güvenlik kuralları Firebase'de tanımlanır
- Ücretsiz katman (Spark plan) çoğu küçük/orta proje için yeterlidir

**BaaS'ın dezavantajları:**
- Firebase'e bağımlı olursunuz (vendor lock-in)
- Karmaşık iş mantığı (business logic) sınırlıdır
- Cloud Functions ile sunucusuz fonksiyonlar yazabilirsiniz ama bu da bir öğrenme eğrisidir

### 1.3 Firebase'in Sunduğu Temel Hizmetler

| Hizmet | Açıklama |
|--------|----------|
| **Authentication** | Kullanıcı kayıt, giriş, şifre sıfırlama, OAuth sağlayıcılar |
| **Cloud Firestore** | NoSQL belge veritabanı, gerçek zamanlı senkronizasyon |
| **Realtime Database** | JSON tabanlı gerçek zamanlı veritabanı |
| **Cloud Storage** | Dosya depolama (resim, video, PDF vb.) |
| **Cloud Messaging (FCM)** | Push bildirimleri |
| **Cloud Functions** | Sunucusuz fonksiyonlar (Node.js çalıştırır) |
| **Analytics** | Kullanıcı analitiği |
| **Crashlytics** | Uygulama çökme raporlama |
| **Remote Config** | Uygulamayı güncellemeden yapılandırma değiştirme |
| **Performance Monitoring** | Uygulama performans izleme |

Takaš projemizde özellikle **Authentication**, **Cloud Firestore** ve **Cloud Storage**
hizmetlerini kullanıyoruz.

### 1.4 Firebase SDK ve Flutter

Firebase, birçok platform için SDK (Software Development Kit) sunar:
- Android (Java/Kotlin)
- iOS (Objective-C/Swift)
- Web (JavaScript/TypeScript)
- **Flutter (Dart)** ← biz bunu kullanıyoruz
- Unity
- C++

Flutter için Firebase paketleri `pub.dev` üzerinden gelir:

```yaml
# pubspec.yaml içindeki Firebase bağımlılıkları
dependencies:
  firebase_core:          # Firebase'in temel başlatma paketi
  firebase_auth:          # Authentication hizmeti
  cloud_firestore:        # Firestore veritabanı
  firebase_storage:       # Cloud Storage
  google_sign_in:         # Google ile giriş
```

**`firebase_core`** olmadan hiçbir Firebase hizmeti çalışmaz. Bu paket, Firebase'i Flutter
uygulamasında başlatır (`Firebase.initializeApp()`).

---

## 2. Firebase Console ve CLI

### 2.1 Firebase Console — Proje Oluşturma

Firebase Console, Firebase projelerinizi yönettiğiniz web arayüzüdür.
Adres: **https://console.firebase.google.com**

Adım adım proje oluşturma:

1. **Firebase Console'a gidin** ve Google hesabınızla giriş yapın.
2. **"Add project" (Proje ekle)** butonuna tıklayın.
3. **Proje adı** girin (örneğin: `takash-app`).
4. **Google Analytics** seçeneğini açın veya kapatın (önerilen: açık).
5. **"Create project"** butonuna tıklayın.
6. Firebase projeniz oluşturulur.

### 2.2 Android Uygulamasını Firebase'e Kaydetme

Firebase Console'da projenizi oluşturduktan sonra bir Android uygulaması eklemeniz gerekir:

1. Proje genel görünümünde **Android ikonuna** tıklayın.
2. **Android paket adı** girin (örneğin: `com.example.takash`). Bu, `android/app/build.gradle`
   dosyasındaki `applicationId` ile **birebir aynı** olmalıdır.
3. **Uygulama takma adı** (App nickname) girin (örneğin: `Takaš`).
4. **SHA-1 sertifika parmak izini** girin (aşağıda nasıl bulunur açıklanıyor).
5. **"Register app"** butonuna tıklayın.

### 2.3 SHA-1 Sertifika Parmak İzi

SHA-1, Android uygulamanızın dijital imzasıdır. Firebase, bu imzayı kullanarak uygulamanızın
gerçekten sizin uygulamanız olduğunu doğrular. Özellikle **Google Sign-In** için zorunludur.

**Hata ayıklama (debug) SHA-1'i bulmak için:**

```bash
# Linux / macOS
keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android -keypass android

# Windows
keytool -list -v -alias androiddebugkey -keystore %USERPROFILE%\.android\debug.keystore -storepass android -keypass android
```

Çıktıda şöyle bir satır görürsünüz:

```
SHA1: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
```

Bu değeri Firebase Console'daki SHA-1 alanına yapıştırın.

**Önemli:** Production (yayın) için release keystore'unuzun SHA-1'ini de eklemeniz gerekir.
Aksi halde Google Sign-In sadece debug derlemelerinde çalışır.

### 2.4 google-services.json Dosyası

Firebase Console, Android uygulamanızı kaydettikten sonra bir `google-services.json` dosyası
indirmenizi ister. Bu dosya şunları içerir:

- **project_id:** Firebase proje kimliği
- **project_number:** Firebase proje numarası
- **mobilesdk_app_id:** Uygulamanızın benzersiz kimliği
- **oauth_client:** OAuth2 istemci bilgileri (Google Sign-In için)
- **api_key:** Firebase API anahtarı

Bu dosya **`android/app/`** klasörüne yerleştirilir:

```
android/
  app/
    google-services.json   ← buraya
    build.gradle
    src/
      main/
        AndroidManifest.xml
```

**Bu dosya asla Git'e commit edilmemelidir!** `.gitignore` dosyasında olduğundan emin olun.
Ancak eğitim amaçlı projelerde bazen commit edildiği görülür.

### 2.5 iOS Uygulamasını Firebase'e Kaydetme

iOS için benzer bir süreç izlenir:

1. Firebase Console'da **iOS ikonuna** tıklayın.
2. **Bundle ID** girin (örneğin: `com.example.takash`).
3. **`GoogleService-Info.plist`** dosyası indirilir.
4. Bu dosya Xcode'da projeye eklenir (Runner altına sürüklenir).

### 2.6 Firebase CLI (Command Line Interface)

Firebase CLI, terminal üzerinden Firebase işlemleri yapmanızı sağlar:

```bash
# Firebase CLI'ı kurma
npm install -g firebase-tools

# Firebase'e giriş yapma
firebase login

# Projeyi başlatma
firebase init

# Cloud Functions'ları dağıtma
firebase deploy --only functions

# Firestore kurallarını dağıtma
firebase deploy --only firestore:rules

# Storage kurallarını dağıtma
firebase deploy --only storage
```

Takaš projesinde CLI kullanmasanız da olur; çoğu işlem Firebase Console'dan yapılabilir.
Ama CLI, özellikle Cloud Functions ve güvenlik kuralları dağıtımı için çok kullanışlıdır.

### 2.7 Flutter'da Firebase Başlatma

Firebase hizmetlerini kullanmadan önce uygulamanızda Firebase'i başlatmanız gerekir.
Bu genellikle `main.dart` dosyasında yapılır:

```dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();   // Firebase'i başlat
  runApp(const MyApp());
}
```

**`WidgetsFlutterBinding.ensureInitialized()`** nedir?
Flutter engine'i ve framework'ü arasındaki bağlantıyı kurar. `main()` fonksiyonunda
`async/await` kullanmadan önce çağrılmalıdır, çünkü `Firebase.initializeApp()` bir
platform kanalı (platform channel) üzerinden native kod çalıştırır ve bunun için
Flutter engine'in hazır olması gerekir.

**`Firebase.initializeApp()`** arka planda ne yapar?
- Android'de: `google-services.json` dosyasını okur
- iOS'te: `GoogleService-Info.plist` dosyasını okur
- Firebase hizmetlerine bağlantı kurar
- Kimlik doğrulama durumunu yükler

---

## 3. Firebase Auth Nedir?

### 3.1 Kullanıcı Yönetimi ve Kimlik Doğrulama

**Kimlik doğrulama (Authentication)**, bir kullanıcının **kim olduğunu** doğrulama sürecidir.
Gerçek hayatta bunu T.C. kimlik kartınızla yaparsınız. Dijital dünyada ise bunu e-posta/şifre,
Google hesabı, telefon numarası vb. ile yaparsınız.

Firebase Authentication, bu süreci sizin için yönetir. Şunları sağlar:

- **Kullanıcı kaydı:** Yeni hesap oluşturma
- **Kullanıcı girişi:** Mevcut hesapla oturum açma
- **Oturum yönetimi:** Kullanıcının giriş yapıp yapmadığını izleme
- **Şifre sıfırlama:** Unutulan şifreler için e-posta gönderme
- **E-posta değiştirme:** Kullanıcının e-posta adresini güncelleme
- **Hesap silme:** Kullanıcı hesabını silebilme
- **Profil güncelleme:** Ad, fotoğraf gibi profil bilgilerini değiştirme

### 3.2 Desteklenen Giriş Yöntemleri (Sign-in Providers)

Firebase Auth birçok giriş yöntemi destekler:

| Sağlayıcı | Açıklama |
|-----------|----------|
| **Email/Password** | E-posta ve şifre ile klasik kayıt/giriş |
| **Google** | Google hesabı ile OAuth2.0 girişi |
| **Apple** | Apple ID ile giriş (iOS'ta zorunlu) |
| **Facebook** | Facebook hesabı ile giriş |
| **Twitter** | Twitter hesabı ile giriş |
| **GitHub** | GitHub hesabı ile giriş |
| **Phone** | SMS ile telefon numarası doğrulama |
| **Anonymous** | Anonim (geçici) hesap |
| **Custom** | Özel kimlik doğrulama sistemi |

Takaš projemizde **Email/Password** ve **Google** giriş yöntemlerini kullanıyoruz.

### 3.3 Firebase Console'da Giriş Yöntemlerini Etkinleştirme

Firebase Console'da giriş yöntemlerini açmak için:

1. Firebase Console → **Authentication** bölümüne gidin.
2. **"Sign-in method" (Oturum açma yöntemi)** sekmesine tıklayın.
3. İstediğiniz sağlayıcının üzerine tıklayın.
4. **"Enable" (Etkinleştir)** seçeneğini açın.
5. Gerekli bilgileri doldurun (Google için destek e-postası vb.).
6. **"Save" (Kaydet)** butonuna tıklayın.

**Email/Password** için ek yapılandırma gerekmez; sadece etkinleştirmeniz yeterlidir.

**Google** için:
- Support email (destek e-postası) seçmeniz gerekir
- Proje SHA-1'i doğru girilmiş olmalıdır

### 3.4 FirebaseAuth Instance

Flutter'da Firebase Auth'a erişmek için `FirebaseAuth` sınıfı kullanılır:

```dart
import 'package:firebase_auth/firebase_auth.dart';

// FirebaseAuth singleton instance'ına erişim
final auth = FirebaseAuth.instance;
```

`FirebaseAuth.instance`, uygulama boyunca tek bir örnek (singleton) döndürür.
Yani her yerde aynı FirebaseAuth nesnesini kullanırsınız.

**Temel özellikler:**

```dart
// Şu an oturum açmış kullanıcı (null ise giriş yapılmamış)
User? currentUser = FirebaseAuth.instance.currentUser;

// Oturum durumu değişikliklerini dinleme (Stream)
Stream<User?> authStream = FirebaseAuth.instance.authStateChanges();
```

### 3.5 Takaš Projesinde Provider ile FirebaseAuth

Takaš projesinde FirebaseAuth instance'ını Riverpod provider ile yönetiyoruz:

```dart
// lib/core/providers.dart

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});
```

Bu provider, `FirebaseAuth.instance`'ı Riverpod'un bağımlılık enjeksiyonu (DI) sistemine
kaydeder. Böylece herhangi bir yerde `ref.read(firebaseAuthProvider)` diyerek FirebaseAuth'a
erişebiliriz.

**Neden doğrudan `FirebaseAuth.instance` kullanmıyoruz?**

- **Test edilebilirlik:** Testlerde mock (sahte) FirebaseAuth verebilirsiniz.
- **Merkezi yönetim:** FirebaseAuth yapılandırması tek bir yerdedir.
- **Bağımlılık enjeksiyonu:** Kodunuz gevşek bağlı (loosely coupled) olur.

Benzer şekilde Firestore ve Storage için de provider'larımız var:

```dart
// lib/core/providers.dart

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final storageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});
```

Ve en önemlisi, auth durumunu dinleyen `authStateProvider`:

```dart
// lib/core/providers.dart

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});
```

Bu provider, kullanıcı giriş yaptığında `User` nesnesi, çıkış yaptığında `null` yayınlar.
Uygulamanın herhangi bir yerinden `ref.watch(authStateProvider)` diyerek giriş durumunu
gözlemleyebilirsiniz.

---

## 4. E-posta / Şifre ile Kayıt ve Giriş

### 4.1 Kayıt (Registration) Mantığı

E-posta/şifre ile kayıt, en temel kimlik doğrulama yöntemidir. Süreç şu şekildedir:

```
Kullanıcı formu doldurur (e-posta, şifre, isim)
        ↓
Flutter uygulaması Firebase Auth'a kayıt isteği gönderir
        ↓
Firebase Auth kullanıcıyı oluşturur
        ↓
Firebase Auth bir User nesnesi döndürür (uid ile birlikte)
        ↓
Uygulama, bu User'ın bilgilerini Firestore'a kaydeder
        ↓
Kayıt tamamlanır, kullanıcı otomatik olarak giriş yapmış olur
```

**Firebase Auth tarafında:**

```dart
final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
  email: 'kullanici@example.com',
  password: 'sifre123',
);
// credential.user artık oturum açmış kullanıcıdır
// credential.user.uid → benzersiz kullanıcı kimliği
```

**Önemli kurallar:**
- E-posta benzersiz olmalıdır (aynı e-posta ile iki kez kayıt olunamaz)
- Şifre en az 6 karakter olmalıdır
- E-posta geçerli bir formatta olmalıdır (@ işareti vb.)

### 4.2 Giriş (Sign In) Mantığı

Giriş süreci:

```
Kullanıcı formu doldurur (e-posta, şifre)
        ↓
Flutter uygulaması Firebase Auth'a giriş isteği gönderir
        ↓
Firebase Auth e-posta ve şifreyi doğrular
        ↓
Başarılı ise User nesnesi döndürülür
        ↓
Başarısız ise FirebaseAuthException fırlatılır
```

```dart
final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
  email: 'kullanici@example.com',
  password: 'sifre123',
);
```

**Olası hatalar:**

| Hata Kodu | Açıklama |
|-----------|----------|
| `user-not-found` | Bu e-posta ile kayıtlı kullanıcı yok |
| `wrong-password` | Şifre yanlış |
| `invalid-email` | E-posta formatı geçersiz |
| `user-disabled` | Bu kullanıcı devre dışı bırakılmış |
| `too-many-requests` | Çok fazla başarısız deneme, geçici olarak engellendi |
| `invalid-credential` | Kimlik bilgileri geçersiz |

### 4.3 Oturum Durumunu İzleme

Kullanıcının giriş yapıp yapmadığını anlamak için `authStateChanges` stream'ini dinleriz:

```dart
FirebaseAuth.instance.authStateChanges().listen((User? user) {
  if (user == null) {
    // Kullanıcı giriş yapmamış → login ekranını göster
  } else {
    // Kullanıcı giriş yapmış → ana ekrana yönlendir
  }
});
```

Bu stream şu durumlarda tetiklenir:
- Uygulama başladığında (önceki oturum varsa geri yüklenir)
- Kullanıcı giriş yaptığında
- Kullanıcı çıkış yaptığında

**Oturum kalıcılığı:** Firebase Auth, oturum bilgilerini cihazda saklar. Uygulamayı
kapatsanız bile kullanıcı giriş yapmış kalır. Bu varsayılan davranıştır.

### 4.4 Çıkış (Sign Out)

```dart
await FirebaseAuth.instance.signOut();
```

Bu çağrı, oturumu sonlandırır. `authStateChanges` stream'i `null` yayınlar.
Uygulamanız otomatik olarak login ekranına yönlendirir.

### 4.5 Şifre Sıfırlama

Firebase Auth, kullanıcıya şifre sıfırlama e-postası gönderme özelliği sunar:

```dart
await FirebaseAuth.instance.sendPasswordResetEmail(
  email: 'kullanici@example.com',
);
```

Bu çağrı, Firebase'in e-posta gönderme sistemini kullanarak kullanıcının e-posta adresine
özel bir bağlantı gönderir. Kullanıcı bu bağlantıya tıklayarak yeni şifresini belirleyebilir.

---

## 5. Google Sign-In

### 5.1 OAuth 2.0 Nedir?

OAuth 2.0, bir uygulamanın başka bir servise (Google, Facebook vb.) kullanıcı adı ve şifresini
vermeden, kullanıcı adına belirli işlemler yapmasına izin veren bir yetkilendirme protokolüdür.

**Basit analoji:**
Oteli düşünün. Otele girdiğinizde resepsiyonist (Google) size bir oda kartı (token) verir.
Bu kartla odanıza (uygulamanıza) girebilirsiniz. Ama resepsiyonist sizin kimliğinizi (şifrenizi)
oda kartının üzerinde yazmaz. Kart belirli bir süre için geçerlidir.

**OAuth 2.0 akışı (Google Sign-In için):**

```
1. Uygulama Google'a yönlendirme yapar
2. Kullanıcı Google'da giriş yapar ve uygulamanın bilgilerine erişmesine izin verir
3. Google, uygulamaya bir "authorization code" döndürür
4. Uygulama bu kodu bir "access token" ve "id token" ile değiştirir
5. Uygulama bu token'ları Firebase Auth'a gönderir
6. Firebase Auth token'ları doğrular ve kullanıcı oturumunu açar
```

### 5.2 Google Sign-In'in Çalışma Prensibi

Flutter'da Google Sign-In için iki paket birlikte çalışır:

1. **`google_sign_in`**: Google hesap seçim arayüzünü gösterir ve token'ları alır.
2. **`firebase_auth`**: Bu token'ları Firebase'e gönderir ve oturum açar.

```dart
// 1. Adım: Google hesap seçimini başlat
final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
// Kullanıcı hesabını seçti (veya iptal etti)

// 2. Adım: Google'dan kimlik doğrulama bilgilerini al
final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
// googleAuth.idToken → kullanıcının kimlik bilgileri (JWT)
// googleAuth.accessToken → Google API'lerine erişim token'ı

// 3. Adım: Firebase credential oluştur
final credential = GoogleAuthProvider.credential(
  accessToken: googleAuth.accessToken,
  idToken: googleAuth.idToken,
);

// 4. Adım: Firebase ile oturum aç
final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
// Artık kullanıcı Firebase'de giriş yapmış durumda
```

### 5.3 SHA-1 ve serverClientId

**SHA-1** ve **serverClientId**, Google Sign-In'in çalışması için kritik iki bilgidir.

**SHA-1** (daha önce bahsetmiştik):
- Android uygulamanızın dijital imzasıdır
- Firebase Console'da kaydedilmelidir
- Google, gelen isteğin gerçekten sizin uygulamanızdan geldiğini SHA-1 ile doğrular
- Yanlış SHA-1 girilirse Google Sign-In çalışmaz ve `DEVELOPER_ERROR` alırsınız

**serverClientId (Web Client ID):**
- Google Cloud Console'da oluşturulan OAuth 2.0 istemci kimliğidir
- Genellikle otomatik olarak Firebase Console'da oluşturulur
- `google-services.json` dosyasında `oauth_client` bölümünde bulunur
- ID Token almak için gereklidir

**Web Client ID nasıl bulunur:**
1. Firebase Console → Proje Ayarları
2. **"Your apps"** bölümünde Android uygulamanızın yanındaki yapılandırma bilgilerine bakın
3. Alternatif olarak: Google Cloud Console → APIs & Services → Credentials
4. **"OAuth 2.0 Client IDs"** altında "Web client" olanının Client ID'sini kopyalayın

### 5.4 Google Sign-In'de İptal Senaryosu

Kullanıcı Google hesap seçim ekranında "İptal" butonuna basarsa `googleUser` null olur:

```dart
final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
if (googleUser == null) {
  // Kullanıcı iptal etti
  return null;
}
```

Bu null kontrolü mutlaka yapılmalıdır, aksi halde null referans hatası alırsınız.

### 5.5 Google Sign-In ile İlk Kez Giren Kullanıcılar

Bir kullanıcı ilk kez Google hesabıyla uygulamanıza girdiğinde, Firebase Auth otomatik
olarak yeni bir kullanıcı hesabı oluşturur. `userCredential.additionalUserInfo?.isNewUser`
ile bunun yeni bir kullanıcı olup olmadığını kontrol edebilirsiniz.

Takaš projemizde, yeni kullanıcılar için Firestore'da bir profil belgesi oluşturuyoruz.
Bu, kullanıcının adını, e-postasını, fotoğrafını ve diğer bilgilerini saklar.

---

## 6. Token (ID Token, Access Token)

### 6.1 Token Nedir?

Token, dijital dünyada bir "bilet" veya "pasaport" gibidir. Bir kullanıcı giriş yaptığında,
Firebase Auth ona bir token verir. Bu token, kullanıcının kim olduğunu ve hangi yetkilere
sahip olduğunu kanıtlar.

### 6.2 ID Token (Kimlik Token'ı)

**ID Token**, kullanıcının kimliğini kanıtlayan bir JWT (JSON Web Token)'dir.

**JWT'nin yapısı:**

```
header.payload.signature
```

Her üç bölüm de Base64 ile kodlanmıştır. Decode edildiğinde:

**Header:**
```json
{
  "alg": "RS256",
  "typ": "JWT",
  "kid": "..."
}
```

**Payload (yük):**
```json
{
  "iss": "https://securetoken.google.com/takash-app",
  "aud": "takash-app",
  "auth_time": 1713123456,
  "sub": "a1b2c3d4e5f6...",     ← kullanıcının uid'si
  "iat": 1713123456,
  "exp": 1713127056,            ← son kullanma tarihi
  "email": "kullanici@gmail.com",
  "email_verified": true,
  "firebase": {
    "identities": { "google.com": ["..."] },
    "sign_in_provider": "google.com"
  }
}
```

**Signature (imza):**
Google'ın private key'i ile imzalanır. Herkes Google'ın public key'i ile doğrulayabilir.

**ID Token'ın özellikleri:**
- Kullanıcının **kim olduğunu** tanımlar
- **1 saat** geçerlidir (sonra yenilenir)
- Backend sunucunuzda kullanıcıyı doğrulamak için kullanılır
- `sub` alanı kullanıcının benzersiz uid'sini içerir

**Flutter'da ID Token alma:**

```dart
final user = FirebaseAuth.instance.currentUser;
final idToken = await user?.getIdToken();
// veya token'ın yenilenmesini zorlamak için:
final idToken = await user?.getIdToken(true);
```

### 6.3 Access Token (Erişim Token'ı)

**Access Token**, Google API'lerine (Gmail, Drive, Calendar vb.) erişmek için kullanılır.

Google Sign-In sırasında alınır:

```dart
final googleAuth = await googleUser.authentication;
final accessToken = googleAuth.accessToken;
```

**Access Token'ın özellikleri:**
- Hangi API'lere erişilebileceğini belirler (scopes ile tanımlanır)
- Sınırlı süre geçerlidir
- Firebase Auth ile doğrudan ilişkili değildir
- Google API'lerini çağırmak için kullanılır

Takaš projemizde Access Token'ı doğrudan kullanmıyoruz; sadece Firebase credential
oluştururken geçiriyoruz.

### 6.4 Token Yenileme (Refresh)

Firebase Auth SDK, token'ları otomatik olarak yeniler. Süreç:

```
1. Kullanıcı giriş yapar
2. ID Token oluşturulur (1 saat geçerli)
3. 1 saat dolmak üzereyken SDK otomatik olarak yeni token ister
4. Firebase yeni token verir
5. Bu süreç kullanıcıya görünmez
```

**Önemli:** Token yenileme başarısız olursa (örneğin kullanıcı hesabı silinmişse),
oturum otomatik olarak kapatılır.

### 6.5 Token ve Güvenlik

- Token'ları **asla** client-side'da saklamayın (SharedPreferences, vs.)
- Token'ları **asla** URL parametresi olarak göndermeyin
- Token'ları her zaman **HTTPS** üzerinden iletin
- Firebase Auth SDK token yönetimini sizin için halleder, manuel müdahale gerekmez

### 6.6 Firestore Güvenlik Kuralları ve Token

Firestore güvenlik kuralları, kullanıcının kimlik doğrulama durumunu kontrol edebilir:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Sadece giriş yapmış kullanıcılar okuyabilir
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
  }
}
```

`request.auth`, kullanıcının token bilgilerini içerir. `request.auth.uid` ile kullanıcının
benzersiz kimliğini alabilir ve belge sahipliğini kontrol edebilirsiniz.

---

## 7. Auth Repository — Tam Dosya İçeriği

Bu bölümde Takaš projesinin kalbi olan `auth_repository.dart` dosyasının tamamını satır
satır inceleyeceğiz.

**Dosya yolu:** `lib/features/auth/data/auth_repository.dart`

```dart
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user_model.dart';
import '../../../core/providers.dart';
```

**Satır 1:** `import 'dart:developer' as developer;`
- Dart'ın yerleşik geliştirici kütüphanesini `developer` alias'ı ile içe aktarıyoruz.
- Bu kütüphane `developer.log()` fonksiyonunu sağlar, `print()` yerine daha detaylı
  loglama yapmamızı sağlar. Hata ayıklarken stack trace gibi bilgileri de yazdırabiliriz.

**Satır 2:** `import 'package:cloud_firestore/cloud_firestore.dart';`
- Cloud Firestore paketini içe aktarıyoruz. Firestore, Firebase'in NoSQL belge veritabanıdır.
- Bu dosyada kullanıcı profillerini Firestore'a kaydetmek için kullanacağız.

**Satır 3:** `import 'package:flutter/services.dart';`
- Flutter'ın servis kütüphanesi. Platform kanalları ve sistem servislerine erişim sağlar.
- Bu dosyada doğrudan kullanılmasa da, hata yakalamada `PlatformException` için gerekli olabilir.

**Satır 4:** `import 'package:firebase_auth/firebase_auth.dart';`
- Firebase Authentication paketini içe aktarıyoruz.
- `FirebaseAuth`, `User`, `UserCredential`, `GoogleAuthProvider` gibi sınıflar bu paketten gelir.

**Satır 5:** `import 'package:google_sign_in/google_sign_in.dart';`
- Google Sign-In paketini içe aktarıyoruz.
- `GoogleSignIn`, `GoogleSignInAccount`, `GoogleSignInAuthentication` gibi sınıflar bu paketten gelir.

**Satır 6:** `import 'package:flutter_riverpod/flutter_riverpod.dart';`
- Riverpod state yönetim kütüphanesini içe aktarıyoruz.
- `Provider`, `ref.watch`, `ref.read` gibi API'ler bu paketten gelir.

**Satır 7:** `import '../domain/user_model.dart';`
- Kendi oluşturduğumuz `UserModel` sınıfını içe aktarıyoruz.
- Bu sınıf, Firestore'dan okunan kullanıcı verilerini Dart nesnesine dönüştürür.

**Satır 8:** `import '../../../core/providers.dart';`
- Uygulamanın temel provider'larını içe aktarıyoruz.
- `firebaseAuthProvider`, `firestoreProvider` gibi provider'lar burada tanımlıdır.

---

```dart
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    auth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
  );
});
```

**Satır 10-15:** `authRepositoryProvider`
- Bu, Riverpod `Provider`'ıdır. `AuthRepository` sınıfını oluşturur ve sağlar.
- `ref.watch(firebaseAuthProvider)` → FirebaseAuth instance'ını alır.
- `ref.watch(firestoreProvider)` → FirebaseFirestore instance'ını alır.
- Her ikisini de `AuthRepository` constructor'ına parametre olarak geçirir.
- Böylece uygulamanın herhangi bir yerinden `ref.read(authRepositoryProvider)` diyerek
  `AuthRepository` instance'ına erişebiliriz.
- `ref.watch` kullandık çünkü provider'lar değişirse (testte mock ile değiştirme gibi)
  bu provider da güncellenmelidir.

---

```dart
class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
```

**Satır 17:** `class AuthRepository {`
- `AuthRepository` sınıfı, tüm kimlik doğrulama işlemlerini merkezileştiren bir repository sınıfıdır.
- Repository pattern: Veri kaynağına erişimi soyutlar. UI katmanı Firebase'in detaylarını bilmez,
  sadece bu sınıfın metodlarını çağırır.

**Satır 18:** `final FirebaseAuth _auth;`
- FirebaseAuth instance'ını saklayan private alan. Alt çizgi (_) ön eki Dart'ta private anlamına gelir.
- Tüm Firebase Auth işlemleri bu alan üzerinden yapılır.

**Satır 19:** `final FirebaseFirestore _firestore;`
- FirebaseFirestore instance'ını saklayan private alan.
- Kullanıcı profillerini Firestore'a kaydetmek için kullanılır.

---

```dart
  AuthRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;
```

**Satır 21-25:** Constructor
- `required` anahtar kelimesi, bu parametrelerin zorunlu olduğunu belirtir.
- Named constructor parametreleri kullanılıyor (süslü parantez içinde).
-Initializer list (`:`) ile parametreler private alanlara atanıyor.
- Bu yapı, dependency injection (bağımlılık enjeksiyonu) sağlar: dışarıdan FirebaseAuth ve
  FirebaseFirestore verilir, sınıf onları oluşturmaz.

---

```dart
  Stream<User?> get authStateChanges => _auth.authStateChanges();
```

**Satır 27:** `authStateChanges` getter'ı
- Firebase Auth'ın `authStateChanges()` stream'ini dışarıya açar.
- `User?` döndürür: kullanıcı giriş yapmışsa `User`, yapmamışsa `null`.
- UI katmanı bu stream'i dinleyerek kullanıcının giriş/çıkış durumunu gerçek zamanlı izler.
- `get` anahtar kelimesi ile bir hesaplanmış özellik (computed property) tanımlıyoruz.

---

```dart
  User? get currentUser => _auth.currentUser;
```

**Satır 29:** `currentUser` getter'ı
- Şu an oturum açmış kullanıcıyı döndürür.
- `null` ise kullanıcı giriş yapmamıştır.
- Stream dinlemek yerine anlık bir snapshot almak istediğinizde kullanışlıdır.

---

```dart
  Future<UserCredential> signInWithEmail(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
```

**Satır 31-35:** `signInWithEmail` metodu — Firebase Auth çağrısı
- `Future<UserCredential>`: Bu asenkron bir metottur, tamamlandığında `UserCredential` döndürür.
- `async/await`: Asenkron işlemleri senkronmuş gibi yazmamızı sağlar.
- `_auth.signInWithEmailAndPassword()`: Firebase Auth'un e-posta/şifre giriş metodu.
- Firebase sunucularına bir HTTP isteği gönderir, e-posta ve şifreyi kontrol eder.
- Başarılı: `UserCredential` döner (içinde `User` nesnesi vardır).
- Başarısız: `FirebaseAuthException` fırlatır (yanlış şifre, kullanıcı bulunamadı vb.).

---

```dart
    // Firestore'da profil var mı kontrol et, yoksa oluştur
    if (credential.user != null) {
      final doc =
          await _firestore.collection('users').doc(credential.user!.uid).get();

      if (!doc.exists) {
        await _saveUserToFirestore(
          credential.user!,
          credential.user!.displayName ?? email.split('@').first,
        );
      }
    }
```

**Satır 37-48:** Firestore profil kontrolü
- `credential.user != null`: Giriş başarılı mı kontrol eder.
- `_firestore.collection('users').doc(credential.user!.uid).get()`:
  Firestore'da `users` koleksiyonunda, kullanıcının uid'si ile eşleşen belgeyi getirir.
- `!doc.exists`: Belge yoksa, bu kullanıcı daha önce hiç giriş yapmamış demektir.
- `_saveUserToFirestore()`: Kullanıcı profilini Firestore'a kaydeder.
- `credential.user!.displayName ?? email.split('@').first`:
  Kullanıcının adı varsa onu, yoksa e-posta adresinin @ işaretinden önceki kısmını kullanır.
  Örneğin `ahmet@gmail.com` → `ahmet`.
- **Neden bu kontrol var?** Kullanıcı başka bir cihazda kayıt olmuş ama Firestore'a
  profil kaydedilmemiş olabilir. Ya da veri migration sırasında eksik kalmış olabilir.

---

```dart
    return credential;
  }
```

**Satır 50:** `credential` döndürülür, çağıran taraf (AuthController) bunu kullanabilir.

---

```dart
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
```

**Satır 53-61:** `registerWithEmail` metodu
- `createUserWithEmailAndPassword()`: Firebase Auth'ta yeni bir kullanıcı hesabı oluşturur.
- Firebase sunucularına HTTP isteği gönderir.
- E-posta benzersiz değilse `email-already-in-use` hatası fırlatır.
- Şifre 6 karakterden kısa ise `weak-password` hatası fırlatır.
- Başarılı olursa kullanıcı otomatik olarak giriş yapmış olur.

---

```dart
    if (credential.user != null) {
      await _saveUserToFirestore(credential.user!, displayName);
    }

    return credential;
  }
```

**Satır 63-68:** Kayıt sonrası Firestore'a profil kaydetme
- Kayıt başarılıysa, kullanıcının profil bilgilerini Firestore'a kaydeder.
- `displayName` parametresi kullanıcıdan form aracılığıyla alınır.
- `credential` döndürülür.

---

```dart
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;
```

**Satır 70-75:** `signInWithGoogle` metodu — başlangıç
- `Future<UserCredential?>`: Null dönebilir çünkü kullanıcı iptal edebilir.
- `GoogleSignIn()`: Yeni bir GoogleSignIn instance'ı oluşturur.
- `googleSignIn.signIn()`: Google hesap seçim ekranını açar.
- Kullanıcı bir hesap seçerse `GoogleSignInAccount` döner.
- Kullanıcı iptal ederse `null` döner → metottan null ile çıkılır.

---

```dart
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw Exception('idToken null');
      }
```

**Satır 77-82:** Google kimlik doğrulama bilgilerini alma
- `googleUser.authentication`: Google'dan ID Token ve Access Token alır.
- Bu, arka planda Google'ın OAuth2.0 sunucusuna bir istek gönderir.
- `idToken` null ise hata fırlatılır. ID Token olmadan Firebase credential oluşturulamaz.
- ID Token'ın null olma nedenleri: SHA-1 yanlış, Web Client ID eksik, internet yok vb.

---

```dart
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
```

**Satır 84-87:** Firebase OAuth credential oluşturma
- `GoogleAuthProvider.credential()`: Firebase'in anlayacağı formatta bir credential oluşturur.
- `accessToken`: Google API'lerine erişim için (örn. Drive, Gmail).
- `idToken`: Kullanıcının kimliğini kanıtlayan JWT.
- Her iki token birlikte Firebase'e gönderilir.

---

```dart
      final userCredential = await _auth.signInWithCredential(credential);
```

**Satır 89:** Firebase ile oturum açma
- `signInWithCredential()`: OAuth credential'ı Firebase'e gönderir.
- Firebase, token'ları Google'ın sunucularıyla doğrular.
- İlk kez gelen kullanıcı için otomatik hesap oluşturur.
- Mevcut kullanıcı için oturum açar.
- `UserCredential` döner (içinde `User`, `additionalUserInfo` vb.).

---

```dart
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
```

**Satır 91-103:** Firestore profil kontrolü (Google girişi için)
- E-posta/şifre girişiyle aynı mantık: Firestore'da profil var mı kontrol et.
- Yoksa oluştur. Google hesabından gelen `displayName` kullanılır.
- `displayName` yoksa varsayılan olarak `'Kullanıcı'` kullanılır.

---

```dart
      return userCredential;
    } catch (e, stack) {
      developer.log('=== GOOGLE SIGN-IN ERROR ===');
      developer.log('Error: $e');
      developer.log('Stack: $stack');
      rethrow;
    }
  }
```

**Satır 105-112:** Hata yakalama ve loglama
- `catch (e, stack)`: Hem hatayı (`e`) hem de stack trace'i (`stack`) yakalar.
- `developer.log()`: Hatayı ve stack trace'i konsola yazar.
- `'=== GOOGLE SIGN-IN ERROR ==='`: Log mesajını aramada kolay bulmak için başlık.
- `rethrow`: Hatayı tekrar fırlatırır, böylece çağıran taraf (UI) hatayı yakalayıp
  kullanıcıya gösterebilir. Hatayı yutmuyoruz, sadece logluyoruz.

---

```dart
  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }
```

**Satır 114-117:** Çıkış metodu
- Önce Google'dan çıkış yapılır. Bu, Google hesap seçim ekranının sıfırlanmasını sağlar.
  Böylece bir sonraki girişte kullanıcı tekrar hesap seçebilir.
- Sonra Firebase Auth'tan çıkış yapılır. Bu, oturumu tamamen sonlandırır.
- Sıra önemlidir: önce Google, sonra Firebase.

---

```dart
  Future<void> _saveUserToFirestore(User user, String displayName) async {
    final Map<String, dynamic> data = {
      'uid': user.uid,
      'displayName': displayName,
      'email': user.email ?? '',
      'photoUrl': user.photoURL,
      'createdAt': FieldValue.serverTimestamp(),
    };
```

**Satır 119-127:** `_saveUserToFirestore` — veri hazırlığı
- Private metot (alt çizgi ile başlıyor), sadece bu sınıf içinde çağrılabilir.
- `Map<String, dynamic>`: Firestore'a yazılacak veriyi bir harita (map) olarak hazırlar.
- `user.uid`: Firebase Auth'un atadığı benzersiz kullanıcı kimliği (örn: `"a1b2c3d4..."`).
- `displayName`: Kullanıcının görünen adı.
- `user.email ?? ''`: E-posta null ise boş string kullan (null safety).
- `user.photoURL`: Google hesabından gelen profil fotoğrafı URL'si (null olabilir).
- `FieldValue.serverTimestamp()`: Firestore sunucusunun saatini kullanarak timestamp oluşturur.
  Cihaz saati yanlış olabilir, bu yüzden sunucu zamanı tercih edilir.

---

```dart
    final userRef = _firestore.collection('users').doc(user.uid);
    final doc = await userRef.get();

    if (!doc.exists) {
      data['totalImageCount'] = 0;
    }
```

**Satır 129-134:** totalImageCount kontrolü
- `userRef`: Firestore'daki `users/{uid}` belge referansı.
- `doc.get()`: Belgeyi getirir.
- `!doc.exists`: Belge yoksa (ilk kez kayıt oluyorsa) `totalImageCount` alanını 0 yap.
- Bu alan, kullanıcının toplam kaç resim paylaştığını sayar.
- Eğer belge zaten varsa (kullanıcı daha önce kayıt olmuş) `totalImageCount`'a dokunmaz,
  mevcut değer korunur.

---

```dart
    await userRef.set(data, SetOptions(merge: true));
  }
```

**Satır 136:** Firestore'a yazma
- `set()`: Belgeyi oluşturur veya değiştirir.
- `SetOptions(merge: true)`: **Çok önemli!** Mevcut alanları korur, sadece yeni alanları ekler
  veya değiştirir. `merge: true` olmasaydı, belgedeki diğer alanlar (bio, rating vb.) silinirdi.
- Örneğin: Kullanıcı bio'sunu güncellemiş, sonra tekrar giriş yapmış. `merge: true` sayesinde
  bio silinmez, sadece `uid`, `displayName`, `email`, `photoUrl`, `createdAt` güncellenir.

---

```dart
  Future<UserModel?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromJson(doc.data()!);
    }
    return null;
  }
}
```

**Satır 139-146:** `getUserData` metodu
- Verilen uid ile Firestore'dan kullanıcı verilerini okur.
- `doc.data()!`: Belge verilerini `Map<String, dynamic>` olarak döndürür.
- `UserModel.fromJson()`: Bu map'i `UserModel` nesnesine dönüştürür.
- Belge yoksa `null` döner.
- Bu metot, profil ekranında kullanıcı bilgilerini göstermek için kullanılır.

---

## 8. User Model — Tam Dosya İçeriği

**Dosya yolu:** `lib/features/auth/domain/user_model.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// Kullanıcı veri modeli
class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final String? bio;
  final double rating;
  final int ratingCount;
  final DateTime createdAt;
  final int totalImageCount;
```

**Satır 1:** Firestore paketi import. `Timestamp` sınıfını kullanmak için gerekli.

**Satır 3:** Dart doc comment. `///` ile başlayan yorumlar, IDE'de tooltip olarak gösterilir.

**Satır 4:** `class UserModel {` — Kullanıcı veri modeli sınıfı. Domain katmanında yer alır,
yani iş mantığı (business logic) ile ilgilidir, Firebase'den bağımsızdır.

**Satır 5:** `final String uid;` — Firebase Auth tarafından atanan benzersiz kullanıcı kimliği.
Her kullanıcı için farklıdır, hiç değişmez. Veritabanında anahtar (primary key) olarak kullanılır.

**Satır 6:** `final String displayName;` — Kullanıcının görünen adı (örn: "Ahmet Yılmaz").
Kayıt sırasında alınır veya Google hesabından gelir.

**Satır 7:** `final String email;` — Kullanıcının e-posta adresi. Benzersiz olmalıdır.

**Satır 8:** `final String? photoUrl;` — Profil fotoğrafı URL'si. `String?` ile null olabilir
belirtiliyor. Google girişinde otomatik gelir, e-posta/şifre ile null'dır.

**Satır 9:** `final String? bio;` — Kullanıcının kısa biyografisi. Null olabilir, başlangıçta null.

**Satır 10:** `final double rating;` — Kullanıcının ortalama puanı (0.0 - 5.0).
Varsayılan değer olarak 0.0 verilir.

**Satır 11:** `final int ratingCount;` — Kaç kişinin puan verdiği.
Varsayılan değer olarak 0 verilir.

**Satır 12:** `final DateTime createdAt;` — Hesabın oluşturulma tarihi.
Firestore'dan `Timestamp` olarak gelir, `DateTime`'a dönüştürülür.

**Satır 13:** `final int totalImageCount;` — Kullanıcının toplam yüklediği resim sayısı.
Takas sisteminde kullanıcının ne kadar aktif olduğunu gösterir.

---

```dart
  UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    this.bio,
    this.rating = 0.0,
    this.ratingCount = 0,
    required this.createdAt,
    this.totalImageCount = 0,
  });
```

**Satır 15-25:** Constructor
- `required` olanlar: uid, displayName, email, createdAt — bunlar zorunludur.
- `required` olmayanlar: photoUrl, bio — bunlar null olabilir, opsiyonel.
- Varsayılan değerler: `rating = 0.0`, `ratingCount = 0`, `totalImageCount = 0`.
- `this.uid` kısayolu: parametreyi doğrudan sınıf alanına atar (manuel atama gerekmez).

---

```dart
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      displayName: json['displayName'] ?? '',
      email: json['email'] ?? '',
      photoUrl: json['photoUrl'],
      bio: json['bio'],
      rating: (json['rating'] ?? 0.0).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      totalImageCount: json['totalImageCount'] ?? 0,
    );
  }
```

**Satır 27-39:** `fromJson` factory constructor
- **Factory constructor** nedir? Normal constructor her zaman yeni bir nesne oluşturur.
  Factory constructor ise istediğiniz logic ile nesne oluşturmanıza izin verir. Burada
  bir Map'ten UserModel oluşturuyoruz.
- `json['uid'] ?? ''`: Map'te 'uid' anahtarı yoksa boş string kullan. Null safety.
- `json['photoUrl']`: Null olabilir, ?? gerekmez çünkü zaten `String?` alan.
- `(json['rating'] ?? 0.0).toDouble()`: Firestore'da sayı `int` veya `double` olabilir.
  `.toDouble()` ile her durumda double'a çeviririz.
- `(json['createdAt'] as Timestamp).toDate()`: Firestore timestamp'ini Dart DateTime'a çevirir.
  `as Timestamp` type cast işlemidir, eğer değer Timestamp değilse hata verir.
- `json['totalImageCount'] ?? 0`: Bu alan eski kullanıcılar için olmayabilir, varsayılan 0.

**Neden fromJson kullanıyoruz?**
Firestore'dan veri okunduğunda `Map<String, dynamic>` formatında gelir. Bu map'i uygulama
içinde kullanılabilir bir Dart nesnesine dönüştürmemiz gerekir. Bu işleme **deserialization**
(serileştirme çözme) denir.

---

```dart
  /// Profil kaydederken veya güncellerken kullanılan metot
  /// totalImageCount alanını dahil etmiyoruz ki yanlışlıkla 0 yazılmasın
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
```

**Satır 41-55:** `toJson` metodu
- UserModel nesnesini Map'e dönüştürür (**serialization** — serileştirme).
- Firestore'a yazarken bu map kullanılır.
- **Kritik detay:** `totalImageCount` bu map'te YOK! Yorumda açıklandığı gibi,
  eğer dahil edilseydi ve rating henüz hesaplanmamışsa, `totalImageCount: 0` olarak
  Firestore'a yazılır ve mevcut değer silinirdi.
- `Timestamp.fromDate(createdAt)`: Dart DateTime'ı Firestore Timestamp'ine çevirir.
- `toJson()` ve `fromJson()` birlikte **serialization/deserialization** çiftini oluşturur.

---

```dart
  UserModel copyWith({
    String? displayName,
    String? photoUrl,
    String? bio,
    double? rating,
    int? ratingCount,
    int? totalImageCount,
  }) {
    return UserModel(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      createdAt: createdAt,
      totalImageCount: totalImageCount ?? this.totalImageCount,
    );
  }
}
```

**Satır 57-76:** `copyWith` metodu
- Dart'ta yaygın bir pattern'dir. Immutable (değişmez) nesnelerle çalışırken,
  bir alanı değiştirmek için tüm nesneyi yeniden oluşturmanız gerekir.
- `copyWith` sadece değiştirmek istediğiniz alanları geçirerek yeni bir nesne oluşturur.
- `displayName ?? this.displayName`: Yeni değer verilmişse onu kullan, yoksa mevcut değeri koru.
- `uid`, `email`, `createdAt` değişmez alanlardır, parametre olarak bile alınmazlar.
- Kullanım örneği:
  ```dart
  final updated = user.copyWith(displayName: 'Yeni İsim', bio: 'Merhaba!');
  // uid, email, createdAt korunur, sadece displayName ve bio değişir
  ```

---

## 9. Auth Controller — Tam Dosya İçeriği

**Dosya yolu:** `lib/features/auth/presentation/auth_controller.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/auth_repository.dart';

part 'auth_controller.g.dart';
```

**Satır 1:** `riverpod_annotation` paketi import.
- Riverpod'un kod üretme (code generation) paketidir.
- `@riverpod` anotasyonu ile provider'ları otomatik oluşturur.

**Satır 2:** Auth repository import. Controller, repository'yi kullanarak işlemleri yapar.

**Satır 4:** `part 'auth_controller.g.dart';`
- `part` directive: Bu dosyanın bir parçası olan `auth_controller.g.dart` dosyasını dahil eder.
- `.g.dart` dosyası `build_runner` tarafından otomatik üretilir.
- İçinde `authControllerProvider` tanımı bulunur.

---

```dart
@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {
    // Initial build
  }
```

**Satır 6-11:** AuthController sınıfı tanımı
- `@riverpod` anotasyonu: Riverpod'un bu sınıf için otomatik bir provider üretmesini sağlar.
  Üretilen provider'ın adı: `authControllerProvider` (sınıf adı küçük harfle başlar + Provider).
- `extends _$AuthController`: Oluşturulan `.g.dart` dosyasındaki base sınıftan kalıtım alır.
  Bu, Riverpod'un state yönetim mekanizmasını kullanmamızı sağlar.
- `FutureOr<void>`: State tipi. Bu controller state olarak veri tutmaz, sadece loading/error
  durumlarını yönetir. `FutureOr<void>` ile hem sync hem async başlangıç durumu desteklenir.
- `build()` metodu: Provider'ın başlangıç durumunu belirler. Boş bırakılır çünkü
  bu controller'ın tutacağı bir başlangıç verisi yoktur.

---

```dart
  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => 
      ref.read(authRepositoryProvider).signInWithEmail(email, password)
    );
  }
```

**Satır 13-18:** `signInWithEmail` metodu
- `state = const AsyncLoading()`: Önce state'i loading durumuna geçirir. UI'da spinner gösterilir.
- `AsyncValue.guard()`: Riverpod'un kolaylık metodudur. İçindeki fonksiyonu çalıştırır:
  - Başarılı olursa: `AsyncData<void>` (data durumu)
  - Hata olursa: `AsyncError<void>` (error durumu, exception yakalanır)
  - Bu, `try/catch` yazmaya gerek kalmadan hata yönetimi sağlar.
- `ref.read(authRepositoryProvider)`: AuthRepository instance'ını alır.
- `.signInWithEmail(email, password)`: Repository'deki giriş metodunu çağırır.

**`ref.read` vs `ref.watch` farkı:**
- `ref.read`: Bir kerelik okuma yapar. Fonksiyon içinde kullanılır.
- `ref.watch`: Sürekli dinler. `build()` metodunda veya UI'da kullanılır.

---

```dart
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
```

**Satır 20-33:** `registerWithEmail` metodu
- `signInWithEmail` ile aynı pattern'i izler.
- `registerWithEmail` repository metodunu çağırır.
- `displayName` parametresi de geçirilir.

---

```dart
  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => 
      ref.read(authRepositoryProvider).signInWithGoogle()
    );
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => 
      ref.read(authRepositoryProvider).signOut()
    );
  }
}
```

**Satır 35-47:** `signInWithGoogle` ve `signOut` metodları
- Aynı loading/guard pattern'ini izlerler.
- `signInWithGoogle()`: Google hesap seçimini başlatır.
- `signOut()`: Oturumu sonlandırır.

**Tüm metodlarda aynı pattern:**
1. State → Loading
2. Repository metodunu çağır
3. State → Data (başarılı) veya Error (başarısız)
4. UI, state değişikliğini otomatik algılar ve buna göre güncellenir

Bu pattern sayesinde UI kodunda try/catch yazmaya gerek kalmaz. Sadece `ref.watch(authControllerProvider)`
ile state'i izlemek yeterlidir.

---

## 10. Login Screen — Tam Dosya İçeriği

**Dosya yolu:** `lib/features/auth/presentation/login_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_controller.dart';
```

**Satır 1:** Flutter Material Design kütüphanesi. Widget'lar, temalar, ikonlar vb.

**Satır 2:** Riverpod. `ConsumerStatefulWidget`, `ConsumerState`, `ref` buradan gelir.

**Satır 3:** GoRouter. Sayfalar arası yönlendirme (navigation) için. `context.push()`, `context.pop()`.

**Satır 4:** Firebase Auth. Şifre sıfırlama e-postası göndermek için doğrudan kullanılıyor.

**Satır 5:** Auth controller. `authControllerProvider` burada tanımlı.

---

```dart
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}
```

**Satır 7-12:** `LoginScreen` widget sınıfı
- `ConsumerStatefulWidget`: Riverpod'un stateful widget'ı. Normal `StatefulWidget`'tan
  farkı: `ref` nesnesine erişebilir. `ref` ile provider'ları okuyabilir ve dinleyebiliriz.
- `const` constructor: Derleme zamanında sabit nesne oluşturur, performansı artırır.
- `super.key`: Key parametresini üst sınıfa geçirir. Widget'ın kimliğini belirler.
- `createState()`: Widget'ın state'ini oluşturur. `_LoginScreenState` private state sınıfı.

---

```dart
class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
```

**Satır 14-17:** State sınıfı ve controller'lar
- `_LoginScreenState`: Alt çizgi ile private. Sadece bu dosyada erişilebilir.
- `ConsumerState<LoginScreen>`: LoginScreen widget'ının state'i. `ref` içerir.
- `_formKey`: Form doğrulama (validation) için global anahtar. `Form` widget'ına bağlanır
  ve `validate()` çağrılarak tüm alanların kurallara uygun olup olmadığını kontrol eder.
- `_emailController`: E-posta input alanının metnini kontrol eder. `text` özelliği ile
  girilen değeri okuyabilirsiniz.
- `_passwordController`: Şifre input alanının metnini kontrol eder.

---

```dart
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
```

**Satır 19-24:** `dispose` metodu
- Widget ağacından kaldırıldığında (sayfa değiştiğinde) çağrılır.
- Controller'ların `dispose()` edilmesi **bellek sızıntısını önler**.
- TextEditingController, native (platform) kaynakları kullanır ve manuel olarak serbest
  bırakılması gerekir.
- `super.dispose()` her zaman son çağrılmalıdır.

---

```dart
  void _onLogin() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authControllerProvider.notifier).signInWithEmail(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );

      if (mounted && ref.read(authControllerProvider).hasError) {
        final error = ref.read(authControllerProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Giriş hatası: ${error.toString()}')),
        );
      }
    }
  }
```

**Satır 26-40:** `_onLogin` metodu
- `_formKey.currentState!.validate()`: Tüm form alanlarını doğrular. Her `TextFormField`'ın
  `validator` fonksiyonunu çalıştırır. Hepsi `null` dönerse (hata yoksa) `true` döner.
- `ref.read(authControllerProvider.notifier)`: Controller'ın kendisini (notifier) alır.
  Provider'ın state'ini değil, metodlarını çağırabileceğimiz nesneyi alır.
- `.signInWithEmail(...)`: Controller'daki giriş metodunu çağırır.
- `.trim()`: Baş ve sondaki boşlukları kaldırır. Kullanıcı yanlışlıkla boşluk bırakmış olabilir.
- `mounted`: Widget hâlâ widget ağacında mı kontrolü. Asenkron işlem sonrası widget
  kaldırılmış olabilir (kullanıcı sayfadan çıkmış olabilir). Kaldırılmış widget'ın
  context'ini kullanmak hata verir.
- `ref.read(authControllerProvider).hasError`: İşlem başarısız oldu mu kontrolü.
- `ScaffoldMessenger.of(context).showSnackBar()`: Ekranda kısa bir mesaj gösterir.

---

```dart
  void _onGoogleLogin() async {
    await ref.read(authControllerProvider.notifier).signInWithGoogle();

    if (mounted && ref.read(authControllerProvider).hasError) {
      final error = ref.read(authControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Giriş hatası: ${error.toString()}')),
      );
    }
  }
```

**Satır 42-51:** `_onGoogleLogin` metodu
- Google Sign-In butonuna basıldığında çağrılır.
- Controller'daki `signInWithGoogle()` metodunu çağırır.
- Hata mesajı Google'a özel ("Google Giriş hatası") olarak gösterilir.

---

```dart
  void _showResetPasswordDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Şifremi Sıfırla'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'E-posta adresinize şifre sıfırlama bağlantısı gönderilecek.'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-posta',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
          ],
        ),
```

**Satır 53-73:** Şifre sıfırlama dialog'u
- `showDialog()`: Flutter'ın dialog gösterme fonksiyonu. Modal bir pencere açar.
- `AlertDialog`: Material Design dialog widget'ı. Başlık, içerik, aksiyonlar içerir.
- `mainAxisSize: MainAxisSize.min`: Column'un sadece çocuklarının boyutu kadar yer kaplamasını sağlar.
  Aksi halde Column ekranı tamamen kaplamaya çalışır.
- `TextField`: Form validator'ı olmayan basit metin girdi alanı. (`TextFormField` değil,
  çünkü bu bağımsız bir alan, form parçası değil.)

---

```dart
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () async {
              final email = controller.text.trim();
              if (email.isEmpty || !email.contains('@')) return;
              try {
                await FirebaseAuth.instance
                    .sendPasswordResetEmail(email: email);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Sıfırlama bağlantısı gönderildi')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Hata: $e')),
                  );
                }
              }
            },
            child: const Text('Gönder'),
          ),
        ],
```

**Satır 75-105:** Dialog aksiyonları
- `TextButton`: Metin stili buton (düz metin, arka plansız). İptal butonu için.
- `Navigator.pop(context)`: Dialog'u kapatır.
- `FilledButton`: Dolu arka planlı buton. Gönder butonu için.
- `FirebaseAuth.instance.sendPasswordResetEmail(email: email)`:
  Firebase'in doğrudan API'sini kullanarak şifre sıfırlama e-postası gönderir.
  Repository veya controller kullanmıyor çünkü bu basit bir işlem.
- `context.mounted`: Dialog'un context'i hâlâ aktif mi kontrolü. Asenkron işlem sonrası
  dialog kapatılmış olabilir.
- İki `context` karışıklığı: Dış context (sayfanın) ve iç context (dialog'un).
  Builder fonksiyonundaki `context` parametresi dialog'un context'idir.

---

```dart
      ),
    );
  }
```

**Satır 106-108:** Dialog kapanış parantezleri.

---

```dart
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;
```

**Satır 110-113:** `build` metodu başlangıcı
- `ref.watch(authControllerProvider)`: Controller'ın state'ini dinler.
  State değiştiğinde (loading, data, error) widget otomatik olarak yeniden oluşturulur.
- `authState`: `AsyncValue<void>` tipinde. Üç durum olabilir:
  - `AsyncLoading()`: İşlem devam ediyor
  - `AsyncData()`: İşlem başarılı
  - `AsyncError()`: İşlem başarısız
- `colorScheme`: Material 3 renk şeması. Uygulamanın temasından renkleri alır.
  Koyu/açık temaya otomatik uyum sağlar.

---

```dart
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
```

**Satır 115-122:** Widget ağacı başlangıcı
- `Scaffold`: Material Design sayfa yapısı. AppBar, body, FAB vb. içerir.
- `SafeArea`: Çentikli (notch) ekranlarda ve alt çubuk (bottom bar) olan cihazlarda
  içeriği güvenli alana taşır. Status bar ve navigation bar ile örtüşmez.
- `SingleChildScrollView`: İçeriği kaydırılabilir yapar. Klavye açıldığında alan daralır
  ve kullanıcı aşağı kaydırabilir.
- `Form`: Form alanlarını gruplandırır. `_formKey` ile doğrulama yapılabilir.
- `crossAxisAlignment: CrossAxisAlignment.stretch`: Çocuklar yatayda tam genişliği kaplar.

---

```dart
                const SizedBox(height: 60),
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.swap_horiz_rounded,
                            color: Colors.white, size: 40),
                      ),
```

**Satır 124-144:** Logo bölümü
- `SizedBox(height: 60)`: Üstten 60 piksel boşluk bırakır.
- `Container`: Kutu widget'ı. Genişlik, yükseklik, dekorasyon vb. ayarlanabilir.
- `BoxDecoration`: Kutunun görsel özellikleri (renk, border radius, gölge).
- `borderRadius: BorderRadius.circular(20)`: Köşeleri yuvarlatır (20 piksel yarıçap).
- `boxShadow`: Gölge efekti. Primary rengin %30 opaklık ile blur efekti.
- `Icon(Icons.swap_horiz_rounded)`: Takas ikonu. Takaš bir takas uygulaması olduğu için
  yatay ok değiştirme ikonu kullanılmış.

---

```dart
                      const SizedBox(height: 16),
                      Text(
                        'Takaş',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Yakınındakilerle takas yap',
                        style: TextStyle(
                          fontSize: 15,
                          color: colorScheme.outline,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
```

**Satır 145-166):** Uygulama adı ve slogan
- `w800`: En kalın font ağırlığı (extra bold).
- `letterSpacing: -0.5`: Harfler arası mesafeyi biraz azaltır, daha kompakt görünür.
- `colorScheme.onSurface`: Yüzey rengi üzerindeki metin rengi (koyu temada beyaz, açık temada siyah).
- `colorScheme.outline`: İkincil metin rengi. Daha soluk görünür.

---

```dart
                const SizedBox(height: 48),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-posta',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !value.contains('@')) {
                      return 'Geçerli bir e-posta girin';
                    }
                    return null;
                  },
                ),
```

**Satır 167-183:** E-posta giriş alanı
- `TextFormField`: Form içinde kullanılan metin girdi alanı. `validator` özelliği vardır.
- `controller: _emailController`: Girilen metni bu controller üzerinden okuruz.
- `labelText`: Alanın etiketi (üzerinde yazan metin).
- `prefixIcon`: Alanın solundaki ikon.
- `keyboardType: TextInputType.emailAddress`: E-posta klavyesi gösterir (@ işareti kolay erişim).
- `validator`: Doğrulama fonksiyonu. `null` dönerse geçerli, String dönerse hata mesajı.
  Burada: null, boş veya @ işareti yoksa hata verir.

---

```dart
                const SizedBox(height: 14),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Şifre',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Şifre en az 6 karakter olmalıdır';
                    }
                    return null;
                  },
                ),
```

**Satır 184-198):** Şifre giriş alanı
- `obscureText: true`: Girilen karakterleri nokta (•) olarak gösterir. Güvenlik için.
- `validator`: En az 6 karakter kontrolü. Firebase Auth'un minimum şifre uzunluğu 6'dır.

---

```dart
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _showResetPasswordDialog(),
                    child: const Text('Şifremi Unuttum'),
                  ),
                ),
```

**Satır 199-206:** Şifremi unuttum butonu
- `Align(alignment: Alignment.centerRight)`: Butonu sağa hizalar.
- `TextButton`: Düz metin buton, arka plansız.
- `_showResetPasswordDialog()`: Şifre sıfırlama dialog'unu açar.

---

```dart
                const SizedBox(height: 16),
                SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: authState.isLoading ? null : _onLogin,
                    child: authState.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: Colors.white),
                          )
                        : const Text('Giriş Yap'),
                  ),
                ),
```

**Satır 207-221:** Giriş butonu
- `SizedBox(height: 52)`: Buton yüksekliğini 52 piksel olarak sabitler.
- `FilledButton`: Material 3 dolu buton. Primary renk ile doldurulur.
- `authState.isLoading ? null : _onLogin`: Loading sırasında buton devre dışı bırakılır (`null`).
  Kullanıcı birden fazla tıklama yapamaz.
- `CircularProgressIndicator`: Dönen yükleme göstergesi. Loading sırasında buton metni
  yerine gösterilir.
- `strokeWidth: 2.5`: İlerleme çubuğunun kalınlığı.

---

```dart
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: Divider(color: colorScheme.outlineVariant)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('veya',
                          style: TextStyle(
                              color: colorScheme.outline,
                              fontWeight: FontWeight.w500)),
                    ),
                    Expanded(child: Divider(color: colorScheme.outlineVariant)),
                  ],
                ),
```

**Satır 222-235):** "veya" ayırıcı
- `Row`: Yatay düzen. Çocuklar yan yana dizilir.
- `Expanded`: Çocuk, kalan tüm alanı kaplar. İki `Expanded` çizgi eşit genişlikte olur.
- `Divider`: Yatay çizgi. `outlineVariant` rengi ile soluk görünür.
- Ortada "veya" metni, her iki yanında çizgi. Klasik bir UI pattern'dir.

---

```dart
                const SizedBox(height: 20),
                SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: authState.isLoading ? null : _onGoogleLogin,
                    icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
                    label: const Text('Google ile Devam Et'),
                  ),
                ),
```

**Satır 236-244:** Google Sign-In butonu
- `OutlinedButton.icon`: Kenarlıklı (outlined) buton, ikon ve metin ile.
- `Icons.g_mobiledata_rounded`: Google "G" logosu benzeri ikon.
- Loading sırasında devre dışı bırakılır (e-posta butonuyla aynı mantık).

---

```dart
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Hesabın yok mu?',
                        style: TextStyle(
                            color: colorScheme.outline,
                            fontWeight: FontWeight.w500)),
                    TextButton(
                      onPressed: () => context.push('/register'),
                      child: const Text('Kayıt Ol'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

**Satır 245-266:** Alt bölüm ve sayfa kapanışı
- "Hesabın yok mu?" metni + "Kayıt Ol" butonu yan yana.
- `context.push('/register')`: GoRouter ile kayıt sayfasına gider. `push` kullanıldığı için
  geri butonu ile login'e dönülebilir (`go` olsaydı dönülemezdi).
- Tüm widget ağacı kapatılır.

---

## 11. Register Screen — Tam Dosya İçeriği

**Dosya yolu:** `lib/features/auth/presentation/register_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'auth_controller.dart';
```

**Satır 1-4:** Import'lar
- Login ekranıyla aynı import'lar, fakat `firebase_auth` import'u yok çünkü register ekranında
  doğrudan Firebase API kullanılmıyor (şifre sıfırlama yok).

---

```dart
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
```

**Satır 6-17:** Register ekranı sınıfı ve state
- Login ile aynı yapı: `ConsumerStatefulWidget` ve `ConsumerState`.
- **Fark:** Login'e ek olarak `_displayNameController` var. Kayıt sırasında kullanıcı
  ismini de alıyoruz.
- `_formKey`: Form doğrulama anahtarı.
- Üç TextEditingController: isim, e-posta, şifre.

---

```dart
  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
```

**Satır 19-25:** `dispose`
- Üç controller'ın da dispose edilmesi gerekiyor.

---

```dart
  void _onRegister() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authControllerProvider.notifier).registerWithEmail(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            displayName: _displayNameController.text.trim(),
          );

      if (mounted && ref.read(authControllerProvider).hasError) {
        final error = ref.read(authControllerProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kayıt hatası: ${error.toString()}')),
        );
      }
    }
  }
```

**Satır 27-42:** `_onRegister` metodu
- Login ile aynı pattern: form doğrula → controller metodu çağır → hata kontrol et.
- `registerWithEmail()`: `email`, `password` ve `displayName` parametrelerini geçirir.
- `displayName`: Kullanıcının girdiği isim, Firestore'a kaydedilecek.

---

```dart
  void _onGoogleRegister() async {
    await ref.read(authControllerProvider.notifier).signInWithGoogle();

    if (mounted && ref.read(authControllerProvider).hasError) {
      final error = ref.read(authControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Kayıt hatası: ${error.toString()}')),
      );
    }
  }
```

**Satır 44-53:** `_onGoogleRegister`
- Login ekranındaki Google girişiyle aynı. `signInWithGoogle()` hem kayıt hem giriş için
  kullanılır. Firebase ilk kez gelen kullanıcı için otomatik hesap oluşturur.

---

```dart
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
```

**Satır 55-57:** `build` metodu
- `authState` ile loading durumunu izliyoruz.

---

```dart
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayıt Ol'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
```

**Satır 59-68):** Sayfa yapısı
- `AppBar`: Üst çubuk. Otomatik geri butonu içerir (GoRouter push ile geldiğimiz için).
- `padding: const EdgeInsets.all(24.0)`: Her taraftan 24 piksel boşluk.

---

```dart
              const SizedBox(height: 16),
              Text(
                'Yeni Hesap Oluştur',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              const Text('Yakınındaki takas dünyasına katıl!'),
              const SizedBox(height: 32),
```

**Satır 69-76):** Başlık bölümü
- `headlineMedium`: Material 3 tema başlık stili. Otomatik olarak uygun font büyüklüğü ve ağırlığı.

---

```dart
              TextFormField(
                controller: _displayNameController,
                decoration: const InputDecoration(
                  labelText: 'İsim Soyisim',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen isminizi girin';
                  }
                  return null;
                },
              ),
```

**Satır 77-89:** İsim giriş alanı
- `Icons.person_outline`: Kişi ikonu.
- Validator: Boş olup olmadığını kontrol eder. Minimum uzunluk yok (tek karakter de kabul eder).

---

```dart
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-posta',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Geçerli bir e-posta girin';
                  }
                  return null;
                },
              ),
```

**Satır 90-104:** E-posta giriş alanı — login ekranıyla aynı.

---

```dart
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Şifre',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Şifre en az 6 karakter olmalıdır';
                  }
                  return null;
                },
              ),
```

**Satır 105-119:** Şifre giriş alanı — login ekranıyla aynı.

---

```dart
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: authState.isLoading ? null : _onRegister,
                  child: authState.isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Kayıt Ol'),
                ),
              ),
```

**Satır 120-129:** Kayıt butonu
- `ElevatedButton`: Login'deki `FilledButton`'dan farklı olarak elevated stilde.
- `width: double.infinity`: Buton tam genişliği kaplar.
- Loading kontrolü login ile aynı.

---

```dart
              const SizedBox(height: 16),
              const Text('veya'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: authState.isLoading ? null : _onGoogleRegister,
                  icon: const Icon(Icons.login),
                  label: const Text('Google ile Kayıt Ol'),
                ),
              ),
```

**Satır 130-140:** Google ile kayıt butonu
- Basit bir "veya" ayırıcı (login'deki çizgili versiyon yerine düz metin).
- `Icons.login`: Giriş ikonu.

---

```dart
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Zaten hesabın var mı? Giriş Yap'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**Satır 141-152:** Alt kısım ve sayfa kapanışı
- `context.pop()`: GoRouter ile önceki sayfaya (login) döner.
- Login'deki `context.push('/register')` ile buradaki `context.pop()` birbirini tamamlar.

---

## 12. Change Email Screen — Tam Dosya İçeriği

**Dosya yolu:** `lib/features/profile/presentation/change_email_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers.dart';
```

**Satır 1:** Material Design kütüphanesi.
**Satır 2:** Riverpod — `ConsumerStatefulWidget` ve `ref` için.
**Satır 3:** GoRouter — `context.pop()` için.
**Satır 4:** Core providers — `firebaseAuthProvider`, `firestoreProvider`, `authStateProvider` için.
- **Dikkat:** Bu dosyada `auth_controller.dart` import edilmiyor. Çünkü e-posta değiştirme
  işlemi doğrudan Firebase Auth API ile yapılıyor, controller üzerinden değil.

---

```dart
class ChangeEmailScreen extends ConsumerStatefulWidget {
  const ChangeEmailScreen({super.key});

  @override
  ConsumerState<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends ConsumerState<ChangeEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
```

**Satır 6-18):** State sınıfı ve alanları
- `_isLoading`: Loading durumunu yönetmek için yerel state değişkeni. Controller kullanmıyoruz
  çünkü bu ekran kendi işlemini yönetiyor.
- `_obscurePassword`: Şifre alanının gizli/açık durumunu tutar. Göz ikonu ile toggle edilir.

---

```dart
  @override
  void initState() {
    super.initState();
    final user = ref.read(authStateProvider).value;
    if (user != null) {
      _emailController.text = user.email ?? '';
    }
  }
```

**Satır 20-27:** `initState` — mevcut e-postayı gösterme
- Widget oluşturulduğunda bir kez çağrılır.
- `ref.read(authStateProvider).value`: `authStateProvider`, `StreamProvider<User?>`'dır.
  `.value` ile mevcut kullanıcıyı alırız.
- `user.email ?? ''`: Mevcut e-posta adresini text controller'a yazar, böylece kullanıcı
  mevcut e-postasını görür ve değiştirebilir.

---

```dart
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
```

**Satır 29-34:** Controller'ları temizleme.

---

```dart
  Future<void> _changeEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final auth = ref.read(firebaseAuthProvider);
      final user = auth.currentUser;
      if (user == null) return;
```

**Satır 36-43:** `_changeEmail` — doğrulama ve Firebase Auth erişimi
- `setState(() => _isLoading = true)`: Loading göstergesini aktif eder.
- `ref.read(firebaseAuthProvider)`: FirebaseAuth instance'ını alır.
- `auth.currentUser`: Şu an giriş yapmış kullanıcı. Null ise (olmaması gerekir) return.

---

```dart
      await user.verifyBeforeUpdateEmail(_emailController.text.trim());
```

**Satır 45:** E-posta güncelleme
- `verifyBeforeUpdateEmail()`: Kullanıcının e-posta adresini günceller, ancak güncellemeden
  önce yeni e-posta adresine bir doğrulama e-postası gönderir. Kullanıcı bu e-postadaki
  bağlantıya tıklayana kadar e-posta değişmez.
- **Alternatif:** `updateEmail()` hemen günceller (doğrulama gerektirmez), ama bu metod
  artık `@deprecated` olarak işaretlenmiştir. `verifyBeforeUpdateEmail()` tercih edilir.
- Bu metod **"recent login" gerektirir**: Kullanıcının son giriş yapması gereklidir.
  Uzun süredir giriş yapmamışsa `requires-recent-login` hatası alır.

---

```dart
      await _updateEmailInFirestore(user.uid, _emailController.text.trim());
```

**Satır 47:** Firestore'daki e-postayı da güncelle
- Firebase Auth'daki e-posta güncellendi, şimdi Firestore'daki profil belgesindeki
  e-posta alanını da güncellemeliyiz. Aksi halde Firestore'da eski e-posta kalır.

---

```dart
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('E-posta başarıyla güncellendi'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
```

**Satır 49-57:** Başarı durumu
- Yeşil renkli SnackBar ile başarı mesajı gösterilir.
- `context.pop()`: Önceki sayfaya döner.

---

```dart
    } catch (e) {
      if (mounted) {
        String message = 'Bir hata oluştu';
        if (e.toString().contains('requires-recent-login')) {
          message = 'Bu işlem için yeniden giriş yapmanız gerekiyor';
        } else if (e.toString().contains('email-already-in-use')) {
          message = 'Bu e-posta adresi zaten kullanımda';
        } else if (e.toString().contains('invalid-email')) {
          message = 'Geçersiz e-posta adresi';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
```

**Satır 58-74:** Hata yakalama
- `requires-recent-login`: Kullanıcı uzun süre önce giriş yapmış. Yeniden giriş gerekli.
- `email-already-in-use`: Bu e-posta başka bir kullanıcı tarafından kullanılıyor.
- `invalid-email`: Geçersiz e-posta formatı.
- Her durumda kırmızı SnackBar ile Türkçe hata mesajı gösterilir.
- `finally`: Başarılı veya başarısız, her durumda loading'i kapat.

---

```dart
  Future<void> _updateEmailInFirestore(String uid, String newEmail) async {
    try {
      await ref.read(firestoreProvider).collection('users').doc(uid).update({
        'email': newEmail,
      });
    } catch (_) {}
  }
```

**Satır 77-83:** Firestore'da e-posta güncelleme
- `firestoreProvider` üzerinden Firestore instance'ını alır.
- `collection('users').doc(uid).update({'email': newEmail})`: Sadece `email` alanını günceller.
- `update()` metodunda sadece belirtilen alanlar güncellenir, diğer alanlar etkilenmez.
- `catch (_) {}`: Hata yutulur. Firestore güncellemesi başarısız olsa bile kullanıcıya
  Firebase Auth güncellemesinin başarılı olduğu bildirilir. Bu bilinçli bir tasarım kararı.

---

```dart
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('E-posta Değiştir'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
```

**Satır 85-99):** build metodu ve sayfa yapısı
- Standart Scaffold + AppBar + SingleChildScrollView + Form yapısı.

---

```dart
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'E-posta adresinizi değiştirmek için yeniden giriş yapmanız istenebilir.',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
```

**Satır 100-121):** Bilgi kutusu
- `primaryContainer.withValues(alpha: 0.3)`: Primary rengin soluk versiyonu arka plan olarak.
- `info_outline` ikonu ile bilgi mesajı. Kullanıcıya e-posta değişikliğinde yeniden giriş
  gerekebileceği hatırlatılır.

---

```dart
              const SizedBox(height: 24),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Yeni E-posta Adresi',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'E-posta gerekli';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Geçerli bir e-posta girin';
                  }
                  return null;
                },
              ),
```

**Satır 122-139:** Yeni e-posta giriş alanı
- initState'te mevcut e-posta ile doldurulmuştu, kullanıcı bunu değiştirir.
- Validator: boş mu, @ ve . içeriyor mu kontrol eder.

---

```dart
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Mevcut Şifreniz',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Şifre gerekli' : null,
              ),
```

**Satır 140-159:** Şifre giriş alanı
- `obscureText: _obscurePassword`: State'e bağlı olarak şifre gizli/açık.
- `suffixIcon`: Alanın sağındaki ikon buton. Göz ikonu ile şifreyi göster/gizle toggle.
- `Icons.visibility_outlined`: Göz açık ikonu (şifre gizli iken gösterilir).
- `Icons.visibility_off_outlined`: Göz kapalı ikonu (şifre açık iken gösterilir).
- `setState(() => _obscurePassword = !_obscurePassword)`: Toggle işlemi.

---

```dart
              const SizedBox(height: 32),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _changeEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('E-postayı Güncelle'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**Satır 160-186):** Güncelle butonu ve sayfa kapanışı
- `ElevatedButton.styleFrom()`: Buton stilini özelleştirir.
- `backgroundColor: colorScheme.primary`: Primary renk arka plan.
- `foregroundColor: colorScheme.onPrimary`: Primary üzerindeki metin rengi (genellikle beyaz).
- `RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))`: 12 piksel yuvarlatılmış köşeler.
- Loading sırasında dönen indicator gösterilir.

---

## 13. Change Password Screen — Tam Dosya İçeriği

**Dosya yolu:** `lib/features/profile/presentation/change_password_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers.dart';
```

**Satır 1-4:** Import'lar — Change Email ile aynı.

---

```dart
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
```

**Satır 6-22):** State sınıfı ve alanları
- **Üç TextEditingController:** Mevcut şifre, yeni şifre, yeni şifre tekrarı.
- **Üç gizlilik değişkeni:** Her alan için ayrı obscure durumu (göster/gizle).
- `_isLoading`: Yükleme durumu.

---

```dart
  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
```

**Satır 24-30:** Üç controller'ın dispose edilmesi.

---

```dart
  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final auth = ref.read(firebaseAuthProvider);
      final user = auth.currentUser;
      if (user == null) return;

      await user.updatePassword(_newPasswordController.text.trim());
```

**Satır 32-41:** `_changePassword` — Firebase Auth çağrısı
- `user.updatePassword()`: Firebase Auth kullanıcısının şifresini günceller.
- Parametre olarak yeni şifreyi alır (düz metin, Firebase sunucusunda hash'lenir).
- **Önemli:** Bu metod da "recent login" gerektirir. Uzun süredir giriş yapılmamışsa
  `requires-recent-login` hatası alırsınız.
- Güvenlik nedeniyle, Firebase kullanıcının gerçekten kullanıcı olduğunu doğrulamak ister.

---

```dart
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Şifre başarıyla güncellendi'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
```

**Satır 43-51:** Başarı mesajı ve sayfa kapatma.

---

```dart
    } catch (e) {
      if (mounted) {
        String message = 'Bir hata oluştu';
        if (e.toString().contains('requires-recent-login')) {
          message = 'Bu işlem için yeniden giriş yapmanız gerekiyor';
        } else if (e.toString().contains('weak-password')) {
          message = 'Şifre çok zayıf (en az 6 karakter)';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
```

**Satır 52-67:** Hata yakalama
- `requires-recent-login`: Yeniden giriş gerekli.
- `weak-password`: Şifre çok zayıf (6 karakterden kısa).
- Kırmızı SnackBar ile Türkçe hata mesajı.

---

```dart
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Şifre Değiştir'),
      ),
```

**Satır 69-76:** Sayfa yapısı.

---

```dart
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Şifrenizi değiştirmek için yeniden giriş yapmanız istenebilir.',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
```

**Satır 84-105):** Bilgi kutusu — Change Email ile aynı yapı, farklı mesaj.

---

```dart
              const SizedBox(height: 24),
              TextFormField(
                controller: _currentPasswordController,
                obscureText: _obscureCurrent,
                decoration: InputDecoration(
                  labelText: 'Mevcut Şifreniz',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureCurrent
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () =>
                        setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Mevcut şifre gerekli'
                    : null,
              ),
```

**Satır 106-124:** Mevcut şifre alanı
- Kullanıcının şu anki şifresini girer. Bu, `updatePassword()` tarafından doğrudan
  kullanılmaz (Firebase recent login için kullanır), ancak UI'da bir güvenlik katmanı
  olarak bulunur.

---

```dart
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                obscureText: _obscureNew,
                decoration: InputDecoration(
                  labelText: 'Yeni Şifre',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureNew
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Yeni şifre gerekli';
                  if (value.length < 6) return 'En az 6 karakter olmalı';
                  return null;
                },
              ),
```

**Satır 125-145:** Yeni şifre alanı
- En az 6 karakter kontrolü.

---

```dart
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: 'Yeni Şifre (Tekrar)',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Şifre tekrarı gerekli';
                  if (value != _newPasswordController.text) {
                    return 'Şifreler eşleşmiyor';
                  }
                  return null;
                },
              ),
```

**Satır 146-169:** Şifre tekrar alanı
- `value != _newPasswordController.text`: İki şifre alanının aynı olup olmadığını kontrol eder.
  Eğer farklıysa "Şifreler eşleşmiyor" hatası gösterilir.
- Bu kontrol client-side'da yapılır, Firebase'e gönderilmeden önce.

---

```dart
              const SizedBox(height: 32),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Şifreyi Güncelle'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**Satır 170-196):** Güncelle butonu ve sayfa kapanışı — Change Email ile aynı yapı.

---

## Ek: Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER                          │
│                                                                     │
│  ┌──────────────┐  ┌───────────────┐  ┌──────────────┐             │
│  │ LoginScreen  │  │ RegisterScreen│  │ ChangeEmail  │             │
│  │              │  │               │  │ ChangePass   │             │
│  └──────┬───────┘  └───────┬───────┘  └──────┬───────┘             │
│         │                  │                  │                      │
│         ▼                  ▼                  │                      │
│  ┌──────────────────────────────────┐         │                     │
│  │       AuthController             │         │                     │
│  │  (Riverpod @riverpod notifier)   │         │                     │
│  └──────────────┬───────────────────┘         │                     │
│                 │                              │                     │
├─────────────────┼──────────────────────────────┼─────────────────────┤
│                 │         DATA LAYER           │                     │
│                 ▼                              ▼                     │
│  ┌────────────────────────┐    ┌──────────────────────┐             │
│  │    AuthRepository      │    │  firebaseAuthProvider │             │
│  │  signInWithEmail()     │    │  firestoreProvider    │             │
│  │  registerWithEmail()   │    │  (doğrudan kullanım) │             │
│  │  signInWithGoogle()    │    └──────────────────────┘             │
│  │  signOut()             │                                         │
│  └──────────┬─────────────┘                                         │
│             │                                                        │
├─────────────┼───────────────────────────────────────────────────────┤
│             │              DOMAIN LAYER                             │
│             ▼                                                        │
│  ┌────────────────┐   ┌──────────────────┐                         │
│  │   UserModel    │   │   core/providers │                         │
│  │   fromJson()   │   │   authStateProv. │                         │
│  │   toJson()     │   │                  │                         │
│  │   copyWith()   │   │                  │                         │
│  └────────────────┘   └──────────────────┘                         │
│                                                                      │
├──────────────────────────────────────────────────────────────────────┤
│                      FIREBASE SERVICES                               │
│                                                                      │
│  ┌──────────────┐   ┌───────────────────┐   ┌────────────────┐     │
│  │ FirebaseAuth │   │ Cloud Firestore   │   │ Google Sign-In │     │
│  │              │   │                   │   │                │     │
│  │ createUser() │   │ collection/users  │   │ signIn()       │     │
│  │ signIn()     │   │ doc(uid)          │   │ authentication │     │
│  │ signOut()    │   │ set() / get()     │   │                │     │
│  └──────────────┘   └───────────────────┘   └────────────────┘     │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Ek: Veri Akışı

### Kayıt Akışı
```
Kullanıcı formu doldurur
  → RegisterScreen._onRegister()
    → Form.validate()
    → AuthController.registerWithEmail()
      → state = AsyncLoading()
      → AuthRepository.registerWithEmail()
        → FirebaseAuth.createUserWithEmailAndPassword()  ← Firebase API
        → AuthRepository._saveUserToFirestore()
          → FirebaseFirestore.collection('users').doc(uid).set()  ← Firestore API
      → state = AsyncData / AsyncError
  → authStateProvider güncellenir (User? yayınlar)
  → Uygulama ana ekrana yönlendirir
```

### Google Sign-In Akışı
```
Kullanıcı "Google ile devam et" butonuna basar
  → LoginScreen._onGoogleLogin()
    → AuthController.signInWithGoogle()
      → state = AsyncLoading()
      → AuthRepository.signInWithGoogle()
        → GoogleSignIn().signIn()          ← Hesap seçim ekranı
        → googleUser.authentication        ← Token alma
        → GoogleAuthProvider.credential()  ← Firebase credential
        → FirebaseAuth.signInWithCredential()  ← Firebase API
        → Firestore profil kontrolü
      → state = AsyncData / AsyncError
  → authStateProvider güncellenir
  → Uygulama ana ekrana yönlendirir
```

### E-posta Değişikliği Akışı
```
Kullanıcı yeni e-posta girer ve butona basar
  → ChangeEmailScreen._changeEmail()
    → Form.validate()
    → FirebaseAuth.currentUser.verifyBeforeUpdateEmail()  ← Firebase API
    → Firestore collection('users').doc(uid).update()     ← Firestore API
    → SnackBar: "E-posta başarıyla güncellendi"
    → context.pop()  ← Önceki sayfaya dön
```

---

## Ek: Sık Karşılaşılan Hatalar ve Çözümleri

### 1. `PlatformException(sign_in_failed, com.google.android.gms.common.api.ApiException: 10)`
**Neden:** SHA-1 sertifikası Firebase Console'da kaydedilmemiş veya yanlış.
**Çözüm:** SHA-1'i doğru alın ve Firebase Console → Project Settings → Your apps → SHA certificate fingerprints'e ekleyin.

### 2. `FirebaseAuthException: idToken null`
**Neden:** Google Sign-In'de ID Token alınamadı. Genellikle SHA-1 veya Web Client ID sorunu.
**Çözüm:** SHA-1'i kontrol edin ve `google-services.json` dosyasının güncel olduğundan emin olun.

### 3. `FirebaseAuthException: requires-recent-login`
**Neden:** E-posta veya şifre değişikliği gibi hassas işlemler için kullanıcının yakın zamanda giriş yapması gerekir.
**Çözüm:** Kullanıcıyı yeniden giriş yapmaya yönlendirin, ardından işlemi tekrar deneyin.

### 4. `FirebaseAuthException: email-already-in-use`
**Neden:** Kayıt olunmaya çalışılan e-posta zaten başka bir hesapta kullanılıyor.
**Çözüm:** Kullanıcıya bu e-posta ile giriş yapmasını veya farklı bir e-posta kullanmasını söyleyin.

### 5. `FirebaseAuthException: too-many-requests`
**Neden:** Kısa sürede çok fazla başarısız giriş denemesi. Firebase güvenlik mekanizması.
**Çözüm:** Bekleyin (genellikle birkaç dakika) ve tekrar deneyin.

### 6. `MissingPluginException(No implementation found for method ...)`
**Neden:** Flutter plugin'leri native tarafa bağlanamamış.
**Çözüm:** `flutter clean && flutter pub get` çalıştırın ve uygulamayı yeniden derleyin.

### 7. `google-services.json` bulunamadı
**Neden:** Dosya `android/app/` klasöründe değil veya eksik.
**Çözüm:** Firebase Console'dan dosyayı indirin ve `android/app/` klasörüne yerleştirin.

---

*Bu belge Takaš projesinin Firebase Authentication sistemini başlangıç seviyesinden ileri seviyeye
kadar detaylı bir şekilde açıklamaktadır. Her dosya satır satır incelenmiş, her kavram temelden
anlatılmıştır.*
