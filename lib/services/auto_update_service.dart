import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'network_service.dart';

class UpdateInfo {
  final int latestVersionCode;
  final String latestVersionName;
  final String apkDownloadUrl;
  final String changelog;
  final bool forceUpdate;

  UpdateInfo({
    required this.latestVersionCode,
    required this.latestVersionName,
    required this.apkDownloadUrl,
    required this.changelog,
    this.forceUpdate = false,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      latestVersionCode: json['latestVersionCode'] ?? 1,
      latestVersionName: json['latestVersionName'] ?? '1.0.0',
      apkDownloadUrl: json['apkDownloadUrl'] ?? '',
      changelog: json['changelog'] ?? 'Pembaruan versi terbaru RENATA TV',
      forceUpdate: json['forceUpdate'] ?? false,
    );
  }
}

class AutoUpdateService {
  /// URL endpoint JSON untuk cek update APK versi terbaru
  /// Terhubung ke repository GitHub resmi pengguna: rendihomeofficial-sudo/renata-tv
  static const String updateJsonUrl =
      'https://raw.githubusercontent.com/rendihomeofficial-sudo/renata-tv/main/version.json';

  /// Batas waktu satu kali permintaan ke server versi.
  static const Duration requestTimeout = Duration(seconds: 8);

  /// Lamanya hasil pengecekan terakhir dianggap masih relevan.
  static const Duration cacheDuration = Duration(minutes: 10);

  /// Awalan key preferensi untuk menandai dialog pembaruan yang sudah ditolak.
  static const String _dismissedKeyPrefix = 'update_dialog_dismissed_';

  /// Waktu pengecekan terakhir (untuk cache) dan hasilnya.
  static DateTime? _lastCheckAt;
  static UpdateInfo? _lastCheckResult;

  /// Cek ke server apakah ada update APK baru.
  ///
  /// - Dilewati bila perangkat sedang offline (hemat kuota dan tidak menunda
  ///   tampilan aplikasi).
  /// - Hasil disimpan sebentar ([cacheDuration]) agar tidak mengecekan server
  ///   setiap kali Home Screen dibangun ulang.
  /// - Gunakan [force] = true untuk memaksa pengecekan baru (misalnya saat
  ///   pengguna menekan tombol "Cek Pembaruan" di AppBar).
  static Future<UpdateInfo?> checkForUpdate({bool force = false}) async {
    final networkService = NetworkService();
    if (!networkService.isOnline.value) {
      debugPrint('Pengecekan pembaruan dilewati: perangkat sedang offline.');
      return null;
    }

    if (!force &&
        _lastCheckAt != null &&
        DateTime.now().difference(_lastCheckAt!) < cacheDuration) {
      return _lastCheckResult;
    }

    try {
      final response = await http
          .get(Uri.parse(updateJsonUrl))
          .timeout(requestTimeout);

      if (response.statusCode != 200) {
        debugPrint('Pengecekan pembaruan gagal: status ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body);
      final updateInfo = UpdateInfo.fromJson(data);

      // Ambil versi aplikasi saat ini
      final packageInfo = await PackageInfo.fromPlatform();
      final currentCode = int.tryParse(packageInfo.buildNumber) ?? 1;

      UpdateInfo? result;
      if (updateInfo.latestVersionCode > currentCode) {
        result = updateInfo;
      }

      _lastCheckAt = DateTime.now();
      _lastCheckResult = result;
      return result;
    } catch (e) {
      debugPrint('Tidak dapat memeriksa pembaruan: $e');
    }
    return null;
  }

  /// Apakah dialog pembaruan untuk versi tertentu sudah pernah ditolak
  /// pengguna? dipakai agar dialog tidak muncul otomatis setiap kali aplikasi
  /// dibuka (badge "Pembaruan Tersedia" tetap ditampilkan).
  static Future<bool> isUpdateDialogDismissed(int versionCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('$_dismissedKeyPrefix$versionCode') ?? false;
    } catch (e) {
      debugPrint('Gagal membaca status dialog pembaruan: $e');
      return false;
    }
  }

  /// Tandai dialog pembaruan versi tertentu sebagai sudah ditolak.
  static Future<void> markUpdateDialogDismissed(int versionCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('$_dismissedKeyPrefix$versionCode', true);
    } catch (e) {
      debugPrint('Gagal menyimpan status dialog pembaruan: $e');
    }
  }

