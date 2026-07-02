Write-Host "`nEscape Arduboy - Setup-Pruefung" -ForegroundColor Cyan
Write-Host "================================`n"

# arduino-cli
$arduinoCli = "$env:LOCALAPPDATA\Programs\Arduino IDE\resources\app\lib\backend\resources\arduino-cli.exe"
if (Test-Path $arduinoCli) {
    Write-Host "[OK]    arduino-cli:   $arduinoCli" -ForegroundColor Green
} else {
    Write-Host "[FEHLT] arduino-cli:   $arduinoCli" -ForegroundColor Red
    Write-Host "        -> Arduino IDE (2.x) als User-Installer installieren"
}

# Board-Package
$packagePath = "$env:LOCALAPPDATA\Arduino15\packages\arduboy-homemade"
if (Test-Path $packagePath) {
    Write-Host "[OK]    Board-Package: $packagePath" -ForegroundColor Green
} else {
    Write-Host "[FEHLT] Board-Package: $packagePath" -ForegroundColor Red
    Write-Host "        -> In Arduino IDE: File > Preferences > Additional boards manager URLs:"
    Write-Host "           https://raw.githubusercontent.com/MrBlinky/Arduboy-homemade-package/master/package_arduboy_homemade_index.json"
    Write-Host "           Dann: Tools > Board > Boards Manager > 'arduboy-homemade' v1.4.1 installieren"
}

# ArdensPlayer
$ardens = "$env:USERPROFILE\Desktop\Arduboy\ArdensPlayer.exe"
if (Test-Path $ardens) {
    Write-Host "[OK]    ArdensPlayer:  $ardens" -ForegroundColor Green
} else {
    Write-Host "[FEHLT] ArdensPlayer:  $ardens" -ForegroundColor Red
    Write-Host "        -> ArdensPlayer.exe herunterladen und nach Desktop\Arduboy\ kopieren"
    Write-Host "           (Nur ArdensPlayer.exe, NICHT Ardens.exe!)"
}

# Ctrl+F5 Keybinding setzen
$keybindingsPath = "$env:APPDATA\Code\User\keybindings.json"
$newBinding = @'
    {
        "key": "ctrl+f5",
        "command": "workbench.action.tasks.runTask",
        "args": "Simulate in Ardens"
    }
'@

if (Test-Path $keybindingsPath) {
    $content = Get-Content $keybindingsPath -Raw
    if ($content -match "Simulate in Ardens") {
        Write-Host "[OK]    Ctrl+F5 Keybinding bereits vorhanden" -ForegroundColor Green
    } else {
        Write-Host "[INFO]  Ctrl+F5 Keybinding noch nicht gesetzt" -ForegroundColor Yellow
        Write-Host "        -> In VS Code: Ctrl+Shift+P > 'Open Keyboard Shortcuts (JSON)'"
        Write-Host "           Folgenden Eintrag hinzufuegen:"
        Write-Host $newBinding
    }
} else {
    Write-Host "[INFO]  VS Code keybindings.json nicht gefunden (VS Code noch nicht gestartet?)" -ForegroundColor Yellow
    Write-Host "        -> Nach erstem VS Code-Start erneut ausfuehren oder manuell eintragen:"
    Write-Host $newBinding
}

Write-Host "`nAlle Punkte muessen [OK] zeigen bevor weitergemacht wird.`n"
