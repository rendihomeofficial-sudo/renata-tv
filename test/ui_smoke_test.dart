// Uji cepat tampilan (smoke test) untuk desain ulang v1.5.0.
//
// Menguji 4 hal yang berkaitan dengan tampilan yang diperbarui:
//   1. Splash Screen menampilkan judul, tagline, dan logo tanpa error.
//   2. Animasi logo di splash benar-benar berjalan (nilai scale berubah).
//   3. Home Screen tampil tanpa error overflow di mode landscape (TV/tablet).
//   4. Home Screen tampil tanpa error overflow di mode portrait (HP).
//
// Test ini tidak butuh jaringan: HomeScreen menerima `updateChecker` yang
// di-inject sehingga pengecekan pembaruan tidak memanggil server.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:renata_tv/screens/home_screen.dart';
import 'package:renata_tv/screens/splash_screen.dart';
import 'package:renata_tv/theme/app_theme.dart';
import 'package:renata_tv/widgets/channel_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Splash Screen', () {
    testWidgets('menampilkan judul, tagline, dan logo tanpa error',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const SplashScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 900));

      expect(find.text('RENATA TV'), findsOneWidget);
      expect(find.text('Siaran TV Indonesia · Bebas & Jernih'), findsOneWidget);
      expect(find.byType(ScaleTransition), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('animasi logo berjalan (scale berubah antar frame)',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const SplashScreen(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 150));

      final first = tester
          .widget<ScaleTransition>(find.byType(ScaleTransition).first)
          .scale
          .value;

      await tester.pump(const Duration(milliseconds: 400));

      final second = tester
          .widget<ScaleTransition>(find.byType(ScaleTransition).first)
          .scale
          .value;

      expect(second, isNot(first));
    });
  });

  group('Home Screen', () {
    testWidgets('tampil tanpa error di mode landscape (1280x720)',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: HomeScreen(updateChecker: () async => null),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('RENATA TV'), findsOneWidget);
      expect(find.text('Live Streaming Siaran TV Indonesia'), findsOneWidget);
      expect(find.byType(ChannelCard), findsWidgets);

      // Tunggu timer jeda pengecekan pembaruan (1200 ms) selesai supaya tidak
      // ada timer menggantung saat widget tree dibuang.
      await tester.pump(const Duration(milliseconds: 1500));
      expect(tester.takeException(), isNull);
    });

    testWidgets('tampil tanpa error di mode portrait (390x844)',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: HomeScreen(updateChecker: () async => null),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(ChannelCard), findsWidgets);

      // Tunggu timer jeda pengecekan pembaruan (1200 ms) selesai supaya tidak
      // ada timer menggantung saat widget tree dibuang.
      await tester.pump(const Duration(milliseconds: 1500));
      expect(tester.takeException(), isNull);
    });
  });
}
