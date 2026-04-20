# Takaş Projesi — Tam Öğrenme Kılavuzu

## Bu Kılavuz Nedir?

Bu doküman, Takaş mobil uygulamasının **her dosyasını, her satırını, her teknolojiyi** sıfırdan açıklayan bir öğrenme rehberidir. Flutter bilgisi olmayan biri için tasarlanmıştır. Hiçbir şey özetlenmemiş, hiçbir detay atlanmamıştır.

---

## Proje Özeti

**Takaş**, bir konum tabanlı mobil takas uygulamasıdır. Kullanıcılar eşya ve yeteneklerini takas edebilir, yakınındaki insanların ilanlarını harita üzerinde görebilir, mesajlaşabilir ve teklif verebilir.

**Teknoloji Stack'i:**
- **Frontend:** Flutter (Dart dili)
- **Backend:** Firebase (Google Cloud)
- **State Management:** Riverpod
- **Navigasyon:** GoRouter
- **Harita:** Mapbox
- **Platform:** Android

---

## Okuma Sırası

Bu kılavuz **sıralı** okunmak için tasarlanmıştır. Her bölüm bir önceki üzerine inşa edilir.

| Sıra | Dosya | Konu | Tahmini Okuma Süresi |
|------|-------|------|---------------------|
| 1 | `01_flutter_dart_temelleri.md` | Flutter framework, Dart dili, widget sistemi, async/await, null safety | 45 dk |
| 2 | `02_proje_mimarisi.md` | Clean Architecture, klasör yapısı, 65 dosyanın haritası | 20 dk |
| 3 | `03_state_management_riverpod.md` | Riverpod, Provider tipleri, controller dosyaları (tam içerik) | 60 dk |
| 4 | `04_navigasyon_gorouter.md` | GoRouter, route tanımları, StatefulShellRoute (tam içerik) | 30 dk |
| 5 | `05_firebase_auth.md` | Firebase Authentication, login/register, Google Sign-In (tam içerik) | 45 dk |
| 6 | `06_firebase_firestore.md` | Firestore database, CRUD, queries, batch, security rules (tam içerik) | 60 dk |
| 7 | `07_firebase_storage_messaging.md` | Storage dosya yükleme, FCM bildirimler, local notifications (tam içerik) | 40 dk |
| 8 | `08_ui_ekranlari.md` | Tüm UI ekranları, widget ağacı, theme sistemi (tam içerik) | 90 dk |
| 9 | `09_harita_konum.md` | Mapbox harita, GPS izinleri, geolocator, geoflutterfire (tam içerik) | 40 dk |
| 10 | `10_android_build.md` | Gradle, keystore, SHA1, signing, google-services.json (tam içerik) | 30 dk |
| 11 | `11_teknik_terimler_sozlugu.md` | API, REST, OAuth, JWT, backend, frontend, token vs. | 30 dk |

**Toplam tahmini okuma süresi:** ~8 saat

---

## Proje Dosya Haritası

