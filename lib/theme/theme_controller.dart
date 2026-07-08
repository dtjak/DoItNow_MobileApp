import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Status mode gelap/terang untuk seluruh aplikasi.
///
/// [AppColors] mengambil nilainya berdasarkan [isDark], dan [MyApp]
/// mendengarkan notifier ini untuk membangun ulang seluruh widget tree saat
/// mode berubah, sehingga setiap layar digambar ulang dengan palet yang benar.
class ThemeController extends ValueNotifier<bool> {
  ThemeController._() : super(false);

  static final ThemeController instance = ThemeController._();

  static const String _prefsKey = 'dark_mode_enabled';

  bool get isDark => value;

  /// Memuat preferensi yang tersimpan. Panggil sekali saat aplikasi mulai.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    value = prefs.getBool(_prefsKey) ?? false;
  }

  /// Mengaktifkan/menonaktifkan mode gelap dan menyimpan pilihannya.
  Future<void> setDark(bool enabled) async {
    value = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, enabled);
  }
}
