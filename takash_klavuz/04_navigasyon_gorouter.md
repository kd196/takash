# Takaş Flutter Projesi — GoRouter Navigasyon Kılavuzu

> **Hedef Kitle:** Flutter'a yeni başlayan geliştiriciler
> **Dil:** Türkçe
> **Proje:** Takaş — İkinci el eşya takas uygulaması

---

## İçindekiler

1. [Navigasyon Nedir?](#1-navigasyon-nedir)
2. [GoRouter Nedir?](#2-gorouter-nedir)
3. [Temel Kavramlar](#3-temel-kavramlar)
4. [context.push vs context.go vs context.pop Farkları](#4-contextpush-vs-contextgo-vs-contextpop-farkları)
5. [Route Guards (Redirect ile Auth Kontrolü)](#5-route-guards-redirect-ile-auth-kontrolü)
6. [Takaş Projesi — router.dart Tam Dosya İncelemesi](#6-takaş-projesi--routerdart-tam-dosya-incelemesi)
7. [Takaş Projesi — main.dart Tam Dosya İncelemesi](#7-takaş-projesi--maindart-tam-dosya-incelemesi)
8. [Özet Akış Diyagramı](#8-özet-akış-diyagramı)

---

## 1. Navigasyon Nedir?

### 1.1 Navigasyonun Temel Anlamı

Navigasyon, bir uygulamanın içinde farklı ekranlar (sayfalar) arasında geçiş yapma mekanizmasıdır.
Kullanıcı bir butona tıkladığında yeni bir sayfa açılır, geri tuşuna bastığında bir önceki sayfaya döner.
İşte bu geçiş sistemi genel olarak **navigasyon** olarak adlandırılır.

### 1.2 Web'de URL Routing (URL Yönlendirme)

Web tarayıcılarında her sayfanın bir adresi (URL) vardır:

```
https://takas-app.com/login        → Giriş ekranı
https://takas-app.com/profile       → Profil ekranı
https://takas-app.com/listing/123   → 123 numaralı ilanın detay sayfası
```

Tarayıcıda URL'ye göre doğru sayfanın gösterilmesine **URL routing** denir.
Kullanıcı adres çubuğuna bir URL yazdığında, uygulama o URL'ye karşılık gelen sayfayı render eder.
Bu sistem aynı zamanda tarayıcının "İleri" ve "Geri" butonlarıyla da çalışır.

### 1.3 Mobilde Sayfa Geçişleri

Mobil uygulamalarda (Android ve iOS) URL çubuğu yoktur. Ancak kavram aynıdır:
Kullanıcı bir ekrandan diğerine geçer ve cihazın geri butonuyla (Android'de fiziksel veya yazılımsal geri butonu) önceki ekrana döner.

Flutter'da bu geçişler genellikle bir **yığın (stack)** yapısıyla yönetilir:
Yeni bir sayfa açıldığında yığının üzerine eklenir, geri gidildiğinde yığının üstünden çıkarılır.

```
Yığın (Stack) Gösterimi:

┌─────────────────┐
│  İlan Detay     │  ← En üstteki (görülen) ekran
├─────────────────┤
│  Ana Sayfa      │  ← Altındaki ekran
├─────────────────┤
│  (Boş)          │
└─────────────────┘
```

### 1.4 Flutter'ın Yerleşik Navigator Sistemi

Flutter, `Navigator` sınıfı ile birlikte gelir. Bu sistem **imperative** (emir kipli) bir yaklaşımdır.
Yani "şu sayfayı aç", "şu sayfayı kapat" gibi doğrudan komutlar verirsiniz.

Örnek kullanım:

```dart
// Yeni sayfa aç (yığının üstüne ekle)
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const LoginScreen()),
);

// Mevcut sayfayı kapat (yığından çıkar)
Navigator.pop(context);
```

**Navigator sisteminin sorunları:**

| Sorun | Açıklama |
|-------|----------|
| URL desteği yoktur | Web'de URL'ye göre sayfa gösterilemez |
| Derin bağlantı (deep link) zordur | `takas-app.com/listing/123` gibi linklerle uygulamayı açmak karmaşık olur |
| Kod karmaşıklığı | Birçok `push` ve `pop` çağrısı yönetmek zorlaşır |
| State kaybı | Sayfalar arası geçişte state (durum) yönetimi zordur |
| Test edilebilirlik düşük | Navigasyon akışını test etmek zordur |

### 1.5 Navigator'dan GoRouter'a Neden Geçiyoruz?

Flutter ekibi, Navigator sisteminin eksikliklerini gidermek için **Navigator 2.0**'ı piyasaya sürdü.
Ancak Navigator 2.0 çok karmaşıktı ve kullanımı zordu.

Topluluk bu sorunu çözmek için çeşitli paketler geliştirdi. En popüleri **GoRouter** oldu.
GoRouter, Navigator 2.0'ın gücünü basit bir API arkasında sunar.

**Karşılaştırma:**

| Özellik | Navigator (eski) | GoRouter |
|---------|-------------------|----------|
| URL desteği | Yok | Var |
| Deep link | Zor | Kolay |
| Kod tarzı | Imperative (emir kipli) | Declarative (bildirimsel) |
| Auth (kimlik) kontrolü | Elle yapılır | `redirect` ile otomatik |
| Nested (iç içe) navigasyon | Çok zor | `StatefulShellRoute` ile kolay |
| Bakım kolaylığı | Düşük | Yüksek |

---

## 2. GoRouter Nedir?

### 2.1 Tanım

**GoRouter**, Flutter ekibi tarafından resmi olarak desteklenen (flutter/packages reposunda bulunan)
bir navigasyon paketidir. **Declarative routing** (bildirimsel yönlendirme) yaklaşımını kullanır.

### 2.2 Declarative Routing (Bildirimsel Yönlendirme) Nedir?

Declarative routing'te siz "neyin yapılacağını" söylersiniz, "nasıl yapılacağını" değil.
Yani her URL'nin hangi ekrana karşılık geldiğini bir **route tablosu** (haritası) olarak tanımlarsınız.

Örnek:

```dart
GoRouter(
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
  ],
);
```

Bu tanıma göre:
- Kullanıcı `/login` adresine giderse → `LoginScreen` gösterilir
- Kullanıcı `/profile` adresine giderse → `ProfileScreen` gösterilir

Bu yaklaşım, bir haritaya benzer. Haritada her adresin bir yeri vardır ve GoRouter bu haritaya
bakarak doğru yere yönlendirme yapar.

### 2.3 Neden GoRouter'ı Seçtik?

Takaş projesinde GoRouter'ı seçmemizin nedenleri:

1. **Web desteği:** Uygulama web'e de açıldığında URL'ler doğru çalışmalıdır
2. **Deep link desteği:** Kullanıcı bir bildirime tıkladığında doğrudan ilgili sohbet ekranına gidebilmeli
3. **Auth kontrolü:** Giriş yapmamış kullanıcıları otomatik olarak login ekranına yönlendirmeli
4. **Bottom Navigation Bar:** 5 sekmeli ana ekran yapısını `StatefulShellRoute` ile kolayca yönetmeli
5. **Parametreli route'lar:** `/listing/123` gibi dinamik URL'ler desteklemeli

### 2.4 GoRouter'ın Avantajları

| Avantaj | Açıklama |
|---------|----------|
| **Basit API** | Sadece `path` ve `builder` tanımlayarak route oluşturursunuz |
| **Otomatik redirect** | `redirect` fonksiyonu ile koşullu yönlendirme yapabilirsiniz |
| **Nested routing** | Route'lar iç içe tanımlanabilir, alt route'lar oluşturulabilir |
| **StatefulShellRoute** | Bottom Navigation Bar ile sekme geçişlerinde state korunur |
| **Parametreli route'lar** | `:id` sözdizimi ile dinamik URL parametreleri alınabilir |
| **Deep link** | Uygulama dışından gelen URL'ler otomatik olarak işlenir |
| **Test edilebilirlik** | Route yapısı bildirimsel olduğu için test edilmesi kolaydır |

---

## 3. Temel Kavramlar

### 3.1 Route Tanımlama (path ve builder)

En temel route tanımı iki bileşenden oluşur:

- **`path`**: URL adresi (örneğin `'/login'`)
- **`builder`**: Bu URL'ye gidildiğinde hangi widget'ın (ekranın) gösterileceğini belirten fonksiyon

```dart
GoRoute(
  path: '/login',                                          // URL: /login
  builder: (context, state) => const LoginScreen(),         // Gösterilecek ekran
),
```

**`builder` fonksiyonunun parametreleri:**

| Parametre | Tip | Açıklama |
|-----------|-----|----------|
| `context` | `BuildContext` | Flutter'ın widget ağacındaki konumu temsil eder |
| `state` | `GoRouterState` | Mevcut route hakkında bilgi içerir (path, parametreler vb.) |

`GoRouterState` içindeki önemli alanlar:

| Alan | Açıklama | Örnek |
|------|----------|-------|
| `matchedLocation` | Eşleşen tam yol | `'/listing/123'` |
| `pathParameters` | URL'deki dinamik parametreler | `{'id': '123'}` |
| `uri` | Tam URI bilgisi | `Uri.parse('/listing/123')` |
| `name` | Route'a verilen isim | `'listingDetail'` |

### 3.2 Parametreli Route'lar (:id)

URL'de değişken değerler kullanmak için `:` (iki nokta) sözdizimi kullanılır.
Bu parametreler **path parameter** (yol parametresi) olarak adlandırılır.

```dart
GoRoute(
  path: '/listing/:id',       // :id bir path parametresidir
  builder: (context, state) {
    final id = state.pathParameters['id']!;   // URL'den id değerini al
    return ListingDetailScreen(listingId: id); // id'yi ekrana gönder
  },
),
```

**Çalışma mantığı:**

| URL | `state.pathParameters['id']` | Sonuç |
|-----|------------------------------|-------|
| `/listing/abc123` | `'abc123'` | `ListingDetailScreen(listingId: 'abc123')` |
| `/listing/xyz789` | `'xyz789'` | `ListingDetailScreen(listingId: 'xyz789')` |
| `/listing/` | Hata (id eksik) | — |

**Birden fazla parametre örneği:**

```dart
GoRoute(
  path: '/user/:userId/post/:postId',
  builder: (context, state) {
    final userId = state.pathParameters['userId']!;
    final postId = state.pathParameters['postId']!;
    return PostDetailScreen(userId: userId, postId: postId);
  },
),
```

### 3.3 Nested Route'lar (İç İçe Route'lar)

Bir route'un **alt route'ları** olabilir. Alt route'lar, ana route'un `routes` parametresi
içinde tanımlanır. Bu, bir ekrandan diğerine hiyerarşik geçiş sağlar.

```dart
GoRoute(
  path: '/profile',
  builder: (context, state) => const ProfileScreen(),
  routes: [                               // ← Alt route'lar burada
    GoRoute(
      path: 'edit',                       // Tam yol: /profile/edit
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: 'favorites',                  // Tam yol: /profile/favorites
      builder: (context, state) => const FavoritesScreen(),
    ),
  ],
),
```

**Dikkat:** Alt route'ların path'inde başta `/` yoktur. `path: 'edit'` yazılır, `path: '/edit'` değil.
GoRouter, alt route'u ana route'un path'iyle birleştirir:
- Ana: `/profile`
- Alt: `edit`
- **Tam yol:** `/profile/edit`

**Hiyerarşi görselleştirmesi:**

```
/profile            → ProfileScreen
  ├── /profile/edit       → EditProfileScreen
  ├── /profile/favorites  → FavoritesScreen
  └── /profile/my-listings → MyListingsScreen
```

### 3.4 StatefulShellRoute (Bottom Navigation Bar İçin)

`StatefulShellRoute`, Bottom Navigation Bar'lı (alt sekmeli) uygulamalar için tasarlanmıştır.
Her sekme ayrı bir **branch** (dal) olarak tanımlanır ve her branch kendi navigasyon yığınını korur.

**Neden StatefulShellRoute kullanıyoruz?**

Normalde Bottom Navigation Bar'da sekme değiştirdiğinizde, önceki sekmeye döndüğünüzde
o sekmenin state'i (kaydırma konumu, form verileri vb.) kaybolur.
`StatefulShellRoute`, her branch'in state'ini ayrı ayrı korur.

**Basit bir StatefulShellRoute yapısı:**

```dart
StatefulShellRoute.indexedStack(
  builder: (context, state, navigationShell) {
    return MainScreen(navigationShell: navigationShell);
  },
  branches: [
    StatefulShellBranch(routes: [/* Sekme 0 route'ları */]),
    StatefulShellBranch(routes: [/* Sekme 1 route'ları */]),
    StatefulShellBranch(routes: [/* Sekme 2 route'ları */]),
  ],
),
```

**Parametrelerin açıklaması:**

| Parametre | Tip | Açıklama |
|-----------|-----|----------|
| `builder` | `Function(BuildContext, GoRouterState, StatefulNavigationShell)` | Tüm branch'leri saran ana widget'ı oluşturur |
| `branches` | `List<StatefulShellBranch>` | Her bir sekmeyi temsil eden dal listesi |

**`StatefulNavigationShell` nedir?**

Bu nesne, mevcut aktif branch'i (sekmeyi) temsil eder ve:
- `navigationShell.currentIndex` → Aktif sekmeyi gösterir
- `navigationShell.goBranch(2)` → 2 numaralı sekmeye geçer
- `navigationShell` widget olarak kullanıldığında aktif branch'in içeriğini gösterir

**`.indexedStack` ne demek?**

`StatefulShellRoute.indexedStack`, tüm branch'lerin widget'larını aynı anda bellekte tutar
(`IndexedStack` gibi) ama sadece aktif olanı gösterir. Bu sayede sekme değiştiğinde
önceki sekmenin state'i korunmuş olur.

### 3.5 Redirect (Yönlendirme)

`redirect`, bir route'a gitmeden önce çalıştırılan bir fonksiyondur.
Bu fonksiyon, kullanıcının o route'a erişim izni olup olmadığını kontrol edebilir ve
gerekirse farklı bir route'a yönlendirebilir.

**Örnek mantık:**

```dart
redirect: (context, state) {
  // Kullanıcı giriş yapmamış ve korumalı bir sayfaya erişmeye çalışıyorsa
  if (!isLoggedIn && !isAuthRoute) {
    return '/login';    // Login ekranına yönlendir
  }
  // Kullanıcı giriş yapmış ve login sayfasındaysa
  if (isLoggedIn && isAuthRoute) {
    return '/';          // Ana sayfaya yönlendir
  }
  return null;           // null dönerse yönlendirme yapılmaz, normal devam eder
},
```

**Önemli kurallar:**
- `redirect` fonksiyonu `null` dönerse → yönlendirme yapılmaz, istenen sayfa gösterilir
- `redirect` fonksiyonu bir `String` dönerse → o URL'ye yönlendirme yapılır
- Sonsuz döngüye dikkat! (Örneğin `/login`'den `/login`'e yönlendirme yapmayın)

---

## 4. context.push vs context.go vs context.pop Farkları

GoRouter ile sayfalar arası geçiş yapmak için üç temel metod kullanılır:

### 4.1 context.push(String path)

**Ne yapar?** Yeni bir sayfayı mevcut sayfanın **üzerine** ekler (yığına push eder).

```
Mevcut yığın:        Push sonrası yığın:
┌─────────────┐      ┌─────────────────┐
│             │      │ İlan Detay      │ ← Yeni eklenen
│  Ana Sayfa  │      ├─────────────────┤
│             │      │ Ana Sayfa       │
└─────────────┘      └─────────────────┘
```

**Kullanım:**

```dart
// İlan detay sayfasını aç
context.push('/listing/abc123');
```

**Özellikleri:**
- Yeni bir yığın (stack) katmanı oluşturur
- Geri butonu ile önceki sayfaya dönülebilir
- URL değişir: `/` → `/listing/abc123`
- Aynı route'a birden fazla kez push yapılabilir (farklı parametrelerle)

**Kullanım senaryosu:** Bir listeden detay sayfasına gitmek (geri dönmek istediğinizde)

### 4.2 context.go(String path)

**Ne yapar?** Mevcut yığını **temizler** ve belirtilen URL'ye gider.

```
Mevcut yığın:        go sonrası yığın:
┌─────────────────┐  ┌─────────────────┐
│ İlan Detay      │  │                 │
├─────────────────┤  │  Login Ekranı   │ ← Yeni (yığın sıfırlandı)
│ Ana Sayfa       │  │                 │
└─────────────────┘  └─────────────────┘
```

**Kullanım:**

```dart
// Login ekranına git (önceki yığını temizle)
context.go('/login');
```

**Özellikleri:**
- Yığını temizler (önceki sayfalara geri dönülemez)
- URL'yi doğrudan değiştirir
- "Baştan başla" hissi verir
- Auth (giriş) işlemlerinde çok kullanılır

**Kullanım senaryosu:** Login ekranına yönlendirme, çıkış yapıldığında ana sayfaya dönme

### 4.3 context.pop()

**Ne yapar?** Mevcut sayfayı yığından çıkarır (yığının üsttekini kaldırır) ve bir önceki sayfaya döner.

```
Mevcut yığın:        pop sonrası yığın:
┌─────────────────┐  ┌─────────────────┐
│ İlan Detay      │  │                 │ ← Kaldırıldı
├─────────────────┤  │  Ana Sayfa      │
│ Ana Sayfa       │  │                 │
└─────────────────┘  └─────────────────┘
```

**Kullanım:**

```dart
// Önceki sayfaya dön
context.pop();
```

**Özellikleri:**
- Yalnızca bir adım geri gider
- Yığında tek sayfa varsa (kök sayfadaysa) pop yapılamaz
- Opsiyonel olarak değer döndürebilir: `context.pop(result)`

**Kullanım senaryosu:** Geri butonu, iptal butonu, formdan çıkış

### 4.4 Karşılaştırma Tablosu

| Özellik | `context.push()` | `context.go()` | `context.pop()` |
|---------|------------------|----------------|-----------------|
| Yığın davranışı | Üzerine ekle | Temizle ve git | Üsttekini kaldır |
| Geri dönüş | Mümkün | Mümkün değil | — |
| URL değişimi | Evet | Evet | Evet (önceki URL'ye) |
| Tipik kullanım | Detay sayfası açma | Auth yönlendirme | Geri dönme |
| Analama benzerliği | `Navigator.push` | `Navigator.pushReplacement` | `Navigator.pop` |

### 4.5 Takaş Projesinde Kullanım Örnekleri

```dart
// İlan detayını aç (geri dönebilmek için push kullan)
onTap: () => context.push('/listing/${listing.id}'),

// Sohbet detayını aç
onTap: () => context.push('/chat/${chat.id}'),

// Başarıyla giriş yaptıktan sonra ana sayfaya git (yığını sıfırla)
context.go('/');

// Çıkış yapınca login ekranına git
context.go('/login');

// Profil düzenlemeden vazgeç (geri dön)
context.pop();

// Edit listing sayfasını aç
context.push('/edit-listing/${listing.id}');
```

---

## 5. Route Guards (Redirect ile Auth Kontrolü)

### 5.1 Route Guard Nedir?

Route guard, belirli route'lara erişimi kontrol eden bir mekanizmadır.
Örneğin, sadece giriş yapmış kullanıcıların görebileceği sayfalar vardır.
Giriş yapmamış bir kullanıcı bu sayfalara erişmeye çalıştığında, guard onu login ekranına yönlendirir.

### 5.2 GoRouter'da Route Guard Nasıl Uygulanır?

GoRouter'da ayrı bir "guard" kavramı yoktur. Bunun yerine `redirect` fonksiyonu kullanılır.
`redirect`, her navigasyon işleminden önce çalışır ve koşullu yönlendirme yapabilir.

### 5.3 Takaş Projesinde Auth Mantığı

Takaş projesinde üç farklı durum kontrol edilir:

1. **Onboarding tamamlanmamışsa** → Kullanıcı onboarding (karşılama) ekranına yönlendirilir
2. **Onboarding tamamlanmış ama giriş yapılmamışsa** → Login ekranına yönlendirilir
3. **Giriş yapılmışsa** → İstenen sayfaya normal erişim sağlanır

**Akış diyagramı:**

```
Uygulama Açıldı
      │
      ▼
 Onboarding Tamamlandı mı? ──── Hayır ────→ /onboarding
      │
     Evet
      │
      ▼
 Giriş Yapıldı mı? ──── Hayır ────→ /login
      │
     Evet
      │
      ▼
 İstenen sayfayı göster
```

**Kod olarak:**

```dart
redirect: (context, state) async {
  final prefs = await SharedPreferences.getInstance();
  final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
  final isLoggedIn = authState.value != null;

  // 1. Onboarding tamamlanmamışsa → onboarding'e yönlendir
  if (!onboardingCompleted) return '/onboarding';

  // 2. Onboarding tamamlanmış ve onboarding sayfasındaysa → login'e yönlendir
  if (onboardingCompleted && state.matchedLocation == '/onboarding') return '/login';

  // 3. Giriş yapılmamış ve auth route'larında değilse → login'e yönlendir
  if (!isLoggedIn && !isAuthRoute) return '/login';

  // 4. Giriş yapılmış ve auth route'undaysa → ana sayfaya yönlendir
  if (isLoggedIn && isAuthRoute) return '/';

  // 5. Sorun yoksa normal devam et
  return null;
},
```

### 5.4 authStateProvider Nedir?

Takaş projesinde kimlik doğrulama durumu `authStateProvider` ile izlenir:

```dart
// lib/core/providers.dart
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});
```

Bu provider, Firebase Authentication'dan gelen kullanıcı durumunu dinler:
- Kullanıcı giriş yaptığında → `User` nesnesi döner (null değil)
- Kullanıcı çıkış yaptığında → `null` döner

**Router'da kullanımı:**

```dart
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);  // Auth durumunu dinle
  // ...
  final isLoggedIn = authState.value != null;       // null değilse giriş yapılmış
  // ...
});
```

`ref.watch(authStateProvider)` kullanıldığı için, auth durumu değiştiğinde
(router'a her giriş/çıkışta) `routerProvider` yeniden oluşturulur ve `redirect` fonksiyonu
tekrar çalışır. Bu sayede auth durumu değiştiğinde otomatik yönlendirme yapılır.

### 5.5 Onboarding Mantığı

Onboarding (karşılama ekranı), kullanıcının uygulamayı ilk kez açtığında gördüğü
tanıtım ekranıdır. Kullanıcı bu ekranı gördükten sonra `SharedPreferences`'a bir
bayrak (flag) kaydedilir:

```dart
// Kullanıcı onboarding'i tamamladığında
await prefs.setBool('onboarding_completed', true);

// Uygulama her açıldığında kontrol
final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
```

`?? false` ifadesi, değer daha önce kaydedilmediyse varsayılan olarak `false` kabul eder.
Yani ilk kez açılıyorsa `onboardingCompleted = false` olur ve kullanıcı onboarding ekranına yönlendirilir.

---

## 6. Takaş Projesi — router.dart Tam Dosya İncelemesi

Bu bölümde projenin `lib/app/router.dart` dosyasının her satırını tek tek inceleyeceğiz.

### 6.1 Tam Dosya İçeriği

Aşağıda dosyanın tamamı, her satır numaralandırılmış olarak yer almaktadır:

```dart
 1: import 'package:flutter/material.dart';
 2: import 'package:flutter_riverpod/flutter_riverpod.dart';
 3: import 'package:go_router/go_router.dart';
 4: import 'package:shared_preferences/shared_preferences.dart';
 5: import '../core/providers.dart';
 6: import '../features/chat/presentation/chat_controller.dart';
 7: import '../features/auth/presentation/login_screen.dart';
 8: import '../features/auth/presentation/register_screen.dart';
 9: import '../features/listings/presentation/home_screen.dart';
10: import '../features/listings/presentation/create_listing_screen.dart';
11: import '../features/listings/presentation/edit_listing_screen.dart';
12: import '../features/listings/presentation/listing_detail_screen.dart';
13: import '../features/listings/presentation/my_listings_screen.dart';
14: import '../features/listings/presentation/favorites_screen.dart';
15: import '../features/chat/presentation/chat_list_screen.dart';
16: import '../features/chat/presentation/chat_detail_screen.dart';
17: import '../features/map/presentation/map_screen.dart';
18: import '../features/profile/presentation/profile_screen.dart';
19: import '../features/profile/presentation/edit_profile_screen.dart';
20: import '../features/notifications/presentation/notification_screen.dart';
21: import '../features/onboarding/presentation/onboarding_screen.dart';
22: import '../features/profile/presentation/public_profile_screen.dart';
23: import '../features/profile/presentation/settings_screen.dart';
24: import '../features/profile/presentation/change_email_screen.dart';
25: import '../features/profile/presentation/change_password_screen.dart';
26: 
27: final routerProvider = Provider<GoRouter>((ref) {
28:   final authState = ref.watch(authStateProvider);
29: 
30:   return GoRouter(
31:     initialLocation: '/onboarding',
32:     redirect: (context, state) async {
33:       final prefs = await SharedPreferences.getInstance();
34:       final onboardingCompleted =
35:           prefs.getBool('onboarding_completed') ?? false;
36:       final isLoggedIn = authState.value != null;
37:       final isAuthRoute = state.matchedLocation == '/login' ||
38:           state.matchedLocation == '/register';
39:       final isOnboarding = state.matchedLocation == '/onboarding';
40: 
41:       if (!onboardingCompleted) return '/onboarding';
42:       if (onboardingCompleted && isOnboarding) return '/login';
43:       if (!isLoggedIn && !isAuthRoute) return '/login';
44:       if (isLoggedIn && isAuthRoute) return '/';
45:       return null;
46:     },
47:     routes: [
48:       GoRoute(
49:         path: '/onboarding',
50:         builder: (context, state) => const OnboardingScreen(),
51:       ),
52:       GoRoute(
53:         path: '/login',
54:         builder: (context, state) => const LoginScreen(),
55:       ),
56:       GoRoute(
57:         path: '/register',
58:         builder: (context, state) => const RegisterScreen(),
59:       ),
60:       GoRoute(
61:         path: '/user/:id',
62:         builder: (context, state) {
63:           final id = state.pathParameters['id']!;
64:           return PublicProfileScreen(userId: id);
65:         },
66:       ),
67:       GoRoute(
68:         path: '/notifications',
69:         builder: (context, state) => const NotificationScreen(),
70:       ),
71:       GoRoute(
72:         path: '/settings',
73:         builder: (context, state) => const SettingsScreen(),
74:       ),
75:       StatefulShellRoute.indexedStack(
76:         builder: (context, state, navigationShell) {
77:           return MainScreen(navigationShell: navigationShell);
78:         },
79:         branches: [
80:           StatefulShellBranch(
81:             routes: [
82:               GoRoute(
83:                 path: '/',
84:                 builder: (context, state) => const HomeScreen(),
85:                 routes: [
86:                   GoRoute(
87:                     path: 'listing/:id',
88:                     builder: (context, state) {
89:                       final id = state.pathParameters['id']!;
90:                       return ListingDetailScreen(listingId: id);
91:                     },
92:                   ),
93:                ],
94:               ),
95:             ],
96:           ),
97:           StatefulShellBranch(
98:             routes: [
99:               GoRoute(
100:                path: '/map',
101:                builder: (context, state) => const MapScreen(),
102:              ),
103:            ],
104:          ),
105:          StatefulShellBranch(
106:            routes: [
107:              GoRoute(
108:                path: '/create-listing',
109:                builder: (context, state) => const CreateListingScreen(),
110:              ),
111:            ],
112:          ),
113:          StatefulShellBranch(
114:            routes: [
115:              GoRoute(
116:                path: '/chats',
117:                builder: (context, state) => const ChatListScreen(),
118:              ),
119:            ],
120:          ),
121:          StatefulShellBranch(
122:            routes: [
123:              GoRoute(
124:                path: '/profile',
125:                builder: (context, state) => const ProfileScreen(),
126:                routes: [
127:                  GoRoute(
128:                    path: 'edit',
129:                    builder: (context, state) => const EditProfileScreen(),
130:                  ),
131:                  GoRoute(
132:                    path: 'my-listings',
133:                    builder: (context, state) => const MyListingsScreen(),
134:                  ),
135:                  GoRoute(
136:                    path: 'favorites',
137:                    builder: (context, state) => const FavoritesScreen(),
138:                  ),
139:                ],
140:              ),
141:            ],
142:          ),
143:        ],
144:      ),
145:      GoRoute(
146:        path: '/edit-listing/:id',
147:        builder: (context, state) {
148:          final id = state.pathParameters['id']!;
149:          return EditListingScreen(listingId: id);
150:        },
151:      ),
152:      GoRoute(
153:        path: '/chat/:id',
154:        builder: (context, state) {
155:          final id = state.pathParameters['id']!;
156:          return ChatDetailScreen(chatId: id);
157:        },
158:      ),
159:      GoRoute(
160:        path: '/change-email',
161:        builder: (context, state) => const ChangeEmailScreen(),
162:      ),
163:      GoRoute(
164:        path: '/change-password',
165:        builder: (context, state) => const ChangePasswordScreen(),
166:      ),
167:    ],
168:  );
169: });
170: 
171: class MainScreen extends ConsumerWidget {
172:   final StatefulNavigationShell navigationShell;
173: 
174:   const MainScreen({super.key, required this.navigationShell});
175: 
176:   @override
177:   Widget build(BuildContext context, WidgetRef ref) {
178:     final unreadCount = ref.watch(unreadCountProvider);
179:     final currentIndex = navigationShell.currentIndex;
180: 
181:     return Scaffold(
182:       body: navigationShell,
183:       extendBody: true,
184:       bottomNavigationBar: Container(
185:         decoration: BoxDecoration(
186:           color: Theme.of(context).colorScheme.surface,
187:           boxShadow: [
188:             BoxShadow(
189:               color: Colors.black.withValues(alpha: 0.06),
190:               blurRadius: 20,
191:               offset: const Offset(0, -4),
192:             ),
193:          ],
194:        ),
195:        child: SafeArea(
196:          child: Padding(
197:            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
198:            child: Row(
199:              mainAxisAlignment: MainAxisAlignment.spaceAround,
200:              children: [
201:                _NavItem(
202:                  icon: Icons.explore_outlined,
203:                  activeIcon: Icons.explore,
204:                  label: 'Keşfet',
205:                  isActive: currentIndex == 0,
206:                  onTap: () => navigationShell.goBranch(0),
207:                ),
208:                _NavItem(
209:                  icon: Icons.map_outlined,
210:                  activeIcon: Icons.map,
211:                  label: 'Harita',
212:                  isActive: currentIndex == 1,
213:                  onTap: () => navigationShell.goBranch(1),
214:                ),
215:                _CenterButton(
216:                  isActive: currentIndex == 2,
217:                  onTap: () => navigationShell.goBranch(2),
218:                ),
219:                _NavItem(
220:                  icon: Icons.chat_outlined,
221:                  activeIcon: Icons.chat,
222:                  label: 'Sohbet',
223:                  isActive: currentIndex == 3,
224:                  badge: unreadCount > 0 ? '$unreadCount' : null,
225:                  onTap: () => navigationShell.goBranch(3),
226:                ),
227:                _NavItem(
228:                  icon: Icons.person_outline_rounded,
229:                  activeIcon: Icons.person_rounded,
230:                  label: 'Profil',
231:                  isActive: currentIndex == 4,
232:                  onTap: () => navigationShell.goBranch(4),
233:                ),
234:              ],
235:            ),
236:          ),
237:        ),
238:      ),
239:    );
240:  }
241: }
242: 
243: class _NavItem extends StatelessWidget {
244:   final IconData icon;
245:   final IconData activeIcon;
246:   final String label;
247:   final bool isActive;
248:   final String? badge;
249:   final VoidCallback onTap;
250: 
251:   const _NavItem({
252:    required this.icon,
253:    required this.activeIcon,
254:    required this.label,
255:    required this.isActive,
256:    required this.onTap,
257:    this.badge,
258:  });
259: 
260:  @override
261:  Widget build(BuildContext context) {
262:    final colorScheme = Theme.of(context).colorScheme;
263:    final activeColor = colorScheme.primary;
264:    final inactiveColor = colorScheme.outline;
265: 
266:    return GestureDetector(
267:      behavior: HitTestBehavior.opaque,
268:      onTap: onTap,
269:      child: SizedBox(
270:        width: 60,
271:        child: Column(
272:          mainAxisSize: MainAxisSize.min,
273:          children: [
274:            const SizedBox(height: 4),
275:            SizedBox(
276:              height: 28,
277:              width: 28,
278:              child: Stack(
279:                clipBehavior: Clip.none,
280:                children: [
281:                  Center(
282:                    child: Icon(
283:                      isActive ? activeIcon : icon,
284:                      color: isActive ? activeColor : inactiveColor,
285:                      size: 24,
286:                    ),
287:                  ),
288:                  if (badge != null)
289:                    Positioned(
290:                      right: -4,
291:                      top: -2,
292:                      child: Container(
293:                        padding: const EdgeInsets.symmetric(
294:                            horizontal: 4, vertical: 1),
295:                        decoration: BoxDecoration(
296:                          color: colorScheme.error,
297:                          borderRadius: BorderRadius.circular(10),
298:                        ),
299:                        constraints:
300:                            const BoxConstraints(minWidth: 16, minHeight: 16),
301:                        child: Text(
302:                          badge!,
303:                          textAlign: TextAlign.center,
304:                          style: TextStyle(
305:                            color: Colors.white,
306:                            fontSize: 10,
307:                            fontWeight: FontWeight.w700,
308:                          ),
309:                        ),
310:                      ),
311:                    ),
312:                ],
313:              ),
314:            ),
315:            const SizedBox(height: 2),
316:            Text(
317:              label,
318:              style: TextStyle(
319:                fontSize: 11,
320:                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
321:                color: isActive ? activeColor : inactiveColor,
322:                letterSpacing: -0.2,
323:              ),
324:            ),
325:          ],
326:        ),
327:      ),
328:    );
329:  }
330: }
331: 
332: class _CenterButton extends StatelessWidget {
333:   final bool isActive;
334:   final VoidCallback onTap;
335: 
336:   const _CenterButton({required this.isActive, required this.onTap});
337: 
338:  @override
339:  Widget build(BuildContext context) {
340:    final colorScheme = Theme.of(context).colorScheme;
341: 
342:    return GestureDetector(
343:      onTap: onTap,
344:      child: AnimatedContainer(
345:        duration: const Duration(milliseconds: 200),
346:        curve: Curves.easeInOut,
347:        height: 48,
348:        width: 56,
349:        decoration: BoxDecoration(
350:          color: isActive ? colorScheme.onPrimary : colorScheme.primary,
351:          borderRadius: BorderRadius.circular(16),
352:          boxShadow: [
353:            BoxShadow(
354:              color: colorScheme.primary.withValues(alpha: 0.35),
355:              blurRadius: 12,
356:              offset: const Offset(0, 4),
357:            ),
358:          ],
359:        ),
360:        child: Icon(
361:          Icons.add_rounded,
362:          color: isActive ? colorScheme.primary : Colors.white,
363:          size: 28,
364:        ),
365:      ),
366:    );
367:  }
368: }
```

### 6.2 Satır Satır Açıklama

#### Satır 1–25: Import (İçeri Aktarma) Bölümü

**Satır 1:**
```dart
import 'package:flutter/material.dart';
```
Flutter'ın temel material design widget'larını (Scaffold, Icon, Text, Container, vb.)
kullanabilmek için `material` paketini içeri aktarır. Bu paket olmadan hiçbir UI bileşeni
kullanılamaz.

---

**Satır 2:**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
```
Riverpod state management kütüphanesini içeri aktarır. `Provider`, `ConsumerWidget`,
`WidgetRef`, `ref.watch`, `ref.read` gibi Riverpod bileşenlerini kullanabilmek için gereklidir.
Takaş projesinde state management olarak Riverpod kullanılır. Router, bir Riverpod `Provider`
olarak tanımlanır ve auth durumunu dinlemek için `ref.watch` kullanılır.

---

**Satır 3:**
```dart
import 'package:go_router/go_router.dart';
```
GoRouter paketini içeri aktarır. `GoRouter`, `GoRoute`, `StatefulShellRoute`,
`StatefulNavigationShell`, `GoRouterState` gibi navigasyon sınıflarını kullanabilmek için
bu import gereklidir. Ayrıca `context.push()`, `context.go()`, `context.pop()` gibi
extension metodları da bu paketle gelir.

---

**Satır 4:**
```dart
import 'package:shared_preferences/shared_preferences.dart';
```
`SharedPreferences` paketini içeri aktarır. Bu paket, basit anahtar-değer çiftlerini
cihazın local deposuna kaydetmeyi sağlar. Takaş projesinde onboarding durumunu
(`onboarding_completed` bayrağını) saklamak için kullanılır.

---

**Satır 5:**
```dart
import '../core/providers.dart';
```
Projenin `core/providers.dart` dosyasını içeri aktarır. Bu dosyada `authStateProvider`
ve `firebaseAuthProvider` gibi temel provider'lar tanımlanır. Router, kullanıcının giriş
durumunu (`authStateProvider`) dinlemek için bu import'a ihtiyaç duyar.

---

**Satır 6:**
```dart
import '../features/chat/presentation/chat_controller.dart';
```
Sohbet (chat) özelliğinin controller dosyasını içeri aktarır. Bu dosyada
`unreadCountProvider` tanımlıdır. Bu provider, okunmamış mesaj sayısını hesaplar
ve sohbet sekmesindeki badge (kırmızı bildirim sayısı) için kullanılır.
`MainScreen` widget'ı bu değeri dinleyerek badge gösterir.

---

**Satır 7–25:**
```dart
import '../features/auth/presentation/login_screen.dart';           // Satır 7
import '../features/auth/presentation/register_screen.dart';         // Satır 8
import '../features/listings/presentation/home_screen.dart';         // Satır 9
import '../features/listings/presentation/create_listing_screen.dart';  // Satır 10
import '../features/listings/presentation/edit_listing_screen.dart';    // Satır 11
import '../features/listings/presentation/listing_detail_screen.dart';  // Satır 12
import '../features/listings/presentation/my_listings_screen.dart';     // Satır 13
import '../features/listings/presentation/favorites_screen.dart';       // Satır 14
import '../features/chat/presentation/chat_list_screen.dart';           // Satır 15
import '../features/chat/presentation/chat_detail_screen.dart';         // Satır 16
import '../features/map/presentation/map_screen.dart';                  // Satır 17
import '../features/profile/presentation/profile_screen.dart';          // Satır 18
import '../features/profile/presentation/edit_profile_screen.dart';     // Satır 19
import '../features/notifications/presentation/notification_screen.dart'; // Satır 20
import '../features/onboarding/presentation/onboarding_screen.dart';    // Satır 21
import '../features/profile/presentation/public_profile_screen.dart';   // Satır 22
import '../features/profile/presentation/settings_screen.dart';         // Satır 23
import '../features/profile/presentation/change_email_screen.dart';     // Satır 24
import '../features/profile/presentation/change_password_screen.dart';  // Satır 25
```

Her bir import, ilgili route'un `builder`'ında kullanılacak ekran widget'ını içeri aktarır.
Proje **feature-first** (özellik öncelikli) klasör yapısı kullanır:
```
features/
  ├── auth/           → Kimlik doğrulama (giriş, kayıt)
  ├── listings/       → İlanlar (ana sayfa, ilan oluşturma, düzenleme, detay, favoriler)
  ├── chat/           → Sohbet (sohbet listesi, sohbet detayı)
  ├── map/            → Harita
  ├── profile/        → Profil (görüntüleme, düzenleme, ayarlar)
  ├── notifications/  → Bildirimler
  └── onboarding/     → Karşılama ekranı
```

Her özelliğin kendi `presentation/` klasörü vardır ve ekran widget'ları orada bulunur.

---

#### Satır 27–28: routerProvider Tanımı

**Satır 27:**
```dart
final routerProvider = Provider<GoRouter>((ref) {
```

Bu satır, `GoRouter` tipinde bir Riverpod `Provider` tanımlar.

- `final` → Bu değişken bir kez atanır ve değiştirilemez
- `routerProvider` → Provider'ın adı. Başka dosyalardan erişmek için bu isim kullanılır
- `Provider<GoRouter>` → Bu provider bir `GoRouter` nesnesi üretir
- `(ref)` → Riverpod'un sağladığı referans nesnesi. Diğer provider'ları okumak/dinlemek için kullanılır
- `ref` üzerinden `ref.watch()` ve `ref.read()` çağrıları yapılabilir

**Neden provider olarak tanımlıyoruz?**

Çünkü router'ın auth durumuna tepki vermesi gerekir. `ref.watch(authStateProvider)` ile
auth durumunu dinleriz. Auth durumu değiştiğinde (giriş/çıkış), provider otomatik olarak
yeniden oluşturulur ve yeni bir `GoRouter` nesnesi üretilir. Bu sayede router her zaman
güncel auth durumunu bilir.

---

**Satır 28:**
```dart
final authState = ref.watch(authStateProvider);
```

`authStateProvider`'ı dinler ve mevcut auth durumunu alır.

- `ref.watch()` → Provider'ı dinler. Değer değiştiğinde bu provider da yeniden oluşturulur
- `authStateProvider` → `StreamProvider<User?>` tipindedir. Firebase auth durum akışını dinler
- `authState` → `AsyncValue<User?>` tipindedir. Üç durumdan birinde olabilir:
  - `AsyncLoading` → Henüz yüklenmedi (bekleniyor)
  - `AsyncData(User)` → Kullanıcı giriş yapmış
  - `AsyncError` → Bir hata oluştu
- `authState.value` → `User?` tipindedir. Kullanıcı varsa `User` nesnesi, yoksa `null`

---

#### Satır 30–31: GoRouter Başlangıç Konfigürasyonu

**Satır 30:**
```dart
return GoRouter(
```

`GoRouter` sınıfından bir nesne oluşturur. Bu, uygulamanın tüm navigasyon sistemini yöneten
ana nesnedir. Aldığı parametreler:
- `initialLocation` → Uygulama açıldığında ilk gidilecek URL
- `redirect` → Her navigasyondan önce çalışan yönlendirme fonksiyonu
- `routes` → Uygulamanın route haritası (tüm sayfa tanımları)

---

**Satır 31:**
```dart
initialLocation: '/onboarding',
```

Uygulama ilk açıldığında `/onboarding` URL'sine gidileceğini belirtir.
Ancak `redirect` fonksiyonu buna engel olabilir. Eğer kullanıcı daha önce
onboarding'i tamamlamışsa, `redirect` onu `/login`'e yönlendirecektir.

**Neden `/onboarding`?**

Uygulama varsayılan olarak yeni kullanıcıları karşılama ekranıyla başlatmak ister.
Eğer kullanıcı daha önce onboarding'i görmüşse, `redirect` onu login'e yönlendirir.
Bu bir "varsayılan + override" (geçersiz kılma) kalıbıdır.

---

#### Satır 32–46: redirect Fonksiyonu

Bu, projenin en kritik bölümlerinden biridir. Her navigasyon işleminden önce çalışır.

**Satır 32:**
```dart
redirect: (context, state) async {
```

- `redirect` → GoRouter'ın yönlendirme fonksiyonu. Her route değişikliğinde çağrılır
- `context` → `BuildContext` — Widget ağacındaki konum
- `state` → `GoRouterState` — Hedef route hakkında bilgi içerir
- `async` → Bu fonksiyon asenkron (zaman alıcı) işlemler yapabilir (SharedPreferences okuma gibi)
- Dönüş tipi: `Future<String?>` — String dönerse yönlendirme yapılır, null dönerse normal devam eder

---

**Satır 33:**
```dart
final prefs = await SharedPreferences.getInstance();
```

`SharedPreferences`'ın tekil (singleton) örneğini alır. Bu, uygulamanın local deposudur.
Anahtar-değer çiftleri olarak veri saklar. Uygulama kapatılsa bile veriler kalır.
`await` anahtar sözcüğü, bu işlemin tamamlanmasını bekler çünkü dosya I/O işlemidir.

---

**Satır 34–35:**
```dart
final onboardingCompleted =
    prefs.getBool('onboarding_completed') ?? false;
```

`'onboarding_completed'` anahtarıyla kaydedilmiş boolean değeri okur.
Eğer bu anahtar daha önce kaydedilmemişse `null` döner.
`?? false` ifadesi (null coalescing operatörü), sol taraf `null` ise sağ tarafı kullanır.
Yani ilk kez açılan uygulamada `onboardingCompleted = false` olur.

**Ne zaman `true` olur?** Kullanıcı onboarding ekranındaki "Başla" veya "Atla" butonuna
bastığında, uygulama şu kodu çalıştırır:
```dart
await prefs.setBool('onboarding_completed', true);
```

---

**Satır 36:**
```dart
final isLoggedIn = authState.value != null;
```

Kullanıcının giriş yapıp yapmadığını kontrol eder.
- `authState.value` bir `User?` (nullable User) tipindedir
- Eğer kullanıcı giriş yaptıysa → `User` nesnesi vardır → `!= null` → `true`
- Eğer kullanıcı giriş yapmadıysa → `null` → `!= null` → `false`

---

**Satır 37–38:**
```dart
final isAuthRoute = state.matchedLocation == '/login' ||
    state.matchedLocation == '/register';
```

Kullanıcının gitmek istediği sayfanın bir kimlik doğrulama sayfası olup olmadığını kontrol eder.

- `state.matchedLocation` → Gitmek istenen URL (tam eşleşme yolu)
- `'/login'` veya `'/register'` ise → `isAuthRoute = true`

**Neden buna ihtiyacımız var?** Çünkü giriş yapmamış bir kullanıcı zaten login sayfasındaysa,
tekrar login'e yönlendirme yapmamalıyız (sonsuz döngü oluşur). Aynı şekilde, giriş yapmış
bir kullanıcı login sayfasına erişmeye çalışıyorsa, onu ana sayfaya yönlendirmeliyiz.

---

**Satır 39:**
```dart
final isOnboarding = state.matchedLocation == '/onboarding';
```

Kullanıcının onboarding sayfasında olup olmadığını kontrol eder.
Bu, onboarding tamamlandıktan sonra kullanıcıyı login'e yönlendirmek için kullanılır.

---

**Satır 41:**
```dart
if (!onboardingCompleted) return '/onboarding';
```

**KURAL 1:** Onboarding tamamlanmamışsa, nereye gitmek istenirse istensin onboarding'e yönlendir.

Bu en yüksek öncelikli kuraldır. Kullanıcı henüz karşılama ekranını görmemişse,
başka hiçbir sayfaya erişemez. Uygulama her açıldığında bu kontrol yapılır.

Örnek senaryolar:
- İlk kez açılıyorsa → `/onboarding`'e yönlendir
- SharedPreferences silinmişse → `/onboarding`'e yönlendir

---

**Satır 42:**
```dart
if (onboardingCompleted && isOnboarding) return '/login';
```

**KURAL 2:** Onboarding tamamlanmış ama kullanıcı somehow onboarding sayfasındaysa → login'e yönlendir.

Bu, kullanıcının tarayıcıda URL'yi elle `/onboarding` olarak değiştirmesi veya
bir deep link ile onboarding'e gelmesi durumunda çalışır. Onboarding'i zaten görmüş
bir kullanıcıya tekrar gösterilmemelidir.

---

**Satır 43:**
```dart
if (!isLoggedIn && !isAuthRoute) return '/login';
```

**KURAL 3:** Kullanıcı giriş yapmamış ve login/register dışında bir sayfaya gitmek istiyorsa → login'e yönlendir.

Bu, uygulamanın ana güvenlik kuralıdır. Korunan tüm sayfalar (ana sayfa, profil, sohbet vb.)
için geçerlidir. `!isAuthRoute` kontrolü olmadan sonsuz döngü oluşurdu:
→ `/login`'e yönlendir → redirect tekrar çalışır → `/login`'e yönlendir → ...

---

**Satır 44:**
```dart
if (isLoggedIn && isAuthRoute) return '/';
```

**KURAL 4:** Kullanıcı giriş yapmış ve login/register sayfasına erişmek istiyorsa → ana sayfaya yönlendir.

Zaten giriş yapmış bir kullanıcının tekrar login sayfasını görmesi mantıksızdır.
Örnek senaryo: Kullanıcı giriş yaptıktan sonra tarayıcıda geri butonuna basarsa,
login sayfasına dönmek yerine ana sayfada kalmalıdır.

---

**Satır 45:**
```dart
return null;
```

**KURAL 5:** Yukarıdaki hiçbir koşul sağlanmıyorsa → yönlendirme yapma, istenen sayfayı göster.

Bu, normal kullanım durumudur. Kullanıcı giriş yapmış ve geçerli bir sayfaya gitmek istiyorsa,
hiçbir müdahale yapılmaz.

---

#### Satır 47–167: routes Tanımları

Bu bölümde uygulamanın tüm route haritası tanımlanır.

**Satır 47:**
```dart
routes: [
```

`routes` parametresi, `List<RouteBase>` tipindedir. Tüm route tanımları bu liste içinde yer alır.
Her eleman bir `GoRoute` veya `StatefulShellRoute` olabilir.

---

**Satır 48–51: Onboarding Route**
```dart
GoRoute(
  path: '/onboarding',
  builder: (context, state) => const OnboardingScreen(),
),
```

| Satır | Açıklama |
|-------|----------|
| 48 | `GoRoute` — tekil bir route tanımı başlatır |
| 49 | `path: '/onboarding'` — URL `/onboarding` olduğunda bu route eşleşir |
| 50 | `builder` — bu URL'ye gidildiğinde `OnboardingScreen` widget'ı gösterilir |
| 51 | Kapanış parantezi ve virgül |

`const` anahtar sözcüğü: `OnboardingScreen`'in yapıcı metodu (constructor) sabit olduğundan,
Flutter bu widget'ı derleme zamanında oluşturur ve performansı artırır.

---

**Satır 52–55: Login Route**
```dart
GoRoute(
  path: '/login',
  builder: (context, state) => const LoginScreen(),
),
```

Giriş ekranı route'u. Kullanıcı e-posta ve şifre ile giriş yapar.
Bu route hem `redirect` tarafından hem de kullanıcı tarafından doğrudan erişilebilir.
Giriş yapıldıktan sonra `context.go('/')` ile ana sayfaya geçilir.

---

**Satır 56–59: Register Route**
```dart
GoRoute(
  path: '/register',
  builder: (context, state) => const RegisterScreen(),
),
```

Kayıt ekranı route'u. Yeni kullanıcı hesap oluşturur.
Login ekranındaki "Hesabın yok mu? Kayıt ol" linkinden `context.push('/register')` ile erişilir.

---

**Satır 60–66: Public Profile Route (Parametreli)**
```dart
GoRoute(
  path: '/user/:id',
  builder: (context, state) {
    final id = state.pathParameters['id']!;
    return PublicProfileScreen(userId: id);
  },
),
```

**Detaylı açıklama:**

| Satır | Açıklama |
|-------|----------|
| 61 | `path: '/user/:id'` — `:id` dinamik bir path parametresidir |
| 62 | `builder` fonksiyonu başlar — `context` ve `state` parametreleri alır |
| 63 | `state.pathParameters['id']!` — URL'den `id` değerini çıkarır. `!` operatörü null olmadığını garanti eder |
| 64 | `PublicProfileScreen(userId: id)` — Çıkarılan `id` değeri ekrana parametre olarak gönderilir |
| 65 | Builder fonksiyonu kapanışı |
| 66 | GoRoute kapanışı |

**Örnek URL eşleşmeleri:**

| URL | `id` değeri | Gösterilen ekran |
|-----|-------------|-------------------|
| `/user/abc123` | `'abc123'` | `PublicProfileScreen(userId: 'abc123')` |
| `/user/user_xyz_789` | `'user_xyz_789'` | `PublicProfileScreen(userId: 'user_xyz_789')` |

Bu route, bir ilanın sahibinin profiline tıklandığında veya sohbetteki kullanıcı
profili linkine tıklandığında kullanılır.

---

**Satır 67–70: Notifications Route**
```dart
GoRoute(
  path: '/notifications',
  builder: (context, state) => const NotificationScreen(),
),
```

Bildirimler ekranı. Kullanıcının tüm bildirimleri (yeni mesaj, ilan beğenisi, takas teklifi vb.)
burada listelenir. Bildirim ikonuna tıklandığında `context.push('/notifications')` ile açılır.

---

**Satır 71–74: Settings Route**
```dart
GoRoute(
  path: '/settings',
  builder: (context, state) => const SettingsScreen(),
),
```

Ayarlar ekranı. Kullanıcı uygulama ayarlarını (tema, dil, bildirim tercihleri vb.) buradan yönetir.
Profil ekranındaki ayarlar ikonundan `context.push('/settings')` ile erişilir.

---

#### Satır 75–144: StatefulShellRoute (Ana Uygulama Kabuğu)

Bu, projenin en karmaşık ve en önemli route yapısıdır. Bottom Navigation Bar'lı
5 sekmeli ana ekranı tanımlar.

**Satır 75:**
```dart
StatefulShellRoute.indexedStack(
```

`StatefulShellRoute.indexedStack`, her branch'in (sekmeye karşılık gelen dal) state'ini
ayrı ayrı koruyan bir shell route oluşturur. `IndexedStack` widget'ı gibi çalışır:
tüm branch'ler bellekte tutulur ama sadece aktif olanı görünür olur.

**Neden `.indexedStack`?** Çünkü sekmeler arası geçişte her sekmenin state'ini
(kaydırma konumu, form verileri, arama sonuçları) korumak istiyoruz.

---

**Satır 76–78: Shell Builder**
```dart
builder: (context, state, navigationShell) {
  return MainScreen(navigationShell: navigationShell);
},
```

| Parametre | Tip | Açıklama |
|-----------|-----|----------|
| `context` | `BuildContext` | Widget ağacı konumu |
| `state` | `GoRouterState` | Mevcut route durumu |
| `navigationShell` | `StatefulNavigationShell` | Branch'leri (sekmeleri) yöneten kabuk |

`MainScreen`, tüm sekmeleri saran ana widget'tır. Bottom Navigation Bar'ı içerir
ve `navigationShell`'i gövde (body) olarak gösterir. `navigationShell` widget olarak
kullanıldığında, aktif branch'in (sekmeye karşılık gelen ekranın) içeriğini gösterir.

---

**Satır 79:**
```dart
branches: [
```

`branches` parametresi, her bir sekmeyi temsil eden `StatefulShellBranch` listesini alır.
Takaş uygulamasında 5 branch (sekme) vardır:

| Branch Index | Path | Sekme Adı | Ekran |
|--------------|------|-----------|-------|
| 0 | `/` | Keşfet | `HomeScreen` |
| 1 | `/map` | Harita | `MapScreen` |
| 2 | `/create-listing` | İlan Oluştur | `CreateListingScreen` |
| 3 | `/chats` | Sohbet | `ChatListScreen` |
| 4 | `/profile` | Profil | `ProfileScreen` |

---

**Satır 80–96: Branch 0 — Keşfet Sekmesi**
```dart
StatefulShellBranch(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'listing/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return ListingDetailScreen(listingId: id);
          },
        ),
      ],
    ),
  ],
),
```

**Detaylı açıklama:**

| Satır | Açıklama |
|-------|----------|
| 80 | `StatefulShellBranch` — İlk branch (index 0) başlar |
| 81 | `routes: [` — Bu branch'in route listesi |
| 82 | `GoRoute(` — Ana sayfa route'u |
| 83 | `path: '/'` — Kök URL. Uygulamanın ana sayfası |
| 84 | `builder: ... HomeScreen()` — Ana sayfa ekranı. İlanları grid/liste olarak gösterir |
| 85 | `routes: [` — Ana sayfanın alt route'ları (nested) |
| 86 | `GoRoute(` — İlan detay alt route'u |
| 87 | `path: 'listing/:id'` — Tam yol: `/listing/:id` (baştaki `/` yok çünkü nested) |
| 88 | `builder: (context, state) {` — Builder fonksiyonu |
| 89 | `state.pathParameters['id']!` — URL'den ilan ID'sini çıkarır |
| 90 | `ListingDetailScreen(listingId: id)` — İlan detay ekranını ID ile oluşturur |
| 91–93 | Kapanış parantezleri |
| 94 | `GoRoute` kapanışı (ana sayfa) |
| 95 | `StatefulShellBranch` routes kapanışı |
| 96 | Branch kapanışı |

**Hiyerarşi:**

```
Branch 0 (Keşfet)
  └── /              → HomeScreen
        └── /listing/:id  → ListingDetailScreen
```

**Kullanım:**
- Ana sayfayı açmak: `context.go('/')` veya uygulama başlangıcı
- İlan detayını açmak: `context.push('/listing/abc123')`
- İlan detayından geri dönmek: `context.pop()`

**Neden `push` kullanılıyor?** Çünkü ilan detayından ana sayfaya geri dönmek istiyoruz.
Eğer `go` kullanılsaydı, ana sayfa yığını temizlenirdi ve geri dönemeyiz.

---

**Satır 97–104: Branch 1 — Harita Sekmesi**
```dart
StatefulShellBranch(
  routes: [
    GoRoute(
      path: '/map',
      builder: (context, state) => const MapScreen(),
    ),
  ],
),
```

Harita sekmesi. Kullanıcıların yakınlardaki takas ilanlarını harita üzerinde görmesini sağlar.
Mapbox kullanılarak harita render edilir.

| Satır | Açıklama |
|-------|----------|
| 97 | `StatefulShellBranch` — İkinci branch (index 1) |
| 98 | `routes: [` — Bu branch'in route listesi |
| 99 | `GoRoute(` — Harita route'u |
| 100 | `path: '/map'` — Harita URL'si |
| 101 | `builder: ... MapScreen()` — Mapbox harita ekranı |
| 102–103 | GoRoute kapanışı |
| 104 | Branch kapanışı |

Bu branch'in alt route'u yoktur. Harita ekranı tek başına bir ekrandır.

---

**Satır 105–112: Branch 2 — İlan Oluştur Sekmesi (Ortadaki + Butonu)**
```dart
StatefulShellBranch(
  routes: [
    GoRoute(
      path: '/create-listing',
      builder: (context, state) => const CreateListingScreen(),
    ),
  ],
),
```

İlan oluşturma sekmesi. Bu, Bottom Navigation Bar'daki ortadaki yuvarlak (+) butonuna
karşılık gelir. Kullanıcı yeni bir takas ilanı oluşturmak için bu ekrana gelir.

| Satır | Açıklama |
|-------|----------|
| 105 | `StatefulShellBranch` — Üçüncü branch (index 2) |
| 106 | `routes: [` — Route listesi |
| 107 | `GoRoute(` — İlan oluşturma route'u |
| 108 | `path: '/create-listing'` — İlan oluşturma URL'si |
| 109 | `builder: ... CreateListingScreen()` — Yeni ilan form ekranı |
| 110–111 | GoRoute kapanışı |
| 112 | Branch kapanışı |

**Not:** Bu branch, `_CenterButton` widget'ı tarafından temsil edilir (satır 215–218).
Diğer sekmeler `_NavItem` kullanırken, bu sekme özel bir yuvarlak buton kullanır.

---

**Satır 113–120: Branch 3 — Sohbet Sekmesi**
```dart
StatefulShellBranch(
  routes: [
    GoRoute(
      path: '/chats',
      builder: (context, state) => const ChatListScreen(),
    ),
  ],
),
```

Sohbet sekmesi. Kullanıcının tüm aktif sohbetlerini listeler.
Her sohbet, başka bir kullanıcıyla yapılan takas görüşmesini temsil eder.

| Satır | Açıklama |
|-------|----------|
| 113 | `StatefulShellBranch` — Dördüncü branch (index 3) |
| 114 | `routes: [` — Route listesi |
| 115 | `GoRoute(` — Sohbet listesi route'u |
| 116 | `path: '/chats'` — Sohbet listesi URL'si |
| 117 | `builder: ... ChatListScreen()` — Sohbet listesi ekranı |
| 118–119 | GoRoute kapanışı |
| 120 | Branch kapanışı |

Sohbet listesindeki bir sohbete tıklandığında, ayrı bir route olan `/chat/:id`'ye
`context.push('/chat/${chat.id}')` ile gidilir (bu route shell dışındadır, satır 152–158).

---

**Satır 121–143: Branch 4 — Profil Sekmesi**
```dart
StatefulShellBranch(
  routes: [
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
      routes: [
        GoRoute(
          path: 'edit',
          builder: (context, state) => const EditProfileScreen(),
        ),
        GoRoute(
          path: 'my-listings',
          builder: (context, state) => const MyListingsScreen(),
        ),
        GoRoute(
          path: 'favorites',
          builder: (context, state) => const FavoritesScreen(),
        ),
      ],
    ),
  ],
),
```

Profil sekmesi. En fazla alt route'a sahip branch'dir.

| Satır | Açıklama |
|-------|----------|
| 121 | `StatefulShellBranch` — Beşinci branch (index 4) |
| 122 | `routes: [` — Route listesi |
| 123 | `GoRoute(` — Profil route'u |
| 124 | `path: '/profile'` — Profil URL'si |
| 125 | `builder: ... ProfileScreen()` — Profil ekranı |
| 126 | `routes: [` — Profil alt route'ları |
| 127–130 | `path: 'edit'` → Tam yol: `/profile/edit` → `EditProfileScreen` |
| 131–134 | `path: 'my-listings'` → Tam yol: `/profile/my-listings` → `MyListingsScreen` |
| 135–138 | `path: 'favorites'` → Tam yol: `/profile/favorites` → `FavoritesScreen` |
| 139–141 | Alt route listesi kapanışı |
| 142 | Branch routes kapanışı |
| 143 | Branch kapanışı |

**Hiyerarşi:**

```
Branch 4 (Profil)
  └── /profile                → ProfileScreen
        ├── /profile/edit           → EditProfileScreen
        ├── /profile/my-listings    → MyListingsScreen
        └── /profile/favorites      → FavoritesScreen
```

**Kullanım:**
- Profil düzenleme: `context.push('/profile/edit')`
- İlanlarım: `context.push('/profile/my-listings')`
- Favorilerim: `context.push('/profile/favorites')`

---

**Satır 144: StatefulShellRoute Kapanışı**
```dart
),
```

`StatefulShellRoute` tanımı burada sona erer. Tüm branch'ler ve shell builder yukarıda
tanımlanmıştır. Bu noktada GoRouter, 5 sekmeli ana ekranı tamamen bilmektedir.

---

**Satır 145–151: Edit Listing Route (Parametreli)**
```dart
GoRoute(
  path: '/edit-listing/:id',
  builder: (context, state) {
    final id = state.pathParameters['id']!;
    return EditListingScreen(listingId: id);
  },
),
```

İlan düzenleme ekranı. Bu route `StatefulShellRoute` dışındadır (top-level route).
Neden? Çünkü ilan düzenleme, Bottom Navigation Bar ile gösterilmesi gereken bir ekran değildir.
Kullanıcı kendi ilanlarını görüntülerken "Düzenle" butonuna basar ve bu ekrana gelir.

**Kullanım:** `context.push('/edit-listing/${listing.id}')`

**URL örneği:** `/edit-listing/abc123` → `EditListingScreen(listingId: 'abc123')`

---

**Satır 152–158: Chat Detail Route (Parametreli)**
```dart
GoRoute(
  path: '/chat/:id',
  builder: (context, state) {
    final id = state.pathParameters['id']!;
    return ChatDetailScreen(chatId: id);
  },
),
```

Sohbet detay ekranı. İki kullanıcı arasındaki mesajlaşma ekranıdır.
Bu route da `StatefulShellRoute` dışındadır. Neden? Çünkü sohbet detayı tam ekran
görüntülenmelidir ve Bottom Navigation Bar gösterilmemelidir.

**Kullanım:** `context.push('/chat/${chat.id}')`

**URL örneği:** `/chat/chat_xyz_789` → `ChatDetailScreen(chatId: 'chat_xyz_789')`

---

**Satır 159–162: Change Email Route**
```dart
GoRoute(
  path: '/change-email',
  builder: (context, state) => const ChangeEmailScreen(),
),
```

E-posta değiştirme ekranı. Kullanıcı hesabının e-posta adresini değiştirmek istediğinde
bu ekrana gelir. Ayarlar veya profil düzenleme ekranından erişilir.

**Kullanım:** `context.push('/change-email')`

---

**Satır 163–166: Change Password Route**
```dart
GoRoute(
  path: '/change-password',
  builder: (context, state) => const ChangePasswordScreen(),
),
```

Şifre değiştirme ekranı. Kullanıcı mevcut şifresini değiştirmek istediğinde bu ekrana gelir.
Ayarlar ekranından erişilir.

**Kullanım:** `context.push('/change-password')`

---

**Satır 167: routes Listesi Kapanışı**
```dart
],
```

Tüm route tanımlarının listesi burada sona erer.

---

**Satır 168: GoRouter Kapanışı**
```dart
);
```

`GoRouter` nesnesinin yapıcı metodu burada sona erer.

---

**Satır 169: routerProvider Kapanışı**
```dart
});
```

`routerProvider` tanımı burada sona erer. Artık bu provider, tam yapılandırılmış
bir `GoRouter` nesnesi üretir.

---

#### Satır 171–241: MainScreen Widget'ı

`MainScreen`, uygulamanın ana ekranıdır. Bottom Navigation Bar'ı ve `StatefulNavigationShell`'i
bir arada tutan `ConsumerWidget`'tır.

**Satır 171:**
```dart
class MainScreen extends ConsumerWidget {
```

- `class MainScreen` — `MainScreen` adında yeni bir sınıf tanımlar
- `extends ConsumerWidget` — Riverpod'un `ConsumerWidget`'ından kalıtım alır.
  `ConsumerWidget`, normal `StatelessWidget` gibi çalışır ama ek olarak `ref` parametresi
  sağlar. `ref` üzerinden provider'ları dinleyebilir/okuyabiliriz.

---

**Satır 172:**
```dart
final StatefulNavigationShell navigationShell;
```

`navigationShell` alanı (field) tanımlar. Bu, `StatefulShellRoute`'un builder'ından
gelen kabuk nesnesidir. Aktif branch'in (sekmeye karşılık gelen ekranın) içeriğini
gösterir ve sekme geçişlerini yönetir.

---

**Satır 174:**
```dart
const MainScreen({super.key, required this.navigationShell});
```

Yapıcı metod (constructor). `required` anahtar sözcüğü, `navigationShell` parametresinin
zorunlu olduğunu belirtir. `super.key` üst sınıfa (ConsumerWidget) key değerini iletir.

---

**Satır 177:**
```dart
Widget build(BuildContext context, WidgetRef ref) {
```

`ConsumerWidget`'ın `build` metodu. Normal `StatelessWidget.build`'den farklı olarak
ek bir `WidgetRef ref` parametresi alır. Bu parametre, provider'lara erişmek için kullanılır.

---

**Satır 178:**
```dart
final unreadCount = ref.watch(unreadCountProvider);
```

Okunmamış mesaj sayısını dinler. `unreadCountProvider`, sohbet controller dosyasında
tanımlı bir provider'dır. Tüm sohbetlerdeki okunmamış mesaj sayısını hesaplar.
Bu değer sohbet sekmesindeki kırmızı badge'de gösterilir.

`ref.watch` kullanıldığı için, okunmamış mesaj sayısı değiştiğinde widget otomatik
olarak yeniden oluşturulur ve badge güncellenir.

---

**Satır 179:**
```dart
final currentIndex = navigationShell.currentIndex;
```

Mevcut aktif sekmenin index'ini alır. Bu değer, Bottom Navigation Bar'da hangi
sekmenin vurgulanacağını (highlight) belirler.

| currentIndex | Sekme |
|--------------|-------|
| 0 | Keşfet |
| 1 | Harita |
| 2 | İlan Oluştur |
| 3 | Sohbet |
| 4 | Profil |

---

**Satır 181–183: Scaffold Yapısı**
```dart
return Scaffold(
  body: navigationShell,
  extendBody: true,
```

- `Scaffold` — Flutter'ın temel sayfa iskelet widget'ı
- `body: navigationShell` — Sayfanın gövdesi olarak `navigationShell` kullanılır.
  Bu, aktif branch'in (sekmeye karşılık gelen ekranın) içeriğini gösterir
- `extendBody: true` — Gövde, Bottom Navigation Bar'ın arkasına uzanır.
  Bu, yarı saydam veya gölgeli nav bar'larda güzel bir görünüm sağlar

---

**Satır 184–194: Bottom Navigation Bar Konteyneri**
```dart
bottomNavigationBar: Container(
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.surface,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 20,
        offset: const Offset(0, -4),
      ),
    ],
  ),
```

- `bottomNavigationBar` — Scaffold'un alt navigasyon bar'ı
- `Container` — Dekorasyon ve boyut verilebilen konteyner widget
- `color: colorScheme.surface` — Arka plan rengi (temaya uygun)
- `boxShadow` — Üst kenarda hafif bir gölge efekti. `blurRadius: 20` → gölge 20 birim bulanıklaşır,
  `offset: Offset(0, -4)` → gölge 4 birim yukarı kayar, `alpha: 0.06` → çok hafif (%6 opaklık)

Bu tasarım, Bottom Navigation Bar'ı sayfanın gövdesinden ayıran ince, zarif bir gölge oluşturur.

---

**Satır 195–197: SafeArea ve Padding**
```dart
child: SafeArea(
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
```

- `SafeArea` — Cihazın çentik (notch), durum çubuğu vb. alanlarından kaçınarak
  içeriği güvenli alanda gösterir
- `Padding` — İçeriğe boşluk ekler. Yatayda 8, dikeyde 6 birim padding

---

**Satır 198–234: Sekme Öğeleri (Row)**
```dart
child: Row(
  mainAxisAlignment: MainAxisAlignment.spaceAround,
  children: [
```

- `Row` — Yatay düzen widget'ı. Beş sekme öğesini yan yana dizer
- `MainAxisAlignment.spaceAround` — Öğeler arası eşit boşluk bırakır
  (ilk ve son öğe ile kenarlar arasında da boşluk)

---

**Satır 201–207: Keşfet Sekmesi (Index 0)**
```dart
_NavItem(
  icon: Icons.explore_outlined,
  activeIcon: Icons.explore,
  label: 'Keşfet',
  isActive: currentIndex == 0,
  onTap: () => navigationShell.goBranch(0),
),
```

- `_NavItem` — Özel navigasyon öğesi widget'ı (satır 243–330'da tanımlı)
- `icon` → Pasif durumda gösterilen ikon (outlined/beyaz kenarlıklı)
- `activeIcon` → Aktif durumda gösterilen ikon (dolu)
- `label` → Sekmenin altındaki metin etiketi
- `isActive` → Bu sekme aktif mi? `currentIndex == 0` karşılaştırması
- `onTap` → Tıklandığında `navigationShell.goBranch(0)` çağrılır, 0 numaralı branch'e geçilir

---

**Satır 208–214: Harita Sekmesi (Index 1)**
```dart
_NavItem(
  icon: Icons.map_outlined,
  activeIcon: Icons.map,
  label: 'Harita',
  isActive: currentIndex == 1,
  onTap: () => navigationShell.goBranch(1),
),
```

Harita sekmesi. Yapı Keşfit sekmesiyle aynı, sadece ikonlar ve label farklı.
`goBranch(1)` → 1 numaralı branch'e (Harita) geçilir.

---

**Satır 215–218: İlan Oluştur Butonu (Index 2 — Orta Buton)**
```dart
_CenterButton(
  isActive: currentIndex == 2,
  onTap: () => navigationShell.goBranch(2),
),
```

Ortadaki yuvarlak (+) butonu. `_NavItem` yerine `_CenterButton` widget'ı kullanılır.
Bu buton özel bir tasarıma sahiptir: yuvarlak, renkli, gölgeli ve daha büyük.
Detaylı açıklama satır 332–368'de.

---

**Satır 219–226: Sohbet Sekmesi (Index 3)**
```dart
_NavItem(
  icon: Icons.chat_outlined,
  activeIcon: Icons.chat,
  label: 'Sohbet',
  isActive: currentIndex == 3,
  badge: unreadCount > 0 ? '$unreadCount' : null,
  onTap: () => navigationShell.goBranch(3),
),
```

Sohbet sekmesi. Diğerlerinden farklı olarak `badge` parametresi de vardır:
- `unreadCount > 0` → Okunmamış mesaj varsa
- `'$unreadCount'` → Sayıyı string'e çevirip badge olarak gösterir (ör: "3")
- `null` → Okunmamış mesaj yoksa badge gösterilmez

Bu, sohbet ikonunun sağ üst köşesinde kırmızı bir daire içinde sayı gösterir.

---

**Satır 227–233: Profil Sekmesi (Index 4)**
```dart
_NavItem(
  icon: Icons.person_outline_rounded,
  activeIcon: Icons.person_rounded,
  label: 'Profil',
  isActive: currentIndex == 4,
  onTap: () => navigationShell.goBranch(4),
),
```

Profil sekmesi. Son sekme (index 4). Kullanıcı profil bilgilerini, ilanlarını,
favorilerini ve ayarlarını buradan yönetir.

---

#### Satır 243–330: _NavItem Widget'ı

Bu, Bottom Navigation Bar'daki normal sekme öğelerini temsil eden özel widget'tır.

**Satır 243–258: Sınıf Tanımı ve Alanlar**
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
```

Alt çizgi (`_`) ile başlayan sınıflar Dart'ta **private** (özel) sınıflardır.
Sadece aynı dosya içinde erişilebilirler.

| Alan | Tip | Açıklama |
|------|-----|----------|
| `icon` | `IconData` | Pasif durum ikonu |
| `activeIcon` | `IconData` | Aktif durum ikonu |
| `label` | `String` | Sekme etiket metni |
| `isActive` | `bool` | Sekme aktif mi? |
| `badge` | `String?` | Opsiyonel bildirim sayısı (nullable) |
| `onTap` | `VoidCallback` | Tıklama geri çağırma fonksiyonu |

---

**Satır 261–264: Tema Renkleri**
```dart
final colorScheme = Theme.of(context).colorScheme;
final activeColor = colorScheme.primary;
final inactiveColor = colorScheme.outline;
```

- `colorScheme` — Uygulamanın Material 3 renk şeması
- `activeColor` → Aktif sekme rengi (primary — genellikle mavi/yeşil)
- `inactiveColor` → Pasif sekme rengi (outline — genellikle gri)

---

**Satır 266–268: GestureDetector**
```dart
return GestureDetector(
  behavior: HitTestBehavior.opaque,
  onTap: onTap,
```

- `GestureDetector` — Dokunma hareketlerini algılayan widget
- `behavior: HitTestBehavior.opaque` — Widget'ın tüm alanı dokunma algılar
  (boş alanlara dokunulsa bile onTap tetiklenir)
- `onTap: onTap` — Tıklandığında dışarıdan verilen `onTap` fonksiyonunu çağırır

---

**Satır 269–271: Boyut ve Kolon Düzeni**
```dart
child: SizedBox(
  width: 60,
  child: Column(
    mainAxisSize: MainAxisSize.min,
```

- `SizedBox(width: 60)` — Sabit 60 piksel genişlik
- `Column` → Dikey düzen (ikon üstte, metin altta)
- `MainAxisSize.min` → Sadece içeriğin gerektirdiği kadar yer kaplar

---

**Satır 275–313: İkon ve Badge**
```dart
SizedBox(
  height: 28,
  width: 28,
  child: Stack(
    clipBehavior: Clip.none,
    children: [
      Center(
        child: Icon(
          isActive ? activeIcon : icon,
          color: isActive ? activeColor : inactiveColor,
          size: 24,
        ),
      ),
      if (badge != null)
        Positioned(
          right: -4,
          top: -2,
          child: Container(
            ...
          ),
        ),
    ],
  ),
),
```

- `Stack` → Üst üste bindirilmiş widget'lar. İkon ve badge üst üste yerleştirilir
- `clipBehavior: Clip.none` → Badge, Stack sınırlarının dışına taşabilir
- `Icon` → Aktifse `activeIcon`, değilse `icon` gösterilir
- `if (badge != null)` → Badge varsa kırmızı daire içinde sayı gösterilir
- `Positioned(right: -4, top: -2)` → Badge ikonun sağ üst köşesine yerleştirilir
- Badge `Container`'ı → Kırmızı arka plan (`colorScheme.error`), yuvarlatılmış köşeler,
  minimum 16x16 boyut kısıtlaması
- Badge metni → Beyaz renk, 10 punto font, kalın (w700)

---

**Satır 315–324: Etiket Metni**
```dart
Text(
  label,
  style: TextStyle(
    fontSize: 11,
    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
    color: isActive ? activeColor : inactiveColor,
    letterSpacing: -0.2,
  ),
),
```

- Sekmenin altındaki metin (ör: "Keşfet", "Harita", "Sohbet", "Profil")
- Aktifse kalın (`w700`), değilse orta (`w500`)
- Aktifse primary renk, değilse gri renk
- `letterSpacing: -0.2` → Harfler arası biraz daraltılmış

---

#### Satır 332–368: _CenterButton Widget'ı

Bu, Bottom Navigation Bar'daki ortadaki yuvarlak (+) butonunu temsil eden özel widget'tır.

**Satır 332–336: Sınıf Tanımı**
```dart
class _CenterButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _CenterButton({required this.isActive, required this.onTap});
```

`_NavItem`'den daha basittir. Sadece `isActive` ve `onTap` parametreleri vardır.
`icon`, `label`, `badge` parametreleri yoktur çünkü bu butonun tasarımı sabittir.

---

**Satır 339–340: Tema Rengi**
```dart
final colorScheme = Theme.of(context).colorScheme;
```

---

**Satır 342–365: Buton Tasarımı**
```dart
return GestureDetector(
  onTap: onTap,
  child: AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    curve: Curves.easeInOut,
    height: 48,
    width: 56,
    decoration: BoxDecoration(
      color: isActive ? colorScheme.onPrimary : colorScheme.primary,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: colorScheme.primary.withValues(alpha: 0.35),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Icon(
      Icons.add_rounded,
      color: isActive ? colorScheme.primary : Colors.white,
      size: 28,
    ),
  ),
);
```

**Detaylı açıklama:**

| Satır/Öğe | Açıklama |
|-----------|----------|
| `AnimatedContainer` | Dekorasyon değişikliklerini animasyonlu yapar. Aktif/pasif geçişi yumuşak olur |
| `duration: 200ms` | Animasyon 200 milisaniye sürer |
| `curve: Curves.easeInOut` | Başlangıç ve bitiş yavaş, orta hızlı animasyon eğrisi |
| `height: 48, width: 56` | Buton boyutu — diğer sekme öğelerinden daha büyük |
| `color` (aktif) | `colorScheme.onPrimary` — Açık renk (buton invert olmuş gibi) |
| `color` (pasif) | `colorScheme.primary` — Ana renk |
| `borderRadius: 16` | Yuvarlatılmış köşeler (tam daire değil, yumuşak kare) |
| `boxShadow` | Primary renkli, %35 opaklıkta, 12 birim bulanık, 4 birim aşağı kaymış gölge |
| `Icon: Icons.add_rounded` | + (artı) ikonu, yuvarlatılmış köşeli |
| `icon color` (aktif) | `colorScheme.primary` — Ana renk |
| `icon color` (pasif) | `Colors.white` — Beyaz |

**Görsel görünüm:**

Pasif durum:
```
┌─────────────┐
│             │  → Yuvarlak primary renkli buton
│     +       │  → Beyaz + ikonu
│             │  → Altında gölge
└─────────────┘
```

Aktif durum:
```
┌─────────────┐
│             │  → Yuvarlak açık renkli buton (invert)
│     +       │  → Primary renkli + ikonu
│             │
└─────────────┘
```

---

## 7. Takaş Projesi — main.dart Tam Dosya İncelemesi

Bu bölümde projenin `lib/main.dart` dosyasının her satırını inceleyeceğiz.

### 7.1 Tam Dosya İçeriği

```dart
 1: import 'dart:ui';
 2: import 'package:flutter/material.dart';
 3: import 'package:flutter_riverpod/flutter_riverpod.dart';
 4: import 'package:firebase_core/firebase_core.dart';
 5: import 'package:flutter_dotenv/flutter_dotenv.dart';
 6: import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
 7: import 'package:firebase_messaging/firebase_messaging.dart';
 8: import 'package:firebase_crashlytics/firebase_crashlytics.dart';
 9: import 'package:firebase_auth/firebase_auth.dart';
10: import 'package:intl/date_symbol_data_local.dart';
11: import 'firebase_options.dart';
12: import 'app/router.dart';
13: import 'app/theme.dart';
14: import 'core/providers/theme_provider.dart';
15: import 'features/notifications/data/notification_service.dart';
16: 
17: @pragma('vm:entry-point')
18: Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
19:   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
20: }
21: 
22: void main() async {
23:   WidgetsFlutterBinding.ensureInitialized();
24: 
25:   await dotenv.load(fileName: ".env");
26: 
27:   String mapboxToken = dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
28:   MapboxOptions.setAccessToken(mapboxToken);
29: 
30:   await Firebase.initializeApp(
31:     options: DefaultFirebaseOptions.currentPlatform,
32:   );
33: 
34:   await initializeDateFormatting('tr_TR', null);
35: 
36:   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
37: 
38:   FlutterError.onError = (errorDetails) {
39:     FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
40:   };
41: 
42:   PlatformDispatcher.instance.onError = (error, stack) {
43:     FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
44:     return true;
45:   };
46: 
47:   runApp(
48:     const ProviderScope(
49:       child: TakashApp(),
50:     ),
51:   );
52: }
53: 
54: class TakashApp extends ConsumerStatefulWidget {
55:   const TakashApp({super.key});
56: 
57:   @override
58:   ConsumerState<TakashApp> createState() => _TakashAppState();
59: }
60: 
61: class _TakashAppState extends ConsumerState<TakashApp> {
62:   @override
63:   void initState() {
64:     super.initState();
65:     WidgetsBinding.instance.addPostFrameCallback((_) {
66:       ref.read(notificationServiceProvider).initialize();
67:     });
68: 
69:     FirebaseAuth.instance.authStateChanges().listen((user) {
70:       ref.read(notificationServiceProvider).onUserChanged(user);
71:     });
72:   }
73: 
74:   @override
75:   Widget build(BuildContext context) {
76:     final router = ref.watch(routerProvider);
77: 
78:     return MaterialApp.router(
79:       title: 'Takaş',
80:       theme: AppTheme.lightTheme,
81:       darkTheme: AppTheme.darkTheme,
82:       themeMode: ref.watch(themeModeProvider),
83:       routerConfig: router,
84:       debugShowCheckedModeBanner: false,
85:     );
86:   }
87: }
```

### 7.2 Satır Satır Açıklama

#### Satır 1–15: Import Bölümü

**Satır 1:** `import 'dart:ui';` — Dart'ın UI çekirdek kütüphanesi. `PlatformDispatcher` (satır 42) için gereklidir.

**Satır 2:** `import 'package:flutter/material.dart';` — Flutter Material Design widget'ları.

**Satır 3:** `import 'package:flutter_riverpod/flutter_riverpod.dart';` — Riverpod state management.
`ProviderScope` (satır 48), `ConsumerStatefulWidget` (satır 54), `ConsumerState` (satır 61),
`ConsumerStatefulWidget`, `ref.watch`, `ref.read` için gereklidir.

**Satır 4:** `import 'package:firebase_core/firebase_core.dart';` — Firebase çekirdek başlatma.
`Firebase.initializeApp()` (satır 30) için gereklidir.

**Satır 5:** `import 'package:flutter_dotenv/flutter_dotenv.dart';` — `.env` dosyasından
ortam değişkenlerini okumak için. `dotenv.load()` (satır 25) ve `dotenv.env` (satır 27).

**Satır 6:** `import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';` — Mapbox harita SDK'sı.
`MapboxOptions.setAccessToken()` (satır 28) için gereklidir.

**Satır 7:** `import 'package:firebase_messaging/firebase_messaging.dart';` — Firebase push bildirimleri.
`FirebaseMessaging.onBackgroundMessage()` (satır 36) ve `RemoteMessage` (satır 18) için.

**Satır 8:** `import 'package:firebase_crashlytics/firebase_crashlytics.dart';` — Firebase crash raporlama.
`FirebaseCrashlytics.instance.recordFlutterFatalError()` (satır 39) için.

**Satır 9:** `import 'package:firebase_auth/firebase_auth.dart';` — Firebase kimlik doğrulama.
`FirebaseAuth.instance.authStateChanges()` (satır 69) için.

**Satır 10:** `import 'package:intl/date_symbol_data_local.dart';` — Tarih biçimlendirme yerelleştirmesi.
Türkçe tarih gösterimi için `initializeDateFormatting('tr_TR', null)` (satır 34).

**Satır 11:** `import 'firebase_options.dart';` — FlutterFire CLI tarafından oluşturulan
Firebase yapılandırma dosyası. Platforma göre (Android, iOS, Web) doğru Firebase ayarlarını sağlar.

**Satır 12:** `import 'app/router.dart';` — **GoRouter yapılandırma dosyası.**
`routerProvider` (satır 76) buradan gelir. Bu, navigasyon sisteminin kalbidir.

**Satır 13:** `import 'app/theme.dart';` — Uygulama tema tanımları.
`AppTheme.lightTheme` ve `AppTheme.darkTheme` (satır 80–81).

**Satır 14:** `import 'core/providers/theme_provider.dart';` — Tema modu provider'ı.
`themeModeProvider` (satır 82) kullanıcının açık/koyu tema tercihini dinler.

**Satır 15:** `import 'features/notifications/data/notification_service.dart';` — Bildirim servisi.
`notificationServiceProvider` (satır 66) push bildirimlerini yönetir.

---

#### Satır 17–20: Background Message Handler

```dart
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}
```

- `@pragma('vm:entry-point')` — Dart sanal makinesine bu fonksiyonun bir giriş noktası
  olduğunu bildirir. Tree-shaking (kullanılmayan kodların silinmesi) sırasında bu
  fonksiyonun silinmesini engeller
- `_firebaseMessagingBackgroundHandler` — Uygulama arka plandayken (kapalı veya minimize)
  bildirim geldiğinde çağrılır
- `Firebase.initializeApp()` — Background context'te Firebase'in çalışması için
  yeniden başlatılması gerekir (main context'teki başlatma ayrıdır)

---

#### Satır 22–52: main Fonksiyonu

**Satır 22:** `void main() async {` — Uygulamanın giriş noktası. `async` çünkü
birden fazla asenkron başlatma işlemi yapar.

**Satır 23:** `WidgetsFlutterBinding.ensureInitialized();` — Flutter engine'inin
başlatılmasını garanti eder. `main` fonksiyonu `async` olduğu ve `await` kullandığı
için, Flutter engine'inin `runApp()` çağrılmadan önce hazır olması gerekir.
Bu satır olmadan asenkron işlemler Flutter engine henüz hazır olmadan çalışmaya çalışabilir.

**Satır 25:** `await dotenv.load(fileName: ".env");` — `.env` dosyasını okur.
Bu dosyada `MAPBOX_ACCESS_TOKEN` gibi hassas API anahtarları saklanır.
`.env` dosyası git'e commit edilmez (`.gitignore`'a eklenir).

**Satır 27–28:**
```dart
String mapboxToken = dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
MapboxOptions.setAccessToken(mapboxToken);
```

`.env` dosyasından Mapbox erişim token'ını okur ve Mapbox SDK'sına verir.
`?? ''` — Token bulunamazsa boş string kullanır (harita çalışmaz ama uygulama çökmez).

**Satır 30–32:**
```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

Firebase'i başlatır. `DefaultFirebaseOptions.currentPlatform` — Çalışılan platforma
(Android, iOS, Web) göre doğru Firebase yapılandırmasını seçer. Bu, Firebase
Console'dan alınan API anahtarlarını, proje ID'sini vb. içerir.

**Satır 34:** `await initializeDateFormatting('tr_TR', null);` — Türkçe tarih
biçimlendirmesini başlatır. Bu sayede tarihler "15 Nisan 2026" formatında gösterilir.

**Satır 36:** `FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);`
— Uygulama arka plandayken bildirim geldiğinde çalışacak handler'ı kaydeder.

**Satır 38–40:** Flutter hatalarını Firebase Crashlytics'e bildirir.
`FlutterError.onError` — Flutter framework'ü içinde oluşan hataları yakalar.

**Satır 42–45:** Dart hatalarını (Flutter dışı) Firebase Crashlytics'e bildirir.
`PlatformDispatcher.instance.onError` — Tüm Dart hatalarını yakalar.

**Satır 47–51:**
```dart
runApp(
  const ProviderScope(
    child: TakashApp(),
  ),
);
```

- `runApp()` — Flutter uygulamasını başlatır. Verilen widget'ı widget ağacının köküne yerleştirir
- `ProviderScope` — Riverpod'un en üst provider kabı (scope). Tüm provider'lar bu kapsam içinde
  tanımlanır ve yaşar. `const` ile oluşturulur çünkü durumu yoktur
- `TakashApp()` — Uygulamanın ana widget'ı (satır 54–87)

---

#### Satır 54–59: TakashApp Widget'ı

```dart
class TakashApp extends ConsumerStatefulWidget {
  const TakashApp({super.key});

  @override
  ConsumerState<TakashApp> createState() => _TakashAppState();
}
```

- `ConsumerStatefulWidget` — Riverpod'un `StatefulWidget` versiyonu.
  Hem state tutabilir hem de `ref` üzerinden provider'lara erişebilir
- `createState()` → State nesnesini oluşturur. `_TakashAppState` state sınıfı

---

#### Satır 61–72: _TakashAppState — initState

```dart
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
```

**Satır 63–67: Bildirim Servisi Başlatma**

- `initState()` — Widget oluşturulduğunda bir kez çağrılır (yaşam döngüsü metodu)
- `WidgetsBinding.instance.addPostFrameCallback` — İlk frame çizildikten sonra
  verilen fonksiyonu çalıştırır. Neden? Çünkü `initState` içinde `ref.read` kullanmak
  güvenli değildir (henüz widget ağacına eklenmemiş olabilir). Post-frame callback
  ile widget ağacının hazır olması garanti edilir
- `ref.read(notificationServiceProvider).initialize()` — Bildirim servisini başlatır
  (push bildirimleri izni, token alma vb.)

**Satır 69–71: Auth Durumu Dinleme**

- `FirebaseAuth.instance.authStateChanges().listen()` — Firebase auth durumunu dinler
- Kullanıcı giriş yaptığında veya çıkış yaptığında bu callback çalışır
- `notificationServiceProvider.onUserChanged(user)` — Bildirim servisine kullanıcı
  değişikliğini bildirir. Bu, bildirim token'ını kullanıcı hesabına bağlamak için kullanılır

---

#### Satır 74–86: _TakashAppState — build

```dart
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
```

**Satır 76:**
```dart
final router = ref.watch(routerProvider);
```

`routerProvider`'ı dinler. Bu, `lib/app/router.dart` dosyasında tanımlanan GoRouter'dır.
`ref.watch` kullanıldığı için, provider değiştiğinde widget yeniden oluşturulur.
Auth durumu değiştiğinde `routerProvider` yeniden oluşturulur ve `MaterialApp.router`
yeni router konfigürasyonuyla güncellenir.

**Satır 78:** `MaterialApp.router(` — `MaterialApp`'in router destekli versiyonu.
Normal `MaterialApp`, `home` veya `routes` parametresi alır. `MaterialApp.router` ise
`routerConfig` parametresi alır ve GoRouter ile çalışır.

| Parametre | Açıklama |
|-----------|----------|
| `title: 'Takaş'` | Uygulama adı (Android'de son uygulamalar listesinde görünür) |
| `theme: AppTheme.lightTheme` | Açık tema |
| `darkTheme: AppTheme.darkTheme` | Koyu tema |
| `themeMode: ref.watch(themeModeProvider)` | Hangi temanın aktif olacağını belirler (kullanıcı tercihi) |
| `routerConfig: router` | **GoRouter konfigürasyonu.** Tüm navigasyon bu nesne tarafından yönetilir |
| `debugShowCheckedModeBanner: false` | Sağ üstteki "DEBUG" etiketini gizler |

**Satır 83: `routerConfig: router`** — Bu satır, `main.dart` ile `router.dart` arasındaki
bağlantı noktasıdır. GoRouter'ın tüm yapılandırması (`routes`, `redirect`, `initialLocation`)
bu parametre aracılığıyla `MaterialApp`'e aktarılır.

---

## 8. Özet Akış Diyagramı

### 8.1 Uygulama Başlatma Akışı

```
main()
  │
  ├── WidgetsFlutterBinding.ensureInitialized()
  ├── dotenv.load(".env")
  ├── MapboxOptions.setAccessToken(...)
  ├── Firebase.initializeApp()
  ├── initializeDateFormatting('tr_TR')
  ├── FirebaseMessaging.onBackgroundMessage(...)
  ├── FlutterError.onError → Crashlytics
  ├── PlatformDispatcher.onError → Crashlytics
  │
  └── runApp(ProviderScope(TakashApp))
        │
        └── TakashApp.build()
              │
              ├── ref.watch(routerProvider)  ← router.dart
              │     │
              │     ├── ref.watch(authStateProvider)
              │     └── GoRouter(initialLocation, redirect, routes)
              │
              ├── ref.watch(themeModeProvider)
              │
              └── MaterialApp.router(routerConfig: router)
                    │
                    └── [GoRouter redirect çalışır]
                          │
                          ├── Onboarding tamamlanmadı mı? → /onboarding
                          ├── Onboarding tamamlanmış + /onboarding? → /login
                          ├── Giriş yapılmadı + korumalı sayfa? → /login
                          ├── Giriş yapıldı + auth sayfası? → /
                          └── Sorun yok → istenen sayfa
```

### 8.2 Route Haritası (Tam Görünüm)

```
GoRouter
│
├── /onboarding                    → OnboardingScreen
├── /login                         → LoginScreen
├── /register                      → RegisterScreen
├── /user/:id                      → PublicProfileScreen(userId)
├── /notifications                 → NotificationScreen
├── /settings                      → SettingsScreen
│
├── StatefulShellRoute (Bottom Nav)
│   ├── Branch 0: /               → HomeScreen
│   │              └── /listing/:id → ListingDetailScreen(listingId)
│   ├── Branch 1: /map            → MapScreen
│   ├── Branch 2: /create-listing → CreateListingScreen
│   ├── Branch 3: /chats          → ChatListScreen
│   └── Branch 4: /profile        → ProfileScreen
│                    ├── /profile/edit        → EditProfileScreen
│                    ├── /profile/my-listings → MyListingsScreen
│                    └── /profile/favorites   → FavoritesScreen
│
├── /edit-listing/:id              → EditListingScreen(listingId)
├── /chat/:id                      → ChatDetailScreen(chatId)
├── /change-email                  → ChangeEmailScreen
└── /change-password               → ChangePasswordScreen
```

### 8.3 Yeni Route Ekleme Rehberi

Projeye yeni bir route eklemek istediğinizde şu adımları izleyin:

**1. Ekran widget'ını oluşturun:**
```dart
// lib/features/your_feature/presentation/your_screen.dart
import 'package:flutter/material.dart';

class YourScreen extends StatelessWidget {
  const YourScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Yeni Ekran')),
    );
  }
}
```

**2. router.dart'a import ekleyin:**
```dart
import '../features/your_feature/presentation/your_screen.dart';
```

**3. Route tanımını ekleyin:**

Basit route:
```dart
GoRoute(
  path: '/your-path',
  builder: (context, state) => const YourScreen(),
),
```

Parametreli route:
```dart
GoRoute(
  path: '/your-path/:id',
  builder: (context, state) {
    final id = state.pathParameters['id']!;
    return YourScreen(itemId: id);
  },
),
```

Bottom Nav'a yeni sekme (yeni branch):
```dart
StatefulShellBranch(
  routes: [
    GoRoute(
      path: '/your-path',
      builder: (context, state) => const YourScreen(),
    ),
  ],
),
```

**4. Navigasyon çağrısını yapın:**
```dart
// Push (geri dönmek için)
context.push('/your-path');

// Go (yığını sıfırlamak için)
context.go('/your-path');

// Parametreli
context.push('/your-path/${item.id}');
```

---

> **Sonuç:** Takaş projesinde GoRouter, uygulamanın tüm navigasyon sisteminin temelidir.
> `router.dart` dosyası route haritasını, auth kontrolünü ve Bottom Navigation Bar yapısını
> tek bir yerde tanımlar. `main.dart` dosyası ise GoRouter'ı `MaterialApp.router` aracılığıyla
> Flutter'a tanıtır. Bu iki dosya birlikte çalışarak uygulamanın navigasyon sistemini oluşturur.
