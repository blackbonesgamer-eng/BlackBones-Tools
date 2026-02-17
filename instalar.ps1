# ============================================
# BlackBones Tools Web Installer
# Descarga + SteamTools + Millennium sin GUI
# ============================================

$Temp = "$env:TEMP\BlackBonesTools"

$SteamToolsURL = "https://github.com/blackbonesgamer-eng/BlackBones-Tools/releases/download/v1.0/st-setup-1.8.30.exe"
$MillenniumURL = "https://github.com/blackbonesgamer-eng/BlackBones-Tools/releases/download/v1.0/MillenniumFiles.zip"

$SteamToolsEXE = "$Temp\st-setup.exe"
$MillenniumZIP = "$Temp\MillenniumFiles.zip"
$MillenniumDir = "$Temp\MillenniumFiles"

$OkSteamTools = $false
$OkMillennium = $false

Write-Host ""
Write-Host "🔥 BlackBones Tools Web Installer 🔥" -ForegroundColor Cyan
Write-Host ""

# ==========================
# Crear carpeta temporal
# ==========================
New-Item -ItemType Directory -Path $Temp -Force | Out-Null

# ==========================
# Descargar SteamTools
# ==========================
Write-Host "⬇ Descargando SteamTools..." -ForegroundColor Yellow
Invoke-WebRequest $SteamToolsURL -OutFile $SteamToolsEXE

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
Invoke-WebRequest $MillenniumURL -OutFile $MillenniumZIP

# ==========================
# Extraer Millennium
# ==========================
if (Test-Path $MillenniumZIP) {
    Expand-Archive $MillenniumZIP -DestinationPath $MillenniumDir -Force
}

# ==========================
# Detectar Steam automáticamente
# ==========================
Write-Host "🔎 Buscando instalación de Steam..." -ForegroundColor Yellow

$SteamExe = Get-ChildItem "C:\","D:\","E:\","F:\" -ErrorAction SilentlyContinue -Recurse -Filter steam.exe |
Select-Object -First 1 -ExpandProperty FullName

if ($SteamExe) {

    $SteamPath = Split-Path $SteamExe

    Write-Host "✅ Steam encontrado en: $SteamPath" -ForegroundColor Green

    # Cerrar Steam
    Get-Process steam -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep 2

    # Copiar Millennium
    Copy-Item "$MillenniumDir\MillenniumFiles\*" $SteamPath -Recurse -Force

    # Abrir Steam
    Start-Process $SteamExe | Out-Null

    $OkMillennium = $true

} else {
    Write-Host "❌ No se encontró Steam en el sistema." -ForegroundColor Red
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
    Write-Host "✅ SteamTools instalado correctamente" -ForegroundColor Green
} else {
    Write-Host "❌ SteamTools falló" -ForegroundColor Red
}

if ($OkMillennium) {
    Write-Host "✅ Millennium instalado correctamente" -ForegroundColor Green
} else {
    Write-Host "❌ Millennium falló" -ForegroundColor Red
}

Write-Host ""
Write-Host "VAPORES AL MÁXIMOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO" -ForegroundColor Magenta
Write-Host "🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥" -ForegroundColor Magenta
Write-Host ""

Read-Host "Presiona Enter para salir"
