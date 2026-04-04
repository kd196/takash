# 📦 Skill: Faz 2 — İlan Yönetimi (Listings)

> Bu skill dosyasını ilan yönetimi ile ilgili her sohbetin başına PROJECT_CONTEXT.md ile birlikte yapıştır.

---

## Bu Skill Ne İçin?

İlan oluşturma, listeleme, filtreleme, detay görüntüleme, düzenleme, silme, favoriler ve widget yapılarını anlamak ve geliştirmek için.

**Durum:** ✅ Tamamlandı — Planın ötesinde implementasyon var.

---

## 🗂️ Dosya Yapısı

```
lib/features/listings/
├── data/
│   └── listing_repository.dart          # CRUD, Storage, Favorites, Geofencing (269 satır)
├── domain/
│   ├── listing_model.dart               # İlan modeli (100 satır)
│   └── listing_category.dart            # Enum'lar + extensions (73 satır)
└── presentation/
    ├── home_screen.dart                 # Ana sayfa — Letgo-style grid (332 satır)
    ├── listing_detail_screen.dart       # İlan detay (540 satır)
    ├── create_listing_screen.dart       # İlan oluştur (349 satır)
    ├── edit_listing_screen.dart         # İlan düzenle (376 satır)
    ├── my_listings_screen.dart          # İlanlarım — Aktif/Diğer tab (138 satır)
    ├── favorites_screen.dart            # Favoriler (83 satır)
    ├── listings_controller.dart         # Riverpod providers (244 satır)
    └── widgets/
        ├── listing_card.dart            # Reusable ilan kartı (244 satır)
        ├── filter_sheet.dart            # Alt filtre sheet'i (110 satır)
        └── manage_listing_card.dart     # İlan yönetim kartı (230 satır)
```

---

## 📋 ListingModel (100 satır)

```dart
class ListingModel {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final ListingCategory category;
  final List<String> imageUrls;
  final String wantedItem;       // "Karşılığında ne istiyorum"
  final GeoPoint? location;
  final String? geohash;         // Geofencing için
  final ListingStatus status;    // active, reserved, completed
  final DateTime createdAt;
}
```

**toJson/fromJson:** Tam serialization. `category` ve `status` enum'lar `.name` ile string olarak kaydedilir, `fromJson`'da `firstWhere(orElse:)` ile güvenli parse.

### ListingCategory Enum
```dart
enum ListingCategory { electronics, clothing, books, furniture, sports, toys, other }
```

**Extension:** Her kategorinin `label` (Türkçe) ve `icon` (emoji) property'si var.

### ListingStatus Enum
```dart
enum ListingStatus { active, reserved, completed }
```

**Extension:** Her status'un `label` (Türkçe) property'si var.

---

## 📁 ListingRepository (269 satır)

### CRUD Metodları
```dart
Future<String> createListing({ownerId, title, description, wantedItem, category, images, location, geohash})
Future<ListingModel?> getListingById(String listingId)
Stream<List<ListingModel>> getAllActiveListings()
Stream<List<ListingModel>> getUserListings(String userId)
Stream<List<ListingModel>> getListingsByCategory(ListingCategory category)
Future<List<ListingModel>> searchListings(String query)  // client-side

Future<void> updateListing(ListingModel listing)
Future<void> updateListingStatus(String listingId, ListingStatus status)
Future<void> deleteListing(String listingId)  // Önce Storage'dan siler
```

### Geofencing
```dart
Stream<List<ListingModel>> getNearbyListings({required GeoPoint center, required double radiusInKm})
```
`geoflutterfire_plus` paketi kullanıyor. `GeoCollectionReference` ile `subscribeWithin`.

### Favoriler
```dart
Future<void> toggleFavorite(String userId, ListingModel listing)
Stream<bool> isFavorite(String userId, String listingId)
Stream<List<ListingModel>> getUserFavorites(String userId)
```
Favoriler `users/{userId}/favorites/{listingId}` alt koleksiyonunda saklanır.

### Storage
```dart
Future<List<String>> uploadImages(List<File> images, String listingId)
Future<void> deleteImages(String listingId)
```
Storage path: `listings/{listingId}/image_0.jpg`, `image_1.jpg`, ...

---

## 🎮 ListingsController (244 satır)

