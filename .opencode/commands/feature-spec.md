---
description: "Yeni özellik için spec yaz — koda dokunmadan önce çalıştır"
---

# Görev: Özellik Spesifikasyonu

Özellik: $ARGUMENTS

AGENTS.md'deki proje bağlamını oku. Ardından aşağıdaki başlıkları doldur.
Kod yazma. Yorum ekleme. Sadece analiz et ve yaz.

---

## 1. Kullanıcı Hikayesi
Kullanıcı ne yapabilmeli? Tek cümleyle.

## 2. Etkilenen Dosyalar
Hangi mevcut dosyalar değişecek? Hangi yeni dosyalar oluşacak?
Şu yapıyı kullan:
- DEĞİŞECEK: `dosya/yolu.dart` — neden
- YENİ: `dosya/yolu.dart` — ne için

## 3. Veri Katmanı
- Yeni Firestore collection/field gerekiyor mu?
- Yeni model alanı gerekiyor mu?
- Varsa şemayı yaz (alan adı: tip)

## 4. Provider / State Değişiklikleri
- Yeni provider gerekiyor mu? İsmi ne olacak?
- Mevcut hangi provider'lar etkilenecek?

## 5. Firebase / Servis Gereksinimleri
- Firebase Storage, FCM, Functions gereken var mı?
- Security rules güncellemesi gerekiyor mu?

## 6. Edge Case'ler
En az 3 tane yaz:
- İzin verilmemiş / yetkisiz erişim durumu
- Ağ/internet olmadığında
- Boş state (ilk kullanım, veri yok)

## 7. Geliştirme Sırası
Hangi parça önce yazılmalı? Numaralandır.

## 8. Açık Sorular
Spec sırasında ortaya çıkan belirsizlikleri yaz. Geliştirmeye başlamadan önce bunların cevaplanması gerekiyor.

---

Spec tamamlandığında şunu söyle:
"Spec hazır. /feature-build komutuyla geliştirmeye başlayabilirsin."
