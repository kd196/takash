İlanlarım Sekmesi Düzeltmesi ve UX İyileştirmesi
🚨 Mevcut Sorun (Problem)
Kullanıcı yeni bir ilan yüklediğinde uygulama onu "Keşfet" (Home) sayfasına yönlendiriyor. Kendi ilanını görmek için Keşfet sayfasında kendi ilanını araması gerekiyor. Bu çok kötü bir kullanıcı deneyimidir. Ayrıca profilim sekmesinde kullanıcının kendi ilanlarını görüp yönetebileceği bir alan yok.

🎯 Hedeflenen Çözüm
Profil sayfasına ("Profilim") girildiğinde, kullanıcının ilanlarını gösteren "İlanlarım" bölümü/sekmesi eklenecek.
İlanlar "Aktif İlanlar" ve "Diğer İlanlar" (Satıldı, Askıya Alındı vb.) şeklinde sekmelere (TabBar) ayrılacak.
Yeni ilan oluşturulduktan sonra yönlendirme Keşfet'ten çıkıp, bu İlanlarım sayfasına yapılacak.
İlanlarım sayfasındaki kartlar, keşfet sayfasındaki kartlardan farklı olarak "Düzenle", "Durum Değiştir" ve "Sil" aksiyonlarını barındıracak.
🛠️ Yapılacaklar (Adım Adım)
Adım 1: Yönlendirmeyi (Redirect) Düzelt
Dosya: İlan oluşturma ekranı (muhtemelen lib/features/listings/presentation/create_listing_screen.dart veya benzeri).
İşlem: İlan başarıyla oluşturulduktan sonra ( onSuccess callback'i içinde ) context.go('/') (Keşfet) yerine context.go('/profile') veya doğrudan İlanlarım sekmesine yönlendirme yap.
Adım 2: Profil Sayfasına İlanlarım Entegrasyonu
Dosya: lib/features/profile/presentation/profile_screen.dart
İşlem: Profil bilgilerinin altına (veya Profil ekranı altındaki ikinci bir sayfa olarak) "İlanlarım" butonu/section'ı ekle. Tıklanınca "İlanlarım" sayfasına götersin veya direkt ProfileScreen içine bir TabBar koy.
Tavsiye Edilen Mimari: Profil ekranını karmaşıklaştırmamak için MyListingsScreen adında ayrı bir sayfa oluştur ve router'a ekle (örn: /my-listings). Profilim sayfasından bu sayfaya geçiş yap.
Adım 3: İlanlarım Sayfasını Oluştur (MyListingsScreen)
Dosya: lib/features/listings/presentation/my_listings_screen.dart (Yeni dosya)
İşlem:
Üstte iki kapsamlı Tab olmalı: Aktif İlanlar ve Devre Dışı.
Mevcut userListingsProvider (zaten var olan stream provider) kullanılacak.
Bu provider'dan gelen veriyi, ListingStatus.active olanlar ve olmayanlar diye ayıracak bir filtreleme mantığı yazılacak (Controller'a eklenebilir).
Adım 4: İlan Yönetim Kartı (ManageListingCard) Tasarla
Dosya: lib/features/listings/presentation/widgets/manage_listing_card.dart
İşlem: Keşfet sayfasındaki ListingCard'ı kopyalayıp yeni bir widget yap. Bu kartın altına 3 ikon buton ekle:
Düzenle (Edit) -> context.go('/edit-listing/$listingId')
Durum Değiştir (Satıldı/Askıya al) -> Popup menü ile updateListingStatus metodunu çağır.
Sil (Delete) -> Uyarı dialogu gösterip deleteListing metodunu çağır.
Adım 5: Boş Durum (Empty State) İyileştirmesi
Eğer kullanıcının aktif ilanı yoksa: "Henüz aktif ilanınız yok" + [Yeni İlan Oluştur] butonu.
Eğer devre dışı ilanları yoksa: "Burada eski ilanlarınız yer alacak" yazısı.
⚠️ Claude'ya Dikkat Edilmesi Gerekenler
listing_controller.dart içindeki userListingsProvider ve updateStatus / deleteListing metodları zaten var, yeniden yazmana gerek yok, sadece UI'da consume et.
listing_model.dart içindeki ListingStatus enum'unu incele, orada zaten active, sold, paused vb. durumlar olabilir, onlara göre filtrele.
Görsel tasarım (UI) uygulamanın genel temasına (theme.dart) uygun olsun.