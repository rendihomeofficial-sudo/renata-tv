import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/offline_banner.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Aplikasi mendukung portrait maupun landscape. Library tidak dikunci
  // supaya pengguna bebas memutar HP saat menonton.
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Tampilan tepi-ke-tepi supaya konten memakai seluruh layar, termasuk
  // di mode landscape pada layar yang panjang/tinggi.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const RenataTVApp());
}

class RenataTVApp extends StatelessWidget {
  const RenataTVApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RENATA TV',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.dark,
      builder: (context, child) {
        // Batasi skala teks agar tampilan tetap rapi di HP kecil maupun
        // tablet/TV besar, tanpa membuat teks_small市场份额 tidak terbaca.
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: mediaQuery.textScaler.clamp(
              minScaleFactor: 0.9,
              maxScaleFactor: 1.3,
            ),
          ),
          child: OfflineBannerWrapper(
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      home: const SplashScreen(),
    );
  }
}
