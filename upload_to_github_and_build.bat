@echo off
setlocal
title RENATA TV - Upload ke GitHub & Auto Update Setup

echo ========================================================
echo       RENATA TV - UPLOAD KE GITHUB (rendihomeofficial-sudo)
echo ========================================================
echo.
echo Akun GitHub Anda: rendihomeofficial-sudo
echo Repository target: https://github.com/rendihomeofficial-sudo/renata-tv
echo.
echo Langkah mudah:
echo 1. Pastikan Anda sudah membuat repository di browser:
echo    https://github.com/new
echo    Beri nama Repository: renata-tv
echo    Pilih: Public
echo    (Jangan centang Add README / .gitignore karena project sudah lengkap)
echo.
echo 2. Jika sudah dibuat di browser, tekan ENTER di sini untuk mulai upload otomatis.
echo.
pause

echo.
echo [1/4] Mengatur remote repository GitHub...
git remote remove origin 2>nul
git remote add origin https://github.com/rendihomeofficial-sudo/renata-tv.git

echo [2/4] Menyiapkan branch utama (main)...
git branch -M main

echo [3/4] Menambahkan semua file source code & logo TV baru...
git add .
git commit -m "Rilis v1.1.0: Semua logo siaran TV HD lokal offline dan fitur auto-update GitHub" 2>nul

echo [4/4] Mengupload ke GitHub...
echo (Jika muncul popup login GitHub di browser/layar, silakan klik Authorize)
git push -u origin main

if %ERRORLEVEL% neq 0 (
    echo.
    echo ========================================================
    echo [PERHATIAN] Upload ke GitHub belum berhasil.
    echo Pastikan repository 'renata-tv' sudah dibuat di https://github.com/new
    echo ========================================================
    pause
    exit /b 1
)

echo.
echo ========================================================
echo [SUKSES BESAR] Seluruh kode RENATA TV berhasil diupload!
echo ========================================================
echo.
echo File version.json untuk Auto-Update sudah aktif di:
echo https://raw.githubusercontent.com/rendihomeofficial-sudo/renata-tv/main/version.json
echo.
echo Sekarang langkah terakhir agar pengguna bisa download APK otomatis:
echo 1. Buka halaman Releases di browser:
echo    https://github.com/rendihomeofficial-sudo/renata-tv/releases/new
echo 2. Tag version isi: v1.1.0
echo 3. Release title isi: RENATA TV v1.1.0
echo 4. Tarik file: C:\Users\LAURENSIUS RENDI S\Desktop\renata-tv-v1.1.0.apk
echo 5. Klik "Publish release"
echo.
echo Selesai! Semua pengguna aplikasi akan otomatis mendapat notifikasi update!
echo.
pause
