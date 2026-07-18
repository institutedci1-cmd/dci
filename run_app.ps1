# Ensure the Pub Cache is on the A: drive to avoid "different roots" errors
$cachePath = "A:\.pub-cache"
if (!(Test-Path $cachePath)) {
    New-Item -ItemType Directory -Path $cachePath
}

$env:PUB_CACHE = $cachePath
Write-Host "PUB_CACHE set to $env:PUB_CACHE" -ForegroundColor Cyan

flutter clean
flutter pub get
flutter run
