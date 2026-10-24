import '../models/channel.dart';

class ChannelService {
  /// Daftar channel resmi RENATA TV sesuai link dan ID yang diberikan pengguna
  static final List<Channel> channels = [
    // 1. TRANS TV
    Channel(
      id: 'transtv',
      name: 'TRANS TV',
      streamUrl: 'https://20.detik.com/watch/livestreaming-transtv',
      logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/Trans_TV_logo_2013.svg/320px-Trans_TV_logo_2013.svg.png',
      category: 'Nasional',
      type: StreamType.webview,
      description: 'Siaran Langsung Trans TV - Hiburan & Informasi Keluarga',
    ),

    // 2. TRANS 7
    Channel(
      id: 'trans7',
      name: 'TRANS 7',
      streamUrl: 'https://20.detik.com/watch/livestreaming-trans7',
      logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/07/Trans7_2013.svg/320px-Trans7_2013.svg.png',
      category: 'Nasional',
      type: StreamType.webview,
      description: 'Siaran Langsung Trans 7 - Program Cerdas & Inspiratif',
    ),

    // 3. CNN INDONESIA
    Channel(
      id: 'cnn_indonesia',
      name: 'CNN INDONESIA',
      streamUrl: 'https://www.cnnindonesia.com/tv/embed?ref=transmedia&smartautoplay=true',
      logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4c/CNN_Indonesia_logo.svg/320px-CNN_Indonesia_logo.svg.png',
      category: 'Berita',
      type: StreamType.webview,
      description: 'Berita Terkini, Akurat & Terpercaya Indonesia',
    ),

    // 4. CNBC INDONESIA
    Channel(
      id: 'cnbc_indonesia',
      name: 'CNBC INDONESIA',
      streamUrl: 'https://www.cnbcindonesia.com/embed/tv?ref=transmedia&smartautoplay=true',
      logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cf/CNBC_Indonesia_logo.svg/320px-CNBC_Indonesia_logo.svg.png',
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
      logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/10/TvOne_2023.svg/320px-TvOne_2023.svg.png',
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
      logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cd/Kompas_TV_2018.svg/320px-Kompas_TV_2018.svg.png',
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
      logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7b/MetroTV_2010.svg/320px-MetroTV_2010.svg.png',
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
      logoUrl: 'https://images.unsplash.com/photo-1534567153574-2b12153a87f0?w=200&auto=format&fit=crop&q=60',
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
      logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/07/NET._2019.svg/320px-NET._2019.svg.png',
      category: 'Hiburan',
      type: StreamType.youtube,
      description: 'Televisi Masa Kini NET TV',
    ),

    // 10. INEWS TV
    Channel(
      id: 'inewstv',
      name: 'INEWS TV',
      streamUrl: 'https://embed.rctiplus.com/live/inews/inewsid',
      logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f6/INews_2017.svg/320px-INews_2017.svg.png',
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
      logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/9/91/Liputan_6_2018.svg/320px-Liputan_6_2018.svg.png',
      category: 'Berita',
      type: StreamType.youtube,
      description: 'Liputan6 SCTV Berita Terkini & Tajam',
    ),

    // 12. TVRI NASIONAL
    Channel(
      id: 'tvri',
      name: 'TVRI',
      streamUrl: 'https://klik.tvri.go.id/detailchannel/TVRI_CH_17',
      logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/TVRI_2019.svg/320px-TVRI_2019.svg.png',
      category: 'Nasional',
      type: StreamType.webview,
      description: 'Televisi Republik Indonesia Saluran Pemersatu Bangsa',
    ),

    // 13. GTV
    Channel(
      id: 'gtv',
      name: 'GTV',
      streamUrl: 'https://embed.rctiplus.com/live/gtv/inewsid',
      logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/GTV_2017.svg/320px-GTV_2017.svg.png',
      category: 'Hiburan',
      type: StreamType.webview,
      description: 'GTV Pilihan Terbaik Keluarga Indonesia',
    ),

    // 14. MNCTV
    Channel(
      id: 'mnctv',
      name: 'MNCTV',
      streamUrl: 'https://embed.rctiplus.com/live/mnctv/inewsid',
      logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/18/MNCTV_2011.svg/320px-MNCTV_2011.svg.png',
      category: 'Hiburan & Nasional',
      type: StreamType.webview,
      description: 'Selalu di Hati - MNCTV',
    ),

    // 15. IDX TV (INDONESIA STOCK EXCHANGE)
    Channel(
      id: 'idxtv',
      name: 'IDX TV',
      streamUrl: 'https://mncmpiwv.visionplus.id/playing/channels/67671',
      logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b3/Logo_IDX_Channel.png/320px-Logo_IDX_Channel.png',
      category: 'Berita & Bisnis',
      type: StreamType.webview,
      description: 'Saluran Resmi Informasi Bursa Efek Indonesia',
    ),
  ];

  static List<Channel> getChannels() {
    return List.from(channels);
  }

  static List<String> getCategories(List<Channel> channelList) {
    final Set<String> cats = {'Semua'};
    for (final ch in channelList) {
      cats.add(ch.category);
    }
    return cats.toList();
  }
}
