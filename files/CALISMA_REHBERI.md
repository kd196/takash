# 🤖 Yapay Zeka ile Çalışma Rehberi
## (Agentic Workflow Kullanım Kılavuzu)

---

## Bu Sistem Nedir?

Sen yapay zekayı bir **asistan geliştirici** gibi kullanacaksın.
Ama yapay zekanın her sohbette hafızası sıfırlanır — bu dosyalar onun "hafızası" olacak.

Her sohbette doğru dosyaları yapıştırırsan, yapay zeka projenin tamamını biliyor gibi davranır ve çok daha iyi kod üretir.

---

## 🆕 OTOMATİK SKILL SEÇİM SİSTEMİ

Artık hangi skill dosyasını kullanacağını düşünmene gerek yok!

### Nasıl Çalışır?

1. **Yeni bir sohbet aç**
2. **Sadece `AUTO_SKILL_DETECTOR.md` içeriğini yapıştır**
3. **İsteğini yaz** — AI otomatik olarak doğru skill dosyasını seçecek

AI, isteğindeki anahtar kelimelere bakarak hangi faz/özellik ile ilgili olduğunu anlayacak ve ilgili skill dosyasını otomatik okuyacak.

### Örnek Kullanım

```
[AUTO_SKILLL_DETECTOR.md içeriğini yapıştır]

Bana chat_detail_screen.dart'ta mesaj silme özelliği ekle.
```

→ AI otomatik olarak `skill_faz4_chat.md` dosyasını yükleyecek ve doğru bağlamla kod üretecek.

---

## Manuel Kullanım (İstersen)

Eğer hangi skill dosyasını kullanacağını biliyorsan, doğrudan o dosyayı da yapıştırabilirsin:

| Dosya | Ne Zaman Kullanılır |
|-------|---------------------|
| `PROJECT_CONTEXT.md` | **Her sohbetin başında** — her zaman |
| `AUTO_SKILL_DETECTOR.md` | **Tek dosya ile otomatik seçim** (önerilen) |
| `skill_faz1_infrastructure.md` | Auth, tema, router, navigation, main.dart, providers |
| `skill_faz2_listings.md` | İlan oluşturma, listeleme, favoriler, filtreleme |
| `skill_faz3_map.md` | Harita, konum, geofencing, marker'lar |
| `skill_faz4_chat.md` | Sohbet, mesajlaşma, resim gönderme |
| `skill_faz5_rating.md` | Puanlama, profil, ayarlar |
| `skill_faz6_notifications.md` | Bildirimler, FCM, ayarlar ekranı |
| `skill_faz7_testing.md` | Test yazma, CI/CD, GitHub Actions |
| `skill_security_rules.md` | Firestore/Storage güvenlik kuralları |
| `skill_error_handling.md` | Hata yönetimi, logging, Crashlytics |
| `skill_analytics.md` | Firebase Analytics, event tracking |

---

## Altın Kurallar

### ✅ Yap
- Her sohbette PROJECT_CONTEXT.md'yi yapıştır (veya AUTO_SKILL_DETECTOR.md)
- İlgili skill dosyasını da ekle (manuel kullanımda)
- Tek seferde tek bir ekran veya özellik iste
- Hata aldığında aynı sohbette düzeltmesini iste
- "Bunu neden böyle yaptın?" diye sor, öğren

### ❌ Yapma
- "Tüm uygulamayı yaz" deme — çok geniş, kalitesiz çıkar
- Üretilen kodu anlamadan kopyalama
- Paket versiyonlarını kontrol etmeden kullanma
- Aynı sohbette çok farklı konulara geçme

---

## İstek Yazma Şablonları

### Yeni ekran oluştururken:
```
[Auto Skill Detector veya Bağlam dosyaları yapıştırıldı]

[ekran_adı].dart dosyasını oluştur.
Bu ekranda şunlar olmalı: [liste]
State yönetimi: Riverpod
Stil: Material Design 3
Navigasyon: GoRouter
```

### Hata düzeltirken:
```
[Auto Skill Detector veya Bağlam dosyaları yapıştırıldı]

Şu dosyada hata var: [dosya_adı].dart
Hata: [hata mesajı]
Mevcut kod:
[kodu yapıştır]

Düzelt ve açıkla.
```

---

## Yapay Zeka Modeli Seçimi

| Model | Ne Zaman Kullan |
|-------|-----------------|
| **Claude Sonnet** | Günlük kod yazma, hata düzeltme |
| **Claude Opus** | Karmaşık mimari kararlar, zor buglar |

---

## Haftalık Rutin Önerisi

| Gün | Ne Yapılır |
|-----|-----------|
| Pazartesi | DEVELOPMENT_PLAN.md'ye bak, o hafta ne yapacağını planla |
| Salı-Perşembe | Günde 1-2 özellik implement et |
| Cuma | Yazdıklarını test et, hataları düzelt |
| Cumartesi | DEVELOPMENT_PLAN.md'deki tamamlananları işaretle |

---

## Skill Dosyalarını Güncelleme

Bir özelliği bitirince **o skill dosyasına notlar ekle:**
```markdown
## ✅ Tamamlandı (Tarih: XX/XX/XXXX)
- create_listing_screen.dart oluşturuldu
- listing_repository.dart yazıldı
- Karşılaşılan sorun: image_picker iOS izni
- Çözüm: Info.plist'e NSPhotoLibraryUsageDescription eklendi
```

Bu notlar ileride aynı konuya döndüğünde çok işe yarar.
