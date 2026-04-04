# ⚠️ KRİTİK — BUNU OKUMADAN KOD YAZMA

## Bu Projenin Platform Durumu

| Platform | Durum | Neden |
|---|---|---|
| ✅ Android | AKTİF GELİŞTİRME PLATFORMU | Elimizde Android cihaz var |
| ✅ Web | İLERİDE eklenecek | Flutter Web olarak |
| ❌ iOS | KAPALI | Mac cihaz yok, build alınamaz |
| ❌ Windows | KAPALI | Flutter Windows build kullanmıyoruz |
| ❌ macOS | KAPALI | Gerekmez |
| ❌ Linux | KAPALI | Gerekmez |

---

## YASAK KOMUTLAR — ASLA KULLANMA

```bash
# ❌ BUNLARI ASLA YAZMA
flutter build windows
flutter build ios
flutter build macos
flutter build linux
flutter run -d windows
flutter run -d macos
```

---

## İZİN VERİLEN KOMUTLAR — SADECE BUNLARI KULLAN

```bash
# ✅ SADECE BUNLARI KULLAN
flutter run                          # Bağlı Android cihazda çalıştır
flutter run -d android               # Android cihazı açıkça belirt
flutter build apk --debug            # Debug APK
flutter build apk --release          # Release APK
flutter build appbundle              # Play Store için
flutter pub get                      # Paket indir
flutter clean                        # Build temizle
dart run build_runner build          # Kod üretimi
```

---

## Komut Yazarken Dikkat Et

Eğer kullanıcıya terminal komutu önereceksen:
- `flutter run` yaz → Android cihazda çalışır, sorun yok
- `flutter build apk` yaz → Android APK üretir, sorun yok
- `flutter build windows` **YAZMA** → Build başarısız olur, zaman kaybı

---

## Geliştirme Ortamı

- **İşletim Sistemi:** Windows
- **Flutter SDK:** `C:\flutter\bin\flutter.bat`
- **Proje Dizini:** `C:\Users\yenik\Desktop\takash\takash`
- **Test Cihazı:** Android (DNP NX9)
- **Android Studio:** Kurulu
- **Xcode:** YOK (Mac yok)

---

## Flutter Komutu Nasıl Çalıştırılır

Bu projede `flutter` komutu PATH'te tanımlı olmayabilir.
Eğer `flutter` çalışmıyorsa tam yolu kullan:

```powershell
C:\flutter\bin\flutter.bat run
C:\flutter\bin\flutter.bat build apk
C:\flutter\bin\flutter.bat pub get
```

---

## iOS İçin Ne Zaman Build Alınabilir?

iOS build için 3 seçenek var — bunlar **MVP sonrası** için planlanmıştır:

1. **Codemagic.io** — Cloud'da iOS build (ayda 500 dakika ücretsiz)
2. **Mac'i olan bir arkadaş** — Tek seferlik build için yeterli
3. **GitHub Actions Mac runner** — CI/CD ile otomatik iOS build

**Şu an için iOS'u düşünme. Android'i bitir.**

---

> Bu dosyayı PROJECT_CONTEXT.md ile birlikte her sohbetin başına ekle.
