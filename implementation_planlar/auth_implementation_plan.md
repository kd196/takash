# Faz 1.2: Firebase Authentication Entegrasyonu

Bu plan, uygulamanın kimlik doğrulama altyapısını kurmayı ve kullanıcı giriş/kayıt işlemlerini (Phase 1.2) `skill_01_auth.md` belgesine uygun olarak Riverpod kullanarak implement etmeyi hedeflemektedir.

## User Review Required

> [!IMPORTANT]
> Uygulamanın başarıyla çalışması için bu kodlar yazıldıktan sonra (ya da öncesinde) terminalde `flutterfire configure` komutunu çalıştırarak Firebase kurulumunuzu tamamlamış olmanız gerekmektedir. Aksi halde `firebase_options.dart` dosyası eksik olacağı için derleme hatası alacaksınız.
>
> Ayrıca, Google ile girişin (Google Sign-In) çalışabilmesi için Firebase konsoluna projenizin **SHA-1** key'ini eklemelisiniz.

## Proposed Changes

### Bağlantılar & Bağımlılıklar

#### [MODIFY] pubspec.yaml
- `google_sign_in` paketini ekleyeceğiz. (Mevcutta `firebase_auth` var).

---

### Veri Modeli ve Repository

#### [NEW] lib/features/auth/domain/user_model.dart
- `UserModel` sınıfı `fromJson` ve `toJson` metodlarıyla oluşturulacak. (Firestore veritabanına kayıt için gerekli).

#### [NEW] lib/features/auth/data/auth_repository.dart
- `AuthRepository` sınıfında şu fonksiyonlar implement edilecek:
  - `signInWithEmail(email, password)`
  - `registerWithEmail(email, password, displayName)`
  - `signInWithGoogle()`
  - `signOut()`
  - Kullanıcı ilk kez kayıt/giriş yaptığında `users` koleksiyonuna Firestore'a profil kaydetme.

#### [NEW] lib/features/auth/presentation/auth_controller.dart
- `AsyncNotifier` veya `StateNotifier` yardımıyla kullanıcı arayüzünde (UI) kullanılacak `authControllerProvider` yaratılacak. Loading durumu ve hata yönetimi eklenecek.

---

### Kullanıcı Arayüzü (UI)

#### [MODIFY] lib/features/auth/presentation/login_screen.dart
- E-posta, şifre alanları oluşturulacak.
- `AuthValidator` (ör. `Validators.email` ve `Validators.password`) eklenecek.
- "Giriş Yap" ve "Google ile Giriş Yap" butonları ve `authController` entegrasyonu.

#### [MODIFY] lib/features/auth/presentation/register_screen.dart
- İsim, E-posta ve Şifre için alanlar barındıracak.
- "Kayıt Ol" butonu ve `authController` ile firebase entegrasyonu.

---

### Konfigürasyon ve Global Provider'lar

#### [MODIFY] lib/core/providers.dart
- Daha önceden yorum satırına alınan `FirebaseAuth`, `FirebaseFirestore` ve `currentUserProvider` aktif hale getirilecek.

#### [MODIFY] lib/app/router.dart
- GoRouter yapısındaki auth redirect (yönlendirme) mantığı aktif edilecek (kullanıcı giriş yapmamışsa otomatik olarak `/login` sayfasına yönlendirilecek).

#### [MODIFY] lib/main.dart
- `Firebase.initializeApp` fonksiyonu yorum satırından çıkarılacak. `firebase_options.dart` import edilecek.

## Open Questions

- `google_sign_in` entegrasyonunu da bu aşamada tamamen yazmamı ister misiniz? (Bilgisayarınızda test için SHA key vs. hazır değilse e-posta ile başlanabilir, ama kodda Google Sign-In de hazır olacaktır).

## Verification Plan

### Automated Tests
- Authentication Repository için fake auth ve firestore ile login senaryo testleri yazılabilir. (İleriki test aşamasında ele alınacak)

### Manual Verification
1. Uygulamayı başlattığınızda otomatik olarak `/login` rotasına yönlendirildiğinizi teyit edin.
2. E-posta ile yeni bir kullanıcı hesabı oluşturun.
3. Firestore konsolunuza gidip, `users` koleksiyonunda hesabınızın oluştuğunu (`displayName`, `email`, vs. verilerle) gözlemleyin.
4. Çıkış yapıp (çıkış butonu eklendiğinde) tekrar aynı bilgilerle girmeyi deneyin.
