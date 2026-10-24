import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/channel.dart';
import '../services/favorites_service.dart';

class PlayerScreen extends StatefulWidget {
  final Channel channel;
  final List<Channel> allChannels;

  const PlayerScreen({
    super.key,
    required this.channel,
    required this.allChannels,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late Channel _currentChannel;
  bool _isFavorite = false;
  bool _isLoading = true;
  bool _isFullScreen = false;

  // Webview controller
  WebViewController? _webViewController;

  // Youtube player controller
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    _currentChannel = widget.channel;
    _checkFavorite();
    _setupPlayer();
    WakelockPlus.enable();
  }

  Future<void> _checkFavorite() async {
    final fav = await FavoritesService.isFavorite(_currentChannel.id);
    if (mounted) {
      setState(() => _isFavorite = fav);
    }
  }

  Future<void> _toggleFavorite() async {
    await FavoritesService.toggleFavorite(_currentChannel.id);
    _checkFavorite();
  }

  void _setupPlayer() {
    setState(() {
      _isLoading = true;
    });

    // Reset controllers
    _youtubeController?.dispose();
    _youtubeController = null;
    _webViewController = null;

    if (_currentChannel.type == StreamType.youtube &&
        _currentChannel.youtubeVideoId != null) {
      // Inisialisasi YouTube Player
      _youtubeController = YoutubePlayerController(
        initialVideoId: _currentChannel.youtubeVideoId!,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          isLive: true,
          enableCaption: false,
          forceHD: true,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } else {
      // Inisialisasi WebView untuk Embed Stream (Detik, RCTI+, TVRI, dll)
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.black)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (url) {
              if (mounted) setState(() => _isLoading = true);
            },
            onPageFinished: (url) {
              if (mounted) setState(() => _isLoading = false);
            },
            onWebResourceError: (error) {
              if (mounted) setState(() => _isLoading = false);
            },
          ),
        )
        ..setUserAgent(
          "Mozilla/5.0 (Linux; Android 13; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36",
        )
        ..loadRequest(Uri.parse(_currentChannel.streamUrl));
    }
  }

  void _switchChannel(Channel channel) {
    if (_currentChannel.id == channel.id) return;
    setState(() {
      _currentChannel = channel;
    });
    _checkFavorite();
    _setupPlayer();
  }

  /// Masuk atau keluar mode Full Screen
  /// Saat Full Screen: WAJIB Landscape (LandscapeLeft / LandscapeRight) & sembunyikan status bar
  /// Saat keluar Full Screen: Kembali ke PortraitUp
  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _youtubeController?.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mode Full Screen: Tampilan penuh layar tanpa AppBar & Daftar Channel
    if (_isFullScreen) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            _toggleFullScreen();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Positioned.fill(
                child: _buildPlayerView(),
              ),
              // Tombol kontrol mengambang untuk keluar Fullscreen
              Positioned(
                top: 16,
                right: 16,
                child: SafeArea(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.fullscreen_exit_rounded,
                          color: Colors.white, size: 28),
                      tooltip: 'Keluar Layar Penuh',
                      onPressed: _toggleFullScreen,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: SafeArea(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _currentChannel.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Mode Normal (Portrait)
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF14171F),
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Expanded(
              child: Text(
                _currentChannel.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'LIVE',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.redAccent : Colors.white,
            ),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat Ulang Siaran',
            onPressed: _setupPlayer,
          ),
        ],
      ),
      body: Column(
        children: [
          // Screen Player Container
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: [
                Positioned.fill(child: _buildPlayerView()),
                // Tombol Full Screen (Masuk Mode Landscape)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.fullscreen_rounded,
                          color: Colors.white, size: 24),
                      tooltip: 'Layar Penuh (Landscape)',
                      onPressed: _toggleFullScreen,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Detail Channel Info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFF1B1E26),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 44,
                    height: 44,
                    color: Colors.white,
                    padding: const EdgeInsets.all(4),
                    child: _currentChannel.logoUrl.isNotEmpty
                        ? (_currentChannel.logoUrl.startsWith('assets/')
                            ? Image.asset(
                                _currentChannel.logoUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.tv, color: Colors.black54),
                              )
                            : Image.network(
                                _currentChannel.logoUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.tv, color: Colors.black54),
                              ))
                        : const Icon(Icons.tv, color: Colors.black54),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentChannel.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _currentChannel.description,
                        style: const TextStyle(color: Colors.white60, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Colors.white12),

          // Daftar Channel Siaran Lainnya
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(
              children: [
                const Icon(Icons.live_tv_rounded, color: Colors.redAccent, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Saluran TV Lainnya (${widget.allChannels.length})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.separated(
              itemCount: widget.allChannels.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white10),
              itemBuilder: (context, index) {
                final ch = widget.allChannels[index];
                final isSelected = ch.id == _currentChannel.id;

                return ListTile(
                  selected: isSelected,
                  selectedTileColor: Colors.redAccent.withOpacity(0.12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      width: 40,
                      height: 40,
                      color: Colors.white,
                      padding: const EdgeInsets.all(4),
                      child: ch.logoUrl.isNotEmpty
                          ? (ch.logoUrl.startsWith('assets/')
                              ? Image.asset(
                                  ch.logoUrl,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.tv, color: Colors.black38),
                                )
                              : Image.network(
                                  ch.logoUrl,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.tv, color: Colors.black38),
                                ))
                          : const Icon(Icons.tv, color: Colors.black38),
                    ),
                  ),
                  title: Text(
                    ch.name,
                    style: TextStyle(
                      color: isSelected ? Colors.redAccent : Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    '${ch.category} • ${ch.type == StreamType.youtube ? "YouTube Live" : "Official Stream"}',
                    style: TextStyle(
                      color: isSelected ? Colors.redAccent.withOpacity(0.8) : Colors.white54,
                      fontSize: 11,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.play_circle_fill, color: Colors.redAccent)
                      : const Icon(Icons.chevron_right, color: Colors.white24),
                  onTap: () => _switchChannel(ch),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerView() {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          if (_currentChannel.type == StreamType.youtube &&
              _youtubeController != null)
            YoutubePlayer(
              controller: _youtubeController!,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.redAccent,
              liveUIColor: Colors.redAccent,
              onEnterFullScreen: () {
                if (!_isFullScreen) _toggleFullScreen();
              },
              onExitFullScreen: () {
                if (_isFullScreen) _toggleFullScreen();
              },
            )
          else if (_webViewController != null)
            WebViewWidget(controller: _webViewController!)
          else
            const Center(
              child: Text('Format pemutar tidak didukung',
                  style: TextStyle(color: Colors.white70)),
            ),

          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.redAccent),
                    SizedBox(height: 10),
                    Text('Menghubungkan ke siaran live...',
                        style: TextStyle(color: Colors.white70, fontSize: 12))
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
