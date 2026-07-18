# Ensure the Pub Cache is on the A: drive to avoid drive-root issues
$cachePath = "A:\.pub-cache"
if (!(Test-Path $cachePath)) {
    New-Item -ItemType Directory -Path $cachePath | Out-Null
}

$env:PUB_CACHE = $cachePath
Write-Host "PUB_CACHE set to $env:PUB_CACHE" -ForegroundColor Cyan

Write-Host "Cleaning stale build files..." -ForegroundColor Yellow
flutter clean

Write-Host "Fetching dependencies..." -ForegroundColor Yellow
flutter pub get

Write-Host "Launching DCI Teachers App on Windows..." -ForegroundColor Green
# Using --vane to see more output if it fails
flutter run -d windows
