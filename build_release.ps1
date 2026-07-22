# Ensure the Pub Cache is on the A: drive to avoid drive-root issues
$cachePath = "A:\.pub-cache"
if (!(Test-Path $cachePath)) { New-Item -ItemType Directory -Path $cachePath | Out-Null }
$env:PUB_CACHE = $cachePath

Write-Host "--- Starting Clean Release Build ---" -ForegroundColor Cyan

# 1. Clean up project and build artifacts
Write-Host "[1/4] Cleaning project..." -ForegroundColor Yellow
flutter clean | Out-Null

# 2. Fetch fresh dependencies
Write-Host "[2/4] Getting dependencies..." -ForegroundColor Yellow
flutter pub get | Out-Null

# 3. Build Optimized APK
# --split-per-abi: Creates smaller APKs for each architecture (unwanted bulk removed)
# --obfuscate: Protects your code (unwanted readable code removed)
# --split-debug-info: Moves debug symbols out of the APK (unwanted symbol weight removed)
Write-Host "[3/4] Building Optimized Release APK..." -ForegroundColor Green
if (!(Test-Path "A:\dci-latest\debug_symbols")) { New-Item -ItemType Directory -Path "A:\dci-latest\debug_symbols" | Out-Null }
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=A:\dci-latest\debug_symbols

# 4. Success message
Write-Host "[4/4] Build Successful!" -ForegroundColor Green
Write-Host "Optimized APKs: build\app\outputs\flutter-apk\" -ForegroundColor Cyan
Write-Host "Debug Symbols: debug_symbols\" -ForegroundColor Cyan
