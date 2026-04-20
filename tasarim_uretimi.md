# Takaş Uygulaması - Tasarım Üretim Raporu

## 1. Uygulama Özeti

**Takaş** - Konum tabanlı takas/als-Veriş platformu
- Flutter + Riverpod + GoRouter
- Firebase (Auth, Firestore, Storage, Messaging)
- Mapbox haritalar, Stream Chat
- Mevcut tema: Yeşil (#1B8C3A) + Sarı (#FFB300) + Grafik/Gri

---

## 2. Renk Paleti

### Ana Tema (Yeşil-Gri - Default)
| Renk Adı | Hex | Kullanım |
|---------|-----|----------|
| primary | #1B8C3A | Ana butonlar, aktif öğeler |
| primaryDark | #14692D | Pressed state |
| primaryLight | #E8F5E9 | Arka plan vurguları |
| accent | #FFB300 | İkinci vurgu, yıldızlar |
| surfaceLight | #F8FAF8 | Scaffold arka plan |
| textPrimary | #1A1A2E | Ana metin |
| textSecondary | #6B7280 | İkincil metin |
| textTertiary | #9CA3AF | Hint metin |
| divider | #F0F0F0 | Ayrıştırıcı çizgiler |
| error | #EF4444 | Hata durumları |
| success | #22C55E | Başarılı durumlar |

### İstisna Kurallar (Kuraldan Sapmalar)
| Alan | Kullanılacak Renk | Gerekçe |
|------|-------------------|---------|
| Favoriler | #EF4444 (Kırmızı) | Yeşil kalp absürt olur, kullanıcı beklentisi |
| Favori-active | #EF4444 | Active heart - standart kırmızı |
| Favori-border | #6B7280 (gri) | Inactive heart - gri outline |
| Hata/Delete | #EF4444 | Error icon - mevcut error rengi |
| Başarılı/Onay | #22C55E | Success - mevcut success |
| Yıldızlar | #FFB300 (amber) | Rating - mevcut accent |

---

## 3. Buton Tasarımları

### 3.1 CustomButton Widget (Özelleştirilebilir)
**Konum:** `lib/shared/widgets/custom_button.dart`

**Mevcut Kullanım (38+ yer):**
- edit_profile_screen.dart
- login_screen.dart
- register_screen.dart
- settings_screen.dart
- home_screen.dart
- listing_detail_screen.dart
- Ve daha fazlası...

**Yeni Tasarım Stili:**
- Material 3 Elevated/Outlined base
- Custom padding (horizontal: 24, vertical: 14)
- Border radius: 14px
- Loading spinner: CircularProgressIndicator
- Icon desteği

**Variant'lar:**
| Variant | Dolgu | Yazı Rengi | Kenar |
|--------|------|-----------|------|
| primary (default) | #1B8C3A | beyaz | yok |
| outlined | şeffaf | #1B8C3A | 1.5px #1B8C3A |
| accent | #FFB300 | beyaz | yok |
| danger | #EF4444 | beyaz | yok |

---

### 3.2 ElevatedButton (Theme'de)
**Konum:** `lib/app/theme.dart:105-117`

**Yeni Tasarım:**
- Background: primary (#1B8C3A)
- Foreground: beyaz
- Padding: horizontal 24, vertical 14
- Radius: 14px
- Elevation: 0 (flat)
- Shadow: yok

---

### 3.3 OutlinedButton (Theme'de)
**Konum:** `lib/app/theme.dart:119-129`

**Yeni Tasarım:**
- Background: şeffaf
- Foreground: primary
- Border: 1.5px primary
- Radius: 14px

---

### 3.4 TextButton (Theme'de)
**Konum:** `lib/app/theme.dart:131-137`

**Yeni Tasarım:**
- Foreground: primary
- Font weight: w600
- Font size: 14

---

## 4. Icon Tasarımları

### 4.1 Özel Icon Seti (171 icon kullanımı tespit edildi)

#### Navigation Icons
| Alan | Icon | Önerilen Tasarım |
|------|------|-----------------|
| Geri | arrow_back_rounded | Mevcut rounded variant |
| İleri | chevron_right | Mevcut |
| Menü | menu_rounded | Mevcut |
| Kapat | close_rounded | Mevcut |

#### Action Icons
| Alan | Icon | Önerilen Tasarım |
|------|------|-----------------|
| **Favori (aktif)** | **favorite** | **#EF4444 (KIRMIZI)** |
| **Favori (pasif)** | **favorite_border** | **#6B7280 (GRI)** |
| Sil | delete_outline | #EF4444 |
| Düzenle | edit_rounded / edit | Mevcut |
| Paylaş | share_rounded | Mevcut |

#### Form Icons
| Alan | Icon | Önerilen Tasarım |
|------|------|-----------------|
| Kullanıcı | person_outline | Mevcut |
| E-posta | email_outlined | Mevcut |
| Şifre | lock_outline | Mevcut |
| Göster | visibility_outlined | Mevcut |
| Gizle | visibility_off_outlined | Mevcut |

#### Listing Icons
| Alan | Icon | Önerilen Tasarım |
|------|------|-----------------|
| Takas | swap_horiz_rounded | Mevcut - primary |
| Konum | location_on_rounded | Mevcut |
| Fotoğraf | photo_library | Mevcut |
| Kamera | camera_alt | Mevcut |
| Resim yok | image_not_supported | Mevcut |

#### Profile Icons
| Alan | Icon | Önerilen Tasarım |
|------|------|-----------------|
| Profil | person_rounded | Mevcut |
| Ayarlar | settings_rounded | Mevcut |
| Bildirimler | notifications_none_rounded | Mevcut |
| İlanlarım | inventory_2_rounded | Mevcut |
| Mağaza | storefront_outlined | Mevcut |

#### Map Icons
| Alan | Icon | Önerilen Tasarım |
|------|------|-----------------|
| Lokasyonum | my_location | Mevcut |
| Konum kapalı | location_off | Mevcut |
| Harita konum | location_on | Mevcut |

#### Rating/Quality Icons
| Alan | Icon | Önerilen Tasarım |
|------|------|-----------------|
| **Yıldız** | **star / star_rounded** | **#FFB300 (AMBAR)** |
| Chat | chat_bubble_outline | Mevcut |

---

## 5. İstisna Kural Listesi

### Kuraldan Sapacak Alanlar
| # | Yer | Mevcut | Yeni | Gerekçe |
|---|-----|--------|-----|--------|
| 1 | Favori ikonu (aktif) | green | #EF4444 | Kırmızı kalp standart |
| 2 | Favori ikonu (pasif) | outlined | grey | Gri outline |
| 3 | Error/delete | mevcut | #EF4444 | Tutarlı |
| 4 | Rating yıldız | amber | #FFB300 | Tutarlı |
| 5 | Başarılı durum | green | #22C55E | Tutarlı |

---

## 6. Yapılacak Değişiklikler

### Öncelik Sırası

#### P0 - Kritik
1. `CustomButton` widget'ını yeniden tasarla
2. Theme'deki Elevated/Outlined/TextButton stillerini güncelle
3. Favori icon renklerini değiştir (#EF4444 ve #6B7280)

#### P1 - Önemli
4. CustomTextField tasarım güncelleme
5. ListingCard favorite icon rengi

#### P2 - İsteğe Bağlı
6. Loading indicator renkleri
7. Error state widget renkleri

---

## 7. AI Promptları (Tasarım Üretimi için)

### Notion/Simai İçin Promptlar

#### Buton Tasarımı
```
Modern minimalist button design, rounded corners 14px, flat design without shadow, 
green primary color #1B8C3A, white text, clean edges, 
Flutter Material 3 widget design
```

#### Icon Seti
```
Minimalist icon set, line icons, rounded style, 
green primary color #1B8C3A, consistent stroke width,
modern UI icons for mobile app
```

#### Favori Kalp İconu (İstisna)
```
Red heart icon, favorite icon, filled heart #EF4444, 
outline heart #6B7280, minimalist line style,
iOS and Android compatible
```

#### Yıldız İconu
```
Gold star icon, amber color #FFB300, rating star,
filled and outline variants, minimalist design
```

---

## 8. Etkilenecek Dosyalar

### Doğrudan Değiştirilecek
| Dosya | Değişiklik |
|-------|-----------|
| lib/app/theme.dart | Elevated/Outlined/TextButton theme |
| lib/shared/widgets/custom_button.dart | CustomButton widget |
| lib/shared/widgets/custom_text_field.dart | TextField styling |
| lib/features/listings/presentation/widgets/listing_card.dart | Favorite icon color |

### Dolaylı Etkilenecek (Theme üzerinden)
Tüm ElevatedButton, OutlinedButton, TextButton kullanımları otomatik güncellenecek.

---

## 9. Özet

### Yapılacaklar
- [x] Analiz tamamlandı
- [ ] CustomButton yeniden tasarlanacak
- [ ] Theme buton stilleri güncellenecek
- [ ] Favori icon renkleri düzeltilecek
- [ ] İstisna kurallar uygulanacak

### Değişmeyecekler
- Ana renk paleti (#1B8C3A, #FFB300)
- Tema yapısı (Material 3)
- Font (Inter Google Fonts)
- Border radius değerleri

### Yeni Eklenen İstisnalar
- Favori aktif: #EF4444 (kırmızı)
- Favori pasif: #6B7280 (gri)