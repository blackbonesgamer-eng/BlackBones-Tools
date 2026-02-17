# ============================================
# BlackBones Tools ULTRA FAST Installer
# ============================================

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

Write-Host ""
Write-Host "🔥 BlackBones Tools ULTRA FAST Installer 🔥" -ForegroundColor Cyan
Write-Host ""

# ==========================
# Preparar carpetas
# ==========================
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

    # Cerrar Steam
    Get-Process steam -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep 2

    # Detectar carpeta correcta dentro del ZIP
    $SourcePath = $MillenniumDir

    if (Test-Path "$MillenniumDir\MillenniumFiles") {
        $SourcePath = "$MillenniumDir\MillenniumFiles"
    }

    # Copiar archivos
    Copy-Item "$SourcePath\*" $SteamPath -Recurse -Force

    # Abrir Steam
    Start-Process $SteamExe | Out-Null

    $OkMillennium = $true

} else {
    Write-Host "❌ No se encontró Steam en el sistema." -ForegroundColor Red
}

# ==========================
# Limpieza
# ==========================
Remove-Item $Temp -Recurse -Force -ErrorAction SilentlyContinue

# ==========================
# Resultado final
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
