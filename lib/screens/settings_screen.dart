import 'package:flutter/material.dart';
import '../services/channel_service.dart';
import '../services/favorites_service.dart';
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

  @override
  void initState() {
    super.initState();
    _loadSavedUrl();
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
        padding: const EdgeInsets.all(16.0),
        children: [
          // Banner Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.10),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.accent.withOpacity(0.28)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: AppColors.accent, size: 26),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Anda dapat menambahkan link playlist M3U/M3U8 eksternal untuk memperluas daftar channel TV.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Custom Playlist M3U URL',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),

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

          const SizedBox(height: 32),

          const Divider(color: AppColors.border),

          const SizedBox(height: 16),

          const Text(
            'Rekomendasi Sumber Playlist Legal IPTV:',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.public_rounded, color: AppColors.primaryLight),
            title: const Text('IPTV-ORG Indonesia', style: TextStyle(color: AppColors.textPrimary, fontSize: 13)),
            subtitle: const Text('https://iptv-org.github.io/iptv/countries/id.m3u', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
            onTap: () {
              _urlController.text = 'https://iptv-org.github.io/iptv/countries/id.m3u';
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.language_rounded, color: AppColors.accent),
            title: const Text('IPTV-ORG Global News', style: TextStyle(color: AppColors.textPrimary, fontSize: 13)),
            subtitle: const Text('https://iptv-org.github.io/iptv/categories/news.m3u', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
            onTap: () {
              _urlController.text = 'https://iptv-org.github.io/iptv/categories/news.m3u';
            },
          ),

          const SizedBox(height: 24),

          // Kartu informasi aplikasi.
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
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

          const SizedBox(height: 16),

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
