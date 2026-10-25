// Uji alur "Hapus Playlist Kustom" di layar Pengaturan.
//
// Menguji:
//   1. Tombol hapus hanya muncul ketika ada playlist kustom tersimpan.
//   2. Menekan tombol hapus menghapus URL dari preferensi dan memberi
//      callback ke layar pemanggil.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:renata_tv/screens/settings_screen.dart';
import 'package:renata_tv/services/favorites_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpSettings(
    WidgetTester tester, {
    required VoidCallback onRemoved,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: Brightness.dark),
        home: SettingsScreen(
          onPlaylistLoaded: (_) {},
          onPlaylistRemoved: onRemoved,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('tombol hapus tidak muncul saat belum ada playlist tersimpan',
      (tester) async {
    SharedPreferences.setMockInitialValues({});

    await pumpSettings(tester, onRemoved: () {});

    expect(find.text('Hapus Playlist Kustom & Kembali ke Daftar Bawaan'),
        findsNothing);
  });

  testWidgets('tombol hapus muncul dan menghapus playlist tersimpan',
      (tester) async {
    SharedPreferences.setMockInitialValues(
      {'custom_m3u_url': 'https://example.com/playlist.m3u'},
    );

    var removedCalled = false;
    await pumpSettings(
      tester,
      onRemoved: () => removedCalled = true,
    );

    final resetButton = find.text(
        'Hapus Playlist Kustom & Kembali ke Daftar Bawaan');
    expect(resetButton, findsOneWidget);

    await tester.tap(resetButton);
    await tester.pumpAndSettle();

    // Preferensi sudah dibersihkan.
    expect(await FavoritesService.getCustomM3uUrl(), isNull);
    // Callback ke layar pemanggil dipanggil.
    expect(removedCalled, isTrue);
    // Tombol hapus hilang lagi.
    expect(find.text('Hapus Playlist Kustom & Kembali ke Daftar Bawaan'),
        findsNothing);
  });
}
