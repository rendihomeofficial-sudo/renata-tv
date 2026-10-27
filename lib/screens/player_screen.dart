import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../models/channel.dart';
import '../services/favorites_service.dart';
import '../services/player_settings_service.dart';
import '../theme/app_theme.dart';

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

  /// Apakah stream langsung harus diputar otomatis saat kanal dibuka.
  /// Diambil dari preferensi pengguna di halaman Pengaturan.
  bool _autoPlayOnOpen = true;

  @override
  void initState() {
    super.initState();
    _currentChannel = widget.channel;
    _checkFavorite();
    // Pemutar disiapkan setelah preferensi auto play dibaca, supaya pilihan
    // pengguna langsung berlaku pada kanal pertama yang dibuka.
    _loadAutoPlayThenSetup();
    WakelockPlus.enable();
  }

  /// Baca preferensi auto play lalu siapkan pemutar sesuai nilai tersebut.
  Future<void> _loadAutoPlayThenSetup() async {
    final autoPlay = await PlayerSettingsService.getAutoPlayOnOpen();
    if (!mounted) return;
    _autoPlayOnOpen = autoPlay;
    // `silent` dipakai karena setup pemutar bisa berjalan pada fase build
    // sehingga pemanggilan setState() di dalamnya akan memicu error.
    _setupPlayer(silent: true);
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
        flags: YoutubePlayerFlags(
          autoPlay: _autoPlayOnOpen,
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
          autoPlay: _autoPlayOnOpen,
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
    final controller = WebViewController();
    _webViewController = controller;

    if (_autoPlayOnOpen) {
      // Di Android, WebView memutar media hanya setelah ada interaksi
      // pengguna. Izinkan pemutaran otomatis supaya stream langsung tidak
      // diam saja ketika kanal dibuka.
      final platform = controller.platform;
      if (platform is AndroidWebViewController) {
        platform.setMediaPlaybackRequiresUserGesture(false);
      }
    }

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            if (mounted) setState(() => _isLoading = false);
            if (_autoPlayOnOpen) _scheduleWebAutoPlay(controller);
          },
          onWebResourceError: (error) {
            if (!mounted) return;
            setState(() => _isLoading = false);
            // Hanya error halaman utama yang dianggap fatal; error aset/iklan
            // tidak boleh menghentikan pemutaran.
            if (error.isForMainFrame == true) {
              _showPlayerError(_mainFrameErrorMessage(channel));
            }
          },
        ),
      )
      ..setUserAgent(
        "Mozilla/5.0 (Linux; Android 13; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36",
      )
      ..loadRequest(Uri.parse(channel.streamUrl));
  }

  /// Skrip yang mencoba memulai pemutaran pada halaman web.
  ///
  /// Situs embed (Detik, RCTI+, CNN, CNBC) biasanya memakai video.js atau
  /// JWPlayer dan sengaja menonaktifkan auto play di level halaman. Skrip ini
  /// karena itu tidak hanya memanggil `play()` pada elemen video pertama,
  /// tetapi juga:
  /// - menelusuri semua elemen `<video>` lalu memilih yang paling besar
  ///   (elemen live, bukan slot iklan kecil);
  /// - memanggil API pemain yang tersedia (`jwplayer()`, `videojs`);
  /// - menekan tombol play besar yang ditampilkan situs;
  /// - mengulang percobaan secara berkala sampai 15 detik, karena beberapa
  ///   pemain baru siap setelah beberapa detik (mis. setelah snapshot
  ///   Firestore dan iklan IMA pada RCTI+).
  ///
  /// Nilai balik dipakai sebagai diagnostik:
  /// `playing`, `muted-playing`, `no-video`, `rejected`, atau `error`.
  static const String _webAutoPlayScript = '''
(function () {
  function pickVideo() {
    var all = document.querySelectorAll('video');
    if (!all || all.length === 0) return null;
    var best = null;
    var bestSize = -1;
    for (var i = 0; i < all.length; i++) {
      var v = all[i];
      if (!v) continue;
      var w = v.videoWidth || v.clientWidth || 0;
      var h = v.videoHeight || v.clientHeight || 0;
      var size = w * h;
      // Elemen yang sudah diputar/dimuat dianggap lebih mungkin live stream.
      if (v.readyState >= 1) size += 1000000;
      if (size > bestSize) {
        bestSize = size;
        best = v;
      }
    }
    return best;
  }

  function tryPlayerApi() {
    // JWPlayer (RCTI+, Detik)
    try {
      if (typeof window.jwplayer === 'function') {
        var inst = window.jwplayer();
        if (inst && typeof inst.play === 'function') {
          inst.play();
          return 'jwplayer';
        }
        if (inst && inst.length) {
          for (var i = 0; i < inst.length; i++) {
            if (inst[i] && typeof inst[i].play === 'function') {
              inst[i].play();
              return 'jwplayer';
            }
          }
        }
      }
    } catch (e) {}
    // video.js (Detik, TVRI, CNN)
    try {
      if (window.videojs && typeof window.videojs.getPlayers === 'function') {
        var players = window.videojs.getPlayers();
        for (var key in players) {
          try {
            players[key].play();
            return 'videojs';
          } catch (e) {}
        }
      }
    } catch (e) {}
    return null;
  }

  function clickBigPlayButton() {
    var selectors = [
      '.vjs-big-play-button',
      '.vjs-play-button',
      '.jwplayer-play-button',
      'button[aria-label*="Play" i]',
      'button[title*="Play" i]'
    ];
    for (var i = 0; i < selectors.length; i++) {
      var btn = document.querySelector(selectors[i]);
      if (btn) {
        try {
          btn.click();
          return true;
        } catch (e) {}
      }
    }
    return false;
  }

  try {
    var api = tryPlayerApi();
    var v = pickVideo();
    if (!v) {
      if (api) return api;
      if (clickBigPlayButton()) return 'clicked';
      return 'no-video';
    }

    if (!v.paused && v.readyState >= 2) return 'playing';

    var result = 'rejected';
    try {
      v.muted = false;
      var p = v.play();
      if (p && p.then) {
        p.then(function () {
          window.__renataAutoPlayResult = 'playing';
        }).catch(function () {
          try {
            v.muted = true;
            var p2 = v.play();
            if (p2 && p2.then) {
              p2.then(function () {
                window.__renataAutoPlayResult = 'muted-playing';
              }).catch(function () {});
            }
          } catch (e) {}
        });
      }
      result = 'playing';
    } catch (e) {
      try {
        v.muted = true;
        var p3 = v.play();
        if (p3 && p3.then) {
          p3.then(function () {
            window.__renataAutoPlayResult = 'muted-playing';
          }).catch(function () {});
        }
        result = 'muted-playing';
      } catch (e2) {
        result = 'error';
      }
    }

    if (api) {
      window.__renataAutoPlayResult = api;
    } else if (clickBigPlayButton()) {
      window.__renataAutoPlayResult = 'clicked';
    }
    return result;
  } catch (e) {
    return 'error';
  }
})()
''';

  /// Berapa kali skrip auto play dicoba, dan jeda antar percobaan.
  ///
  /// Pemutar web sering baru siap beberapa detik setelah halaman terbuka,
  /// jadi percobaan dilanjutkan sampai [_webAutoPlayMaxAttempts] kali.
  static const int _webAutoPlayMaxAttempts = 15;
  static const Duration _webAutoPlayInterval = Duration(seconds: 1);

  /// Jumlah percobaan auto play yang sudah dijalankan untuk halaman aktif.
  int _webAutoPlayAttempts = 0;

  /// Jalankan skrip auto play pada halaman web secara berkala.
  void _scheduleWebAutoPlay(WebViewController controller) {
    _webAutoPlayAttempts = 0;
    _runWebAutoPlayScript(controller);
  }

  Future<void> _runWebAutoPlayScript(WebViewController controller) async {
    // Abaikan kalau halaman sudah ditutup atau kanal sudah berganti.
    if (!mounted || controller != _webViewController) return;
    if (_webAutoPlayAttempts >= _webAutoPlayMaxAttempts) return;

    _webAutoPlayAttempts++;
    try {
      final result =
          await controller.runJavaScriptReturningResult(_webAutoPlayScript);
      debugPrint('Auto play percobaan $_webAutoPlayAttempts: $result');
    } catch (_) {
      // Halaman sudah ditutup atau controller sudah dilepas.
    }

    if (!mounted || controller != _webViewController) return;
    if (_webAutoPlayAttempts >= _webAutoPlayMaxAttempts) return;

    Future.delayed(_webAutoPlayInterval, () {
      _runWebAutoPlayScript(controller);
    });
  }

  void _setLoading(bool value) {
    if (!mounted) return;
    setState(() => _isLoading = value);
  }

  /// Pesan error yang ditampilkan ketika halaman utama kanal gagal dimuat.
  ///
  /// Untuk kanal yang kendalanya sudah diketahui (mis. sertifikat server
  /// kedaluwarsa), pesan dibuat lebih spesifik supaya pengguna tidak
  /// mengira itu masalah koneksi internet miliknya.
  String _mainFrameErrorMessage(Channel channel) {
    if (channel.id == 'idxtv') {
      return 'IDX TV sedang tidak tersedia. Sertifikat server VisionPlus '
          'untuk kanal ini kedaluwarsa, jadi live stream belum bisa dimuat. '
          'Coba lagi nanti.';
    }
    return 'Halaman live stream tidak dapat dimuat. '
        'Periksa koneksi internet Anda lalu coba lagi.';
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
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white24, width: 1),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.fullscreen_exit_rounded,
                            color: Colors.white, size: 26),
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(color: Colors.white24, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.live,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _currentChannel.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
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
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          titleSpacing: 16,
          title: Row(
            children: [
              Expanded(
                child: Text(
                  _currentChannel.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _buildLiveBadge(),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Favorit',
              onPressed: _toggleFavorite,
              icon: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: _isFavorite
                      ? AppColors.primary.withOpacity(0.18)
                      : Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _isFavorite
                        ? AppColors.primary.withOpacity(0.5)
                        : AppColors.border,
                  ),
                ),
                child: Icon(
                  _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: _isFavorite ? AppColors.primaryLight : AppColors.textSecondary,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              tooltip: 'Muat Ulang Siaran',
              onPressed: () => _setupPlayer(),
              icon: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(
                  Icons.refresh_rounded,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 8),
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
                    bottom: 10,
                    right: 10,
                    child: _buildFullScreenButton(),
                  ),
                ],
              ),
            ),

            // Detail Channel Info
            Container(
              margin: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: AppColors.glassGradient,
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.border),
                boxShadow: AppShadows.soft(opacity: 0.35, blur: 18, offsetY: 6),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Container(
                      width: 52,
                      height: 52,
                      color: Colors.white,
                      padding: const EdgeInsets.all(5),
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
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentChannel.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _buildInfoPill(
                              icon: Icons.category_rounded,
                              label: _currentChannel.category,
                            ),
                            const SizedBox(width: 6),
                            _buildInfoPill(
                              icon: Icons.cell_tower_rounded,
                              label: _streamTypeLabel(_currentChannel.type),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _currentChannel.description,
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: AppColors.border),

            // Daftar Channel Siaran Lainnya
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: AppColors.brandGradient,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Icon(Icons.live_tv_rounded,
                        color: Colors.white, size: 15),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Saluran TV Lainnya',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                      letterSpacing: -0.1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      '${widget.allChannels.length}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: widget.allChannels.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: AppColors.border),
                itemBuilder: (context, index) {
                  final ch = widget.allChannels[index];
                  final isSelected = ch.id == _currentChannel.id;

                  return Container(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.10)
                        : Colors.transparent,
                    child: ListTile(
                      selected: isSelected,
                      selectedTileColor: Colors.transparent,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 2),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        child: Container(
                          width: 42,
                          height: 42,
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
                          color: isSelected
                              ? AppColors.primaryLight
                              : AppColors.textPrimary,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${ch.category} • ${_streamTypeLabel(ch.type)}',
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primaryLight.withOpacity(0.8)
                              : AppColors.textMuted,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.play_circle_fill_rounded,
                              color: AppColors.primaryLight, size: 26)
                          : const Icon(Icons.chevron_right_rounded,
                              color: AppColors.textMuted, size: 22),
                      onTap: () => _switchChannel(ch),
                    ),
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
          width: 220,
          color: AppColors.backgroundSoft,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        gradient: AppColors.brandGradient,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: const Icon(Icons.live_tv_rounded,
                          color: Colors.white, size: 13),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Kanal (${widget.allChannels.length})',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.allChannels.length,
                  itemBuilder: (context, index) {
                    final ch = widget.allChannels[index];
                    final isSelected = ch.id == _currentChannel.id;
                    return ListTile(
                      dense: true,
                      selected: isSelected,
                      selectedTileColor: AppColors.primary.withOpacity(0.12),
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
                          color: isSelected
                              ? AppColors.primaryLight
                              : AppColors.textPrimary,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
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
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: IconButton(
        icon: const Icon(Icons.fullscreen_rounded, color: Colors.white, size: 22),
        tooltip: 'Layar Penuh (Landscape)',
        onPressed: _toggleFullScreen,
      ),
    );
  }

  /// Lencana "LIVE" dengan titik berdenyut di AppBar.
  Widget _buildLiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: AppShadows.glow(AppColors.primary, opacity: 0.3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          const Text(
            'LIVE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Lencana kecil berisi ikon dan teks, dipakai di panel info kanal.
  Widget _buildInfoPill({required IconData icon, required String label}) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: AppColors.primaryLight),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
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
              color: Colors.black45,
              child: Center(
                child: _buildOverlayMessage(
                  icon: Icons.hourglass_top_rounded,
                  label: 'Meny buffering...',
                ),
              ),
            ),

          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: _buildOverlayMessage(
                  icon: Icons.live_tv_rounded,
                  label: 'Menghubungkan ke siaran live...',
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Panel pesan yang muncul di tengah area video (loading / buffering).
  Widget _buildOverlayMessage({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(
              color: AppColors.primaryLight,
              strokeWidth: 2.4,
            ),
          ),
          const SizedBox(height: 12),
          Icon(icon, color: AppColors.textMuted, size: 18),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
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
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.signal_wifi_connected_no_internet_4_rounded,
                    color: AppColors.textMuted, size: 40),
                const SizedBox(height: 12),
                Text(
                  _playerError ?? 'Terjadi kesalahan saat memuat siaran.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => _setupPlayer(),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
