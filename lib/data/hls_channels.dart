import '../models/channel.dart';

/// Daftar kanal TV Indonesia tambahan yang disiarkan lewat HLS (.m3u8).
///
/// Setiap URL di bawah ini sudah diverifikasi: playlist-nya bisa diakses
/// dan segmen video di dalamnya berisi data TS/fMP4 yang valid. Logo
/// disimpan sebagai aset lokal di `assets/logos/` supaya tampil cepat
/// tanpa jaringan.
class HlsChannels {
  static const List<Channel> channels = [
    // 1. Ahsan TV
    Channel(
      id: 'ahsan_tv',
      name: 'Ahsan TV',
      streamUrl: 'https://5bf7b725107e5.streamlock.net/ahsantv/ahsantv/playlist.m3u8',
      logoUrl: 'assets/logos/ahsan_tv.png',
      category: 'Religi',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Ahsan TV',
    ),

    // 2. AKTV
    Channel(
      id: 'aktv',
      name: 'AKTV',
      streamUrl: 'https://akativi.siar.us/live/akativi.m3u8',
      logoUrl: 'assets/logos/aktv.png',
      category: 'Nasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung AKTV',
    ),

    // 3. Al Wafa Tarim
    Channel(
      id: 'al_wafa_tarim',
      name: 'Al Wafa Tarim',
      streamUrl: 'https://ammedia.siar.us/ammedia/live/playlist.m3u8',
      logoUrl: 'assets/logos/al_wafa_tarim.png',
      category: 'Religi',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Al Wafa Tarim',
    ),

    // 4. Ashiil TV
    Channel(
      id: 'ashiil_tv',
      name: 'Ashiil TV',
      streamUrl: 'https://5bf7b725107e5.streamlock.net/ashiiltv/ashiiltv/playlist.m3u8',
      logoUrl: 'assets/logos/ashiil_tv.png',
      category: 'Religi',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Ashiil TV',
    ),

    // 5. Atambua TV
    Channel(
      id: 'atambua_tv',
      name: 'Atambua TV',
      streamUrl: 'http://122.248.43.242:1935/ATAMBUATV/_definst_/myStream/playlist.m3u8',
      logoUrl: 'assets/logos/atambua_tv.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Atambua TV',
    ),

    // 6. Balikpapan TV
    Channel(
      id: 'balikpapan_tv',
      name: 'Balikpapan TV',
      streamUrl: 'http://122.248.43.242:1935/BALIKPAPANTV/_definst_/myStream/playlist.m3u8',
      logoUrl: 'assets/logos/balikpapan_tv.png',
      category: 'Nasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Balikpapan TV',
    ),

    // 7. Bandung TV
    Channel(
      id: 'bandung_tv',
      name: 'Bandung TV',
      streamUrl: 'http://202.150.153.254:65500/bandungtvWEBSITE.m3u8',
      logoUrl: 'assets/logos/bandung_tv.png',
      category: 'Nasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Bandung TV',
    ),

    // 8. Banjar TV
    Channel(
      id: 'banjar_tv',
      name: 'Banjar TV',
      streamUrl: 'https://banjartv.siar.us/banjartv/live/playlist.m3u8',
      logoUrl: 'assets/logos/banjar_tv.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Banjar TV',
    ),

    // 9. Banten TV
    Channel(
      id: 'banten_tv',
      name: 'Banten TV',
      streamUrl: 'https://5bf7b725107e5.streamlock.net/bantentv/bantentv/playlist.m3u8',
      logoUrl: 'assets/logos/banten_tv.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Banten TV',
    ),

    // 10. BMS TV
    Channel(
      id: 'bms_tv',
      name: 'BMS TV',
      streamUrl: 'https://5bf7b725107e5.streamlock.net/bmstv/bmstv/playlist.m3u8',
      logoUrl: 'assets/logos/bms_tv.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung BMS TV',
    ),

    // 11. BN Channel
    Channel(
      id: 'bn_channel',
      name: 'BN Channel',
      streamUrl: 'https://flv.intechmedia.net/live/ch112.m3u8',
      logoUrl: 'assets/logos/bn_channel.png',
      category: 'Berita',
      type: StreamType.m3u8,
      description: 'Siaran Langsung BN Channel',
    ),

    // 12. BRTV
    Channel(
      id: 'brtv',
      name: 'BRTV',
      streamUrl: 'https://5bf7b725107e5.streamlock.net/brtv/brtv/playlist.m3u8',
      logoUrl: 'assets/logos/brtv.png',
      category: 'Nasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung BRTV',
    ),

    // 13. BTV
    Channel(
      id: 'btv',
      name: 'BTV',
      streamUrl: 'https://lnd0t3b922.tenbytecdn.com/ta-sg1/90369cf5-6ac2-411d-b3d0-15fae10a2e2c/master.m3u8',
      logoUrl: 'assets/logos/btv.png',
      category: 'Musik',
      type: StreamType.m3u8,
      description: 'Siaran Langsung BTV',
    ),

    // 14. Caruban TV
    Channel(
      id: 'caruban_tv',
      name: 'Caruban TV',
      streamUrl: 'https://stream.carubantv.id/hls/0/stream.m3u8',
      logoUrl: 'assets/logos/caruban_tv.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Caruban TV',
    ),

    // 15. DAAI TV
    Channel(
      id: 'daai_tv',
      name: 'DAAI TV',
      streamUrl: 'https://pull.daaiplus.com/live-DAAIPLUS/live-DAAIPLUS_HD.m3u8',
      logoUrl: 'assets/logos/daai_tv.png',
      category: 'Religi',
      type: StreamType.m3u8,
      description: 'Siaran Langsung DAAI TV',
    ),

    // 16. Davika TV
    Channel(
      id: 'davika_tv',
      name: 'Davika TV',
      streamUrl: 'https://5bf7b725107e5.streamlock.net/davika/davika/playlist.m3u8',
      logoUrl: 'assets/logos/davika_tv.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Davika TV',
    ),

    // 17. Dens Food Channel
    Channel(
      id: 'dens_food_channel',
      name: 'Dens Food Channel',
      streamUrl: 'https://op-flashcon-digdayahd-1.dens.tv/h/h221/02.m3u8',
      logoUrl: 'assets/logos/dens_food_channel.png',
      category: 'Kuliner',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Dens Food Channel',
    ),

    // 18. Dhamma TV
    Channel(
      id: 'dhamma_tv',
      name: 'Dhamma TV',
      streamUrl: 'https://b.webcache.maxindo.net.id/dhamma/dhamma.m3u8',
      logoUrl: 'assets/logos/dhamma_tv.png',
      category: 'Religi',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Dhamma TV',
    ),

    // 19. Dhoho TV
    Channel(
      id: 'dhoho_tv',
      name: 'Dhoho TV',
      streamUrl: 'https://dhohotv.siar.us/dhohotv/live/playlist.m3u8',
      logoUrl: 'assets/logos/dhoho_tv.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Dhoho TV',
    ),

    // 20. Duta TV
    Channel(
      id: 'duta_tv',
      name: 'Duta TV',
      streamUrl: 'https://dutatv.siar.us/dutatv/live/playlist.m3u8',
      logoUrl: 'assets/logos/duta_tv.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Duta TV',
    ),

    // 21. E International
    Channel(
      id: 'e_international',
      name: 'E International',
      streamUrl: 'https://vodcdn.bamboo-cloud.com/livehls/69a123b780c99d28cc0f0016/master.m3u8',
      logoUrl: 'assets/logos/e_international.png',
      category: 'Nasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung E International',
    ),

    // 22. Efarina TV
    Channel(
      id: 'efarina_tv',
      name: 'Efarina TV',
      streamUrl: 'https://live.efarinatv.com/hls/bgtaufikganteng.m3u8',
      logoUrl: 'assets/logos/efarina_tv.png',
      category: 'Nasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Efarina TV',
    ),

    // 23. Groovia Kanal
    Channel(
      id: 'groovia_kanal',
      name: 'Groovia Kanal',
      streamUrl: 'https://gist.githubusercontent.com/iptvonlinetv/02d209207082846012c15305f7471c55/raw/4439b54b986e696e6fcfba7a53380d85b27bbbc1/udp450.500.723:6050.m3u8',
      logoUrl: 'assets/logos/groovia_kanal.png',
      category: 'Nasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Groovia Kanal',
    ),

    // 24. Groovia Kids
    Channel(
      id: 'groovia_kids',
      name: 'Groovia Kids',
      streamUrl: 'https://gist.githubusercontent.com/iptvonlinetv/244b66c61f162a7c0c2b4fa59b528139/raw/2376b7ba1989ebbd383301ec7d645e222a6c9338/udp780.510.345:4545.m3u8',
      logoUrl: 'assets/logos/groovia_kids.png',
      category: 'Anak',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Groovia Kids',
    ),

    // 25. I Am Channel
    Channel(
      id: 'i_am_channel',
      name: 'I Am Channel',
      streamUrl: 'https://61146e7ab7a66.streamlock.net:8089/tes/1/chunklist.m3u8',
      logoUrl: 'assets/logos/i_am_channel.png',
      category: 'Religi',
      type: StreamType.m3u8,
      description: 'Siaran Langsung I Am Channel',
    ),

    // 26. Jambi TV
    Channel(
      id: 'jambi_tv',
      name: 'Jambi TV',
      streamUrl: 'https://jambitv.globaldigitalcore.com/hls/sah5tu7Eiveepohyieyie3OoteL2anga.m3u8',
      logoUrl: 'assets/logos/jambi_tv.png',
      category: 'Nasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Jambi TV',
    ),

    // 27. Jawa Pos TV
    Channel(
      id: 'jawa_pos_tv',
      name: 'Jawa Pos TV',
      streamUrl: 'http://122.248.43.242:1935/JAWAPOSTVJKT/_definst_/myStream/playlist.m3u8',
      logoUrl: 'assets/logos/jawa_pos_tv.png',
      category: 'Nasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Jawa Pos TV',
    ),

    // 28. Jek TV
    Channel(
      id: 'jek_tv',
      name: 'Jek TV',
      streamUrl: 'http://27.124.81.245:1935/jektv/myStream/playlist.m3u8',
      logoUrl: 'assets/logos/jek_tv.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Jek TV',
    ),

    // 29. Jogja Istimewa TV
    Channel(
      id: 'jogja_istimewa_tv',
      name: 'Jogja Istimewa TV',
      streamUrl: 'http://103.255.15.222:1935/tv/jitv_720p/playlist.m3u8',
      logoUrl: 'assets/logos/jogja_istimewa_tv.png',
      category: 'Nasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Jogja Istimewa TV',
    ),

    // 30. JTV Kediri
    Channel(
      id: 'jtv_kediri',
      name: 'JTV Kediri',
      streamUrl: 'http://122.248.43.242:1935/JTVKEDIRI/_definst_/myStream/playlist.m3u8',
      logoUrl: 'assets/logos/jtv.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung JTV Kediri',
    ),

    // 31. JTV Madiun
    Channel(
      id: 'jtv_madiun',
      name: 'JTV Madiun',
      streamUrl: 'http://122.248.43.242:1935/JTVMADIUN/_definst_/myStream/playlist.m3u8',
      logoUrl: 'assets/logos/jtv.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung JTV Madiun',
    ),

    // 32. JTV Malang
    Channel(
      id: 'jtv_malang',
      name: 'JTV Malang',
      streamUrl: 'http://122.248.43.242:1935/JTVMALANG/_definst_/myStream/playlist.m3u8',
      logoUrl: 'assets/logos/jtv.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung JTV Malang',
    ),

    // 33. JTV Surabaya
    Channel(
      id: 'jtv_surabaya',
      name: 'JTV Surabaya',
      streamUrl: 'http://122.248.43.242:1935/JTVSURABAYA/_definst_/myStream/playlist.m3u8',
      logoUrl: 'assets/logos/jtv.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung JTV Surabaya',
    ),

    // 34. Kawanua TV
    Channel(
      id: 'kawanua_tv',
      name: 'Kawanua TV',
      streamUrl: 'http://122.248.43.242:1935/KAWANUATV/_definst_/myStream/playlist.m3u8',
      logoUrl: 'assets/logos/kawanua_tv.png',
      category: 'Nasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Kawanua TV',
    ),

    // 35. Lingkar TV
    Channel(
      id: 'lingkar_tv',
      name: 'Lingkar TV',
      streamUrl: 'https://lingkartv.my.id/hls/lingkartv.m3u8',
      logoUrl: 'assets/logos/lingkar_tv.png',
      category: 'Berita',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Lingkar TV',
    ),

    // 36. Madani TV
    Channel(
      id: 'madani_tv',
      name: 'Madani TV',
      streamUrl: 'https://stream.asianastream.com/madani/madanitv.smil/playlist.m3u8',
      logoUrl: 'assets/logos/madani_tv.png',
      category: 'Religi',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Madani TV',
    ),

    // 37. Madu TV
    Channel(
      id: 'madu_tv',
      name: 'Madu TV',
      streamUrl: 'https://re1.siar.us/madutv/hd720/playlist.m3u8',
      logoUrl: 'assets/logos/madu_tv.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Madu TV',
    ),

    // 38. MDTV
    Channel(
      id: 'mdtv',
      name: 'MDTV',
      streamUrl: 'https://op-flashcon-digdayahd-1.dens.tv/h/h223/index.m3u8',
      logoUrl: 'assets/logos/mdtv.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung MDTV',
    ),

    // 39. MQTV
    Channel(
      id: 'mqtv',
      name: 'MQTV',
      streamUrl: 'https://5bf7b725107e5.streamlock.net/mqtv/mqtv/playlist.m3u8',
      logoUrl: 'assets/logos/mqtv.png',
      category: 'Hiburan',
      type: StreamType.m3u8,
      description: 'Siaran Langsung MQTV',
    ),

    // 40. Padang TV
    Channel(
      id: 'padang_tv',
      name: 'Padang TV',
      streamUrl: 'http://122.248.43.242:1935/PADANGTV/_definst_/myStream/playlist.m3u8',
      logoUrl: 'assets/logos/padang_tv.png',
      category: 'Nasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Padang TV',
    ),

    // 41. PKTV
    Channel(
      id: 'pktv',
      name: 'PKTV',
      streamUrl: 'https://streaming.id18.tunnel.my.id/hls/stream.m3u8',
      logoUrl: 'assets/logos/pktv.png',
      category: 'Nasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung PKTV',
    ),

    // 42. PONTV
    Channel(
      id: 'pontv',
      name: 'PONTV',
      streamUrl: 'http://122.248.43.242:1935/PONTV/_definst_/myStream/playlist.m3u8',
      logoUrl: 'assets/logos/pontv.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung PONTV',
    ),

    // 43. RBTV Jogja
    Channel(
      id: 'rbtv_jogja',
      name: 'RBTV Jogja',
      streamUrl: 'https://official.rbtvjogja.tv/live/mychannel.m3u8',
      logoUrl: 'assets/logos/rbtv_jogja.png',
      category: 'Nasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung RBTV Jogja',
    ),

    // 44. RCTV
    Channel(
      id: 'rctv',
      name: 'RCTV',
      streamUrl: 'https://v10.siar.us/rctv/live/playlist.m3u8',
      logoUrl: 'assets/logos/rctv.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung RCTV',
    ),

    // 45. Riau TV
    Channel(
      id: 'riau_tv',
      name: 'Riau TV',
      streamUrl: 'http://122.248.43.242:1935/RIAUTV/_definst_/myStream/playlist.m3u8',
      logoUrl: 'assets/logos/riau_tv.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Riau TV',
    ),

    // 46. Rodja TV
    Channel(
      id: 'rodja_tv',
      name: 'Rodja TV',
      streamUrl: 'https://rodjatv.com/rodjatv/live.m3u8',
      logoUrl: 'assets/logos/rodja_tv.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Rodja TV',
    ),

    // 47. RRI Net
    Channel(
      id: 'rri_net',
      name: 'RRI Net',
      streamUrl: 'https://private-streaming.rri.go.id/memfs/6f77c7b5-feb2-4935-9f89-e7e9fca0a54a_output_0.m3u8',
      logoUrl: 'assets/logos/rri_net.png',
      category: 'Berita',
      type: StreamType.m3u8,
      description: 'Siaran Langsung RRI Net',
    ),

    // 48. Salam TV
    Channel(
      id: 'salam_tv',
      name: 'Salam TV',
      streamUrl: 'https://live.salamtelevisi.com/hls/0/stream.m3u8',
      logoUrl: 'assets/logos/salam_tv.png',
      category: 'Religi',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Salam TV',
    ),

    // 49. Salira TV
    Channel(
      id: 'salira_tv',
      name: 'Salira TV',
      streamUrl: 'https://live.salira.tv:3870/stream/play.m3u8',
      logoUrl: 'assets/logos/salira_tv.png',
      category: 'Gaya Hidup',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Salira TV',
    ),

    // 50. SMTV
    Channel(
      id: 'smtv',
      name: 'SMTV',
      streamUrl: 'http://122.248.43.242:1935/SMTV/_definst_/myStream/playlist.m3u8',
      logoUrl: 'assets/logos/smtv.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung SMTV',
    ),

    // 51. Stara TV Bandung
    Channel(
      id: 'stara_tv_bandung',
      name: 'Stara TV Bandung',
      streamUrl: 'https://bandung.staratv.id/hls/0/stream.m3u8',
      logoUrl: 'assets/logos/stara_tv.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Stara TV Bandung',
    ),

    // 52. Stara TV Bojonegoro
    Channel(
      id: 'stara_tv_bojonegoro',
      name: 'Stara TV Bojonegoro',
      streamUrl: 'https://bojonegoro.staratv.id/hls/stream.m3u8',
      logoUrl: 'assets/logos/stara_tv.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Stara TV Bojonegoro',
    ),

    // 53. Stara TV Cianjur
    Channel(
      id: 'stara_tv_cianjur',
      name: 'Stara TV Cianjur',
      streamUrl: 'https://cianjur.staratv.id/hls/0/stream.m3u8',
      logoUrl: 'assets/logos/stara_tv.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Stara TV Cianjur',
    ),

    // 54. Stara TV Jakarta
    Channel(
      id: 'stara_tv_jakarta',
      name: 'Stara TV Jakarta',
      streamUrl: 'https://jakarta.staratv.id/hls/0/stream.m3u8',
      logoUrl: 'assets/logos/stara_tv.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Stara TV Jakarta',
    ),

    // 55. Stara TV Malang
    Channel(
      id: 'stara_tv_malang',
      name: 'Stara TV Malang',
      streamUrl: 'https://malang.staratv.id/hls/0/stream.m3u8',
      logoUrl: 'assets/logos/stara_tv.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Stara TV Malang',
    ),

    // 56. Stara TV Parahyangan
    Channel(
      id: 'stara_tv_parahyangan',
      name: 'Stara TV Parahyangan',
      streamUrl: 'https://parahyangan.staratv.id/hls/0/stream.m3u8',
      logoUrl: 'assets/logos/stara_tv.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Stara TV Parahyangan',
    ),

    // 57. STV
    Channel(
      id: 'stv',
      name: 'STV',
      streamUrl: 'http://122.248.43.242:1935/SAMARINDATV/_definst_/myStream/playlist.m3u8',
      logoUrl: 'assets/logos/stv.png',
      category: 'Nasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung STV',
    ),

    // 58. Suara Surabaya Visual Radio
    Channel(
      id: 'suara_surabaya_visual_radio',
      name: 'Suara Surabaya Visual Radio',
      streamUrl: 'https://ssfm.siar.us/ssfm/live/playlist.m3u8',
      logoUrl: 'assets/logos/suara_surabaya_visual_radio.png',
      category: 'Berita',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Suara Surabaya Visual Radio',
    ),

    // 59. Surau TV
    Channel(
      id: 'surau_tv',
      name: 'Surau TV',
      streamUrl: 'https://surau-tv-rtmp-surautv.ltjafv.easypanel.host/hls/surautv.m3u8',
      logoUrl: 'assets/logos/surau_tv.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Surau TV',
    ),

    // 60. The Indonesia Channel
    Channel(
      id: 'the_indonesia_channel',
      name: 'The Indonesia Channel',
      streamUrl: 'https://restreamer.indonusa.id:8443/d5f4ad43-1b5a-4b0f-8bef-5b37224ed221.m3u8',
      logoUrl: 'assets/logos/the_indonesia_channel.png',
      category: 'Gaya Hidup',
      type: StreamType.m3u8,
      description: 'Siaran Langsung The Indonesia Channel',
    ),

    // 61. TV 9 Nusantara
    Channel(
      id: 'tv_9_nusantara',
      name: 'TV 9 Nusantara',
      streamUrl: 'https://5bf7b725107e5.streamlock.net/tv9/tv9/playlist.m3u8',
      logoUrl: 'assets/logos/tv_9_nusantara.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TV 9 Nusantara',
    ),

    // 62. TV Tabalong
    Channel(
      id: 'tv_tabalong',
      name: 'TV Tabalong',
      streamUrl: 'https://5bf7b725107e5.streamlock.net/tvtabalong/tvtabalong/playlist.m3u8',
      logoUrl: 'assets/logos/tv_tabalong.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TV Tabalong',
    ),

    // 63. TVRI Aceh
    Channel(
      id: 'tvri_aceh',
      name: 'TVRI Aceh',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Aceh/hls/Aceh.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Aceh',
    ),

    // 64. TVRI Ambon
    Channel(
      id: 'tvri_ambon',
      name: 'TVRI Ambon',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Ambon/hls/Ambon.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Ambon',
    ),

    // 65. TVRI Babel
    Channel(
      id: 'tvri_babel',
      name: 'TVRI Babel',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Babel/hls/Babel.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Babel',
    ),

    // 66. TVRI Bali
    Channel(
      id: 'tvri_bali',
      name: 'TVRI Bali',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Bali/hls/Bali.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Bali',
    ),

    // 67. TVRI Bengkulu
    Channel(
      id: 'tvri_bengkulu',
      name: 'TVRI Bengkulu',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Bengkulu/hls/Bengkulu.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Bengkulu',
    ),

    // 68. TVRI DKI
    Channel(
      id: 'tvri_dki',
      name: 'TVRI DKI',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/DKI/hls/DKI.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI DKI',
    ),

    // 69. TVRI Gorontalo
    Channel(
      id: 'tvri_gorontalo',
      name: 'TVRI Gorontalo',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Gorontalo/hls/Gorontalo.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Gorontalo',
    ),

    // 70. TVRI Jabar
    Channel(
      id: 'tvri_jabar',
      name: 'TVRI Jabar',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Jabar/hls/Jabar.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Jabar',
    ),

    // 71. TVRI Jambi
    Channel(
      id: 'tvri_jambi',
      name: 'TVRI Jambi',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Jambi/hls/Jambi.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Jambi',
    ),

    // 72. TVRI Jateng
    Channel(
      id: 'tvri_jateng',
      name: 'TVRI Jateng',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Jateng/hls/Jateng.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Jateng',
    ),

    // 73. TVRI Jatim
    Channel(
      id: 'tvri_jatim',
      name: 'TVRI Jatim',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Jatim/hls/Jatim.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Jatim',
    ),

    // 74. TVRI Jogjakarta
    Channel(
      id: 'tvri_jogjakarta',
      name: 'TVRI Jogjakarta',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Jogjakarta/hls/Jogjakarta.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Jogjakarta',
    ),

    // 75. TVRI Kalbar
    Channel(
      id: 'tvri_kalbar',
      name: 'TVRI Kalbar',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Kalbar/hls/Kalbar.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Kalbar',
    ),

    // 76. TVRI Kalsel
    Channel(
      id: 'tvri_kalsel',
      name: 'TVRI Kalsel',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Kalsel/hls/Kalsel.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Kalsel',
    ),

    // 77. TVRI Kalteng
    Channel(
      id: 'tvri_kalteng',
      name: 'TVRI Kalteng',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Kalteng/hls/Kalteng.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Kalteng',
    ),

    // 78. TVRI Kaltim
    Channel(
      id: 'tvri_kaltim',
      name: 'TVRI Kaltim',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Kaltim/hls/Kaltim.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Kaltim',
    ),

    // 79. TVRI Lampung
    Channel(
      id: 'tvri_lampung',
      name: 'TVRI Lampung',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Lampung/hls/Lampung.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Lampung',
    ),

    // 80. TVRI Nasional
    Channel(
      id: 'tvri_nasional',
      name: 'TVRI Nasional',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Nasional/hls/Nasional.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Nasional',
    ),

    // 81. TVRI NTB
    Channel(
      id: 'tvri_ntb',
      name: 'TVRI NTB',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/NTB/hls/NTB.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI NTB',
    ),

    // 82. TVRI NTT
    Channel(
      id: 'tvri_ntt',
      name: 'TVRI NTT',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/NTT/hls/NTT.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI NTT',
    ),

    // 83. TVRI Pabar
    Channel(
      id: 'tvri_pabar',
      name: 'TVRI Pabar',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Pabar/hls/Pabar.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Pabar',
    ),

    // 84. TVRI Papua
    Channel(
      id: 'tvri_papua',
      name: 'TVRI Papua',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Papua/hls/Papua.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Papua',
    ),

    // 85. TVRI Riau
    Channel(
      id: 'tvri_riau',
      name: 'TVRI Riau',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Riau/hls/Riau.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Riau',
    ),

    // 86. TVRI Sulbar
    Channel(
      id: 'tvri_sulbar',
      name: 'TVRI Sulbar',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Sulbar/hls/Sulbar.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Sulbar',
    ),

    // 87. TVRI Sulsel
    Channel(
      id: 'tvri_sulsel',
      name: 'TVRI Sulsel',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Sulsel/hls/Sulsel.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Sulsel',
    ),

    // 88. TVRI Sulteng
    Channel(
      id: 'tvri_sulteng',
      name: 'TVRI Sulteng',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Sulteng/hls/Sulteng.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Sulteng',
    ),

    // 89. TVRI Sultra
    Channel(
      id: 'tvri_sultra',
      name: 'TVRI Sultra',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Sultra/hls/Sultra.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Sultra',
    ),

    // 90. TVRI Sulut
    Channel(
      id: 'tvri_sulut',
      name: 'TVRI Sulut',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Sulut/hls/Sulut.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Sulut',
    ),

    // 91. TVRI Sumbar
    Channel(
      id: 'tvri_sumbar',
      name: 'TVRI Sumbar',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Sumbar/hls/Sumbar.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Sumbar',
    ),

    // 92. TVRI Sumut
    Channel(
      id: 'tvri_sumut',
      name: 'TVRI Sumut',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Sumut/hls/Sumut.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Sumut',
    ),

    // 93. TVRI World
    Channel(
      id: 'tvri_world',
      name: 'TVRI World',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/TVRIWorld/hls/TVRIWorld.m3u8',
      logoUrl: 'assets/logos/tvri_world.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI World',
    ),

    // 94. USM TV
    Channel(
      id: 'usm_tv',
      name: 'USM TV',
      streamUrl: 'https://play.fsa-stream.my.id/hls/siaran.m3u8',
      logoUrl: 'assets/logos/usm_tv.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung USM TV',
    ),

    // 95. VTV
    Channel(
      id: 'vtv',
      name: 'VTV',
      streamUrl: 'https://flv.intechmedia.net/live/ch107.m3u8',
      logoUrl: 'assets/logos/vtv.png',
      category: 'Nasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung VTV',
    ),

    // 96. YOY International
    Channel(
      id: 'yoy_international',
      name: 'YOY International',
      streamUrl: 'https://gist.githubusercontent.com/iptvonlinetv/8a6b2f12e5e968537378f1245cea02c9/raw/78bf84476f8e24cc8ea9d5ac24855078c61b18db/udp305.575.530:3030.m3u8',
      logoUrl: 'assets/logos/yoy_international.png',
      category: 'Nasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung YOY International',
    ),
  ];
}
