import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/channel.dart';
import '../services/favorites_service.dart';
import '../theme/app_theme.dart';

/// Intent untuk menandai channel sebagai favorit lewat keyboard/remote
/// (tombol F), karena pada Android TV tombol favorit tidak menerima fokus
/// navigasi D-pad.
class _ToggleFavoriteIntent extends Intent {
  const _ToggleFavoriteIntent();
}

/// Kartu kanal di grid Home Screen.
///
/// Tampilan memakai sistem desain [AppTheme]: permukaan gelap, aksen merah
/// merek, dan state fokus yang tegas supaya navigasi remote D-pad tetap
/// jelas. Kartu juga menampilkan penanda "LIVE" supaya pengguna tahu
/// kanal tersebut disiarkan langsung.
class ChannelCard extends StatefulWidget {
  final Channel channel;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteChanged;

  const ChannelCard({
    super.key,
    required this.channel,
    required this.onTap,
    this.onFavoriteChanged,
  });

  /// Rasio lebar/tinggi kartu yang pas untuk lebar tile tertentu.
  ///
  /// Tinggi kartu dihitung dari tinggi pelat logo (rasio 16:10) ditambah
  /// blok teks di bawahnya, jadi grid tidak menyisakan ruang kosong di
  /// bawah konten kartu.
  static double aspectRatioFor(double tileWidth) {
    const horizontalPadding = 24.0; // padding kartu 12 + 12
    // padding atas/bawah + jarak + baris nama + jarak + baris kategori,
    // ditambah sedikit kelonggaran agar aman dari pembulatan piksel.
    const contentBlockHeight = 88.0;
    final plateHeight = (tileWidth - horizontalPadding) * 10 / 16;
    final totalHeight = plateHeight + contentBlockHeight;
    return tileWidth / totalHeight;
  }

  @override
  State<ChannelCard> createState() => _ChannelCardState();
}

class _ChannelCardState extends State<ChannelCard> {
  bool _isFavorite = false;
  bool _isFocused = false;
  bool _isPressed = false;

  /// Tombol favorit sengaja tidak ikut dalam traversal fokus D-pad supaya
  /// navigasi remote TV tetap rapi antar kartu channel.
  final FocusNode _favoriteFocusNode = FocusNode(skipTraversal: true);

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  @override
  void dispose() {
    _favoriteFocusNode.dispose();
    super.dispose();
  }

  Future<void> _checkFavorite() async {
    final fav = await FavoritesService.isFavorite(widget.channel.id);
    if (mounted) {
      setState(() => _isFavorite = fav);
    }
  }

  Future<void> _toggleFavorite() async {
    await FavoritesService.toggleFavorite(widget.channel.id);
    await _checkFavorite();
    widget.onFavoriteChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.keyF): _ToggleFavoriteIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _ToggleFavoriteIntent: CallbackAction<_ToggleFavoriteIntent>(
            onInvoke: (_) {
              _toggleFavorite();
              return null;
            },
          ),
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..scale(
              _isFocused ? 1.035 : (_isPressed ? 0.985 : 1.0),
            ),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            color: _isFocused ? AppColors.surfaceElevated : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            gradient: _isFocused
                ? AppColors.glassGradient
                : const LinearGradient(
                    colors: [Color(0x0AFFFFFF), Color(0x00FFFFFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            border: Border.all(
              color: _isFocused ? AppColors.primaryLight : AppColors.border,
              width: _isFocused ? 1.6 : 1,
            ),
            boxShadow: _isFocused
                ? AppShadows.glow(AppColors.primary, opacity: 0.38)
                : AppShadows.soft(opacity: 0.18, blur: 12, offsetY: 3),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              focusColor: AppColors.primary.withOpacity(0.14),
              splashColor: AppColors.primary.withOpacity(0.18),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              onHighlightChanged: (pressed) {
                if (mounted && pressed != _isPressed) {
                  setState(() => _isPressed = pressed);
                }
              },
              onFocusChange: (hasFocus) {
                if (mounted && hasFocus != _isFocused) {
                  setState(() => _isFocused = hasFocus);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Pelat logo memakai rasio tetap 16:10 terhadap lebar
                    // area konten, sehingga tinggi kartu bisa dihitung
                    // persis oleh grid dan tidak ada ruang kosong.
                    final plateHeight = constraints.maxWidth * 10 / 16;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: plateHeight,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: _ChannelLogo(
                                  url: widget.channel.logoUrl,
                                  isFocused: _isFocused,
                                ),
                              ),
                              // Tombol favorit melayang di pojok pelat logo.
                              Positioned(
                                top: 4,
                                right: 4,
                                child: _FavoriteButton(
                                  isFavorite: _isFavorite,
                                  focusNode: _favoriteFocusNode,
                                  onPressed: _toggleFavorite,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Nama kanal. Baris dikunci tingginya supaya grid
                        // bisa menghitung tinggi kartu tanpa menyisakan
                        // ruang kosong maupun meluber.
                        SizedBox(
                          height: 24,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.channel.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Kategori + penanda live.
                        SizedBox(
                          height: 22,
                          child: Row(
                            children: [
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceMuted,
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.sm),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Text(
                                    widget.channel.category,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              _LiveBadge(isFocused: _isFocused),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Logo kanal dengan pelat putih dan fallback ikon TV.
class _ChannelLogo extends StatelessWidget {
  final String url;
  final bool isFocused;

  const _ChannelLogo({required this.url, required this.isFocused});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isFocused ? 0.42 : 0.28),
            blurRadius: isFocused ? 16 : 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isFocused
              ? AppColors.primaryLight.withOpacity(0.55)
              : AppColors.borderStrong,
        ),
      ),
      child: url.isEmpty
          ? const _LogoFallback()
          : (url.startsWith('assets/')
              ? Image.asset(
                  url,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const _LogoFallback(),
                )
              : Image.network(
                  url,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const _LogoFallback(),
                )),
    );
  }
}

class _LogoFallback extends StatelessWidget {
  const _LogoFallback();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(color: Colors.white),
      child: Icon(
        Icons.live_tv_rounded,
        color: Color(0xFFB0B7C3),
        size: 26,
      ),
    );
  }
}

/// Penanda kanal disiarkan langsung.
class _LiveBadge extends StatelessWidget {
  final bool isFocused;

  const _LiveBadge({required this.isFocused});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.live.withOpacity(isFocused ? 0.22 : 0.14),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: AppColors.live.withOpacity(isFocused ? 0.55 : 0.28),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.live,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.live.withOpacity(0.8),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 5),
          const Text(
            'LIVE',
            style: TextStyle(
              color: AppColors.live,
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tombol favorit.
class _FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final FocusNode focusNode;
  final VoidCallback onPressed;

  const _FavoriteButton({
    required this.isFavorite,
    required this.focusNode,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      // Latar gelap supaya ikon tetap terbaca di atas pelat logo putih.
      color: isFavorite
          ? AppColors.primary.withOpacity(0.92)
          : Colors.black.withOpacity(0.42),
      shape: const CircleBorder(),
      child: IconButton(
        iconSize: 19,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        focusNode: focusNode,
        tooltip: isFavorite ? 'Hapus dari favorit' : 'Tambah ke favorit',
        icon: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: isFavorite ? Colors.white : Colors.white.withOpacity(0.85),
          shadows: isFavorite
              ? [
                  Shadow(
                    color: AppColors.primary.withOpacity(0.6),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
