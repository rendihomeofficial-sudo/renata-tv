// Uji alur auto-update: kasus aplikasi sudah versi terbaru.
//
// Dipisah dalam file sendiri karena PackageInfo.fromPlatform() melakukan cache
// statis per isolate, sedangkan flutter test menjalankan tiap file di isolate
// terpisah.
//
// Angka versi TIDAK di-hardcode di sini. Build number yang disimulasikan
// diambil dari version.json publik, sehingga test ini tetap benar untuk
// rilis apa pun yang sedang aktif.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:renata_tv/services/auto_update_service.dart';

/// Mengosongkan override HTTP global milik flutter_test supaya request HTTP
/// sungguhan (ke GitHub) bisa dilakukan.
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(enableRealHttp);

  tearDown(enableRealHttp);

  test('checkForUpdate mengembalikan null saat aplikasi sudah versi terbaru',
      () async {
    final response =
        await http.get(Uri.parse(AutoUpdateService.updateJsonUrl));
    expect(response.statusCode, 200);

    final published = jsonDecode(response.body) as Map<String, dynamic>;
    final latestCode = published['latestVersionCode'] as int;

    // Aplikasi terpasang disimulasikan sudah memakai kode versi terbaru.
    mockInstalledBuildNumber('$latestCode');

    final updateInfo = await AutoUpdateService.checkForUpdate(force: true);

    expect(updateInfo, isNull);
  });
}
