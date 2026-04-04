# Kullanıcı Profilindeki Harita/Navigasyon Sorunu

Bu döküman, Faz 3 geliştirme sürecinde karşılaşılan "Kırmızı Ekran" (GlobalKey/Hero Assertion) hatasını ve uygulanan kesin çözümü özetler.

## 🚨 Mevcut Sorun (Problem)
Kullanıcı şu adımları izlediğinde uygulama hata verip kırmızı ekran gösteriyordu:
1. **Keşfet** sayfasından bir ilana tıklama.
2. İlan detayından **İlan Sahibinin Profili**'ne gitme.
3. Profil sayfasındaki ilanlar listesinden **Aynı İlanın Detayı**'na tekrar gitme.
4. İlan kartındaki konum veya harita etkileşimi tetiklendiğinde `A GlobalKey was used multiple times` hatası alınması.

## 🔍 Teknik Analiz
Hatanın üç ana temel nedeni vardı:
1. **Navigasyon Stack Şişmesi:** `context.push` kullanımı, önceki sayfaları bellekte tutar. Aynı ilana farklı bir yoldan tekrar gidildiğinde, Flutter aynı "ID"ye sahip widget'ları navigator ağacında iki farklı yerde görür.
2. **Hero Tag Çakışması:** `ListingCard` içindeki fotoğraf animasyonu (Hero), sadece `listing.id` kullanıyordu. Stack'te aynı ilandan iki tane olduğunda Hero etiketleri benzersizliğini yitirdi.
3. **Platform View (Mapbox) Çakışması:** Harita widget'ı (Native Android View), sekmeler arasında taşınırken eski anahtarını (key) bırakamadı ve `keyReservation` hatasına yol açtı.

## 🛠️ Uygulanan Çözüm
Sorunu kökten çözmek için üç katmanlı bir iyileştirme yapıldı:

### 1. Navigasyon Temizliği
`PublicProfileScreen` ve `ListingCard` içindeki yönlendirmeler `context.push` (üst üste ekle) yerine **`context.go`** (stack'i temizle ve git) olarak güncellendi. Bu, derinlemesine giden sayfa döngülerini engelledi.

### 2. Benzersiz Hero Etiketleri
`ListingCard` içindeki `Hero` tag'ine, o anki sayfa bağlamını temsil eden `context.hashCode` eklendi:
```dart
tag: 'image_${listing.id}_${context.hashCode}'
```
Bu sayede aynı ilan farklı sayfalarda (Keşfet vs Profil) gösterilse bile Flutter onları farklı Hero objeleri olarak tanıdı.

### 3. Dinamik Harita Anahtarı (ValueKey)
`MapScreen` içindeki `MapWidget`'a, o anki rotanın URI bilgisini içeren bir `ValueKey` atandı:
```dart
key: ValueKey('mapbox_widget_${GoRouterState.of(context).uri}')
```
Bu, Flutter'ın harita widget'ını her rota değişiminde tamamen dispose edip temiz bir şekilde yeniden oluşturmasını sağladı.

## 🚀 Sonuç
Yapılan değişiklikler sonrası navigasyon stack'i optimize edildi ve platform tabanlı (Mapbox) çakışmalar giderildi. Uygulama artık derin navigasyon senaryolarında kararlı bir şekilde çalışmaktadır.
