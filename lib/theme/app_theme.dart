import 'package:flutter/material.dart';

/// Sistem desain RENATA TV.
///
/// Semua warna, radius, danBayangan aplikasi dikumpulkan di sini supaya
/// tampilan antar layar konsisten dan mudah dipelihara.
class AppColors {
  AppColors._();

  // Latar
  static const Color background = Color(0xFF070A11);
  static const Color backgroundSoft = Color(0xFF0B1018);
  static const Color surface = Color(0xFF111721);
  static const Color surfaceElevated = Color(0xFF18202D);
  static const Color surfaceMuted = Color(0xFF212B3B);
  static const Color surfaceGlass = Color(0xCC141B27);

  // Aksen utama
  static const Color primary = Color(0xFFE11D48);
  static const Color primaryLight = Color(0xFFF87171);
  static const Color primaryDark = Color(0xFF9F1239);
  static const Color accent = Color(0xFF38BDF8);
  static const Color gold = Color(0xFFE8B44A);

  // Teks
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF9AA7BD);
  static const Color textMuted = Color(0xFF64748B);

  // Garis & status
  static const Color border = Color(0x14FFFFFF);
  static const Color borderStrong = Color(0x2EFFFFFF);
  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFBBF24);
  static const Color live = Color(0xFFF43F5E);

  /// Gradien latar bergradasi yang dipakai di header.
  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF1A2130), Color(0xFF0A0E16)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Gradien aksen untuk tombol utama dan logo.
  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFFFF4D6D), Color(0xFFB3123C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradien premium: merah tua -> ungu -> hitam. Dipakai pada banner
  /// hero supaya latar terasa berkelas, bukan sekadar warna solid.
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF3A0E1E), Color(0xFF1B1029), Color(0xFF0A0E16)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradien emas untuk aksen premium sekunder (misalnya lencana).
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF7D488), Color(0xFFCE9A31)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradien permukaan "kaca" untuk panel dan kartu.
  static const LinearGradient glassGradient = LinearGradient(
    colors: [Color(0x1FFFFFFF), Color(0x08FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Skala spasi standar supaya jarak antar-elemen konsisten.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
}

/// Radius sudut yang dipakai konsisten di seluruh aplikasi.
class AppRadius {
  AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 22;
  static const double pill = 999;
}

/// Bayangan halus untuk elevasi kartu.
class AppShadows {
  AppShadows._();

  static List<BoxShadow> soft({
    Color color = Colors.black,
    double opacity = 0.25,
    double blur = 14,
    double offsetY = 4,
  }) {
    return [
      BoxShadow(
        color: color.withOpacity(opacity),
        blurRadius: blur,
        offset: Offset(0, offsetY),
      ),
    ];
  }

  /// Bayangan elevasi tinggi: dua lapis supaya terasa "naif" seperti
  /// material yang naik dari latar, bukan sekadar blur satu lapis.
  static List<BoxShadow> elevated({
    double opacity = 0.45,
    double blur = 28,
    double offsetY = 10,
  }) {
    return [
      BoxShadow(
        color: Colors.black.withOpacity(opacity * 0.7),
        blurRadius: blur * 0.5,
        offset: Offset(0, offsetY * 0.4),
      ),
      BoxShadow(
        color: Colors.black.withOpacity(opacity),
        blurRadius: blur,
        offset: Offset(0, offsetY),
      ),
    ];
  }

  /// Cahaya lembut warna merek di sekeliling elemen (state fokus/tertekan).
  static List<BoxShadow> glow(Color color, {double opacity = 0.35}) {
    return [
      BoxShadow(
        color: color.withOpacity(opacity),
        blurRadius: 22,
        spreadRadius: -4,
        offset: const Offset(0, 6),
      ),
    ];
  }
}

/// Tema gelap aplikasi.
class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.accent,
      onSecondary: Color(0xFF04212E),
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: Color(0xFFF87171),
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ).copyWith(
        headlineLarge: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.9,
          height: 1.15,
        ),
        headlineMedium: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.7,
          height: 1.2,
        ),
        headlineSmall: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
        titleLarge: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        titleMedium: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        titleSmall: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.1,
        ),
        bodyLarge: const TextStyle(
          fontSize: 14.5,
          height: 1.5,
          color: AppColors.textSecondary,
        ),
        bodyMedium: const TextStyle(
          fontSize: 13.5,
          height: 1.45,
          color: AppColors.textSecondary,
        ),
        bodySmall: const TextStyle(
          fontSize: 12,
          height: 1.4,
          color: AppColors.textMuted,
        ),
        labelLarge: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
        labelMedium: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        labelSmall: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceElevated,
        selectedColor: AppColors.primary,
        side: BorderSide.none,
        labelStyle: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.textSecondary,
        textColor: AppColors.textPrimary,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return AppColors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withOpacity(0.65);
          }
          return AppColors.surfaceMuted;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(AppColors.textMuted.withOpacity(0.45)),
        radius: const Radius.circular(AppRadius.pill),
        thickness: const WidgetStatePropertyAll<double>(6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13.5),
        prefixIconColor: AppColors.textMuted,
        suffixIconColor: AppColors.textMuted,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.surfaceElevated,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            side: const BorderSide(color: AppColors.border),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          textStyle: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.borderStrong),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: const BorderSide(color: AppColors.borderStrong),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceElevated,
        contentTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 13,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
      splashFactory: InkSparkle.splashFactory,
    );
  }
}
