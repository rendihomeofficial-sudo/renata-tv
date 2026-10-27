// Uji pengaturan "Auto play saat membuka kanal".
//
// Menguji:
//   1. Default preferensi adalah nyala (belum pernah diubah pengguna).
//   2. Nilai preferensi bisa disimpan dan dibaca kembali.
//   3. Sakelar di halaman Pengaturan menampilkan nilai yang tersimpan dan
//      mengubahnya ketika ditekan.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:renata_tv/screens/settings_screen.dart';
import 'package:renata_tv/services/player_settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpSettings(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: Brightness.dark),
        home: SettingsScreen(onPlaylistLoaded: (_) {}),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Sakelar "Auto play saat membuka kanal" pada halaman Pengaturan.
  Finder findAutoPlaySwitch() {
    return find.descendant(
      of: find.widgetWithText(SwitchListTile, 'Auto play saat membuka kanal'),
      matching: find.byType(Switch),
    );
  }

  test('auto play aktif secara bawaan', () async {
    SharedPreferences.setMockInitialValues({});
    expect(await PlayerSettingsService.getAutoPlayOnOpen(), isTrue);
  });

  test('preferensi auto play tersimpan dan dibaca kembali', () async {
    SharedPreferences.setMockInitialValues({});

    await PlayerSettingsService.setAutoPlayOnOpen(false);
    expect(await PlayerSettingsService.getAutoPlayOnOpen(), isFalse);

    await PlayerSettingsService.setAutoPlayOnOpen(true);
    expect(await PlayerSettingsService.getAutoPlayOnOpen(), isTrue);
  });

  testWidgets('sakelar di Pengaturan mengikuti nilai yang tersimpan',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await pumpSettings(tester);

    await tester.scrollUntilVisible(
      findAutoPlaySwitch(),
      120,
      scrollable: find.byType(Scrollable).first,
    );

    final toggle = tester.widget<Switch>(findAutoPlaySwitch());
    expect(toggle.value, isTrue);
  });

  testWidgets('menyalakan dan mematikan sakelar menyimpan preferensi',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await pumpSettings(tester);

    await tester.scrollUntilVisible(
      findAutoPlaySwitch(),
      120,
      scrollable: find.byType(Scrollable).first,
    );

    // Matikan auto play.
    await tester.tap(findAutoPlaySwitch());
    await tester.pumpAndSettle();
    expect(await PlayerSettingsService.getAutoPlayOnOpen(), isFalse);
    expect(tester.widget<Switch>(findAutoPlaySwitch()).value, isFalse);

    // Nyalakan kembali.
    await tester.tap(findAutoPlaySwitch());
    await tester.pumpAndSettle();
    expect(await PlayerSettingsService.getAutoPlayOnOpen(), isTrue);
    expect(tester.widget<Switch>(findAutoPlaySwitch()).value, isTrue);
  });
}
