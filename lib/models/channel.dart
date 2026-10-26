enum StreamType {
  youtube, // Menggunakan YouTube Player
  webview, // Menggunakan WebView In-App (untuk embed URL seperti Detik, RCTI+, CNN, TVRI)
  m3u8,    // Menggunakan Native HLS Video Player
  native,  // Menggunakan Native Video Player untuk file progresif (mp4, ts, mkv)
}

class Channel {
  final String id;
  final String name;
  final String streamUrl;
  final String logoUrl;
  final String category;
  final StreamType type;
  final String? youtubeVideoId;
  final String description;

  /// URL cadangan yang dipakai otomatis saat [streamUrl] gagal dimuat.
  ///
  /// Kanal live sering punya beberapa mirror resmi. Dengan daftar cadangan,
  /// pemutar mencoba URL berikutnya secara otomatis sehingga menonton tetap
  /// lancar walaupun satu mirror sedang bermasalah.
  final List<String> fallbackUrls;

  const Channel({
    required this.id,
    required this.name,
    required this.streamUrl,
    required this.logoUrl,
    required this.category,
    required this.type,
    this.youtubeVideoId,
    this.description = '',
    this.fallbackUrls = const <String>[],
  });

  /// Semua URL kanal Tried: URL utama lebih dulu, lalu URL cadangan.
  List<String> get allUrls => <String>[
        streamUrl,
        ...fallbackUrls.where((u) => u.isNotEmpty && u != streamUrl),
      ];

  factory Channel.fromJson(Map<String, dynamic> json) {
    final rawFallbacks = json['fallbackUrls'];
    final fallbacks = <String>[];
    if (rawFallbacks is List) {
      for (final item in rawFallbacks) {
        if (item is String && item.isNotEmpty) fallbacks.add(item);
      }
    }

    return Channel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      streamUrl: json['streamUrl'] ?? '',
      logoUrl: json['logoUrl'] ?? '',
      category: json['category'] ?? 'Umum',
      type: StreamType.values.firstWhere(
        (e) => e.name == '${json['type']}',
        orElse: () => StreamType.webview,
      ),
      youtubeVideoId: json['youtubeVideoId'],
      description: json['description'] ?? '',
      fallbackUrls: fallbacks,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'streamUrl': streamUrl,
      'logoUrl': logoUrl,
      'category': category,
      'type': type.name,
      'youtubeVideoId': youtubeVideoId,
      'description': description,
      'fallbackUrls': fallbackUrls,
    };
  }
}
