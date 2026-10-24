import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
  /// Anda bisa meletakkan file version.json ini di GitHub Releases, Raw GitHub, atau hosting Anda sendiri
  static const String updateJsonUrl =
      'https://raw.githubusercontent.com/renata-tv/releases/main/version.json';

  /// Cek ke server apakah ada update APK baru
  static Future<UpdateInfo?> checkForUpdate() async {
    try {
      final response = await http
          .get(Uri.parse(updateJsonUrl))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final updateInfo = UpdateInfo.fromJson(data);

        // Ambil versi aplikasi saat ini
        final packageInfo = await PackageInfo.fromPlatform();
        final currentCode = int.tryParse(packageInfo.buildNumber) ?? 1;

        if (updateInfo.latestVersionCode > currentCode) {
          return updateInfo;
        }
      }
    } catch (e) {
      debugPrint('Tidak dapat memeriksa pembaruan: $e');
    }
    return null;
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
            return WillPopScope(
              onWillPop: () async => !updateInfo.forceUpdate && !isDownloading,
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
                      onPressed: () => Navigator.pop(ctx),
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
