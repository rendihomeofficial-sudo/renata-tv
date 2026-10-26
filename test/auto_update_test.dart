// Uji alur auto-update RENATA TV.
//
// Menguji 4 hal yang dipakai AutoUpdateService di aplikasi:
//   1. version.json diambil dari repo GitHub dan isinya valid.
//   2. checkForUpdate() menemukan pembaruan saat aplikasi terpasang versi lama.
//   3. APK rilis bisa diunduh lewat Dio (library yang dipakai aplikasi).
//   4. Dialog pembaruan menampilkan versi + catatan rilis yang benar.
//
// Catatan: test ini memakai jaringan sungguhan (raw.githubusercontent.com dan
// GitHub Releases), jadi butuh koneksi internet.
//
// Penting: test ini SENGAJA tidak meng-hardcode nomor versi. Data versi
// dibaca dari endpoint publik, sehingga rilis baru berikutnya tidak membuat
// test ini gagal. Golden dialog memakai data versi tetap supaya gambar
// golden tidak berubah setiap kali ada rilis baru.

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:renata_tv/services/auto_update_service.dart';

/// flutter_test memasang HttpOverrides global yang memblokir semua request HTTP
/// (selalu balas 400). Mengosongkan override global membuat HttpClient asli
/// dipakai lagi sehingga request ke GitHub bisa benar-benar terjadi.
void enableRealHttp() {
  HttpOverrides.global = null;
}

/// Simulasikan buildNumber aplikasi yang terpasang di HP.
void mockInstalledBuildNumber(String buildNumber) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('dev.fluttercommunity.plus/package_info'),
    (call) async {
      if (call.method == 'getAll') {
        return <String, dynamic>{
          'appName': 'RENATA TV',
          'packageName': 'com.renata.tv',
          'version': '1.0.0',
          'buildNumber': buildNumber,
          'buildSignature': '',
        };
      }
      return null;
    },
  );
}

/// Muat font Windows asli supaya hasil golden bukan kotak-kotak Ahem.
Future<void> loadRealFont() async {
  const candidates = [
    r'C:\Windows\Fonts\arial.ttf',
    r'C:\Windows\Fonts\segoeui.ttf',
    r'C:\Windows\Fonts\calibri.ttf',
  ];
  for (final path in candidates) {
    final file = File(path);
    if (file.existsSync()) {
      final loader = FontLoader('Roboto')
        ..addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
      await loader.load();
      return;
    }
  }
}

/// Data versi tetap untuk golden dialog (tidak bergantung jaringan).
UpdateInfo goldenUpdateInfo() {
  return UpdateInfo(
    latestVersionCode: 5,
    latestVersionName: '1.4.0',
    apkDownloadUrl:
        'https://github.com/rendihomeofficial-sudo/renata-tv/releases/download/v1.4.0/renata-tv-v1.4.0.apk',
    changelog: 'Pembaruan RENATA TV v1.4.0:\n'
        '1. 96 kanal TV Indonesia tambahan yang bisa ditonton langsung.\n'
        '2. Logo kanal disimpan lokal supaya cepat tampil.',
  );
}

