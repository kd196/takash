import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/settings_service.dart';

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
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
