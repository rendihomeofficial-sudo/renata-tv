# Audit Auto-Play Kanal Embed — RENATA TV

Tanggal audit: 27 Oktober 2026
Ruang lingkup: 9 kanal `StreamType.webview` — TRANS TV, TRANS 7, CNN Indonesia, CNBC Indonesia, INEWS TV, TVRI, GTV, MNCTV, IDX TV.

## 1. Metodologi

- Membaca kode aplikasi: `lib/screens/player_screen.dart` (jalur WebView + skrip auto-play), `lib/services/channel_service.dart` (definisi kanal), `lib/services/player_settings_service.dart` (sakelar auto-play).
- Mengambil HTML sumber tiap kanal embed dengan User-Agent Android (curl/Python), lalu membaca konfigurasi pemutar yang dikEmbed situs (detikVideo, JWPlayer, video.js).
- Menelusuri pustaka sisi klien yang dipakai situs (`detikVideo.core.js`, konfigurasi JWPlayer, pemanggilan `initplayer`).
- Memeriksa sertifikat TLS tiap host embed dan ketersediaan playlist HLS langsung (ott-balancer TVRI, CDN video.detik.com).

Yang **terverifikasi** = hasil pemeriksaan langsung di atas. Yang **hipotesis** = penjelasan yang masuk akal tetapi hanya bisa dipastikan dengan uji perangkat.

## 2. Cara auto-play bekerja di aplikasi sekarang

Alur di [lib/screens/player_screen.dart](lib/screens/player_screen.dart):

1. `_initWebView()` membuat `WebViewController`. Bila sakelar auto-play nyala, `AndroidWebViewController.setMediaPlaybackRequiresUserGesture(false)` dipanggil sebelum `loadRequest` — ini lifting hambatan "user gesture" milik WebView.
2. `NavigationDelegate.onPageFinished` memicu `_scheduleWebAutoPlay()`.
3. Skrip `_webAutoPlayScript` dijalankan pada **frame teratas** dokumen, tiga kali: saat halaman selesai, +2 detik, +5 detik. Isi skrip: ambil `document.querySelector('video')` (video pertama), set `muted = false`, panggil `play()`, dan jika promise ditolak, ulangi dengan `muted = true`.
4. Kegagalan `play()` hanya ditangkap (`p.catch`), tidak dilaporkan ke pengguna maupun ke log aplikasi.

Kelemahan struktural skrip ini yang memengaruhi semua kanal embed:

- Hanya mencari **video pertama** di dokumen. Kalau elemen pertama adalah video iklan (IMA) atau bukan elemen live, pemanggilan `play()` tidak membuat pemutar live berjalan.
- Hanya 3 percobaan dalam rentang 5 detik. Kanal yang memutar pemutar setelah loader/IKLAN/Firestore (RCTI+) sering belum siap.
- Tidak pernah memanggil API pemain (`jwplayer().play()`, `videojs.getPlayers()`), sehingga tombol play besar milik situs tetap tampil dan state internal pemain tidak sinkron.
- Tidak ada penelusuran iframe: `runJavaScript` hanya berjalan di frame teratas.
- Tidak ada penanganan error TLS, sehingga kanal dengan sertifikat bermasalah hanya menampilkan pesan "halaman tidak dapat dimuat".

## 3. Ringkasan per kanal

| Kanal | URL embed | Sumber masalah | Status stream saat ini | Prioritas |
|---|---|---|---|---|
| TRANS TV | `20.detik.com/watch/livestreaming-transtv` | Halaman set `autoplay:false`, `mute:false`; pemutar Detik pakai video.js + IMA | Halaman termuat, perlu tap | P2 |
| TRANS 7 | `20.detik.com/watch/livestreaming-trans7` | Sama seperti TRANS TV | Halaman termuat, perlu tap | P2 |
| CNN Indonesia | `cnnindonesia.com/tv/embed?…smartautoplay=true` | `autoplay:false` di level halaman; parameter `smartautoplay=true` tidak mengubahnya | Halaman termuat, perlu tap | P2 |
| CNBC Indonesia | `cnbcindonesia.com/embed/tv?…smartautoplay=true` | Sama seperti CNN | Halaman termuat, perlu tap | P2 |
| INEWS TV | `embed.rctiplus.com/live/inews/inewsid` | JWPlayer `autostart:false`, `mute:false`; pemutar baru dibuat setelah snapshot Firestore + IMA ads | Sering belum siap saat skrip jalan | P1 |
| GTV | `embed.rctiplus.com/live/gtv/inewsid` | Sama seperti INEWS | Sering belum siap saat skrip jalan | P1 |
| MNCTV | `embed.rctiplus.com/live/mnctv/inewsid` | Sama seperti INEWS | Sering belum siap saat skrip jalan | P1 |
| TVRI | `klik.tvri.go.id/detailchannel/TVRI_CH_17` | Halaman tidak punya atribut `autoplay`; video.js big-play; **ID 17 = TVRI Lampung, bukan Nasional**; kanal ini juga **duplikat** dengan `TVRI Nasional` yang sudah ada sebagai m3u8 | Memutar TVRI Lampung | P1 |
| IDX TV | `mncmpiwv.visionplus.id/playing/channels/67671` | Sertifikat TLS host kedaluwarsa 16 Nov 2025 | **Tidak bisa dimuat sama sekali** | P1 |

