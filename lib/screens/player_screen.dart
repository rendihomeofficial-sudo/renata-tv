import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
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

  /// Pesan error yang tampil di atas area pemutar (bukan null = ada error).
  String? _playerError;

  /// True saat pemutar sedang buffering (bukan sedang memuat pertama kali).
  bool _isBuffering = false;

  /// Indeks URL yang sedang dicoba dari [Channel.allUrls]. Dipakai untuk
  /// mencoba mirror berikutnya secara otomatis saat stream utama gagal.
  int _urlAttempt = 0;

  /// Berapa kali percobaan untuk satu URL yang sama sebelum pindah mirror.
  static const int _attemptsPerUrl = 2;

  // Webview controller
  WebViewController? _webViewController;

  // Youtube player controller
  YoutubePlayerController? _youtubeController;

  // Native HLS player (video_player + chewie)
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  /// Listener buffering dari VideoPlayerController.
  VoidCallback? _bufferingListener;

  @override
  void initState() {
    super.initState();
    _currentChannel = widget.channel;
    _checkFavorite();
    // `silent` dipakai karena initState berjalan pada fase build sehingga
    // pemanggilan setState() di dalamnya akan memicu error.
    _setupPlayer(silent: true);
    WakelockPlus.enable();
  }

  Future<void> _checkFavorite() async {
    final fav = await FavoritesService.isFavorite(_currentChannel.id);
    if (!mounted) return;
    setState(() => _isFavorite = fav);
  }

  Future<void> _toggleFavorite() async {
    await FavoritesService.toggleFavorite(_currentChannel.id);
    await _checkFavorite();
  }

  /// Buang semua controller yang sedang aktif sebelum membuat pemutar baru.
  void _disposeControllers() {
    final video = _videoController;
    final listener = _bufferingListener;
    if (video != null && listener != null) {
      video.removeListener(listener);
    }
    _bufferingListener = null;
    _isBuffering = false;

    _youtubeController?.dispose();
    _youtubeController = null;
    _chewieController?.dispose();
    _chewieController = null;
    _videoController?.dispose();
    _videoController = null;
    _webViewController = null;
  }

  void _setupPlayer({bool silent = false}) {
    _disposeControllers();
    // Mulai lagi dari mirror utama setiap kali kanal dimuat ulang.
    _urlAttempt = 0;

    if (silent) {
      _isLoading = true;
      _playerError = null;
    } else if (mounted) {
      setState(() {
        _isLoading = true;
        _playerError = null;
      });
    }

    final channel = _currentChannel;

    if (channel.type == StreamType.youtube && channel.youtubeVideoId != null) {
      // Inisialisasi YouTube Player
      _youtubeController = YoutubePlayerController(
        initialVideoId: channel.youtubeVideoId!,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          isLive: true,
          enableCaption: false,
          forceHD: true,
        ),
      );
      _setLoading(false);
    } else if (channel.type == StreamType.m3u8 ||
        channel.type == StreamType.native) {
      // Stream native (HLS .m3u8 atau berkas video progresif)
      _initNativePlayer(channel);
    } else {
      // Inisialisasi WebView untuk Embed Stream (Detik, RCTI+, TVRI, dll)
      _initWebView(channel);
    }
  }

  /// Siapkan pemutar video native untuk channel bertipe [StreamType.m3u8]
  /// atau [StreamType.native].
  ///
  /// Channel live sering punya beberapa mirror resmi. Fungsi ini mencoba
  /// URL utama terlebih dahulu, lalu otomatis pindah ke mirror berikutnya
  /// bila gagal, sehingga menonton tetap lancar walaupun satu mirror
  /// sedang bermasalah.
  Future<void> _initNativePlayer(Channel channel) async {
    final urls = channel.allUrls;
    if (urls.isEmpty) {
      _showPlayerError('URL stream tidak valid.');
      return;
    }

    String? lastError;

    for (int attempt = 0; attempt < _attemptsPerUrl; attempt++) {
      final urlIndex = _urlAttempt % urls.length;
      final url = urls[urlIndex];

      final Uri uri;
      try {
        uri = Uri.parse(url);
      } catch (e) {
        lastError = 'URL stream tidak valid.';
        break;
      }

      final controller = VideoPlayerController.networkUrl(uri);
      _videoController = controller;

      try {
        await controller.initialize().timeout(
              const Duration(seconds: 25),
            );

        // Pastikan widget masih hidup dan controller ini masih yang dipakai
        // (pengguna bisa saja sudah pindah channel saat initialization).
        if (!mounted || _videoController != controller) {
          await controller.dispose();
          return;
        }

        _attachBufferingListener(controller);

        _chewieController = ChewieController(
          videoPlayerController: controller,
          autoPlay: true,
          aspectRatio: 16 / 9,
          allowFullScreen: false,
          showControls: true,
          errorBuilder: (context, error) => _buildErrorState(),
        );

        _setLoading(false);
        return;
      } catch (e) {
        debugPrint('Gagal memuat stream HLS ($url): $e');
        lastError = e.toString();
        await controller.dispose();
        if (!mounted) return;
        if (_videoController == controller) _videoController = null;
      }
    }

    // Semua percobaan pada URL ini gagal -> pindah ke mirror berikutnya.
    if (_urlAttempt + 1 < urls.length) {
      _urlAttempt++;
      if (mounted) {
        setState(() => _playerError = null);
      }
      await _initNativePlayer(channel);
      return;
    }

    if (!mounted) return;
    debugPrint('Error terakhir: $lastError');
    _showPlayerError(
      'Tidak dapat memuat stream ini dari ${urls.length} mirror. Periksa '
      'koneksi internet Anda lalu coba lagi.',
    );
  }

  /// Pantau status buffering dari pemutar native supaya indikator
  /// "buffering" bisa ditampilkan di atas video.
  void _attachBufferingListener(VideoPlayerController controller) {
    _bufferingListener = () {
      if (!mounted) return;
      final buffering = controller.value.isBuffering;
      if (buffering != _isBuffering) {
        setState(() => _isBuffering = buffering);
      }
    };
    controller.addListener(_bufferingListener!);
  }

  /// Siapkan WebView untuk channel embed (Detik, RCTI+, CNN, TVRI, dll).
  void _initWebView(Channel channel) {
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
            if (!mounted) return;
            setState(() => _isLoading = false);
            // Hanya error halaman utama yang dianggap fatal; error aset/iklan
            // tidak boleh menghentikan pemutaran.
            if (error.isForMainFrame == true) {
              _showPlayerError(
                'Halaman live stream tidak dapat dimuat. Periksa koneksi internet Anda lalu coba lagi.',
              );
            }
          },
        ),
      )
      ..setUserAgent(
        "Mozilla/5.0 (Linux; Android 13; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36",
      )
      ..loadRequest(Uri.parse(channel.streamUrl));
  }

  void _setLoading(bool value) {
    if (!mounted) return;
    setState(() => _isLoading = value);
  }

  void _showPlayerError(String message) {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _playerError = message;
    });
  }

  void _switchChannel(Channel channel) {
    if (_currentChannel.id == channel.id) return;
    setState(() {
      _currentChannel = channel;
      _playerError = null;
    });
    _checkFavorite();
    _setupPlayer();
  }

  /// Pindah ke channel sebelumnya / berikutnya (dipakai remote D-pad TV).
  void _stepChannel(int delta) {
    if (widget.allChannels.isEmpty) return;
    final currentIndex =
        widget.allChannels.indexWhere((c) => c.id == _currentChannel.id);
    final baseIndex = currentIndex == -1 ? 0 : currentIndex;
    final nextIndex =
        (baseIndex + delta) % widget.allChannels.length;
    final safeIndex = nextIndex < 0 ? widget.allChannels.length - 1 : nextIndex;
    _switchChannel(widget.allChannels[safeIndex]);
  }

  void _previousChannel() => _stepChannel(-1);

  void _nextChannel() => _stepChannel(1);

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
    final video = _videoController;
    final listener = _bufferingListener;
    if (video != null && listener != null) {
      video.removeListener(listener);
    }
    _bufferingListener = null;
    _youtubeController?.dispose();
    _chewieController?.dispose();
    _videoController?.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  /// Pintasan keyboard/remote (D-pad) yang tersedia di layar pemutar.
  Widget _withRemoteShortcuts(Widget child) {
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.arrowLeft): _previousChannel,
        const SingleActivator(LogicalKeyboardKey.arrowRight): _nextChannel,
        const SingleActivator(LogicalKeyboardKey.keyF): _toggleFullScreen,
        const SingleActivator(LogicalKeyboardKey.escape): _toggleFullScreen,
      },
      child: Focus(
        autofocus: true,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mode Full Screen: Tampilan penuh layar tanpa AppBar & Daftar Channel
    if (_isFullScreen) {
      return _withRemoteShortcuts(
        PopScope(
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
        ),
      );
    }

    // Mode Normal (Portrait)
    return _withRemoteShortcuts(
      Scaffold(
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
              tooltip: 'Favorit',
              onPressed: _toggleFavorite,
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Muat Ulang Siaran',
              onPressed: () => _setupPlayer(),
            ),
          ],
        ),
        body: OrientationBuilder(
          builder: (context, orientation) {
            // Di mode landscape, video tampil besar di kiri dan daftar kanal
            // pindah ke panel samping supaya tidak menutupi layar.
            if (orientation == Orientation.landscape) {
              return _buildLandscapeBody();
            }
            return Column(
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
                      '${ch.category} • ${_streamTypeLabel(ch.type)}',
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
          );
        },
      ),
    ),
    );
  }

  /// Tampilan landscape: video memenuhi tinggi layar, daftar kanal di
  /// panel kanan yang bisa digulir.
  Widget _buildLandscapeBody() {
    return Row(
      children: [
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(child: _buildPlayerView()),
              Positioned(
                bottom: 8,
                right: 8,
                child: _buildFullScreenButton(),
              ),
            ],
          ),
        ),
        Container(
          width: 200,
          color: const Color(0xFF14171F),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                child: Row(
                  children: [
                    const Icon(Icons.live_tv_rounded,
                        color: Colors.redAccent, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Kanal (${widget.allChannels.length})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.allChannels.length,
                  itemBuilder: (context, index) {
                    final ch = widget.allChannels[index];
                    final isSelected = ch.id == _currentChannel.id;
                    return ListTile(
                      dense: true,
                      selected: isSelected,
                      selectedTileColor: Colors.redAccent.withOpacity(0.15),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          width: 32,
                          height: 32,
                          color: Colors.white,
                          padding: const EdgeInsets.all(3),
                          child: ch.logoUrl.isNotEmpty
                              ? (ch.logoUrl.startsWith('assets/')
                                  ? Image.asset(
                                      ch.logoUrl,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => const Icon(
                                          Icons.tv, color: Colors.black38),
                                    )
                                  : Image.network(
                                      ch.logoUrl,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => const Icon(
                                          Icons.tv, color: Colors.black38),
                                    ))
                              : const Icon(Icons.tv, color: Colors.black38),
                        ),
                      ),
                      title: Text(
                        ch.name,
                        style: TextStyle(
                          color: isSelected ? Colors.redAccent : Colors.white,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => _switchChannel(ch),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Tombol masuk layar penuh yang dipakai di mode landscape.
  Widget _buildFullScreenButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        icon: const Icon(Icons.fullscreen_rounded, color: Colors.white, size: 24),
        tooltip: 'Layar Penuh (Landscape)',
        onPressed: _toggleFullScreen,
      ),
    );
  }

  String _streamTypeLabel(StreamType type) {
    switch (type) {
      case StreamType.youtube:
        return 'YouTube Live';
      case StreamType.m3u8:
        return 'HLS Stream';
      case StreamType.native:
        return 'Direct Stream';
      case StreamType.webview:
        return 'Official Stream';
    }
  }

  Widget _buildPlayerView() {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          if (_currentChannel.type == StreamType.youtube &&
              _youtubeController != null)
            // YoutubePlayerBuilder agar tombol fullscreen bawaan YouTube ikut
            // memaksa orientasi Landscape di aplikasi ini
            YoutubePlayerBuilder(
              player: YoutubePlayer(
                controller: _youtubeController!,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Colors.redAccent,
                liveUIColor: Colors.redAccent,
              ),
              onEnterFullScreen: () {
                if (!_isFullScreen) _toggleFullScreen();
              },
              onExitFullScreen: () {
                if (_isFullScreen) _toggleFullScreen();
              },
              builder: (_, player) => player,
            )
          else if ((_currentChannel.type == StreamType.m3u8 ||
                  _currentChannel.type == StreamType.native) &&
              _chewieController != null)
            // Pemutar video native dengan kontrol dari Chewie.
            Chewie(controller: _chewieController!)
          else if (_webViewController != null)
            WebViewWidget(controller: _webViewController!)
          else if (_playerError == null)
            const Center(
              child: Text('Format pemutar tidak didukung',
                  style: TextStyle(color: Colors.white70)),
            ),

          if (_playerError != null) _buildErrorState(),

          // Indikator buffering: tampil ketika stream sudah siap tetapi
          // data video belum sampai (jaringan lambat).
          if (_isBuffering && !_isLoading && _playerError == null)
            Container(
              color: Colors.black26,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.redAccent),
                    SizedBox(height: 10),
                    Text('Meny buffering...',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
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

  /// Tampilan error di area pemutar dengan tombol "Coba Lagi".
  Widget _buildErrorState() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(20),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.signal_wifi_connected_no_internet_4_rounded,
              color: Colors.white54, size: 42),
          const SizedBox(height: 12),
          Text(
            _playerError ?? 'Terjadi kesalahan saat memuat siaran.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _setupPlayer(),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Coba Lagi'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
