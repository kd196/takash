# ⭐ Skill: Faz 5 — Puanlama & Güven Sistemi

> Bu skill dosyasını puanlama ile ilgili her sohbetin başına PROJECT_CONTEXT.md ile birlikte yapıştır.

---

## Bu Skill Ne İçin?

Takas sonrası karşılıklı puanlama, ortalama puan hesaplama ve kullanıcı güven sistemini anlamak ve geliştirmek için.

**Durum:** ✅ Tamamlandı — Puanlama chat_detail_screen içinde inline olarak çalışıyor.

---

## 🗂️ Dosya Yapısı

```
lib/features/profile/
├── data/
│   ├── profile_repository.dart          # Profil CRUD (66 satır)
│   └── rating_repository.dart           # Puanlama işlemleri (68 satır)
├── domain/
│   └── rating_model.dart                # Puanlama modeli (40 satır)
└── presentation/
    ├── profile_screen.dart              # Profil ekranı (290 satır)
    ├── profile_controller.dart          # Riverpod controller (58 satır)
    ├── profile_controller.g.dart        # Generated
    ├── edit_profile_screen.dart         # Profil düzenleme (189 satır)
    ├── public_profile_screen.dart       # Herkese açık profil (195 satır)
    ├── settings_screen.dart             # Ayarlar (261 satır)
    └── rating_screen.dart               # ❌ STUB (1 satır)
```

---

## 📋 RatingModel (40 satır)

```dart
class RatingModel {
  final String id;
  final String fromUserId;       // Puan veren
  final String toUserId;         // Puan alan
  final String listingId;        // Hangi takas için
  final int score;               // 1-5
  final DateTime createdAt;
}
```

**Not:** `comment` alanı mevcut modelde YOK. Sadece skor kaydediliyor.

---

## 📁 RatingRepository (68 satır)

```dart
class RatingRepository {
  Future<void> submitRating({fromUserId, toUserId, listingId, score})
  // Transaction ile: 1. Rating kaydet 2. Ortalamayı güncelle

  Future<bool> hasUserRatedListing(String fromUserId, String listingId)
  Stream<List<RatingModel>> getUserRatings(String userId)
}
```

**Transaction mantığı:**
```dart
await _firestore.runTransaction((transaction) async {
  transaction.set(ratingRef, rating.toJson());
  final userDoc = await transaction.get(userRef);
  final currentRating = userDoc.data()?['rating'] ?? 0.0;
  final currentCount = userDoc.data()?['ratingCount'] ?? 0;
  final newCount = currentCount + 1;
  final newRating = ((currentRating * currentCount) + score) / newCount;
  transaction.update(userRef, {'rating': newRating, 'ratingCount': newCount});
});
```

---

## 📁 ProfileRepository (66 satır)

```dart
class ProfileRepository {
  Stream<UserModel?> watchProfile(String userId)
  Future<UserModel?> getProfile(String userId)
  Future<void> updateProfile(userId, {name, bio, photoUrl})
  Future<String> uploadProfilePhoto(File image, String userId)
}

// Providers
final profileRepositoryProvider = Provider((ref) => ProfileRepository(...));
final userProfileProvider = StreamProvider.family<UserModel?, String>((ref, userId) => ...);
final userDataProvider = FutureProvider.family<UserModel?, String>((ref, userId) => ...);
```

---

## 🎮 ProfileController (58 satır)

```dart
@riverpod
class ProfileController extends _$ProfileController {
  FutureOr<void> build() {}
  Future<void> updateProfile({String? name, String? bio, String? photoUrl})
}
```

---

## 🖥️ Ekranlar

### ProfileScreen (290 satır)
- Profil fotoğrafı, isim, puan (yıldız + sayı), bio
- Aksiyon butonları: Düzenle / Bildirimler / Favoriler
- Genişletilebilir "İlanlarım" bölümü

### PublicProfileScreen (195 satır)
- SliverAppBar ile büyük profil fotoğrafı
- Kullanıcının aktif ilanları (grid)

### EditProfileScreen (189 satır)
- Profil fotoğrafı değiştirme (image_picker + crop)
- İsim + bio düzenleme

### SettingsScreen (261 satır)
- Hesap, Görünüm (tema seçimi), Bildirimler, Gizlilik, Destek
- Versiyon bilgisi + Çıkış Yap

### RatingScreen — ❌ STUB
Puanlama `ChatDetailScreen` içinde `_showRatingDialog` ile inline olarak yapılıyor.

---

## 🔄 Takas Tamamlama + Puanlama Akışı

1. İlan sahibi "Takası Bitir" butonuna basar
2. Karşı taraf onaylar
3. İlan `ListingStatus.completed` olur
4. `_showRatingDialog` açılır
5. Kullanıcı 1-5 yıldız seçer
6. `RatingRepository.submitRating()` ile transaction ile kaydedilir

---

## 📊 Firestore Yapısı

```
ratings/{ratingId}
  - fromUserId, toUserId, listingId, score, createdAt

users/{userId}
  - rating: number           # Ortalama puan (transaction ile güncellenir)
  - ratingCount: number      # Toplam değerlendirme sayısı
```

---

## ☁️ Cloud Function

```javascript
exports.onNewRating = functions.firestore
  .document('ratings/{ratingId}')
  .onCreate(async (snap, context) => {
    // Bildirim gönder
  });
```

---

## ⚠️ Önemli Notlar

1. **Comment alanı yok:** Sadece skor kaydediliyor.
2. **Dedicated rating screen STUB:** Ama sorun değil, chat içinde inline puanlama var.
3. **Transaction kullanılıyor:** Rating kaydetme ve ortalama güncelleme atomik.
4. **Tek puan hakkı:** `hasUserRatedListing` ile aynı takas için tekrar puanlama engelleniyor.

---

## 🔧 Geliştirilmesi Gerekenler

- [ ] RatingModel'e `comment` alanı ekle
- [ ] Profil sayfasında puanlama geçmişi göster
- [ ] Karşılıklı puanlama (her iki taraf da puanlamadan sonuç gösterme)

---

## 🤖 Yapay Zekadan İstek Örnekleri

```
"PROJECT_CONTEXT.md ve skill_faz5_rating.md'ye göre,
rating_model.dart'a 'comment' alanı ekle.
fromJson, toJson ve copyWith metodlarını güncelle."
```

```
"PROJECT_CONTEXT.md ve skill_faz5_rating.md'ye göre,
public_profile_screen.dart'a kullanıcının aldığı puanları gösteren
bir bölüm ekle."
```

```
"PROJECT_CONTEXT.md ve skill_faz5_rating.md'ye göre,
chat_detail_screen.dart'taki _showRatingDialog'a yorum alanı ekle."
```
