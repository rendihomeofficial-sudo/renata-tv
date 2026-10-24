import 'package:flutter/material.dart';

import '../services/auto_update_service.dart';

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
          margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              colors: [Color(0xFF241419), Color(0xFF1E222A)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            border: Border.all(
              color: Colors.redAccent.withOpacity(0.40 + 0.30 * t),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withOpacity(0.08 + 0.16 * t),
                blurRadius: 10 + 12 * t,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    // Ikon yang membesar-kecil saat denyut.
                    Transform.scale(
                      key: const Key('update-badge-pulse'),
                      scale: 1.0 + 0.10 * t,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.redAccent.withOpacity(0.16),
                          border: Border.all(
                            color: Colors.redAccent.withOpacity(0.55),
                          ),
                        ),
                        child: const Icon(
                          Icons.system_update_rounded,
                          color: Colors.redAccent,
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
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Versi v${widget.updateInfo.latestVersionName} '
                            'sudah bisa diunduh',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Perbarui',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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
