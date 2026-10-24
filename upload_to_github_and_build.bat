@echo off
setlocal
title RENATA TV - Upload ke GitHub & Auto Build APK

echo ========================================================
echo       RENATA TV - UPLOAD KE GITHUB ^& AUTO BUILD APK
echo ========================================================
echo.
echo Panduan Cepat:
echo 1. Buka browser dan login ke akun GitHub Anda: https://github.com/new
echo 2. Buat repository baru, contoh beri nama: renata-tv
echo 3. Salin URL repository GitHub Anda (contoh: https://github.com/username/renata-tv.git)
echo.
echo --------------------------------------------------------
set /p REPO_URL="Masukkan URL Git Repository Anda: "

if "%REPO_URL%"=="" (
    echo [ERROR] URL tidak boleh kosong!
    pause
    exit /b 1
)

echo.
echo [1/3] Menyiapkan remote origin...
git remote remove origin 2>nul
git remote add origin %REPO_URL%

echo [2/3] Mengupload seluruh kode & workflow builder ke GitHub...
git push -u origin main

if %ERRORLEVEL% neq 0 (
    echo.
    echo [PERHATIAN] Gagal push ke GitHub. Pastikan Anda sudah login Git di komputer ini.
    pause
    exit /b 1
)

echo.
echo ========================================================
echo [3/3] SUKSES! Kode berhasil diupload ke GitHub!
echo ========================================================
echo.
echo Server GitHub Actions sekarang sedang otomatis mengompilasi APK Anda!
echo.
echo Cara download APK hasil jadinya:
echo 1. Buka halaman GitHub repo Anda di browser
echo 2. Klik tab "Actions" di bagian atas
echo 3. Klik workflow "Build RENATA TV APK" yang sedang berjalan (~3 menit)
echo 4. Setelah selesai, scroll ke bawah ke bagian "Artifacts"
echo 5. Klik "renata-tv-release-apk" untuk langsung download file APK ke HP!
echo.
pause
