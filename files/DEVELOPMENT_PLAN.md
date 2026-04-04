# 📋 Takaş — Geliştirme Planı

> Bu dosya projenin yol haritasıdır. Her tamamlanan görevi [x] ile işaretle.

---

## FAZ 1 — Temel Altyapı & Auth (Tahmini: 2 Hafta)

### 1.1 Proje Kurulumu
- [x ] Flutter projesi oluştur (`flutter create takash`)
- [x ] `pubspec.yaml`'a temel paketleri ekle
- [x ] Firebase projesi oluştur (console.firebase.google.com)
- [x ] `flutterfire configure` ile bağla
- [x ] GoRouter ile navigation kur
- [x ] Riverpod ile state management kur
- [x ] Tema ve renk sistemi oluştur (`app/theme.dart`)
- [x ] Klasör yapısını oluştur

### 1.2 Firebase Auth
- [x ] Google ile giriş
- [x ] E-posta / şifre ile giriş
- [x ] Telefon numarası ile giriş
- [x ] Çıkış yapma
- [x ] Auth state listener (oturum açık mı kontrolü)
- [x ] Firestore'a kullanıcı profili kaydet (ilk girişte)

### 1.3 Kullanıcı Profili
- [x] Profil görüntüleme ekranı
- [x] Profil düzenleme (isim, bio, fotoğraf)
- [x] Firebase Storage'a profil fotoğrafı yükleme
- [x] Diğer kullanıcıların profilini görüntüleme


**FAZ 1 Tamamlandı mı?** [evet ]

---

## FAZ 2 — İlan Yönetimi (Tahmini: 2 Hafta)

### 2.1 İlan Oluşturma
- [x] İlan oluşturma formu (başlık, açıklama, kategori)
- [x] Çoklu fotoğraf yükleme (Firebase Storage)
- [x] "Karşılığında ne istiyorum" alanı
- [ ] İlan önizlemesi
- [x] Firestore'a kaydetme

### 2.2 İlan Listeleme
- [x] Ana sayfa ilan listesi
- [x] Kategori filtresi
- [x] Arama fonksiyonu
- [x] İlan kartı tasarımı
- [ ] Sonsuz scroll (pagination)

### 2.3 İlan Detay
- [x] Fotoğraf carousel
- [x] İlan bilgileri
- [x] İlan sahibinin profili (mini kart)
- [ ] "Teklif Ver" butonu
- [ ] İlanı favorilere ekleme

### 2.4 İlan Yönetimi (Sahip için)
- [x] Kendi ilanlarımı görüntüle (Aktif / Diğer sekmeleri ile)
- [x] İlan düzenleme (EditListingScreen)
- [x] İlan silme (ManageListingCard içinden)
- [x] İlan durumu değiştirme (aktif/rezerve/tamamlandı)

**FAZ 2 Tamamlandı mı?** [Kısmen - UX İyileştirmeleri Yapıldı]

---

## FAZ 3 — Konum & Harita (Tahmini: 2 Hafta)

### 3.1 Mapbox Kurulumu
- [ ] Mapbox SDK Flutter paketi ekle
- [ ] API key yapılandırması
- [ ] Temel harita görüntüleme

### 3.2 Konum Servisleri
- [ ] Kullanıcı konumunu al (geolocator paketi)
- [ ] Konum izni yönetimi
- [ ] İlan oluştururken konum seçme (haritadan pin at)
- [ ] Firestore'a GeoPoint + geohash kaydet

### 3.3 Geofencing & Filtreleme
- [ ] Geohash hesaplama fonksiyonu
- [ ] 5 km ve 10 km yarıçaplı sorgular
- [ ] Ana sayfada sadece yakın ilanları göster
- [ ] Mesafe bilgisini ilan kartında göster

### 3.4 Harita Ekranı
- [ ] Yakın ilanları haritada göster (marker'lar)
- [ ] Marker'a tıklayınca ilan özeti
- [ ] Yarıçap ayarlama (kullanıcı 5-10 km seçebilir)

**FAZ 3 Tamamlandı mı?** [ ]

---

## FAZ 4 — Chat Sistemi (Tahmini: 1.5 Hafta)

### 4.1 Stream Chat Kurulumu
- [ ] Stream Chat Flutter SDK ekle
- [ ] Stream dashboard'dan API key al
- [ ] Kullanıcı token üretimi (Firebase Cloud Function)
- [ ] Stream'e kullanıcı kaydı

### 4.2 Chat Fonksiyonları
- [ ] Yeni sohbet başlatma (ilan sahibine teklif ver)
- [ ] Sohbet listesi ekranı
- [ ] Sohbet detay ekranı (mesajlaşma)
- [ ] Fotoğraf gönderme
- [ ] "Yazıyor..." göstergesi
- [ ] Okundu bilgisi

**FAZ 4 Tamamlandı mı?** [ ]

---

## FAZ 5 — Puanlama & Güven (Tahmini: 1 Hafta)

### 5.1 Takas Tamamlama
- [ ] Takas tamamlandı butonu (her iki taraf onaylamalı)
- [ ] İlan durumu "tamamlandı" olarak güncelle

### 5.2 Puanlama Sistemi
- [ ] Takas sonrası puanlama ekranı (1-5 yıldız + yorum)
- [ ] Puanı Firestore'a kaydet
- [ ] Kullanıcı ortalama puanını güncelle (Cloud Function)
- [ ] Profilde puanları göster

**FAZ 5 Tamamlandı mı?** [ ]

---

## FAZ 6 — Bildirimler & Son Dokunuşlar (Tahmini: 1 Hafta)

- [ ] Firebase Cloud Messaging (FCM) kurulumu
- [ ] Yeni mesaj bildirimi
- [ ] Yeni teklif bildirimi
- [ ] Takas tamamlandı bildirimi
- [ ] Uygulama ikonu ve splash screen
- [ ] Onboarding ekranları
- [ ] Boş durum ekranları (hiç ilan yok, vs.)
- [ ] Hata yönetimi (internet bağlantısı yok, vs.)

**FAZ 6 Tamamlandı mı?** [ ]

---

## FAZ 7 — Test & Beta (Tahmini: 2 Hafta)

- [ ] Firebase Test Lab ile cihaz testleri
- [ ] Performans optimizasyonu
- [ ] Güvenlik kuralları (Firestore Security Rules)
- [ ] Beta kullanıcı grubu oluştur (10–20 kişi)
- [ ] Geri bildirim topla ve düzelt
- [ ] App Store & Play Store hazırlığı

**FAZ 7 Tamamlandı mı?** [ ]

---

## 📦 pubspec.yaml — Kullanılacak Paketler

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1
  
  # Navigation
  go_router: ^14.x.x
  
  # Firebase
  firebase_core: ^3.x.x
  firebase_auth: ^5.x.x
  cloud_firestore: ^5.x.x
  firebase_storage: ^12.x.x
  firebase_messaging: ^15.x.x
  cloud_functions: ^5.x.x
  
  # Mapbox
  mapbox_maps_flutter: ^2.x.x
  geolocator: ^13.x.x
  
  # Stream Chat
  stream_chat_flutter: ^9.x.x
  
  # Utilities
  image_picker: ^1.x.x
  cached_network_image: ^3.x.x
  intl: ^0.19.x
  uuid: ^4.x.x

dev_dependencies:
  riverpod_generator: ^2.x.x
  build_runner: ^2.x.x
```

> ⚠️ Paket eklerken her zaman pub.dev'den güncel versiyonu kontrol et!
