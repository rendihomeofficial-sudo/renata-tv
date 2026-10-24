@echo off
setlocal EnableDelayedExpansion
title RENATA TV - Otomatisasi Update Versi Baru

echo ========================================================
echo       RENATA TV - ASISTEN OTOMATIS RILIS UPDATE
echo ========================================================
echo.

set /p NEW_CODE="Masukkan versionCode baru (contoh: 3): "
set /p NEW_NAME="Masukkan versionName baru (contoh: 1.2.0): "
set /p NEW_LOG="Masukkan catatan update: "

if "%NEW_CODE%"=="" (
    echo [ERROR] versionCode tidak boleh kosong!
    pause
    exit /b 1
)

echo.
echo [1/3] Memperbarui file version.json otomatis...
(
  echo {
  echo   "latestVersionCode": %NEW_CODE%,
  echo   "latestVersionName": "%NEW_NAME%",
  echo   "apkDownloadUrl": "https://github.com/rendihomeofficial-sudo/renata-tv/releases/download/v%NEW_NAME%/renata-tv-v%NEW_NAME%.apk",
  echo   "changelog": "%NEW_LOG%",
  echo   "forceUpdate": false
  echo }
) > version.json

echo [2/3] Mengupload pembaruan version.json ke GitHub...
git add version.json
git commit -m "Update rilis ke versi %NEW_NAME% (code %NEW_CODE%)"
git push origin main

echo.
echo ========================================================
echo [SELESAI OTOMATIS!]
echo ========================================================
echo version.json sudah terupdate di GitHub!
echo Sekarang Anda tinggal upload APK barunya ke:
echo https://github.com/rendihomeofficial-sudo/renata-tv/releases/new (tag: v%NEW_NAME%)
echo.
pause