### Stream Providers
```dart
final allListingsProvider        // Tüm aktif ilanlar
final nearbyListingsProvider     // Yakındaki ilanlar (geofencing)
final userListingsProvider       // Belirli kullanıcının ilanları
final singleListingProvider      // Tek ilan detayı
final isFavoriteProvider         // Favori mi kontrolü
final userFavoritesProvider      // Kullanıcının favorileri
```

### State Providers
```dart
final searchRadiusProvider       // Arama yarıçapı (default: 100km)
final searchQueryProvider        // Arama metni
final categoryFilterProvider     // Kategori filtresi (null = hepsi)
final showMyListingsProvider     // Kendi ilanlarımı göster (default: false)
final filteredListingsProvider   // Filtrelenmiş sonuç
```

### CreateListingController (AsyncNotifier)
```dart
class CreateListingController extends AsyncNotifier<void> {
  Future<String?> createListing({title, description, category, wantedItem, images, location})
  Future<bool> updateListing({required ListingModel listing, List<File>? newImages})
  Future<bool> deleteListing(String listingId)
  Future<bool> updateStatus(String listingId, ListingStatus status)
  Future<void> toggleFavorite(ListingModel listing)
}
```

**Önemli:** `createListing` içinde geohash otomatik hesaplanır (`GeoFirePoint.geohash`).

---

## 🖥️ Ekranlar

### HomeScreen (332 satır)
- Letgo-style grid layout (2 sütun)
- Arama çubuğu + kategori chip'leri
- FilterSheet (kategori + "kendi ilanlarım" toggle)
- Pull-to-refresh + Empty state

### ListingDetailScreen (540 satır)
- PageView fotoğraf carousel
- Sahip mini kartı → PublicProfileScreen
- "Karşılığında istediğim" kartı
- Paylaş, Favori, Mesaj/teklif butonları
- Sahip ise: Rezerve et / Sil butonları

### CreateListingScreen (349 satır)
- Image picker (max 5 fotoğraf)
- GPS konum alma
- Kategori dropdown + "Karşılığında ne istiyorum"

### EditListingScreen (376 satır)
- Mevcut ilan verilerini yükler
- Text alanları + fotoğraf değiştirme

### MyListingsScreen (138 satır)
- TabBarView: Aktif / Diğer ilanlar
- ManageListingCard ile düzenle/sil/status

### FavoritesScreen (83 satır)
- Favori ilanlar listesi

---

## 🧩 Widget'lar

| Widget | Açıklama |
|--------|----------|
| `ListingCard` | Fotoğraf, kategori badge, favori butonu, mesafe, zaman |
| `FilterSheet` | Bottom sheet — kategori chip'leri + toggle |
| `ManageListingCard` | İlan özeti + status dropdown + düzenle/sil |

---

## 📊 Firestore Yapısı

```
listings/{listingId}
  - id, ownerId, title, description, category
  - imageUrls: string[], wantedItem
  - location: GeoPoint, geohash: string
  - status: active/reserved/completed
  - createdAt

users/{userId}/favorites/{listingId}
  - (ListingModel kopyası)
```

---

## ⚠️ Önemli Notlar

1. **Geofencing fallback:** `nearbyListingsProvider` yakında ilan bulamazsa tüm ilanları gösterir.
2. **Arama client-side:** `searchListings` tüm aktif ilanları çeker, client-side filtre yapar.
3. **Favoriler kopya:** Favoriye eklenen ilan verisi alt koleksiyona kopyalanır.
4. **Fotoğraf limiti:** İlan başına max 5 fotoğraf.
5. **Silme işlemi:** Önce Storage'dan fotoğraflar silinir, sonra Firestore dökümanı silinir.

---

## 🤖 Yapay Zekadan İstek Örnekleri

```
"PROJECT_CONTEXT.md ve skill_faz2_listings.md'ye göre,
listing_card.dart'a mesafe bilgisini ekle.
location varsa kullanıcının konumuna uzaklığı hesapla ve göster."
```

```
"PROJECT_CONTEXT.md ve skill_faz2_listings.md'ye göre,
home_screen.dart'a pagination (sonsuz scroll) ekle.
Firestore'da startAfterDocument kullanarak sayfalama yap."
```
