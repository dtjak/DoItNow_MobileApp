import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global, app-wide dark/light mode state.
///
/// [AppColors] resolves its values against [isDark], and [MyApp] listens to
/// this notifier to rebuild the whole widget tree when the mode changes, so
/// every screen repaints with the correct palette.
class ThemeController extends ValueNotifier<bool> {
  ThemeController._() : super(false);

  static final ThemeController instance = ThemeController._();

  static const String _prefsKey = 'dark_mode_enabled';

  bool get isDark => value;

  /// Load the persisted preference. Call once during app startup.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    value = prefs.getBool(_prefsKey) ?? false;
  }

  /// Toggle/set dark mode and persist the choice.
  Future<void> setDark(bool enabled) async {
    value = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, enabled);
  }
}
