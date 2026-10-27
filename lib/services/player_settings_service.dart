import 'package:shared_preferences/shared_preferences.dart';

/// Menyimpan preferensi playback yang bisa diubah pengguna lewat halaman
/// Pengaturan.
class PlayerSettingsService {
  static const String _keyAutoPlayOnOpen = 'auto_play_on_channel_open';

  /// Apakah stream langsung diputar otomatis begitu kanal dibuka.
  ///
  /// Default `true` supaya perilaku aplikasi tidak berubah untuk pengguna
  /// yang belum pernah menyentuh pengaturan ini.
  static Future<bool> getAutoPlayOnOpen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAutoPlayOnOpen) ?? true;
  }

  static Future<void> setAutoPlayOnOpen(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoPlayOnOpen, value);
  }
}
