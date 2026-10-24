import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';
import 'widgets/offline_banner.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

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
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF10131A),
        primaryColor: const Color(0xFFE11D48),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE11D48),
          secondary: Color(0xFFF59E0B),
          surface: Color(0xFF1A1D27),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF141721),
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return OfflineBannerWrapper(
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const SplashScreen(),
    );
  }
}
