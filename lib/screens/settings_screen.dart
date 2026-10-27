import 'package:flutter/material.dart';
import '../services/channel_service.dart';
import '../services/favorites_service.dart';
import '../services/player_settings_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  final Function(String url) onPlaylistLoaded;

  /// Dipanggil setelah playlist kustom berhasil dihapus. Opsional supaya
  /// layar ini tetap bisa dipakai tanpa callback tersebut.
  final VoidCallback? onPlaylistRemoved;

  const SettingsScreen({
    super.key,
    required this.onPlaylistLoaded,
    this.onPlaylistRemoved,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _urlController = TextEditingController();
  bool _isLoading = false;
  bool _hasSavedPlaylist = false;
  String? _statusMessage;

  /// Apakah stream langsung diputar otomatis saat kanal dibuka.
  bool _autoPlayOnOpen = true;

  @override
  void initState() {
    super.initState();
    _loadSavedUrl();
    _loadAutoPlay();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedUrl() async {
    final saved = await FavoritesService.getCustomM3uUrl();
    if (!mounted) return;
    if (saved != null && saved.isNotEmpty) {
      _urlController.text = saved;
      setState(() => _hasSavedPlaylist = true);
    }
  }

  /// Ambil nilai preferensi auto play yang terakhir disimpan pengguna.
  Future<void> _loadAutoPlay() async {
    final value = await PlayerSettingsService.getAutoPlayOnOpen();
    if (!mounted) return;
    setState(() => _autoPlayOnOpen = value);
  }

  /// Simpan pilihan auto play dan beri umpan balik ke pengguna.
  Future<void> _toggleAutoPlay(bool value) async {
    setState(() => _autoPlayOnOpen = value);
    await PlayerSettingsService.setAutoPlayOnOpen(value);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value
            ? 'Auto play dinyalakan. Siaran langsung diputar otomatis.'
            : 'Auto play dimatikan. Siaran dimulai setelah kamu menekan tombol play.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Hapus playlist M3U kustom yang tersimpan dan kembali ke daftar channel
  /// bawaan aplikasi.
  Future<void> _removeCustomPlaylist() async {
    await FavoritesService.removeCustomM3uUrl();
    if (!mounted) return;

    _urlController.clear();
    setState(() {
      _hasSavedPlaylist = false;
      _statusMessage = 'Playlist kustom dihapus. Kembali ke daftar channel bawaan.';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Playlist kustom berhasil dihapus.'),
        backgroundColor: Colors.green,
      ),
    );

    widget.onPlaylistRemoved?.call();
  }

  Future<void> _testAndSavePlaylist() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() => _statusMessage = 'Masukkan link URL m3u terlebih dahulu');
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = 'Mengunduh dan memeriksa playlist...';
    });

    try {
      final channels = await ChannelService.parseM3UFromUrl(url);
      if (channels.isEmpty) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _statusMessage = 'Gagal memuat atau tidak ada channel valid dalam playlist.';
        });
      } else {
        await FavoritesService.saveCustomM3uUrl(url);
        widget.onPlaylistLoaded(url);

        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _hasSavedPlaylist = true;
          _statusMessage = 'Berhasil memuat ${channels.length} channel dari playlist!';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil memuat ${channels.length} channel baru!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _statusMessage = 'Terjadi kesalahan: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        title: const Text('Pengaturan & Playlist IPTV'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          32,
        ),
        children: [
          // Banner info dengan gaya premium: panel kaca di atas gradien gelap.
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppColors.borderStrong),
              boxShadow: AppShadows.elevated(opacity: 0.35),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: AppColors.brandGradient,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    Icons.info_outline_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Playlist M3U Eksternal',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tambahkan link playlist M3U/M3U8 untuk memperluas '
                        'daftar channel TV.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.5,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          const _SectionTitle(
            icon: Icons.play_circle_outline_rounded,
            title: 'Playback',
          ),
          const SizedBox(height: AppSpacing.md),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _autoPlayOnOpen,
              onChanged: _toggleAutoPlay,
              // Warna sakelar mengikuti warna utama aplikasi lewat tema.
              title: const Text(
                'Auto play saat membuka kanal',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
              ),
              subtitle: const Text(
                'Siaran langsung langsung diputar begitu kanal dibuka. Matikan '
                'kalau ingin memulai menonton secara manual.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          const _SectionTitle(
            icon: Icons.link_rounded,
            title: 'Custom Playlist M3U URL',
          ),
          const SizedBox(height: AppSpacing.md),

          TextField(
            controller: _urlController,
            style: const TextStyle(color: AppColors.textPrimary),
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              hintText: 'https://example.com/playlist.m3u',
              hintStyle: const TextStyle(color: AppColors.textMuted),
              prefixIcon: const Icon(Icons.link_rounded, color: AppColors.textMuted),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear_rounded, color: AppColors.textMuted),
                onPressed: () => _urlController.clear(),
              ),
            ),
          ),

          const SizedBox(height: 16),

          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            onPressed: _isLoading ? null : _testAndSavePlaylist,
            icon: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.download_rounded),
            label: Text(_isLoading ? 'Memproses...' : 'Terapkan & Simpan Playlist'),
          ),

          if (_statusMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              _statusMessage!,
              style: TextStyle(
                color: (_statusMessage!.startsWith('Berhasil') ||
                        _statusMessage!.contains('dihapus'))
                    ? AppColors.success
                    : AppColors.warning,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          if (_hasSavedPlaylist) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _removeCustomPlaylist,
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('Hapus Playlist Kustom & Kembali ke Daftar Bawaan'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryLight,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.xxl),

          const _SectionTitle(
            icon: Icons.explore_outlined,
            title: 'Sumber Playlist Legal IPTV',
          ),
          const SizedBox(height: AppSpacing.md),

          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _PlaylistSourceTile(
                  icon: Icons.public_rounded,
                  iconColor: AppColors.primaryLight,
                  title: 'IPTV-ORG Indonesia',
                  subtitle:
                      'https://iptv-org.github.io/iptv/countries/id.m3u',
                  onTap: () {
                    _urlController.text =
                        'https://iptv-org.github.io/iptv/countries/id.m3u';
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _PlaylistSourceTile(
                  icon: Icons.language_rounded,
                  iconColor: AppColors.accent,
                  title: 'IPTV-ORG Global News',
                  subtitle:
                      'https://iptv-org.github.io/iptv/categories/news.m3u',
                  onTap: () {
                    _urlController.text =
                        'https://iptv-org.github.io/iptv/categories/news.m3u';
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Kartu informasi aplikasi.
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: AppColors.glassGradient,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Row(
                  children: [
                    Icon(Icons.verified_rounded, color: AppColors.success, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Tentang RENATA TV',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  'Aplikasi pemutar TV gratis. Semua kanal memakai URL resmi '
                  'broadcaster atau mirror publik yang telah diuji. '
                  'Tidak ada akun, tidak ada langganan, dan tidak ada iklan '
                  'dari kami.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5, height: 1.5),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          const Center(
            child: Text(
              'RENATA TV · Versi 1.5.0',
              style: TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}

/// Judul bagian dengan ikon kecil, dipakai untuk memisahkan bagian menu.
class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.gold),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        const Expanded(child: Divider(height: 1)),
      ],
    );
  }
}

/// Baris sumber playlist yang bisa diketuk untuk mengisi kolom URL.
class _PlaylistSourceTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PlaylistSourceTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.14),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, color: iconColor, size: 17),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.north_east_rounded,
              color: AppColors.textMuted,
              size: 15,
            ),
          ],
        ),
      ),
    );
  }
}
