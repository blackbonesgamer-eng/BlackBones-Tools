#requires -RunAsAdministrator

# ============================================
# BlackBones Tools Web Installer
# Descarga + SteamTools + Millennium sin GUI
# ============================================

$Temp = "$env:TEMP\BlackBonesTools"
$SteamPath = "E:\Programas\Steam"
$SteamExe  = Join-Path $SteamPath "steam.exe"

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
    Write-Host "➡ Instalando SteamTools (silencioso)..." -ForegroundColor Yellow
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
# Instalar Millennium sin GUI
# ==========================
if ((Test-Path $SteamExe) -and (Test-Path $MillenniumDir)) {

    Write-Host "➡ Instalando Millennium..." -ForegroundColor Yellow

    # Cerrar Steam
    Get-Process steam -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep 2

    # Copiar archivos
    Copy-Item "$MillenniumDir\MillenniumFiles\*" $SteamPath -Recurse -Force

    # Abrir Steam
    Start-Process $SteamExe | Out-Null

    $OkMillennium = $true
}

# ==========================
# LIMPIEZA
# ==========================
Remove-Item $Temp -Recurse -Force -ErrorAction SilentlyContinue

# ==========================
# RESUMEN FINAL
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
