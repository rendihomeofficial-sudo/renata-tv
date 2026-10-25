// Uji parser playlist M3U RENATA TV.
//
// Menguji ChannelService.parseM3UContent tanpa akses jaringan:
//   1. Baris #EXTINF dibaca (nama, logo, group, tvg-id).
//   2. Jenis stream ditebak benar (m3u8 / youtube / webview).
//   3. Edge case: playlist kosong, baris tanpa EXTINF, atribut tanpa tanda kutip.

import 'package:flutter_test/flutter_test.dart';
import 'package:renata_tv/models/channel.dart';
import 'package:renata_tv/services/channel_service.dart';

void main() {
  group('parseM3UContent', () {
    test('playlist kosong menghasilkan daftar kosong', () {
      expect(ChannelService.parseM3UContent(''), isEmpty);
      expect(ChannelService.parseM3UContent('\n\n   \n'), isEmpty);
    });

    test('membaca nama, logo, kategori, dan id dari baris EXTINF', () {
      const content = '''
#EXTM3U
#EXTINF:-1 tvg-id="trans7" tvg-name="TRANS 7" tvg-logo="https://example.com/t7.png" group-title="Nasional",TRANS 7
https://example.com/live/trans7.m3u8
''';

      final channels = ChannelService.parseM3UContent(content);

      expect(channels, hasLength(1));
      final channel = channels.first;
      expect(channel.id, 'trans7');
      expect(channel.name, 'TRANS 7');
      expect(channel.logoUrl, 'https://example.com/t7.png');
      expect(channel.category, 'Nasional');
      expect(channel.streamUrl, 'https://example.com/live/trans7.m3u8');
    });

    test('menentukan jenis stream HLS untuk URL .m3u8', () {
      const content = '''
#EXTINF:-1,Contoh HLS
https://example.com/stream/index.m3u8
''';

      final channels = ChannelService.parseM3UContent(content);
      expect(channels.single.type, StreamType.m3u8);
      expect(channels.single.name, 'Contoh HLS');
    });

    test('menentukan jenis stream YouTube dan mengambil video id', () {
      const content = '''
#EXTINF:-1,TV One
https://www.youtube.com/watch?v=yNKvkPJl-tg
#EXTINF:-1,Kompas TV
https://youtu.be/DOOrIxw5xOw
#EXTINF:-1,Embed
https://www.youtube.com/embed/DOOrIxw5xOw
''';

      final channels = ChannelService.parseM3UContent(content);
      expect(channels, hasLength(3));
      expect(channels.every((c) => c.type == StreamType.youtube), isTrue);
      expect(channels[0].youtubeVideoId, 'yNKvkPJl-tg');
      expect(channels[1].youtubeVideoId, 'DOOrIxw5xOw');
      expect(channels[2].youtubeVideoId, 'DOOrIxw5xOw');
    });

    test('berkas video progresif memakai pemutar video native', () {
      const content = '''
#EXTINF:-1,Contoh MP4
https://example.com/video.mp4
#EXTINF:-1,Contoh MKV
https://example.com/video.mkv
''';

      final channels = ChannelService.parseM3UContent(content);
      expect(channels[0].type, StreamType.native);
      expect(channels[1].type, StreamType.native);
    });

    test('URL m3u8 dengan query string tetap dikenali sebagai HLS', () {
      const content = '''
#EXTINF:-1,HLS Bertoken
https://example.com/live/index.m3u8?token=abc123
''';

      final channels = ChannelService.parseM3UContent(content);
      expect(channels.single.type, StreamType.m3u8);
    });

    test('URL biasa tanpa .m3u8 dan bukan YouTube memakai webview', () {
      const content = '''
#EXTINF:-1,Detik TV
https://20.detik.com/watch/livestreaming-transtv
''';

      final channels = ChannelService.parseM3UContent(content);
      expect(channels.single.type, StreamType.webview);
      expect(channels.single.category, 'Umum');
    });

    test('baris URL tanpa EXTINF tetap dibuat dengan nama bawaan', () {
      const content = '''
https://example.com/stream.m3u8
''';

      final channels = ChannelService.parseM3UContent(content);
      expect(channels, hasLength(1));
      expect(channels.single.name, 'Channel');
      expect(channels.single.type, StreamType.m3u8);
      expect(channels.single.category, 'Umum');
      expect(channels.single.id, startsWith('m3u_'));
    });

    test('nama dari nilai setelah koma dipakai saat tvg-name kosong', () {
      const content = '''
#EXTINF:-1 tvg-logo="https://example.com/x.png",Nama Dari Koma
https://example.com/a.m3u8
''';

      final channels = ChannelService.parseM3UContent(content);
      expect(channels.single.name, 'Nama Dari Koma');
      expect(channels.single.logoUrl, 'https://example.com/x.png');
    });

    test('atribut tanpa tanda kutip tidak membuat parser crash', () {
      const content = '''
#EXTINF:-1 tvg-name=ChannelTanpaKutip group-title=Umum,Alternatif
https://example.com/b.m3u8
''';

      final channels = ChannelService.parseM3UContent(content);
      expect(channels, hasLength(1));
      expect(channels.single.streamUrl, 'https://example.com/b.m3u8');
    });

    test('baris komentar lain diabaikan', () {
      const content = '''
#EXTM3U
#PLAYLIST:Contoh
#EXTINF:-1,Channel Baik
https://example.com/ok.m3u8
#EXTVLCOPT:http-user-agent=Mozilla
''';

      final channels = ChannelService.parseM3UContent(content);
      expect(channels, hasLength(1));
      expect(channels.single.name, 'Channel Baik');
    });

    test('id fallback unik untuk channel tanpa tvg-id', () {
      const content = '''
#EXTINF:-1,Saluran A
https://example.com/a.m3u8
#EXTINF:-1,Saluran B
https://example.com/b.m3u8
''';

      final channels = ChannelService.parseM3UContent(content);
      expect(channels, hasLength(2));
      expect(channels[0].id, isNot(channels[1].id));
    });
  });
}
