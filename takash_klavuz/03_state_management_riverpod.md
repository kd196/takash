# 03 — Riverpod State Management (Takaş Projesi)

---

## İçindekiler

1. [State Management Nedir?](#1-state-management-nedir)
2. [Riverpod Nedir?](#2-riverpod-nedir)
3. [Provider Tipleri](#3-provider-tipleri)
4. [ref.watch vs ref.read vs ref.listen](#4-refwatch-vs-refread-vs-reflisten)
5. [AsyncValue Nedir?](#5-asyncvalue-nedir)
6. [ConsumerWidget ve ConsumerStatefulWidget](#6-consumerwidget-ve-consumerstatefulwidget)
7. [Takaş Projesindeki Tüm Provider ve Controller Dosyaları](#7-takaş-projesindeki-tüm-provider-ve-controller-dosyaları)

---

## 1. State Management Nedir?

### 1.1 — "State" (Durum) Kavramı

Bir Flutter uygulaması, ekranda gördüğünüz her şeyin **veriye dayalı** olduğunu bilmelisiniz. Örneğin Takaş uygulamasında:

- Kullanıcının giriş yapıp yapmadığı bir **veri** (true/false)
- Ekranda listelenen ilanlar bir **veri** (liste)
- Karanlık mod açık mı kapalı mı bir **veri** (ThemeMode.dark / ThemeMode.light)
- Kullanıcının konumu bir **veri** (enlem, boylam)

İşte bu verilere **"state"** (durum) diyoruz. State, uygulamanızın **herhangi bir anındaki** tüm değişken verilerin toplamıdır.

### 1.2 — Neden State Management Gerekli?

Basit bir örnek düşünelim. Takaş'ta bir ilan listesi var. Kullanıcı aşağıdaki işlemleri yapıyor:

1. Ana sayfada ilanları görüntülüyor
2. Arama çubuğuna "bisiklet" yazıyor
3. Bir kategori filtresi seçiyor
4. Favorilerine bir ilan ekliyor
5. Harita görünümüne geçiyor

Her bir adımda **ekrandaki veri değişiyor**. Bu değişikliklerin **doğru zamanda, doğru şekilde** ekrana yansıması gerekir. İşte bu senkronizasyon işine **State Management** (Durum Yönetimi) diyoruz.

**Özetle:** State management, verinizle kullanıcı arayüzünüzün (UI) her zaman senkronize kalmasını sağlayan bir mekanizmadır.

### 1.3 — setState() Yöntemi ve Yetersizliği

Flutter'da en temel state management yöntemi `setState()` metodudur. Bir `StatefulWidget` içinde kullanılır:

```dart
class MyCounterPage extends StatefulWidget {
  @override
  State<MyCounterPage> createState() => _MyCounterPageState();
}

class _MyCounterPageState extends State<MyCounterPage> {
  int _sayac = 0;  // <-- Bu bizim "state"imiz

  void _arttir() {
    setState(() {     // <-- setState, ekranın yeniden çizilmesini tetikler
      _sayac++;       // <-- State'i güncelliyoruz
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text('Sayaç: $_sayac');
  }
}
```

Bu basit örnekte `setState()` gayet çalışır. Ancak gerçek bir uygulamada şu sorunlarla karşılaşırsınız:

#### Sorun 1: State Sadece Bir Widget'ta Yaşar

`setState()` ile tutulan veri, **sadece o widget'ın içinde** var olur. Başka bir ekranda, başka bir widget'ta aynı veriye erişemezsiniz.

Örnek: Takaş'ta kullanıcı giriş yaptı. Bu bilgi `setState()` ile tutuluyorsa, uygulamanın 20 farklı ekranının her biri ayrı ayrı "kullanıcı giriş yaptı mı?" bilgisini bilemez. Her ekranda ayrı bir değişken tutmanız gerekir.

#### Sorun 2: Widget Ağacında Derin Veri Aktarımı (Prop Drilling)

Diyelim ki `MainPage` widget'ında kullanıcının adını biliyorsunuz. Bu bilgiyi `ProfilePage`'e, oradan `ProfileHeader`'a, oradan `UserNameText`'e aktarmanız gerekiyor. Her seviyede constructor parametresi olarak geçmeniz gerekir:

```dart
// Ana widget
MainPage(userName: "Ahmet")
  └── ProfilePage(userName: "Ahmet")        // 1. seviye
        └── ProfileHeader(userName: "Ahmet") // 2. seviye
              └── UserNameText(userName: "Ahmet") // 3. seviye
```

Buna **"prop drilling"** denir. Uygulama büyüdükçe yönetilmez hale gelir.

#### Sorun 3: İş Mantığı (Business Logic) ile UI Karışır

`setState()` kullandığınızda, veri güncelleme kodu ile ekran çizdirme kodu aynı widget'ın içindedir. Bu, test edilebilirliği ve bakımı zorlaştırır.

İşte bu yüzden **profesyonel bir state management çözümüne** ihtiyaç duyarız.

---

## 2. Riverpod Nedir?

### 2.1 — Provider Paketinden Riverpod'a Evrim

Riverpod, **Remi Rousselet** tarafından oluşturulmuş bir Dart paketidir. Remi aynı zamanda **Provider** paketinin de yaratıcısıdır.

Gelişim süreci:

```
Provider (eski)  ──────►  Riverpod (yeni, geliştirilmiş)
```

**Provider paketinin sorunları:**
- Provider'lar yalnızca widget ağacı içinde çalışıyordu (BuildContext gerekiyordu)
- Runtime'da hatalar çok geç fark ediliyordu
- Aynı türde birden fazla provider tanımlamak zordu
- Test yazmak karmaşıktı

**Riverpod'un çözümleri:**
- BuildContext'e ihtiyaç **yok** — `ref` nesnesi ile her yerden erişilebilir
- **Compile-time** (derleme zamanı) güvenliği — hataları kodu çalıştırmadan yakalar
- Global olarak tanımlanabilir — widget ağacından bağımsızdır
- Kolay test edilebilir

### 2.2 — Neden Riverpod Seçtik?

Takaş projesinde Riverpod'u tercih etmemizin nedenleri:

1. **Firebase entegrasyonu:** `StreamProvider` ve `FutureProvider` ile Firebase verilerini dinlemek çok kolay
2. **Code generation desteği:** `@riverpod` annotation'ı ile tekrar eden kodu otomatik üretiyoruz
3. **Modüler yapı:** Her feature (auth, chat, listings, profile) kendi provider/controller'ına sahip
4. **Async veri yönetimi:** `AsyncValue` ile loading/error/data durumlarını tek tipte yönetiyoruz
5. **Açık kaynak ve aktif topluluk:** Sürekli güncellenen, iyi dokümantasyona sahip bir paket

### 2.3 — Diğer Alternatifler ve Karşılaştırma

Flutter ekosisteminde birden fazla state management çözümü vardır:

| Özellik | Riverpod | Bloc | GetX | Provider |
|---|---|---|---|---|
| Öğrenme eğrisi | Orta | Yüksek | Düşük | Düşük |
| Boilerplate (tekrar eden kod) | Az (code gen ile) | Çok | Çok az | Az |
| Test edilebilirlik | Mükemmel | Mükemmel | Orta | İyi |
| Async destek | Yerleşik (AsyncValue) | Yerleşik | Zayıf | Zayıf |
| Code generation | Var | Yok (hand-written) | Yok | Yok |
| BuildContext gereksinimi | Hayır | Evet | Hayır | Evet |
| Tip güvenliği | Yüksek | Yüksek | Düşük | Orta |

**Bloc (Business Logic Component):**
- Google mühendisleri tarafından önerilir
- Event-driven (olay güdümlü) bir mimari kullanır
- Her state değişikliği bir "event" tetikler
- Çok fazla boilerplate kod yazmanızı gerektirir (event sınıfları, state sınıfları, bloc sınıfları)
- Büyük ekiplerde tutarlılık sağlar ancak küçük/orta projeler için ağır kalır

**GetX:**
- Çok hızlı prototipleme için uygundur
- Ancak "her şeyi yapar" yaklaşımı sorunludur — navigation, DI, state management hepsi bir arada
- Test edilebilirliği zayıftır
- Topluluk desteği tartışmalıdır

**Provider (eski):**
- Riverpod'un öncüsüdür
- BuildContext'e bağımlıdır
- Artık geliştirilmiyor — Remi Rousselet kendisi Riverpod'u öneriyor

**Sonuç:** Takaş projesi için **Riverpod** en uygun seçimdir çünkü Firebase tabanlı, async yoğunluklu bir uygulama geliştiriyoruz ve Riverpod'un `AsyncValue` yapısı bu senaryoda çok güçlü bir avantaj sağlar.

---

## 3. Provider Tipleri

Riverpod'da "provider" kelimesi, **"bir değer sağlayan nesne"** anlamına gelir. Her provider, belli bir veriyi üretir ve yönetir. Farklı ihtiyaçlar için farklı provider tipleri vardır.

### 3.1 — Provider (Salt Okunur Değer)

**Ne yapar:** Sabit veya hesaplanan bir değer sağlar. Değer **değişmez** — bir kez oluşturulur ve her yerde aynı kalır.

**Ne zaman kullanılır:**
- Servis sınıflarını (Firebase Auth, Firestore, vb.) uygulama genelinde erişilebilir kılmak için
- Repository (veri erişim) sınıflarını sağlamak için
- Başka provider'lardan türetilmiş, hesaplanmış değerler için

**Takaş'tan örnek:**

```dart
// lib/core/providers.dart
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});
```

**Satır satır açıklama:**

```dart
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
```
- `final` — Bu değişken bir kez atanır ve sonra değiştirilemez. Global düzeyde tanımlandığı için uygulama boyunca aynı kalır.
- `firebaseAuthProvider` — Provider'ın adı. Dart'ta değişken adları `camelCase` yazılır.
- `Provider<FirebaseAuth>` — Provider tipi. Generic parametre olarak `FirebaseAuth` verilmiş, yani bu provider bir `FirebaseAuth` nesnesi üretecek.
- `((ref) { ... })` — Bu bir **creator function** (oluşturucu fonksiyon). Provider ilk kez erişildiğinde bu fonksiyon çalışır ve döndürdüğü değer, provider'ın değerini oluşturur.
- `ref` — "Reference" kelimesinin kısaltması. Bu nesne üzerinden **diğer provider'lara** erişebilirsiniz.

```dart
  return FirebaseAuth.instance;
```
- `FirebaseAuth.instance` — Firebase Authentication servisinin singleton (tekil) örneğini döndürür.
- `return` — Bu değeri provider'ın değeri olarak belirler.

```dart
});
```
- Fonksiyonu ve provider tanımını kapatır.

**Kullanımı:**

```dart
// Başka bir provider'da veya widget'ta:
final firebaseAuth = ref.read(firebaseAuthProvider);
// Artık firebaseAuth üzerinden giriş/çıkış işlemleri yapılabilir
```

### 3.2 — StateProvider (Basit State)

**Ne yapar:** Basit, değiştirilebilir bir değer tutar. Değeri doğrudan atayarak veya mevcut değeri okuyup değiştirerek güncelleyebilirsiniz.

**Ne zaman kullanılır:**
- Basit sayaçlar, toggle'lar (açık/kapalı)
- Seçili filtre değerleri
- Arama sorguları gibi basit string'ler
- Sayısal değerler

**Takaş'tan örnek:**

```dart
final searchRadiusProvider =
    StateProvider<double>((ref) => 100.0);
```

**Satır satır açıklama:**

```dart
final searchRadiusProvider =
```
- Provider'ın adı. Arama yarıçapını (km cinsinden) tutacak.

```dart
    StateProvider<double>((ref) => 100.0);
```
- `StateProvider<double>` — Bu provider bir `double` (ondalık sayı) tutacak.
- `((ref) => 100.0)` — Başlangıç değeri `100.0` (100 kilometre). Bu, provider oluşturulduğunda alacağı ilk değerdir.
- `ref` parametresi burada kullanılmasa da sağlanır — gerekirse diğer provider'lardan değer okuyabilirsiniz.

**Değer okuma:**

```dart
double radius = ref.watch(searchRadiusProvider);
// radius değişkeni şu an 100.0 olacak
```

**Değer güncelleme:**

```dart
// Yeni bir değer ata:
ref.read(searchRadiusProvider.notifier).state = 50.0;

// Mevcut değeri değiştir:
ref.read(searchRadiusProvider.notifier).state++;
```

- `.notifier` — StateProvider'ın state yöneticisine erişim sağlar.
- `.state` — Gerçek değerin tutulduğu alan. Buna yeni bir değer atayarak state'i güncellersiniz.

**Takaş'taki diğer StateProvider örnekleri:**

```dart
final searchQueryProvider = StateProvider<String>((ref) => '');
```
- Arama sorgusunu tutar. Başlangıç değeri boş string `''`.

```dart
final categoryFilterProvider = StateProvider<ListingCategory?>((ref) => null);
```
- Seçili kategori filtresini tutar. `null` olduğunda filtre yok demektir (tüm kategoriler gösterilir).
- `ListingCategory?` — Soru işareti, bu değerin `null` olabileceğini belirtir (nullable type).

```dart
final showMyListingsProvider = StateProvider<bool>((ref) => false);
```
- Kullanıcının kendi ilanlarını gösterip göstermeyeceğini tutar. Varsayılan olarak `false` — yani kendi ilanları gizlenir.

```dart
final unreadNotificationCountProvider = StateProvider<int>((ref) => 0);
```
- Okunmamış bildirim sayısını tutar. Başlangıç değeri `0`.

### 3.3 — FutureProvider (Async Tek Seferlik Veri)

**Ne yapar:** Bir `Future` (asenkron işlem) sonucunu yönetir. Veriyi **bir kez** getirir ve cache'ler. Yükleme, hata ve veri durumlarını otomatik takip eder.

**Ne zaman kullanılır:**
- API'den bir kez veri çekmek
- Firestore'dan tek bir belge getirmek
- Konum bilgisini bir kez almak
- SharedPreferences'tan ayar okumak

**Takaş'tan örnek 1 — Kullanıcı konumu:**

```dart
final userLocationProvider = FutureProvider<Position?>((ref) {
  return ref.watch(locationServiceProvider).getCurrentLocationOnce();
});
```

**Satır satır açıklama:**

```dart
final userLocationProvider = FutureProvider<Position?>((ref) {
```
- `FutureProvider<Position?>` — Bu provider bir `Future<Position?>` döndürecek. `Position` sınıfı `geolocator` paketinden gelir ve enlem/boylam bilgisi içerir. `?` işareti null olabileceğini belirtir — konum alınamazsa `null` dönebilir.

```dart
  return ref.watch(locationServiceProvider).getCurrentLocationOnce();
```
- `ref.watch(locationServiceProvider)` — `LocationService` nesnesini alır. `watch` kullanıldığı için, eğer `locationServiceProvider` değişirse bu provider da yeniden çalışır.
- `.getCurrentLocationOnce()` — LocationService'teki metodu çağırarak mevcut konumu bir kez alır.

```dart
});
```
- Fonksiyonu kapatır.

**Bu provider'ın yaşam döngüsü:**

```
1. İlk erişim:     state = AsyncLoading<Position?>()     // Yükleniyor...
2. Veri geldi:     state = AsyncData<Position?>(position) // Veri hazır
2b. Hata oldu:     state = AsyncError(error, stackTrace)   // Hata!
```

**Takaş'tan örnek 2 — Tek ilan detayı:**

```dart
final singleListingProvider =
    FutureProvider.family<ListingModel?, String>((ref, listingId) {
  final repo = ref.watch(listingRepositoryProvider);
  return repo.getListingById(listingId);
});
```

- `.family` modifier'ı kullanılmış — bunu 3.6 bölümünde detaylı açıklayacağız.
- Her farklı `listingId` için ayrı bir cache oluşturur.
- `getListingById(listingId)` — Firestore'dan bu ID'ye sahip ilanı getirir.

### 3.4 — StreamProvider (Sürekli Güncellenen Veri)

**Ne yapar:** Bir `Stream` (veri akışı) dinler. Stream yeni veri ürettiğinde provider otomatik güncellenir. **Gerçek zamanlı** veri için idealdir.

**Ne zaman kullanılır:**
- Firestore koleksiyonlarını dinlemek (ilanlar gerçek zamanlı güncellenir)
- Firebase Auth durumunu dinlemek (kullanıcı giriş/çıkış)
- Chat mesajlarını dinlemek
- Herhangi bir real-time veri akışı

**Takaş'tan örnek 1 — Tüm aktif ilanlar:**

```dart
final allListingsProvider = StreamProvider<List<ListingModel>>((ref) {
  final repo = ref.watch(listingRepositoryProvider);
  return repo.getAllActiveListings();
});
```

**Satır satır açıklama:**

```dart
final allListingsProvider = StreamProvider<List<ListingModel>>((ref) {
```
- `StreamProvider<List<ListingModel>>` — Bu provider bir `Stream<List<ListingModel>>` dinleyecek. Yani sürekli olarak bir `ListingModel` listesi akışı gelecek.
- `ListingModel` — Takaş'taki bir ilanın veri modeli (başlık, açıklama, fotoğraflar, konum, vb.)

```dart
  final repo = ref.watch(listingRepositoryProvider);
```
- `listingRepositoryProvider`'dan repository (veri erişim katmanı) nesnesini alır.
- `ref.watch` kullanarak, eğer repository değişirse bu provider'ın da yeniden oluşturulmasını sağlar.

```dart
  return repo.getAllActiveListings();
```
- Repository'nin `getAllActiveListings()` metodu bir `Stream<List<ListingModel>>` döndürür.
- Firestore'daki "listings" koleksiyonundaki aktif (silinmemiş) ilanları dinler.
- Firestore'da bir ilan eklenir, silinir veya güncellenirse, stream otomatik olarak yeni listeyi yayınlar.
- Bu stream'i döndürerek provider, her yeni veri geldiğinde state'i günceller.

```dart
});
```
- Fonksiyonu kapatır.

**StreamProvider'ın yaşam döngüsü:**

```
1. Başlangıç:       state = AsyncLoading()              // İlk veri bekleniyor
2. İlk veri geldi:  state = AsyncData([listing1, ...])  // Veri hazır
3. Veri güncellendi: state = AsyncData([listing1, ...güncel])  // Otomatik güncellenir
3b. Hata oldu:      state = AsyncError(error, st)       // Hata!
4. Stream bitti:    state = AsyncData(sonVeri)           // Son veri korunur
```

**Takaş'tan örnek 2 — Auth durumu:**

```dart
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});
```

- `StreamProvider<User?>` — Firebase User nesnesini veya null dinler.
- `authStateChanges()` — Firebase'in sunduğu bir stream. Kullanıcı giriş yaptığında `User` nesnesi, çıkış yaptığında `null` yayınlar.
- Bu provider Takaş'taki **en temel provider'dır** — kullanıcı giriş yapıp yapmadığını tüm uygulama boyunca buradan anlarız.

**Takaş'tan örnek 3 — Sohbet mesajları:**

```dart
final chatMessagesProvider =
    StreamProvider.family<List<MessageModel>, String>((ref, chatId) {
  return ref.watch(chatRepositoryProvider).getMessages(chatId);
});
```

- `.family` ile parametreli — her `chatId` için ayrı bir stream dinlenir.
- Yeni mesaj geldiğinde otomatik güncellenir.
- Gerçek zamanlı chat deneyimi sağlar.

### 3.5 — AsyncNotifierProvider (Complex Async State)

**Ne yapar:** Asenkron işlemleri yöneten bir controller (denetleyici) sınıfı sağlar. Sınıf içinde metotlar tanımlayarak, yükleme/hata durumlarını merkezi olarak yönetebilirsiniz.

**Ne zaman kullanılır:**
- Veri oluşturma, güncelleme, silme işlemleri (CRUD)
- Birden fazla asenkron metodu olan karmaşık işlemler
- İşlem sonucunu takip etmeniz gereken durumlar

**Takaş'tan örnek — İlan oluşturma controller'ı:**

```dart
final createListingControllerProvider =
    AsyncNotifierProvider<CreateListingController, void>(
  CreateListingController.new,
);
```

**Satır satır açıklama:**

```dart
final createListingControllerProvider =
```
- Provider'ın adı. "Controller" kelimesi, bunun bir iş mantığı (business logic) sınıfı olduğunu belirtir.

```dart
    AsyncNotifierProvider<CreateListingController, void>(
```
- `AsyncNotifierProvider` — Riverpod'un asenkron notifier tipi.
- İlk generic parametre: `CreateListingController` — Hangi sınıf bu provider'ı yönetecek?
- İkinci generic parametre: `void` — State'in tipi. `void` demek, bu controller kalıcı bir state tutmuyor demektir — sadece geçici olarak loading/error durumunu takip eder.

```dart
  CreateListingController.new,
```
- `CreateListingController.new` — Bu, `() => CreateListingController()` yazımının kısaltmasıdır. Yani controller sınıfının yeni bir örneğini oluşturur.
- Riverpod, controller'ı **lazy** (tembel) olarak oluşturur — yani ilk erişildiğinde oluşturulur.

**Controller sınıfı:**

```dart
class CreateListingController extends AsyncNotifier<void> {
```
- `extends AsyncNotifier<void>` — Riverpod'un `AsyncNotifier` temel sınıfından kalıtım alır.
- `<void>` — State tipi. Bu controller kalıcı bir veri tutmaz, sadece işlem durumunu (loading/error) takip eder.

```dart
  @override
  Future<void> build() async {}
```
- `build()` — Controller ilk oluşturulduğunda çağrılır. Başlangıç state'ini belirler.
- `async {}` — Boş bırakılmış çünkü başlangıçta yapılacak bir şey yok.
- `@override` — Üst sınıftaki abstract metodu eziyor (override ediyor).

**Not:** Bu projede iki farklı AsyncNotifier yazım stili kullanılmıştır:

1. **Manuel (hand-written) stil** — `AsyncNotifier<void>` ve `AsyncNotifierProvider`
2. **Code generation stili** — `@riverpod` annotation ve `_$AuthController` extends

Her ikisi de aynı işi yapar, sadece tanımlama biçimleri farklıdır. Code generation stili daha az kod yazmanızı sağlar ama bir build step gerektirir (`dart run build_runner build`).

### 3.6 — family Modifier (Parametreli Provider)

**Ne yapar:** Bir provider'a dışarıdan **parametre** geçmenizi sağlar. Böylece aynı provider mantığı farklı parametrelerle yeniden kullanılabilir.

**Ne zaman kullanılır:**
- Belirli bir ID'ye sahip veriyi getirmek (ilan ID, kullanıcı ID, sohbet ID)
- Her parametre değeri için ayrı bir cache oluşturmak

**Takaş'tan örnek 1 — Parametreli StreamProvider:**

```dart
final userListingsProvider =
    StreamProvider.family<List<ListingModel>, String>((ref, userId) {
  final repo = ref.watch(listingRepositoryProvider);
  return repo.getUserListings(userId);
});
```

**Satır satır açıklama:**

```dart
    StreamProvider.family<List<ListingModel>, String>((ref, userId) {
```
- `.family` — Bu modifier, provider'a parametre geçme yeteneği ekler.
- İlk generic: `List<ListingModel>` — Stream'in yayacağı veri tipi.
- İkinci generic: `String` — Parametrenin tipi (burada `userId` bir String).
- Creator fonksiyon artık iki parametre alır: `(ref, userId)` — `ref` her zamanki reference nesnesi, `userId` ise dışarıdan geçirilen parametre.

```dart
  final repo = ref.watch(listingRepositoryProvider);
  return repo.getUserListings(userId);
```
- Repository'yi alır ve `userId` parametresiyle o kullanıcının ilanlarını dinler.

**Kullanımı:**

```dart
// "abc123" ID'li kullanıcının ilanlarını dinle:
final userListingAsync = ref.watch(userListingsProvider("abc123"));

// "xyz789" ID'li kullanıcının ilanlarını dinle:
final otherUserListings = ref.watch(userListingsProvider("xyz789"));

// Her iki çağrı da BAĞIMSIZ cache'lere sahiptir!
```

**Takaş'tan örnek 2 — Parametreli FutureProvider:**

```dart
final singleListingProvider =
    FutureProvider.family<ListingModel?, String>((ref, listingId) {
  final repo = ref.watch(listingRepositoryProvider);
  return repo.getListingById(listingId);
});
```

- Her `listingId` için ayrı bir Future çalışır ve cache'lenir.
- Aynı `listingId` ile tekrar erişildiğinde cache'den döner (yeniden fetch yapmaz).

**Takaş'tan örnek 3 — Parametreli StreamProvider (favori kontrolü):**

```dart
final isFavoriteProvider =
    StreamProvider.family<bool, String>((ref, listingId) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(false);

  final repo = ref.watch(listingRepositoryProvider);
  return repo.isFavorite(user.uid, listingId);
});
```

- Parametre: `listingId` (String) — Hangi ilanın favori olup olmadığını sorgulayacağız.
- Kullanıcı giriş yapmamışsa `Stream.value(false)` döner — yani "favori değil" sonucu yayınlar.
- Giriş yapılmışsa, Firestore'daki favoriler koleksiyonunu dinler.

---

## 4. ref.watch vs ref.read vs ref.listen

Riverpod'da `ref` nesnesi, provider'lara erişim sağlayan anahtarınızdır. Üç farklı erişim yöntemi vardır ve her birinin farklı bir amacı vardır. Bu bölüm, bu üç yöntemi derinlemesine açıklayacaktır.

### 4.1 — ref.watch

**Ne yapar:** Bir provider'ın **mevcut değerini okur** ve o provider değiştiğinde **kendisini otomatik olarak yeniden çalıştırır** (rebuild).

**Ne zaman kullanılır:**
- `build()` metodu içinde — UI'ı güncel tutmak için
- Başka bir provider'ın creator fonksiyonu içinde — provider'lar arası bağımlılık kurmak için

**ÖNEMLİ KURAL:** `ref.watch` **asla** bir `onPressed`, `onTap`, veya herhangi bir callback (geri çağırma fonksiyonu) içinde kullanılmamalıdır!

**Takaş'tan örnek:**

```dart
// listings_controller.dart - satır 26-48
final nearbyListingsProvider = StreamProvider<List<ListingModel>>((ref) {
  final userLocation = ref.watch(userLocationProvider).value;
  final radius = ref.watch(searchRadiusProvider);
  final allListingsAsync = ref.watch(allListingsProvider);
  // ...
});
```

**Ne oluyor?**

1. `ref.watch(userLocationProvider).value` — Kullanıcının konumunu dinler. Konum değişirse bu provider **yeniden çalışır**.
2. `ref.watch(searchRadiusProvider)` — Arama yarıçapını dinler. Kullanıcı yarıçapı değiştirirse bu provider **yeniden çalışır**.
3. `ref.watch(allListingsProvider)` — Tüm ilanları dinler. Yeni ilan eklenirse bu provider **yeniden çalışır**.

Yani `ref.watch` ile bir **bağımlılık zinciri** oluşturuyoruz:

```
userLocationProvider değişti ──► nearbyListingsProvider yeniden çalışır
searchRadiusProvider değişti ──► nearbyListingsProvider yeniden çalışır
allListingsProvider değişti   ──► nearbyListingsProvider yeniden çalışır
```

**Widget içinde kullanımı:**

```dart
class ListingsPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(allListingsProvider);
    // allListingsProvider her değiştiğinde build() yeniden çağrılır
    // ve UI otomatik güncellenir
  }
}
```

### 4.2 — ref.read

**Ne yapar:** Bir provider'ın **mevcut değerini okur** ancak dinlemez (watch etmez). Provider değişse bile bir şey tetiklenmez.

**Ne zaman kullanılır:**
- Callback'lerin içinde (onPressed, onTap, vb.)
- Bir metodu çağırırken (örneğin controller'daki bir metodu tetiklerken)
- Sadece "şu anki değeri" okumak istediğinizde
- Provider'ın `.notifier`'ına erişirken

**Takaş'tan örnek:**

```dart
// listings_controller.dart - satır 156
final user = ref.read(authStateProvider).value;
```

- Burada `ref.read` kullanılmış çünkü bu kod bir metot gövdesinde (`createListing`) çalışıyor.
- Amaç sadece mevcut kullanıcıyı almak, değil onu dinlemek.
- Eğer `ref.watch` kullansaydık, kullanıcı değiştiğinde `createListing` metodu anlamsız bir şekilde tetiklenirdi.

```dart
// chat_controller.dart - satır 72
await ref.read(chatRepositoryProvider).sendMessage(chatId, text, userId);
```

- `sendMessage` bir callback'den tetiklenir — bu yüzden `ref.read` kullanılır.
- Repository'nin metodunu bir kez çağırıp bırakıyoruz.

**Daha fazla örnek:**

```dart
// StateProvider'ın değerini değiştirirken:
ref.read(searchRadiusProvider.notifier).state = 50.0;

// Controller'daki bir metodu çağırırken:
ref.read(createListingControllerProvider.notifier).createListing(...);

// Mevcut auth durumunu kontrol ederken:
final isLoggedIn = ref.read(authStateProvider).value != null;
```

### 4.3 — ref.listen

**Ne yapar:** Bir provider'ı dinler ve provider **değiştiğinde** bir callback çalıştırır. Ancak `ref.watch`'tan farklı olarak, widget'ı veya provider'ı **yeniden oluşturmaz** — sadece yan etki (side effect) yapar.

**Ne zaman kullanılır:**
- SnackBar göstermek
- Dialog açmak
- Navigation (sayfa değiştirme) yapmak
- Hata mesajı göstermek
- Herhangi bir "yan etki" yapmak

**Genel kullanım şekli:**

```dart
ref.listen<AsyncValue<void>>(
  createListingControllerProvider,
  (previous, next) {
    next.when(
      data: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('İlan başarıyla oluşturuldu!')),
        );
      },
      error: (error, stack) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $error')),
        );
      },
      loading: () {},
    );
  },
);
```

**Parametrelerin açıklaması:**

- `<AsyncValue<void>>` — Dinlenecek provider'ın tipi.
- İlk parametre: Dinlenecek provider.
- İkinci parametre: Callback fonksiyonu.
  - `previous` — Provider'ın eski değeri.
  - `next` — Provider'ın yeni değeri.

**Takaş'tan örnek bir senaryo:**

```dart
// auth_controller'ı dinleyip, giriş başarılı olduğunda ana sayfaya git:
ref.listen<AsyncValue<void>>(
  authControllerProvider,
  (previous, next) {
    if (next.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Giriş başarısız: ${next.error}')),
      );
    }
  },
);
```

### 4.4 — Karşılaştırma Özet Tablosu

| Özellik | ref.watch | ref.read | ref.listen |
|---|---|---|---|
| Değeri okur | Evet | Evet | Hayır (callback alır) |
| Değişikliği dinler | Evet | Hayır | Evet |
| Yeniden oluşturur | Evet (rebuild) | Hayır | Hayır |
| Kullanım yeri | build() veya provider body | Callback'ler, metotlar | initState veya build() |
| Yan etki yapar | Hayır | Hayır | Evet (SnackBar, vb.) |

---

## 5. AsyncValue Nedir?

### 5.1 — Problem

Asenkron işlemler (API çağrıları, veritabanı sorguları) üç durumda olabilir:

1. **Yükleniyor (Loading)** — Veri henüz gelmedi, bir loading göstergesi lazım
2. **Veri geldi (Data)** — İşlem başarılı, veriyi gösterebiliriz
3. **Hata (Error)** — Bir şey ters gitti, hata mesajı göstermeliyiz

Eğer Riverpod olmasaydı, bunu manuel olarak yönetmemiz gerekirdi:

```dart
// Manuel yönetim (KÖTÜ YÖNTEM):
bool isLoading = true;
List<ListingModel>? data;
String? error;

try {
  data = await fetchData();
  isLoading = false;
} catch (e) {
  error = e.toString();
  isLoading = false;
}

// Widget'ta:
if (isLoading) return CircularProgressIndicator();
if (error != null) return Text('Hata: $error');
return ListView(children: data!.map(...).toList());
```

Bu yaklaşım her asenkron işlem için tekrarlanır ve hata yapmaya çok açıktır.

### 5.2 — Çözüm: AsyncValue

Riverpod, bu üç durumu tek bir tipte birleştirir: **`AsyncValue<T>`**

```dart
// AsyncValue üç alt tipe sahiptir:
AsyncLoading<T>()   // Yükleniyor
AsyncData<T>(data)  // Veri hazır
AsyncError<T>(error, stackTrace)  // Hata
```

### 5.3 — .when() Metodu

`AsyncValue`'nin en güçlü özelliği `.when()` metodudur. Üç durumu da **mutlaka** ele almanızı sağlar:

```dart
listingsAsync.when(
  data: (List<ListingModel> listings) {
    // Veri başarıyla geldiğinde çalışır
    return ListView.builder(
      itemCount: listings.length,
      itemBuilder: (context, index) {
        return ListingCard(listing: listings[index]);
      },
    );
  },
  loading: () {
    // Veri yüklenirken çalışır
    return Center(child: CircularProgressIndicator());
  },
  error: (Object error, StackTrace stackTrace) {
    // Hata olduğunda çalışır
    return Center(child: Text('Bir hata oluştu: $error'));
  },
);
```

**Neden .when() harikadır?**

1. **Derleyici zorlar:** Üç durumu da yazmazsanız kod derlenmez. Unutma şansınız yok.
2. **Tip güvenliği:** `data` callback'inde `listings` değişkeninin tipi `List<ListingModel>` olarak bilinir — cast yapmanıza gerek yok.
3. **Okunabilirlik:** Kod, "veri varsa bunu yap, yükleniyorsa şunu yap, hata varsa bunu yap" şeklinde çok net okunur.

### 5.4 — AsyncValue'nun Faydalı Metodları

```dart
final asyncValue = ref.watch(allListingsProvider);

asyncValue.hasValue    // Veri var mı? (bool)
asyncValue.hasError    // Hata var mı? (bool)
asyncValue.isLoading   // Yükleniyor mu? (bool)
asyncValue.value       // Veriyi döndürür (T?) — yoksa null
asyncValue.error       // Hatayı döndürür (Object?) — yoksa null
asyncValue.stackTrace  // Stack trace döndürür (StackTrace?)
```

### 5.5 — Takaş'ta AsyncValue Kullanımı

**Örnek 1 — Filtrelenmiş ilanlar:**

```dart
// listings_controller.dart - satır 97-131
final filteredListingsProvider =
    Provider<AsyncValue<List<ListingModel>>>((ref) {
  final listingsAsync = ref.watch(allListingsProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  // ... diğer filtre state'leri

  return listingsAsync.whenData((listings) {
    var filtered = listings;
    // ... filtreleme mantığı
    return filtered;
  });
});
```

- `listingsAsync` bir `AsyncValue<List<ListingModel>>`'dir.
- `.whenData((listings) { ... })` — **Sadece** veri geldiğinde çalışır. Loading ve error durumlarında `AsyncValue` olduğu gibi döner (yani filtreleme yapılmaz).
- `whenData` bir `AsyncValue` döndürür — filtrelenmiş listeyi `AsyncData` olarak sarar.

**Örnek 2 — AsyncValue.guard()

`AsyncValue.guard`, try-catch yazmanın zarif bir alternatifidir:

```dart
// Manuel try-catch (uzun):
state = const AsyncLoading();
try {
  final result = await someAsyncOperation();
  state = AsyncData(result);
} catch (error, stackTrace) {
  state = AsyncError(error, stackTrace);
}

// AsyncValue.guard ile (kısa):
state = const AsyncLoading();
state = await AsyncValue.guard(() => someAsyncOperation());
```

Takaş projesinde `AsyncValue.guard` yoğun olarak kullanılır. Neredeyse her controller metodunda karşınıza çıkacaktır.

---

## 6. ConsumerWidget ve ConsumerStatefulWidget

### 6.1 — ConsumerWidget

**Ne yapar:** Riverpod provider'larına erişebilen bir stateless widget'dır. Normal `StatelessWidget`'ın Riverpod versiyonudur.

**Fark:** Normal `StatelessWidget`'ta `build(BuildContext context)` metodu vardır. `ConsumerWidget`'ta ise `build(BuildContext context, WidgetRef ref)` — ekstra `ref` parametresi vardır.

**Normal StatelessWidget:**

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // ref YOK — provider'lara erişemezsiniz
    return Container();
  }
}
```

**ConsumerWidget:**

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref VAR — provider'lara erişebilirsiniz!
    final listings = ref.watch(allListingsProvider);
    return listings.when(
      data: (data) => ListView(...),
      loading: () => CircularProgressIndicator(),
      error: (e, st) => Text('Hata: $e'),
    );
  }
}
```

**`WidgetRef ref` parametresi:**
- `ref.watch(...)` — Provider'ı dinle
- `ref.read(...)` — Provider'ı oku (dinlemeden)
- `ref.listen(...)` — Provider'ı dinle ve yan etki yap

### 6.2 — ConsumerStatefulWidget

**Ne yapar:** Riverpod provider'larına erişebilen bir stateful widget'dır. Normal `StatefulWidget`'ın Riverpod versiyonudur.

**Ne zaman kullanılır:**
- Widget'ın kendi içinde yaşam döngüsü yönetimi (initState, dispose) gerektiğinde
- Animation controller, text controller gibi kaynakları yönetmeniz gerektiğinde
- initState içinde `ref.listen` çağrısı yapmanız gerektiğinde

**Kullanımı:**

```dart
class MyPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyPage> createState() => _MyPageState();
}

class _MyPageState extends ConsumerState<MyPage> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    // initState içinde ref.listen ile auth durumunu dinle:
    ref.listen(authStateProvider, (previous, next) {
      if (next.value == null) {
        // Kullanıcı çıkış yaptı — login sayfasına yönlendir
        context.go('/login');
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ref, ConsumerState üzerinden otomatik sağlanır
    final theme = ref.watch(themeModeProvider);
    return MaterialApp(themeMode: theme, ...);
  }
}
```

**ConsumerState'in avantajı:**
- `ref` özelliği `ConsumerState` sınıfında bir getter olarak tanımlıdır.
- `initState`, `dispose`, ve `build` dahil olmak üzere tüm metotlarda kullanılabilir.
- Ancak `initState` içinde **sadece `ref.listen` ve `ref.read`** kullanılmalıdır — `ref.watch` kullanılmamalıdır (çünkü initState bir callback değil, yaşam döngüsü metodudur ve `ref.watch` burada doğru çalışmaz).

### 6.3 — Ne Zaman Hangisi?

| Widget Tipi | Ne Zaman |
|---|---|
| `StatelessWidget` | Provider'a erişim gerekmiyorsa |
| `ConsumerWidget` | Provider'a erişim gerekiyor ama yaşam döngüsü yönetimi gerekmiyorsa |
| `StatefulWidget` | Yaşam döngüsü yönetimi gerekiyor ama provider'a erişim gerekmiyorsa |
| `ConsumerStatefulWidget` | Hem provider erişimi hem yaşam döngüsü yönetimi gerekiyorsa |

---

## 7. Takaş Projesindeki Tüm Provider ve Controller Dosyaları

Bu bölümde, Takaş projesindeki HER provider ve controller dosyasının **tam içeriğini** ve **satır satır açıklamasını** bulacaksınız.

---

### 7.1 — lib/core/providers.dart (Temel Provider'lar)

Bu dosya, uygulamanın **temel altyapı servislerini** sağlayan provider'ları içerir. Firebase servisleri ve auth durumu gibi uygulama genelinde kullanılan temel bileşenler burada tanımlanır.

```dart
// ═══════════════════════════════════════════════════════════
// lib/core/providers.dart — TAM DOSYA İÇERİĞİ
// ═══════════════════════════════════════════════════════════

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final storageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});
```

**Satır satır açıklama:**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
```
- **Satır 1:** Riverpod'un ana paketini import eder. `Provider`, `StateProvider`, `StreamProvider`, `FutureProvider`, `ref.watch`, `ref.read` gibi tüm temel bileşenler bu paketten gelir.

```dart
import 'package:firebase_auth/firebase_auth.dart';
```
- **Satır 2:** Firebase Authentication paketini import eder. `User` sınıfı ve `FirebaseAuth` sınıfı bu paketten gelir. Kullanıcı giriş/çıkış/kayıt işlemleri için gereklidir.

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
```
- **Satır 3:** Cloud Firestore paketini import eder. `FirebaseFirestore`, `QuerySnapshot`, `DocumentSnapshot`, `GeoPoint` gibi sınıflar bu paketten gelir. Firestore, uygulamanın ana veritabanıdır.

```dart
import 'package:firebase_storage/firebase_storage.dart';
```
- **Satır 4:** Firebase Storage paketini import eder. `FirebaseStorage` sınıfı bu paketten gelir. Fotoğraf ve dosya yükleme/indirme işlemleri için gereklidir.

---

```dart
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});
```
- **Satır 6-8:** Firebase Authentication servisini sağlayan provider.
- `Provider<FirebaseAuth>` — Salt okunur bir provider. Bir kez oluşturulur ve değişmez.
- `FirebaseAuth.instance` — Firebase Auth'un singleton (tekil) örneği. Tüm uygulama boyunca tek bir FirebaseAuth nesnesi kullanılır.
- **Ne zaman kullanılır:** Kullanıcı giriş/çıkış/kayıt işlemleri yapan repository ve controller sınıfları bu provider'ı kullanarak Firebase Auth servisine erişir.

---

```dart
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});
```
- **Satır 10-12:** Cloud Firestore servisini sağlayan provider.
- `FirebaseFirestore.instance` — Firestore'un singleton örneği.
- **Ne zaman kullanılır:** Repository sınıfları veri okuma/yazma/silme işlemleri yaparken bu provider'ı kullanır.

---

```dart
final storageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});
```
- **Satır 14-16:** Firebase Storage servisini sağlayan provider.
- `FirebaseStorage.instance` — Storage'ın singleton örneği.
- **Ne zaman kullanılır:** İlan fotoğrafları, profil fotoğrafları ve resim mesajları yüklenirken bu provider kullanılır.

---

```dart
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});
```
- **Satır 18-20:** Uygulamanın **en kritik provider'ı**. Kullanıcının giriş/çıkış durumunu gerçek zamanlı dinler.
- `StreamProvider<User?>` — Bir `Stream<User?>` dinler. `User?` çünkü kullanıcı giriş yapmışsa `User` nesnesi, yapmamışsa `null` gelecektir.
- `ref.watch(firebaseAuthProvider)` — FirebaseAuth servisini alır. `watch` kullanılır çünkü bu provider da bir provider'a bağımlıdır.
- `.authStateChanges()` — Firebase'in sunduğu bir `Stream<User?>`. Kullanıcı giriş yaptığında, çıkış yaptığında veya token yenilendiğinde yeni bir değer yayınlar.
- **Kullanıldığı yerler:** Uygulamanın hemen her yerinde — giriş yapmış mı kontrolü, kullanıcı verisi okuma, yetkilendirme kontrolleri için.

---

### 7.2 — lib/features/map/data/location_service.dart (Konum Servisi)

Bu dosya, kullanıcının mevcut konumunu almayı sağlayan servis sınıfını ve bunu Riverpod provider'larına bağlayan tanımları içerir.

```dart
// ═══════════════════════════════════════════════════════════
// lib/features/map/data/location_service.dart — TAM DOSYA İÇERİĞİ
// ═══════════════════════════════════════════════════════════

import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocationService {
  Future<Position?> getCurrentLocationOnce() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (_) {
      try {
        return await Geolocator.getLastKnownPosition();
      } catch (_) {
        return null;
      }
    }
  }
}

final locationServiceProvider =
    Provider<LocationService>((ref) => LocationService());

final userLocationProvider = FutureProvider<Position?>((ref) {
  return ref.watch(locationServiceProvider).getCurrentLocationOnce();
});
```

**Satır satır açıklama:**

```dart
import 'package:geolocator/geolocator.dart';
```
- **Satır 1:** `geolocator` paketini import eder. `Position`, `LocationPermission`, `Geolocator` gibi konum ile ilgili tüm sınıflar bu paketten gelir. Bu paket, cihazın GPS'ini kullanarak konum bilgisi almayı sağlar.

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
```
- **Satır 2:** Riverpod paketini import eder. `Provider` ve `FutureProvider` tanımlamak için gereklidir.

---

```dart
class LocationService {
```
- **Satır 4:** `LocationService` sınıfı tanımı. Bu sınıf, konum alma işlemlerini kapsüller (encapsulate). İş mantığını provider'dan ayırmak için kullanılır.

```dart
  Future<Position?> getCurrentLocationOnce() async {
```
- **Satır 5:** Kullanıcının mevcut konumunu **bir kez** alan asenkron metot.
- `Future<Position?>` — Asenkron bir işlem sonucunda bir `Position` (konum bilgisi) veya `null` (konum alınamazsa) döndürür.
- `async` — Bu metot asenkron çalışır, yani uzun süren konum alma işlemini bloklamadan yapar.
- `getCurrentLocationOnce` — Metot adı. "Once" (bir kez) kelimesi, bu metodun stream değil, tek bir değer döndürdüğünü vurgular.

```dart
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
```
- **Satır 6-7:** Cihazda konum servisinin (GPS) açık olup olmadığını kontrol eder.
- `await` — Asenkron işlemin tamamlanmasını bekler.
- `bool serviceEnabled` — `true` ise GPS açık, `false` ise kapalı.

```dart
      if (!serviceEnabled) return null;
```
- **Satır 8:** GPS kapalıysa `null` döner. Konum almak mümkün değil.

```dart
      LocationPermission permission = await Geolocator.checkPermission();
```
- **Satır 10:** Kullanıcının konum izni verip vermediğini kontrol eder.
- `LocationPermission` — Üç değer alabilir: `whileInUse`, `always`, `denied`, `deniedForever`.

```dart
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
```
- **Satır 11-14:** Eğer kullanıcı konum iznini reddetmişse veya kalıcı olarak reddetmişse `null` döner.

```dart
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
```
- **Satır 16-19:** Cihazın mevcut konumunu alır.
- `desiredAccuracy: LocationAccuracy.high` — Yüksek doğruluk (GPS seviyesi) talep eder. Daha doğru ama daha fazla pil tüketir.
- `timeLimit: const Duration(seconds: 10)` — 10 saniye içinde konum alınamazsa timeout hatası fırlatır. Uygulamanın sonsuza kadar beklemesini önler.

```dart
    } catch (_) {
      try {
        return await Geolocator.getLastKnownPosition();
```
- **Satır 20-22:** Eğer mevcut konum alınırken bir hata olursa, en son bilinen konumu döndürmeye çalışır. Bu bir **fallback** (yedek) stratejisidir.
- `catch (_)` — Hata türünü umursamadan yakalar. `_` kullanılması, hata değişkenini kullanmayacağımız anlamına gelir.
- `getLastKnownPosition()` — Cihazın belleğindeki en son kaydedilmiş konumu getirir.

```dart
      } catch (_) {
        return null;
      }
```
- **Satır 23-25:** Son bilinen konum da alınamazsa `null` döner.

---

```dart
final locationServiceProvider =
    Provider<LocationService>((ref) => LocationService());
```
- **Satır 30-31:** `LocationService` sınıfını sağlayan salt okunur provider.
- `Provider<LocationService>` — Bu provider bir `LocationService` örneği sağlar.
- `(ref) => LocationService()` — Her erişildiğinde yeni bir `LocationService` oluşturur. Aslında Riverpod bunu cache'ler, yani sadece bir kez oluşturulur ve sonrasında aynı nesne döndürülür.
- **Neden Provider<LocatıonService> ve doğrudan sınıf değil?** Çünkü Riverpod'un dependency injection (bağımlılık enjeksiyonu) mekanizmasından yararlanmak istiyoruz. Test edebiliriz, değiştirebiliriz, geçersiz kılabiliriz (invalidate).

```dart
final userLocationProvider = FutureProvider<Position?>((ref) {
  return ref.watch(locationServiceProvider).getCurrentLocationOnce();
});
```
- **Satır 33-35:** Kullanıcının konumunu bir kez getiren `FutureProvider`.
- `FutureProvider<Position?>` — Bir `Future<Position?>` sonucunu yönetir.
- `ref.watch(locationServiceProvider)` — LocationService nesnesini alır. `watch` kullanılmıştır çünkü locationServiceProvider değişirse (örneğin test ortamında mock bir servis verilirse), bu provider da yeniden çalışır.
- `.getCurrentLocationOnce()` — LocationService'teki metodu çağırarak konumu alır.
- **Bu provider'ın state yaşam döngüsü:**
  - İlk erişim: `AsyncLoading()` — Yükleniyor durumu
  - Konum geldi: `AsyncData(position)` — Konum bilgisi hazır
  - Konum alınamadı: `AsyncData(null)` — Null da bir veridir
  - Hata oldu: `AsyncError(error, stackTrace)` — Hata durumu

---

### 7.3 — lib/core/providers/theme_provider.dart (Tema Yönetimi)

Bu dosya, uygulamanın tema modunu (açık, koyu, sistem) yöneten provider ve notifier sınıfını içerir.

```dart
// ═══════════════════════════════════════════════════════════
// lib/core/providers/theme_provider.dart — TAM DOSYA İÇERİĞİ
// ═══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/settings_service.dart';

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref.read(settingsServiceProvider));
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SettingsService _service;

  ThemeModeNotifier(this._service) : super(ThemeMode.system) {
    _loadInitialTheme();
  }

  Future<void> _loadInitialTheme() async {
    final mode = await _service.getThemeMode();
    state = mode;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _service.setThemeMode(mode);
    state = mode;
  }
}
```

**Satır satır açıklama:**

```dart
import 'package:flutter/material.dart';
```
- **Satır 1:** Flutter'ın Material Design paketini import eder. `ThemeMode` enum'ı (light, dark, system) bu paketten gelir.

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
```
- **Satır 2:** Riverpod paketini import eder. `Provider`, `StateNotifierProvider` için gereklidir.

```dart
import '../services/settings_service.dart';
```
- **Satır 3:** Ayarların kalıcı olarak saklandığı `SettingsService` sınıfını import eder. `../services/` — bir üst dizindeki `services` klasörüne gider.

---

```dart
final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});
```
- **Satır 5-7:** `SettingsService` nesnesini sağlayan provider.
- `Provider<SettingsService>` — Salt okunur provider. SettingsService değişmez, sadece bir kez oluşturulur.
- **Rolü:** SettingsService, SharedPreferences kullanarak tema modunu, bildirim ayarlarını vb. cihaza kalıcı olarak kaydeder. Bu provider, o servisi uygulama genelinde erişilebilir kılar.

---

```dart
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref.read(settingsServiceProvider));
});
```
- **Satır 9-12:** Tema modunu yöneten provider. Bu, `StateNotifierProvider` kullanır — Riverpod'un eski ama hâlâ geçerli bir state yönetim modeli.
- `StateNotifierProvider<ThemeModeNotifier, ThemeMode>` — İki generic parametre alır:
  1. `ThemeModeNotifier` — State'i yöneten notifier sınıfı.
  2. `ThemeMode` — State'in tipi (`ThemeMode.light`, `ThemeMode.dark`, `ThemeMode.system`).
- `(ref) { ... }` — Provider'ın creator fonksiyonu. ThemeModeNotifier'ı oluşturur.
- `ref.read(settingsServiceProvider)` — SettingsService nesnesini okur. **`read` kullanılmış**, `watch` değil. Neden? Çünkü creator fonksiyon sadece bir kez çalışır ve SettingsService değişmeyeceği için dinlemeye gerek yoktur.
- `ThemeModeNotifier(ref.read(settingsServiceProvider))` — Notifier'ı oluştururken constructor'a settings servisini enjekte eder (dependency injection).

---

```dart
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
```
- **Satır 14:** StateNotifier sınıfı tanımı.
- `extends StateNotifier<ThemeMode>` — Riverpod'un StateNotifier temel sınıfından kalıtım alır. `ThemeMode` ile parametrelenmiştir, yani bu notifier `ThemeMode` tipinde bir state yönetir.
- `StateNotifier` içinde bir `state` property'si vardır — bu, dinlenen değerdir.

```dart
  final SettingsService _service;
```
- **Satır 15:** SettingsService referansı. `final` olduğu için constructorda atandıktan sonra değiştirilemez. `_` ön eki (underscore) bu alanın private olduğunu belirtir — sadece bu sınıf içinde erişilebilir.

```dart
  ThemeModeNotifier(this._service) : super(ThemeMode.system) {
```
- **Satır 17:** Constructor (kurucu metot).
- `this._service` — Constructor parametresini sınıfın `_service` alanına atar. Kısa yazım şekli.
- `: super(ThemeMode.system)` — Üst sınıfın (StateNotifier) constructor'ını `ThemeMode.system` ile çağırır. Bu, **başlangıç state'inin** sistem varsayılanı olduğu anlamına gelir. Uygulama ilk açıldığında cihazın teması kullanılır.
- `{ _loadInitialTheme(); }` — Constructor gövdesi. Nesne oluşturulur oluşturulmaz kaydedilmiş tema ayarını yükler.

```dart
    _loadInitialTheme();
```
- **Satır 18:** Kaydedilmiş tema ayarını yükleyen private metodu çağırır.

---

```dart
  Future<void> _loadInitialTheme() async {
    final mode = await _service.getThemeMode();
    state = mode;
  }
```
- **Satır 21-24:** Uygulamanın daha önce seçilmiş tema ayarını SharedPreferences'tan yükler.
- `Future<void>` — Asenkron metot, değer döndürmez.
- `_loadInitialTheme` — Private metot (alt çizgi ile başlıyor). Sadece bu sınıf içinde çağrılabilir.
- `await _service.getThemeMode()` — SettingsService'ten kayıtlı tema modunu alır. Bu işlem SharedPreferences'tan okuma yapar, bu yüzden asenkron.
- `state = mode` — State'i günceller. Bu, tüm `ref.watch(themeModeProvider)` yapan widget'ların yeniden çizilmesini tetikler.

---

```dart
  Future<void> setThemeMode(ThemeMode mode) async {
    await _service.setThemeMode(mode);
    state = mode;
  }
```
- **Satır 26-29:** Tema modunu değiştiren public metot.
- `ThemeMode mode` — Parametre olarak yeni tema modunu alır (`ThemeMode.light`, `ThemeMode.dark`, veya `ThemeMode.system`).
- `await _service.setThemeMode(mode)` — Önce yeni tema modunu SharedPreferences'a kaydeder. Böylece uygulama yeniden açıldığında aynı tema korunur.
- `state = mode` — Sonra state'i günceller. Bu satır, tüm dinleyen widget'ların rebuild olmasını tetikler.

**Kullanımı (widget içinde):**

```dart
// Tema modunu oku:
final themeMode = ref.watch(themeModeProvider);

// Tema modunu değiştir:
ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
```

---

### 7.4 — lib/core/services/settings_service.dart (Ayarlar Servisi)

Bu dosya, kullanıcı ayarlarını cihaza kalıcı olarak kaydetmeyi ve okumayı sağlayan servis sınıfını içerir.

```dart
// ═══════════════════════════════════════════════════════════
// lib/core/services/settings_service.dart — TAM DOSYA İÇERİĞİ
// ═══════════════════════════════════════════════════════════

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class SettingsService {
  static const _themeModeKey = 'theme_mode';
  static const _notificationsKey = 'notifications_enabled';
  static const _locationSharingKey = 'location_sharing';
  static const _profileVisibilityKey = 'profile_visibility';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<ThemeMode> getThemeMode() async {
    final prefs = await _prefs;
    final value = prefs.getString(_themeModeKey) ?? 'system';
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await _prefs;
    final value = mode == ThemeMode.light
        ? 'light'
        : mode == ThemeMode.dark
            ? 'dark'
            : 'system';
    await prefs.setString(_themeModeKey, value);
  }

  Future<bool> getNotificationsEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_notificationsKey) ?? true;
  }

  Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_notificationsKey, value);
  }

  Future<bool> getLocationSharing() async {
    final prefs = await _prefs;
    return prefs.getBool(_locationSharingKey) ?? true;
  }

  Future<void> setLocationSharing(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_locationSharingKey, value);
  }

  Future<String> getProfileVisibility() async {
    final prefs = await _prefs;
    return prefs.getString(_profileVisibilityKey) ?? 'public';
  }

  Future<void> setProfileVisibility(String value) async {
    final prefs = await _prefs;
    await prefs.setString(_profileVisibilityKey, value);
  }
}
```

**Satır satır açıklama:**

```dart
import 'package:shared_preferences/shared_preferences.dart';
```
- **Satır 1:** SharedPreferences paketini import eder. Bu paket, basit anahtar-değer çiftlerini cihazın local belleğine kaydetmeyi sağlar. Veritabanı değil — küçük, basit veriler için idealdir.

```dart
import 'package:flutter/material.dart';
```
- **Satır 2:** Flutter Material paketi. `ThemeMode` enum'ı için gereklidir.

---

```dart
class SettingsService {
```
- **Satır 4:** SettingsService sınıfı tanımı. Bu sınıf, kullanıcı ayarlarını kalıcı olarak yöneten bir servis katmanıdır. UI veya state management bağımlılığı yoktur — sadece veri okuma/yazma yapar.

```dart
  static const _themeModeKey = 'theme_mode';
```
- **Satır 5:** SharedPreferences'ta tema modunun saklandığı anahtar. `static const` — sınıf örneği oluşturulmadan erişilebilir ve değiştirilemez.
- `'theme_mode'` — Anahtarın string değeri. SharedPreferences'ta bu isimle saklanır.

```dart
  static const _notificationsKey = 'notifications_enabled';
```
- **Satır 6:** Bildirim ayarının anahtarı.

```dart
  static const _locationSharingKey = 'location_sharing';
```
- **Satır 7:** Konum paylaşımı ayarının anahtarı.

```dart
  static const _profileVisibilityKey = 'profile_visibility';
```
- **Satır 8:** Profil görünürlüğü ayarının anahtarı.

---

```dart
  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();
```
- **Satır 10:** SharedPreferences örneğini sağlayan private getter.
- `Future<SharedPreferences>` — SharedPreferences.getInstance() asenkron bir metottur, bu yüzden bir Future döndürür.
- `get _prefs` — Bu bir property (özellik) tanımıdır, bir metot değil. `_prefs` okunduğunda otomatik olarak `SharedPreferences.getInstance()` çağrılır.
- Bu yazım şekli, her metotta `await SharedPreferences.getInstance()` yazmak yerine `await _prefs` yazmayı sağlar — temizleyici bir kısaltma.

---

```dart
  Future<ThemeMode> getThemeMode() async {
```
- **Satır 12:** Kaydedilmiş tema modunu okuyan asenkron metot.

```dart
    final prefs = await _prefs;
```
- **Satır 13:** SharedPreferences örneğini alır.

```dart
    final value = prefs.getString(_themeModeKey) ?? 'system';
```
- **Satır 14:** SharedPreferences'tan `'theme_mode'` anahtarıyla string değerini okur.
- `?? 'system'` — Null coalescing operatörü. Eğer değer null ise (ilk kez açılıyorsa veya hiç kaydedilmediyse) `'system'` kullanılır.

```dart
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
```
- **Satır 15-22:** String değeri `ThemeMode` enum'ına dönüştürür.
- `'light'` → `ThemeMode.light` — Açık tema
- `'dark'` → `ThemeMode.dark` — Koyu tema
- `default` → `ThemeMode.system` — Cihazın varsayılanı

---

```dart
  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await _prefs;
    final value = mode == ThemeMode.light
        ? 'light'
        : mode == ThemeMode.dark
            ? 'dark'
            : 'system';
    await prefs.setString(_themeModeKey, value);
  }
```
- **Satır 25-33:** Tema modunu SharedPreferences'a kaydeden metot.
- İç içe ternary (üçlü) operatör kullanılmış:
  - `mode == ThemeMode.light` ise `'light'`
  - `mode == ThemeMode.dark` ise `'dark'`
  - değilse `'system'`
- `await prefs.setString(_themeModeKey, value)` — String değeri SharedPreferences'a yazar.

---

```dart
  Future<bool> getNotificationsEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_notificationsKey) ?? true;
  }
```
- **Satır 35-38:** Bildirim ayarını okur.
- `prefs.getBool(_notificationsKey)` — Boolean değer okur.
- `?? true` — Varsayılan olarak bildirimler açık.

```dart
  Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_notificationsKey, value);
  }
```
- **Satır 40-43:** Bildirim ayarını kaydeder.

```dart
  Future<bool> getLocationSharing() async {
    final prefs = await _prefs;
    return prefs.getBool(_locationSharingKey) ?? true;
  }
```
- **Satır 45-48:** Konum paylaşımı ayarını okur. Varsayılan: açık.

```dart
  Future<void> setLocationSharing(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_locationSharingKey, value);
  }
```
- **Satır 50-53:** Konum paylaşımı ayarını kaydeder.

```dart
  Future<String> getProfileVisibility() async {
    final prefs = await _prefs;
    return prefs.getString(_profileVisibilityKey) ?? 'public';
  }
```
- **Satır 55-58:** Profil görünürlüğünü okur. Varsayılan: `'public'` (herkese açık).

```dart
  Future<void> setProfileVisibility(String value) async {
    final prefs = await _prefs;
    await prefs.setString(_profileVisibilityKey, value);
  }
```
- **Satır 60-63:** Profil görünürlüğünü kaydeder.

---

### 7.5 — lib/features/auth/presentation/auth_controller.dart (Kimlik Doğrulama Controller)

Bu dosya, kullanıcı giriş, kayıt ve çıkış işlemlerini yöneten controller'ı içerir. **Code generation** stiliyle yazılmıştır (`@riverpod` annotation'ı kullanır).

```dart
// ═══════════════════════════════════════════════════════════
// lib/features/auth/presentation/auth_controller.dart — TAM DOSYA İÇERİĞİ
// ═══════════════════════════════════════════════════════════

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/auth_repository.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {
    // Initial build
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => 
      ref.read(authRepositoryProvider).signInWithEmail(email, password)
    );
  }

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

**Satır satır açıklama:**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
```
- **Satır 1:** Riverpod code generation paketini import eder. `@riverpod` annotation'ı bu paketten gelir. Bu paket, tekrar eden provider tanımlarını otomatik olarak üretmenizi sağlar.

```dart
import '../data/auth_repository.dart';
```
- **Satır 2:** Auth repository sınıfını import eder. Bu repository, Firebase Auth ile gerçek iletişimi sağlayan sınıftır. Controller, repository'yi kullanarak giriş/çıkış işlemlerini gerçekleştirir.

```dart
part 'auth_controller.g.dart';
```
- **Satır 4:** Code generation tarafından üretilen dosyayı dahil eder.
- `part` — Dart'ın bir dosyayı başka bir dosyanın parçası olarak tanımlama mekanizması.
- `.g.dart` — "Generated Dart" anlamına gelir. `dart run build_runner build` komutu çalıştırıldığında bu dosya otomatik oluşturulur.
- Bu dosya, `_$AuthController` temel sınıfını ve `authControllerProvider` global değişkenini içerir.

---

```dart
@riverpod
```
- **Satır 6:** Riverpod annotation'ı. Bu sınıfın bir Riverpod provider'ı olarak kod üretilmesini sağlar.
- Bu annotation, build_runner'ın bu sınıfı bulmasını ve gerekli kodu üretmesini söyler.
- Üretilen kod şuna benzer:

```dart
// auth_controller.g.dart (otomatik üretilen kod):
final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(AuthController.new);

abstract class _$AuthController extends AsyncNotifier<void> {
  // ... ortak metotlar
}
```

- Yani biz manuel olarak `final authControllerProvider = ...` yazmak ZORUNDA DEĞİLİZ — annotation bunu bizim için üretir!

```dart
class AuthController extends _$AuthController {
```
- **Satır 7:** AuthController sınıfı, otomatik üretilen `_$AuthController` temel sınıfından kalıtım alır.
- `_$AuthController` — Bu sınıf `.g.dart` dosyasında tanımlıdır. `ref` property'sini ve diğer altyapıyı sağlar.
- Bu modelde, temel sınıfın adı daima `_$SınıfAdı` formatındadır.

```dart
  @override
  FutureOr<void> build() {
    // Initial build
  }
```
- **Satır 8-11:** Controller'ın başlangıç state'ini belirleyen metot.
- `@override` — Üst sınıftaki abstract metodu ezer.
- `FutureOr<void>` — Bu, `Future<void>` veya `void` olabilir anlamına gelir. Asenkron veya senkron başlangıç yapılabilir.
- Gövde boş — başlangıçta bir şey yapmaya gerek yok. State otomatik olarak `AsyncData(null)` olur.

---

```dart
  Future<void> signInWithEmail(String email, String password) async {
```
- **Satır 13:** E-posta ile giriş yapan asenkron metot.
- `String email` — Kullanıcının e-posta adresi.
- `String password` — Kullanıcının şifresi.

```dart
    state = const AsyncLoading();
```
- **Satır 14:** State'i loading (yükleniyor) durumuna ayarlar.
- `const AsyncLoading()` — AsyncValue'nun loading durumu. `const` çünkü derleme zamanında bilinen sabit bir değer.
- Bu satır çalıştığında, UI'da `ref.watch(authControllerProvider)` yapan widget'lar loading state'ini alır ve örneğin bir CircularProgressIndicator gösterebilir.

```dart
    state = await AsyncValue.guard(() => 
      ref.read(authRepositoryProvider).signInWithEmail(email, password)
    );
```
- **Satır 15-17:** Asenkron giriş işlemini gerçekleştirir.
- `ref.read(authRepositoryProvider)` — Auth repository'yi alır. `read` kullanılmış çünkü:
  1. Bu bir callback/metot gövdesi — `watch` burada kullanılmamalı
  2. Repository'yi dinlemeye gerek yok, sadece bir kez alıp kullanmak istiyoruz
- `.signInWithEmail(email, password)` — Repository'deki Firebase Auth giriş metodunu çağırır.
- `AsyncValue.guard(() => ...)` — Try-catch'in zarif hali:
  - İşlem başarılı olursa → `state = AsyncData(null)` (void olduğu için null)
  - Hata olursa → `state = AsyncError(error, stackTrace)` (hata bilgileriyle birlikte)
- `await` — İşlemin tamamlanmasını bekler ve sonucu `state`'e atar.

---

```dart
  Future<void> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
```
- **Satır 20-24:** E-posta ile kayıt olan asenkron metot.
- `required` — Bu parametrelerin verilmesi ZORUNLU. Named parameter (isimli parametre) kullanılmış — çağrılırken parametre adını yazmanız gerekir: `registerWithEmail(email: "a@b.com", password: "123", displayName: "Ahmet")`.

```dart
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => 
      ref.read(authRepositoryProvider).registerWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      )
    );
```
- **Satır 25-32:** Aynı loading → guard kalıbı. Repository'deki `registerWithEmail` metodunu çağırır.

---

```dart
  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => 
      ref.read(authRepositoryProvider).signInWithGoogle()
    );
  }
```
- **Satır 35-40:** Google ile giriş yapan metot. Firebase Auth'un Google sign-in özelliğini kullanır.

```dart
  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => 
      ref.read(authRepositoryProvider).signOut()
    );
  }
```
- **Satır 42-47:** Çıkış yapan metot. Firebase oturumunu sonlandırır.

**Ortak kalıp (pattern):**

Tüm metotlar aynı yapıyı izler:

```
1. state = AsyncLoading()     → UI'a "yükleniyor" göster
2. state = AsyncValue.guard(  → İşlemi dene
     () => asyncOperation()      Başarılı: AsyncData(null)
   )                             Hatalı:   AsyncError(...)
```

Bu kalıptan başka hiçbir şey yapmanıza gerek yoktur — Riverpod state'i otomatik yönetir.

---

### 7.6 — lib/features/listings/presentation/listings_controller.dart (İlan Yönetimi)

Bu dosya, Takaş uygulamasının kalbini oluşturur. İlanların gerçek zamanlı dinlenmesi, filtrelenmesi, oluşturulması, güncellenmesi ve silinmesi ile ilgili TÜM provider ve controller'ları içerir.

```dart
// ═══════════════════════════════════════════════════════════
// lib/features/listings/presentation/listings_controller.dart — TAM DOSYA İÇERİĞİ
// ═══════════════════════════════════════════════════════════

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:takash/features/map/data/location_service.dart';
import '../data/listing_repository.dart';
import '../domain/listing_model.dart';
import '../domain/listing_category.dart';
import '../../../core/providers.dart';
```

**Satır satır açıklama:**

```dart
import 'dart:io';
```
- **Satır 1:** Dart'ın core IO (girdi/çıkış) kütüphanesi. `File` sınıfı için gereklidir — fotoğraf yükleme işlemlerinde dosya nesnelerini kullanmak için import edilir.

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
```
- **Satır 2:** Firestore paketi. `GeoPoint` sınıfı için gereklidir — ilanların konumunu temsil eder.

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
```
- **Satır 3:** Riverpod ana paketi. Tüm provider tipleri ve `ref` için gereklidir.

```dart
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
```
- **Satır 4:** GeoFlutterFire Plus paketi. `GeoFirePoint` sınıfı için gereklidir — konum bazlı arama yapmak için geohash hesaplar. Geohash, coğrafi koordinatları kısa bir string'e dönüştürme yöntemidir ve yakınlık aramalarını hızlandırır.

```dart
import 'package:takash/features/map/data/location_service.dart';
```
- **Satır 5:** Location service ve `userLocationProvider` için import.

```dart
import '../data/listing_repository.dart';
```
- **Satır 6:** İlan veri erişim katmanı. Firestore CRUD işlemlerini gerçekleştiren sınıf.

```dart
import '../domain/listing_model.dart';
```
- **Satır 7:** İlan veri modeli. `ListingModel` sınıfı bir ilanın tüm bilgilerini (başlık, açıklama, fotoğraflar, konum, kategori, vb.) içerir.

```dart
import '../domain/listing_category.dart';
```
- **Satır 8:** İlan kategorileri. `ListingCategory` enum'ı ve `ListingStatus` enum'ı bu dosyadadır.

```dart
import '../../../core/providers.dart';
```
- **Satır 9:** Temel provider'lar (`authStateProvider`, `listingRepositoryProvider` gibi).

---

#### Stream Providers — Gerçek Zamanlı Veri

```dart
/// Tüm aktif ilanları dinle
final allListingsProvider = StreamProvider<List<ListingModel>>((ref) {
  final repo = ref.watch(listingRepositoryProvider);
  return repo.getAllActiveListings();
});
```
- **Satır 16-19:** Firestore'daki tüm aktif (silinmemiş) ilanları **gerçek zamanlı** dinleyen provider.
- `StreamProvider<List<ListingModel>>` — Bir ilan listesi stream'i dinler.
- `ref.watch(listingRepositoryProvider)` — Repository'yi alır ve dinler.
- `repo.getAllActiveListings()` — Firestore'daki "listings" koleksiyonunu dinleyen bir stream döndürür.
- **Gerçek zamanlı:** Firestore'da bir ilan eklenirse, silinirse veya değiştirilirse, bu stream otomatik olarak güncel listeyi yayınlar ve `allListingsProvider`'ın state'i güncellenir.

---

```dart
/// Arama yarıçapı (km)
final searchRadiusProvider =
    StateProvider<double>((ref) => 100.0);
```
- **Satır 22-23:** Yakınlık araması için yarıçapı tutan StateProvider. Varsayılan 100 km.

---

```dart
/// Yakındaki ilanları dinle
final nearbyListingsProvider = StreamProvider<List<ListingModel>>((ref) {
  final userLocation = ref.watch(userLocationProvider).value;
  final radius = ref.watch(searchRadiusProvider);
  final allListingsAsync = ref.watch(allListingsProvider);

  if (userLocation == null) {
    return Stream.value([]);
  }

  final repo = ref.watch(listingRepositoryProvider);

  return repo
      .getNearbyListings(
    center: GeoPoint(userLocation.latitude, userLocation.longitude),
    radiusInKm: radius,
  )
      .map((nearbyListings) {
    if (nearbyListings.isEmpty && allListingsAsync.hasValue) {
      return allListingsAsync.value!.where((l) => l.location != null).toList();
    }
    return nearbyListings;
  });
});
```
- **Satır 26-48:** Yakındaki ilanları dinleyen karmaşık bir StreamProvider.

**Detaylı satır açıklaması:**

```dart
  final userLocation = ref.watch(userLocationProvider).value;
```
- Kullanıcının konumunu dinler. `.value` ile `AsyncValue<Position?>`'ın içinden `Position?` değerini çıkarır.
- `ref.watch` kullanılmış — konum değişirse bu provider yeniden çalışır.

```dart
  final radius = ref.watch(searchRadiusProvider);
```
- Arama yarıçapını dinler. Kullanıcı yarıçapı değiştirirse bu provider yeniden çalışır.

```dart
  final allListingsAsync = ref.watch(allListingsProvider);
```
- Tüm ilanları dinler. Fallback (yedek) olarak kullanılacak.

```dart
  if (userLocation == null) {
    return Stream.value([]);
  }
```
- Konum alınamamışsa boş bir liste stream'i döner. `Stream.value([])` — tek bir değer (boş liste) yayınlayan bir stream oluşturur.

```dart
  final repo = ref.watch(listingRepositoryProvider);
```
- Repository'yi alır.

```dart
  return repo
      .getNearbyListings(
    center: GeoPoint(userLocation.latitude, userLocation.longitude),
    radiusInKm: radius,
  )
```
- `GeoPoint(userLocation.latitude, userLocation.longitude)` — Kullanıcının konumunu Firestore `GeoPoint` nesnesine dönüştürür.
- `radiusInKm: radius` — Yarıçapı kilometre cinsinden verir.
- `getNearbyListings()` — GeoFlutterFire Plus kullanarak, belirlenen merkez noktasından belirli yarıçap içindeki ilanları getiren bir stream döndürür. Geohash tabanlı sorgulama yapar.

```dart
      .map((nearbyListings) {
    if (nearbyListings.isEmpty && allListingsAsync.hasValue) {
      return allListingsAsync.value!.where((l) => l.location != null).toList();
    }
    return nearbyListings;
  });
```
- `.map()` — Stream'den gelen veriyi dönüştürür.
- Eğer yakında ilan bulunamazsa ve tüm ilanlar yüklenmişse, fallback olarak **konumu olan tüm ilanları** gösterir.
- `allListingsAsync.hasValue` — Tüm ilanlar provider'ının veri taşıyıp taşımadığını kontrol eder.
- `.where((l) => l.location != null)` — Sadece konumu olan ilanları filtreler.
- `!` — Null olmayan değer assertion'ı. `hasValue` kontrolünden sonra `value`'nin null olmayacağını biliyoruz.

---

```dart
/// Belirli bir kullanıcının ilanlarını dinle
final userListingsProvider =
    StreamProvider.family<List<ListingModel>, String>((ref, userId) {
  final repo = ref.watch(listingRepositoryProvider);
  return repo.getUserListings(userId);
});
```
- **Satır 51-55:** `family` modifier ile parametreli provider. Her `userId` için ayrı stream dinlenir.

```dart
/// Tek ilan detayını getir
final singleListingProvider =
    FutureProvider.family<ListingModel?, String>((ref, listingId) {
  final repo = ref.watch(listingRepositoryProvider);
  return repo.getListingById(listingId);
});
```
- **Satır 58-62:** Tek bir ilan getiren `FutureProvider.family`. Stream değil, Future — çünkü ilan detayı sürekli güncellenmesi gereken bir veri değil, bir kez getirip cache'lemek yeterli.

```dart
/// İlan favorilerde mi?
final isFavoriteProvider =
    StreamProvider.family<bool, String>((ref, listingId) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(false);

  final repo = ref.watch(listingRepositoryProvider);
  return repo.isFavorite(user.uid, listingId);
});
```
- **Satır 65-72:** Bir ilanın favori olup olmadığını dinleyen parametreli StreamProvider.
- Kullanıcı giriş yapmamışsa her zaman `false` döner.
- Giriş yapmışsa, Firestore'daki favori durumunu gerçek zamanlı dinler.

```dart
/// Kullanıcının tüm favori ilanları
final userFavoritesProvider = StreamProvider<List<ListingModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);

  final repo = ref.watch(listingRepositoryProvider);
  return repo.getUserFavorites(user.uid);
});
```
- **Satır 75-81:** Kullanıcının tüm favori ilanlarını getiren StreamProvider.

---

#### Filtre & Arama State'leri

```dart
/// Arama sorgusu
final searchQueryProvider = StateProvider<String>((ref) => '');
```
- **Satır 88:** Arama kutusuna yazılan metni tutar. Boş string ile başlar.

```dart
/// Seçili kategori filtresi (null = hepsi)
final categoryFilterProvider = StateProvider<ListingCategory?>((ref) => null);
```
- **Satır 91:** Seçili kategoriyi tutar. `null` hiçbir filtre seçilmemiş demektir.

```dart
/// Kendi ilanlarımı göster/gizle (Default: false - Gizli)
final showMyListingsProvider = StateProvider<bool>((ref) => false);
```
- **Satır 94:** Kullanıcının kendi ilanlarını listede gösterip göstermeyeceğini tutar.

---

#### Filtrelenmiş İlan Listesi

```dart
/// Filtrelenmiş ilan listesi
final filteredListingsProvider =
    Provider<AsyncValue<List<ListingModel>>>((ref) {
  final listingsAsync = ref.watch(allListingsProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final categoryFilter = ref.watch(categoryFilterProvider);
  final showMyListings = ref.watch(showMyListingsProvider);
  final currentUser = ref.watch(authStateProvider).value;

  return listingsAsync.whenData((listings) {
    var filtered = listings;

    // Kendi ilanlarımı filtrele (Eğer showMyListings false ise gizle)
    if (currentUser != null && !showMyListings) {
      filtered = filtered.where((l) => l.ownerId != currentUser.uid).toList();
    }

    // Kategori filtresi
    if (categoryFilter != null) {
      filtered = filtered.where((l) => l.category == categoryFilter).toList();
    }

    // Arama filtresi
    if (searchQuery.isNotEmpty) {
      final lower = searchQuery.toLowerCase();
      filtered = filtered
          .where((l) =>
              l.title.toLowerCase().contains(lower) ||
              l.description.toLowerCase().contains(lower) ||
              l.wantedItem.toLowerCase().contains(lower))
          .toList();
    }

    return filtered;
  });
});
```
- **Satır 97-131:** Bu, Riverpod'un **türetilmiş state (derived state)** konsektinin harika bir örneğidir.

**Detaylı açıklama:**

```dart
final filteredListingsProvider =
    Provider<AsyncValue<List<ListingModel>>>((ref) {
```
- `Provider<AsyncValue<List<ListingModel>>>` — Bu provider'ın dönüş tipi `AsyncValue<List<ListingModel>>`'dir. Neden doğrudan `List<ListingModel>` değil? Çünkü kaynak verisi (`allListingsProvider`) bir `AsyncValue` ve loading/error durumlarını da iletmek istiyoruz.

```dart
  final listingsAsync = ref.watch(allListingsProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final categoryFilter = ref.watch(categoryFilterProvider);
  final showMyListings = ref.watch(showMyListingsProvider);
  final currentUser = ref.watch(authStateProvider).value;
```
- Beş farklı provider'ı `ref.watch` ile dinler. **Herhangi biri değişirse**, bu provider **yeniden çalışır** ve filtrelenmiş liste güncellenir.
- Bu, **reaktif programlamanın** özüdür: veri değiştiğinde sonucu otomatik güncelleme.

```dart
  return listingsAsync.whenData((listings) {
```
- `.whenData()` — Sadece veri başarıyla geldiyse çalışır. Loading durumunda `AsyncLoading` döner, error durumunda `AsyncError` döner — yani filtreleme yapılmaz, UI loading/error göstergesi gösterir.

```dart
    var filtered = listings;
```
- Başlangıçta tüm ilanları alır. `var` kullanılmış çünkü sonradan değişecek.

```dart
    if (currentUser != null && !showMyListings) {
      filtered = filtered.where((l) => l.ownerId != currentUser.uid).toList();
    }
```
- Kullanıcı giriş yapmışsa ve "kendi ilanlarımı göster" kapalıysa, kullanıcının kendi ilanlarını listeden çıkarır.
- `.where((l) => l.ownerId != currentUser.uid)` — İlan sahibi ID'si mevcut kullanıcı ID'sine eşit olmayanları tutar.
- `.toList()` — `where` bir `Iterable` döndürür, `.toList()` ile `List`'e dönüştürür.

```dart
    if (categoryFilter != null) {
      filtered = filtered.where((l) => l.category == categoryFilter).toList();
    }
```
- Kategori filtresi seçilmişse, sadece o kategorideki ilanları tutar.

```dart
    if (searchQuery.isNotEmpty) {
      final lower = searchQuery.toLowerCase();
      filtered = filtered
          .where((l) =>
              l.title.toLowerCase().contains(lower) ||
              l.description.toLowerCase().contains(lower) ||
              l.wantedItem.toLowerCase().contains(lower))
          .toList();
    }
```
- Arama sorgusu boş değilse, başlık, açıklama veya istenen ürün (wantedItem) alanlarında arama yapar.
- `toLowerCase()` — Büyük/küçük harf duyarsız arama sağlar. Hem arama sorgusu hem de karşılaştırılan alan küçük harfe dönüştürülür.

---

#### İlan Oluşturma Controller

```dart
/// İlan oluşturma/düzenleme state'i
final createListingControllerProvider =
    AsyncNotifierProvider<CreateListingController, void>(
  CreateListingController.new,
);
```
- **Satır 138-141:** İlan CRUD işlemlerini yöneten controller provider'ı.
- `AsyncNotifierProvider<CreateListingController, void>` — Manuel stil (code generation değil). Generic parametreler: controller sınıfı ve state tipi.
- `CreateListingController.new` — Controller sınıfının yeni bir örneğini oluşturan constructor reference.

```dart
class CreateListingController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}
```
- **Satır 143-145:** Controller sınıfı tanımı. `AsyncNotifier<void>`'dan kalıtım alır. `build()` metodu boş — başlangıç state'i yok.

**createListing metodu:**

```dart
  Future<String?> createListing({
    required String title,
    required String description,
    required ListingCategory category,
    required String wantedItem,
    required List<File> images,
    GeoPoint? location,
  }) async {
```
- **Satır 148-155:** Yeni ilan oluşturan metot. `String?` döndürür — başarılı olursa oluşturulan ilanın ID'si, başarısız olursa `null`.
- `required` parametreler: başlık, açıklama, kategori, istenen ürün, fotoğraflar — bunlar zorunlu.
- `GeoPoint? location` — Opsiyonel (nullable). Kullanıcı konum seçmeyebilir.

```dart
    final user = ref.read(authStateProvider).value;
    if (user == null) return null;
```
- **Satır 156-157:** Mevcut kullanıcıyı kontrol eder. Giriş yapılmamışsa `null` döner.

```dart
    String? resultId;
```
- **Satır 159:** Oluşturulan ilanın ID'sini tutacak değişken.

```dart
    state = await AsyncValue.guard(() async {
      final repo = ref.read(listingRepositoryProvider);

      String? geohash;
      if (location != null) {
        final GeoFirePoint geoFirePoint = GeoFirePoint(location);
        geohash = geoFirePoint.geohash;
      }

      resultId = await repo.createListing(
        ownerId: user.uid,
        title: title,
        description: description,
        category: category,
        wantedItem: wantedItem,
        images: images,
        location: location,
        geohash: geohash,
      );
    });
```
- **Satır 161-181:** `AsyncValue.guard` ile asenkron işlemi sarar.
- `GeoFirePoint(location)` — GeoPoint'i GeoFirePoint'e dönüştürür.
- `.geohash` — Konumun geohash string'ini hesaplar. Örneğin: `"sxk3m"` gibi kısa bir string. Bu, yakınlık aramalarını çok hızlandırır.
- `repo.createListing(...)` — Tüm ilan bilgilerini repository'ye gönderir. Repository, Firestore'a yazar ve Storage'a fotoğrafları yükler.

```dart
    return state.hasError ? null : resultId;
```
- **Satır 183:** State'te hata varsa `null`, yoksa ilan ID'sini döndürür.

**updateListing metodu:**

```dart
  Future<bool> updateListing({
    required ListingModel listing,
    List<File>? newImages,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repo = ref.read(listingRepositoryProvider);

      if (newImages != null && newImages.isNotEmpty) {
        await repo.deleteImages(listing.id);
        final newUrls = await repo.uploadImages(newImages, listing.id);
        final updatedListing = listing.copyWith(imageUrls: newUrls);
        await repo.updateListing(updatedListing);
      } else {
        await repo.updateListing(listing);
      }
    });

    return !state.hasError;
  }
```
- **Satır 187-208:** İlan güncelleme metodu.
- `state = const AsyncLoading()` — Loading durumunu ayarlar.
- Eğer yeni fotoğraflar varsa: eski fotoğrafları sil, yenilerini yükle, listing modelini güncelle.
- `listing.copyWith(imageUrls: newUrls)` — `copyWith` metodu, mevcut modelin bir kopyasını oluşturur ve sadece belirtilen alanları değiştirir. Orijinal model değişmez.
- `return !state.hasError` — Hata yoksa `true`, varsa `false` döner.

**deleteListing metodu:**

```dart
  Future<bool> deleteListing(String listingId) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repo = ref.read(listingRepositoryProvider);
      await repo.deleteListing(listingId);
    });

    return !state.hasError;
  }
```
- **Satır 211-220:** İlan silme metodu. Basit loading → guard kalıbı.

**updateStatus metodu:**

```dart
  Future<bool> updateStatus(String listingId, ListingStatus status) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repo = ref.read(listingRepositoryProvider);
      await repo.updateListingStatus(listingId, status);
    });

    return !state.hasError;
  }
```
- **Satır 223-232:** İlan durumunu değiştirme (aktif, tamamlandı, vb.).

**toggleFavorite metodu:**

```dart
  Future<void> toggleFavorite(ListingModel listing) async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    final repo = ref.read(listingRepositoryProvider);
    await repo.toggleFavorite(user.uid, listing);
  }
```
- **Satır 235-241:** Favori ekleme/çıkarma metodu.
- `AsyncValue.guard` kullanılmamış — çünkü favori işlemi için loading state göstermeye gerek yok. Bu bir **optimistik güncelleme** (optimistic update) yaklaşımıdır: UI anında güncellenir, arka planda Firestore'a yazılır.
- `toggleFavorite` — Eğer ilan favorilerdeyse çıkarır, değilse ekler.

---

### 7.7 — lib/features/chat/presentation/chat_controller.dart (Sohbet Yönetimi)

Bu dosya, mesajlaşma sisteminin tüm provider ve controller'larını içerir.

```dart
// ═══════════════════════════════════════════════════════════
// lib/features/chat/presentation/chat_controller.dart — TAM DOSYA İÇERİĞİ
// ═══════════════════════════════════════════════════════════

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/chat_repository.dart';
import '../domain/chat_model.dart';
import '../domain/message_model.dart';
import '../../../core/providers.dart';
import '../../profile/data/profile_repository.dart';
import '../../auth/domain/user_model.dart';
```

**Satır satır açıklama:**

```dart
import 'dart:io';
```
- **Satır 1:** `File` sınıfı için — resim mesajı gönderirken dosya nesnesi kullanılır.

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
```
- **Satır 2:** Riverpod paketi.

```dart
import '../data/chat_repository.dart';
```
- **Satır 3:** Chat veri erişim katmanı. Firestore'da sohbet ve mesaj CRUD işlemleri.

```dart
import '../domain/chat_model.dart';
```
- **Satır 4:** Chat veri modeli. `ChatModel` sınıfı bir sohbetin bilgilerini (katılımcılar, son mesaj, okunmamış sayısı) tutar.

```dart
import '../domain/message_model.dart';
```
- **Satır 5:** Mesaj veri modeli. `MessageModel` sınıfı bir mesajın bilgilerini (metin, gönderen, zaman, vb.) tutar.

```dart
import '../../../core/providers.dart';
```
- **Satır 6:** Temel provider'lar — `authStateProvider` gibi.

```dart
import '../../profile/data/profile_repository.dart';
```
- **Satır 7:** Profil repository — sohbet başlatırken kullanıcı profillerini almak için.

```dart
import '../../auth/domain/user_model.dart';
```
- **Satır 8:** Kullanıcı veri modeli. `UserModel` sınıfı.

---

```dart
/// Kullanıcının tüm sohbetlerini dinleyen provider
final userChatsProvider = StreamProvider<List<ChatModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  
  return ref.watch(chatRepositoryProvider).getUserChats(user.uid);
});
```
- **Satır 11-16:** Kullanıcının tüm sohbetlerini gerçek zamanlı dinleyen StreamProvider.
- `ref.watch(authStateProvider).value` — Firebase User nesnesini alır.
- Kullanıcı giriş yapmamışsa boş liste stream'i döner.
- `ref.watch(chatRepositoryProvider)` — Chat repository'yi alır ve dinler.
- `.getUserChats(user.uid)` — Bu kullanıcının dahil olduğu tüm sohbetleri getiren stream. Yeni mesaj geldiğinde, sohbet oluşturulduğunda veya silindiğinde otomatik güncellenir.

---

```dart
/// Belirli bir sohbetin mesajlarını dinleyen provider
final chatMessagesProvider = StreamProvider.family<List<MessageModel>, String>((ref, chatId) {
  return ref.watch(chatRepositoryProvider).getMessages(chatId);
});
```
- **Satır 19-21:** Parametreli StreamProvider. Her `chatId` için ayrı bir mesaj stream'i dinlenir.
- `String` parametre tipi — sohbet ID'si.

---

```dart
/// Toplam okunmamış mesaj sayısını hesaplayan provider (Badge için)
final unreadCountProvider = Provider<int>((ref) {
  final chats = ref.watch(userChatsProvider).value ?? [];
  final currentUser = ref.watch(authStateProvider).value;
  if (currentUser == null) return 0;

  int total = 0;
  for (final chat in chats) {
    final count = chat.unreadCounts[currentUser.uid];
    if (count != null) total += count.toInt();
  }
  return total;
});
```
- **Satır 24-35:** Türetilmiş (derived) bir provider. Okunmamış mesajların toplam sayısını hesaplar.
- `Provider<int>` — Salt okunur provider. Hesaplanmış bir değer sağlar.
- `ref.watch(userChatsProvider).value ?? []` — Sohbet listesini alır. Veri yoksa (loading/error) boş liste kullanır.
- `chat.unreadCounts[currentUser.uid]` — Her sohbet modelinde, her kullanıcı için kaç okunmamış mesaj olduğu bir Map'te tutulur. `Map<String, int>` yapısındadır.
- `.toInt()` — Firestore'dan gelen değer bir `num` (sayı) olabilir, `int`'e dönüştürür.
- **Ne zaman kullanılır:** Alt navigasyon çubuğundaki (bottom navigation) chat ikonunun üstünde kırmızı badge göstermek için.

---

```dart
/// Sohbet işlemlerini yöneten controller
final chatControllerProvider = AsyncNotifierProvider<ChatController, void>(ChatController.new);
```
- **Satır 38:** Chat controller provider'ı. Manuel stilde yazılmış.

```dart
class ChatController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}
```
- **Satır 40-42:** Controller sınıfı. Başlangıç state'i yok.

**startChat metodu:**

```dart
  Future<ChatModel?> startChat({
    required UserModel otherUser,
    String? listingId,
    String? listingTitle,
  }) async {
    final currentUser = ref.read(userDataProvider(ref.read(authStateProvider).value?.uid ?? '')).value;
    if (currentUser == null) return null;
```
- **Satır 45-51:** Sohbet başlatma veya mevcut sohbeti getirme metodu.
- `UserModel otherUser` — Sohbet edilecek karşı kullanıcı.
- `String? listingId` — Opsiyonel — ilanla ilgili bir sohbet olabilir.
- `ref.read(userDataProvider(...))` — `family` provider ile belirli bir kullanıcı ID'sine ait profil verisini alır.
- `ref.read(authStateProvider).value?.uid ?? ''` — Mevcut kullanıcının ID'sini alır. Giriş yapılmamışsa boş string kullanır (ki bu durumda zaten null return edilir).

```dart
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      return await ref.read(chatRepositoryProvider).createOrGetChat(
        currentUser: currentUser,
        otherUser: otherUser,
        listingId: listingId,
        listingTitle: listingTitle,
      );
    });
    
    state = const AsyncData(null);
    return result.value;
```
- **Satır 53-64:** Loading → guard kalıbı.
- `createOrGetChat` — İki kullanıcı arasında daha önce bir sohbet varsa onu getirir, yoksa yeni oluşturur. Bu, her mesaj gönderişinde yeni sohbet oluşturulmasını önler.
- `state = const AsyncData(null)` — State'i doğrudan data durumuna ayarlar (void olduğu için null). Bu, guard başarılı veya başarısız olduktan sonra loading'den çıkmasını sağlar.
- `result.value` — Guard'ın sonucunu döndürür. Başarılıysa `ChatModel`, başarısızsa `null`.

**sendTextMessage metodu:**

```dart
  Future<void> sendTextMessage(String chatId, String text) async {
    final userId = ref.read(authStateProvider).value?.uid;
    if (userId == null) return;

    await ref.read(chatRepositoryProvider).sendMessage(chatId, text, userId);
  }
```
- **Satır 68-73:** Metin mesajı gönderir.
- `ref.read(authStateProvider).value?.uid` — `?.` (null-aware access) — değer null değilse uid'i al, null ise null döndür.
- `sendMessage(chatId, text, userId)` — Firestore'a yeni bir mesaj belgesi ekler.

**sendImageMessage metodu:**

```dart
  Future<void> sendImageMessage(String chatId, File imageFile) async {
    final userId = ref.read(authStateProvider).value?.uid;
    if (userId == null) return;

    try {
      await ref.read(chatRepositoryProvider).sendImageMessage(chatId, imageFile, userId);
    } catch (e) {
      rethrow;
    }
  }
```
- **Satır 76-85:** Resim mesajı gönderir.
- `try-catch` ve `rethrow` — Hatayı yakalayıp tekrar fırlatır. Bu, UI katmanında hatayı yakalayıp kullanıcıya göstermek için yapılır (örneğin dosya boyutu limitini aştığında SnackBar göstermek).

**deleteMessage metodu:**

```dart
  Future<void> deleteMessage(String chatId, MessageModel message) async {
    await ref.read(chatRepositoryProvider).deleteMessage(chatId, message);
  }
```
- **Satır 88-90:** Mesajı siler. Firestore'dan mesaj belgesini kaldırır.

**markMessagesAsRead metodu:**

```dart
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    await ref.read(chatRepositoryProvider).markAsRead(chatId, userId);
  }
