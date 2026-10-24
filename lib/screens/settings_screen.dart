import 'package:flutter/material.dart';
import '../services/channel_service.dart';
import '../services/favorites_service.dart';

class SettingsScreen extends StatefulWidget {
  final Function(String url) onPlaylistLoaded;

  const SettingsScreen({super.key, required this.onPlaylistLoaded});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _urlController = TextEditingController();
  bool _isLoading = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _loadSavedUrl();
  }

  Future<void> _loadSavedUrl() async {
    final saved = await FavoritesService.getCustomM3uUrl();
    if (saved != null && saved.isNotEmpty) {
      _urlController.text = saved;
    }
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
        setState(() {
          _isLoading = false;
          _statusMessage = 'Gagal memuat atau tidak ada channel valid dalam playlist.';
        });
      } else {
        await FavoritesService.saveCustomM3uUrl(url);
        widget.onPlaylistLoaded(url);

        setState(() {
          _isLoading = false;
          _statusMessage = 'Berhasil memuat ${channels.length} channel dari playlist!';
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Berhasil memuat ${channels.length} channel baru!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Terjadi kesalahan: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF12141A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D24),
        foregroundColor: Colors.white,
        title: const Text('Pengaturan & Playlist IPTV'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Banner Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blueAccent, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Anda dapat menambahkan link playlist M3U/M3U8 eksternal untuk memperluas daftar channel TV.',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Custom Playlist M3U URL',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          TextField(
            controller: _urlController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'https://example.com/playlist.m3u',
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: const Color(0xFF1E222A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear, color: Colors.white54),
                onPressed: () => _urlController.clear(),
              ),
            ),
          ),

          const SizedBox(height: 16),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
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
                color: _statusMessage!.startsWith('Berhasil') ? Colors.greenAccent : Colors.orangeAccent,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: 32),

          const Divider(color: Colors.white12),

          const SizedBox(height: 16),

          const Text(
            'Rekomendasi Sumber Playlist Legal IPTV:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.public, color: Colors.redAccent),
            title: const Text('IPTV-ORG Indonesia', style: TextStyle(color: Colors.white, fontSize: 13)),
            subtitle: const Text('https://iptv-org.github.io/iptv/countries/id.m3u', style: TextStyle(color: Colors.white54, fontSize: 11)),
            onTap: () {
              _urlController.text = 'https://iptv-org.github.io/iptv/countries/id.m3u';
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.language, color: Colors.blueAccent),
            title: const Text('IPTV-ORG Global News', style: TextStyle(color: Colors.white, fontSize: 13)),
            subtitle: const Text('https://iptv-org.github.io/iptv/categories/news.m3u', style: TextStyle(color: Colors.white54, fontSize: 11)),
            onTap: () {
              _urlController.text = 'https://iptv-org.github.io/iptv/categories/news.m3u';
            },
          ),
        ],
      ),
    );
  }
}
