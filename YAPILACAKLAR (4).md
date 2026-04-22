# Takaş — Geliştirme Yapılacaklar Listesi

> Öncelik sırası: Play Store sonrası ilk iterasyon için kritik olanlar üstte.
> Altyapı: Flutter + Firebase (Auth, Firestore, Storage, FCM) + Mapbox + Riverpod + GoRouter

---

## 1. Teklif Akışı — Durum Takibi + Bildirim

**Neden kritik:** Uygulamanın core loop'u. Teklif gönderildi ama karşı taraf kabul/reddetti mi? Takip yoksa kullanıcı kaybı garantidir.

### Firestore Değişiklikleri

```
chats/{chatId}
  + offerStatus: 'pending' | 'accepted' | 'declined' | 'completed'
  + offerListingId: string        // teklif edilen ilanın ID'si
  + targetListingId: string       // hedef ilanın ID'si
  + offerSenderId: string
  + offerUpdatedAt: Timestamp
```

### Yapılacaklar

- [ ] `ChatModel`'e `offerStatus`, `offerListingId`, `targetListingId`, `offerSenderId`, `offerUpdatedAt` alanlarını ekle
- [ ] `ChatRepository`'e `sendOffer()`, `acceptOffer()`, `declineOffer()` metodlarını ekle
- [ ] `ChatDetailScreen`'e teklif durumuna göre değişen UI banner'ı ekle:
  - Beklemede → sarı banner "Teklif bekleniyor"
  - Kabul edildi → yeşil banner "Teklif kabul edildi! Teslimatı koordine edin"
  - Reddedildi → kırmızı banner "Teklif reddedildi"
- [ ] `ChatListScreen`'deki her sohbet kartına `offerStatus` badge'i ekle
- [ ] Teklif durumu değiştiğinde FCM bildirimi gönder (Cloud Function trigger: `onUpdate` → `chats/{chatId}`)
- [ ] `chatMessagesProvider` → `offerStatusProvider(chatId)` olarak ayır, gereksiz rebuild önle

---

## 2. Sohbette Ürün Bağlamı (Context Header)

**Neden kritik:** Kullanıcı 5 farklı takas pazarlığı yürütüyorsa sohbet listesinde kaybolur.

### Firestore Değişiklikleri

```
chats/{chatId}
  + listingId: string             // zaten var mı kontrol et
  + listingTitle: string          // denormalize — sorgusuz göster
  + listingThumbnailUrl: string   // denormalize — sorgusuz göster
```

### Yapılacaklar

- [ ] `chats` koleksiyonunda `listingTitle` ve `listingThumbnailUrl` alanları yoksa ekle (sohbet oluşturulurken yazılacak, denormalize)
- [ ] `ChatDetailScreen` AppBar'ını custom widget'a çevir:
  - Sol: ürün thumbnail (40x40, rounded)
  - Orta: ürün başlığı + karşı kullanıcı adı
  - Sağ: ilan detayına giden `IconButton`
- [ ] `ChatListScreen`'deki `ListTile`'a leading'de kullanıcı avatarının yanına küçük ürün thumbnail'i ekle
- [ ] `ChatRepository.createChat()` metodunu güncelle — sohbet oluştururken listing bilgilerini de yaz

---

## 3. Ürün Kondisyon Alanı

**Neden kritik:** Kondisyon olmadan değer kıyaslaması yapılamaz, takas teklifleri gerçekçi olmaz.

### Firestore Değişiklikleri

```
listings/{listingId}
  + condition: 'new' | 'like_new' | 'good' | 'fair' | 'worn'
```

### Yapılacaklar

- [ ] `ListingModel`'e `condition` enum/string alanı ekle
- [ ] `CreateListingScreen`'e kondisyon seçici ekle (SegmentedButton veya chip row):
  - Sıfır / Az Kullanılmış / İyi / Orta / Yıpranmış
- [ ] `ListingDetailScreen`'de kondisyon ikonla göster (örn. `condition_icon` + etiket)
- [ ] `ListingCard` widget'ına kondisyon badge'i ekle (isteğe bağlı, küçük)
- [ ] `filteredListingsProvider`'a kondisyon filtresi ekle
- [ ] Mevcut ilanlar için `condition` alanı yoksa varsayılan `'good'` ata (migration script veya null-safe okuma)

---

## 4. "Takası Tamamla" → İlan Otomatik Pasife Alma

**Neden kritik:** Takas gerçekleşmiş ama ilan aktif kalmaya devam ederse kullanıcı şikayeti kaçınılmaz.

### Firestore Değişiklikleri

```
listings/{listingId}
  status: 'active' | 'inactive' | 'traded'   // 'traded' durumu ekle

chats/{chatId}
  offerStatus: ... | 'completed'              // zaten üstte var
```

### Yapılacaklar