```
- **Satır 93-95:** Sohbetteki tüm mesajları okundu olarak işaretler. Karşı tarafın okunmamış sayacını sıfırlar.

---

### 7.8 — lib/features/profile/presentation/profile_controller.dart (Profil Yönetimi)

Bu dosya, kullanıcı profil bilgilerini güncelleme işlemlerini yöneten controller'ı içerir. **Code generation** stiliyle yazılmıştır.

```dart
// ═══════════════════════════════════════════════════════════
// lib/features/profile/presentation/profile_controller.dart — TAM DOSYA İÇERİĞİ
// ═══════════════════════════════════════════════════════════

import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:takash/features/profile/data/profile_repository.dart';
import 'package:takash/features/auth/domain/user_model.dart';

part 'profile_controller.g.dart';
```

**Satır satır açıklama:**

```dart
import 'dart:io';
```
- **Satır 1:** `File` sınıfı — profil fotoğrafı yüklerken dosya nesnesi kullanılır.

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
```
- **Satır 2:** Riverpod code generation paketi. `@riverpod` annotation'ı için.

```dart
import 'package:takash/features/profile/data/profile_repository.dart';
```
- **Satır 3:** Profil repository — Firestore'daki kullanıcı belgelerini günceller.

```dart
import 'package:takash/features/auth/domain/user_model.dart';
```
- **Satır 4:** `UserModel` sınıfı — kullanıcı veri modeli.

