@echo off
setlocal enabledelayedexpansion
title RENATA TV - Build APK Release
echo ========================================================
echo   BUILD APK FLUTTER TV INDONESIA
echo ========================================================
echo.

REM Cek apakah Flutter terpasang
where flutter >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [INFO] Flutter tidak ada di PATH, mencoba toolchain bawaan...
)

call "%~dp0flutter_toolchain.bat"
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Toolchain tidak siap. Build dibatalkan.
    pause
    exit /b 1
)

cd /d "%SHORT_BUILD_DIR%"

echo.
echo [1/4] Mengambil paket dependensi (pub get)...
call "%FLUTTER_DIR%\flutter.bat" pub get
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Gagal menjalankan flutter pub get.
    pause
    exit /b 1
)

echo.
echo [2/4] Menjalankan analisis kode (flutter analyze)...
call "%FLUTTER_DIR%\flutter.bat" analyze
if %ERRORLEVEL% neq 0 (
    echo [PERHATIAN] Ada peringatan dari flutter analyze, build tetap dilanjutkan.
)

echo.
echo [3/4] Memulai proses kompilasi APK Release...
call "%FLUTTER_DIR%\flutter.bat" build apk --release
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Gagal membuat APK.
    pause
    exit /b 1
)

echo.
echo [4/4] Menyalin APK ke folder project...
set "APK_NAME=renata-tv"
for /f "tokens=2 delims== " %%V in ('findstr /r /b /c:"^version:" "%PROJECT_DIR%\pubspec.yaml"') do (
    set "RAWVER=%%V"
)
for /f "tokens=1 delims=+" %%A in ("!RAWVER!") do set "VER=%%A"
set "APK_FULL=%APK_NAME%-v!VER!.apk"
copy /Y "%SHORT_BUILD_DIR%\build\app\outputs\flutter-apk\app-release.apk" "%PROJECT_DIR%\%APK_FULL%" >nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Gagal menyalin APK ke %PROJECT_DIR%.
    pause
    exit /b 1
)

echo.
echo ========================================================
echo [SUKSES] File APK berhasil dibuat:
echo %PROJECT_DIR%\%APK_FULL%
echo ========================================================
echo.
pause
