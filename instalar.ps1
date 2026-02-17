# ============================================
# ============================================
# BlackBones Tools ULTRA FAST Installer
# Descarga con aria2 + Instalación automática
# ============================================

$Temp = "$env:TEMP\BlackBonesTools"
$AriaDir = "$Temp\aria2"
$AriaExe = "$AriaDir\aria2c.exe"

$SteamToolsURL = "https://github.com/blackbonesgamer-eng/BlackBones-Tools/releases/download/v1.0/st-setup-1.8.30.exe"
$MillenniumURL = "https://github.com/blackbonesgamer-eng/BlackBones-Tools/releases/download/v1.0/MillenniumFiles.zip"

$SteamToolsEXE = "$Temp\st-setup.exe"
$MillenniumZIP = "$Temp\MillenniumFiles.zip"
$MillenniumDir = "$Temp\MillenniumFiles"

$AriaURL = "https://github.com/aria2/aria2/releases/latest/download/aria2-1.37.0-win-64bit-build1.zip"

$OkSteamTools = $false
$OkMillennium = $false

Write-Host ""
Write-Host "🔥 BlackBones Tools ULTRA FAST Installer 🔥" -ForegroundColor Cyan
Write-Host ""

New-Item -ItemType Directory -Path $Temp -Force | Out-Null
New-Item -ItemType Directory -Path $AriaDir -Force | Out-Null

# ==========================
# Descargar aria2
# ==========================
Write-Host "⬇ Preparando motor de descarga..." -ForegroundColor Yellow

$AriaZip = "$Temp\aria2.zip"

Invoke-WebRequest $AriaURL -OutFile $AriaZip -UseBasicParsing
Expand-Archive $AriaZip -DestinationPath $AriaDir -Force

$AriaExe = Get-ChildItem $AriaDir -Recurse -Filter aria2c.exe | Select-Object -First 1 -ExpandProperty FullName

# ==========================
# Función descarga rápida
# ==========================
function DescargarRapido($url,$destino) {
    & $AriaExe -x 16 -s 16 -k 1M -o (Split-Path $destino -Leaf) -d (Split-Path $destino) $url
}

# ==========================
# Descargar SteamTools
# ==========================
Write-Host "⬇ Descargando SteamTools..." -ForegroundColor Yellow
DescargarRapido $SteamToolsURL $SteamToolsEXE

# ==========================
# Instalar SteamTools
# ==========================
if (Test-Path $SteamToolsEXE) {
    Write-Host "➡ Instalando SteamTools..." -ForegroundColor Yellow
    Start-Process $SteamToolsEXE -ArgumentList "/S" -Wait -WindowStyle Hidden
    $OkSteamTools = $true
}

# ==========================
# Descargar Millennium
# ==========================
Write-Host "⬇ Descargando Millennium..." -ForegroundColor Yellow
DescargarRapido $MillenniumURL $MillenniumZIP

# ==========================
# Extraer Millennium
# ==========================
if (Test-Path $MillenniumZIP) {
    Expand-Archive $MillenniumZIP -DestinationPath $MillenniumDir -Force
}

# ==========================
# Detectar Steam
# ==========================
Write-Host "🔎 Buscando Steam..." -ForegroundColor Yellow

$SteamExe = Get-ChildItem "C:\","D:\","E:\","F:\" -ErrorAction SilentlyContinue -Recurse -Filter steam.exe |
Select-Object -First 1 -ExpandProperty FullName

if ($SteamExe) {

    $SteamPath = Split-Path $SteamExe
    Write-Host "✅ Steam encontrado en: $SteamPath" -ForegroundColor Green

    Get-Process steam -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep 2

    Copy-Item "$MillenniumDir\MillenniumFiles\*" $SteamPath -Recurse -Force

    Start-Process $SteamExe | Out-Null

    $OkMillennium = $true

} else {
    Write-Host "❌ No se encontró Steam." -ForegroundColor Red
}

# ==========================
# LIMPIEZA
# ==========================
Remove-Item $Temp -Recurse -Force -ErrorAction SilentlyContinue

# ==========================
# RESULTADO FINAL
# ==========================
Write-Host ""
Write-Host "----------------------------------"
Write-Host "📌 RESULTADO:" -ForegroundColor Cyan

if ($OkSteamTools) {
    Write-Host "✅ SteamTools OK" -ForegroundColor Green
} else {
    Write-Host "❌ SteamTools FALLÓ" -ForegroundColor Red
}

if ($OkMillennium) {
    Write-Host "✅ Millennium OK" -ForegroundColor Green
} else {
    Write-Host "❌ Millennium FALLÓ" -ForegroundColor Red
}

Write-Host ""
Write-Host "VAPORES AL MÁXIMOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO" -ForegroundColor Magenta
Write-Host "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥" -ForegroundColor Magenta
Write-Host ""

Read-Host "Presiona Enter para salir"