- [ ] `ListingModel`'e `'traded'` status değerini ekle
- [ ] `ChatDetailScreen`'e "Takası Tamamla" butonu ekle (sadece `offerStatus == 'accepted'` iken görünür)
- [ ] "Takası Tamamla" akışı:
  1. Onay dialog'u göster
  2. `chats/{chatId}.offerStatus` → `'completed'` yaz
  3. Her iki ilanı (`offerListingId` + `targetListingId`) `status: 'traded'` yap
  4. Her iki kullanıcıya `completedTradesCount` +1 (bkz. madde 6)
  5. Rating ekranına yönlendir (bkz. aşağı)
- [ ] `allListingsProvider` / `nearbyListingsProvider` sorgularına `where('status', isEqualTo: 'active')` filtresi zaten var mı kontrol et, yoksa ekle
- [ ] Cloud Function: `offerStatus` → `completed` olunca listing'leri otomatik pasife al (client-side'a güvenme, double-write guard)

---

## 5. Harita Kümeleme

**Neden kritik:** İlan sayısı arttığında harita kullanılamaz hale gelir.

### Yapılacaklar

- [ ] Mapbox `MapboxMap` widget'ında GeoJSON source'a `cluster: true`, `clusterMaxZoom: 14`, `clusterRadius: 50` parametrelerini ekle
- [ ] Cluster circle layer ekle (renk: primary green, boyut: count'a göre `step` expression)
- [ ] Cluster count symbol layer ekle (beyaz metin)
- [ ] Cluster'a tıklanınca kamera zoom in yap (`flyTo` + `zoom +2`)
- [ ] Unclustered point layer'ı mevcut ilan marker'larıyla eşleştir
- [ ] `MapScreen`'deki mevcut marker ekleme mantığını GeoJSON feature collection'a taşı (tek tek `addAnnotation` yerine)

---

## 6. Profilde Başarılı Takas Sayısı

**Neden kritik:** Yıldız ortalaması tek başına güven sinyali olarak zayıf kalır.

### Firestore Değişiklikleri

```
users/{userId}
  + completedTradesCount: int     // varsayılan: 0
```

### Yapılacaklar

- [ ] `UserModel`'e `completedTradesCount` alanı ekle (null-safe, default 0)
- [ ] `ProfileScreen` ve `PublicProfileScreen`'e istatistik satırı ekle:
  - ⭐ 4.8 (12 değerlendirme) | 🔄 8 başarılı takas
- [ ] Takas tamamlandığında her iki kullanıcı için `completedTradesCount` +1 yaz (madde 4'teki Cloud Function içinde)

---

## 7. Boş Durum Ekranları (Empty States)

**Neden kritik:** Yeni kullanıcı deneyimi — çevrede ilan yoksa ne görür?

### Yapılacaklar

- [ ] `HomeScreen` (Keşfet) boş durum: "Çevrenizde henüz ilan yok. İlk ilanı siz ekleyin!" + CTA butonu
- [ ] `ChatListScreen` boş durum: "Henüz sohbet yok. Bir ilan beğenin ve takas teklifi gönderin!"
- [ ] `MapScreen` boş durum: haritada hiç marker yoksa alt sheet ile bilgilendirme
- [ ] `ProfileScreen` → kendi ilanları boşsa yönlendirici boş durum widget'ı
- [ ] Boş durum için `shared/widgets/empty_state_widget.dart` ortak bileşeni oluştur (icon + title + subtitle + optional CTA parametreleriyle)

---

## 8. İlan Detayında "Teklif Et" Butonu (Sohbet Başlatma Akışı İyileştirme)

**Neden kritik:** Gemini'nin bahsettiği "kendi ilanlarımdan teklif et" özelliği — Firebase chat altyapısıyla doğru kurgu.

### Yapılacaklar

- [ ] `ListingDetailScreen`'deki "Mesaj Gönder" butonunu "Takas Teklif Et" olarak yeniden adlandır
- [ ] Tıklanınca kendi aktif ilanlarını listeleyen bottom sheet aç (`userActiveListingsProvider(currentUserId)`)
- [ ] Kullanıcı kendi ilanını seçince:
  1. Varsa mevcut sohbeti bul (`chats` sorgula: `participants` array-contains + `listingId`)
  2. Yoksa yeni sohbet oluştur
  3. `offerListingId` ve `offerStatus: 'pending'` yaz
  4. `ChatDetailScreen`'e yönlendir
- [ ] Aktif ilanı yoksa "Önce bir ilan ekleyin" dialog'u göster + `CreateListingScreen`'e yönlendirme seçeneği sun

---

## Notlar

- Madde 1 ve 4'teki Cloud Function'lar birbirine bağlı — birlikte yazılması mantıklı
- Madde 3 (kondisyon) ilan ekleme formunu etkiliyor — Play Store öncesi tamamlanması önerilir
- Madde 5 (harita kümeleme) bağımsız, herhangi bir aşamada yapılabilir
- Rating/değerlendirme akışı (takas sonrası) ayrı bir madde olarak ele alınmadı — mevcut `ratings` koleksiyonu var ama UI akışı net değilse sonraki iterasyona bırak
