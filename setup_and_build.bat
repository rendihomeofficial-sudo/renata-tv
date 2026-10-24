@echo off
setlocal enabledelayedexpansion
title RENATA TV - Auto Installer ^& APK Builder

echo ========================================================
echo         RENATA TV - AUTO INSTALLER ^& BUILD APK
echo ========================================================
echo.

REM 1. Cek apakah Flutter sudah terpasang
where flutter >nul 2>nul
if %ERRORLEVEL% equ 0 (
    echo [INFO] Flutter SDK sudah terpasang di komputer Anda!
    goto BUILD_PROCESS
)

echo [INFO] Flutter SDK belum terdeteksi.
echo [1/4] Memasang Flutter SDK secara otomatis melalui Chocolatey...
echo Mohon tunggu sebentar...
echo.

choco install flutter -y
if %ERRORLEVEL% neq 0 (
    echo.
    echo [PERHATIAN] Butuh hak Administrator untuk memasang Flutter via Chocolatey.
    echo Silakan jalankan file ini dengan klik kanan: 'Run as administrator'
    echo Atau download Flutter zip dari: https://docs.flutter.dev/get-started/install/windows/mobile
    pause
    exit /b 1
)

REM Refresh Environment PATH
call RefreshEnv.cmd 2>nul
set "PATH=%PATH%;C:\tools\flutter\bin;C:\flutter\bin"

:BUILD_PROCESS
echo.
echo ========================================================
echo [2/4] Mengambil dependensi paket RENATA TV...
echo ========================================================
call flutter pub get

echo.
echo ========================================================
echo [3/4] Mengompilasi Project ke file APK Android Release...
echo ========================================================
call flutter build apk --release

if %ERRORLEVEL% neq 0 (
    echo.
    echo [ERROR] Gagal melakukan build APK.
    pause
    exit /b 1
)

echo.
echo ========================================================
echo [4/4] BERHASIL! File APK RENATA TV siap dipasang:
echo ========================================================
echo Lokasi File APK:
echo %CD%\build\app\outputs\flutter-apk\app-release.apk
echo.

REM Membuka folder output tempat file APK berada di Windows Explorer
explorer.exe "%CD%\build\app\outputs\flutter-apk"

echo File APK sudah siap dikirim dan diinstall di HP Android Anda!
echo.
pause
