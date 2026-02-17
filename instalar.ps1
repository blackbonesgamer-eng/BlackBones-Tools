$Temp = "$env:TEMP\BlackBonesTools"
$AriaDir = "$Temp\aria2"

$SteamToolsURL = "https://github.com/blackbonesgamer-eng/BlackBones-Tools/releases/download/v1.0/st-setup-1.8.30.exe"
$MillenniumURL = "https://github.com/blackbonesgamer-eng/BlackBones-Tools/releases/download/v1.0/MillenniumFiles.zip"
$AriaURL       = "https://github.com/aria2/aria2/releases/latest/download/aria2-1.37.0-win-64bit-build1.zip"

$SteamToolsEXE = "$Temp\st-setup.exe"
$MillenniumZIP = "$Temp\Millennium.zip"
$MillenniumDir = "$Temp\MillenniumExtract"

$OkSteamTools = $false
$OkMillennium = $false

function Barra($p){
    Write-Progress -Activity "BlackBones Tools Installer" -Status "$p% completado" -PercentComplete $p
}

Barra 5

New-Item -ItemType Directory -Path $Temp -Force | Out-Null
New-Item -ItemType Directory -Path $AriaDir -Force | Out-Null

# Descargar aria2
$AriaZip = "$Temp\aria2.zip"
Invoke-WebRequest $AriaURL -OutFile $AriaZip -UseBasicParsing | Out-Null
Expand-Archive $AriaZip -DestinationPath $AriaDir -Force | Out-Null

$AriaExe = Get-ChildItem $AriaDir -Recurse -Filter aria2c.exe | Select-Object -First 1 -ExpandProperty FullName

Barra 20

function Descargar($url,$dest){
    & $AriaExe -x 16 -s 16 --console-log-level=error --summary-interval=0 `
    -o (Split-Path $dest -Leaf) -d (Split-Path $dest) $url | Out-Null
}

# SteamTools
Descargar $SteamToolsURL $SteamToolsEXE

if (Test-Path $SteamToolsEXE) {
    Start-Process $SteamToolsEXE -ArgumentList "/S" -Wait -WindowStyle Hidden
    $OkSteamTools = $true
}

Barra 55

# Millennium
Descargar $MillenniumURL $MillenniumZIP

if (Test-Path $MillenniumZIP) {
    Expand-Archive $MillenniumZIP -DestinationPath $MillenniumDir -Force | Out-Null
}

Barra 75

# Buscar Steam
$SteamExe = Get-ChildItem "C:\","D:\","E:\" -ErrorAction SilentlyContinue -Recurse -Filter steam.exe |
Select-Object -First 1 -ExpandProperty FullName

if ($SteamExe) {

    $SteamPath = Split-Path $SteamExe

    Get-Process steam -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep 2

    $SourcePath = $MillenniumDir
    if (Test-Path "$MillenniumDir\MillenniumFiles") {
        $SourcePath = "$MillenniumDir\MillenniumFiles"
    }

    Copy-Item "$SourcePath\*" $SteamPath -Recurse -Force
    Start-Process $SteamExe | Out-Null

    $OkMillennium = $true
}

Barra 100
Write-Progress -Activity "BlackBones Tools Installer" -Completed

Remove-Item $Temp -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "RESULTADO:" -ForegroundColor Cyan

if ($OkSteamTools) {
    Write-Host "SteamTools: OK" -ForegroundColor Green
} else {
    Write-Host "SteamTools: ERROR" -ForegroundColor Red
}

if ($OkMillennium) {
    Write-Host "Millennium: OK" -ForegroundColor Green
} else {
    Write-Host "Millennium: ERROR" -ForegroundColor Red
}

Write-Host ""

# ASCII BLACKBONES
Write-Host "██████╗ ██╗      █████╗  ██████╗██╗  ██╗██████╗  ██████╗ ███╗   ██╗███████╗███████╗" -ForegroundColor Magenta
Write-Host "██╔══██╗██║     ██╔══██╗██╔════╝██║ ██╔╝██╔══██╗██╔═══██╗████╗  ██║██╔════╝██╔════╝" -ForegroundColor Magenta
Write-Host "██████╔╝██║     ███████║██║     █████╔╝ ██████╔╝██║   ██║██╔██╗ ██║█████╗  ███████╗" -ForegroundColor Magenta
Write-Host "██╔══██╗██║     ██╔══██║██║     ██╔═██╗ ██╔══██╗██║   ██║██║╚██╗██║██╔══╝  ╚════██║" -ForegroundColor Magenta
Write-Host "██████╔╝███████╗██║  ██║╚██████╗██║  ██╗██████╔╝╚██████╔╝██║ ╚████║███████╗███████║" -ForegroundColor Magenta
Write-Host "╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚══════╝╚══════╝" -ForegroundColor Magenta

Write-Host ""
Write-Host "🔥 VAPORES AL MÁXIMO 🔥" -ForegroundColor Yellow
