import '../models/channel.dart';

/// Daftar kanal TV Indonesia & internasional yang disiarkan lewat HLS.
///
/// Semua URL di bawah ini sudah diverifikasi lewat probe playlist:
/// playlist dapat diakses dan segmen video di dalamnya berisi data
/// TS/fMP4 yang valid. Kanal dengan beberapa mirror resmi menyimpan
/// mirror alternatif pada `fallbackUrls` sehingga pemutar otomatis
/// pindah ke mirror lain saat stream utama bermasalah.
///
/// Logo disimpan sebagai aset lokal di `assets/logos/` agar tampil cepat
/// tanpa jaringan; bila logo daring dipakai, channel_card menanganinya.
class HlsChannels {
  static const List<Channel> channels = [
    // 1. Al Wafa Tarim
    Channel(
      id: 'al_wafa_tarim',
      name: 'Al Wafa Tarim',
      streamUrl: 'https://ammedia.siar.us/ammedia/live/playlist.m3u8',
      logoUrl: 'assets/logos/al_wafa_tarim.png',
      category: 'Religi',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Al Wafa Tarim',
    ),

    // 2. Bandung TV
    Channel(
      id: 'bandung_tv',
      name: 'Bandung TV',
      streamUrl: 'http://202.150.153.254:65500/bandungtvWEBSITE.m3u8',
      logoUrl: 'assets/logos/bandung_tv.png',
      category: 'Nasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Bandung TV',
    ),

    // 3. BN Channel
    Channel(
      id: 'bn_channel',
      name: 'BN Channel',
      streamUrl: 'https://flv.intechmedia.net/live/ch112.m3u8',
      logoUrl: 'assets/logos/bn_channel.png',
      category: 'Berita',
      type: StreamType.m3u8,
      description: 'Siaran Langsung BN Channel',
    ),

    // 4. Caruban TV
    Channel(
      id: 'caruban_tv',
      name: 'Caruban TV',
      streamUrl: 'https://stream.carubantv.id/hls/0/stream.m3u8',
      logoUrl: 'assets/logos/caruban_tv.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Caruban TV',
    ),

    // 5. DAAI TV
    Channel(
      id: 'daai_tv',
      name: 'DAAI TV',
      streamUrl: 'https://pull.daaiplus.com/live-DAAIPLUS/live-DAAIPLUS_HD.m3u8',
      logoUrl: 'assets/logos/daai_tv.png',
      category: 'Religi',
      type: StreamType.m3u8,
      description: 'Siaran Langsung DAAI TV',
    ),

    // 6. Dens Food Channel
    Channel(
      id: 'dens_food_channel',
      name: 'Dens Food Channel',
      streamUrl: 'https://op-flashcon-digdayahd-1.dens.tv/h/h221/02.m3u8',
      logoUrl: 'assets/logos/dens_food_channel.png',
      category: 'Kuliner',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Dens Food Channel',
    ),

    // 7. Dhamma TV
    Channel(
      id: 'dhamma_tv',
      name: 'Dhamma TV',
      streamUrl: 'https://b.webcache.maxindo.net.id/dhamma/dhamma.m3u8',
      logoUrl: 'assets/logos/dhamma_tv.png',
      category: 'Religi',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Dhamma TV',
    ),

    // 8. Dhoho TV
    Channel(
      id: 'dhoho_tv',
      name: 'Dhoho TV',
      streamUrl: 'https://dhohotv.siar.us/dhohotv/live/playlist.m3u8',
      logoUrl: 'assets/logos/dhoho_tv.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Dhoho TV',
    ),

    // 9. Duta TV
    Channel(
      id: 'duta_tv',
      name: 'Duta TV',
      streamUrl: 'https://dutatv.siar.us/dutatv/live/playlist.m3u8',
      logoUrl: 'assets/logos/duta_tv.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Duta TV',
    ),

    // 10. E International
    Channel(
      id: 'e_international',
      name: 'E International',
      streamUrl: 'https://gist.githubusercontent.com/iptvonlinetv/cf56ccf36d1c0827e4dc470db7b7912d/raw/066b1c9755b2496805575f16d413bd1207ca8117/udp410.310.578:2020.m3u8',
      logoUrl: '',
      category: 'General',
      type: StreamType.m3u8,
      description: 'Siaran Langsung E International',
      fallbackUrls: [
        'https://vodcdn.bamboo-cloud.com/livehls/69a123b780c99d28cc0f0016/master.m3u8',
        'https://gist.githubusercontent.com/iptvonlinetv/cf56ccf36d1c0827e4dc470db7b7912d/raw/066b1c9755b2496805575f16d413bd1207ca8117/udp315.520.789:8060.m3u8',
        'https://gist.githubusercontent.com/iptvonlinetv/cf56ccf36d1c0827e4dc470db7b7912d/raw/066b1c9755b2496805575f16d413bd1207ca8117/udp120.510.450:6060.m3u8',
      ],
    ),

    // 11. Efarina TV
    Channel(
      id: 'efarina_tv',
      name: 'Efarina TV',
      streamUrl: 'https://live.efarinatv.com/hls/bgtaufikganteng.m3u8',
      logoUrl: 'assets/logos/efarina_tv.png',
      category: 'Nasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Efarina TV',
    ),

    // 12. Groovia Kanal
    Channel(
      id: 'groovia_kanal',
      name: 'Groovia Kanal',
      streamUrl: 'https://gist.githubusercontent.com/iptvonlinetv/02d209207082846012c15305f7471c55/raw/4439b54b986e696e6fcfba7a53380d85b27bbbc1/udp450.500.723:6050.m3u8',
      logoUrl: 'assets/logos/groovia_kanal.png',
      category: 'Nasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Groovia Kanal',
    ),

    // 13. Groovia Kids
    Channel(
      id: 'groovia_kids',
      name: 'Groovia Kids',
      streamUrl: 'https://gist.githubusercontent.com/iptvonlinetv/244b66c61f162a7c0c2b4fa59b528139/raw/2376b7ba1989ebbd383301ec7d645e222a6c9338/udp780.510.345:4545.m3u8',
      logoUrl: 'assets/logos/groovia_kids.png',
      category: 'Anak',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Groovia Kids',
    ),

    // 14. I Am Channel
    Channel(
      id: 'i_am_channel',
      name: 'I Am Channel',
      streamUrl: 'https://61146e7ab7a66.streamlock.net:8089/tes/1/chunklist.m3u8',
      logoUrl: 'assets/logos/i_am_channel.png',
      category: 'Religi',
      type: StreamType.m3u8,
      description: 'Siaran Langsung I Am Channel',
    ),

    // 15. Jambi TV
    Channel(
      id: 'jambi_tv',
      name: 'Jambi TV',
      streamUrl: 'https://jambitv.globaldigitalcore.com/hls/sah5tu7Eiveepohyieyie3OoteL2anga.m3u8',
      logoUrl: 'assets/logos/jambi_tv.png',
      category: 'Nasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Jambi TV',
    ),

    // 16. Lingkar TV
    Channel(
      id: 'lingkar_tv',
      name: 'Lingkar TV',
      streamUrl: 'https://lingkartv.my.id/hls/lingkartv.m3u8',
      logoUrl: 'assets/logos/lingkar_tv.png',
      category: 'Berita',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Lingkar TV',
    ),

    // 17. Madani TV
    Channel(
      id: 'madani_tv',
      name: 'Madani TV',
      streamUrl: 'https://stream.asianastream.com/madani/madanitv.smil/playlist.m3u8',
      logoUrl: 'assets/logos/madani_tv.png',
      category: 'Religi',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Madani TV',
    ),

    // 18. MDTV
    Channel(
      id: 'mdtv',
      name: 'MDTV',
      streamUrl: 'https://op-flashcon-digdayahd-1.dens.tv/h/h223/index.m3u8',
      logoUrl: 'assets/logos/mdtv.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung MDTV',
    ),

    // 19. PKTV
    Channel(
      id: 'pktv',
      name: 'PKTV',
      streamUrl: 'https://streaming.id18.tunnel.my.id/hls/stream.m3u8',
      logoUrl: 'assets/logos/pktv.png',
      category: 'Nasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung PKTV',
    ),

    // 20. RBTV Jogja
    Channel(
      id: 'rbtv_jogja',
      name: 'RBTV Jogja',
      streamUrl: 'https://official.rbtvjogja.tv/live/mychannel.m3u8',
      logoUrl: 'assets/logos/rbtv_jogja.png',
      category: 'Nasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung RBTV Jogja',
    ),

    // 21. Salam TV
    Channel(
      id: 'salam_tv',
      name: 'Salam TV',
      streamUrl: 'https://live.salamtelevisi.com/hls/0/stream.m3u8',
      logoUrl: 'assets/logos/salam_tv.png',
      category: 'Religi',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Salam TV',
    ),

    // 22. Salira TV
    Channel(
      id: 'salira_tv',
      name: 'Salira TV',
      streamUrl: 'https://live.salira.tv/p/3870/hybrid/play.m3u8',
      logoUrl: '',
      category: 'Culture',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Salira TV',
      fallbackUrls: [
        'https://live.salira.tv:3870/stream/play.m3u8',
      ],
    ),

    // 23. Stara TV Bandung
    Channel(
      id: 'stara_tv_bandung',
      name: 'Stara TV Bandung',
      streamUrl: 'https://bandung.staratv.id/hls/0/stream.m3u8',
      logoUrl: 'assets/logos/stara_tv.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Stara TV Bandung',
    ),

    // 24. Stara TV Bojonegoro
    Channel(
      id: 'stara_tv_bojonegoro',
      name: 'Stara TV Bojonegoro',
      streamUrl: 'https://bojonegoro.staratv.id/hls/stream.m3u8',
      logoUrl: 'assets/logos/stara_tv.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Stara TV Bojonegoro',
    ),

    // 25. Stara TV Cianjur
    Channel(
      id: 'stara_tv_cianjur',
      name: 'Stara TV Cianjur',
      streamUrl: 'https://cianjur.staratv.id/hls/0/stream.m3u8',
      logoUrl: 'assets/logos/stara_tv.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Stara TV Cianjur',
    ),

    // 26. Suara Surabaya Visual Radio
    Channel(
      id: 'suara_surabaya_visual_radio',
      name: 'Suara Surabaya Visual Radio',
      streamUrl: 'https://ssfm.siar.us/ssfm/live/playlist.m3u8',
      logoUrl: 'assets/logos/suara_surabaya_visual_radio.png',
      category: 'Berita',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Suara Surabaya Visual Radio',
    ),

    // 27. Surau TV
    Channel(
      id: 'surau_tv',
      name: 'Surau TV',
      streamUrl: 'https://surau-tv-rtmp-surautv.ltjafv.easypanel.host/hls/surautv.m3u8',
      logoUrl: 'assets/logos/surau_tv.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Surau TV',
    ),

    // 28. The Indonesia Channel
    Channel(
      id: 'the_indonesia_channel',
      name: 'The Indonesia Channel',
      streamUrl: 'https://restreamer.indonusa.id:8443/d5f4ad43-1b5a-4b0f-8bef-5b37224ed221.m3u8',
      logoUrl: 'assets/logos/the_indonesia_channel.png',
      category: 'Gaya Hidup',
      type: StreamType.m3u8,
      description: 'Siaran Langsung The Indonesia Channel',
    ),

    // 29. TVRI Aceh
    Channel(
      id: 'tvri_aceh',
      name: 'TVRI Aceh',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Aceh/hls/Aceh.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Aceh',
    ),

    // 30. TVRI Ambon
    Channel(
      id: 'tvri_ambon',
      name: 'TVRI Ambon',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Ambon/hls/Ambon.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Ambon',
    ),

    // 31. TVRI Babel
    Channel(
      id: 'tvri_babel',
      name: 'TVRI Babel',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Babel/hls/Babel.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Babel',
    ),

    // 32. TVRI Bali
    Channel(
      id: 'tvri_bali',
      name: 'TVRI Bali',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Bali/hls/Bali.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Bali',
    ),

    // 33. TVRI Bengkulu
    Channel(
      id: 'tvri_bengkulu',
      name: 'TVRI Bengkulu',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Bengkulu/hls/Bengkulu.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Bengkulu',
    ),

    // 34. TVRI DKI
    Channel(
      id: 'tvri_dki',
      name: 'TVRI DKI',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/DKI/hls/DKI.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI DKI',
    ),

    // 35. TVRI Gorontalo
    Channel(
      id: 'tvri_gorontalo',
      name: 'TVRI Gorontalo',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Gorontalo/hls/Gorontalo.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Gorontalo',
    ),

    // 36. TVRI Jabar
    Channel(
      id: 'tvri_jabar',
      name: 'TVRI Jabar',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Jabar/hls/Jabar.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Jabar',
    ),

    // 37. TVRI Jambi
    Channel(
      id: 'tvri_jambi',
      name: 'TVRI Jambi',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Jambi/hls/Jambi.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Jambi',
    ),

    // 38. TVRI Jateng
    Channel(
      id: 'tvri_jateng',
      name: 'TVRI Jateng',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Jateng/hls/Jateng.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Jateng',
    ),

    // 39. TVRI Jatim
    Channel(
      id: 'tvri_jatim',
      name: 'TVRI Jatim',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Jatim/hls/Jatim.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Jatim',
    ),

    // 40. TVRI Jogjakarta
    Channel(
      id: 'tvri_jogjakarta',
      name: 'TVRI Jogjakarta',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Jogjakarta/hls/Jogjakarta.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Jogjakarta',
    ),

    // 41. TVRI Kalbar
    Channel(
      id: 'tvri_kalbar',
      name: 'TVRI Kalbar',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Kalbar/hls/Kalbar.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Kalbar',
    ),

    // 42. TVRI Kalsel
    Channel(
      id: 'tvri_kalsel',
      name: 'TVRI Kalsel',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Kalsel/hls/Kalsel.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Kalsel',
    ),

    // 43. TVRI Kalteng
    Channel(
      id: 'tvri_kalteng',
      name: 'TVRI Kalteng',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Kalteng/hls/Kalteng.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Kalteng',
    ),

    // 44. TVRI Kaltim
    Channel(
      id: 'tvri_kaltim',
      name: 'TVRI Kaltim',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Kaltim/hls/Kaltim.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Kaltim',
    ),

    // 45. TVRI Lampung
    Channel(
      id: 'tvri_lampung',
      name: 'TVRI Lampung',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Lampung/hls/Lampung.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Lampung',
    ),

    // 46. TVRI Nasional
    Channel(
      id: 'tvri_nasional',
      name: 'TVRI Nasional',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Nasional/hls/Nasional.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Nasional',
      fallbackUrls: [
        'https://ott-balancer.tvri.go.id/live/eds/Aceh/hls/Aceh.m3u8',
        'https://ott-balancer.tvri.go.id/live/eds/Bali/hls/Bali.m3u8',
        'https://ott-balancer.tvri.go.id/live/eds/Babel/hls/Babel.m3u8',
      ],
    ),

    // 47. TVRI NTB
    Channel(
      id: 'tvri_ntb',
      name: 'TVRI NTB',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/NTB/hls/NTB.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI NTB',
    ),

    // 48. TVRI NTT
    Channel(
      id: 'tvri_ntt',
      name: 'TVRI NTT',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/NTT/hls/NTT.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI NTT',
    ),

    // 49. TVRI Pabar
    Channel(
      id: 'tvri_pabar',
      name: 'TVRI Pabar',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Pabar/hls/Pabar.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Pabar',
    ),

    // 50. TVRI Papua
    Channel(
      id: 'tvri_papua',
      name: 'TVRI Papua',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Papua/hls/Papua.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Papua',
    ),

    // 51. TVRI Riau
    Channel(
      id: 'tvri_riau',
      name: 'TVRI Riau',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Riau/hls/Riau.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Riau',
    ),

    // 52. TVRI Sulbar
    Channel(
      id: 'tvri_sulbar',
      name: 'TVRI Sulbar',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Sulbar/hls/Sulbar.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Sulbar',
    ),

    // 53. TVRI Sulsel
    Channel(
      id: 'tvri_sulsel',
      name: 'TVRI Sulsel',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Sulsel/hls/Sulsel.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Sulsel',
    ),

    // 54. TVRI Sulteng
    Channel(
      id: 'tvri_sulteng',
      name: 'TVRI Sulteng',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Sulteng/hls/Sulteng.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Sulteng',
    ),

    // 55. TVRI Sultra
    Channel(
      id: 'tvri_sultra',
      name: 'TVRI Sultra',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Sultra/hls/Sultra.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Sultra',
    ),

    // 56. TVRI Sulut
    Channel(
      id: 'tvri_sulut',
      name: 'TVRI Sulut',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Sulut/hls/Sulut.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Sulut',
    ),

    // 57. TVRI Sumbar
    Channel(
      id: 'tvri_sumbar',
      name: 'TVRI Sumbar',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Sumbar/hls/Sumbar.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Sumbar',
    ),

    // 58. TVRI Sumut
    Channel(
      id: 'tvri_sumut',
      name: 'TVRI Sumut',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Sumut/hls/Sumut.m3u8',
      logoUrl: 'assets/logos/tvri.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI Sumut',
    ),

    // 59. TVRI World
    Channel(
      id: 'tvri_world',
      name: 'TVRI World',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/TVRIWorld/hls/TVRIWorld.m3u8',
      logoUrl: 'assets/logos/tvri_world.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI World',
    ),

    // 60. USM TV
    Channel(
      id: 'usm_tv',
      name: 'USM TV',
      streamUrl: 'https://play.fsa-stream.my.id/hls/siaran.m3u8',
      logoUrl: 'assets/logos/usm_tv.png',
      category: 'Daerah',
      type: StreamType.m3u8,
      description: 'Siaran Langsung USM TV',
    ),

    // 61. VTV
    Channel(
      id: 'vtv',
      name: 'VTV',
      streamUrl: 'https://flv.intechmedia.net/live/ch107.m3u8',
      logoUrl: 'assets/logos/vtv.png',
      category: 'Nasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung VTV',
      fallbackUrls: [
        'https://sunplay-cdn.bitratelabs.com/live/local-channel/vtv-7a0f24809c234ea78d972b1f336ac1b9/index.m3u8',
      ],
    ),

    // 62. YOY International
    Channel(
      id: 'yoy_international',
      name: 'YOY International',
      streamUrl: 'https://gist.githubusercontent.com/iptvonlinetv/8a6b2f12e5e968537378f1245cea02c9/raw/78bf84476f8e24cc8ea9d5ac24855078c61b18db/udp305.575.530:3030.m3u8',
      logoUrl: 'assets/logos/yoy_international.png',
      category: 'Nasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung YOY International',
    ),

    // 63. E International Asia
    Channel(
      id: 'e_international_asia',
      name: 'E International Asia',
      streamUrl: 'https://gist.githubusercontent.com/iptvonlinetv/cf56ccf36d1c0827e4dc470db7b7912d/raw/066b1c9755b2496805575f16d413bd1207ca8117/udp315.520.789:8060.m3u8',
      logoUrl: 'https://hosting.renderforestsites.com/35126779/1659328/media/1058391c8059a0d092426e145d55951b.png',
      category: 'Umum',
      type: StreamType.m3u8,
      description: 'Siaran Langsung E International Asia',
    ),

    // 64. E International Europe
    Channel(
      id: 'e_international_europe',
      name: 'E International Europe',
      streamUrl: 'https://gist.githubusercontent.com/iptvonlinetv/cf56ccf36d1c0827e4dc470db7b7912d/raw/066b1c9755b2496805575f16d413bd1207ca8117/udp120.510.450:6060.m3u8',
      logoUrl: 'https://hosting.renderforestsites.com/35126779/1659328/media/1058391c8059a0d092426e145d55951b.png',
      category: 'Umum',
      type: StreamType.m3u8,
      description: 'Siaran Langsung E International Europe',
    ),

    // 65. Jogja TV
    Channel(
      id: 'jogja_tv',
      name: 'Jogja TV',
      streamUrl: 'https://stream.jogjatv.co.id/jtvlive/stream/index.m3u8',
      logoUrl: 'https://static.wikia.nocookie.net/logopedia/images/4/40/Jogjatvnew.png',
      category: 'Umum',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Jogja TV',
    ),

    // 66. Nusantara TV
    Channel(
      id: 'nusantara_tv',
      name: 'Nusantara TV',
      streamUrl: 'https://nusantaratv.siar.us/nusantaratv/live/playlist.m3u8',
      logoUrl: 'https://i.imgur.com/viun5hj.png',
      category: 'Umum',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Nusantara TV',
    ),

    // 67. Rinjani TV
    Channel(
      id: 'rinjani_tv',
      name: 'Rinjani TV',
      streamUrl: 'https://rinjanitv.cloud/hls/tvkabel.m3u8',
      logoUrl: 'https://lombokindustries.com/assunnah/zone/img/rinjanitv.png',
      category: 'Umum',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Rinjani TV',
    ),

    // 68. Sangaji TV
    Channel(
      id: 'sangaji_tv',
      name: 'Sangaji TV',
      streamUrl: 'https://cdn.adyadigitalteknologi.com:8090/vod/relay.m3u8',
      logoUrl: 'https://i.imgur.com/4rTNT8F.png',
      category: 'Umum',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Sangaji TV',
    ),

    // 69. TATV
    Channel(
      id: 'tatv',
      name: 'TATV',
      streamUrl: 'https://v2.siar.us/tatv/live.sdp/playlist.m3u8',
      logoUrl: 'https://i.imgur.com/1f0EC7t.png',
      category: 'Umum',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TATV',
    ),

    // 70. TVRI South Sumatra
    Channel(
      id: 'tvri_south_sumatra',
      name: 'TVRI South Sumatra',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Sumsel/hls/Sumsel.m3u8',
      logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/eb/TVRILogo2019.svg/960px-TVRILogo2019.svg.png',
      category: 'Umum',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI South Sumatra',
    ),

    // 71. U Channel
    Channel(
      id: 'u_channel',
      name: 'U Channel',
      streamUrl: 'https://srs.u-channel.tv/live/uchannel-tv.m3u8',
      logoUrl: 'https://i.imgur.com/qxkb0cy.png',
      category: 'Umum',
      type: StreamType.m3u8,
      description: 'Siaran Langsung U Channel',
    ),

    // 72. UGTV
    Channel(
      id: 'ugtv',
      name: 'UGTV',
      streamUrl: 'https://cdn.gunadarma.ac.id/streams/ugtv/ingestugtv.m3u8',
      logoUrl: 'https://i.imgur.com/iEKDH26.png',
      category: 'Umum',
      type: StreamType.m3u8,
      description: 'Siaran Langsung UGTV',
    ),

    // 73. ABC News
    Channel(
      id: 'abc_news',
      name: 'ABC News',
      streamUrl: 'https://abc-news-dmd-streams-1.akamaized.net/out/v1/701126012d044971b3fa89406a440133/index.m3u8',
      logoUrl: 'https://i.imgur.com/BrW7gk8.png',
      category: 'Internasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung ABC News',
    ),

    // 74. Al Jazeera English
    Channel(
      id: 'al_jazeera_english',
      name: 'Al Jazeera English',
      streamUrl: 'https://live-hls-apps-aje-fa.getaj.net/AJE/index.m3u8',
      logoUrl: 'https://i.imgur.com/7bRVpnu.png',
      category: 'Internasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Al Jazeera English',
    ),

    // 75. CNA
    Channel(
      id: 'cna',
      name: 'CNA',
      streamUrl: 'https://live1.mediadesk.al/cnatvlive.m3u8',
      logoUrl: 'https://codeit.al/wp-content/uploads/2020/08/cna.png',
      category: 'Internasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung CNA',
    ),

    // 76. CNN International
    Channel(
      id: 'cnn_international',
      name: 'CNN International',
      streamUrl: 'https://d3bp6dwmpbdajl.cloudfront.net/v1/master/3722c60a815c199d9c0ef36c5b73da68a62b09d1/cc-ury0meh5m4nzm/index.m3u8',
      logoUrl: 'https://thumb.wikimedia.org/wikipedia/commons/thumb/b/b8/CNN-International-Logo.svg/960px-CNN-International-Logo.svg.png',
      category: 'Internasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung CNN International',
    ),

    // 77. Discovery Channel
    Channel(
      id: 'discovery_channel',
      name: 'Discovery Channel',
      streamUrl: 'http://88.212.7.14/live/discovery_hungary/index.m3u8',
      logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f1/2019_Discovery_logo.svg/960px-2019_Discovery_logo.svg.png',
      category: 'Internasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Discovery Channel',
    ),

    // 78. DW Arabic
    Channel(
      id: 'dw_arabic',
      name: 'DW Arabic',
      streamUrl: 'https://dwamdstream103.akamaized.net/hls/live/2015526/dwstream103/master.m3u8',
      logoUrl: 'https://i.imgur.com/8MRNFb9.png',
      category: 'Internasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung DW Arabic',
    ),

    // 79. DW English
    Channel(
      id: 'dw_english',
      name: 'DW English',
      streamUrl: 'https://amg01644-amg01644c1-amgplt0343.playout.now3.amagi.tv/ts-eu-w1-n2/playlist/amg01644-amg01644c1-amgplt0343/playlist.m3u8',
      logoUrl: 'https://i.imgur.com/8MRNFb9.png',
      category: 'Internasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung DW English',
    ),

    // 80. Euronews
    Channel(
      id: 'euronews',
      name: 'Euronews',
      streamUrl: 'https://cdn-euronews.akamaized.net/live/eds/euronews-pl/26382/index.m3u8',
      logoUrl: 'https://images-2.rakuten.tv/storage/global-live-channel/translation/artwork/bc84c3b7-6008-4ee3-8f6a-e4bb4365f082-width200-quality90.jpeg',
      category: 'Internasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Euronews',
    ),

    // 81. France 24
    Channel(
      id: 'france_24',
      name: 'France 24',
      streamUrl: 'https://live.france24.com/hls/live/2037179-b/F24_FR_HI_HLS/master_5000.m3u8',
      logoUrl: 'https://i.imgur.com/u8N6uoj.png',
      category: 'Internasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung France 24',
    ),

    // 82. France 24 Arabic
    Channel(
      id: 'france_24_arabic',
      name: 'France 24 Arabic',
      streamUrl: 'https://live.france24.com/hls/live/2037222-b/F24_AR_HI_HLS/master_5000.m3u8',
      logoUrl: 'https://xstreamcp-assets-msp.streamready.in/assets/LIVETV/LIVECHANNEL/LIVETV_LIVETVCHANNEL_FRANCE_24/images/LOGO_HD/image.png',
      category: 'Internasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung France 24 Arabic',
    ),

    // 83. Nasa TV
    Channel(
      id: 'nasa_tv',
      name: 'Nasa TV',
      streamUrl: 'https://stream.nasatv.com.mk/hls/nasatv_live.m3u8',
      logoUrl: 'https://i.imgur.com/9rB4VZy.png',
      category: 'Internasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Nasa TV',
    ),

    // 84. Red Bull TV
    Channel(
      id: 'red_bull_tv',
      name: 'Red Bull TV',
      streamUrl: 'https://3ea22335.wurl.com/master/f36d25e7e52f1ba8d7e56eb859c636563214f541/UmFrdXRlblRWLWdiX1JlZEJ1bGxUVl9ITFM/playlist.m3u8',
      logoUrl: 'https://images.pluto.tv/channels/5e7cb84a172a0f0007da69e4/colorLogoPNG.png',
      category: 'Internasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Red Bull TV',
    ),

    // 85. RT Arabic
    Channel(
      id: 'rt_arabic',
      name: 'RT Arabic',
      streamUrl: 'https://rt-arb.rttv.com/dvr/rtarab/playlist.m3u8',
      logoUrl: 'https://i.imgur.com/G8vGrn1.png',
      category: 'Internasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung RT Arabic',
    ),

    // 86. CNBC Indonesia
    Channel(
      id: 'cnbc_indonesia',
      name: 'CNBC Indonesia',
      streamUrl: 'https://video.detik.com/livecnbc/smil:cnbctv/chunklist_w1279679883_b384000_sleng.m3u8',
      logoUrl: '',
      category: 'Business',
      type: StreamType.m3u8,
      description: 'Siaran Langsung CNBC Indonesia',
    ),

    // 87. CNN Indonesia
    Channel(
      id: 'cnn_indonesia',
      name: 'CNN Indonesia',
      streamUrl: 'https://video.detik.com/livecnn/smil:cnntv/chunklist_w268557525_b384000_sleng.m3u8',
      logoUrl: '',
      category: 'News',
      type: StreamType.m3u8,
      description: 'Siaran Langsung CNN Indonesia',
    ),

    // 88. Radar Tasikmalaya TV
    Channel(
      id: 'radar_tasikmalaya_tv',
      name: 'Radar Tasikmalaya TV',
      streamUrl: 'https://v2.siar.us/radartasikmalaya/live/playlist.m3u8',
      logoUrl: '',
      category: 'Umum',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Radar Tasikmalaya TV',
    ),

    // 89. SMTV
    Channel(
      id: 'smtv',
      name: 'SMTV',
      streamUrl: 'https://e.siar.us/live/smtv.m3u8',
      logoUrl: '',
      category: 'Umum',
      type: StreamType.m3u8,
      description: 'Siaran Langsung SMTV',
    ),

    // 90. BTV
    Channel(
      id: 'btv',
      name: 'BTV',
      streamUrl: 'https://hls.tvabierta.net/hls/boliviatv.m3u8',
      logoUrl: '',
      category: 'Umum',
      type: StreamType.m3u8,
      description: 'Siaran Langsung BTV',
    ),

    // 91. STV
    Channel(
      id: 'stv',
      name: 'STV',
      streamUrl: 'http://89.201.163.244:8080/hls/hdmi.m3u8',
      logoUrl: '',
      category: 'Umum',
      type: StreamType.m3u8,
      description: 'Siaran Langsung STV',
    ),

    // 92. E International Asia
    Channel(
      id: 'e_international_asia_2',
      name: 'E International Asia',
      streamUrl: 'https://gist.githubusercontent.com/iptvonlinetv/cf56ccf36d1c0827e4dc470db7b7912d/raw/066b1c9755b2496805575f16d413bd1207ca8117/udp315.520.789:8060.m3u8',
      logoUrl: 'https://hosting.renderforestsites.com/35126779/1659328/media/1058391c8059a0d092426e145d55951b.png',
      category: 'Umum',
      type: StreamType.m3u8,
      description: 'Siaran Langsung E International Asia',
    ),

    // 93. E International Europe
    Channel(
      id: 'e_international_europe_2',
      name: 'E International Europe',
      streamUrl: 'https://gist.githubusercontent.com/iptvonlinetv/cf56ccf36d1c0827e4dc470db7b7912d/raw/066b1c9755b2496805575f16d413bd1207ca8117/udp120.510.450:6060.m3u8',
      logoUrl: 'https://hosting.renderforestsites.com/35126779/1659328/media/1058391c8059a0d092426e145d55951b.png',
      category: 'Umum',
      type: StreamType.m3u8,
      description: 'Siaran Langsung E International Europe',
    ),

    // 94. Jogja TV
    Channel(
      id: 'jogja_tv_2',
      name: 'Jogja TV',
      streamUrl: 'https://stream.jogjatv.co.id/jtvlive/stream/index.m3u8',
      logoUrl: 'https://static.wikia.nocookie.net/logopedia/images/4/40/Jogjatvnew.png',
      category: 'Umum',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Jogja TV',
    ),

    // 95. Nusantara TV
    Channel(
      id: 'nusantara_tv_2',
      name: 'Nusantara TV',
      streamUrl: 'https://nusantaratv.siar.us/nusantaratv/live/playlist.m3u8',
      logoUrl: 'https://i.imgur.com/viun5hj.png',
      category: 'Umum',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Nusantara TV',
    ),

    // 96. Rinjani TV
    Channel(
      id: 'rinjani_tv_2',
      name: 'Rinjani TV',
      streamUrl: 'https://rinjanitv.cloud/hls/tvkabel.m3u8',
      logoUrl: 'https://lombokindustries.com/assunnah/zone/img/rinjanitv.png',
      category: 'Umum',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Rinjani TV',
    ),

    // 97. Sangaji TV
    Channel(
      id: 'sangaji_tv_2',
      name: 'Sangaji TV',
      streamUrl: 'https://cdn.adyadigitalteknologi.com:8090/vod/relay.m3u8',
      logoUrl: 'https://i.imgur.com/4rTNT8F.png',
      category: 'Umum',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Sangaji TV',
    ),

    // 98. TATV
    Channel(
      id: 'tatv_2',
      name: 'TATV',
      streamUrl: 'https://v2.siar.us/tatv/live.sdp/playlist.m3u8',
      logoUrl: 'https://i.imgur.com/1f0EC7t.png',
      category: 'Umum',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TATV',
    ),

    // 99. TVRI South Sumatra
    Channel(
      id: 'tvri_south_sumatra_2',
      name: 'TVRI South Sumatra',
      streamUrl: 'https://ott-balancer.tvri.go.id/live/eds/Sumsel/hls/Sumsel.m3u8',
      logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/eb/TVRILogo2019.svg/960px-TVRILogo2019.svg.png',
      category: 'Umum',
      type: StreamType.m3u8,
      description: 'Siaran Langsung TVRI South Sumatra',
    ),

    // 100. U Channel
    Channel(
      id: 'u_channel_2',
      name: 'U Channel',
      streamUrl: 'https://srs.u-channel.tv/live/uchannel-tv.m3u8',
      logoUrl: 'https://i.imgur.com/qxkb0cy.png',
      category: 'Umum',
      type: StreamType.m3u8,
      description: 'Siaran Langsung U Channel',
    ),

    // 101. UGTV
    Channel(
      id: 'ugtv_2',
      name: 'UGTV',
      streamUrl: 'https://cdn.gunadarma.ac.id/streams/ugtv/ingestugtv.m3u8',
      logoUrl: 'https://i.imgur.com/iEKDH26.png',
      category: 'Umum',
      type: StreamType.m3u8,
      description: 'Siaran Langsung UGTV',
    ),

    // 102. ABC News
    Channel(
      id: 'abc_news_2',
      name: 'ABC News',
      streamUrl: 'https://abc-news-dmd-streams-1.akamaized.net/out/v1/701126012d044971b3fa89406a440133/index.m3u8',
      logoUrl: 'https://i.imgur.com/BrW7gk8.png',
      category: 'Internasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung ABC News',
    ),

    // 103. Al Jazeera English
    Channel(
      id: 'al_jazeera_english_2',
      name: 'Al Jazeera English',
      streamUrl: 'https://live-hls-apps-aje-fa.getaj.net/AJE/index.m3u8',
      logoUrl: 'https://i.imgur.com/7bRVpnu.png',
      category: 'Internasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Al Jazeera English',
    ),

    // 104. CNA
    Channel(
      id: 'cna_2',
      name: 'CNA',
      streamUrl: 'https://live1.mediadesk.al/cnatvlive.m3u8',
      logoUrl: 'https://codeit.al/wp-content/uploads/2020/08/cna.png',
      category: 'Internasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung CNA',
    ),

    // 105. CNN International
    Channel(
      id: 'cnn_international_2',
      name: 'CNN International',
      streamUrl: 'https://d3bp6dwmpbdajl.cloudfront.net/v1/master/3722c60a815c199d9c0ef36c5b73da68a62b09d1/cc-ury0meh5m4nzm/index.m3u8',
      logoUrl: 'https://thumb.wikimedia.org/wikipedia/commons/thumb/b/b8/CNN-International-Logo.svg/960px-CNN-International-Logo.svg.png',
      category: 'Internasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung CNN International',
    ),

    // 106. Discovery Channel
    Channel(
      id: 'discovery_channel_2',
      name: 'Discovery Channel',
      streamUrl: 'http://88.212.7.14/live/discovery_hungary/index.m3u8',
      logoUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f1/2019_Discovery_logo.svg/960px-2019_Discovery_logo.svg.png',
      category: 'Internasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Discovery Channel',
    ),

    // 107. DW Arabic
    Channel(
      id: 'dw_arabic_2',
      name: 'DW Arabic',
      streamUrl: 'https://dwamdstream103.akamaized.net/hls/live/2015526/dwstream103/master.m3u8',
      logoUrl: 'https://i.imgur.com/8MRNFb9.png',
      category: 'Internasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung DW Arabic',
    ),

    // 108. DW English
    Channel(
      id: 'dw_english_2',
      name: 'DW English',
      streamUrl: 'https://amg01644-amg01644c1-amgplt0343.playout.now3.amagi.tv/ts-eu-w1-n2/playlist/amg01644-amg01644c1-amgplt0343/playlist.m3u8',
      logoUrl: 'https://i.imgur.com/8MRNFb9.png',
      category: 'Internasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung DW English',
    ),

    // 109. Euronews
    Channel(
      id: 'euronews_2',
      name: 'Euronews',
      streamUrl: 'https://cdn-euronews.akamaized.net/live/eds/euronews-pl/26382/index.m3u8',
      logoUrl: 'https://images-2.rakuten.tv/storage/global-live-channel/translation/artwork/bc84c3b7-6008-4ee3-8f6a-e4bb4365f082-width200-quality90.jpeg',
      category: 'Internasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Euronews',
    ),

    // 110. France 24
    Channel(
      id: 'france_24_2',
      name: 'France 24',
      streamUrl: 'https://live.france24.com/hls/live/2037179-b/F24_FR_HI_HLS/master_5000.m3u8',
      logoUrl: 'https://i.imgur.com/u8N6uoj.png',
      category: 'Internasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung France 24',
    ),

    // 111. France 24 Arabic
    Channel(
      id: 'france_24_arabic_2',
      name: 'France 24 Arabic',
      streamUrl: 'https://live.france24.com/hls/live/2037222-b/F24_AR_HI_HLS/master_5000.m3u8',
      logoUrl: 'https://xstreamcp-assets-msp.streamready.in/assets/LIVETV/LIVECHANNEL/LIVETV_LIVETVCHANNEL_FRANCE_24/images/LOGO_HD/image.png',
      category: 'Internasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung France 24 Arabic',
    ),

    // 112. Nasa TV
    Channel(
      id: 'nasa_tv_2',
      name: 'Nasa TV',
      streamUrl: 'https://stream.nasatv.com.mk/hls/nasatv_live.m3u8',
      logoUrl: 'https://i.imgur.com/9rB4VZy.png',
      category: 'Internasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Nasa TV',
    ),

    // 113. Red Bull TV
    Channel(
      id: 'red_bull_tv_2',
      name: 'Red Bull TV',
      streamUrl: 'https://3ea22335.wurl.com/master/f36d25e7e52f1ba8d7e56eb859c636563214f541/UmFrdXRlblRWLWdiX1JlZEJ1bGxUVl9ITFM/playlist.m3u8',
      logoUrl: 'https://images.pluto.tv/channels/5e7cb84a172a0f0007da69e4/colorLogoPNG.png',
      category: 'Internasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Red Bull TV',
    ),

    // 114. RT Arabic
    Channel(
      id: 'rt_arabic_2',
      name: 'RT Arabic',
      streamUrl: 'https://rt-arb.rttv.com/dvr/rtarab/playlist.m3u8',
      logoUrl: 'https://i.imgur.com/G8vGrn1.png',
      category: 'Internasional',
      type: StreamType.m3u8,
      description: 'Siaran Langsung RT Arabic',
    ),

    // 115. CNBC Indonesia
    Channel(
      id: 'cnbc_indonesia_2',
      name: 'CNBC Indonesia',
      streamUrl: 'https://video.detik.com/livecnbc/smil:cnbctv/chunklist_w1279679883_b384000_sleng.m3u8',
      logoUrl: '',
      category: 'Business',
      type: StreamType.m3u8,
      description: 'Siaran Langsung CNBC Indonesia',
    ),

    // 116. CNN Indonesia
    Channel(
      id: 'cnn_indonesia_2',
      name: 'CNN Indonesia',
      streamUrl: 'https://video.detik.com/livecnn/smil:cnntv/chunklist_w268557525_b384000_sleng.m3u8',
      logoUrl: '',
      category: 'News',
      type: StreamType.m3u8,
      description: 'Siaran Langsung CNN Indonesia',
    ),

    // 117. Radar Tasikmalaya TV
    Channel(
      id: 'radar_tasikmalaya_tv_2',
      name: 'Radar Tasikmalaya TV',
      streamUrl: 'https://v2.siar.us/radartasikmalaya/live/playlist.m3u8',
      logoUrl: '',
      category: 'Umum',
      type: StreamType.m3u8,
      description: 'Siaran Langsung Radar Tasikmalaya TV',
    ),
  ];

  /// Cari kanal berdasarkan id.
  static Channel? byId(String id) {
    for (final c in channels) {
      if (c.id == id) return c;
    }
    return null;
  }
}
