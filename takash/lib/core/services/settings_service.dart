import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class SettingsService {
  static const _themeModeKey = 'theme_mode';
  static const _notificationsKey = 'notifications_enabled';
  static const _locationSharingKey = 'location_sharing';
  static const _profileVisibilityKey = 'profile_visibility';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<ThemeMode> getThemeMode() async {
    final prefs = await _prefs;
    final value = prefs.getString(_themeModeKey) ?? 'system';
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await _prefs;
    final value = mode == ThemeMode.light
        ? 'light'
        : mode == ThemeMode.dark
            ? 'dark'
            : 'system';
    await prefs.setString(_themeModeKey, value);
  }

  Future<bool> getNotificationsEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_notificationsKey) ?? true;
  }

  Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_notificationsKey, value);
  }

  Future<bool> getLocationSharing() async {
    final prefs = await _prefs;
    return prefs.getBool(_locationSharingKey) ?? true;
  }

  Future<void> setLocationSharing(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_locationSharingKey, value);
  }

  Future<String> getProfileVisibility() async {
    final prefs = await _prefs;
    return prefs.getString(_profileVisibilityKey) ?? 'public';
  }

  Future<void> setProfileVisibility(String value) async {
    final prefs = await _prefs;
    await prefs.setString(_profileVisibilityKey, value);
  }
}
