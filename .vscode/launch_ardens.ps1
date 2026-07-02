$arduinoCli = "$env:LOCALAPPDATA\Programs\Arduino IDE\resources\app\lib\backend\resources\arduino-cli.exe"

$candidates = @(
    "$env:USERPROFILE\Desktop\Arduboy\ArdensPlayer.exe",
    "$env:USERPROFILE\Desktop\ArdensPlayer.exe",
    "$env:USERPROFILE\Downloads\ArdensPlayer.exe"
)

$sketchDir = Split-Path $PSScriptRoot -Parent
$buildDir  = Join-Path $sketchDir "build\arduboy-homemade.avr.arduboy-homemade"
$hexFile   = Join-Path $buildDir   "Escape.ino.hex"

if (-not (Test-Path $arduinoCli)) {
    Write-Error "arduino-cli.exe nicht gefunden: $arduinoCli`nBitte Arduino IDE installieren."
    exit 1
}

$ardens = $null
foreach ($c in $candidates) {
    if (Test-Path $c) { $ardens = $c; break }
}
if (-not $ardens) {
    Write-Error "ArdensPlayer.exe nicht gefunden.`nBitte ArdensPlayer.exe nach Desktop\Arduboy\ kopieren."
    exit 1
}

Write-Host "Kompiliere Escape (SSD1309)..." -ForegroundColor Cyan
& $arduinoCli compile `
    --fqbn "arduboy-homemade:avr:arduboy-homemade:display=ssd1309" `
    --output-dir $buildDir `
    $sketchDir

if ($LASTEXITCODE -ne 0) {
    Write-Error "Kompilierung fehlgeschlagen!"
    exit 1
}

Write-Host "Starte ArdensPlayer..." -ForegroundColor Green
& $ardens $hexFile
