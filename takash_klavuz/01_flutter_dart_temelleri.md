# Flutter ve Dart Temelleri — Takaş Projesi Üzerinden Öğreniyoruz

> Bu belge, Flutter ve Dart konusunda **hiçbir bilgisi olmayan** birinin, Takaş projesinin gerçek kodlarıyla adım adım öğrenmesi için hazırlanmıştır.
> Her kavram açıklanacak, her terim tanımlanacak, her örnek projeden alınacaktır.

---

## İçindekiler

1. [Flutter Nedir?](#1-flutter-nedir)
2. [Dart Dili Temelleri](#2-dart-dili-temelleri)
   - 2.1 [Değişkenler (var, final, const, late)](#21-değişkenler-var-final-const-late)
   - 2.2 [Veri Tipleri (String, int, double, bool, List, Map)](#22-veri-tipleri-string-int-double-bool-list-map)
   - 2.3 [Null Safety (?, !, late, required)](#23-null-safety--late-required)
   - 2.4 [Fonksiyonlar](#24-fonksiyonlar)
   - 2.5 [Sınıflar (class, constructor, extends, mixins)](#25-sınıflar-class-constructor-extends-mixins)
   - 2.6 [Async/Await (Future, Stream, async, await)](#26-asyncawait-future-stream-async-await)
   - 2.7 [Generics (List\<T\>, Map\<K,V\>)](#27-generics-listt-mapkv)
   - 2.8 [Enum](#28-enum)
   - 2.9 [Extensions](#29-extensions)
3. [Widget Sistemi](#3-widget-sistemi)
   - 3.1 [Widget Nedir? (StatelessWidget vs StatefulWidget)](#31-widget-nedir-statelesswidget-vs-statefulwidget)
   - 3.2 [build() Metodu](#32-build-metodu)
   - 3.3 [Widget Ağacı Kavramı](#33-widget-ağacı-kavramı)
   - 3.4 [setState() Ne Yapar?](#34-setstate-ne-yapar)
   - 3.5 [Context Nedir?](#35-context-nedir)
   - 3.6 [Key Kavramı (ValueKey, GlobalKey)](#36-key-kavramı-valuekey-globalkey)
4. [Material Design Bileşenleri](#4-material-design-bileşenleri)
5. [Layout Sistemi](#5-layout-sistemi)

---

## 1. Flutter Nedir?

Flutter, Google tarafından geliştirilen, **tek bir kod tabanından** hem iOS hem Android hem web hem masaüstü (Windows, macOS, Linux) uygulamaları oluşturmanıza olanak tanıyan bir **UI (Kullanıcı Arayüzü) framework'üdür**.

### Framework Nedir?

Framework (çerçeve), yazılımcıların işini kolaylaştıran, hazır kod ve araç koleksiyonudur. Flutter da bir framework'tür: düğmeler, listeler, sayfa geçişleri, animasyonlar gibi şeyleri sıfırdan yazmanıza gerek kalmadan hazır şablonlar sunar.

### Cross-Platform (Çapraz Platform) Nedir?

Geleneksel mobil geliştirmede:
- **iOS** uygulamaları için Swift/Objective-C dili ile Xcode kullanılır
- **Android** uygulamaları için Kotlin/Java dili ile Android Studio kullanılır
- Yani aynı uygulamayı **iki kez** yazmanız gerekir

Flutter ise **cross-platform** (çapraz platform) bir yaklaşımdır. Siz Dart dilinde bir kez kod yazarsınız, Flutter bu kodu hem iOS hem Android'e derler. Bu, zamandan ve maliyetten büyük tasarruf sağlar.

### Flutter Nasıl Çalışır? (Derleme Süreci)

Flutter'ın diğer cross-platform araçlardan (React Native gibi) en büyük farkı, **native (yerel) koda derlenmesidir**.

```
Dart Kodunuz (örn: main.dart)
        │
        ▼
  Dart Derleyici (AOT - Ahead of Time)
        │
        ├──► iOS için ──► ARM makine kodu (doğrudan çalışır)
        ├──► Android için ──► ARM makine kodu (doğrudan çalışır)
        └──► Web için ──► JavaScript/WebAssembly
```

**AOT (Ahead of Time) Derleme:** Uygulamanız yayınlanmadan ÖNCE, Dart kodları doğrudan makine diline (ARM işlemci komutlarına) çevrilir. Bu sayede uygulama çok hızlı çalışır çünkü çalışma zamanında yorumlama yapılmaz.

Flutter, kendi rendering (görüntüleme) motorunu (Skia/Impeller) kullanır. Yani Android'in veya iOS'un yerel UI bileşenlerine (button, text vb.) ihtiyaç duymaz. Her pikseli kendisi çizer. Bu da demek ki:
- Her platformda **aynı görünüm** elde edersiniz
- Platform-specific (platforma özel) hatalar最小 olur

### Takaş Projesinde Flutter'ın Rolü

Takaş, insanların yakınındaki kişilerle eşya takası yapmasını sağlayan bir mobil uygulamadır. Bu projede Flutter kullanılmıştır çünkü:

1. Tek kod tabanından hem iOS hem Android uygulaması çıkar
2. Zengin UI bileşenleri (kartlar, haritalar, animasyonlar) kolayca oluşturulur
3. Firebase entegrasyonu Flutter'da çok güçlüdür

**Takaş'ta Flutter'ın giriş noktası — `main.dart`:**

```dart
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ... başlangıç işlemleri ...
  runApp(
    const ProviderScope(
      child: TakashApp(),
    ),
  );
}
```

Burada `runApp()` fonksiyonu, Flutter framework'üne **"uygulamam başlatılmaya hazır, şimdi ekrana çiz"` der. `TakashApp` widget'ı uygulamanın kök (root) widget'ıdır.

### Dart Nedir?

Dart, Google tarafından oluşturulmuş, **nesne yönelimli**, **statik tipli** bir programlama dilidir. Flutter'ın resmi dilidir.

- **Nesne yönelimli (Object-Oriented):** Her şey bir "nesne"dir. Sınıflar (class) üzerinden yapılır.
- **Statik tipli:** Değişkenlerin tipleri (String, int vb.) derleme zamanında bilinir. Bu, hataları erken yakalamanızı sağlar.
- **JIT ve AOT destekler:** Geliştirme sırasında hot-reload için JIT (Just in Time), yayınlama sırasında performans için AOT kullanır.

---

## 2. Dart Dili Temelleri

### 2.1 Değişkenler (var, final, const, late)

Değişken, bilgisayar belleğinde bir değer saklayan **isimlendirilmiş kutu**dur. Dart'ta değişken tanımlamanın birkaç yolu vardır:

#### var — Türü Derleyicinin Anladığı Değişken

`var` anahtar kelimesiyle bir değişken tanımladığınızda, Dart atadığınız değere bakarak tipi otomatik olarak belirler (buna **type inference** — tip çıkarımı denir).

```dart
var isim = 'Takaş';       // Dart bunun String olduğunu anlar
var sayi = 42;             // Dart bunun int olduğunu anlar
var pi = 3.14;             // Dart bunun double olduğunu anlar
```

> **Önemli:** `var` ile tanımlanan değişkene ilk atanan tip sabitlenir. Yani `var isim = 'Takaş';` dedikten sonra `isim = 42;` yapamazsınız çünkü `isim` artık bir `String`'dir.

#### final — Bir Kez Atanan Değişken

`final`, bir değişkenin değerinin **sadece bir kez** atanabileceğini belirtir. Atandıktan sonra değiştirilemez. Ancak değeri **çalışma zamanında** (runtime) belirlenebilir.

```dart
// Takaş projesinden — main.dart
final router = ref.watch(routerProvider);
```

Burada `router` değişkeni, uygulama çalıştığında `ref.watch(routerProvider)` ifadesinin sonucuna göre değerini alır. Bu değer bir kez atanır ve sonrasında değişmez.

Başka bir örnek:

```dart
final suAnkiZaman = DateTime.now();  // Çalışma zamanında hesaplanır
// suAnkiZaman = DateTime.now();     // HATA! final değişken tekrar atanamaz
```

#### const — Derleme Zamanında Sabit

`const` da `final` gibi değiştirilemez, ancak daha katıdır: değeri **derleme zamanında** (compile-time) bilinen sabit bir değer olmalıdır. Yani `DateTime.now()` gibi çalışma zamanında hesaplanan bir şey `const` olamaz.

```dart
const pi = 3.14159;           // Derleme zamanında biliniyor — TAMAM
const uygulamaAdi = 'Takaş';  // Derleme zamanında biliniyor — TAMAM

// const simdi = DateTime.now(); // HATA! DateTime.now() derleme zamanında bilinemez
```

**Takaş projesinden yoğun `const` kullanımı — `listing_card.dart`:**

```dart
const ListingCard({
  super.key,
  required this.listing,
  required this.onTap,
});
```

```dart
const SizedBox(height: 60),
const Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 40),
```

Flutter'da `const` kullanmak **performansı artırır** çünkü Flutter aynı `const` objeyi yeniden oluşturmaz, bellekteki aynı yere referans verir. Bu yüzden Flutter geliştiriciler mümkün olduğunca `const` kullanmaya çalışır.

#### late — Geç Başlatılan Değişken

`late` anahtar kelimesi, bir değişkenin **ilk kullanılacağı zamana kadar** değer almayacağını, ancak kesinlikle bir değer alacağını söyler.

```dart
late String kullaniciAdi;

// ... daha sonra ...
kullaniciAdi = 'Ahmet';  // Artık değer atandı, kullanılabilir
```

Eğer `late` bir değişkene değer atamadan kullanmaya çalışırsanız, **runtime hatası** (LateInitializationError) alırsınız.

Takaş projesinde doğrudan `late` kullanımı görmesek de, Flutter'ın kendi içinde `late` sıkça kullanılır. Örneğin `State` sınıfında `mounted` property'si veya controller'ların başlatılmasında.

#### Değişken Tanımlama Karşılaştırma Tablosu

| Anahtar Kelime | Değiştirilebilir mi? | Ne Zaman Değer Alır? | Kullanım Senaryosu |
|---|---|---|---|
| `var` | Evet | Her zaman | Genel amaçlı değişkenler |
| `final` | Hayır (1 kez atanır) | Çalışma zamanı | Değişmeyecek ama runtime'da hesaplanan değerler |
| `const` | Hayır (1 kez atanır) | Derleme zamanı | Asla değişmeyen sabitler (pi, uygulama adı) |
| `late` | Evet (ama 1 kez) | İlk kullanımdan önce | Geç başlatılacak değişkenler |

---

### 2.2 Veri Tipleri (String, int, double, bool, List, Map)

Her programlama dilinde veri tipleri, bir değişkende ne tür bir değer saklanabileceğini tanımlar. Dart'ta temel veri tipleri şunlardır:

#### String — Metin (Yazı) Tipi

`String`, bir veya birden fazla karakterden oluşan metin ifadelerini saklar. Tek tırnak `'` veya çift tırnak `"` ile tanımlanır.

```dart
String uygulamaAdi = 'Takaş';
String slogan = "Yakınındakilerle takas yap";
```

**String Birleştirme (Interpolation):**

Dart'ta `$` işareti ile bir değişkeni string içine gömebilirsiniz. Daha karmaşık ifadeler için `${}` kullanılır.

```dart
String ad = 'Takaş';
String mesaj = 'Hoş geldin, $ad!';               // "Hoş geldin, Takaş!"
String uzunMesaj = 'Uygulama: ${ad.toUpperCase()}';  // "Uygulama: TAKAS"
```

**Takaş'tan örnek — `listing_card.dart`:**

```dart
Text(
  '${listing.imageUrls.length}',  // String interpolation ile sayıyı metne dönüştürme
  style: const TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  ),
),
```

```dart
SnackBar(content: Text('Giriş hatası: ${error.toString()}')),  // login_screen.dart
```

#### int — Tam Sayı Tipi

`int`, ondalıksız tam sayıları saklar: -5, 0, 42, 1000 vb.

```dart
int kullaniciSayisi = 1500;
int derece = -10;
int sifir = 0;
```

**Takaş'tan örnek — `user_model.dart`:**

```dart
final int ratingCount;       // Kullanıcının aldığı değerlendirme sayısı
final int totalImageCount;   // Kullanıcının toplam fotoğraf sayısı
```

#### double — Ondalıklı Sayı Tipi

`double`, ondalıklı sayıları saklar: 3.14, -0.5, 100.0 vb.

```dart
double pi = 3.14159;
double sicaklik = 36.6;
```

**Takaş'tan örnek — `listing_card.dart` içinde mesafe hesaplama:**

```dart
final double distance = Helpers.calculateDistance(
  GeoPoint(userLocation.latitude, userLocation.longitude),
  listing.location!,
);
```

**Takaş'tan örnek — `user_model.dart`:**

```dart
final double rating;  // Kullanıcının puanı (örn: 4.7)
```

#### bool — Mantıksal (Doğru/Yanlış) Tipi

`bool`, sadece iki değer alabilir: `true` (doğru) veya `false` (yanlış). Karar verme işlemlerinde kullanılır.

```dart
bool isLoggedIn = true;
bool isAdmin = false;
```

**Takaş'tan örnek — `listing_card.dart`:**

```dart
final isFavorite = ref.watch(isFavoriteProvider(listing.id)).value ?? false;
```

Burada `isFavorite` değişkeni, ilanın favori olup olmadığını tutar (`true` = favoride, `false` = favoride değil).

**Takaş'tan örnek — `login_screen.dart`:**

```dart
onPressed: authState.isLoading ? null : _onLogin,
```

Burada `authState.isLoading` bir `bool`'dur. Eğer yükleniyorsa (`true`), buton devre dışı kalır (`null`). Yüklenmiyorsa (`false`), `_onLogin` fonksiyonu çalışır. Bu yapıya **ternary operator (üçlü operatör)** denir: `koşul ? doğruDeğer : yanlışDeğer`.

#### List — Liste (Dizi) Tipi

`List`, birden fazla değeri sıralı bir şekilde saklar. Diğer dillerdeki "array" (dizi) kavramına karşılık gelir. Dart'ta List generic bir tiptir, yani listenin ne tür elemanlar içereceğini belirtirsiniz: `List<String>`, `List<int>` vb.

```dart
List<String> meyveler = ['Elma', 'Armut', 'Muz'];
List<int> notlar = [85, 90, 78, 92];
```

**Liste Elemanlarına Erişim:**

```dart
meyveler[0]    // 'Elma' — indeksler 0'dan başlar
meyveler[1]    // 'Armut'
meyveler.length // 3 — eleman sayısı
```

**Liste Metotları:**

```dart
meyveler.add('Çilek');         // Sonuna ekle: ['Elma', 'Armut', 'Muz', 'Çilek']
meyveler.remove('Armut');      // 'Armut' u çıkar
meyveler.contains('Muz');      // true — Muz var mı?
meyveler.isEmpty;              // false — boş mu?
```

**Takaş'tan örnek — `listing_model.dart`:**

```dart
final List<String> imageUrls;  // İlanın fotoğraf URL'leri listesi
```

Bu, ilanın birden fazla fotoğrafı olabileceğini ve bunların URL'lerinin bir listede tutulacağını gösterir.

**Takaş'tan örnek — `listing_model.dart` içinde fromJson:**

```dart
imageUrls: List<String>.from(json['imageUrls'] ?? []),
```

Burada `List<String>.from()`, bir veriyi `String` listesine dönüştürür. `json['imageUrls']` Firestore'dan gelen ham veridir. `?? []` ise eğer bu veri `null` ise boş bir liste `[]` kullan anlamına gelir.

**Takaş'tan örnek — `listing_card.dart` içinde liste kontrolü:**

```dart
listing.imageUrls.isNotEmpty    // En az bir fotoğraf var mı?
    ? CachedNetworkImage(       // Varsa: fotoğrafı göster
        imageUrl: listing.imageUrls.first,  // İlk fotoğrafı al
      )
    : Container(                // Yoksa: boş konteyner göster
        child: Icon(Icons.image),
      ),
```

`imageUrls.first` listenin ilk elemanını verir. `isNotEmpty` ise listenin boş olup olmadığını kontrol eder.

#### Map — Anahtar-Değer Çifti Tipi

`Map`, her değerin bir **anahtara (key)** bağlı olduğu bir veri yapısıdır. Sözlük (dictionary) gibi çalışır.

```dart
Map<String, int> yaslar = {
  'Ali': 25,
  'Ayşe': 30,
  'Mehmet': 22,
};

yaslar['Ali']        // 25
yaslar['Fatma']      // null — Fatma anahtarı yok
yaslar.containsKey('Ayşe')  // true
```

**Takaş'tan örnek — `listing_model.dart` içinde toJson:**

```dart
Map<String, dynamic> toJson() {
  return {
    'id': id,
    'ownerId': ownerId,
    'title': title,
    'description': description,
    'category': category.name,
    'imageUrls': imageUrls,
    'wantedItem': wantedItem,
    'location': location,
    'geohash': geohash,
    'status': status.name,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
```

Burada `Map<String, dynamic>` ne anlama gelir?
- **String:** Anahtarlar (key) her zaman bir String'dir: `'id'`, `'title'`, `'category'` vb.
- **dynamic:** Değerler farklı tiplerde olabilir: `id` bir String, `imageUrls` bir List, `createdAt` bir Timestamp vb. `dynamic` tipi "herhangi bir tip olabilir" demektir.

Bu yapı, veritabanına (Firestore) veri kaydederken çok kullanılır çünkü Firestore verileri anahtar-değer çiftleri olarak saklar.

**Takaş'tan örnek — `user_model.dart` içinde fromJson:**

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

Bu `fromJson` metodu, Firestore'dan gelen `Map<String, dynamic>` yapısını bir `UserModel` nesnesine dönüştürür. Her alanı Map'ten çıkarıp modelin constructor'ına (yapıcı metoduna) verir.

---

### 2.3 Null Safety (?, !, late, required)

Null safety, Dart'ın en önemli özelliklerinden biridir. **Null**, "değer yok" veya "boş" anlamına gelen özel bir değerdir. Null safety sistemi, null değerlerin istenmeyen yerlerde kullanılmasını engelleyerek uygulamanın çökmesini (crash) önler.

Dart'ta varsayılan olarak, bir değişken **null olamaz**. Null olabileceğini açıkça belirtmeniz gerekir.

#### ? (Soru İşareti) — Null Olabilir İşareti

Bir değişken tipinin yanına `?` koyarsanız, o değişkenin null olabileceğini belirtirsiniz.

```dart
String isim = 'Ahmet';      // null OLAMAZ — her zaman bir String değer olmalı
String? takmaAd = null;     // null OLABİLİR — null veya bir String olabilir
String? sehir = 'İstanbul'; // null OLABİLİR — şu an 'İstanbul' ama null da olabilir
```

**Takaş'tan örnek — `listing_model.dart`:**

```dart
final GeoPoint? location;   // İlanın konumu olabilir de olmayabilir de
final String? geohash;      // Geohash değeri olabilir de olmayabilir de
```

**Takaş'tan örnek — `user_model.dart`:**

```dart
final String? photoUrl;   // Kullanıcının fotoğraf URL'i yoksa null olur
final String? bio;         // Kullanıcının biyografisi yoksa null olur
```

Kullanıcı henüz fotoğraf yüklememişse `photoUrl` null olur. Eğer null safety olmasaydı ve biz bu null değere erişmeye çalışsaydık, uygulama çökerdi.

#### ?? (Null Coalescing — Null Birleştirme Operatörü)

`??` operatörü, "eğer soldaki değer null ise, sağdaki değeri kullan" anlamına gelir.

```dart
String? ad;
String gosterilecekAd = ad ?? 'Misafir';  // ad null olduğu için 'Misafir' kullanılır
```

**Takaş'tan örnek — `listing_card.dart`:**

```dart
final isFavorite = ref.watch(isFavoriteProvider(listing.id)).value ?? false;
```

Burada `ref.watch(...).value` null olabilir (henüz veri yüklenmemişse). Eğer null ise `false` (favoride değil) olarak kabul edilir.

**Takaş'tan örnek — `user_model.dart` içinde fromJson:**

```dart
uid: json['uid'] ?? '',                      // uid yoksa boş string kullan
rating: (json['rating'] ?? 0.0).toDouble(),  // rating yoksa 0.0 kullan
ratingCount: json['ratingCount'] ?? 0,       // ratingCount yoksa 0 kullan
totalImageCount: json['totalImageCount'] ?? 0,
```

Bu, Firestore'dan gelen verilerde bazı alanların eksik olabileceği durumlar için güvenli bir yaklaşımdır.

#### ! (Ünlem İşareti) — Null Değil Assertion (Sert Beyan)

`!` operatörü, Dart'a "Bu değerin null olmadığına EMİNİM, eğer null ise uygulama çökebilir ama bunu kabul ediyorum" demektir. Buna **null assertion** denir.

```dart
String? isim = 'Ahmet';
String kesinIsim = isim!;  // "isim'in null olmadığını biliyorum" — TAMAM

String? bosIsim = null;
String hataYapacak = bosIsim!;  // RUNTIME HATA! bosIsim null
```

> **Dikkat:** `!` operatörünü kullanmak tehlikelidir. Eğer değer gerçekten null ise uygulama çöker. Sadece %100 emin olduğunuz durumlarda kullanın.

**Takaş'tan örnek — `listing_card.dart`:**

```dart
final double distance = Helpers.calculateDistance(
  GeoPoint(userLocation.latitude, userLocation.longitude),
  listing.location!,  // location'ın null olmadığını biliyoruz çünkü üstte kontrol ettik
);
```

Yukarıda şu kontrol yapılmıştı:

```dart
if (userLocation != null && listing.location != null) {
  // Bu bloğun İÇİNDEYİZ — listing.location null değil!
  final double distance = Helpers.calculateDistance(
    ...,
    listing.location!,  // Güvenli çünkü if bloğu null olmadığını garanti etti
  );
}
```

**Takaş'tan örnek — `login_screen.dart`:**

```dart
if (_formKey.currentState!.validate()) {
```

`_formKey.currentState!` — formKey'in currentState'inin null olmadığını beyan ediyoruz. Bu güvenlidir çünkü `_formKey` bir `GlobalKey<FormState>` olarak tanımlanmıştır ve form oluşturulduktan sonra her zaman bir currentState'e sahiptir.

#### required — Zorunlu Parametre

`required` anahtar kelimesi, bir fonksiyon veya constructor parametresinin **mutlaka verilmesi gerektiğini** belirtir. Verilmezse derleme hatası alınır.

**Takaş'tan örnek — `listing_card.dart`:**

```dart
const ListingCard({
  super.key,
  required this.listing,   // listing PARAMETRESİ ZORUNLU
  required this.onTap,     // onTap PARAMETRESİ ZORUNLU
});
```

Bu şu anlama gelir: `ListingCard` widget'ını kullanırken `listing` ve `onTap` parametrelerini vermek ZORUNDASINIZ. Aksi halde kod derlenmez.

```dart
// DOĞRU — tüm zorunlu parametreler verilmiş:
ListingCard(
  listing: myListing,
  onTap: () { /* ... */ },
)

// YANLIŞ — derleme hatası:
ListingCard(
  listing: myListing,
  // onTap eksik!
)
```

**Takaş'tan örnek — `listing_model.dart` constructor'ı:**

```dart
ListingModel({
  required this.id,
  required this.ownerId,
  required this.title,
  required this.description,
  required this.category,
  required this.imageUrls,
  required this.wantedItem,
  this.location,          // required DEĞİL — opsiyonel, null olabilir
  this.geohash,           // required DEĞİL — opsiyonel, null olabilir
  this.status = ListingStatus.active,  // varsayılan değer verilmiş
  required this.createdAt,
});
```

Burada `id`, `title` gibi alanlar zorunludur çünkü bir ilan bu bilgiler olmadan anlamsızdır. Ancak `location` ve `geohash` opsiyoneldir — kullanıcı konum paylaşmak zorunda değildir. `status` alanı ise varsayılan olarak `ListingStatus.active` değerini alır.

---

### 2.4 Fonksiyonlar

Fonksiyon (method/metod), belirli bir işi yapan, yeniden kullanılabilir kod bloğudur. Fonksiyonlar veri alabilir (parametre) ve veri döndürebilir (return).

#### Temel Fonksiyon Yapısı

```dart
DönüşTipi fonksiyonAdı(ParametreTipi parametreAdı) {
  // Yapılacak işler
  return döndürülecekDeğer;
}
```

**Takaş'tan örnek — `helpers.dart`:**

```dart
static String formatDistance(double distanceInKm) {
  if (distanceInKm < 1) {
    return '${(distanceInKm * 1000).round()} m';
  }
  return '${distanceInKm.toStringAsFixed(1)} km';
}
```

Bu fonksiyonun parçalarını inceleyelim:
- `static` — Bu fonksiyon sınıfın bir örneği olmadan çağrılabilir. `Helpers.formatDistance(...)` gibi.
- `String` — Dönüş tipi. Bu fonksiyon bir String döndürür.
- `formatDistance` — Fonksiyonun adı.
- `double distanceInKm` — Parametre. Bir `double` (ondalıklı sayı) alır ve bu değere `distanceInKm` adını verir.
- `return` — Fonksiyonun döndürdüğü değer.

**Kullanımı:**
```dart
String mesafe = Helpers.formatDistance(0.5);   // "500 m"
String mesafe2 = Helpers.formatDistance(3.7);  // "3.7 km"
```

#### void — Değer Döndürmeyen Fonksiyonlar

Bir fonksiyon değer döndürmek zorunda değildir. Değer döndürmeyen fonksiyonların dönüş tipi `void` olur.

**Takaş'tan örnek — `login_screen.dart`:**

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

Bu fonksiyon:
- `void` — Hiçbir değer döndürmez
- `_onLogin` — Alt çizgi (`_`) ile başlayan isimler Dart'ta **private** (özel) anlamına gelir. Bu fonksiyon sadece bu dosya içinde çağrılabilir.
- `async` — Asenkron bir fonksiyon (ileride detaylı anlatılacak)

#### Arrow Functions (Ok Fonksiyonları) — Kısa Fonksiyonlar

Eğer fonksiyonunuz tek bir ifade (expression) içeriyorsa, `=>` (ok) operatörü ile daha kısa yazabilirsiniz.

```dart
// Normal fonksiyon:
int kareAl(int sayi) {
  return sayi * sayi;
}

// Arrow (ok) fonksiyonu — aynı şey:
int kareAl(int sayi) => sayi * sayi;
```

**Takaş'tan örnek — `login_screen.dart`:**

```dart
onPressed: () => _showResetPasswordDialog(),
```

Bu, `() { return _showResetPasswordDialog(); }` yazmakla aynı şeydir.

**Takaş'tan örnek — `login_screen.dart`:**

```dart
onPressed: () => Navigator.pop(context),
```

#### Named Parameters (İsimlendirilmiş Parametreler)

Dart'ta fonksiyon parametrelerini `{}` süslü parantez içinde tanımlayarak, çağırırken parametre adını kullanarak verebilirsiniz. Bu, kodun okunabilirliğini artırır.

```dart
void kullaniciOlustur({required String ad, required int yas, String sehir = 'İstanbul'}) {
  print('Ad: $ad, Yaş: $yas, Şehir: $sehir');
}

// Çağırma:
kullaniciOlustur(ad: 'Ali', yas: 25);              // sehir varsayılan: 'İstanbul'
kullaniciOlustur(ad: 'Ayşe', yas: 30, sehir: 'Ankara');
```

**Takaş'tan örnek — `listing_model.dart` copyWith:**

```dart
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
    // ...
  );
}
```

Bu fonksiyonun tüm parametreleri **opsiyoneldir** (null olabilir, `required` yok). Sadece değiştirmek istediğiniz alanları verirsiniz:

```dart
final guncelIlan = ilan.copyWith(title: 'Yeni Başlık', status: ListingStatus.reserved);
// Sadece title ve status değişti, diğer alanlar aynı kaldı
```

Bu **copyWith** deseni (pattern), Flutter ve Dart'ta immutable (değiştirilemez) objeleri güncellemek için çok yaygın kullanılır. Orijinal objeyi değiştirmek yerine, bazı alanları değiştirilmiş yeni bir kopya oluşturur.

#### factory Constructor (Fabrika Yapıcı)

`factory` anahtar kelimesi, normal bir constructor yerine özel bir yapılandırma işlemi yapan constructor tanımlamanızı sağlar. En yaygın kullanımı, bir Map'ten (JSON'dan) obje oluşturmaktır.

**Takaş'tan örnek — `user_model.dart`:**

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

Bu bir `factory` constructor'dır. Normal constructor'lar (`UserModel(...)`) her zaman yeni bir obje oluşturur. `factory` constructor ise bir hesaplama sonucu obje döndürebilir. Burada JSON verisinden bir `UserModel` oluşturup döndürüyor.

**Kullanımı:**
```dart
final Map<String, dynamic> jsonVerisi = firestoreDoc.data();
final kullanici = UserModel.fromJson(jsonVerisi);
```

---

### 2.5 Sınıflar (class, constructor, extends, mixins)

#### class — Sınıf (Tasarım Şablonu) Nedir?

Sınıf (class), bir nesnenin **tasarım şablonudur** (blueprint). Bir sınıf, nesnenin hangi verilere (özelliklere/fields) ve hangi davranışlara (metotlara/methods) sahip olacağını tanımlar.

Gerçek hayattan benzetme: "Araba" bir sınıftır. Her arabanın:
- Özellikleri (fields): renk, marka, hız
- Davranışları (methods): gazla, fren yap, dön

**Takaş'tan örnek — `user_model.dart`:**

```dart
class UserModel {
  // ── Özellikler (Fields / Properties) ──
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final String? bio;
  final double rating;
  final int ratingCount;
  final DateTime createdAt;
  final int totalImageCount;

  // ── Constructor (Yapıcı Metot) ──
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

  // ── Metotlar (Methods) ──
  Map<String, dynamic> toJson() { /* ... */ }
  factory UserModel.fromJson(Map<String, dynamic> json) { /* ... */ }
  UserModel copyWith({/* ... */}) { /* ... */ }
}
```

Bu sınıfın parçaları:
1. **Fields (Özellikler):** `uid`, `displayName`, `email` vb. — Bu sınıfın her örneği bu verileri taşır.
2. **Constructor:** `UserModel({...})` — Yeni bir `UserModel` oluştururken hangi verilerin verilmesi gerektiğini belirler.
3. **Methods (Metotlar):** `toJson()`, `fromJson()`, `copyWith()` — Bu sınıfın yapabileceği işlemler.

**this Anahtar Kelimesi:**

`this`, sınıfın mevcut örneğine (instance) referans verir.

```dart
UserModel({
  required this.uid,  // "parametre olan uid'yi sınıfın uid alanına ata"
});
```

`this.uid` soldaki `uid`, sınıfın alanıdır. Sağdaki (parametre adı) de `uid`'dir. Dart `this.uid` yazdığınızda parametrenin aynı isimli sınıf alanına atanacağını bilir.

#### Constructor (Yapıcı Metot) Türleri

**1. Named Constructor (İsimlendirilmiş Constructor):**

```dart
// Varsayılan constructor
UserModel({required this.uid, ...});

// İsimlendirilmiş constructor — farklı bir şekilde obje oluşturma
UserModel.anonim() {
  uid = '';
  displayName = 'Anonim';
  // ...
}
```

**2. Factory Constructor:**

Yukarıda `fromJson` örneğinde gördük. Bir Map'ten obje oluşturur.

**3. const Constructor:**

```dart
const ListingCard({
  super.key,
  required this.listing,
  required this.onTap,
});
```

`const` constructor, derleme zamanında sabit objeler oluşturmanızı sağlar. Flutter'da performans için çok önemlidir.

#### extends — Kalıtım (Inheritance)

`extends` anahtar kelimesi, bir sınıfın başka bir sınıfın özelliklerini ve metotlarını **miras almasını** sağlar.

**Takaş'tan örnek — `main.dart`:**

```dart
class TakashApp extends ConsumerStatefulWidget {
  const TakashApp({super.key});

  @override
  ConsumerState<TakashApp> createState() => _TakashAppState();
}

class _TakashAppState extends ConsumerState<TakashApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(/* ... */);
  }
}
```

Burada:
- `_TakashAppState` sınıfı, `ConsumerState<TakashApp>` sınıfını **genişletir** (extends).
- Bu, `_TakashAppState`'in `ConsumerState`'in tüm özelliklerini ve metotlarını miras aldığı anlamına gelir.
- `@override` annotasyonu, miras alınan bir metodu **geçersiz kıldığımızı** (yeniden tanımladığımızı) belirtir.

**Takaş'tan örnek — `listing_card.dart`:**

```dart
class ListingCard extends ConsumerWidget {
  // ...
}
```

`ListingCard`, `ConsumerWidget`'ı miras alır. `ConsumerWidget` ise Riverpod kütüphanesinden gelen, `ref` (reference) ile state yönetimi yapabilen özel bir `StatelessWidget`'tır.

#### implements — Uygulama (Interface)

`implements` anahtar kelimesi, bir sınıfın belirli bir **arayüzü (interface)** uygulamasını zorunlu kılar. Interface, "şu metotlara sahip olmalısın" diyen bir sözleşmedir.

```dart
abstract class Hayvan {
  void sesCikar();  // Abstract metod — gövdesi yok
}

class Kedi implements Hayvan {
  @override
  void sesCikar() {
    print('Miyav!');
  }
}
```

Takaş projesinde doğrudan `implements` kullanımı azdır, ancak Flutter'ın kendi içinde sıkça kullanılır. Örneğin bir `State` sınıfı, aslında `StatefulWidget` ile ilişkili olan ve `build()` metodunu `implement` eden bir yapıdır.

#### Mixins — Karışım (Tekrar Kullanılabilir Kod Blokları)

Mixin, bir sınıfa **ek özellikler eklemek** için kullanılan, başlı başına instantiate edilemeyen (örneği oluşturulamayan) kod bloklarıdır. `with` anahtar kelimesi ile kullanılır.

```dart
mixin Loglayici {
  void log(String mesaj) {
    print('[LOG] $mesaj');
  }
}

class VeriServisi with Loglayici {
  void veriGetir() {
    log('Veri getiriliyor...');  // Mixin'den gelen metod
  }
}
```

Takaş projesinde Riverpod'un `ConsumerWidget` ve `ConsumerState` sınıfları mixin benzeri bir yaklaşımla `ref` erişimi sağlar.

---

### 2.6 Async/Await (Future, Stream, async, await)

#### Senkron vs Asenkron Çalışma

**Senkron (Eşzamanlı) Çalışma:** Kod satır satır, sırayla çalışır. Her satır bir önceki bitmeden başlamaz.

```dart
String veri = veritabanindanOku();  // Bu satır 5 saniye bekler
print(veri);                        // 5 saniye SONRA çalışır
```

Sorun: Eğer veritabanı okuması 5 saniye sürerse, uygulama bu 5 saniye boyunca **donar** (freeze). Kullanıcı hiçbir şey yapamaz.

**Asenkron (Eşzamanlı Olmayan) Çalışma:** Uzun süren işlemler (ağ isteği, dosya okuma vb.) arka planda yapılır. Uygulama donmaz, kullanıcı başka işlemler yapabilir.

```dart
// Asenkron yaklaşım:
String veri = await veritabanindanOku();  // Arka planda bekler
print(veri);  // Veri hazır olduğunda çalışır
```

#### Future — Gelecekte Tamamlanacak İşlem

`Future<T>`, gelecekte bir `T` değeri üretecek olan bir işlemi temsil eder. Bir nevi "söz vermedir" — "İleride bir değer döndüreceğim" der.

```dart
Future<String> isimGetir() {
  return Future.delayed(Duration(seconds: 2), () => 'Takaş');
}
```

Bu fonksiyon, 2 saniye sonra 'Takaş' String'ini döndürecektir. Ama şu anda henüz hazır değildir — bir `Future<String>`'dir.

#### async ve await — Asenkron Kodu Senkron Gibi Yazmak

`async` bir fonksiyonun asenkron olduğunu belirtir. `await` ise bir `Future`'ın tamamlanmasını bekler.

```dart
Future<void> isimYazdir() async {            // async — bu fonksiyon asenkron
  String isim = await isimGetir();           // await — Future'ı bekle
  print(isim);                               // 2 saniye sonra: "Takaş"
}
```

**Takaş'tan örnek — `main.dart`:**

```dart
void main() async {  // async — bu fonksiyon asenkron işlemler içeriyor
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");          // .env dosyasını YÜKLE ve BEKLE

  String mapboxToken = dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
  MapboxOptions.setAccessToken(mapboxToken);

  await Firebase.initializeApp(                  // Firebase'i BAŞLAT ve BEKLE
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeDateFormatting('tr_TR', null); // Tarih formatını AYARLA ve BEKLE

  // ... tüm asenkron işlemler bittikten sonra uygulamayı başlat
  runApp(
    const ProviderScope(
      child: TakashApp(),
    ),
  );
}
```

Burada sıra çok önemlidir:
1. Önce `dotenv.load` tamamlanır (çevre değişkenleri yüklenir)
2. Sonra `Firebase.initializeApp` tamamlanır (Firebase hazır hale gelir)
3. Sonra `initializeDateFormatting` tamamlanır (tarih formatı hazır olur)
4. En son `runApp` çağrılır (uygulama başlar)

Her `await`, bir önceki işlemin tamamlanmasını bekler. Bu, "Firebase başlamadan uygulamayı başlatmak" gibi sorunları önler.

**Takaş'tan örnek — `login_screen.dart`:**

```dart
void _onLogin() async {
  if (_formKey.currentState!.validate()) {
    await ref.read(authControllerProvider.notifier).signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
    // signInWithEmail tamamlanana kadar buraya geçmez

    if (mounted && ref.read(authControllerProvider).hasError) {
      // Giriş başarısız olduysa hata göster
      final error = ref.read(authControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Giriş hatası: ${error.toString()}')),
      );
    }
  }
}
```

#### Stream — Sürekli Veri Akışı

`Stream`, `Future`'ın aksine tek bir değer değil, **sürekli akan bir değer dizisi** sağlar. Örneğin:
- Kullanıcının konumu sürekli değişir → bir Stream'dir
- Sohbet mesajları sürekli gelir → bir Stream'dir
- FirebaseAuth'ın oturum durumu değişir → bir Stream'dir

**Takaş'tan örnek — `main.dart`:**

```dart
FirebaseAuth.instance.authStateChanges().listen((user) {
  ref.read(notificationServiceProvider).onUserChanged(user);
});
```

`authStateChanges()` bir `Stream<User?>` döndürür. Kullanıcı her giriş yaptığında veya çıkış yaptığında, bu stream yeni bir değer yayar ve `.listen()` içindeki fonksiyon çalışır.

`.listen()` metodu, Stream'e bir **dinleyici (listener)** ekler. Stream'den her yeni değer geldiğinde, verilen fonksiyon çalışır.

---

### 2.7 Generics (List\<T\>, Map\<K,V\>)

Generic (jenerik), bir sınıfın veya fonksiyonun **farklı veri tipleriyle çalışabilmesini** sağlayan bir özelliktir. `<T>` içindeki `T` bir **tip parametresidir** — herhangi bir tip olabilir.

Neden Generic'e ihtiyacımız var?

```dart
// Generic OLMADAN — her tip için ayrı liste sınıfı gerekirdi:
StringList, IntList, DoubleList...

// Generic ILE — tek bir List sınıfı, her tipte çalışır:
List<String>  // String listesi
List<int>     // int listesi
List<UserModel>  // UserModel listesi
```

**Takaş'tan örnekler:**

```dart
// List<String> — String tipinde liste
final List<String> imageUrls;           // listing_model.dart
imageUrls: List<String>.from(json['imageUrls'] ?? []),

// Map<String, dynamic> — String anahtarlı, herhangi tipte değerli Map
Map<String, dynamic> toJson() { ... }   // listing_model.dart, user_model.dart
factory ListingModel.fromJson(Map<String, dynamic> json) { ... }

// Future<bool> — gelecekte bir bool döndürecek işlem
// Provider tipinde generics
ref.watch(isFavoriteProvider(listing.id)).value ?? false;
```

**Takaş'tan örnek — `listing_model.dart`:**

```dart
imageUrls: List<String>.from(json['imageUrls'] ?? []),
```

`List<String>.from()` — bu bir generic constructor'dır. `String` tip parametresi, listenin sadece String elemanlar içereceğini belirtir. `.from()` ise mevcut bir iterable'dan (dönüşlenebilir veriden) liste oluşturur.

Eğer generic olmasaydı:
```dart
// Tehlikeli — tip güvenliği yok:
List hamListe = json['imageUrls'];  // Ne tip elemanlar var? Bilinmiyor!
String ilkUrl = hamListe[0];        // Çalışmayabilir — belki eleman int'tir!

// Güvenli — generic ile:
List<String> guvenliListe = List<String>.from(json['imageUrls']);
String ilkUrl = guvenliListe[0];    // Kesinlikle String
```

---

### 2.8 Enum

**Enum (Enumeration — Numaralandırma)**, sabit bir değerler kümesi tanımlamak için kullanılır. Örneğin haftanın günleri, mevsimler, sıipariş durumları vb.

Enum, "bireysel string değerleri dağınık yazmak yerine, gruplandırılmış ve güvenli bir yapı kullanmak" için idealdir.

**Temel Enum:**

```dart
enum Meyve {
  elma,
  armut,
  muz,
  portakal,
}

Meyve simdiki = Meyve.elma;
```

Enum değerlarının her biri otomatik olarak bir `name` property'sine sahiptir:

```dart
Meyve.elma.name       // 'elma'
Meyve.armut.name      // 'armut'
```

Ayrıca `values` ile tüm enum değerlerini bir liste olarak alabilirsiniz:

```dart
Meyve.values           // [Meyve.elma, Meyve.armut, Meyve.muz, Meyve.portakal]
Meyve.values[0]        // Meyve.elma
```

**Takaş'tan örnek — `listing_category.dart`:**

```dart
enum ListingCategory {
  electronics,
  clothing,
  books,
  furniture,
  sports,
  toys,
  other,
}
```

Bu enum, Takaş uygulamasında bir ilanın hangi kategoriye ait olabileceğini tanımlar. Bu sayede:

1. **Tip güvenliği:** Bir fonksiyon sadece `ListingCategory` tipinde değer kabul ederse, yanlışlıkla 'elektronik' (string) yazamazsınız — derleme hatası alırsınız.
2. **Tüm seçenekler bir arada:** Yeni bir kategori eklemek isterseniz, sadece enum'a bir satır eklersiniz.
3. **Kolay eşleştirme:** `switch` veya `firstWhere` ile kolayca arama yapılabilir.

**Takaş'tan kullanım — `listing_model.dart` içinde fromJson:**

```dart
category: ListingCategory.values.firstWhere(
  (e) => e.name == json['category'],
  orElse: () => ListingCategory.other,
),
```

Bu satır ne yapar?
1. `ListingCategory.values` — tüm kategorileri listeler: `[electronics, clothing, books, ...]`
2. `.firstWhere((e) => e.name == json['category'])` — JSON'dan gelen kategori adıyla eşleşen İLK enum değerini bulur. Örneğin JSON'da `'electronics'` varsa, `ListingCategory.electronics` döner.
3. `orElse: () => ListingCategory.other` — Eğer eşleşen bir şey bulunamazsa varsayılan olarak `other` (diğer) kullanılır.

**Takaş'tan ikinci enum örneği — `listing_category.dart`:**

```dart
enum ListingStatus {
  active,      // Aktif — takasa açık
  reserved,    // Rezerve — birisi talep etmiş
  completed,   // Tamamlandı — takas gerçekleşti
}
```

Bu enum bir ilanın yaşam döngüsünü temsil eder. Her ilan bu üç durumdan birinde bulunur.

---

### 2.9 Extensions (Genişletmeler)

Extension (genişletme), **var olan bir sınıfa yeni metotlar veya özellikler eklemenizi** sağlar — orijinal sınıf kodunu değiştirmeden!

Bu çok güçlü bir özelliktir. Örneğin Dart'ın `String` sınıfına yeni bir metod ekleyebilirsiniz:

```dart
extension StringExtensions on String {
  bool get gecerliEmail {
    return contains('@') && contains('.');
  }
}

// Artık her String'de bu metod kullanılabilir:
'ahmet@gmail.com'.gecerliEmail    // true
'merhaba'.gecerliEmail             // false
```

**Takaş'tan örnek — `listing_category.dart`:**

```dart
extension ListingCategoryExtension on ListingCategory {
  String get label {
    switch (this) {
      case ListingCategory.electronics:
        return 'Elektronik';
      case ListingCategory.clothing:
        return 'Giyim';
      case ListingCategory.books:
        return 'Kitap';
      case ListingCategory.furniture:
        return 'Mobilya';
      case ListingCategory.sports:
        return 'Spor';
      case ListingCategory.toys:
        return 'Oyuncak';
      case ListingCategory.other:
        return 'Diğer';
    }
  }

  String get icon {
    switch (this) {
      case ListingCategory.electronics:
        return '📱';
      case ListingCategory.clothing:
        return '👕';
      case ListingCategory.books:
        return '📚';
      case ListingCategory.furniture:
        return '🪑';
      case ListingCategory.sports:
        return '⚽';
      case ListingCategory.toys:
        return '🧸';
      case ListingCategory.other:
        return '📦';
    }
  }
}
```

Bu extension ne yapar?
- `ListingCategoryExtension on ListingCategory` — `ListingCategory` enum'ına yeni yetenekler ekler.
- `String get label` — Her kategori için Türkçe bir isim (etiket) döndüren bir **getter** (salt-okunur property) ekler.
- `String get icon` — Her kategori için bir emoji ikon döndüren bir getter ekler.

**Kullanımı — `listing_card.dart`:**

```dart
Text(
  listing.category.label,  // listing.category bir ListingCategory enum'dır
                            // .label extension'dan gelen property'dir
                            // Örneğin ListingCategory.electronics → 'Elektronik'
  style: const TextStyle(
    color: Colors.white,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
  ),
),
```

Extension kullanmasaydık, kategori Türkçe adını almak için her seferinde bir fonksiyon çağırmamız gerekirdi:

```dart
// Extension OLMADAN:
String kategoriAdi(ListingCategory kategori) {
  switch (kategori) {
    case ListingCategory.electronics: return 'Elektronik';
    // ...
  }
}
Text(kategoriAdi(listing.category));

// Extension ILE (daha temiz):
Text(listing.category.label);
```

**Takaş'tan ikinci extension örneği — `listing_category.dart`:**

```dart
extension ListingStatusExtension on ListingStatus {
  String get label {
    switch (this) {
      case ListingStatus.active:
        return 'Aktif';
      case ListingStatus.reserved:
        return 'Rezerve';
      case ListingStatus.completed:
        return 'Tamamlandı';
    }
  }
}
```

Aynı mantık: `ListingStatus` enum'ına Türkçe etiketler ekler. `ListingStatus.active.label` → `'Aktif'`.

---

## 3. Widget Sistemi

### 3.1 Widget Nedir? (StatelessWidget vs StatefulWidget)

Flutter'da **her şey bir widget'tır**. Ekranda gördüğünüz her şey — düğmeler, metinler, resimler, boşluklar, hatta sayfanın kendisi — birer widget'tır. Widget'lar, Flutter'ın inşa bloklarıdır (Lego parçaları gibi).

Flutter'da iki temel widget türü vardır:

#### StatelessWidget — Durumsuz (Değişmeyen) Widget

`StatelessWidget`, oluşturulduktan sonra **asla değişmeyen** widget'tır. Görünümü, ona verilen parametrelere bağlıdır ve parametreler değişmediği sürece ekrandaki görüntü değişmez.

**Gerçek hayattan benzetme:** Bir tabeladaki yazı. Tabela bir kere boyandıktan sonra yazı değişmez. Yeni bir tabela yapılması gerekir.

**Takaş'tan örnek — `listing_card.dart`:**

```dart
class ListingCard extends ConsumerWidget {  // ConsumerWidget, StatelessWidget'ın özel bir türevidir
  final ListingModel listing;
  final VoidCallback onTap;

  const ListingCard({
    super.key,
    required this.listing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ... görüntüyü oluştur ve döndür
    return Container(/* ... */);
  }
}
```

Bu widget stateless'tır çünkü:
- `listing` ve `onTap` parametreleri dışarıdan verilir
- Widget'ın kendi içinde değişen hiçbir durumu (state) yoktur
- Parametreler değişmediği sürece görüntüsü değişmez

**Takaş'tan başka bir StatelessWidget örneği — `router.dart`:**

```dart
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final String? badge;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    // ...
  }
}
```

Bu da stateless'tur çünkü `icon`, `label`, `isActive` gibi tüm değerler dışarıdan sağlanır ve widget'ın kendisi hiçbir değişiklik yapmaz.

#### StatefulWidget — Durumlu (Değişebilen) Widget

`StatefulWidget`, zamanla **görünümü değişebilen** widget'tır. Kullanıcı etkileşimi, ağ cevabı, zamanlayıcı gibi etkenlere bağlı olarak görüntüsü güncellenebilir.

**Gerçek hayattan benzetme:** Bir dijital saat. Her saniye görüntüsü değişir (güncellenir).

StatefulWidget **iki parçadan** oluşur:
1. Widget'ın kendisi (immutable — değiştirilemez)
2. State objesi (mutable — değiştirilebilir)

**Takaş'tan örnek — `login_screen.dart`:**

```dart
// 1. Widget kısmı (immutable)
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

// 2. State kısmı (mutable — değişebilen)
class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() async { /* ... */ }

  @override
  Widget build(BuildContext context) {
    // ...
  }
}
```

**Neden LoginScreen StatefulWidget?**
- Kullanıcı email yazarken, ekrandaki yazı değişir (TextFormField güncellenir)
- Giriş butonuna basıldığında yükleme göstergesi (CircularProgressIndicator) görünür
- Hata mesajları ekrana gelir (SnackBar)
- Tüm bunlar State'in içinde yönetilir

`_LoginScreenState` içindeki `_emailController` ve `_passwordController` değişkenleri, widget'ın durumunu (state) oluşturur. Bu değişkenler zamanla değişir.

**Takaş'tan başka bir StatefulWidget örneği — `main.dart`:**

```dart
class TakashApp extends ConsumerStatefulWidget {
  const TakashApp({super.key});

  @override
  ConsumerState<TakashApp> createState() => _TakashAppState();
}

class _TakashAppState extends ConsumerState<TakashApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationServiceProvider).initialize();
    });

    FirebaseAuth.instance.authStateChanges().listen((user) {
      ref.read(notificationServiceProvider).onUserChanged(user);
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Takaş',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ref.watch(themeModeProvider),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
```

> **Not:** `ConsumerStatefulWidget` ve `ConsumerWidget` Riverpod kütüphanesinin sağladığı özel sınıflardır. Normal `StatefulWidget` ve `StatelessWidget`'ın tüm özelliklerine sahiptir, ek olarak `ref` (reference) ile state yönetimi yapabilir.

---

### 3.2 build() Metodu

`build()` metodu, bir widget'ın **nasıl görüneceğini** tanımlayan en önemli metottur. Flutter, bu metodu çağırarak ekrana çizilecek widget ağacını (widget tree) elde eder.

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(/* ... */);
}
```

- `@override` — Bu annotation (ek açıklama), üst sınıftaki `build` metodunu geçersiz kıldığımızı (override) belirtir.
- `Widget` dönüş tipi — Bu metod bir `Widget` döndürmek ZORUNDADIR. Ekranda gösterilecek şey budur.
- `BuildContext context` — Bu widget'ın widget ağacındaki konumu hakkında bilgi verir (ileride detaylı anlatılacak).

**build() metodu ne zaman çağrılır?**

1. Widget ekrana ilk eklendiğinde
2. Parent (üst) widget yeniden build edildiğinde
3. `setState()` çağrıldığında (sadece StatefulWidget için)
4. `ref.watch()` ile izlenen bir değer değiştiğinde (Riverpod için)

**Takaş'tan detaylı build() örneği — `login_screen.dart`:**

```dart
@override
Widget build(BuildContext context) {
  final authState = ref.watch(authControllerProvider);  // auth durumunu izle
  final colorScheme = Theme.of(context).colorScheme;    // renk şemasını al

  return Scaffold(                                       // Sayfa iskeleti
    body: SafeArea(                                      // Güvenli alan
      child: SingleChildScrollView(                      // Kaydırılabilir alan
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Form(                                     // Form
          key: _formKey,
          child: Column(                                 // Dikey düzen
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo ve başlık
              const SizedBox(height: 60),
              Center(/* ... */),
              // Email alanı
              TextFormField(/* ... */),
              // Şifre alanı
              TextFormField(/* ... */),
              // Butonlar
              FilledButton(/* ... */),
              OutlinedButton.icon(/* ... */),
            ],
          ),
        ),
      ),
    ),
  );
}
```

Bu build metodu her çağrıldığında:
1. `ref.watch(authControllerProvider)` ile giriş durumu okunur
2. Duruma göre arayüz güncellenir (örneğin yükleniyorsa buton devre dışı kalır)

---

### 3.3 Widget Ağacı Kavramı

Flutter'da widget'lar **iç içe** geçerek bir ağaç (tree) yapısı oluşturur. Her widget başka widget'ları içerebilir. Bu yapıya **Widget Tree** (Widget Ağacı) denir.

**Takaş Login ekranının widget ağacı (basitleştirilmiş):**

```
LoginScreen (StatefulWidget)
└── Scaffold
    └── SafeArea
        └── SingleChildScrollView
            └── Form
                └── Column
                    ├── SizedBox(height: 60)
                    ├── Center
                    │   └── Column
                    │       ├── Container (logo)
                    │       │   └── Icon
                    │       ├── SizedBox(height: 16)
                    │       ├── Text ('Takaş')
                    │       ├── SizedBox(height: 4)
                    │       └── Text ('Yakınındakilerle takas yap')
                    ├── SizedBox(height: 48)
                    ├── TextFormField (email)
                    ├── SizedBox(height: 14)
                    ├── TextFormField (şifre)
                    ├── SizedBox(height: 6)
                    ├── Align
                    │   └── TextButton ('Şifremi Unuttum')
                    ├── SizedBox(height: 16)
                    ├── SizedBox (height: 52)
                    │   └── FilledButton ('Giriş Yap')
                    ├── SizedBox(height: 20)
                    ├── Row (ayırıcı)
                    │   ├── Expanded > Divider
                    │   ├── Padding > Text ('veya')
                    │   └── Expanded > Divider
                    ├── SizedBox(height: 20)
                    ├── SizedBox (height: 52)
                    │   └── OutlinedButton.icon ('Google ile Devam Et')
                    ├── SizedBox(height: 28)
                    └── Row (hesap yok mu?)
                        ├── Text
                        └── TextButton ('Kayıt Ol')
```

Bu ağacın anlamı:
- `Scaffold` sayfanın temel yapısıdır
- `SafeArea` içeriği çentik/bar区域dan korur
- `SingleChildScrollView` ekran küçükse kaydırma sağlar
- `Form` tüm form alanlarını gruplandırır ve doğrulama (validation) yapar
- `Column` tüm elemanları dikey olarak dizer
- Her `SizedBox` elemanlar arasında boşluk bırakır
- `TextFormField`, `FilledButton` vb. Material Design bileşenleridir

**Widget ağacının önemi:**
- Flutter, bu ağacı traverse ederek (dolaşarak) her widget'ı ekrana çizer
- Bir widget değiştiğinde, sadece o widget ve alt widget'ları güncellenir
- `BuildContext`, bir widget'ın bu ağaçtaki konumunu temsil eder

---

### 3.4 setState() Ne Yapar?

`setState()`, yalnızca **StatefulWidget**'larda kullanılan, widget'ın durumunu (state) güncelleyip ekranı yeniden çizmesini (rebuild) tetikleyen bir metottur.

**Çalışma mantığı:**

```dart
setState(() {
  // Bu bloğun İÇİNDE state değişkenlerini güncelleyin
  sayac = sayac + 1;
});
// setState çağrıldıktan sonra Flutter build() metodunu yeniden çağırır
// ve ekrandaki görüntüyü günceller
```

**Basit örnek:**

```dart
class SayacSayfasi extends StatefulWidget {
  @override
  State<SayacSayfasi> createState() => _SayacSayfasiState();
}

class _SayacSayfasiState extends State<SayacSayfasi> {
  int sayac = 0;  // ← Bu bir STATE değişkeni

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Sayaç: $sayac'),
        ElevatedButton(
          onPressed: () {
            setState(() {
              sayac++;  // State'i güncelle
            });
            // Artık build() yeniden çağrılır, Text widget'ı yeni değeri gösterir
          },
          child: Text('Artır'),
        ),
      ],
    );
  }
}
```

**Takaş projesinde setState() kullanımı:**

Takaş projesinde doğrudan `setState()` yerine **Riverpod** state yönetim kütüphanesi kullanılır. Riverpod, `setState()`'in daha gelişmiş ve ölçeklenebilir bir alternatifidir. Ancak temel mantık aynıdır:

```dart
// setState() yaklaşımı (temel Flutter):
setState(() {
  _isLoading = true;
});

// Riverpod yaklaşımı (Takaş'ta kullanılan):
// State bir Provider'da tutulur ve ref ile güncellenir
ref.read(authControllerProvider.notifier).signInWithEmail(email, password);
// Bu, state'i günceller ve izleyen widget'ları rebuild eder
```

Riverpod'un avantajı: State'i widget dışında, merkezi bir yerde tutar. Bu, farklı ekranların aynı state'i paylaşmasını kolaylaştırır.

---

### 3.5 Context Nedir?

`BuildContext`, bir widget'ın **widget ağacındaki konumunu** temsil eden bir objedir. Her widget'ın bir context'i vardır ve bu context aracılığıyla:

1. **Theme'e (temaya) erişim:** `Theme.of(context)`
2. **Navigator'a (sayfa geçişlerine) erişim:** `Navigator.of(context)` veya `context.push()`
3. **ScaffoldMessenger'a (mesaj göstermeye) erişim:** `ScaffoldMessenger.of(context)`
4. **Medya bilgilerine (ekran boyutu vb.) erişim:** `MediaQuery.of(context)`

**Gerçek hayattan benzetme:** Context, birevin adresi gibidir. Evin nerede olduğunu bilirseniz, o eve ait hizmetlere (su, elektrik) erişebilirsiniz.

**Takaş'tan örnekler:**

```dart
// 1. Theme'e erişim — login_screen.dart
final colorScheme = Theme.of(context).colorScheme;
// colorScheme.primary → ana renk
// colorScheme.onSurface → yüzey üzerindeki metin rengi
// colorScheme.outline → çerçeve/yardımcı renk
```

```dart
// 2. ScaffoldMessenger'a erişim — login_screen.dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Giriş hatası: ${error.toString()}')),
);
// context üzerinden mevcut Scaffold'un mesaj göstericisine erişilir
```

```dart
// 3. Sayfa geçişi — login_screen.dart
context.push('/register');
// GoRouter kütüphanesi context üzerinden sayfa geçişi yapar
```

```dart
// 4. Theme'e erişim — listing_card.dart
final colorScheme = Theme.of(context).colorScheme;
// Bu widget da tema bilgilerini context'ten alır
```

**Context'in widget ağacındaki rolü:**

```
MaterialApp  ←── Theme burada tanımlı
└── LoginScreen  ←── context: LoginScreen'in konumu
    └── Scaffold
        └── ...
            └── Text  ←── context: Text'in konumu
                Theme.of(context) → ↑↑↑ yukarı doğru arar,
                                    ilk bulduğu MaterialApp'in temasını döndürür
```

`Theme.of(context)` çağrıldığında, Flutter context'ten yukarı doğru (widget ağacında) ilerler ve ilk bulduğu `Theme` bilgisini döndürür. Bu, "widget ağacında konum bilgisi" anlamına gelir.

---

### 3.6 Key Kavramı (ValueKey, GlobalKey)

#### Key Nedir ve Neden Gerekli?

Key, Flutter'ın bir widget'ı widget ağacında **benzersiz olarak tanımlamasını** sağlayan bir değerdir. Flutter, widget ağacını güncellerken hangi widget'ın değiştiğini, eklendiğini veya çıkarıldığını belirlemek için Key kullanır.

Gerçek hayattan benzetme: Bir sınıftaki öğrenciler. Flutter, öğrencileri (widget'ları) isimlerine (Key) göre tanır. İsim yoksa, sıralarına (pozisyonlarına) göre tanır.

#### Varsayılan Davranış (Key olmadan)

Key verilmediğinde, Flutter widget'ları **tip ve pozisyonlarına** göre eşleştirir. Bu çoğu durumda çalışır ama bazen sorun çıkarır.

```dart
Column(
  children: [
    TextWidget('Ali'),    // Pozisyon 0
    TextWidget('Ayşe'),   // Pozisyon 1
  ],
)
```

Eğer `Ali` çıkarılırsa ve sadece `Ayşe` kalırsa:
- Flutter pozisyon 0'daki widget'ı `Ayşe` ile eşleştirir (tip + pozisyon aynı)
- `Ayşe` widget'ının State'i korunur ama aslında `Ali`'nin State'i olmalıydı
- Bu durum hatalara yol açabilir

#### ValueKey

`ValueKey`, bir widget'a **benzersiz bir değer** atayarak onu tanımlanabilir kılar.

```dart
ListView(
  children: [
    ListTile(key: ValueKey('ilan_1'), title: Text('İlan 1')),
    ListTile(key: ValueKey('ilan_2'), title: Text('İlan 2')),
    ListTile(key: ValueKey('ilan_3'), title: Text('İlan 3')),
  ],
)
```

Artık Flutter bu widget'ları pozisyon yerine ValueKey'lerine göre tanır.

#### GlobalKey

`GlobalKey`, bir widget'a **global (tüm uygulama genelinde) benzersiz** bir kimlik verir. GlobalKey ile:
- Widget'ın State'ine dışarıdan erişebilirsiniz
- Form doğrulaması yapabilirsiniz

**Takaş'tan örnek — `login_screen.dart`:**

```dart
final _formKey = GlobalKey<FormState>();
```

```dart
Form(
  key: _formKey,  // Form widget'ına global bir key ata
  child: Column(
    children: [
      TextFormField(/* ... */),
      TextFormField(/* ... */),
    ],
  ),
),
```

```dart
void _onLogin() async {
  if (_formKey.currentState!.validate()) {  // Formu doğrula
    // Tüm alanlar geçerli — giriş yap
  }
}
```

Bu örnekte `_formKey` bir `GlobalKey<FormState>`'dir. Bu key sayesinde:
1. `_formKey.currentState` → Form'un mevcut State'ine erişim
2. `.validate()` → Tüm TextFormField'ların `validator` fonksiyonlarını çalıştır
3. Hepsi `null` döndürürse (hata yoksa) `true` döner, aksi halde `false`

**TextFormField'ın validator'ları — `login_screen.dart`:**

```dart
TextFormField(
  controller: _emailController,
  validator: (value) {
    if (value == null || value.isEmpty || !value.contains('@')) {
      return 'Geçerli bir e-posta girin';  // Hata mesajı — doğrulama başarısız
    }
    return null;  // null = doğrulama başarılı
  },
),

TextFormField(
  controller: _passwordController,
  obscureText: true,
  validator: (value) {
    if (value == null || value.length < 6) {
      return 'Şifre en az 6 karakter olmalıdır';
    }
    return null;
  },
),
```

`_formKey.currentState!.validate()` çağrıldığında, bu iki validator sırayla çalışır. Herhangi biri hata mesajı döndürürse, form geçersizdir ve `_onLogin` fonksiyonunun geri kalanı çalışmaz.

---

## 4. Material Design Bileşenleri

**Material Design**, Google tarafından oluşturulmuş bir tasarım sistemidir. Düğmeler, kartlar, diyaloglar, uygulama çubukları gibi UI bileşenleri için tutarlı kurallar ve görünüm standartları belirler.

Flutter, Material Design bileşenlerini yerleşik olarak sunar. Bu bölümde Takaş projesinde kullanılan Material bileşenlerini inceleyeceğiz.

### Scaffold — Sayfa İskeleti

`Scaffold`, bir Material Design sayfasının temel yapısını sağlar. AppBar, body (ana içerik), FloatingActionButton, BottomNavigationBar gibi alanları barındırır.

**Takaş'tan örnek — `login_screen.dart`:**

```dart
return Scaffold(
  body: SafeArea(         // body — sayfanın ana içeriği
    child: SingleChildScrollView(
      // ...
    ),
  ),
);
```

**Takaş'tan örnek — `router.dart` (MainScreen):**

```dart
return Scaffold(
  body: navigationShell,              // Ana içerik: sayfa içeriği
  extendBody: true,                   // Body'yi bottom bar arkasına uzat
  bottomNavigationBar: Container(     // Alt navigasyon çubuğu
    decoration: BoxDecoration(/* ... */),
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(/* ... nav items ... */),
      ),
    ),
  ),
);
```

Scaffold'un özellikleri:
- `body` — Sayfanın ana içeriği
- `appBar` — Üst çubuk (LoginScreen'de yok, başka ekranlarda var)
- `bottomNavigationBar` — Alt navigasyon çubuğu
- `floatingActionButton` — Yuvarlak işlem düğmesi
- `extendBody` — Body'nin bottom bar arkasına uzanıp uzanmayacağı

### AppBar — Uygulama Üst Çubuğu

`AppBar`, sayfanın üst kısmında yer alan, başlık, geri butonu ve eylem düğmelerini içeren çubuktur.

**Takaş'tan tema tanımı — `theme.dart`:**

```dart
appBarTheme: AppBarTheme(
  centerTitle: false,              // Başlık sola yaslı
  elevation: 0,                    // Gölge yok
  scrolledUnderElevation: 0.5,     // Kaydırıldığında hafif gölge
  backgroundColor: Colors.white,   // Beyaz arka plan
  surfaceTintColor: Colors.transparent,
  titleTextStyle: GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: textPrimary,
  ),
  iconTheme: const IconThemeData(color: textPrimary, size: 24),
),
```

Bu, tüm `AppBar`'ların varsayılan görünümünü tanımlar. Her sayfada ayrı ayrı stil belirtmeye gerek kalmaz.

### ElevatedButton / FilledButton — Düğmeler

Flutter'da birkaç tür düğme vardır:

- **FilledButton:** Dolu arka planlı, vurgulanmış düğme
- **ElevatedButton:** Gölgeeli, hafif yükseltilmiş düğme
- **OutlinedButton:** Sadece çerçevesi olan düğme
- **TextButton:** Düz metin düğme (arka plan yok)

**Takaş'tan örnek — FilledButton (`login_screen.dart`):**

```dart
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

Bu düğmenin özellikleri:
- `height: 52` — SizedBox ile düğme yüksekliği 52 birim
- `onPressed` — Düğmeye basıldığında çalışan fonksiyon. `null` olursa düğme devre dışı kalır.
- `authState.isLoading ? null : _onLogin` — Yükleniyorsa devre dışı, değilse `_onLogin` çalıştır
- `child` — Düğmenin içeriği. Yükleniyorsa dönen çember (CircularProgressIndicator), değilse "Giriş Yap" metni

**Takaş'tan örnek — OutlinedButton.icon (`login_screen.dart`):**

```dart
SizedBox(
  height: 52,
  child: OutlinedButton.icon(
    onPressed: authState.isLoading ? null : _onGoogleLogin,
    icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
    label: const Text('Google ile Devam Et'),
  ),
),
```

`OutlinedButton.icon`, ikon + metin içeren özel bir outlined button oluşturur.

**Takaş'tan örnek — TextButton (`login_screen.dart`):**

```dart
TextButton(
  onPressed: () => context.push('/register'),
  child: const Text('Kayıt Ol'),
),
```

TextButton, arka plansız düz bir metin düğmesidir. Genellikle ikincil eylemler için kullanılır.

### TextFormField — Metin Giriş Alanı

`TextFormField`, kullanıcının metin girdiği alanlardır. Form doğrulama (validation) desteği ile gelir.

**Takaş'tan örnek — `login_screen.dart`:**

```dart
TextFormField(
  controller: _emailController,            // Girilen metne erişim için controller
  decoration: const InputDecoration(        // Görünüm özelleştirme
    labelText: 'E-posta',                  // Alan etiketi
    prefixIcon: Icon(Icons.email_outlined), // Sol taraftaki ikon
  ),
  keyboardType: TextInputType.emailAddress, // Email klavyesi (@ işareti olan)
  validator: (value) {                      // Doğrulama fonksiyonu
    if (value == null ||
        value.isEmpty ||
        !value.contains('@')) {
      return 'Geçerli bir e-posta girin';  // Hata mesajı
    }
    return null;                            // null = geçerli
  },
),
```

```dart
TextFormField(
  controller: _passwordController,
  decoration: const InputDecoration(
    labelText: 'Şifre',
    prefixIcon: Icon(Icons.lock_outline),
  ),
  obscureText: true,                        // Şifreyi gizle (••••••)
  validator: (value) {
    if (value == null || value.length < 6) {
      return 'Şifre en az 6 karakter olmalıdır';
    }
    return null;
  },
),
```

**TextEditingController:** TextFormField'deki metne programatik olarak erişmek ve metin değişikliklerini dinlemek için kullanılır.

```dart
final _emailController = TextEditingController();

// Kullanıcının girdiği metni al:
String email = _emailController.text;

// Metni temizle:
_emailController.clear();

// Widget yok edildiğinde controller'ı da temizle (bellek sızıntısını önler):
@override
void dispose() {
  _emailController.dispose();
  super.dispose();
}
```

### SnackBar — Kısa Mesaj Bildirimi

SnackBar, ekranın alt kısmında短暂的 olarak görünen bir mesajdır. Genellikle işlem sonuçlarını bildirmek için kullanılır.

**Takaş'tan örnek — `login_screen.dart`:**

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Giriş hatası: ${error.toString()}')),
);
```

**Takaş'tan örnek — şifre sıfırlama (`login_screen.dart`):**

```dart
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('Sıfırlama bağlantısı gönderildi')),
);
```

### AlertDialog — Uyarı Diyaloğu

AlertDialog, kullanıcıya bir seçenek veya bilgi sunan, sayfanın üstünde beliren küçük bir penceredir.

**Takaş'tan örnek — `login_screen.dart` (Şifre sıfırlama diyaloğu):**

```dart
void _showResetPasswordDialog() {
  final controller = TextEditingController();
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Şifremi Sıfırla'),
      content: Column(
        mainAxisSize: MainAxisSize.min,  // İçeriğin boyutuna göre küçül
        children: [
          const Text('E-posta adresinize şifre sıfırlama bağlantısı gönderilecek.'),
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
      actions: [                        // Diyaloğun altındaki butonlar
        TextButton(
          onPressed: () => Navigator.pop(context),  // Diyaloğu kapat
          child: const Text('İptal'),
        ),
        FilledButton(
          onPressed: () async {
            final email = controller.text.trim();
            if (email.isEmpty || !email.contains('@')) return;
            try {
              await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sıfırlama bağlantısı gönderildi')),
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
    ),
  );
}
```

Bu diyalogun yapısı:
- `title` — Diyalog başlığı
- `content` — Ana içerik (metin + TextField)
- `actions` — Alt kısımdaki butonlar (İptal, Gönder)
- `Navigator.pop(context)` — Diyalogu kapatır

### CircularProgressIndicator — Yükleme Göstergesi

İşlemin devam ettiğini gösteren dönen daire animasyonu.

**Takaş'tan örnek — `login_screen.dart`:**

```dart
const SizedBox(
  width: 22,
  height: 22,
  child: CircularProgressIndicator(
    strokeWidth: 2.5,     // Çizgi kalınlığı
    color: Colors.white,   // Beyaz renk (koyu buton üzerinde)
  ),
)
```

**Takaş'tan örnek — `listing_card.dart` (Fotoğraf yüklenirken):**

```dart
placeholder: (_, __) => Container(
  color: colorScheme.surfaceContainerHighest,
  child: Center(
    child: SizedBox(
      width: 28,
      height: 28,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        color: colorScheme.primary,
      ),
    ),
  ),
),
```

### Icon — İkon Gösterimi

Material Design ikonlarını ekranda gösterir. Flutter'da yüzlerce hazır ikon vardır.

**Takaş'tan örnekler:**

```dart
const Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 40)  // Takas ikonu
const Icon(Icons.email_outlined)          // Email ikonu
const Icon(Icons.lock_outline)            // Kilit ikonu
Icon(Icons.location_on_rounded, size: 12) // Konum ikonu
Icon(Icons.explore_outlined)              // Keşfet ikonu
Icon(Icons.chat_outlined)                 // Sohbet ikonu
Icon(Icons.person_outline_rounded)        // Profil ikonu
```

`Icons.xxx` — Flutter'ın yerleşik Material ikon galerisidir. `size` ikon boyutunu, `color` rengini belirler.

### InkWell / GestureDetector — Dokunma Algılama

**InkWell:** Material Design ripple efekti (dalgalanma) ile dokunma algılar. Tappable (tıklanabilir) elemanlar için idealdir.

**GestureDetector:** Daha geniş dokunma hareketlerini algılar (tap, double tap, long press, drag vb.) ama görsel efekt vermez.

**Takaş'tan örnek — InkWell (`listing_card.dart`):**

```dart
Material(
  color: Colors.transparent,
  child: InkWell(
    onTap: onTap,                             // Tıklanınca çalışacak fonksiyon
    borderRadius: BorderRadius.circular(20),  // Ripple efekti yuvarlak köşeli
    child: Column(/* ... */),
  ),
),
```

`Material` + `InkWell` kombinasyonu, ripple efektinin doğru çalışması için gerekir. `Material(color: Colors.transparent)` sayesinde arka plan şeffaftır ama ink (mürekkep) efekti çalışır.

**Takaş'tan örnek — GestureDetector (`listing_card.dart` favori butonu):**

```dart
GestureDetector(
  onTap: () {
    ref
        .read(createListingControllerProvider.notifier)
        .toggleFavorite(listing);
  },
  child: AnimatedContainer(/* ... */),
),
```

**Takaş'tan örnek — GestureDetector (`router.dart` navigasyon):**

```dart
GestureDetector(
  behavior: HitTestBehavior.opaque,  // Boş alanlara da dokunmayı algıla
  onTap: onTap,
  child: SizedBox(/* ... */),
)
```

`HitTestBehavior.opaque`, widget'ın tüm alanını (boşluklar dahil) tıklanabilir yapar.

---

## 5. Layout Sistemi

Layout (düzen), widget'ların ekranda **nasıl yerleştirileceğini** belirleyen sistemdir. Flutter'da layout, widget'ları iç içe geçirerek oluşturulur. Her layout widget'ı, alt widget'larını belirli bir kurala göre düzenler.

### Column — Dikey Düzen

`Column`, alt widget'larını **yukarıdan aşağıya** (dikey olarak) dizer.

```
Column
├── Widget 1  (yukarıda)
├── Widget 2  (ortada)
└── Widget 3  (aşağıda)
```

**Takaş'tan örnek — `login_screen.dart`:**

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,  // Tüm elemanları enine yay
  children: [
    const SizedBox(height: 60),           // 60 birim boşluk
    Center(/* logo */),
    const SizedBox(height: 48),           // 48 birim boşluk
    TextFormField(/* email */),
    const SizedBox(height: 14),           // 14 birim boşluk
    TextFormField(/* şifre */),
    const SizedBox(height: 6),
    Align(/* şifremi unuttum */),
    const SizedBox(height: 16),
    SizedBox(/* giriş butonu */),
    // ...
  ],
),
```

**crossAxisAlignment:** Column'un yatay eksenindeki hizalamayı belirler:
- `CrossAxisAlignment.start` — Sola yasla
- `CrossAxisAlignment.center` — Ortala
- `CrossAxisAlignment.end` — Sağa yasla
- `CrossAxisAlignment.stretch` — Tüm elemanları enine yay (tam genişlik)

**Takaş'tan örnek — `listing_card.dart`:**

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,  // Sola yasla
  children: [
    Text(listing.title, /* ... */),
    const SizedBox(height: 3),
    Row(/* ... istenen eşya ... */),
    const Spacer(flex: 1),
    Flexible(
      child: Row(/* ... mesafe ve zaman ... */),
    ),
  ],
),
```

**mainAxisSize:** Column'un dikey boyutunu belirler:
- `MainAxisSize.max` — Tüm kullanılabilir alanı kapla (varsayılan)
- `MainAxisSize.min` — Sadece çocukların toplam boyutu kadar yer kapla

**Takaş'tan örnek — diyalog içinde (`login_screen.dart`):**

```dart
Column(
  mainAxisSize: MainAxisSize.min,  // İçeriğin boyutuna göre küçül
  children: [
    const Text('E-posta adresinize şifre sıfırlama bağlantısı gönderilecek.'),
    const SizedBox(height: 16),
    TextField(/* ... */),
  ],
)
```

### Row — Yatay Düzen

`Row`, alt widget'larını **soldan sağa** (yatay olarak) dizer.

```
Row
├── Widget 1  (solda)
├── Widget 2  (ortada)
└── Widget 3  (sağda)
```

**Takaş'tan örnek — `login_screen.dart` (ayırıcı çizgi):**

```dart
Row(
  children: [
    Expanded(child: Divider(color: colorScheme.outlineVariant)),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text('veya', style: TextStyle(/* ... */)),
    ),
    Expanded(child: Divider(color: colorScheme.outlineVariant)),
  ],
),
```

Bu Row, üç eleman içerir: sol çizgi, "veya" metni, sağ çizgi. `Expanded` widget'ları çizgileri eşit oranda uzatır.

**Takaş'tan örnek — `login_screen.dart` (hesap yok mu?):**

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.center,  // Ortala
  children: [
    Text('Hesabın yok mu?', style: TextStyle(/* ... */)),
    TextButton(
      onPressed: () => context.push('/register'),
      child: const Text('Kayıt Ol'),
    ),
  ],
),
```

**mainAxisAlignment:** Row'un yatay eksenindeki hizalamayı belirler:
- `MainAxisAlignment.start` — Sola yasla
- `MainAxisAlignment.center` — Ortala
- `MainAxisAlignment.end` — Sağa yasla
- `MainAxisAlignment.spaceBetween` — Aralarına eşit boşluk koy
- `MainAxisAlignment.spaceAround` — Etraflarına eşit boşluk koy
- `MainAxisAlignment.spaceEvenly` — Tamamen eşit dağıt

**Takaş'tan örnek — `router.dart` (alt navigasyon):**

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceAround,  // Eşit aralıklarla dağıt
  children: [
    _NavItem(/* Keşfet */),
    _NavItem(/* Harita */),
    _CenterButton(/* + */),
    _NavItem(/* Sohbet */),
    _NavItem(/* Profil */),
  ],
),
```

### Expanded — Kalan Alanı Kaplama

`Expanded`, bir widget'ın parent (üst) widget içinde **kalan tüm alanı kaplamasını** sağlar. Column veya Row içinde kullanılır.

**Takaş'tan örnek — `listing_card.dart`:**

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    Expanded(               // Fotoğraf alanı — kalan alanın ÇOĞUNU kapla
      flex: 7,             // 7 birimlik pay
      child: Stack(/* ... */),
    ),
    Expanded(               // Bilgi alanı — kalan alanın AZINI kapla
      flex: 3,             // 3 birimlik pay
      child: Padding(/* ... */),
    ),
  ],
),
```

**flex:** Alan paylaşımındaki oran. İlk Expanded `flex: 7`, ikincisi `flex: 3` olduğundan, toplam 10 birimlik alanın 7/10'u fotoğrafa, 3/10'u bilgi alanına gider.

**Başka bir Expanded örneği — `listing_card.dart`:**

```dart
Row(
  children: [
    Icon(Icons.swap_horiz_rounded, size: 14),
    const SizedBox(width: 3),
    Expanded(              // Metin kalan tüm alanı kaplasın
      child: Text(
        listing.wantedItem,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,  // Taşarsa "..." göster
      ),
    ),
  ],
),
```

Burada `Expanded`, `Text` widget'ının `Icon` ve `SizedBox`'tan kalan tüm genişliği kaplamasını sağlar. Eğer metin çok uzunsa `TextOverflow.ellipsis` ile "..." gösterilir.

### Flexible — Esnek Boyut

`Flexible`, `Expanded`'a benzer ama farkı: `Flexible` alt widget'ın kendi boyutuna göre küçülmesine izin verirken, `Expanded` alt widget'ı tüm alanı kaplamaya zorlar.

**Takaş'tan örnek — `listing_card.dart`:**

```dart
Flexible(
  child: Row(
    children: [
      if (distanceText != null) ...[
        Icon(Icons.location_on_rounded, size: 12),
        const SizedBox(width: 2),
        Text(distanceText, /* ... */),
        const SizedBox(width: 6),
      ],
      const Spacer(),
      Text(Helpers.timeAgo(listing.createdAt), /* ... */),
    ],
  ),
),
```

`Flexible` kullanılmasının sebebi: Bu satır, Column içindeki diğer elemanlardan arta kalan alanı esnek bir şekilde kaplar. Kendi içinde `Spacer()` ile konum ve zaman bilgilerini iki uca yayar.

### Spacer — Esnek Boşluk

`Spacer`, `Expanded`'ın boşluk bırakan halidir. Row veya Column içinde boşluk bırakmak için kullanılır.

**Takaş'tan örnek — `listing_card.dart`:**

```dart
const Spacer(flex: 1),  // Başlık ve istenen eşya ile alt bilgi arasına boşluk
```

```dart
const Spacer(),  // Konum bilgisini sola, zaman bilgisini sağa iter
```

### Stack — Üst Üste Yerleştirme

`Stack`, alt widget'larını **üst üste** yerleştirir. İlk child en altta, son child en üstte olur. Haritalar, resimler üzerinde rozet (badge) gösterme, resim üzerinde gradyan (renk geçişi) gibi işlemler için idealdir.

```
Stack
├── Widget 1  (en altta)
├── Widget 2  (ortada)
└── Widget 3  (en üstte)
```

**Takaş'tan örnek — `listing_card.dart` (ilan kartı görsel alanı):**

```dart
Stack(
  fit: StackFit.expand,  // Tüm alanı kapla
  children: [
    // 1. Katman: Ana fotoğraf (en altta)
    ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Hero(
        tag: 'image_${listing.id}_${context.hashCode}',
        child: CachedNetworkImage(/* ... */),
      ),
    ),

    // 2. Katman: Üst gradyan (karanlıktan şeffafa geçiş)
    Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [
              Colors.black.withValues(alpha: 0.25),
              Colors.transparent,
            ],
          ),
        ),
      ),
    ),

    // 3. Katman: Fotoğraf sayısı rozeti (sol üst)
    if (listing.imageUrls.length > 1)
      Positioned(
        top: 10,
        left: 10,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.photo_library_outlined, size: 13, color: Colors.white),
              const SizedBox(width: 3),
              Text('${listing.imageUrls.length}', /* ... */),
            ],
          ),
        ),
      ),

    // 4. Katman: Favori butonu (sağ üst)
    Positioned(
      top: 10,
      right: 10,
      child: GestureDetector(
        onTap: () { /* favori toggle */ },
        child: AnimatedContainer(/* kalp ikonu */),
      ),
    ),

    // 5. Katman: Kategori etiketi (sol alt)
    Positioned(
      bottom: 10,
      left: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          listing.category.label,
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
      ),
    ),
  ],
),
```

Bu Stack, beş katmanı üst üste dizer:
1. Fotoğraf (alt katman)
2. Renk geçişi (gradyan)
3. Fotoğraf sayısı (sadece birden fazla fotoğraf varsa)
4. Favori kalp butonu (sağ üst)
5. Kategori etiketi (sol alt)

### Positioned — Stack İçinde Konumlandırma

`Positioned`, `Stack` içindeki bir widget'ın **kesin konumunu** belirler. `top`, `left`, `right`, `bottom` değerleri ile konum verilir.

**Takaş'tan örnekler:**

```dart
Positioned(
  top: 10, left: 10,     // Üstten 10, soldan 10 birim
  child: Container(/* fotoğraf sayısı */),
),

Positioned(
  top: 10, right: 10,    // Üstten 10, sağdan 10 birim
  child: GestureDetector(/* favori butonu */),
),

Positioned(
  bottom: 10, left: 10,  // Alttan 10, soldan 10 birim
  child: Container(/* kategori etiketi */),
),

Positioned.fill(           // Tüm Stack alanını kapla
  child: DecoratedBox(/* gradyan */),
),

Positioned(
  right: -4, top: -2,    // Stack sınırlarının dışına taşabilir
  child: Container(/* badge */),
),
```

`Positioned.fill` kısaltması, `top: 0, left: 0, right: 0, bottom: 0` ile aynı şeydir — widget Stack'in tüm alanını kaplar.

### Padding — İç Boşluk

`Padding`, bir widget'ın **çevresine boşluk** ekler. CSS'teki `padding` kavramıyla aynıdır.

```
┌─────────────────────┐
│    Padding          │
│  ┌───────────────┐  │
│  │   Widget      │  │
│  └───────────────┘  │
│                     │
└─────────────────────┘
```

**Takaş'tan örnekler:**

```dart
// Simetrik (yatay) padding
padding: const EdgeInsets.symmetric(horizontal: 28),  // login_screen.dart

// Simetrik (yatay ve dikey) padding
padding: const EdgeInsets.symmetric(horizontal: 16),
padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),    // sol, üst, sağ, alt

// Tüm yönlere eşit padding
padding: const EdgeInsets.all(7),

// Sadece belirli yönlerde
padding: const EdgeInsets.only(left: 10, top: 5),
```

**EdgeInsets Türleri:**

| Tür | Açıklama | Örnek |
|---|---|---|
| `EdgeInsets.all(X)` | Dört yöne eşit X birim | `EdgeInsets.all(16)` |
| `EdgeInsets.symmetric(horizontal: X, vertical: Y)` | Yatay X, dikey Y | `EdgeInsets.symmetric(horizontal: 28)` |
| `EdgeInsets.fromLTRB(L, T, R, B)` | Sol, Üst, Sağ, Alt | `EdgeInsets.fromLTRB(12, 8, 12, 8)` |
| `EdgeInsets.only(left: X)` | Sadece belirli yönler | `EdgeInsets.only(top: 10)` |

### SizedBox — Sabit Boyut / Boşluk

`SizedBox`, iki amaçla kullanılır:
1. **Boşluk bırakma:** `SizedBox(height: 20)` — 20 birimlik dikey boşluk
2. **Boyut belirleme:** `SizedBox(width: 100, height: 50)` — belirli boyutlarda kutu

**Takaş'tan boşluk örnekleri — `login_screen.dart`:**

```dart
const SizedBox(height: 60),   // Logo öncesi boşluk
const SizedBox(height: 16),   // Başlık sonrası boşluk
const SizedBox(height: 48),   // Logo ve form arası boşluk
const SizedBox(height: 14),   // Email ve şifre arası boşluk
const SizedBox(height: 6),    // Şifre ve "şifremi unuttum" arası boşluk
const SizedBox(height: 20),   // Ayırıcı sonrası boşluk
const SizedBox(height: 28),   // Google butonu sonrası boşluk
```

**Takaş'tan boyut belirleme örnekleri:**

```dart
// Buton yüksekliği
SizedBox(
  height: 52,
  child: FilledButton(/* ... */),
),

// Yükleme göstergesi boyutu
SizedBox(
  width: 22,
  height: 22,
  child: CircularProgressIndicator(strokeWidth: 2.5),
),

// Navigasyon öğesi genişliği — router.dart
SizedBox(width: 60, child: Column(/* ... */)),
```

### SafeArea — Güvenli Alan

`SafeArea`, içeriği çentik (notch), durum çubuğu (status bar) ve gezinme çubuğu (navigation bar) gibi sistem arayüzü elemanlarından korur.

**Takaş'tan örnek — `login_screen.dart`:**

```dart
Scaffold(
  body: SafeArea(    // İçerik çentik ve barlardan korunur
    child: SingleChildScrollView(/* ... */),
  ),
),
```

**Takaş'tan örnek — `router.dart`:**

```dart
child: SafeArea(
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    child: Row(/* navigasyon öğeleri */),
  ),
),
```

SafeArea olmasaydı, iPhone'lardaki çentik alanına içerik girerdi ve okunmaz/görünmez olurdu.

### SingleChildScrollView — Kaydırılabilir Alan

`SingleChildScrollView`, içeriği tek bir kaydırılabilir (scrollable) alan sağlar. İçerik ekranı aşarsa, kullanıcı aşağı/yukarı kaydırabilir.

**Takaş'tan örnek — `login_screen.dart`:**

```dart
SingleChildScrollView(
  padding: const EdgeInsets.symmetric(horizontal: 28),
  child: Form(/* ... */),
)
```

Bu, küçük ekranlı telefonlarda giriş formu ekrana sığmadığında kullanıcının aşağı kaydırabilmesini sağlar. `padding` ile içeriğe yatay boşluk da eklenir.

### Container — Çok Amaçlı Kutu

`Container`, Flutter'ın en çok kullanılan widget'larından biridir. Arka plan rengi, kenar yuvarlaklığı, gölge, boyut, padding ve daha birçok özelliği olan bir kutudur.

**Takaş'tan örnek — `listing_card.dart`:**

```dart
Container(
  height: 280,                                    // Sabit yükseklik
  decoration: BoxDecoration(                      // Görünüm özellikleri
    color: colorScheme.surface,                   // Arka plan rengi
    borderRadius: BorderRadius.circular(20),      // Yuvarlak köşeler (20 birim)
    boxShadow: [                                  // Gölgeler
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 16,                           // Bulanıklık yarıçapı
        offset: const Offset(0, 4),               // Gölge ofseti (sağa 0, aşağı 4)
      ),
    ],
  ),
  child: Material(/* ... */),
),
```

**Takaş'tan örnek — logo konteyneri (`login_screen.dart`):**

```dart
Container(
  width: 72,
  height: 72,
  decoration: BoxDecoration(
    color: colorScheme.primary,                   // Yeşil arka plan
    borderRadius: BorderRadius.circular(20),      // Yuvarlak köşeler
    boxShadow: [
      BoxShadow(
        color: colorScheme.primary.withValues(alpha: 0.3),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  ),
  child: const Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 40),
),
```

**Takaş'tan örnek — kategori etiketi (`listing_card.dart`):**

```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  decoration: BoxDecoration(
    color: colorScheme.primary,
    borderRadius: BorderRadius.circular(8),
  ),
  child: Text(
    listing.category.label,
    style: const TextStyle(color: Colors.white, fontSize: 11),
  ),
),
```

### ClipRRect — Yuvarlatılmış Köşeli Kırpma

`ClipRRect` (Clip Rounded Rectangle), alt widget'ı yuvarlatılmış köşeli bir dikdörtgen şeklinde kırpar.

**Takaş'tan örnek — `listing_card.dart`:**

```dart
ClipRRect(
  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
  child: Hero(
    tag: 'image_${listing.id}_${context.hashCode}',
    child: CachedNetworkImage(
      imageUrl: listing.imageUrls.first,
      fit: BoxFit.cover,
    ),
  ),
),
```

`BorderRadius.vertical(top: Radius.circular(20))` — sadece üst köşeleri yuvarlatır (alt köşeler düz kalır). Bu, kartın üst kısmında fotoğraf, alt kısmında metin olan bir tasarım oluşturur.

### Align — Hizalama

`Align`, alt widget'ını belirli bir konuma hizalar.

**Takaş'tan örnek — `login_screen.dart`:**

```dart
Align(
  alignment: Alignment.centerRight,  // Sağa ortala
  child: TextButton(
    onPressed: () => _showResetPasswordDialog(),
    child: const Text('Şifremi Unuttum'),
  ),
),
```

`Alignment` değerleri:
- `Alignment.topLeft` — Sol üst
- `Alignment.topCenter` — Üst orta
- `Alignment.center` — Tam ortada
- `Alignment.centerRight` — Sağ ortada
- `Alignment.bottomRight` — Sağ alt

---

## Özet Tablosu — Takaş Projesinde Kullanılan Temel Kavramlar

| Kavram | Açıklama | Takaş'taki Örnek |
|---|---|---|
| `StatelessWidget` | Değişmeyen UI | `ListingCard`, `_NavItem` |
| `StatefulWidget` | Değişebilen UI | `LoginScreen`, `TakashApp` |
| `State` | Widget'ın değişken durumu | `_LoginScreenState` |
| `build()` | UI'ı tanımlayan metod | Her widget'ta var |
| `setState()` | State'i güncelle (Riverpod alternatifi kullanılıyor) | Riverpod ile sağlanıyor |
| `context` | Widget'ın ağaçtaki konumu | `Theme.of(context)`, `ScaffoldMessenger.of(context)` |
| `GlobalKey` | Global benzersiz kimlik | `_formKey = GlobalKey<FormState>()` |
| `Scaffold` | Sayfa iskeleti | Her ekran |
| `Column` | Dikey düzen | Login formu, kart bilgi alanı |
| `Row` | Yatay düzen | Navigasyon çubuğu, ayırıcı |
| `Expanded` | Kalan alanı kapla | Fotoğraf alanı, çizgiler |
| `Stack` | Üst üste yerleştirme | Kart görsel alanı |
| `Positioned` | Stack içinde konum | Rozet, favori butonu |
| `Padding` | İç boşluk | Form padding'i |
| `SizedBox` | Sabit boyut/boşluk | Elemanlar arası boşluklar |
| `Container` | Çok amaçlı kutu | Kart, logo, etiket |
| `TextFormField` | Metin girişi | Email ve şifre alanları |
| `FilledButton` | Dolu düğme | Giriş Yap butonu |
| `TextButton` | Metin düğme | Kayıt Ol, Şifremi Unuttum |
| `SnackBar` | Kısa bildirim | Hata mesajları |
| `AlertDialog` | Uyarı penceresi | Şifre sıfırlama |
| `Future` | Gelecekteki değer | Firebase işlemleri |
| `Stream` | Sürekli veri akışı | Auth durumu değişiklikleri |
| `async/await` | Asenkron kod | `main()`, `_onLogin()` |
| `enum` | Sabit değerler kümesi | `ListingCategory`, `ListingStatus` |
| `extension` | Varolan tipe yeni yetenek | Kategori Türkçe label'ları |
| `final` | Tek atamalı değişken | Model alanları |
| `const` | Derleme zamanı sabiti | Widget constructor'ları |
| `required` | Zorunlu parametre | Model ve widget parametreleri |
| `?` ve `??` | Null safety | Opsiyonel alanlar |
| `Map<String, dynamic>` | JSON yapısı | `toJson()`, `fromJson()` |
| `List<T>` | Liste | `imageUrls` |

---

> **Sonraki Adım:** Bu belgede öğrendiğiniz temel kavramlar, Takaş projesinin yapı taşlarıdır. Bir sonraki belgede State yönetimi (Riverpod), Firebase entegrasyonu ve veri katmanı mimarisi konularını inceleyeceğiz.
