@echo off
echo ========================================================
echo   BUILD APK FLUTTER TV INDONESIA
echo ========================================================
echo.

REM Cek apakah Flutter terpasang
where flutter >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Flutter SDK belum terdeteksi di PATH!
    echo Silakan install Flutter SDK terlebih dahulu atau tambahkan ke PATH.
    echo Kunjungi: https://docs.flutter.dev/get-started/install/windows/mobile
    echo.
    pause
    exit /b 1
)

echo [1/3] Mengambil paket dependensi (pub get)...
call flutter pub get
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Gagal menjalankan flutter pub get.
    pause
    exit /b 1
)

echo.
echo [2/3] Memulai proses kompilasi APK Release...
call flutter build apk --release
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Gagal membuat APK.
    pause
    exit /b 1
)

echo.
echo ========================================================
echo [3/3] SUKSES! File APK telah berhasil dibuat di:
echo build\app\outputs\flutter-apk\app-release.apk
echo ========================================================
echo.
pause
