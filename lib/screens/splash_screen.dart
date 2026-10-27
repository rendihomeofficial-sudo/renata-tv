import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'home_screen.dart';

/// Layar pembuka RENATA TV.
///
/// Animasi yang dipakai:
///   1. Cincin cahaya berdenyut di belakang logo.
///   2. Logo membesar masuk (easeOutBack).
///   3. Judul dan tagline muncul bertahap (staggered fade + slide).
///   4. Barindedakan memutar dengan shimmer halus.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _introController;
  late final AnimationController _pulseController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _titleFade;
  late final Animation<double> _taglineFade;
  late final Animation<double> _loadingFade;
  late final Animation<double> _pulse;

  /// Timer perpindahan ke Home Screen. Disimpan agar bisa dibatalkan saat
  /// widget dibuang supaya tidak ada callback yang berjalan setelah
  /// aplikasi sudah pindah halaman.
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _logoScale = Tween<double>(begin: 0.72, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0, 0.65, curve: Curves.easeOutBack),
      ),
    );

    _logoFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0, 0.45, curve: Curves.easeOut),
    );

    _titleFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.30, 0.75, curve: Curves.easeOut),
    );

    _taglineFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.50, 0.90, curve: Curves.easeOut),
    );

    _loadingFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
    );

    _pulse = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _introController.forward();

    // Beri waktu cukup untuk animasi selesai sebelum masuk ke Home.
    _navigationTimer = Timer(const Duration(milliseconds: 2400), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 550),
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _navigationTimer = null;
    _introController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Latar gradien dengan cahaya merah lembut di tengah.
          const Positioned.fill(child: _SplashBackdrop()),

          // Cincin cahaya yang berdenyut di belakang logo.
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _PulseRingsPainter(t: _pulse.value),
                );
              },
            ),
          ),

          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeTransition(
                      opacity: _logoFade,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: const _AppLogo(),
                      ),
                    ),
                    const SizedBox(height: 28),
                    FadeTransition(
                      opacity: _titleFade,
                      child: const _SplashTitle(),
                    ),
                    const SizedBox(height: 16),
                    FadeTransition(
                      opacity: _taglineFade,
                      child: const _SplashTagline(),
                    ),
                    const SizedBox(height: 60),
                    FadeTransition(
                      opacity: _loadingFade,
                      child: const _SplashLoader(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Logo aplikasi di layar pembuka.
class _AppLogo extends StatelessWidget {
  const _AppLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      height: 132,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.brandGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.50),
            blurRadius: 46,
            spreadRadius: 6,
          ),
          BoxShadow(
            color: AppColors.primaryLight.withOpacity(0.22),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/icons/app_icon.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.live_tv_rounded,
            color: Colors.white,
            size: 58,
          ),
        ),
      ),
    );
  }
}

/// Nama aplikasi dengan gradasi aksen.
class _SplashTitle extends StatelessWidget {
  const _SplashTitle();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (rect) => AppColors.brandGradient.createShader(rect),
      child: const Text(
        'RENATA TV',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 34,
          fontWeight: FontWeight.w900,
          letterSpacing: 5,
          height: 1.1,
        ),
      ),
    );
  }
}

/// Tagline singkat di bawah judul.
class _SplashTagline extends StatelessWidget {
  const _SplashTagline();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        gradient: AppColors.glassGradient,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: const Text(
        'Siaran TV Indonesia · Bebas & Jernih',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

/// Indikator memuat berupa bar bergerak.
class _SplashLoader extends StatelessWidget {
  const _SplashLoader();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 150,
          height: 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              backgroundColor: Colors.white.withOpacity(0.08),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Menyiapkan saluran live...',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

/// Latar gradien untuk layar pembuka.
class _SplashBackdrop extends StatelessWidget {
  const _SplashBackdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A0E16),
            AppColors.background,
            Color(0xFF0A0D13),
          ],
          stops: [0.0, 0.45, 1.0],
        ),
      ),
      child: CustomPaint(painter: _GlowPainter()),
    );
  }
}

/// Cahaya merah lembut di belakang logo.
class _GlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.42);
    final radius = size.width * 0.62;

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.primary.withOpacity(0.22),
          AppColors.primary.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Cincin cahaya berdenyut.
class _PulseRingsPainter extends CustomPainter {
  final double t;

  _PulseRingsPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.42);
    final base = size.width * 0.16;

    for (int i = 0; i < 3; i++) {
      final phase = (t + i / 3) % 1.0;
      final radius = base * (1.0 + phase * 1.5);
      final opacity = (1.0 - phase) * 0.16;

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = AppColors.primaryLight.withOpacity(opacity);

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PulseRingsPainter oldDelegate) =>
      oldDelegate.t != t;
}