## 4. Rincian penyebab per kanal

### 4.1 TRANS TV, TRANS 7, CNN Indonesia, CNBC Indonesia (keluarga Detik)

**Bukti.** Halaman `20.detik.com/watch/livestreaming-transtv` menyertakan konfigurasi `detikvideo_props`:

```js
"autoplay": false,
"mute": false,
"live": true,
"channel": "liventranstv",
"videoUrl": "https://video.detik.com/transtv/smil:transtv.smil/playlist.m3u8",
"features": { "smartAutoplay": true, "enableLiveAdsServerPush": true, ... }
```

Pemutar dimuat dari `detikVideo.core.js` (video.js + hls.js + Google IMA untuk iklan). Di dalam pustaka itu, mode smart-autoplay hanya berjalan bila `scriptconf.autoplay === true`; untuk `autoplay:false` pustaka mencatat mode `"NON-AUTOPLAY"`. Parameter `?smartautoplay=true` pada URL CNN/CNBC tidak mengubah `scriptconf.autoplay` yang sudah `false` di dalam halaman.

**Penyebab kegagalan auto-play.**
1. Situs secara eksplisit mematikan auto-play di level halaman dan meminta suara aktif, jadi pemutar hanya menampilkan tombol play besar video.js.
2. Auto-play di sisi aplikasi mengandalkan `video.play()` pada elemen pertama. `<video>` baru ada setelah video.js membuat tech element, dan halaman ini menjalankan IMA (iklan pra-roll) yang membuat elemen video tambahan. Elemen pertama tidak tentu elemen live stream.
3. Iklan IMA yang gagal dimuat (Google IMA SDK butuh jaringan ke `pagead2.googlesyndication.com`) dapat menahan player di tahap iklan sehingga live stream tidak pernah dimulai — perlu konfirmasi di perangkat.

**Opsi bypass (belum dipakai, perlu uji di perangkat).** URL HLS resmi tersedia di konfigurasi halaman, contoh `https://video.detik.com/transtv/smil:transtv.smil/playlist.m3u8`. Catatan: server CDN video.detik.com **menolak** permintaan non-browser (koneksi TLS ditutup tanpa balasan, `RemoteDisconnected` pada urllib/curl). Karena itu jalur m3u8 langsung berisiko gagal di ExoPlayer dan belum tentu lebih andal daripada WebView.

### 4.2 INEWS TV, GTV, MNCTV (RCTI+ embed)

**Bukti.** `embed.rctiplus.com/live/inews/inewsid` memakai JWPlayer 8.36.3 dengan konfigurasi:

```js
player.setup({
  autostart: false, responsive: true, file: url,
  preload: 'metadata', mute: false, primary: 'html5', hlsjsdefault: true,
  advertising: { client: "googima", preloadAds: true, autoplayadsmuted: true, ... },
  autoPause: { viewability: true }, ...
});
```

`initplayer(file, vmap)` **dipanggil dari callback Firestore** `db.collection("dai").doc("rplus_4").onSnapshot(...)`, dengan syarat `!adsAborted && !adsOnPlay && !document.pictureInPictureElement && document.visibilityState === 'visible'`.

