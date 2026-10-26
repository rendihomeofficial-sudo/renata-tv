import 'dart:convert';

import 'package:http/http.dart' as http;

import '../data/hls_channels.dart';
import '../models/channel.dart';

class ChannelService {
  /// Daftar channel resmi RENATA TV sesuai link dan ID yang diberikan pengguna
  static final List<Channel> channels = [
    // 1. TRANS TV
    Channel(
      id: 'transtv',
      name: 'TRANS TV',
      streamUrl: 'https://20.detik.com/watch/livestreaming-transtv',
      logoUrl: 'assets/logos/transtv.png',
      category: 'Nasional',
      type: StreamType.webview,
      description: 'Siaran Langsung Trans TV - Hiburan & Informasi Keluarga',
    ),

    // 2. TRANS 7
    Channel(
      id: 'trans7',
      name: 'TRANS 7',
      streamUrl: 'https://20.detik.com/watch/livestreaming-trans7',
      logoUrl: 'assets/logos/trans7.png',
      category: 'Nasional',
      type: StreamType.webview,
      description: 'Siaran Langsung Trans 7 - Program Cerdas & Inspiratif',
    ),

    // 3. CNN INDONESIA
    Channel(
      id: 'cnn_indonesia',
      name: 'CNN INDONESIA',
      streamUrl: 'https://www.cnnindonesia.com/tv/embed?ref=transmedia&smartautoplay=true',
      logoUrl: 'assets/logos/cnn_indonesia.png',
      category: 'Berita',
      type: StreamType.webview,
      description: 'Berita Terkini, Akurat & Terpercaya Indonesia',
    ),

    // 4. CNBC INDONESIA
    Channel(
      id: 'cnbc_indonesia',
      name: 'CNBC INDONESIA',
      streamUrl: 'https://www.cnbcindonesia.com/embed/tv?ref=transmedia&smartautoplay=true',
      logoUrl: 'assets/logos/cnbc_indonesia.png',
      category: 'Berita & Bisnis',
      type: StreamType.webview,
      description: 'Kanal Berita Ekonomi, Pasar Modal & Bisnis Terbesar',
    ),

    // 5. TV ONE (YOUTUBE)
    Channel(
      id: 'tvone',
      name: 'TV ONE',
      streamUrl: 'https://www.youtube.com/watch?v=yNKvkPJl-tg',
      youtubeVideoId: 'yNKvkPJl-tg',
      logoUrl: 'assets/logos/tvone.png',
      category: 'Berita',
      type: StreamType.youtube,
      description: 'TV One Memang Beda - Siaran Berita & Debat Nasional',
    ),

    // 6. KOMPAS TV (YOUTUBE)
    Channel(
      id: 'kompastv',
      name: 'KOMPAS TV',
      streamUrl: 'https://www.youtube.com/watch?v=DOOrIxw5xOw',
      youtubeVideoId: 'DOOrIxw5xOw',
      logoUrl: 'assets/logos/kompastv.png',
      category: 'Berita',
      type: StreamType.youtube,
      description: 'Saluran Berita Independen & Terpercaya Kompas TV',
    ),

    // 7. METRO TV (YOUTUBE)
    Channel(
      id: 'metrotv',
      name: 'METRO TV',
      streamUrl: 'https://www.youtube.com/watch?v=nfgnpM28xDA',
      youtubeVideoId: 'nfgnpM28xDA',
      logoUrl: 'assets/logos/metrotv.png',
      category: 'Berita',
      type: StreamType.youtube,
      description: 'Metro TV - Knowledge To Elevate',
    ),

    // 8. WILD (YOUTUBE)
    Channel(
      id: 'wild_nature',
      name: 'WILD (NATURE)',
      streamUrl: 'https://www.youtube.com/watch?v=BJ3Yv572V1A',
      youtubeVideoId: 'BJ3Yv572V1A',
      logoUrl: 'assets/logos/wild_nature.jpg',
      category: 'Edukasi & Alam',
      type: StreamType.youtube,
      description: 'Live Streaming Suasana Alam Liar & Satwa Liar',
    ),

    // 9. NET TV (YOUTUBE)
    Channel(
      id: 'nettv',
      name: 'NET TV',
      streamUrl: 'https://www.youtube.com/watch?v=8WCKaco64js',
      youtubeVideoId: '8WCKaco64js',
      logoUrl: 'assets/logos/nettv.png',
      category: 'Hiburan',
      type: StreamType.youtube,
      description: 'Televisi Masa Kini NET TV',
    ),

    // 10. INEWS TV
    Channel(
      id: 'inewstv',
      name: 'INEWS TV',
      streamUrl: 'https://embed.rctiplus.com/live/inews/inewsid',
      logoUrl: 'assets/logos/inewstv.png',
      category: 'Berita',
      type: StreamType.webview,
      description: 'iNews TV - Inspiring & Informative',
    ),

    // 11. LIPUTAN6 (YOUTUBE)
    Channel(
      id: 'liputan6',
      name: 'LIPUTAN6 SCTV',
      streamUrl: 'https://www.youtube.com/watch?v=XZCkAZtWbIY',
      youtubeVideoId: 'XZCkAZtWbIY',
      logoUrl: 'assets/logos/liputan6.png',
      category: 'Berita',
      type: StreamType.youtube,
      description: 'Liputan6 SCTV Berita Terkini & Tajam',
    ),

    // 12. TVRI NASIONAL
    Channel(
      id: 'tvri',
      name: 'TVRI',
      streamUrl: 'https://klik.tvri.go.id/detailchannel/TVRI_CH_17',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Nasional',
      type: StreamType.webview,
      description: 'Televisi Republik Indonesia Saluran Pemersatu Bangsa',
    ),

    // 13. GTV
    Channel(
      id: 'gtv',
      name: 'GTV',
      streamUrl: 'https://embed.rctiplus.com/live/gtv/inewsid',
      logoUrl: 'assets/logos/gtv.png',
      category: 'Hiburan',
      type: StreamType.webview,
      description: 'GTV Pilihan Terbaik Keluarga Indonesia',
    ),

    // 14. MNCTV
    Channel(
      id: 'mnctv',
      name: 'MNCTV',
      streamUrl: 'https://embed.rctiplus.com/live/mnctv/inewsid',
      logoUrl: 'assets/logos/mnctv.png',
      category: 'Hiburan & Nasional',
      type: StreamType.webview,
      description: 'Selalu di Hati - MNCTV',
    ),

    // 15. IDX TV (INDONESIA STOCK EXCHANGE)
    Channel(
      id: 'idxtv',
      name: 'IDX TV',
      streamUrl: 'https://mncmpiwv.visionplus.id/playing/channels/67671',
      logoUrl: 'assets/logos/idxtv.png',
      category: 'Berita & Bisnis',
      type: StreamType.webview,
      description: 'Saluran Resmi Informasi Bursa Efek Indonesia',
    ),
  ];

