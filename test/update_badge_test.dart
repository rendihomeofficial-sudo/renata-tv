// Uji badge "Pembaruan Tersedia" di Home Screen.
//
// Menguji 4 hal:
//   1. Badge menampilkan versi baru dan catatan singkat yang benar.
//   2. Tekanan pada badge memanggil callback (membuka dialog pembaruan).
//   3. Animasi denyut benar-benar berjalan (nilai transform ikon berubah).
//   4. Badge otomatis muncul di Home Screen saat versi baru terdeteksi.
//
// Test ini tidak butuh jaringan: HomeScreen menerima fungsi
// `updateChecker` yang di-inject sehingga hasil pengecekan bisa ditentukan
// sendiri. Alur jaringan sungguhan diuji di test/auto_update_test.dart.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:renata_tv/screens/home_screen.dart';
import 'package:renata_tv/services/auto_update_service.dart';
import 'package:renata_tv/widgets/update_badge.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Muat font Windows asli supaya hasil golden tidak berupa kotak-kotak Ahem.
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

UpdateInfo buildUpdateInfo() {
  return UpdateInfo(
    latestVersionCode: 3,
    latestVersionName: '1.2.0',
    apkDownloadUrl:
        'https://github.com/rendihomeofficial-sudo/renata-tv/releases/download/v1.2.0/renata-tv-v1.2.0.apk',
    changelog: 'Pembaruan RENATA TV v1.2.0:\n1. SplashScreen animasi logo.',
    forceUpdate: false,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Widget UpdateBadge', () {
    testWidgets('menampilkan judul, versi baru, dan tombol Perbarui',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: UpdateBadge(
              updateInfo: buildUpdateInfo(),
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Pembaruan Tersedia'), findsOneWidget);
      expect(find.text('Versi v1.2.0 sudah bisa diunduh'), findsOneWidget);
      expect(find.text('Perbarui'), findsOneWidget);
      expect(find.byIcon(Icons.system_update_rounded), findsOneWidget);
    });

    testWidgets('tekan badge memanggil callback', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: UpdateBadge(
              updateInfo: buildUpdateInfo(),
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Pembaruan Tersedia'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('tampilan badge sesuai golden', (tester) async {
      await loadRealFont();
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.dark,
            fontFamily: 'Roboto',
          ),
          home: Scaffold(
            backgroundColor: const Color(0xFF10131A),
            body: UpdateBadge(
              updateInfo: buildUpdateInfo(),
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await expectLater(
        find.byType(UpdateBadge),
        matchesGoldenFile('goldens/update_badge.png'),
      );
    });

    testWidgets('animasi denyut berjalan (ikon berubah ukuran)',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: UpdateBadge(
              updateInfo: buildUpdateInfo(),
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      double badgeScale() {
        final transform = tester.widget<Transform>(
          find.byKey(const Key('update-badge-pulse')),
        );
        return transform.transform.getMaxScaleOnAxis();
      }

      final scaleAwal = badgeScale();
      await tester.pump(const Duration(milliseconds: 650));
      final scaleTengah = badgeScale();
      await tester.pump(const Duration(milliseconds: 650));
      final scaleAkhir = badgeScale();

      // Nilai skala harus berubah - bukti animasi denyut berjalan.
      expect(scaleTengah, isNot(equals(scaleAwal)));
      expect(scaleAkhir, isNot(equals(scaleTengah)));
    });
  });

  group('Integrasi Home Screen', () {
    testWidgets('badge otomatis muncul saat versi baru terdeteksi',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(
            updateChecker: () async => buildUpdateInfo(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Sebelum pengecekan selesai badge belum ada.
      expect(find.byType(UpdateBadge), findsNothing);

      // Tunggu jeda pengecekan (1200 ms) + animasi masuk badge.
      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(UpdateBadge), findsOneWidget);
      expect(find.text('Pembaruan Tersedia'), findsOneWidget);
      expect(find.text('Versi v1.2.0 sudah bisa diunduh'), findsOneWidget);

      // Dialog pembaruan ikut dibuka otomatis.
      expect(find.text('Pembaruan RENATA TV'), findsOneWidget);
    });

    testWidgets('badge tidak muncul saat aplikasi sudah versi terbaru',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(
            updateChecker: () async => null,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(UpdateBadge), findsNothing);
      expect(find.text('Pembaruan RENATA TV'), findsNothing);
    });

    testWidgets('titik merah pada ikon AppBar muncul saat ada versi baru',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(
            updateChecker: () async => buildUpdateInfo(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pump(const Duration(milliseconds: 400));

      // Titik merah penanda ada versi baru pada ikon AppBar.
      expect(find.byKey(const Key('update-appbar-dot')), findsOneWidget);

      // Tutup dialog pembaruan otomatis supaya AppBar terlihat penuh.
      await tester.tap(find.text('Nanti Saja'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Badge tetap ada setelah dialog ditutup.
      expect(find.byType(UpdateBadge), findsOneWidget);
      expect(find.byKey(const Key('update-appbar-dot')), findsOneWidget);
    });
  });
}
