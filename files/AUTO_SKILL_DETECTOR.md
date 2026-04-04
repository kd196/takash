# 🤖 Takaş — AI Otomatik Skill Seçim Sistemi

> Bu dosyayı her yeni AI sohbetinin BAŞINA yapıştır. AI, kullanıcı isteğini analiz edip doğru skill dosyasını otomatik olarak yükleyecektir.

---

## 📋 Talimat (AI için)

Sen Takaş projesinin AI geliştiricisisin. Kullanıcı bir istek gönderdiğinde:

1. **İsteği analiz et** — Hangi feature/phase ile ilgili?
2. **Doğru skill dosyasını seç** — Aşağıdaki eşleştirme tablosuna bak
3. **Skill dosyasını oku** — İlgili dosyayı oku ve bağlamı al
4. **Kodu üret** — Mevcut yapıya uygun şekilde kod üret

---

## 🔄 Otomatik Skill Eşleştirme

Kullanıcının isteğindeki **anahtar kelimelere** göre doğru skill dosyasını seç:

| Anahtar Kelimeler | Yüklenecek Skill Dosyası |
|-------------------|--------------------------|
| `auth`, `login`, `register`, `giriş`, `kayıt`, `oturum`, `sign in`, `sign up`, `google sign`, `email`, `şifre`, `password`, `theme`, `tema`, `router`, `navigation`, `onboarding`, `main.dart`, `providers`, `splash`, `renk`, `color`, `font` | `skill_faz1_infrastructure.md` |
| `ilan`, `listing`, `create listing`, `ilan oluştur`, `ilan düzenle`, `ilan sil`, `favori`, `favorite`, `kategori`, `category`, `home screen`, `listing detail`, `listing card`, `filter`, `arama`, `search`, `my listings`, `ilanlarım` | `skill_faz2_listings.md` |
| `harita`, `map`, `mapbox`, `konum`, `location`, `geofencing`, `geohash`, `marker`, `gps`, `geolocator`, `mesafe`, `distance`, `pin`, `koordinat`, `latitude`, `longitude` | `skill_faz3_map.md` |
| `chat`, `sohbet`, `mesaj`, `message`, `sendMessage`, `chat detail`, `chat list`, `resim gönder`, `image message`, `takas`, `trade`, `unread`, `okunmamış` | `skill_faz4_chat.md` |
| `puan`, `rating`, `değerlendirme`, `yıldız`, `star`, `score`, `profile`, `profil`, `edit profile`, `public profile`, `settings`, `ayarlar`, `güven`, `trust`, `ortalama puan`, `average rating` | `skill_faz5_rating.md` |
| `bildirim`, `notification`, `fcm`, `push`, `local notification`, `channel`, `token`, `unread count`, `okundu`, `temizle`, `cleanup`, `settings screen`, `ayarlar ekranı` | `skill_faz6_notifications.md` |
| `test`, `unit test`, `widget test`, `integration test`, `ci/cd`, `github actions`, `coverage`, `mock`, `fake`, `beta` | `skill_faz7_testing.md` |
| `güvenlik`, `security`, `rules`, `firestore rules`, `storage rules`, `izin`, `permission`, `yetki`, `access control`, `proguard` | `skill_security_rules.md` |
| `hata`, `error`, `exception`, `crash`, `logging`, `logger`, `crashlytics`, `try-catch`, `failure`, `türkçe hata` | `skill_error_handling.md` |
| `analytics`, `analitik`, `event`, `tracking`, `izleme`, `metrik`, `metric`, `screen view`, `log event`, `firebase analytics` | `skill_analytics.md` |
| `cloud function`, `functions`, `backend`, `server`, `trigger`, `firebase functions`, `node.js` | `skill_faz6_notifications.md` + `skill_security_rules.md` |
| `pubspec`, `paket`, `package`, `dependency`, `bağımlılık`, `flutter pub get` | `skill_faz1_infrastructure.md` |
| `widget`, `custom button`, `custom text field`, `loading`, `empty state`, `error state` | `skill_faz1_infrastructure.md` |

---

## 📁 Dosya Yolları

Tüm skill dosyaları `files/` klasöründe:

```
files/
├── PROJECT_CONTEXT.md                    # HER ZAMAN yükle
├── skill_faz1_infrastructure.md          # Faz 1: Altyapı + Auth
├── skill_faz2_listings.md                # Faz 2: İlan Yönetimi
├── skill_faz3_map.md                     # Faz 3: Harita & Konum
├── skill_faz4_chat.md                    # Faz 4: Sohbet
├── skill_faz5_rating.md                  # Faz 5: Puanlama & Güven
├── skill_faz6_notifications.md           # Faz 6: Bildirimler
├── skill_faz7_testing.md                 # Faz 7: Test & Beta
├── skill_security_rules.md               # Güvenlik Kuralları
├── skill_error_handling.md               # Hata Yönetimi
├── skill_analytics.md                    # Analitik
├── CALISMA_REHBERI.md                    # AI ile çalışma rehberi
└── DEVELOPMENT_PLAN.md                   # Geliştirme planı
```

---

## 🔄 Çalışma Akışı

```
Kullanıcı istek gönderir
    ↓
AI: PROJECT_CONTEXT.md'yi oku (HER ZAMAN)
    ↓
AI: İsteği analiz et — anahtar kelimeleri bul
    ↓
AI: Eşleştirme tablosundan doğru skill dosyasını seç
    ↓
AI: Seçilen skill dosyasını oku
    ↓
AI: Mevcut kod dosyalarını oku (ilgili feature klasöründen)
    ↓
AI: Kodu üret — mevcut yapıya uygun şekilde
    ↓
AI: Gerekirse ilgili .g.dart dosyasını güncellemeyi hatırlat (build_runner)
```

---

## ⚡ Hızlı Referans — Proje Özeti

**Ne:** Konum tabanlı mobil takas uygulaması
**Stack:** Flutter + Riverpod + GoRouter + Firebase (Firestore, Auth, Storage, FCM, Crashlytics)
**Harita:** Mapbox + geoflutterfire_plus
**Chat:** Saf Firestore (Stream Chat KULLANILMIYOR)
**Platform:** Sadece Android
**Mimari:** Feature-First Clean Architecture (data/domain/presentation)

---

## 📌 Önemli Hatırlatmalar (AI için)

1. **Stream Chat KULLANMA** — Chat sistemi Firestore ile çalışıyor
2. **Sadece Riverpod** kullan — başka state management önerme
3. **Türkçe yorum** yaz, değişken isimleri **İngilizce** olsun
4. Mevcut dosya yapısını **koru** — yeni dosya eklerken feature klasörüne ekle
5. `@riverpod` annotation'lı controller'lardan sonra `dart run build_runner` gerektiğini hatırlat
6. **Android** öncelikli — iOS kodu yazma unless explicitly requested
7. Mevcut shared widget'ları **tekrar kullan** (CustomButton, CustomTextField, LoadingIndicator, etc.)
