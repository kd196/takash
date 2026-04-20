---
description: "Yeni özelliği test et ve doğrula — /feature-build sonrası çalıştır"
---

# Görev: Özellik Doğrulama

Özellik: $ARGUMENTS

AGENTS.md'deki proje bağlamını oku.
Bu oturumdaki /feature-build çıktısını baz al.

Aşağıdaki her maddeyi tek tek kontrol et.
Her madde için: ✅ Tamam / ❌ Eksik / ⚠️ Dikkat yaz.

---

## 1. Kod Kalitesi Kontrolü

- [ ] Model: `toJson` / `fromJson` simetrik mi?
- [ ] Repository: tüm metodlar hata handle ediyor mu?
- [ ] Provider: loading / error / data üç state de var mı?
- [ ] UI: `const` constructor kullanılabilecek widget'larda kullanılmış mı?
- [ ] `print()` veya debug kodu kalmış mı? (kaldır)

## 2. Edge Case Kontrolleri

- [ ] Kullanıcı giriş yapmamışken bu özelliğe erişirse ne olur?
- [ ] İnternet yokken ne olur? (hata mesajı gösteriliyor mu?)
- [ ] Liste boşsa EmptyStateWidget gösteriliyor mu?
- [ ] Fotoğraf/dosya işlemi varsa: dosya çok büyükse ne olur?
- [ ] Aynı işlem iki kez yapılırsa (double tap) ne olur?

## 3. Navigation Kontrolü

- [ ] Yeni route `router.dart`'a eklendi mi?
- [ ] Geri tuşu beklendiği gibi çalışıyor mu?
- [ ] Deep link gerekiyorsa tanımlandı mı?

## 4. Firebase Kontrolü

- [ ] Security rules güncellendi mi?
- [ ] Yeni Firestore sorgusu composite index gerektiriyor mu?
  (Birden fazla `where` + `orderBy` varsa index gerekir)
- [ ] Storage kullanıldıysa path doğru mu?
  (`listing_images/{listingId}/`, `profile_photos/{userId}/`)

## 5. Lokalizasyon

- [ ] Yeni Türkçe string'ler `app_localizations_tr.dart`'a eklendi mi?
- [ ] Hardcoded Türkçe metin kalmadı mı?

## 6. Build Runner

- [ ] Riverpod code generation kullanıldıysa `dart run build_runner build` çalıştırıldı mı?
- [ ] `.g.dart` dosyaları güncellendi mi?

## 7. Regresyon Riski

Değiştirilen dosyaları listele ve şu soruyu sor:
"Bu değişiklik başka bir feature'ı bozabilir mi?"
Etkilenebilecek ekranları veya provider'ları belirt.

---

## Özet Rapor

Kontrollerden sonra şu formatta bir özet yaz:

```
✅ Hazır: [geçen maddeler]
❌ Düzeltilmeli: [eksik maddeler ve kısa açıklama]
⚠️  Dikkat: [risk taşıyan noktalar]
```

Eğer ❌ varsa: "Şu sorunları düzeltelim mi?" diye sor ve düzeltmeye başla.
Eğer tüm maddeler ✅ ise: "Özellik production'a hazır." de.
