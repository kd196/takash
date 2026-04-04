# Faz 6.1 — Yeni Tasarım Planı
## Letgo Tarzı Modern UI (Renkler Korunacak)

> Mevcut renkler değişmeyecek. Sadece tipografi, kart tasarımı
> ve genel UI dili güncellenecek.

---

## Ne Değişecek, Ne Değişmeyecek

| | Durum |
|---|---|
| Ana renkler (primary, secondary) | ✅ Korunacak |
| Genel navigasyon yapısı | ✅ Korunacak |
| Firebase / backend | ✅ Dokunulmayacak |
| Tipografi (font) | 🔄 Değişecek |
| Kart tasarımı | 🔄 Değişecek |
| Spacing sistemi | 🔄 İyileştirilecek |
| Buton stili | 🔄 İnce ayar |

---

## Adım 1 — Font Değişikliği

### pubspec.yaml'a Ekle

```yaml
dependencies:
  google_fonts: ^6.2.1
```

### theme.dart'a Uygula

```dart
import 'package:google_fonts/google_fonts.dart';

ThemeData buildTheme(ColorScheme colorScheme) {
  return ThemeData(
    colorScheme: colorScheme,
    textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
      // Başlıklar — güçlü ve net
      displayLarge: GoogleFonts.plusJakartaSans(
        fontSize: 32, fontWeight: FontWeight.w800,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 22, fontWeight: FontWeight.w700,
      ),
      // İlan başlığı gibi önemli metinler
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 18, fontWeight: FontWeight.w700,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16, fontWeight: FontWeight.w600,
      ),
      // Normal metin
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 15, fontWeight: FontWeight.w400,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14, fontWeight: FontWeight.w400,
      ),
      // Küçük etiketler
      labelSmall: GoogleFonts.plusJakartaSans(
        fontSize: 11, fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    ),
  );
}
```

---

## Adım 2 — Kart Tasarımı (listing_card.dart)

Letgo tarzı kart: büyük fotoğraf, minimal metin, net hiyerarşi.

### Mevcut Sorunlar
- Gölge çok belirgin veya hiç yok
- Fotoğraf oranı tutarsız
- Metin hiyerarşisi zayıf
- Mesafe bilgisi küçük ve kaybolmuş

### Yeni Kart Yapısı

```dart
// Hedef görünüm — Letgo tarzı
Card(
  elevation: 0,                    // Gölge yok, border var
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    side: BorderSide(
      color: Colors.grey.shade200,  // İnce border
      width: 1,
    ),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // 1. Fotoğraf — 4:3 oranında, tam genişlik
      AspectRatio(
        aspectRatio: 4 / 3,
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          child: CachedNetworkImage(fit: BoxFit.cover, ...),
        ),
      ),
      
      // 2. İçerik — sıkışmış değil, nefes alan
      Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık — bold, 2 satır max
            Text(
              listing.title,
              maxLines: 2,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 4),
            
            // "Ne istiyor" — accent rengiyle
            Row(children: [
              Icon(Icons.swap_horiz, size: 14, color: primaryColor),
              SizedBox(width: 4),
              Text(
                listing.wantedItem,
                style: TextStyle(
                  fontSize: 12,
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
              ),
            ]),
            SizedBox(height: 8),
            
            // Alt satır — mesafe + zaman
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Mesafe
                Row(children: [
                  Icon(Icons.location_on, size: 12, color: Colors.grey),
                  Text('2.3 km', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ]),
                // Zaman
                Text('2 saat önce', style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    ],
  ),
)
```

---

## Adım 3 — Ana Sayfa Layout (home_screen.dart)

### Mevcut → Yeni

```
MEVCUT:
[ Arama ]
[ Kategori Chips ]
ListView (tek sütun, büyük kartlar)

YENİ (Letgo tarzı):
[ Arama (daha minimal) ]
[ Kategori Chips (yatay scroll) ]
GridView (2 sütun, kare kartlar) ← en büyük görsel fark
```

### GridView Kodu

```dart
GridView.builder(
  padding: EdgeInsets.all(12),
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,          // 2 sütun
    crossAxisSpacing: 10,
    mainAxisSpacing: 10,
    childAspectRatio: 0.72,     // Fotoğraf + metin için ideal oran
  ),
  itemBuilder: (context, index) => ListingCard(listing: listings[index]),
)
```

---

## Adım 4 — Arama Çubuğu

```dart
// Daha minimal, Letgo tarzı
Container(
  decoration: BoxDecoration(
    color: Colors.grey.shade100,  // Beyaz değil, hafif gri
    borderRadius: BorderRadius.circular(12),
  ),
  child: TextField(
    decoration: InputDecoration(
      hintText: 'Ne arıyorsun?',
      prefixIcon: Icon(Icons.search, color: Colors.grey),
      border: InputBorder.none,
      contentPadding: EdgeInsets.symmetric(vertical: 14),
    ),
  ),
)
```

---

## Adım 5 — theme.dart Kart Teması

```dart
cardTheme: CardThemeData(
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    side: BorderSide(color: Color(0xFFEEEEEE)),
  ),
  color: Colors.white,
),
```

---

## Uygulama Sırası

```
1. google_fonts paketi ekle → flutter pub get
2. theme.dart güncelle (font + kart teması)
3. listing_card.dart yeniden yaz
4. home_screen.dart'ı GridView'a geçir
5. Arama çubuğunu güncelle
6. Uygulamayı çalıştır, gözlemle
```

---

## Ajana Vereceğin Paket

Her adımı ayrı sohbette yap:

### Adım 2 ve 5 için (tema):
```
[first_android_IMPORTANT.md]
[PROJECT_CONTEXT.md]

Mevcut theme.dart:
[dosyayı yapıştır]

Şunu yap:
1. google_fonts paketi eklendi, Plus Jakarta Sans kullan
2. textTheme'i bu plandaki gibi güncelle
3. cardTheme'i elevation:0, border: Color(0xFFEEEEEE) yap
4. Mevcut renklere DOKUNMA
5. Sadece değişen kısımları yaz, tüm dosyayı yeniden yazma
```

### Adım 3 için (kart):
```
[first_android_IMPORTANT.md]
[PROJECT_CONTEXT.md]

Mevcut listing_card.dart:
[dosyayı yapıştır]

Şunu yap:
- Kartı bu plandaki yapıya göre güncelle
- 4:3 fotoğraf oranı
- elevation:0, border ile
- "Ne istiyor" satırını primary renkle göster
- Tüm dosyayı yeniden yazma, sadece değişen kısımları yaz
```

### Adım 4 için (grid):
```
[first_android_IMPORTANT.md]
[PROJECT_CONTEXT.md]

Mevcut home_screen.dart:
[dosyayı yapıştır]

Şunu yap:
- ListView'i GridView'a çevir (crossAxisCount: 2, childAspectRatio: 0.72)
- Arama çubuğunu Colors.grey.shade100 arka planla güncelle
- Başka hiçbir şeye dokunma
```

---

## Önemli Uyarı

Her adımdan sonra uygulamayı çalıştır ve test et.
Bir sonraki adıma geçmeden önce mevcut adımın çalıştığını doğrula.
