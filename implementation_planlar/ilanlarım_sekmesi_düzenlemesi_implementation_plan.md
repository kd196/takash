# İlanlarım (My Listings) UX Düzenlemesi — Uygulama Planı

## 📌 Genel Bakış
Kullanıcının isteği üzerine **Faz 3 (Harita)** sonraya ertelenmiştir. 
Bu planda, kullanıcının yeni ilan oluşturduğunda "Keşfet" yerine "İlanlarım" sayfasına yönlendirilmesi ve Profil sayfasından "İlanlarım" sayfasına erişim sağlanması için gerekli UX iyileştirmelerini yapacağız. Ayrıca ilanların yönetilebilmesi için özel bir kart tasarımı oluşturacağız.

---

## 🚀 Uygulama Adımları

### Adım 1 — Yönlendirmeyi (Redirect) Düzeltme
#### [MODIFY] `lib/features/listings/presentation/create_listing_screen.dart`
- İlan başarıyla oluşturulduktan ve form temizlendikten sonra yapılan `context.go('/')` (Keşfet) yönlendirmesi `context.go('/profile/my-listings')` olarak değiştirilecek.

### Adım 2 — Router (GoRouter) Güncellemesi
#### [MODIFY] `lib/app/router.dart`
- `ProfileScreen` altındaki router dalına (branch) `/profile/my-listings` rotası eklenecek.
- `MyListingsScreen` import edilecek.

### Adım 3 — Profil Sayfasına Entegrasyon
#### [MODIFY] `lib/features/profile/presentation/profile_screen.dart`
- "Profili Düzenle" butonunun yanına veya altına "İlanlarım" butonu eklenecek.
- Bu butona tıklandığında `context.go('/profile/my-listings')` rotasına gidecek.

### Adım 4 — İlan Yönetim Kartı (ManageListingCard) Oluşturma
#### [NEW] `lib/features/listings/presentation/widgets/manage_listing_card.dart`
- Keşfet sayfasındaki `ListingCard` kopyalanıp geliştirilecek.
- Kartın alt kısmına "Düzenle" (Edit), "Durum Değiştir" (Satıldı / Askıya Al), ve "Sil" (Delete) butonları eklenecek.
- Silme işleminde uyarı diyaloğu (dialog) gösterilecek. Metodlar Riverpod Controller'dan tetiklenecek.

### Adım 5 — İlanlarım Sayfası Güncellemeleri
#### [MODIFY] `lib/features/listings/presentation/my_listings_screen.dart`
- "Aktif İlanlar" ve "Diğer İlanlar" (Rezerve, Tamamlandı vb.) olmak üzere 2 temel veya mevcut 3 tab korunarak görünümler yenilenecek.
- Boş durum uyarıları, verilen spesifikasyonlara göre (ör: "Henüz aktif ilanınız yok") güncellenecek.
- Önceden kullanılan standart `ListingCard` yerine yeni oluşturduğumuz `ManageListingCard` kullanılacak.

---

## User Review Required

> [!WARNING]
> Yukarıdaki plan istenen UX dosyasına birebir uyacak şekilde hazırlanmıştır. Düzenleme (Edit) rotası henüz uygulamada mevcut değil (`/edit-listing/$id`). 
> 1. Düzenle butonuna tıklayınca şimdilik bir uyarı mesajı (SnackBar) mı gösterelim, yoksa Düzenleme ekranını da hemen yapalım mı?
> 2. Plan onaylandığında kodlamayı tamamlayıp bağlı olan Android cihazınıza uygulamayı tekrar derleyeceğim (build).

Plana onay veriyor musunuz?
