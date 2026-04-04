# 🗺️ Skill: Faz 3 — Harita & Konum

> Bu skill dosyasını harita ve konum ile ilgili her sohbetin başına PROJECT_CONTEXT.md ile birlikte yapıştır.

---

## Bu Skill Ne İçin?

Mapbox harita entegrasyonu, kullanıcı konumu alma, geofencing ve harita üzerinde ilan marker'larını yönetmek için.

**Durum:** ⚠️ Kısmen tamamlandı — MapScreen çalışıyor ama controller ve geo_repository STUB.

---

## 🗂️ Dosya Yapısı

```
lib/features/map/
├── data/
│   ├── location_service.dart          # Konum izinleri, GPS, stream (57 satır)
│   └── geo_repository.dart            # ❌ YOK — geofencing listing_repository'de
├── domain/
│   └── geo_point_model.dart           # ❌ STUB (1 satır)
└── presentation/
    ├── map_screen.dart                # Mapbox harita (178 satır)
    └── map_controller.dart            # ❌ STUB (1 satır)
```

---

## 📍 LocationService (57 satır)

```dart
class LocationService {
  Future<bool> hasPermission()
  Future<bool> requestPermission()
  Future<Position?> getCurrentLocation()
  Stream<Position?> getLocationStream()
}

// Providers
final locationServiceProvider = Provider<LocationService>((ref) => LocationService());
final userLocationProvider = StreamProvider<Position?>((ref) => ...);
```

**Kullanım:** `ref.watch(userLocationProvider)` ile kullanıcının canlı konumu dinlenir.

---

## 🗺️ MapScreen (178 satır)

**Özellikler:**
- Mapbox `MapWidget` ile harita
- Kullanıcı konumuna otomatik odaklanma
- Daire (circle) annotations ile ilan marker'ları
- Marker'a tıklayınca bottom sheet ile ilan özeti
- "Konumuma git" FAB butonu
- `nearbyListingsProvider` ile yakın ilanları gösterir

**Marker Tıklama Akışı:**
1. Circle annotation'a tıkla
2. İlan ID'sini al
3. `singleListingProvider` ile ilan detayını getir
4. Bottom sheet'te başlık, kategori göster
5. "Detayları Gör" → ListingDetailScreen'e yönlendir

---

## 📊 Geofencing (listing_repository.dart'da)

Geofencing ayrı bir repository'de değil, `listing_repository.dart` içinde implement edilmiş:

```dart
Stream<List<ListingModel>> getNearbyListings({
  required GeoPoint center,
  required double radiusInKm,
}) {
  final GeoCollectionReference<Map<String, dynamic>> geoRef =
      GeoCollectionReference(_listingsRef);
  return geoRef.subscribeWithin(
    center: GeoFirePoint(center),
    radiusInKm: radiusInKm,
    field: 'location',
    geopointFrom: (data) => data['location'] as GeoPoint,
    queryBuilder: (query) => query.where('status', isEqualTo: ListingStatus.active.name),
  ).map(...);
}
```

**Paket:** `geoflutterfire_plus: ^0.0.17`

---

## 🔧 Mapbox Yapılandırması

### .env
```bash
MAPBOX_ACCESS_TOKEN=pk.your_mapbox_token
```

### main.dart
```dart
String mapboxToken = dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
MapboxOptions.setAccessToken(mapboxToken);
```

### AndroidManifest.xml
```xml
<meta-data android:name="com.mapbox.token" android:value="pk.YOUR_MAPBOX_TOKEN" />
```

---

## ⚠️ Mevcut Sorunlar ve Eksikler

1. **map_controller.dart STUB** — "// Map Controller -- Faz 3'te implement edilecek"
2. **geo_repository.dart YOK** — Geofencing listing_repository'de
3. **geo_point_model.dart STUB** — Boş dosya
4. **Yarıçap ayarlama yok** — Kullanıcı 5/10/20 km seçemiyor (sabit 100km default)
5. **Konum seçme yok** — İlan oluştururken haritadan pin atma yok (sadece GPS)

---

## 📊 Firestore Yapısı

```
listings/{listingId}
  - location: GeoPoint        # Enlem/boylam
  - geohash: string           # Geoflutterfire_plus geohash
```

---

## 🔧 Geliştirilmesi Gerekenler

- [ ] MapController implementasyonu (marker yönetimi, kamera animasyonları)
- [ ] GeoRepository oluşturma (geocoding, reverse geocoding)
- [ ] Haritada yarıçap seçimi (5/10/20 km)
- [ ] İlan oluştururken haritadan pin atma
- [ ] Cluster desteği (çok marker olduğunda gruplama)

---

## 🤖 Yapay Zekadan İstek Örnekleri

```
"PROJECT_CONTEXT.md ve skill_faz3_map.md'ye göre,
map_controller.dart'ı implement et.
Marker ekleme, silme, kamera animasyonu ve yarıçap daire çizimi olsun."
```

```
"PROJECT_CONTEXT.md ve skill_faz3_map.md'ye göre,
create_listing_screen.dart'a haritadan pin atma özelliği ekle.
Kullanıcı haritaya tıklayarak konum seçebilsin."
```

```
"PROJECT_CONTEXT.md ve skill_faz3_map.md'ye göre,
map_screen.dart'a yarıçap ayarlama slider'ı ekle.
Kullanıcı 1-50 km arası seçebilsin ve harita güncellensin."
```
