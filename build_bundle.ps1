# Ensure the Pub Cache is on the A: drive
$cachePath = "A:\.pub-cache"
if (!(Test-Path $cachePath)) { New-Item -ItemType Directory -Path $cachePath | Out-Null }
$env:PUB_CACHE = $cachePath

Write-Host "--- Building Optimized App Bundle (.aab) ---" -ForegroundColor Cyan

flutter clean
flutter pub get

# Obfuscation and debug info separation for security and size
Write-Host "Generating AAB..." -ForegroundColor Green
flutter build appbundle --release --obfuscate --split-debug-info=A:\dci-latest\debug_symbols

Write-Host "Success! Upload this file to Play Console:" -ForegroundColor Green
Write-Host "A:\dci-latest\build\app\outputs\bundle\release\app-release.aab" -ForegroundColor Cyan
