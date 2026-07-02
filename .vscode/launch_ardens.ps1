param([string]$Display = "sh1106")

$arduinoRoot = Split-Path (Split-Path (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) -Parent) -Parent
$sketchDir   = Split-Path $PSScriptRoot -Parent
$buildDir    = Join-Path $sketchDir "build\arduboy-homemade.avr.arduboy-homemade-$Display"
$hexFile     = Join-Path $buildDir "Escape.ino.hex"

$candidates = @(
    "$env:USERPROFILE\Desktop\Arduboy\ArdensPlayer.exe",
    "$env:USERPROFILE\Desktop\ArdensPlayer.exe",
    "$env:USERPROFILE\Downloads\ArdensPlayer.exe",
    "$arduinoRoot\ArdensPlayer.exe"
)

$ardens = $null
foreach ($c in $candidates) {
    if (Test-Path $c) { $ardens = $c; break }
}
if (-not $ardens) {
    Write-Error "ArdensPlayer.exe nicht gefunden."
    exit 1
}

Write-Host "Kompiliere Escape ($Display)..." -ForegroundColor Cyan
& "$PSScriptRoot\build.ps1" -Display $Display

if ($LASTEXITCODE -ne 0) {
    Write-Error "Kompilierung fehlgeschlagen!"
    exit 1
}

# Hex in einfachen Pfad kopieren (kein Netzlaufwerk, keine Sonderzeichen)
$localHex = "$env:USERPROFILE\Desktop\Arduboy\Escape.hex"
Copy-Item $hexFile $localHex -Force

# ArdensPlayer starten
Write-Host "Starte ArdensPlayer..." -ForegroundColor Green
$proc = Start-Process -FilePath $ardens -PassThru
Start-Sleep -Milliseconds 2000

# Datei per simuliertem Drag & Drop laden (WM_DROPFILES)
Add-Type @"
using System;
using System.Runtime.InteropServices;
using System.Text;
public class DropHelper {
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
    [DllImport("user32.dll")] public static extern IntPtr PostMessage(IntPtr h, uint msg, IntPtr w, IntPtr l);
    [DllImport("kernel32.dll")] public static extern IntPtr GlobalAlloc(uint f, UIntPtr s);
    [DllImport("kernel32.dll")] public static extern IntPtr GlobalLock(IntPtr h);
    [DllImport("kernel32.dll")] public static extern bool GlobalUnlock(IntPtr h);
    public static void Drop(IntPtr hwnd, string path) {
        byte[] pb = Encoding.Unicode.GetBytes(path + "\0\0");
        int total = 20 + pb.Length;
        IntPtr hg = GlobalAlloc(0x0042, (UIntPtr)total);
        IntPtr p  = GlobalLock(hg);
        Marshal.WriteInt32(p,  0, 20);
        Marshal.WriteInt32(p,  4, 0);
        Marshal.WriteInt32(p,  8, 0);
        Marshal.WriteInt32(p, 12, 0);
        Marshal.WriteInt32(p, 16, 1);
        Marshal.Copy(pb, 0, IntPtr.Add(p, 20), pb.Length);
        GlobalUnlock(hg);
        SetForegroundWindow(hwnd);
        PostMessage(hwnd, 0x0233, hg, IntPtr.Zero);
    }
}
"@ -ErrorAction SilentlyContinue

[DropHelper]::Drop($proc.MainWindowHandle, $localHex)
Write-Host "Spiel geladen." -ForegroundColor Green
