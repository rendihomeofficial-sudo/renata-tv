// Uji alur auto-update: kasus aplikasi sudah versi terbaru.
//
// Dipisah dalam file sendiri karena PackageInfo.fromPlatform() melakukan cache
// statis per isolate, sedangkan flutter test menjalankan tiap file di isolate
// terpisah.

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:renata_tv/services/auto_update_service.dart';

/// Mengosongkan override HTTP global milik flutter_test supaya request HTTP
/// sungguhan (ke GitHub) bisa dilakukan.
void enableRealHttp() {
  HttpOverrides.global = null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    enableRealHttp();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/package_info'),
      (call) async {
        if (call.method == 'getAll') {
          return <String, dynamic>{
            'appName': 'RENATA TV',
            'packageName': 'com.renata.tv',
            'version': '1.2.0',
            'buildNumber': '3',
            'buildSignature': '',
          };
        }
        return null;
      },
    );
  });

  tearDown(enableRealHttp);

  test('checkForUpdate mengembalikan null saat aplikasi sudah versi terbaru',
      () async {
    final updateInfo = await AutoUpdateService.checkForUpdate();
    expect(updateInfo, isNull);
  });
}
