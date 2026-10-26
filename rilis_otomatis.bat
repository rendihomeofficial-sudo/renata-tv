@echo off
setlocal enabledelayedexpansion
title RENATA TV - Rilis Otomatis (bump versi + build + push + release)

REM ==============================================================
REM  RENATA TV - RILIS OTOMATIS
REM  Memakai satu file ini untuk:
REM    1. Bump versi di pubspec.yaml + tulis ulang version.json
REM    2. Build APK release
REM    3. Commit + push ke GitHub
REM    4. Buat GitHub Release + upload APK
REM
REM  Cara pakai:
REM    rilis_otomatis.bat                        -> interaktif (bertanya versi)
REM    rilis_otomatis.bat 1.4.0 5 "Catatan"       -> non-interaktif
REM    rilis_otomatis.bat check                  -> cek token & release saja
REM ==============================================================

REM Override lewat environment variable dipakai untuk pengujian terisolasi.
if not defined REPO_SLUG set "REPO_SLUG=rendihomeofficial-sudo/renata-tv"
set "REPO_URL=https://github.com/%REPO_SLUG%"

REM Endpoint GitHub (default resmi). Bisa diarahkan ke mock server saat pengujian.
if not defined GIT_API_BASE set "GIT_API_BASE=https://api.github.com"
if not defined GIT_UPLOAD_BASE set "GIT_UPLOAD_BASE=https://uploads.github.com"
if not defined GIT_DOWNLOAD_BASE set "GIT_DOWNLOAD_BASE=https://github.com"

echo ========================================================
echo        RENATA TV - RILIS OTOMATIS
echo ========================================================
echo Repo : %REPO_URL%
echo.

REM --- 0. Prasyarat ---
where git >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Git tidak ditemukan di PATH.
    call :maybe_pause
    exit /b 1
)
where powershell >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] PowerShell tidak ditemukan di PATH.
    call :maybe_pause
    exit /b 1
)

REM Path script tanpa backslash di akhir. Wajib: argumen PowerShell yang
REM diakhiri "\" membuat kutipan penutup ter-escape sehingga seluruh
REM argumen setelahnya salah parse (contoh: -VersionName jadi kosong).
set "SD=%~dp0"
if "%SD:~-1%"=="\" set "SD=%SD:~0,-1%"

cd /d "%SD%"

REM --- 1. Mode check: hanya memastikan token & release bisa diakses ---
if /i "%~1"=="check" (
    echo [CHECK] Memeriksa akses token GitHub dan daftar release...
    powershell -NoProfile -ExecutionPolicy Bypass -File "%SD%\rilis_otomatis.ps1" -Action check -RepoSlug "%REPO_SLUG%" -ApiBase "%GIT_API_BASE%" -UploadBase "%GIT_UPLOAD_BASE%"
    if %ERRORLEVEL% neq 0 (
        echo.
        echo [ERROR] Pemeriksaan gagal. Perbaiki kredensial lalu jalankan ulang.
        call :maybe_pause
        exit /b 1
    )
    echo.
    echo [OK] Semua pemeriksaan lulus.
    call :maybe_pause
    exit /b 0
)

REM --- 2. Baca versi saat ini dari pubspec.yaml ---
set "CUR_VER="
for /f "tokens=2 delims== " %%V in ('findstr /r /b /c:"^version:" "pubspec.yaml"') do (
    set "RAWVER=%%V"
)
if not defined RAWVER (
    echo [ERROR] Baris version: tidak ditemukan di pubspec.yaml.
    call :maybe_pause
    exit /b 1
)
for /f "tokens=1 delims=+" %%A in ("!RAWVER!") do set "CUR_NAME=%%A"
for /f "tokens=2 delims=+" %%B in ("!RAWVER!") do set "CUR_CODE=%%B"
if not defined CUR_CODE set "CUR_CODE=1"

REM Pastikan versionCode di pubspec.yaml benar-benar angka.
REM Catatan: pakai echo( tanpa spasi, kalau "echo VAR | findstr" menyisipkan
REM spasi akhir sehingga pola "$" selalu gagal.
echo(!CUR_CODE!| findstr /r "^[0-9][0-9]*$" >nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] versionCode di pubspec.yaml bukan angka: "!CUR_CODE!"
    call :maybe_pause
    exit /b 1
)

echo Versi saat ini : !CUR_NAME! - code !CUR_CODE!
echo.

REM --- 3. Parameter rilis ---
set "NEW_NAME="
set "NEW_CODE="
set "NEW_LOG="

if not "%~1"=="" (
    set "NEW_NAME=%~1"
    if not "%~2"=="" set "NEW_CODE=%~2"
    if not "%~3"=="" set "NEW_LOG=%~3"
)

