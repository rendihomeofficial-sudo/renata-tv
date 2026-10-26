<#
  RENATA TV - Helper PowerShell untuk rilis otomatis.
  Dipanggil oleh rilis_otomatis.bat. Dijalankan dengan tiga mode:

    -Action prepare  : bump versi di pubspec.yaml + tulis ulang version.json
    -Action publish  : buat GitHub Release + upload APK sebagai asset
    -Action check    : hanya memastikan token & akses repo berfungsi

  Token GitHub diambil dari Git Credential Manager (credential "https://github.com"),
  jadi tidak ada token yang disimpan di dalam repo ini.
#>

param(
  [Parameter(Mandatory = $true)]
  [ValidateSet('prepare', 'publish', 'check')]
  [string]$Action,

  [string]$ProjectDir = $(if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }),
  [string]$RepoSlug = 'rendihomeofficial-sudo/renata-tv',

  # Dipakai oleh mode prepare
  [string]$VersionName,
  [int]$VersionCode,
  [string]$Changelog = '',
  [string]$ChangelogFile = '',

  # Dipakai oleh mode publish
  [string]$Tag,
  [string]$AssetPath,

  # Mode publish: jangan benar-benar mengupload, hanya cek kesiapan
  [switch]$DryRun,

  # Titik endpoint GitHub. Bisa diubah untuk pengujian terisolasi (mock server).
  [string]$ApiBase = 'https://api.github.com',
  [string]$UploadBase = 'https://uploads.github.com',
  [string]$DownloadBase = 'https://github.com'
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$script:Token = $null

function Write-Step($message) {
  Write-Host "[PS] $message"
}

function Get-GitHubToken {
  # Token dari environment didahulukan supaya tidak perlu GCM di mesin uji.
  if ($env:GITHUB_TOKEN) {
    return $env:GITHUB_TOKEN.Trim()
  }
  # Catatan: jangan pakai variabel otomatis $input di level script, isinya null
  # sehingga `git credential fill` menggantung menunggu stdin selamanya.
  $credentialInput = "protocol=https`nhost=github.com`n`n"
  $result = $credentialInput | git credential fill 2>$null
  if (-not $result) {
    throw 'Git Credential Manager tidak mengembalikan kredensial. Jalankan `git push` sekali secara manual untuk menyimpan kredensial.'
  }
  $line = $result | Where-Object { $_ -like 'password=*' } | Select-Object -First 1
  if (-not $line) {
    throw 'Token GitHub tidak ditemukan di Git Credential Manager. Jalankan `git push` sekali secara manual untuk menyimpan kredensial.'
  }
  return $line.Substring('password='.Length).Trim()
}

function Invoke-GitHubApi {
  # Mengembalikan body respons sebagai string.
  # Catatan: jangan menandai parameter lain sebagai Mandatory, karena parameter
  # Mandatory yang punya nilai default memicu prompt interaktif (script menggantung).
  param(
    [Parameter(Mandatory = $true)][string]$Uri,
    [string]$Method = 'GET',
    [string]$Body = '',
    [string]$ContentType = 'application/json',
    [byte[]]$InFile
  )

  if (-not $script:Token) {
    $script:Token = Get-GitHubToken
  }

  $headers = @{
    'Authorization' = "token $script:Token"
    'Accept'       = 'application/vnd.github+json'
    'User-Agent'   = 'renata-tv-release-script'
  }

  $request = @{
    Uri             = $Uri
    Method          = $Method
    Headers         = $headers
    ErrorAction     = 'Stop'
    UseBasicParsing = $true
    TimeoutSec      = 120
  }
  if ($null -ne $InFile) {
    $request['Body'] = $InFile
    $request['ContentType'] = $ContentType
  } elseif (-not [string]::IsNullOrEmpty($Body)) {
    $request['Body'] = [System.Text.Encoding]::UTF8.GetBytes($Body)
    $request['ContentType'] = $ContentType
  }

  try {
    $response = Invoke-WebRequest @request
    return [string]$response.Content
  } catch {
    $status = $null
    $detail = $null
    if ($_.Exception.Response) {
      $status = $_.Exception.Response.StatusCode.value__
      try {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $detail = $reader.ReadToEnd()
      } catch {
        $detail = '(detail tidak terbaca)'
      }
    }
    if ($status) {
      throw "GitHub API error $status pada $Uri : $detail"
    }
    throw "Permintaan GitHub gagal pada $Uri : $($_.Exception.Message)"
  }
}

function Get-GitHubJson {
  param(
    [Parameter(Mandatory = $true)][string]$Uri,
    [string]$Method = 'GET',
    [string]$Body = ''
  )
  $raw = Invoke-GitHubApi -Uri $Uri -Method $Method -Body $Body
  if ([string]::IsNullOrWhiteSpace($raw)) {
    throw "Respons kosong dari GitHub API: $Uri"
  }
  return ($raw | ConvertFrom-Json)
}

