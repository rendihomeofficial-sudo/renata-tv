@echo off
setlocal enabledelayedexpansion
REM ========================================================
REM  RENATA TV - TOOLCHAIN BUILDER
REM  Menjalankan:
REM    1. Memakai JDK 17 (Gradle 8.2 tidak mendukung JDK 21/25)
REM    2. Menyalin project ke folder build pendek (C:\rtb)
REM       karena path workspace Freebuff > 260 karakter
REM       membuat Flutter gagal menulis file shader.
REM  Dipanggil dari build_apk.bat dan upload_to_github_and_build.bat
REM ========================================================

set "PROJECT_DIR=%~dp0"
if "%PROJECT_DIR:~-1%"=="\" set "PROJECT_DIR=%PROJECT_DIR:~0,-1%"
set "SHORT_BUILD_DIR=C:\rtb"

echo [TOOLCHAIN] Menyiapkan JDK 17, Flutter SDK, dan Android SDK...

REM --- 1. Tentukan lokasi JDK 17 ---
set "JDK17="
if exist "C:\Android\jdk-17\jdk-17.0.18+8\bin\java.exe" (
    set "JDK17=C:\Android\jdk-17\jdk-17.0.18+8"
)
if not defined JDK17 (
    for /d %%D in ("C:\Android\jdk-17\jdk-17*") do (
        if exist "%%D\bin\java.exe" set "JDK17=%%D"
    )
)
if not defined JDK17 (
    for /d %%D in ("C:\Program Files\Eclipse Adoptium\jdk-17*") do (
        if exist "%%D\bin\java.exe" set "JDK17=%%D"
    )
)
if not defined JDK17 (
    for /d %%D in ("C:\Program Files\Java\jdk-17*") do (
        if exist "%%D\bin\java.exe" set "JDK17=%%D"
    )
)
if not defined JDK17 (
    echo [ERROR] JDK 17 tidak ditemukan.
    echo Pasang JDK 17 di C:\Android\jdk-17 atau set JAVA_HOME manual.
    exit /b 1
)
set "JAVA_HOME=%JDK17%"
set "PATH=%JDK17%\bin;%PATH%"
echo [TOOLCHAIN] JAVA_HOME  = %JAVA_HOME%

REM --- 2. Tentukan lokasi Flutter SDK ---
set "FLUTTER_DIR="
if exist "F:\tools\flutter\bin\flutter.bat" set "FLUTTER_DIR=F:\tools\flutter\bin"
if not defined FLUTTER_DIR (
    for /f "delims=" %%F in ('where flutter 2^>nul') do (
        if not defined FLUTTER_DIR set "FLUTTER_DIR=%%~dpF"
    )
)
if not defined FLUTTER_DIR (
    echo [ERROR] Flutter SDK tidak ditemukan di PATH.
    exit /b 1
)
set "PATH=%FLUTTER_DIR%;%PATH%"
echo [TOOLCHAIN] Flutter    = %FLUTTER_DIR%

REM --- 3. Tentukan lokasi Android SDK ---
set "ANDROID_SDK="
if exist "%LOCALAPPDATA%\Android\Sdk" set "ANDROID_SDK=%LOCALAPPDATA%\Android\Sdk"
if not defined ANDROID_SDK if exist "C:\Android\Sdk" set "ANDROID_SDK=C:\Android\Sdk"
if not defined ANDROID_SDK if exist "C:\Users\Public\Android\Sdk" set "ANDROID_SDK=C:\Users\Public\Android\Sdk"
if defined ANDROID_SDK (
    set "ANDROID_HOME=%ANDROID_SDK%"
    set "ANDROID_SDK_ROOT=%ANDROID_SDK%"
    set "PATH=%ANDROID_SDK%\platform-tools;%ANDROID_SDK%\cmdline-tools\latest\bin;%PATH%"
    echo [TOOLCHAIN] Android SDK = %ANDROID_SDK%
) else (
    echo [PERINGATIAN] Android SDK tidak ditemukan, pastikan ANDROID_HOME diset manual.
)

REM --- 4. Kunci konfigurasi Flutter (JDK 17 + Android SDK) ---
call "%FLUTTER_DIR%\flutter.bat" config --jdk-dir="%JDK17%" >nul 2>&1
if defined ANDROID_SDK call "%FLUTTER_DIR%\flutter.bat" config --android-sdk="%ANDROID_SDK%" >nul 2>&1

REM --- 5. Salin project ke folder build pendek ---
echo [TOOLCHAIN] Menyalin project ke %SHORT_BUILD_DIR% (path pendek)...
if not exist "%SHORT_BUILD_DIR%" mkdir "%SHORT_BUILD_DIR%"
robocopy "%PROJECT_DIR%" "%SHORT_BUILD_DIR%" /E /NFL /NDL /NJH /NJS /NS /NC /NP ^
    /XD build .dart_tool .git .gradle /XF "*.apk" >nul
if errorlevel 8 (
    echo [ERROR] Gagal menyalin project ke %SHORT_BUILD_DIR%.
    exit /b 1
)

REM --- 6. Pastikan local.properties menunjuk ke Android SDK yang benar ---
if defined ANDROID_SDK (
    if exist "%SHORT_BUILD_DIR%\android" (
        > "%SHORT_BUILD_DIR%\android\local.properties" echo sdk.dir=%ANDROID_SDK%\
        >> "%SHORT_BUILD_DIR%\android\local.properties" echo flutter.sdk=%FLUTTER_DIR%\..
    )
)

endlocal & (
    set "PROJECT_DIR=%PROJECT_DIR%"
    set "SHORT_BUILD_DIR=%SHORT_BUILD_DIR%"
    set "JAVA_HOME=%JAVA_HOME%"
    set "ANDROID_HOME=%ANDROID_HOME%"
    set "ANDROID_SDK_ROOT=%ANDROID_SDK_ROOT%"
    set "PATH=%PATH%"
    set "FLUTTER_DIR=%FLUTTER_DIR%"
    exit /b 0
)