/// Ambil data rilis publik yang sedang aktif.
Future<UpdateInfo> fetchPublishedUpdateInfo() async {
  final response =
      await http.get(Uri.parse(AutoUpdateService.updateJsonUrl));
  expect(response.statusCode, 200);
  return UpdateInfo.fromJson(
      Map<String, dynamic>.from(jsonDecode(response.body) as Map));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(enableRealHttp);

  tearDown(enableRealHttp);

  group('Cek versi.json', () {
    test('endpoint versi publik mengembalikan data rilis yang valid',
        () async {
      final info = await fetchPublishedUpdateInfo();

      expect(info.latestVersionCode, greaterThan(0));
      expect(info.latestVersionName, isNotEmpty);
      expect(info.forceUpdate, isFalse);
      expect(info.changelog, isNotEmpty);

      // Tautan download harus menunjuk ke tag rilis yang cocok dengan versi.
      expect(
        info.apkDownloadUrl,
        contains('/releases/download/v${info.latestVersionName}/'),
      );
      expect(info.apkDownloadUrl, endsWith('.apk'));
    });

    test('checkForUpdate menemukan pembaruan saat aplikasi masih versi lama',
        () async {
      final published = await fetchPublishedUpdateInfo();

      // Aplikasi terpasang disimulasikan memakai kode versi paling rendah.
      mockInstalledBuildNumber('1');

      final updateInfo = await AutoUpdateService.checkForUpdate(force: true);

      expect(updateInfo, isNotNull);
      expect(updateInfo!.latestVersionCode, published.latestVersionCode);
      expect(updateInfo.latestVersionName, published.latestVersionName);
      expect(updateInfo.apkDownloadUrl, isNotEmpty);
    });
  });

  group('Unduh APK', () {
    test('Dio bisa mengunduh APK rilis sampai lengkap dengan ukuran benar',
        () async {
      final published = await fetchPublishedUpdateInfo();

      final dio = Dio();
      final dir = Directory.systemTemp.createTempSync('renata_tv_update_test');
      final target = '${dir.path}/renata_tv_update.apk';

      await dio.download(published.apkDownloadUrl, target);

      final file = File(target);
      expect(file.existsSync(), isTrue);

      final size = file.lengthSync();
      // APK rilis selalu berukuran puluhan MB; sanity check minimal 1 MB.
      expect(size, greaterThan(1024 * 1024));

      // Berkas yang terunduh harus APK Android yang sah (arsip ZIP).
      final handle = file.openSync();
      final header = handle.readSync(2);
      handle.closeSync();
      expect(header[0], 0x50); // 'P'
      expect(header[1], 0x4B); // 'K'

      dir.deleteSync(recursive: true);
    });
  });

  group('Dialog pembaruan', () {
    testWidgets('menampilkan versi baru, catatan rilis, dan tombol aksi',
        (tester) async {
      await loadRealFont();

      // Data diambil di luar widget test supaya tidak ada request jaringan
      // di dalam fake async (testWidgets memakai jam palsu).
      UpdateInfo? updateInfo;
      await tester.runAsync(() async {
        updateInfo = await fetchPublishedUpdateInfo();
      });
      expect(updateInfo, isNotNull);
      final UpdateInfo info = updateInfo!;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.dark,
            fontFamily: 'Roboto',
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFE11D48),
              secondary: Color(0xFFF59E0B),
              surface: Color(0xFF1A1D27),
            ),
          ),
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => AutoUpdateService.showUpdateDialog(context, info),
                  child: const Text('Buka Dialog Update'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Buka Dialog Update'));
      await tester.pumpAndSettle();

      // Judul dialog
      expect(find.text('Pembaruan RENATA TV'), findsOneWidget);
      // Versi baru
      expect(find.text('Versi Baru: v${info.latestVersionName}'),
          findsOneWidget);
      // Catatan rilis
      expect(find.textContaining(info.latestVersionName), findsWidgets);
      // Tombol aksi
      expect(find.text('Nanti Saja'), findsOneWidget);
      expect(find.text('Update Otomatis'), findsOneWidget);
    });

    testWidgets('tampilan dialog sesuai golden', (tester) async {
      await loadRealFont();
      final info = goldenUpdateInfo();

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.dark,
            fontFamily: 'Roboto',
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFE11D48),
              secondary: Color(0xFFF59E0B),
              surface: Color(0xFF1A1D27),
            ),
          ),
          home: Builder(
            builder: (context) => Scaffold(
              backgroundColor: const Color(0xFF10131A),
              body: Center(
                child: ElevatedButton(
                  onPressed: () => AutoUpdateService.showUpdateDialog(context, info),
                  child: const Text('Buka Dialog Update'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Buka Dialog Update'));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(AlertDialog),
        matchesGoldenFile('goldens/update_dialog.png'),
      );
    });
  });
}
