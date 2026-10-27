import 'package:flutter/material.dart';

import '../services/auto_update_service.dart';
import '../theme/app_theme.dart';

/// Badge "Pembaruan Tersedia" untuk Home Screen.
///
/// Muncul otomatis saat versi baru sudah terdeteksi. Animasi:
///   1. Masuk: fade + slide turun lewat [AnimatedSwitcher] di pemanggil.
///   2. Denyut: ikon di dalam badge membesar kecil dan glow di sekeliling
///      badge ikut berdenyut, supaya pengguna langsung tahu ada informasi
///      baru tanpa harus membaca teksnya.
class UpdateBadge extends StatefulWidget {
  const UpdateBadge({
    super.key,
    required this.updateInfo,
    required this.onTap,
  });

  /// Informasi rilis yang akan ditampilkan pada badge.
  final UpdateInfo updateInfo;

  /// Dipanggil saat pengguna menekan badge.
  final VoidCallback onTap;

  @override
  State<UpdateBadge> createState() => _UpdateBadgeState();
}

class _UpdateBadgeState extends State<UpdateBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_pulseController.value);

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            gradient: const LinearGradient(
              colors: [Color(0xFF2A0E17), Color(0xFF151A24)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.40 + 0.30 * t),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.08 + 0.16 * t),
                blurRadius: 10 + 12 * t,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
                child: Row(
                  children: [
                    // Ikon yang membesar-kecil saat denyut.
                    Transform.scale(
                      key: const Key('update-badge-pulse'),
                      scale: 1.0 + 0.10 * t,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.30),
                              AppColors.primary.withOpacity(0.10),
                            ],
                          ),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.55),
                          ),
                        ),
                        child: const Icon(
                          Icons.system_update_rounded,
                          color: AppColors.primaryLight,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Pembaruan Tersedia',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Versi v${widget.updateInfo.latestVersionName} '
                            'sudah bisa diunduh',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.brandGradient,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        boxShadow: AppShadows.glow(AppColors.primary,
                            opacity: 0.28),
                      ),
                      child: const Text(
                        'Perbarui',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
