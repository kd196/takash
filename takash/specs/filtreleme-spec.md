# Filtreleme Özellik Spesifikasyonu

## 1. Kullanıcı Hikayesi

Kullanıcı, keşfet ekranında ilanları hızlıca bulmak için; kategori, konum (mesafe), arama terimi, ilan durumu ve tarih aralığına göre filtreleyebilmeli.

---

## 2. Etkilenen Dosyalar

- DEĞİŞECEK: `lib/features/listings/presentation/home_screen.dart` — Filtre UI'su yeniden dizayn edilecek
- DEĞİŞECEK: `lib/features/listings/presentation/widgets/filter_sheet.dart` — Gelişmiş filtre seçenekleri
- DEĞİŞECEK: `lib/features/listings/presentation/listings_controller.dart` — Yeni provider'lar eklenecek
- DEĞİŞECEK: `lib/features/listings/domain/listing_model.dart` — `updatedAt` alanı eklenecek
- YENİ: `lib/features/listings/presentation/widgets/filter_chip_bar.dart` — Yeniden kullanılabilir filtre chip barı
- YENİ: `lib/features/listings/presentation/widgets/active_filters_banner.dart` — Aktif filtreler bannerı

---

## 3. Veri Katmanı

### 3.1 Mevcut Model (Güncelleme)

ListingModel'e `updatedAt` alanı zaten var ama Firestore'a yazılmıyor:

```dart
// listing_model.dart — Güncellenecek
class ListingModel {
  // ... mevcut alanlar ...
  DateTime? updatedAt; // Yeni: Son güncelleme zamanı
}
```

### 3.2 Yeni Firestore Field

Mevcut collection'da değişiklik gerekmiyor; `updatedAt` zaten modelde var, sadece `toJson()`'a eklenecek.

### 3.3 Yeni Provider State

```dart
// listings_controller.dart — Eklenecek provider'lar

/// Arama yarıçapı (km) — 1-100 km
final distanceFilterProvider = StateProvider<double>((ref) => 50.0);

/// İlan durumu filtresi — active, traded, all
final statusFilterProvider = StateProvider<ListingStatusFilter>((ref) => ListingStatusFilter.active);

/// Tarih aralığı — bugün, bu hafta, bu ay, hepsi
final dateFilterProvider = StateProvider<DateFilter>((ref) => DateFilter.all);

/// Sıralama — en yeni, en eski, yakında, uzak
final sortByProvider = StateProvider<SortBy>((ref) => SortBy.newest);

/// Enum'lar
enum ListingStatusFilter { active, traded, all }
enum DateFilter { today, thisWeek, thisMonth, all }
enum SortBy { newest, oldest, nearest, farthest }
```

---

## 4. Provider / State Değişiklikleri

### 4.1 Yeni Provider'lar

| Provider | Tip | Açıklama |
|----------|-----|----------|
| `distanceFilterProvider` | `StateProvider<double>` | Arama mesafesi (km) |
| `statusFilterProvider` | `StateProvider<ListingStatusFilter>` | İlan durumu |
| `dateFilterProvider` | `StateProvider<DateFilter>` | Tarih aralığı |
| `sortByProvider` | `StateProvider<SortBy>` | Sıralama |
| `activeFiltersProvider` | `Provider<List<String>>` | Aktif filtreleri sayan computed provider |

### 4.2 Mevcut Provider'lar

Etkilenecek provider'lar:
- `filteredListingsProvider` — Yeni filtreler eklenecek
- `nearbyListingsProvider` — `distanceFilterProvider` kullanacak
- `categoryFilterProvider` — Mevcut, değişmez
- `searchQueryProvider` — Mevcut, değişmez

### 4.3 filteredListingsProvider Güncellemesi

```dart
final filteredListingsProvider = Provider<AsyncValue<List<ListingModel>>>((ref) {
  final listingsAsync = ref.watch(allListingsProvider);
  // ... mevcut filtreler (kategori, arama, myListings) ...

  // YENİ: statusFilter
  final statusFilter = ref.watch(statusFilterProvider);
  if (statusFilter != ListingStatusFilter.all) {
    filtered = filtered.where((l) => l.status == statusFilter.listingStatus).toList();
  }

  // YENİ: dateFilter
  final dateFilter = ref.watch(dateFilterProvider);
  if (dateFilter != DateFilter.all) {
    final now = DateTime.now();
    filtered = filtered.where((l) {
      switch (dateFilter) {
        case DateFilter.today:
          return l.createdAt.isAfter(now.subtract(const Duration(days: 1)));
        case DateFilter.thisWeek:
          return l.createdAt.isAfter(now.subtract(const Duration(days: 7)));
        case DateFilter.thisMonth:
          return l.createdAt.isAfter(now.subtract(const Duration(days: 30)));
        default:
          return true;
      }
    }).toList();
  }

  // YENİ: sortBy
  final sortBy = ref.watch(sortByProvider);
  switch (sortBy) {
    case SortBy.newest:
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    case SortBy.oldest:
      filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    case SortBy.nearest:
    case SortBy.farthest:
      // Konum varsa sırala, yoksa en sona koy
      break;
  }

  return filtered;
});
```

---

## 5. Firebase / Servis Gereksinimleri

### 5.1 Firestore

Yeni collection veya field gerekmiyor. Mevcut `listings` collection'da:
- `status` alanı zaten var (active/traded/cancelled)
- `createdAt` alanı zaten var
- `updatedAt` modelde var, database'e yazılmıyor — eklenecek