```
takash/
├── lib/
│   ├── main.dart                          → Uygulamanın başlangıç noktası
│   ├── firebase_options.dart              → Firebase yapılandırma sabitleri
│   │
│   ├── app/
│   │   ├── router.dart                    → Sayfa yönlendirme (GoRouter)
│   │   └── theme.dart                     → Tema renkleri, fontlar, stiller
│   │
│   ├── core/                              → Ortak kullanılan yardımcı kodlar
│   │   ├── constants/
│   │   │   ├── api_keys.dart              → API anahtarları
│   │   │   └── app_constants.dart         → Uygulama sabitleri
│   │   ├── extensions/
│   │   │   └── string_extensions.dart     → String yardımcı metotları
│   │   ├── providers/
│   │   │   ├── theme_provider.dart        → Tema değiştirici (light/dark/system)
│   │   │   └── providers.dart             → Genel provider'lar (Firebase instances)
│   │   ├── services/
│   │   │   └── settings_service.dart      → SharedPreferences wrapper
│   │   └── utils/
│   │       ├── helpers.dart               → Mesafe hesaplama, tarih formatı
│   │       └── validators.dart            → E-posta, şifre doğrulama
│   │
│   ├── features/                          → Her özellik ayrı klasörde
│   │   ├── auth/                          → Giriş/Kayış sistemi
│   │   │   ├── data/auth_repository.dart  → Firebase Auth işlemleri
│   │   │   ├── domain/user_model.dart     → Kullanıcı veri modeli
│   │   │   └── presentation/
│   │   │       ├── auth_controller.dart   → Auth state yönetimi
│   │   │       ├── login_screen.dart      → Giriş ekranı UI
│   │   │       └── register_screen.dart   → Kayıt ekranı UI
│   │   │
│   │   ├── chat/                          → Mesajlaşma sistemi
│   │   │   ├── data/chat_repository.dart  → Firestore chat CRUD
│   │   │   ├── domain/
│   │   │   │   ├── chat_model.dart        → Sohbet veri modeli
│   │   │   │   └── message_model.dart     → Mesaj veri modeli
│   │   │   └── presentation/
│   │   │       ├── chat_controller.dart   → Chat state yönetimi
│   │   │       ├── chat_detail_screen.dart→ Mesajlaşma ekranı UI
│   │   │       └── chat_list_screen.dart  → Sohbet listesi ekranı UI
│   │   │
│   │   ├── listings/                      → İlan sistemi
│   │   │   ├── data/listing_repository.dart→ Firestore ilan CRUD
│   │   │   ├── domain/
│   │   │   │   ├── listing_category.dart  → Kategori enum'ları
│   │   │   │   └── listing_model.dart     → İlan veri modeli
│   │   │   └── presentation/
│   │   │       ├── create_listing_screen.dart → İlan oluşturma UI
│   │   │       ├── edit_listing_screen.dart  → İlan düzenleme UI
│   │   │       ├── favorites_screen.dart     → Favoriler ekranı UI
│   │   │       ├── home_screen.dart          → Ana sayfa (Keşfet) UI
│   │   │       ├── listing_detail_screen.dart→ İlan detay UI
│   │   │       ├── listings_controller.dart  → İlan state yönetimi
│   │   │       ├── my_listings_screen.dart   → İlanlarım ekranı UI
│   │   │       └── widgets/
│   │   │           ├── filter_sheet.dart     → Filtre bottom sheet
│   │   │           ├── listing_card.dart     → İlan kartı widget
│   │   │           └── manage_listing_card.dart→ Yönetim kartı widget
│   │   │
│   │   ├── map/                           → Harita sistemi
│   │   │   ├── data/location_service.dart → GPS ve izin işlemleri
│   │   │   ├── domain/geo_point_model.dart→ Konum veri modeli
│   │   │   └── presentation/
│   │   │       ├── map_controller.dart    → Harita state yönetimi
│   │   │       └── map_screen.dart        → Harita ekranı UI
│   │   │
│   │   ├── notifications/                 → Bildirim sistemi
│   │   │   ├── data/notification_service.dart → FCM + local notifications
│   │   │   ├── domain/notification_model.dart → Bildirim veri modeli
│   │   │   └── presentation/
│   │   │       ├── notification_controller.dart→ Bildirim state
│   │   │       └── notification_screen.dart   → Bildirimler ekranı UI
│   │   │
│   │   ├── onboarding/                    → Karşılama ekranı
│   │   │   └── presentation/
│   │   │       └── onboarding_screen.dart → İlk açılış ekranı UI
│   │   │
│   │   └── profile/                       → Profil sistemi
│   │       ├── data/
│   │       │   ├── profile_repository.dart→ Kullanıcı profili CRUD
│   │       │   └── rating_repository.dart → Değerlendirme CRUD
│   │       ├── domain/rating_model.dart   → Değerlendirme modeli
│   │       └── presentation/
│   │           ├── change_email_screen.dart   → E-posta değiştirme UI
│   │           ├── change_password_screen.dart→ Şifre değiştirme UI
│   │           ├── edit_profile_screen.dart   → Profil düzenleme UI
│   │           ├── profile_controller.dart    → Profil state yönetimi
│   │           ├── profile_screen.dart        → Profil ekranı UI
│   │           ├── public_profile_screen.dart → Herkese açık profil UI
│   │           ├── rating_screen.dart         → Değerlendirme ekranı UI
│   │           └── settings_screen.dart       → Ayarlar ekranı UI
│   │
│   └── shared/                            → Paylaşılan bileşenler
│       ├── models/base_model.dart         → Temel model sınıfı
│       ├── services/
│       │   ├── firebase_service.dart      → Firebase başlatma yardımcısı
│       │   └── storage_service.dart       → Dosya depolama yardımcısı
│       └── widgets/
│           ├── custom_button.dart         → Özel buton widget
│           ├── custom_text_field.dart     → Özel metin alanı widget
│           ├── empty_state_widget.dart    → Boş durum widget
│           ├── error_state_widget.dart    → Hata durum widget
│           └── loading_indicator.dart     → Yükleme göstergesi widget
│
├── android/                               → Android yerel yapılandırma
│   ├── app/
│   │   ├── build.gradle.kts              → Uygulama build ayarları
│   │   ├── google-services.json          → Firebase yapılandırma dosyası
│   │   └── src/main/AndroidManifest.xml  → Uygulama izinleri ve tanımları
│   ├── build.gradle.kts                  → Root Gradle ayarları
│   ├── settings.gradle.kts               → Plugin ve repository ayarları
│   └── gradle.properties                 → JVM ayarları, Mapbox token
│
├── pubspec.yaml                           → Proje bağımlılıkları
├── .env                                   → Gizli anahtarlar (API key'ler)
├── firestore.rules                        → Firestore güvenlik kuralları
├── storage.rules                          → Storage güvenlik kuralları
└── firebase.json                          → Firebase CLI yapılandırması
```

