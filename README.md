# 📺 RENATA TV - Aplikasi Android Nonton TV

Aplikasi Android Native (**Flutter**) khusus smartphone, tablet, dan Smart TV Box untuk menonton live streaming siaran televisi Indonesia secara langsung dan stabil.

**Versi terbaru: v1.5.0 (version code 6)**

## ✨ Yang Baru di v1.5.0

- **Tampilan didesain ulang**: Home Screen baru (header statistik, pencarian cepat, filter kategori, grid responsif 2-6 kolom), kartu kanal bergaya modern dengan penanda LIVE, dan pemutar dengan daftar kanal di samping video pada mode landscape.
- **Splash screen animasi**: logo membesar (easeOutBack), cincin cahaya berdenyut, judul/tagline staggered, transisi fade ke Home Screen.
- **Native splash Android** memakai latar gelap + logo aplikasi, jadi tidak ada kedipan putih saat aplikasi dibuka.
- **Ikon launcher adaptive** (Android 8+) plus ikon legacy yang di-render ulang dari sumber `assets/icons/app_icon.png`.
- **117 kanal** siap tonton dengan URL yang sudah diverifikasi ulang lewat probe playlist.
- **Mirror otomatis**: kanal dengan beberapa mirror resmi memakai `fallbackUrls`; pemutar otomatis pindah ke mirror lain bila mirror utama gagal.

---

## 🌟 Fitur Utama

1. **Siaran TV Resmi & Lengkap**:
   - **TRANS TV**: https://20.detik.com/watch/livestreaming-transtv
   - **TRANS 7**: https://20.detik.com/watch/livestreaming-trans7
   - **CNN INDONESIA**: https://www.cnnindonesia.com/tv/embed?ref=transmedia&smartautoplay=true
   - **CNBC INDONESIA**: https://www.cnbcindonesia.com/embed/tv?ref=transmedia&smartautoplay=true
   - **TV ONE**: Live stream YouTube (`yNKvkPJl-tg`)
   - **KOMPAS TV**: Live stream YouTube (`DOOrIxw5xOw`)
   - **METRO TV**: Live stream YouTube (`nfgnpM28xDA`)
   - **WILD (NATURE)**: Live stream YouTube (`BJ3Yv572V1A`)
   - **NET TV**: Live stream YouTube (`8WCKaco64js`)
   - **INEWS TV**: https://embed.rctiplus.com/live/inews/inewsid
   - **LIPUTAN6 SCTV**: Live stream YouTube (`XZCkAZtWbIY`)
   - **TVRI**: https://klik.tvri.go.id/detailchannel/TVRI_CH_17
   - **GTV**: https://embed.rctiplus.com/live/gtv/inewsid
   - **MNCTV**: https://embed.rctiplus.com/live/mnctv/inewsid
   - **IDX TV**: https://mncmpiwv.visionplus.id/playing/channels/67671

2. **Dukungan Multi-Engine Player**:
   - Terintegrasi langsung dengan **In-App WebView** berkecepatan tinggi untuk stream embed resmi (Detik, RCTI+, TVRI).
   - Terintegrasi dengan **YouTube Player Flutter Native** untuk siaran live YouTube tanpa iklan browser yang mengganggu.
   - Pengaturan **"Auto play saat membuka kanal"** di halaman Pengaturan: matikan bila ingin memulai menonton secara manual (siaran menunggu tombol play).
   - Layar tidak akan mati sendiri saat menonton (**Wakelock** aktif otomatis).

3. **Fitur Auto Update APK (Pop-up & Download Otomatis)**:
   - Begitu ada versi baru di server/GitHub, aplikasi langsung memunculkan **Pop-up dialog pembaruan**.
   - User tinggal klik tombol **"Update Otomatis"**, aplikasi langsung mengunduh file `.apk` dengan progress bar dan langsung membuka installer Android secara otomatis (`REQUEST_INSTALL_PACKAGES` & `FileProvider`).

4. **Ikon Logo Resmi RENATA TV**:
   - Dibuat khusus dengan desain modern: Layar TV futuristik, antena retro kuning emas, tombol play merah menyala, dan badge tulisan **RENATA TV**.
   - Terpasang lengkap di semua ukuran Android `mipmap` (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi) dan `assets/icons/app_icon.png`.

---

## 🛠️ Cara Build APK RENATA TV

1. Pastikan Anda sudah mengunduh dan memasang **Flutter SDK** di komputer ([Unduh Flutter](https://docs.flutter.dev/get-started/install/windows/mobile)).
2. Cukup klik ganda file **`build_apk.bat`** di folder ini, atau jalankan perintah di terminal:
   ```bash
   flutter pub get
   flutter build apk --release
   ```
3. File APK siap install akan berada di:
   ```text
   build/app/outputs/flutter-apk/app-release.apk
   ```
4. Salin file APK tersebut ke HP Android Anda dan pasang langsung!

---

## 🔄 Cara Kerja Fitur Auto-Update APK

Di file `lib/services/auto_update_service.dart`, terdapat konfigurasi:
```dart
static const String updateJsonUrl = 'https://raw.githubusercontent.com/.../version.json';
```
Format file JSON server (`version.json`):
```json
{
  "latestVersionCode": 2,
  "latestVersionName": "1.1.0",
  "apkDownloadUrl": "https://your-domain.com/renata-tv-latest.apk",
  "changelog": "Pembaruan siaran dan perbaikan player",
  "forceUpdate": false
}
```
Ketika `latestVersionCode` di server lebih tinggi dari versi yang terpasang di HP, pop-up pembaruan akan langsung muncul otomatis di layar HP pengguna!