```dart
part 'profile_controller.g.dart';
```
- **Satır 6:** Otomatik üretilen kod dosyasını dahil eder. `profileControllerProvider` ve `_$ProfileController` bu dosyada tanımlıdır.

---

```dart
@riverpod
class ProfileController extends _$ProfileController {
  @override
  FutureOr<void> build() {
    // Initial state is null or void
  }
```
- **Satır 8-13:** Code generation stiliyle tanımlanmış controller.
- `@riverpod` — Bu annotation, `build_runner`'ın `profileControllerProvider`'ı otomatik üretmesini sağlar.
- `_$ProfileController` — Üretilen temel sınıf. `ref` property'sini ve altyapıyı sağlar.
- `FutureOr<void> build()` — Başlangıç state'i boş.

---

**updateProfile metodu:**

```dart
  Future<void> updateProfile({
    required UserModel user,
    String? displayName,
    String? bio,
    File? imageFile,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(profileRepositoryProvider);
      
      String? photoUrl = user.photoUrl;
      
      // 1. Eğer yeni bir fotoğraf seçildiyse yükle
      if (imageFile != null) {
        photoUrl = await repo.uploadProfilePhoto(user.uid, imageFile);
      }
      
      // 2. Güncellenmiş kullanıcı nesnesini oluştur
      final updatedUser = user.copyWith(
        displayName: displayName,
        bio: bio,
        photoUrl: photoUrl,
      );
      
      // 3. Firestore'da güncelle
      await repo.updateProfile(updatedUser);
    });
  }
```
- **Satır 16-43:** Profil güncelleme metodu.