---

## Kullanılan Teknolojiler ve Versiyonları

### Dart & Flutter Paketleri (pubspec.yaml'dan)

| Paket | Versiyon | Ne İşe Yarar |
|-------|----------|--------------|
| `flutter_riverpod` | ^2.6.1 | State (durum) yönetimi — UI'ın veri ile senkronize kalmasını sağlar |
| `go_router` | ^14.6.1 | Sayfa yönlendirme — hangi URL'de hangi ekranın gösterileceğini belirler |
| `firebase_core` | ^3.6.0 | Firebase'i başlatır — diğer Firebase servislerinin ön koşulu |
| `firebase_auth` | ^5.3.1 | Kullanıcı girişi/kaydı — e-posta, Google ile giriş |
| `google_sign_in` | ^6.2.1 | Google hesabı ile OAuth giriş |
| `cloud_firestore` | ^5.4.4 | Bulut veritabanı — ilanlar, sohbetler, kullanıcılar burada saklanır |
| `firebase_storage` | ^12.3.4 | Bulut dosya depolama — fotoğraflar burada saklanır |
| `firebase_messaging` | ^15.1.3 | Push bildirimler — FCM (Firebase Cloud Messaging) |
| `firebase_crashlytics` | ^4.1.3 | Çökme raporlama — uygulama çökerse rapor gönderir |
| `mapbox_maps_flutter` | ^2.4.0 | Harita gösterimi — Mapbox SDK |
| `geolocator` | ^13.0.2 | GPS konum alma — kullanıcının enlem/boylamını verir |
| `geoflutterfire_plus` | ^0.0.17 | Coğrafi sorgu — "5km içindeki ilanlar" gibi sorgular |
| `image_picker` | ^1.1.2 | Kamera/galeri fotoğraf seçme |
| `image_cropper` | ^8.0.2 | Fotoğraf kırpma |
| `cached_network_image` | ^3.4.1 | Fotoğraf önbellekleme — tekrar indirmeden gösterir |
| `uuid` | ^4.5.1 | Benzersiz ID üretme |
| `flutter_dotenv` | ^5.2.1 | .env dosyasından gizli anahtar okuma |
| `shared_preferences` | ^2.3.3 | Basit yerel depolama (tema tercihi vb.) |
| `flutter_local_notifications` | ^17.2.3 | Yerel bildirim gösterme (sistem panelinde) |
| `google_fonts` | ^6.2.1 | Google Fonts kullanımı (Plus Jakarta Sans) |
| `share_plus` | ^12.0.1 | Sistem paylaşım menüsü |
| `url_launcher` | ^6.3.0 | Harici URL açma (tarayıcı, e-posta vb.) |
| `intl` | ^0.19.0 | Tarih/sayı formatlama (Türkçe) |

---

## Nasıl Okunmalı?

1. **Sırayla oku** — Her bölüm bir önceki bölümün bilgilerini kullanır
2. **Kodu takip et** — Her dosya yolunda gerçek dosyayı aç, satırları karşılaştır
3. **Tekrar oku** — İlk okumada her şeyi anlamak normal değil
4. **Deney yap** — Küçük değişiklikler yapıp sonuçları gözlemle
