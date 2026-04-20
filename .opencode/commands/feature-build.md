---
description: "Spec'e göre özelliği sırayla uygula — önce /feature-spec çalıştır"
---

# Görev: Özellik Geliştirme

Özellik: $ARGUMENTS

AGENTS.md'deki proje bağlamını oku.
Bu oturumda yapılan /feature-spec çıktısı varsa onu baz al.
Yoksa kullanıcıdan spec dosyasını veya özellik açıklamasını iste.

Aşağıdaki sırayı KESINLIKLE boz ma. Her adımı bitir, sonra diğerine geç.

---

## Adım 1 — Model
- Yeni model gerekiyorsa önce onu yaz
- Mevcut modele alan ekliyorsan önce domain dosyasını güncelle
- `toJson()` / `fromJson()` metodlarını güncelle

## Adım 2 — Repository
- Data katmanına Firestore metodunu yaz
- Hata handling ekle (try/catch, meaningful mesajlar)
- Stream mi, Future mi — spec'e göre karar ver

## Adım 3 — Provider / Controller
- Riverpod provider'ını yaz
- `@riverpod` annotation kullan (riverpod_generator)
- Loading, error, data state'lerini handle et
- Controller ise AsyncNotifier kullan

## Adım 4 — UI
- Screen'i yaz
- `ref.watch` / `ref.read` ayrımına dikkat et (watch: rebuild, read: action)
- Loading state → LoadingIndicator widget'ı kullan
- Error state → ErrorStateWidget kullan
- Boş state → EmptyStateWidget kullan
- Tema renklerini kullan (#1B8C3A primary, #FFB300 accent)

## Adım 5 — Router
- Yeni screen varsa `router.dart`'a ekle
- Route path'i mevcut pattern'e uy: `/feature-adi` veya `/feature-adi/:id`
- Gerekirse redirect logic'i güncelle

## Adım 6 — Firebase Security Rules
- Yeni collection/field varsa rules'u güncelle
- Kural: kullanıcı sadece kendi verisini yazabilmeli
- Okuma kurallarını ayrı düşün

---

## Genel Kurallar
- Windows / iOS build komutu önerme
- `pubspec.yaml`'daki versiyon numaralarını değiştirme
- Her değişiklikten sonra `build_runner` gerekliyse belirt: `dart run build_runner build`
- Türkçe string'leri `app_localizations_tr.dart`'a ekle

---

Geliştirme tamamlandığında şunu söyle:
"Build tamamlandı. /feature-verify ile test adımına geç."