**Adım adım:**

```dart
    required UserModel user,
    String? displayName,
    String? bio,
    File? imageFile,
```
- `user` — Mevcut kullanıcı modeli. Zorunlu (`required`).
- `displayName` — Yeni görünen ad. Opsiyonel — `null` ise değiştirilmez.
- `bio` — Yeni bio. Opsiyonel — `null` ise değiştirilmez.
- `imageFile` — Yeni profil fotoğrafı dosyası. Opsiyonel — `null` ise değiştirilmez.

```dart
      String? photoUrl = user.photoUrl;
```
- Başlangıçta mevcut fotoğraf URL'sini alır.

```dart
      if (imageFile != null) {
        photoUrl = await repo.uploadProfilePhoto(user.uid, imageFile);
      }
```
- Yeni fotoğraf seçilmişse, Firebase Storage'a yükler ve yeni URL'yi alır.

```dart
      final updatedUser = user.copyWith(
        displayName: displayName,
        bio: bio,
        photoUrl: photoUrl,
      );
```
- `copyWith` — Mevcut kullanıcı modelinin bir kopyasını oluşturur ve sadece belirtilen alanları değiştirir. `null` verilen alanlar değişmez (eğer copyWith implementasyonu null'ları ignore ediyorsa) veya null olarak ayarlanır.

```dart
      await repo.updateProfile(updatedUser);
```
- Güncellenmiş kullanıcı modelini Firestore'a kaydeder.

---

**uploadPhoto metodu:**

```dart
  Future<void> uploadPhoto({
    required UserModel user,
    required File imageFile,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(profileRepositoryProvider);
      final photoUrl = await repo.uploadProfilePhoto(user.uid, imageFile);
      final updatedUser = user.copyWith(photoUrl: photoUrl);
      await repo.updateProfile(updatedUser);
    });
  }
```
- **Satır 46-57:** Sadece profil fotoğrafı yüklemek için ayrı bir metot. Profil bilgilerini değiştirmeden sadece fotoğraf günceller.
- Neden ayrı bir metot? Çünkü bazen kullanıcı profil bilgilerini değil, sadece fotoğrafını değiştirmek ister. Bu metot, bu tekil işlemi basitleştirir.

---

### 7.9 — lib/features/notifications/presentation/notification_controller.dart (Bildirim Yönetimi)

Bu dosya, push bildirimlerini dinleme, okuma, silme ve okunmamış sayıyı takip etme işlemlerini yönetir.

```dart
// ═══════════════════════════════════════════════════════════
// lib/features/notifications/presentation/notification_controller.dart — TAM DOSYA İÇERİĞİ
// ═══════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../data/notification_service.dart';
import '../domain/notification_model.dart';
import '../../../core/providers.dart';
```

**Satır satır açıklama:**

```dart
import 'package:flutter/foundation.dart';
```
- **Satır 1:** Flutter'ın temel kütüphanesi. `debugPrint` fonksiyonu için gereklidir.

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
```
- **Satır 2:** Riverpod paketi.

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
```
- **Satır 3:** Firebase Cloud Messaging (FCM) paketi. `RemoteMessage` sınıfı ve `FirebaseMessaging` sınıfı bu paketten gelir. Push bildirimleri almak ve yönetmek için gereklidir.

```dart
import '../data/notification_service.dart';
```
- **Satır 4:** Bildirim servisi — Firestore'daki bildirimler koleksiyonu ile etkileşim.

```dart
import '../domain/notification_model.dart';
```
- **Satır 5:** Bildirim veri modeli.

```dart
import '../../../core/providers.dart';
```
- **Satır 6:** Temel provider'lar — `authStateProvider`, `notificationServiceProvider`.

---

```dart
final unreadNotificationCountProvider = StateProvider<int>((ref) => 0);
```
- **Satır 8:** Okunmamış bildirim sayısını tutan StateProvider. Başlangıç değeri `0`.
- Bu, `StreamProvider` değil `StateProvider` çünkü sayı manuel olarak güncellenir (foreground mesaj geldiğinde artırılır, okundu işaretlendiğinde sıfırlanır).

---

```dart
final userNotificationsProvider =
    StreamProvider<List<NotificationModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);

  return ref.watch(notificationServiceProvider).getUserNotifications(user.uid);
});
```
- **Satır 10-16:** Kullanıcının tüm bildirimlerini gerçek zamanlı dinleyen StreamProvider.
- Giriş yapılmamışsa boş liste döner.
- `getUserNotifications(user.uid)` — Firestore'daki "notifications" koleksiyonunu bu kullanıcıya ait olanlardan dinler.

---

```dart
final notificationControllerProvider =
    AsyncNotifierProvider<NotificationController, void>(
        NotificationController.new);
```
- **Satır 18-20:** Bildirim controller provider'ı. Manuel stil.

---

```dart
class NotificationController extends AsyncNotifier<void> {
  late final NotificationService _notificationService;
```
- **Satır 22-23:** Controller sınıfı.
- `late final` — `late` bu değişkenin daha sonra (build metodunda) başlatılacağını belirtir. `final` ise bir kez atandıktan sonra değiştirilemeyeceğini belirtir. İkisi birlikte: "geç başlatılacak ama sonra değiştirilemeyecek."
- `NotificationService _notificationService` — Bildirim servisi referansı. Private.

---

```dart
  @override
  Future<void> build() async {
    _notificationService = ref.read(notificationServiceProvider);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleForegroundMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message);
    });
  }
```
- **Satır 26-36:** Controller'ın build metodu. Başlangıç ayarlarını yapar.

```dart
    _notificationService = ref.read(notificationServiceProvider);
```
- Bildirim servisini alır ve sınıf değişkenine atar. `ref.read` çünkü bu bir kez yapılır.

```dart
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleForegroundMessage(message);
    });
```
- **Foreground mesaj dinleyicisi.** Uygulama açıkken bir bildirim geldiğinde tetiklenir.
- `FirebaseMessaging.onMessage` — Foreground mesajları dinleyen bir stream.
- `RemoteMessage` — Firebase'den gelen mesaj nesnesi. Bildirim başlığı, gövdesi ve data payload içerir.

```dart
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message);
    });
```
- **Bildirim tıklama dinleyicisi.** Kullanıcı bir bildirime tıklayarak uygulamayı açtığında tetiklenir.
- `onMessageOpenedApp` — Uygulama arka plandayken bildirime tıklayınca gelen stream.

---

```dart
  Future<void> initialize() async {
    state = const AsyncLoading();
    await AsyncValue.guard(() async {
      await _notificationService.initialize();
    });
    state = const AsyncData(null);
  }
```
- **Satır 38-44:** Bildirim servisini başlatma metodu. FCM token'ını alır, izinleri ister.
- `state = const AsyncData(null)` — Guard tamamlandıktan sonra state'i data durumuna ayarlar. Guard içinde hata olsa bile bu satır çalışmaz çünkü guard hata döndürdüğünde fonksiyon normal akışta devam eder... Aslında bu kodda küçük bir tutarsızlık var: guard hata verirse `state = AsyncError(...)` olur, sonraki `state = const AsyncData(null)` bu hatayı ezer. Bu, uygulamanın "initialize hata verse bile devam et" stratejisi olabilir.

---

```dart
  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      ref.read(unreadNotificationCountProvider.notifier).state++;
    }
  }
```
- **Satır 46-51:** Foreground'ta bildirim geldiğinde çağrılır.
- `message.notification` — Mesajın bildirim içeriği (başlık, gövde). `null` olabilir (sadece data payload olan mesajlar).
- `ref.read(unreadNotificationCountProvider.notifier).state++` — Okunmamış bildirim sayısını 1 artırır. `.state++` mevcut değeri 1 artırır.

---

```dart
  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    if (data['relatedId'] != null) {
      debugPrint('Bildirim tıklandı: ${data['type']} - ${data['relatedId']}');
    }
  }
```
- **Satır 53-58:** Bildirime tıklandığında çağrılır.
- `message.data` — Bildirimin data payload'u. `Map<String, dynamic>` yapısındadır. Özel anahtar-değer çiftleri içerir (örneğin: `{'type': 'chat', 'relatedId': 'chat123'}`).
- `data['relatedId']` — İlgili nesnenin ID'si (hangi sohbet, hangi ilan, vb.).
- `debugPrint` — Sadece debug modda çalışan print fonksiyonu. Release build'lerde otomatik kaldırılır.

---

```dart
  Future<void> markAsRead(String notificationId) async {
    state = const AsyncLoading();
    await AsyncValue.guard(() async {
      await _notificationService.markAsRead(notificationId);
    });
    state = const AsyncData(null);
  }
```
- **Satır 60-66:** Tek bir bildirimi okundu olarak işaretler. Firestore'daki bildirim belgesini günceller.

```dart
  Future<void> markAllAsRead() async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return;

    state = const AsyncLoading();
    await AsyncValue.guard(() async {
      await _notificationService.markAllAsRead(user.uid);
      ref.read(unreadNotificationCountProvider.notifier).state = 0;
    });
    state = const AsyncData(null);
  }
```
- **Satır 68-78:** Tüm bildirimleri okundu olarak işaretler.
- `_notificationService.markAllAsRead(user.uid)` — Bu kullanıcıya ait tüm okunmamış bildirimleri toplu olarak günceller.
- `ref.read(unreadNotificationCountProvider.notifier).state = 0` — Okunmamış sayacı sıfırlar.

```dart
  Future<void> deleteNotification(String notificationId) async {
    state = const AsyncLoading();
    await AsyncValue.guard(() async {
      await _notificationService.deleteNotification(notificationId);
    });
    state = const AsyncData(null);
  }
```
- **Satır 80-86:** Bir bildirimi siler.

```dart
  Future<int> getUnreadCount() async {
    final user = ref.read(authStateProvider).value;
    if (user == null) return 0;

    return await _notificationService.getUnreadCount(user.uid);
  }
```
- **Satır 88-93:** Firestore'dan okunmamış bildirim sayısını sorgular ve döndürür.

```dart
  Future<void> refreshUnreadCount() async {
    final count = await getUnreadCount();
    ref.read(unreadNotificationCountProvider.notifier).state = count;
  }
```
- **Satır 95-98:** Okunmamış sayacı Firestore ile yeniden senkronize eder. `getUnreadCount()` ile güncel sayıyı alır ve StateProvider'ı günceller.

---

## Ek: Takaş Projesindeki Provider Bağımlılık Haritası

Tüm provider'lar arasındaki bağımlılıkları görselleştirelim:

```
═══════════════════════════════════════════════════════════════
                    TEMEL SAĞLAYICILAR
═══════════════════════════════════════════════════════════════

firebaseAuthProvider (Provider<FirebaseAuth>)
firestoreProvider   (Provider<FirebaseFirestore>)
storageProvider     (Provider<FirebaseStorage>)
authStateProvider   (StreamProvider<User?>)
    └── depends on: firebaseAuthProvider

═══════════════════════════════════════════════════════════════
                    SERVİS SAĞLAYICILARI
═══════════════════════════════════════════════════════════════

locationServiceProvider  (Provider<LocationService>)
userLocationProvider     (FutureProvider<Position?>)
    └── depends on: locationServiceProvider

settingsServiceProvider  (Provider<SettingsService>)
themeModeProvider        (StateNotifierProvider<ThemeModeNotifier, ThemeMode>)
    └── depends on: settingsServiceProvider

═══════════════════════════════════════════════════════════════
                    İLAN SAĞLAYICILARI
═══════════════════════════════════════════════════════════════

allListingsProvider          (StreamProvider<List<ListingModel>>)
searchRadiusProvider         (StateProvider<double>)
searchQueryProvider          (StateProvider<String>)
categoryFilterProvider       (StateProvider<ListingCategory?>)
showMyListingsProvider       (StateProvider<bool>)

nearbyListingsProvider       (StreamProvider<List<ListingModel>>)
    └── depends on: userLocationProvider, searchRadiusProvider, allListingsProvider

userListingsProvider         (StreamProvider.family<List<ListingModel>, String>)
singleListingProvider        (FutureProvider.family<ListingModel?, String>)
isFavoriteProvider           (StreamProvider.family<bool, String>)
    └── depends on: authStateProvider

userFavoritesProvider        (StreamProvider<List<ListingModel>>)
    └── depends on: authStateProvider

filteredListingsProvider     (Provider<AsyncValue<List<ListingModel>>)
    └── depends on: allListingsProvider, searchQueryProvider,
                     categoryFilterProvider, showMyListingsProvider,
                     authStateProvider

createListingControllerProvider (AsyncNotifierProvider<CreateListingController, void>)
    └── depends on: authStateProvider, listingRepositoryProvider

═══════════════════════════════════════════════════════════════
                    SOHBET SAĞLAYICILARI
═══════════════════════════════════════════════════════════════

userChatsProvider            (StreamProvider<List<ChatModel>>)
    └── depends on: authStateProvider, chatRepositoryProvider

chatMessagesProvider         (StreamProvider.family<List<MessageModel>, String>)

unreadCountProvider          (Provider<int>)
    └── depends on: userChatsProvider, authStateProvider

chatControllerProvider       (AsyncNotifierProvider<ChatController, void>)

═══════════════════════════════════════════════════════════════
                    BİLDİRİM SAĞLAYICILARI
═══════════════════════════════════════════════════════════════

unreadNotificationCountProvider  (StateProvider<int>)
userNotificationsProvider        (StreamProvider<List<NotificationModel>>)
    └── depends on: authStateProvider, notificationServiceProvider

notificationControllerProvider   (AsyncNotifierProvider<NotificationController, void>)
```

---

## Ek: Sık Kullanılan Kalıplar (Patterns)

### Kalıp 1: Loading → Guard → Sonuç

Takaş'ta en çok kullanılan kalıp:

```dart
state = const AsyncLoading();        // 1. UI'a loading göster
state = await AsyncValue.guard(()    // 2. İşlemi dene
    => asyncOperation()
);
// 3. state otomatik olarak:
//    - Başarılı → AsyncData(result)
//    - Hata     → AsyncError(error, stackTrace)
```

### Kalıp 2: Null Check ve Erken Dönüş

```dart
final user = ref.read(authStateProvider).value;
if (user == null) return null;  // veya return; veya return false;
```

### Kalıp 3: Türetilmiş State (Derived State)

```dart
final derivedProvider = Provider<ResultType>((ref) {
  final data1 = ref.watch(sourceProvider1);
  final data2 = ref.watch(sourceProvider2);
  // hesaplama yap ve döndür
  return computeResult(data1, data2);
});
```

### Kalıp 4: Family ile Parametreli Provider

```dart
final parametricProvider = Provider.family<ResultType, ParamType>((ref, param) {
  return computeResult(param);
});

// Kullanım:
ref.watch(parametricProvider(someParam));
```

---

Bu doküman, Takaş Flutter projesindeki Riverpod state management yapısının her detayını kapsamaktadır. Her dosya, her satır ve her kavram açıklanmıştır. Sorularınız olduğunda bu dokümana başvurabilirsiniz.
