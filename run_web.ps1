# Ensure the Pub Cache is on the A: drive to avoid drive-root issues
$cachePath = "A:\.pub-cache"
if (!(Test-Path $cachePath)) {
    New-Item -ItemType Directory -Path $cachePath | Out-Null
}

$env:PUB_CACHE = $cachePath
Write-Host "PUB_CACHE set to $env:PUB_CACHE" -ForegroundColor Cyan

Write-Host "Launching DCI Teachers App in Chrome (CanvasKit)..." -ForegroundColor Green
# CanvasKit is more stable and avoids the _viewInsets bug
flutter run -d chrome --web-renderer canvaskit
