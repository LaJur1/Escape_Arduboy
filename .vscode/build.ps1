param([string]$Display = "sh1106")

$arduinoRoot = Split-Path (Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Parent) -Parent
$sketchDir   = Split-Path $PSScriptRoot -Parent
$buildDir    = Join-Path $sketchDir "build\arduboy-homemade.avr.arduboy-homemade-$Display"

New-Item -ItemType Directory -Force -Path $buildDir | Out-Null

& "$arduinoRoot\arduino-builder.exe" `
    -hardware  "$arduinoRoot\hardware" `
    -hardware  "$arduinoRoot\portable\packages" `
    -tools     "$arduinoRoot\tools-builder" `
    -tools     "$arduinoRoot\hardware\tools\avr" `
    -tools     "$arduinoRoot\portable\packages" `
    -libraries "$arduinoRoot\libraries" `
    -libraries "$arduinoRoot\portable\sketchbook\libraries" `
    -fqbn      "arduboy-homemade:avr:arduboy-homemade:display=$Display" `
    -build-path $buildDir `
    -verbose `
    $sketchDir

exit $LASTEXITCODE
