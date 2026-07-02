Write-Host "`nEscape Arduboy - Setup-Pruefung (Portable)" -ForegroundColor Cyan
Write-Host "==========================================`n"

$arduinoRoot = Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Parent

# arduino-builder
$arduinoBuilder = Join-Path $arduinoRoot "arduino-builder.exe"
if (Test-Path $arduinoBuilder) {
    Write-Host "[OK]    arduino-builder: $arduinoBuilder" -ForegroundColor Green
} else {
    Write-Host "[FEHLT] arduino-builder: $arduinoBuilder" -ForegroundColor Red
    Write-Host "        -> Portable Arduino 1.8.19 muss unter $arduinoRoot liegen"
}

# Board-Package
$packagePath = Join-Path $arduinoRoot "portable\packages\arduboy-homemade"
if (Test-Path $packagePath) {
    Write-Host "[OK]    Board-Package:  $packagePath" -ForegroundColor Green
} else {
    Write-Host "[FEHLT] Board-Package:  $packagePath" -ForegroundColor Red
    Write-Host "        -> In Arduino IDE 1.8.x: File > Preferences > Additional boards manager URLs:"
    Write-Host "           https://raw.githubusercontent.com/MrBlinky/Arduboy-homemade-package/master/package_arduboy_homemade_index.json"
    Write-Host "           Dann: Tools > Board > Boards Manager > 'arduboy-homemade' installieren"
}

# ArdensPlayer
$ardensCandidates = @(
    (Join-Path $arduinoRoot "ArdensPlayer.exe"),
    "$env:USERPROFILE\Desktop\Arduboy\ArdensPlayer.exe",
    "$env:USERPROFILE\Desktop\ArdensPlayer.exe"
)
$ardensFound = $ardensCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if ($ardensFound) {
    Write-Host "[OK]    ArdensPlayer:   $ardensFound" -ForegroundColor Green
} else {
    Write-Host "[FEHLT] ArdensPlayer:   (keiner der Pfade gefunden)" -ForegroundColor Red
    Write-Host "        -> ArdensPlayer.exe herunterladen und nach folgendem Pfad kopieren:"
    Write-Host "           $($ardensCandidates[0])"
    Write-Host "        -> Download: https://github.com/tiberiusbrown/Ardens/releases/latest"
    Write-Host "           (Nur ArdensPlayer.exe, NICHT Ardens.exe!)"
}

# F5 Keybinding setzen
$keybindingsPath = "$env:APPDATA\Code\User\keybindings.json"
$newBinding = @'
    {
        "key": "f5",
        "command": "workbench.action.tasks.runTask",
        "args": "Simulate in Ardens"
    }
'@

if (Test-Path $keybindingsPath) {
    $content = Get-Content $keybindingsPath -Raw
    if ($content -match "Simulate in Ardens") {
        Write-Host "[OK]    F5 Keybinding bereits vorhanden" -ForegroundColor Green
    } else {
        Write-Host "[INFO]  F5 Keybinding noch nicht gesetzt" -ForegroundColor Yellow
        Write-Host "        -> In VS Code: Ctrl+Shift+P > 'Open Keyboard Shortcuts (JSON)'"
        Write-Host "           Folgenden Eintrag hinzufuegen:"
        Write-Host $newBinding
    }
} else {
    Write-Host "[INFO]  VS Code keybindings.json nicht gefunden" -ForegroundColor Yellow
    Write-Host "        -> Nach erstem VS Code-Start erneut ausfuehren oder manuell eintragen:"
    Write-Host $newBinding
}

Write-Host "`nAlle Punkte muessen [OK] zeigen bevor weitergemacht wird.`n"
