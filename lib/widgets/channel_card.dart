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

  @override
  State<ChannelCard> createState() => _ChannelCardState();
}

class _ChannelCardState extends State<ChannelCard> {
  bool _isFavorite = false;
  bool _isFocused = false;

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
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: _isFocused ? AppColors.surfaceElevated : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: _isFocused ? AppColors.primary : AppColors.border,
              width: _isFocused ? 1.8 : 1,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.32),
                      blurRadius: 18,
                      spreadRadius: -2,
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              focusColor: AppColors.primary.withOpacity(0.14),
              splashColor: AppColors.primary.withOpacity(0.18),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              onFocusChange: (hasFocus) {
                if (mounted && hasFocus != _isFocused) {
                  setState(() => _isFocused = hasFocus);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bagian atas: logo kanal + tombol favorit.
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _ChannelLogo(url: widget.channel.logoUrl),
                        ),
                        const SizedBox(width: 6),
                        _FavoriteButton(
                          isFavorite: _isFavorite,
                          focusNode: _favoriteFocusNode,
                          onPressed: _toggleFavorite,
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Nama kanal.
                    Text(
                      widget.channel.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _isFocused
                            ? AppColors.textPrimary
                            : AppColors.textPrimary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.1,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Kategori + penanda live.
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMuted,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
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
                        _LiveBadge(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Logo kanal dengan kotak putih dan fallback ikon TV.
class _ChannelLogo extends StatelessWidget {
  final String url;

  const _ChannelLogo({required this.url});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 10,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
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
      ),
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
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
      decoration: BoxDecoration(
        color: AppColors.live.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: AppColors.live,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'LIVE',
            style: TextStyle(
              color: AppColors.live,
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
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
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: IconButton(
        iconSize: 20,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        focusNode: focusNode,
        tooltip: isFavorite ? 'Hapus dari favorit' : 'Tambah ke favorit',
        icon: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: isFavorite ? AppColors.primaryLight : AppColors.textMuted,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