switch ($Action) {
  'prepare' {
    if (-not $VersionName) { throw 'VersionName wajib diisi.' }
    if ($VersionCode -le 0) { throw 'VersionCode harus lebih besar dari 0.' }

    $pubspecPath = Join-Path $ProjectDir 'pubspec.yaml'
    if (-not (Test-Path $pubspecPath)) {
      throw "pubspec.yaml tidak ditemukan: $pubspecPath"
    }
    $pubspec = Get-Content -Path $pubspecPath -Raw

    # Catatan: pakai RegexOptions.Multiline + Replace count 1 (bukan statis
    # dengan argumen ke-4 yang bisa tertukar dengan RegexOptions).
    $versionPattern = [regex]::new('(?m)^version:[ \t]*\S+[ \t]*$')
    if (-not $versionPattern.IsMatch($pubspec)) {
      throw "Baris version: tidak ditemukan di $pubspecPath"
    }
    $newPubspec = $versionPattern.Replace(
      $pubspec,
      [System.Text.RegularExpressions.MatchEvaluator]{ param($m) "version: $VersionName+$VersionCode" },
      1
    )
    [System.IO.File]::WriteAllText($pubspecPath, $newPubspec, (New-Object System.Text.UTF8Encoding($false)))
    Write-Step "pubspec.yaml -> version: $VersionName+$VersionCode"

    if ($ChangelogFile -and (Test-Path $ChangelogFile)) {
      $Changelog = (Get-Content -Path $ChangelogFile -Raw)
    }
    $safeChangelog = $Changelog.Replace('\', '\\').Replace('"', '\"')
    $safeChangelog = $safeChangelog.Replace("`r`n", '\n').Replace("`r", '\n').Replace("`n", '\n')
    if ([string]::IsNullOrWhiteSpace($safeChangelog)) {
      $safeChangelog = "Pembaruan RENATA TV v$VersionName"
    }

    $downloadUrl = "$DownloadBase/$RepoSlug/releases/download/v$VersionName/renata-tv-v$VersionName.apk"
    $versionJson = @"
{
  "latestVersionCode": $VersionCode,
  "latestVersionName": "$VersionName",
  "apkDownloadUrl": "$downloadUrl",
  "changelog": "$safeChangelog",
  "forceUpdate": false
}
"@
    $versionJsonPath = Join-Path $ProjectDir 'version.json'
    [System.IO.File]::WriteAllText($versionJsonPath, $versionJson, (New-Object System.Text.UTF8Encoding($false)))
    Write-Step "version.json ditulis (code $VersionCode, versi $VersionName)"
  }

  'publish' {
    if (-not $Tag) { throw 'Tag wajib diisi.' }
    if (-not $AssetPath -or -not (Test-Path $AssetPath)) {
      throw "Asset APK tidak ditemukan: $AssetPath"
    }

    $assetFile = Get-Item $AssetPath
    $assetName = $assetFile.Name
    Write-Step "Asset siap: $assetName ($([math]::Round($assetFile.Length / 1MB, 1)) MB)"

    # Dry run hanya mengecek kesiapan asset, tanpa menyentuh jaringan/kredensial.
    if ($DryRun) {
      Write-Step "[DRY RUN] Melewati pembuatan release dan upload asset."
      exit 0
    }

    $script:Token = Get-GitHubToken
    Write-Step "Token GitHub siap."

    # --- Cari release dengan tag yang sama (idempoten) ---
    $release = $null
    try {
      $release = Get-GitHubJson -Uri "$ApiBase/repos/$RepoSlug/releases/tags/$Tag"
    } catch {
      $release = $null
    }

    if (-not $release) {
      $releaseBody = @{
        tag_name         = $Tag
        target_commitish = 'main'
        name             = "RENATA TV $Tag"
        body             = "Rilis RENATA TV $Tag.`n`n$Changelog`n`nUnduh APK: ``$assetName``"
        draft            = $false
        prerelease       = $false
      } | ConvertTo-Json -Depth 5

      $release = Get-GitHubJson -Uri "$ApiBase/repos/$RepoSlug/releases" -Method 'POST' -Body $releaseBody
      Write-Step "Release $Tag dibuat (id $($release.id))"
    } else {
      Write-Step "Release $Tag sudah ada (id $($release.id)), asset akan diperbarui."
    }

    $releaseId = $release.id

    # --- Hapus asset lama dengan nama sama ---
    foreach ($asset in @($release.assets)) {
      if ($asset.name -eq $assetName) {
        Write-Step "Menghapus asset lama $assetName (id $($asset.id))"
        Invoke-GitHubApi -Uri "$ApiBase/repos/$RepoSlug/releases/assets/$($asset.id)" -Method 'DELETE' | Out-Null
      }
    }

    # --- Upload APK ---
    $bytes = [System.IO.File]::ReadAllBytes($assetFile.FullName)
    $uploadUri = "$UploadBase/repos/$RepoSlug/releases/$releaseId/assets?name=$([uri]::EscapeDataString($assetName))"
    Invoke-GitHubApi -Uri $uploadUri -Method 'POST' -InFile $bytes -ContentType 'application/vnd.android.package-archive' | Out-Null
    Write-Step "Asset $assetName terupload."

    # --- Verifikasi ---
    $final = Get-GitHubJson -Uri "$ApiBase/repos/$RepoSlug/releases/tags/$Tag"
    $uploaded = @($final.assets | Where-Object { $_.name -eq $assetName })
    if ($uploaded.Count -eq 0) {
      throw "Verifikasi gagal: asset $assetName tidak ditemukan di release $Tag."
    }
    Write-Step "Verifikasi OK: $Tag berisi $assetName ($($uploaded[0].size) byte)"
    Write-Step "URL unduh: $($uploaded[0].browser_download_url)"
  }

  'check' {
    $script:Token = Get-GitHubToken
    Write-Step "Token GitHub berhasil diambil dari Git Credential Manager."

    $repoData = Get-GitHubJson -Uri "$ApiBase/repos/$RepoSlug"
    Write-Step "Repository : $($repoData.full_name) (default branch: $($repoData.default_branch))"

    $list = @(Get-GitHubJson -Uri "$ApiBase/repos/$RepoSlug/releases?per_page=5")
    if ($list.Count -eq 0) {
      Write-Step 'Belum ada release di repository ini.'
    } else {
      Write-Step 'Release terbaru:'
      foreach ($item in $list) {
        $assetNames = (@($item.assets | ForEach-Object { $_.name }) -join ', ')
        Write-Step "  $($item.tag_name)  draft=$($item.draft)  assets=[$assetNames]"
      }
    }
  }
}