**Penyebab kegagalan auto-play.**
1. JWPlayer dikonfigurasi `autostart:false` dan `mute:false` — situs tidak pernah initiating playback sendiri.
2. Elemen `<video>` baru ada setelah: Firebase JS SDK termuat → snapshot Firestore diterima → IMA/VMAP iklan termuat → `initplayer` dipanggil. Rantai ini sering lebih dari 5 detik di jaringan seluler, sedangkan skrip aplikasi berhenti mencoba di detik ke-5 → hasil `no-video`.
3. `autoPause: { viewability: true }` membuat JWPlayer menjeda saat elemen dianggap tidak terlihat. Di dalam WebView yang tertanam di Flutter, deteksi viewability berbasis IntersectionObserver bisa tidak berlaku, sehingga playback bisa berhenti sendiri.
4. Pemanggilan `video.play()` mentah tidak went through API JWPlayer, sehingga tombol play besar JWPlayer tetap tampil dan state internal JWPlayer tidak sinkron → bisa tertahan di status "paused".

### 4.3 TVRI

**Bukti.** `klik.tvri.go.id/detailchannel/TVRI_CH_17` (dengan cookie, seperti WebView) mengembalikan HTTP 200 dan memuat:

```html
<video id="my-video" class="video-js vjs-big-play-centered vjs-theme-sea"
       controls preload="auto" poster="…/lampung.png" data-setup='{}'>
  <source src="https://ott-balancer.tvri.go.id/live/eds/Lampung/hls/Lampung.m3u8" type="application/x-mpegURL">
</video>
```

**Penyebab kegagalan auto-play.**
1. Elemen `<video>` tidak punya atribut `autoplay`; video.js menampilkan big-play button → streaming hanya berjalan setelah pengguna menekan.
2. Halaman melakukan redirect 302 ke URL yang sama; tanpa cookie yang tersimpan server melakukan loop redirect (curl: "Maximum (50) redirects followed"). WebView menyimpan cookie sehingga akhirnya lolos, tapi `onPageFinished` bisa terpicu berulang dan skrip auto-play bisa berjalan pada dokumen yang belum final.
3. **Bug konten:** `TVRI_CH_17` = **TVRI Lampung** (poster `lampung.png`, source `Lampung.m3u8`), bukan TVRI Nasional. TVRI Nasional adalah `TVRI_CH_00` dengan source `https://ott-balancer.tvri.go.id/live/eds/Nasional/hls/Nasional.m3u8` — keduanya sudah diverifikasi ulang (poster `tvrinasional.jpg` vs `lampung.png`, source `Nasional.m3u8` vs `Lampung.m3u8`).