  /// Kanal bawaan aplikasi: kanal utama (webview/youtube) ditambah kanal
  /// HLS regional yang stream-nya sudah diverifikasi.
  static List<Channel> getChannels() {
    return [...channels, ...HlsChannels.channels];
  }

  static List<String> getCategories(List<Channel> channelList) {
    final Set<String> cats = {'Semua'};
    for (final ch in channelList) {
      cats.add(ch.category);
    }
    return cats.toList();
  }

  /// Unduh playlist M3U/M3U8 dari URL lalu parse menjadi daftar [Channel].
  /// Mengembalikan daftar kosong jika playlist tidak valid atau tidak berisi channel.
  static Future<List<Channel>> parseM3UFromUrl(String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return <Channel>[];

    final response = await http
        .get(Uri.parse(trimmed))
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw Exception('Server playlist merespons status ${response.statusCode}');
    }

    return parseM3UContent(response.body);
  }

  /// Parse isi mentah M3U menjadi daftar [Channel].
  static List<Channel> parseM3UContent(String content) {
    final lines = const LineSplitter().convert(content);
    final result = <Channel>[];

    String pendingName = '';
    String pendingLogo = '';
    String pendingGroup = '';
    String pendingId = '';

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      if (line.startsWith('#EXTINF')) {
        pendingName = _extractAttribute(line, 'tvg-name') ??
            _valueAfterComma(line) ??
            '';
        pendingLogo = _extractAttribute(line, 'tvg-logo') ?? '';
        pendingGroup = _extractAttribute(line, 'group-title') ?? '';
        pendingId = _extractAttribute(line, 'tvg-id') ?? '';
        continue;
      }

      if (line.startsWith('#')) continue;

      // Baris berikutnya adalah URL stream
      final youtubeId = _youtubeIdFromUrl(line);
      final type = youtubeId != null
          ? StreamType.youtube
          : _detectStreamType(line);

      final name = pendingName.isNotEmpty ? pendingName : 'Channel';
      final id = pendingId.isNotEmpty
          ? pendingId
          : 'm3u_${result.length}_${name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_')}';

      result.add(Channel(
        id: id,
        name: name,
        streamUrl: line,
        logoUrl: pendingLogo,
        category: pendingGroup.isNotEmpty ? pendingGroup : 'Umum',
        type: type,
        youtubeVideoId: youtubeId,
        description: 'Channel dari playlist M3U',
      ));

      pendingName = '';
      pendingLogo = '';
      pendingGroup = '';
      pendingId = '';
    }

    return result;
  }

  /// Deteksi jenis stream dari URL stream.
  ///
  /// - YouTube ditangani lebih dulu oleh [_youtubeIdFromUrl].
  /// - URL .m3u8 (HLS) diputar dengan pemutar HLS native.
  /// - Berkas video progresif (mp4/mkv/webm/mov) diputar dengan pemutar
  ///   video native, bukan WebView.
  /// - URL lainnya (embed web) memakai WebView.
  static StreamType _detectStreamType(String url) {
    final path = Uri.tryParse(url.trim())?.path.toLowerCase() ?? url.toLowerCase();

    if (path.endsWith('.m3u8') || path.endsWith('.m3u')) {
      return StreamType.m3u8;
    }
    if (path.endsWith('.mp4') ||
        path.endsWith('.mkv') ||
        path.endsWith('.webm') ||
        path.endsWith('.mov') ||
        path.endsWith('.ts')) {
      return StreamType.native;
    }
    return StreamType.webview;
  }

  /// Ambil nilai atribut berformat key="value" dari baris #EXTINF.
  static String? _extractAttribute(String line, String name) {
    final match = RegExp('$name="([^"]*)"', caseSensitive: false).firstMatch(line);
    return match?.group(1);
  }

  /// Ambil nama channel setelah koma terakhir pada baris #EXTINF.
  static String? _valueAfterComma(String line) {
    final index = line.lastIndexOf(',');
    if (index == -1 || index == line.length - 1) return null;
    return line.substring(index + 1).trim();
  }

  /// Ambil ID video YouTube dari berbagai bentuk URL.
  static String? _youtubeIdFromUrl(String url) {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || uri.host.isEmpty) return null;

    if (uri.host.contains('youtu.be')) {
      if (uri.pathSegments.isEmpty) return null;
      final id = uri.pathSegments.first;
      return id.isEmpty ? null : id;
    }

    if (uri.host.contains('youtube.com') ||
        uri.host.contains('youtube-nocookie.com')) {
      final v = uri.queryParameters['v'];
      if (v != null && v.isNotEmpty) return v;

      if (uri.pathSegments.length > 1) {
        final first = uri.pathSegments.first;
        if (first == 'embed' || first == 'live' || first == 'shorts') {
          final id = uri.pathSegments[1];
          if (id.isNotEmpty) return id;
        }
      }
    }

    return null;
  }
}