  /// Daftar kode versi yang dialog pembaruan-nya sudah ditolak pengguna.
  ///
  /// Dipanggil sekali saat aplikasi dibuka agar pengecekan pembaruan tetap
  /// sinkron (tidak menambah jeda pada alur buka aplikasi).
  static Future<Set<int>> loadDismissedUpdateCodes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final result = <int>{};
      for (final key in prefs.getKeys()) {
        if (!key.startsWith(_dismissedKeyPrefix)) continue;
        final code = int.tryParse(key.substring(_dismissedKeyPrefix.length));
        if (code != null && (prefs.getBool(key) ?? false)) {
          result.add(code);
        }
      }
      return result;
    } catch (e) {
      debugPrint('Gagal membaca daftar pembaruan yang ditolak: $e');
      return <int>{};
    }
  }

  /// Menampilkan Pop-Up Dialog Update Otomatis kepada pengguna
  static void showUpdateDialog(BuildContext context, UpdateInfo updateInfo) {
    showDialog(
      context: context,
      barrierDismissible: !updateInfo.forceUpdate,
      builder: (BuildContext ctx) {
        double downloadProgress = 0.0;
        bool isDownloading = false;
        String statusText = 'Versi baru tersedia!';

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return PopScope(
              canPop: !updateInfo.forceUpdate && !isDownloading,
              child: AlertDialog(
                backgroundColor: const Color(0xFF1E222A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Colors.redAccent, width: 1.5),
                ),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.system_update_rounded,
                          color: Colors.redAccent, size: 26),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Pembaruan RENATA TV',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Versi Baru: v${updateInfo.latestVersionName}',
                      style: const TextStyle(
                        color: Colors.amberAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Catatan Pembaruan:',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        updateInfo.changelog,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (isDownloading) ...[
                      LinearProgressIndicator(
                        value: downloadProgress,
                        color: Colors.redAccent,
                        backgroundColor: Colors.white12,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            statusText,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                          ),
                          Text(
                            '${(downloadProgress * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ]
                  ],
                ),
                actions: [
                  if (!updateInfo.forceUpdate && !isDownloading)
                    TextButton(
                      onPressed: () {
                        // Simpan status "ditolak" supaya dialog tidak muncul
                        // otomatis lagi di sesi berikutnya.
                        markUpdateDialogDismissed(
                            updateInfo.latestVersionCode);
                        Navigator.pop(ctx);
                      },
                      child: const Text('Nanti Saja',
                          style: TextStyle(color: Colors.white54)),
                    ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: isDownloading
                        ? null
                        : () async {
                            setDialogState(() {
                              isDownloading = true;
                              statusText = 'Mengunduh APK pembaruan...';
                            });

                            final file = await _downloadAndInstallApk(
                              updateInfo.apkDownloadUrl,
                              onProgress: (received, total) {
                                if (total > 0) {
                                  setDialogState(() {
                                    downloadProgress = received / total;
                                  });
                                }
                              },
                            );

                            if (file != null) {
                              setDialogState(() {
                                statusText = 'Membuka installer APK...';
                              });
                              await OpenFilex.open(file.path);
                            } else {
                              setDialogState(() {
                                isDownloading = false;
                                statusText = 'Gagal mengunduh APK!';
                              });
                            }
                          },
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: Text(isDownloading ? 'Mengunduh...' : 'Update Otomatis'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Download file APK langsung ke memori HP dan jalankan installer Android
  static Future<File?> _downloadAndInstallApk(
    String downloadUrl, {
    required void Function(int received, int total) onProgress,
  }) async {
    try {
      // Cek dan minta izin instalasi aplikasi tidak dikenal
      if (Platform.isAndroid) {
        final installPermission = await Permission.requestInstallPackages.status;
        if (!installPermission.isGranted) {
          await Permission.requestInstallPackages.request();
        }
      }

      final dir = await getExternalStorageDirectory() ??
          await getTemporaryDirectory();
      final savePath = '${dir.path}/renata_tv_update.apk';

      final file = File(savePath);
      if (await file.exists()) {
        await file.delete();
      }

      final dio = Dio();
      await dio.download(
        downloadUrl,
        savePath,
        onReceiveProgress: onProgress,
      );

      return File(savePath);
    } catch (e) {
      debugPrint('Error downloading update: $e');
      return null;
    }
  }
}