**Temuan positifs.** Playlist HLS TVRI bisa diakses langsung dan valid (HTTP 200, master playlist berisi varian 240p–480p). **Lebih penting:** kanal TVRI native **sudah ada** di [lib/data/hls_channels.dart](lib/data/hls_channels.dart#L518) — `TVRI Nasional` (`tvri_nasional`, m3u8 Nasional) plus ~34 kanal TVRI regional (Aceh, Bali, Banten, digested, sampai Jawa Timur) semuanya `StreamType.m3u8`. Jadi perbaikan yang dibutuhkan **bukan** membuat kanal baru, melainkan **menghapus entri webview TVRI di [lib/services/channel_service.dart](lib/services/channel_service.dart#L138)** yang duplikat dan mengarah ke stream yang salah.

**Konsekuensi ke pengguna.** Daftar kanal aplikasi adalah `[...ChannelService.channels, ...HlsChannels.channels]`, jadi saat ini ada **dua entri TVRI** berdampingan: `TVRI` (webview → memutar Lampung) dan `TVRI Nasional` (m3u8 → benar). Pengguna yang memilih "TVRI" justru mendapat Lampung, dan tetap harus menekan tombol play.

### 4.4 IDX TV

**Bukti.** Host `mncmpiwv.visionplus.id` memakai sertifikat `CN=*.visionplus.id` (DigiCert RapidSSL) yang **kedaluwarsa pada 16 Nov 2025** (`notBefore=Nov 17 00:00:00 2024 GMT`, `notAfter=Nov 16 23:59:59 2025 GMT`). Verifikasi TLS gagal: `certificate has expired`. Host lain `www.visionplus.id` (kedaluwarsa Feb 2027) dan `visionplus.id` (Apr 2027) normal — jadi masalahnya khusus host player web itu.

**Penyebab kegagalan auto-play.** Bukan soal auto-play: WebView membatalkan pemuatan dan menampilkan `ERR_CERT_DATE_INVALID`, sehingga tidak pernah ada pemutar. `NavigationDelegate.onWebResourceError` menangkap error frame utama dan menampilkan pesan umum "Halaman live stream tidak dapat dimuat". Tidak ada `onReceivedSslError` di stack aplikasi, jadi tidak ada jalur untuk menerima sertifikat kedaluwarsa (dan melewati proteksi sertifikat secara blanket adalah keputusan keamanan, bukan perbaikan bug).

## 5. Rekomendasi perbaikan

Prioritas P1 (paling cepat memberi manfaat nyata):

1. **Hapus entri TVRI webview.** Entri `id: 'tvri'` di [lib/services/channel_service.dart](lib/services/channel_service.dart#L138) memakai `klik.tvri.go.id/detailchannel/TVRI_CH_17` yang isinya **TVRI Lampung**, bukan TVRI Nasional, dan kanal native yang benar (`tvri_nasional` + seluruh TVRI regional) **sudah ada** di [lib/data/hls_channels.dart](lib/data/hls_channels.dart#L518). Hapus saja entri webview itu — hasilnya satu kanal TVRI Nasional yang auto-play andal lewat pemutar native, dan TVRI Lampung tetap tersedia sebagai kanal m3u8 (`tvri_lampung`).
2. **IDX TV.** Sulitkan: masalah ada di sisi server (sertifikat VisionPlus). Pilihan: (a) tunggu perpanjangan sertifikat, (b) arahkan ke host player lain yang dipakai MNC bila tersedia, (c) sebagai jalan sementara tampilkan keterangan jelas "IDX TV sedang tidak tersedia" alih-alih pesan error generik, (d) bila tetap perlu, terapkan `onReceivedSslError` khusus host VisionPlus lewat MethodChannel — harus dikonfirmasi keamanannya dan tidak diperluas ke host lain.
3. **Perbaiki skrip auto-play WebView** (manfaat untuk Detik/CNN/CNBC/RCTI+):
   - ulangi percobaan tiap ~1 detik sampai 15 detik, bukan hanya 3 kali dalam 5 detik;
   - iterasi **semua** elemen `<video>` dan pilih yang paling sesuai (punya `duration > 0` / berada di container player), bukan hanya yang pertama;
   - panggil API pemain bila ada: `jwplayer().play()` (RCTI+) dan `videojs.getPlayers()` (Detik/TVRI);
   - klik tombol play besar bila ada (`button.vjs-big-play-button`, `.vjs-play-button`);
   - fallback: coba dulu tanpa mute, kalau ditolak mute lalu play, lalu beri tahu pengguna lewat UI "Ketuk untuk memutar" (karena unmute tanpa gesture tidak diizinkan browser);
   - laporkan hasil tiap percobaan (status `no-video` / `playing` / `rejected`) ke log aplikasi untuk diagnosis di perangkat.

Prioritas P2:

4. **Overlay "Ketuk untuk memutar"** di atas WebView ketika auto-play gagal — memberi jalan keluar yang jelas bagi pengguna, alih-alih halaman yang diam.
5. **UA WebView** disamakan dengan UA Chrome Android asli (sekarang tanpa token `wv`/`Version/4.0`), agar situs tidak menyajikan varian halaman mobile yang berbeda.
6. **Perbaiki kategori TVRI Nasional.** Di [lib/data/hls_channels.dart](lib/data/hls_channels.dart#L518) kanal `tvri_nasional` ber-`category: 'Daerah'` padahal dikirim sebagai kanal nasional; setelah entri webview dihapus, pindahkan ke kategori `'Nasional'`.
7. **Pertahankan kanal embed yang memang masih dipakai** — RCTI+ bergantung pada Firestore, dan sebagian embed Detik bisa diganti m3u8 resmi bila uji perangkat membuktikan ExoPlayer diterima oleh CDN.

## 6. Batasan audit

- Tidak ada perangkat/emulator Android di lingkungan audit, jadi perilaku runtime (apakah `play()` diterima WebView, apakah IMA menahan pemutar, apakah viewability JWPlayer aktif) belum diuji langsung; bagian itu ditandai sebagai hipotesis.
- Pemeriksaan dilakukan dari luar jaringan aplikasi; perilaku CDN Detik bisa berbeda bila request berasal dari IP/egress perangkat.
- ID kanal IDX TV (`67671`) tidak bisa diverifikasi karena host tidak bisa diakses (sertifikat kedaluwarsa).

