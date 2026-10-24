@echo off
setlocal enabledelayedexpansion
title RENATA TV - Upload ke GitHub dan Auto Update Setup

echo ========================================================
echo       RENATA TV - BUILD + UPLOAD KE GITHUB (rendihomeofficial-sudo)
echo ========================================================
echo.
echo Repository target: https://github.com/rendihomeofficial-sudo/renata-tv
echo.

REM --- 0. Siapkan toolchain (JDK 17 + folder build pendek) ---
call "%~dp0flutter_toolchain.bat"
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Toolchain tidak siap. Proses dibatalkan.
    pause
    exit /b 1
)

REM --- 1. Tentukan versi aplikasi dari pubspec.yaml ---
set "VER="
for /f "tokens=2 delims== " %%V in ('findstr /r /b /c:"^version:" "%~dp0pubspec.yaml"') do (
    set "RAWVER=%%V"
)
for /f "tokens=1 delims=+" %%A in ("!RAWVER!") do set "VER=%%A"
if not defined VER (
    echo [ERROR] Versi aplikasi tidak terbaca dari pubspec.yaml.
    pause
    exit /b 1
)
echo Versi aplikasi terdeteksi: !VER!
set "APK_NAME=renata-tv-v!VER!.apk"

echo.
echo [1/5] Build APK Release (JDK 17, folder build pendek %SHORT_BUILD_DIR%)...
cd /d "%SHORT_BUILD_DIR%"
call "%FLUTTER_DIR%\flutter.bat" pub get
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Gagal menjalankan flutter pub get.
    pause
    exit /b 1
)
call "%FLUTTER_DIR%\flutter.bat" build apk --release
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Gagal membuat APK.
    pause
    exit /b 1
)
copy /Y "%SHORT_BUILD_DIR%\build\app\outputs\flutter-apk\app-release.apk" "%~dp0%APK_NAME%" >nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Gagal menyalin APK ke folder project.
    pause
    exit /b 1
)
echo APK siap: %~dp0%APK_NAME%

echo.
echo [2/5] Mengatur remote repository GitHub...
git remote remove origin 2>nul
git remote add origin https://github.com/rendihomeofficial-sudo/renata-tv.git

echo [3/5] Menyiapkan branch utama (main)...
git branch -M main

echo [4/5] Menambahkan semua file source code dan commit...
cd /d "%~dp0"
git add .
git commit -m "Rilis v!VER!: build APK otomatis dengan JDK 17 dan folder build pendek" 2>nul

echo [5/5] Mengupload ke GitHub...
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
echo [SUKSES BESAR] Seluruh kode RENATA TV berhasil diupload.
echo ========================================================
echo.
echo File version.json untuk Auto-Update sudah aktif di:
echo https://raw.githubusercontent.com/rendihomeofficial-sudo/renata-tv/main/version.json
echo.
echo Sekarang langkah terakhir agar pengguna bisa download APK otomatis:
echo 1. Buka halaman Releases di browser:
echo    https://github.com/rendihomeofficial-sudo/renata-tv/releases/new
echo 2. Tag version isi: v!VER!
echo 3. Release title isi: RENATA TV v!VER!
echo 4. Tarik file: %~dp0%APK_NAME%
echo 5. Klik "Publish release"
echo.
echo Selesai. Semua pengguna aplikasi akan otomatis mendapat notifikasi update.
echo.
pause
