import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

/// Memantau status koneksi internet aplikasi.
///
/// Implementasi sengaja memakai timer polling sederhana supaya tidak menambah
/// dependensi baru, namun interval-nya dibuat realistis (bukan beberapa detik)
/// dan polling bisa dihentikan dengan [stopMonitoring] supaya tidak boros
/// daya dan jaringan saat aplikasi tidak aktif.
class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  /// Jeda antar pemeriksaan koneksi. 30 detik cukup untuk mendeteksi perubahan
  /// koneksi di perangkat TV/HP tanpa membanjiri jaringan.
  static const Duration checkInterval = Duration(seconds: 30);

  /// Batas waktu satu kali percobaan lookup DNS.
  static const Duration lookupTimeout = Duration(seconds: 5);

  final ValueNotifier<bool> isOnline = ValueNotifier<bool>(true);

  Timer? _timer;
  bool _isMonitoring = false;

  /// Mulai memantau koneksi internet.
  ///
  /// Aman dipanggil berkali-kali: pemanggilan kedua tidak akan membuat timer
  /// ganda.
  void startMonitoring() {
    if (_isMonitoring) return;
    _isMonitoring = true;

    _checkConnection();
    _timer = Timer.periodic(checkInterval, (_) => _checkConnection());
  }

  /// Hentikan pemantauan. Wajib dipanggil saat widget yang memakainya
  /// dibuang, supaya timer tidak terus berjalan di belakang layar.
  void stopMonitoring() {
    _timer?.cancel();
    _timer = null;
    _isMonitoring = false;
  }

  /// Whether monitoring is currently active.
  bool get isMonitoring => _isMonitoring;

  /// Periksa koneksi sekali secara manual. Mengembalikan true bila internet
  /// sedang bisa dijangkau.
  Future<bool> checkNow() async {
    await _checkConnection();
    return isOnline.value;
  }

  Future<void> _checkConnection() async {
    try {
      final result = await InternetAddress.lookup('dns.google')
          .timeout(lookupTimeout);
      final connected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      _setOnline(connected);
    } on SocketException {
      _setOnline(false);
    } on TimeoutException {
      _setOnline(false);
    } catch (e) {
      debugPrint('Gagal memeriksa koneksi internet: $e');
      _setOnline(false);
    }
  }

  void _setOnline(bool value) {
    if (isOnline.value == value) return;
    isOnline.value = value;
  }
}
