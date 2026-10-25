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

  const Channel({
    required this.id,
    required this.name,
    required this.streamUrl,
    required this.logoUrl,
    required this.category,
    required this.type,
    this.youtubeVideoId,
    this.description = '',
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
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
    };
  }
}