### 5.2 Storage

Yeni bucket gerekmiyor.

### 5.3 Security Rules

Güncelleme gerekmiyor — mevcut kurallar yeterli.

### 5.4 Functions

Server-side filtering gerekmiyor — client-side yapılacak.

---

## 6. Edge Case'ler

### 6.1 İzin Verilmemiş / Yetkisiz Erişim

- **Durum**: Kullanıcı giriş yapmamış ama filtrelemek istiyor
- **Çözüm**: `authStateProvider.value == null` ise filtreler sıfırlanır, giriş ekranına yönlendirilir
- **Not**: Mevcut kod zaten bunu yapıyor (`allListingsProvider`)

### 6.2 Ağ / İnternet Olmadığında

- **Durum**: Offline mode'da filtreleme
- **Çözüm**: Client-side filtering mevcut veriyle çalışır — ekran gösterilir "Sonuç bulunamadı" veya önbellekteki verilerle gösterilir
- **Not**: `allListingsProvider` zaten stream, hata gösterilecek

### 6.3 Boş State (İlk Kullanım, Veri Yok)

- **Durum**: Filtreler aktif ama hiç ilan yok veya eşleşen yok
- **Çözüm**: `hasFilters` kontrolü ile "Sonuç bulunamadı" veya "Henüz ilan yok" mesajı + "Filtreleri Temizle" butonu
- **Not**: Mevcut kod `hasFilters` değişkeniyle bunu yapıyor

### 6.4 Ek Edge Case'ler

- **6.4.1 Çok Dar Filtre**: Tüm filtreler aktif ama 0 sonuç — tekrar "Filtreleri temizle" hatırlatması
- **6.4.2 Konum İzni Yok**: "Yakındakiler" filtresi seçili ama konum izni reddedildi — uyarı göster, konum gerektirmeyen filtrelerle devam et
- **6.4.3 Çok Fazla Sonuç**: 1000+ ilan — lazy loading veya "Daha fazla göster" butonu gerekebilir (scroll pagination)

---

## 7. Geliştirme Sırası

| Sıra | Parça | Açıklama |
|------|--------|-----------|
| 1 | Enum'lar ve Provider'lar | `listings_controller.dart`'a yeni state provider'ları ekle |
| 2 | FilteredListingsProvider güncelleme | Yeni filtreleri `filteredListingsProvider`'a entegre et |
| 3 | Active Filters Banner | `active_filters_banner.dart` widget'ını oluştur |
| 4 | Filter Sheet genişletme | `filter_sheet.dart`'a yeni filtre seçeneklerini ekle |
| 5 | Filter Chip Bar | `filter_chip_bar.dart` ile tekrar kullanılabilir chip barı |
| 6 | Home Screen entegrasyonu | Yeni UI'ı `home_screen.dart`'a entegre et |
| 7 | Test | Filtreleme senaryolarını test et |

---

## 8. Açık Sorular

### 8.1 SortBy - Konum Bazlı Sıralama

- **Soru**: `SortBy.nearest` ve `SortBy.farthest` için kullanıcının konumu gerekli. Konum izni reddedilirse ne olsun?
- **Seçenekler**:
  - (A) Konum yoksa bu seçenekler pasif/disabled yapılır
  - (B) Konum yoksa "en yakın" default olarak en yeni sıralaması kullanılır
  - (C) SortBy'dan konum seçeneği tamamen kaldırılır

**Önerilen**: Seçenek A — konum varsa sort yapılır, yoksa pasif (a seçildi)

### 8.2 distanceFilter — Varsayılan Değer

- **Soru**: Varsayılan mesafe ne olsun? Mevcut: 100km (seçilen filtre aktif değilken hepsi-filtre varken 50 km )
- **Seçenekler**:
  - (A) 50km — makul bir değer
  - (B) 100km — mevcut değer
  - (C) Kullanıcıya sorulsun (settings'de)

**Önerilen**: Seçenek A — 50km daha kullanışlı 

### 8.3 dateFilter — Performans

- **Soru**: Tarih filtering client-side yapılacak. Büyük veritabanında performans sorunu olabilir mi?
- **Seçenekler**: seçilen- en optimize yol
  - (A) Client-side yapılır, gerekirse server-side'a taşınır (Future)
  - (B) Doğrudan Firestore query ile server-side yapılır

**Önerilen**: Seçenek A — önce client-side, sonra optimize et 

### 8.4 UI — Filtre Paneli Konumu

- **Soru**: Filtre sheet mi yoksa inline mi? (b-full screen seçildi )
- **Seçenekler**:
  - (A) Mevcut gibi sheet (alttan açılır) 
  - (B) AppBar'a tıklanınca full-screen route
  - (C) Search bar'ın altında inline expandable

**Önerilen**: Seçenek A — mevcut pattern korunur, içerik genişletilir

---

## Özet

| Bölüm | Durum |
|--------|-------|
| Model değişikliği | `updatedAt` toJson'a eklenecek |
| Yeni provider | 5 yeni provider |
| Firestore | Değişiklik yok |
| Storage | Değişiklik yok |
| Security rules | Değişiklik yok |
| Edge case | 6 case tanımlandı |
| Açık soru | 4 soru |

**Spec hazır. /feature-build komutuyla geliştirmeye başlayabilirsin.**