if not defined NEW_NAME (
    set /p NEW_NAME="Versi baru, contoh 1.4.0 - default !CUR_NAME! : "
)
if not defined NEW_NAME set "NEW_NAME=!CUR_NAME!"

if not defined NEW_CODE (
    set /p NEW_CODE="versionCode baru [!CUR_CODE!]: "
)
if not defined NEW_CODE set "NEW_CODE=!CUR_CODE!"

REM Jaga-jaga: versionCode harus naik, kalau tidak auto-update tidak jalan.
echo(!NEW_CODE!| findstr /r "^[0-9][0-9]*$" >nul
if %ERRORLEVEL% neq 0 (
    echo.
    echo [ERROR] versionCode baru "!NEW_CODE!" harus berupa angka.
    call :maybe_pause
    exit /b 1
)
set /a CALC_CODE=!CUR_CODE!+1
if !NEW_CODE! LEQ !CUR_CODE! (
    echo.
    echo [ERROR] versionCode baru !NEW_CODE! harus lebih besar dari versionCode sekarang !CUR_CODE!.
    echo         Usulkan !CALC_CODE! agar pengguna mendapat notifikasi update.
    call :maybe_pause
    exit /b 1
)

if not defined NEW_LOG (
    if exist "%~dp0changelog.txt" (
        set "NEW_LOG_FILE=%~dp0changelog.txt"
        echo Catatan update diambil dari changelog.txt
    ) else (
        set /p NEW_LOG="Catatan update satu baris: "
    )
)

set "TAG=v!NEW_NAME!"
set "APK_NAME=renata-tv-v!NEW_NAME!.apk"

echo.
echo Rilis yang akan dibuat : !NEW_NAME! - code !NEW_CODE!
echo Tag                    : !TAG!
echo.

REM --- 4. Bump versi + tulis version.json ---
echo [1/7] Menaikkan versi di pubspec.yaml dan menulis version.json...
if defined NEW_LOG_FILE (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%SD%\rilis_otomatis.ps1" -Action prepare -ProjectDir "%SD%" -RepoSlug "%REPO_SLUG%" -VersionName "!NEW_NAME!" -VersionCode !NEW_CODE! -ChangelogFile "!NEW_LOG_FILE!" -ApiBase "%GIT_API_BASE%" -UploadBase "%GIT_UPLOAD_BASE%" -DownloadBase "%GIT_DOWNLOAD_BASE%"
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%SD%\rilis_otomatis.ps1" -Action prepare -ProjectDir "%SD%" -RepoSlug "%REPO_SLUG%" -VersionName "!NEW_NAME!" -VersionCode !NEW_CODE! -Changelog "!NEW_LOG!" -ApiBase "%GIT_API_BASE%" -UploadBase "%GIT_UPLOAD_BASE%" -DownloadBase "%GIT_DOWNLOAD_BASE%"
)
if %ERRORLEVEL% neq 0 (
    echo.
    echo [ERROR] Gagal menaikkan versi.
    call :maybe_pause
    exit /b 1
)

REM --- 5. Toolchain + build APK ---
echo.
echo [2/7] Menyiapkan toolchain - JDK 17, Flutter, Android SDK...
call "%~dp0flutter_toolchain.bat"
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Toolchain tidak siap. Proses dibatalkan.
    call :maybe_pause
    exit /b 1
)

echo.
echo [3/7] Build APK release...
cd /d "%SHORT_BUILD_DIR%"
call "%FLUTTER_DIR%\flutter.bat" pub get
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Gagal menjalankan flutter pub get.
    call :maybe_pause
    exit /b 1
)
call "%FLUTTER_DIR%\flutter.bat" build apk --release
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Gagal membuat APK.
    call :maybe_pause
    exit /b 1
)

cd /d "%~dp0"
copy /Y "%SHORT_BUILD_DIR%\build\app\outputs\flutter-apk\app-release.apk" "%~dp0!APK_NAME!" >nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Gagal menyalin APK ke %~dp0.
    call :maybe_pause
    exit /b 1
)
echo APK siap: %~dp0!APK_NAME!

REM --- 6. Commit + push ---
REM version.json sengaja ditahan sampai release & APK benar-benar siap,
REM supaya aplikasi tidak menunjuk tautan download yang belum ada (404).
echo.
echo [4/7] Commit dan push ke GitHub...
git add -A
git restore --staged version.json 2>nul
git commit -m "Rilis v!NEW_NAME!: bump versi dan build APK release"
if %ERRORLEVEL% neq 0 (
    echo [INFO] Tidak ada perubahan untuk di-commit, lanjut ke push.
)
git push origin main
if %ERRORLEVEL% neq 0 (
    echo.
    echo [ERROR] Push ke GitHub gagal. Periksa koneksi dan kredensial git.
    call :maybe_pause
    exit /b 1
)

