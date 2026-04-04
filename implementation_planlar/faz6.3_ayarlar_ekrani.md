# Faz 6.3 — Ayarlar Ekranı

## Amaç
Profil sayfasındaki logout butonunu kaldırıp, tüm ayarları tek bir SettingsScreen'de toplamak.

---

## Değişecek Dosyalar

| Dosya | Değişiklik |
|-------|-----------|
| `pubspec.yaml` | `shared_preferences: ^2.3.0` ekle |
| `lib/core/services/settings_service.dart` | Yeni — SharedPreferences wrapper |
| `lib/core/providers/theme_provider.dart` | Yeni — Tema durumu provider'ı |
| `lib/features/profile/presentation/settings_screen.dart` | Yeni — Ayarlar sayfası |
| `lib/features/profile/presentation/profile_screen.dart` | Logout kaldır, settings ikonu ekle |
| `lib/app/router.dart` | `/settings` route ekle |
| `lib/main.dart` | themeMode'u Riverpod'dan oku |

---

## 1. pubspec.yaml

```yaml
shared_preferences: ^2.3.0
```

---

## 2. settings_service.dart

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class SettingsService {
  static const _themeModeKey = 'theme_mode';
  static const _notificationsKey = 'notifications_enabled';
  static const _locationSharingKey = 'location_sharing';
  static const _profileVisibilityKey = 'profile_visibility';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // Tema
  Future<ThemeMode> getThemeMode() async {
    final prefs = await _prefs;
    final value = prefs.getString(_themeModeKey) ?? 'system';
    switch (value) {
      case 'light': return ThemeMode.light;
      case 'dark': return ThemeMode.dark;
      default: return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await _prefs;
    final value = mode == ThemeMode.light ? 'light'
        : mode == ThemeMode.dark ? 'dark' : 'system';
    await prefs.setString(_themeModeKey, value);
  }

  // Bildirimler
  Future<bool> getNotificationsEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_notificationsKey) ?? true;
  }

  Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_notificationsKey, value);
  }

  // Konum Paylaşımı
  Future<bool> getLocationSharing() async {
    final prefs = await _prefs;
    return prefs.getBool(_locationSharingKey) ?? true;
  }

  Future<void> setLocationSharing(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_locationSharingKey, value);
  }

  // Profil Görünürlüğü
  Future<String> getProfileVisibility() async {
    final prefs = await _prefs;
    return prefs.getString(_profileVisibilityKey) ?? 'public';
  }

  Future<void> setProfileVisibility(String value) async {
    final prefs = await _prefs;
    await prefs.setString(_profileVisibilityKey, value);
  }
}
```

---

## 3. theme_provider.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/settings_service.dart';

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref.read(settingsServiceProvider));
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SettingsService _service;

  ThemeModeNotifier(this._service) : super(ThemeMode.system) {
    _loadInitialTheme();
  }

  Future<void> _loadInitialTheme() async {
    final mode = await _service.getThemeMode();
    state = mode;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _service.setThemeMode(mode);
    state = mode;
  }
}
```

---

## 4. settings_screen.dart

```
Section'lar:
┌─────────────────────────────────┐
│ 👤 HESAP                         │
│ ├─ E-posta Değiştir             │
│ └─ Şifre Değiştir               │
├─────────────────────────────────┤
│ 🎨 GÖRÜNÜM                       │
│ └─ Tema (Light/Dark/System)     │
├─────────────────────────────────┤
│ 🔔 BİLDİRİMLER                   │
│ └─ Push Bildirimleri (Switch)   │
├─────────────────────────────────┤
│ 🔒 GİZLİLİK                      │
│ ├─ Konum Paylaşımı (Switch)     │
│ └─ Profil Görünürlüğü (Switch)  │
├─────────────────────────────────┤
│ ❓ DESTEK                        │
│ ├─ Yardım Merkezi               │
│ └─ Bize Ulaşın                  │
├─────────────────────────────────┤
│ ℹ️ HAKKINDA                      │
│ ├─ Versiyon                     │
│ └─ Gizlilik Politikası          │
├─────────────────────────────────┤
│ 🚪 ÇIKIŞ YAP (kırmızı buton)    │
└─────────────────────────────────┘
```

---

## 5. profile_screen.dart Değişiklikleri

```dart
// AppBar'dan logout kaldır
appBar: AppBar(
  title: Text(isMe ? 'Profilim' : 'Kullanıcı Profili'),
  actions: [
    if (isMe)
      IconButton(
        icon: const Icon(Icons.settings),
        onPressed: () => context.push('/settings'),
      ),
  ],
),
```

---

## 6. router.dart Değişiklikleri

```dart
GoRoute(
  path: '/settings',
  builder: (context, state) => const SettingsScreen(),
),
```

---

## 7. main.dart Değişiklikleri

```dart
// ProviderScope içinde themeMode'u izle
final themeMode = ref.watch(themeModeProvider);
MaterialApp(
  themeMode: themeMode,
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
)
```

---

## Uygulama Sırası

1. `pubspec.yaml` + `flutter pub get`
2. `settings_service.dart` oluştur
3. `theme_provider.dart` oluştur
4. `settings_screen.dart` oluştur
5. `profile_screen.dart` güncelle
6. `router.dart` güncelle
7. `main.dart` güncelle
8. Build + test