REM --- 7. Buat release + upload APK ---
echo.
echo [5/7] Membuat GitHub Release !TAG! dan mengupload APK...
if defined RELEASE_DRY_RUN (
    echo [DRY RUN] Upload dilewati, hanya mengecek kesiapan asset.
    powershell -NoProfile -ExecutionPolicy Bypass -File "%SD%\rilis_otomatis.ps1" -Action publish -ProjectDir "%SD%" -RepoSlug "%REPO_SLUG%" -Tag "!TAG!" -AssetPath "%SD%\!APK_NAME!" -Changelog "!NEW_LOG!" -DryRun -ApiBase "%GIT_API_BASE%" -UploadBase "%GIT_UPLOAD_BASE%"
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%SD%\rilis_otomatis.ps1" -Action publish -ProjectDir "%SD%" -RepoSlug "%REPO_SLUG%" -Tag "!TAG!" -AssetPath "%SD%\!APK_NAME!" -Changelog "!NEW_LOG!" -ApiBase "%GIT_API_BASE%" -UploadBase "%GIT_UPLOAD_BASE%"
)
if %ERRORLEVEL% neq 0 (
    echo.
    echo [ERROR] Pembuatan release gagal. Kode sudah ter-push, jadi kamu bisa
    echo         mengulang langkah release saja dengan perintah:
    echo         powershell -File "%~dp0rilis_otomatis.ps1" -Action publish -Tag "!TAG!" -AssetPath "%~dp0!APK_NAME!"
    call :maybe_pause
    exit /b 1
)

REM --- 8. Push version.json (sekarang tautan APK sudah hidup) ---
echo.
echo [6/7] Menerbitkan version.json agar pengguna mendapat notifikasi update...
git add version.json
git commit -m "Update version.json ke rilis v!NEW_NAME!"
if %ERRORLEVEL% neq 0 (
    echo [INFO] version.json tidak berubah, lanjut ke verifikasi.
)
git push origin main
if %ERRORLEVEL% neq 0 (
    echo.
    echo [PERINGATIAN] Push version.json gagal. Jalankan ulang manual:
    echo         git add version.json
    echo         git commit -m "Update version.json"
    echo         git push origin main
    call :maybe_pause
    exit /b 1
)

REM --- 9. Verifikasi akhir (dengan retry, CDN GitHub butuh waktu) ---
echo.
echo [7/7] Verifikasi akhir...
set "TRY=1"
set "VERIFY_OK=0"
set "HTTP_CODE=000"
if not defined VERIFY_TRIES set "VERIFY_TRIES=6"

:VERIFY_LOOP
for /f "delims=" %%H in ('curl -s -o NUL -w "%%{http_code}" -L "%GIT_DOWNLOAD_BASE%/%REPO_SLUG%/releases/download/!TAG!/!APK_NAME!"') do set "HTTP_CODE=%%H"
curl -s -o NUL -w "  version.json publik : HTTP %%{http_code}\n" "%GIT_DOWNLOAD_BASE%/%REPO_SLUG%/raw/main/version.json"
echo "  tautan unduh APK   : HTTP !HTTP_CODE!"
if "!HTTP_CODE!"=="200" (
    set "VERIFY_OK=1"
    goto VERIFY_DONE
)
if !TRY! GEQ !VERIFY_TRIES! goto VERIFY_DONE
echo  ...menunggu CDN GitHub, mencoba lagi !TRY! dari !VERIFY_TRIES!
ping -n 6 127.0.0.1 >nul
set /a TRY+=1
goto VERIFY_LOOP

:VERIFY_DONE

echo.
echo ========================================================
if "!VERIFY_OK!"=="1" (
    echo [SUKSES] Rilis !NEW_NAME! selesai dan tautan unduh aktif.
) else (
    echo [PERINGATAN] Rilis !NEW_NAME! dibuat, tapi tautan unduh belum merespons 200.
    echo             Buka %REPO_URL%/releases/tag/!TAG! untuk memastikan.
)
echo.
echo  APK lokal : %~dp0!APK_NAME!
echo  Release   : %REPO_URL%/releases/tag/!TAG!
echo  Unduh     : %GIT_DOWNLOAD_BASE%/%REPO_SLUG%/releases/download/!TAG!/!APK_NAME!
echo ========================================================
echo.
call :maybe_pause
exit /b 0

REM ==============================================================
REM  Subrutin: pause hanya kalau RELEASE_NO_PAUSE belum diset,
REM  supaya bisa dijalankan non-interaktif (CI/otomasi).
REM ==============================================================
:maybe_pause
if defined RELEASE_NO_PAUSE exit /b 0
pause >nul
exit /b 0
