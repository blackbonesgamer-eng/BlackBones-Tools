Clear-Host

Write-Host ""
Write-Host "🔥 BLACKBONES INSTALLER 🔥" -ForegroundColor Magenta
Write-Host "SteamTools Setup" -ForegroundColor Cyan
Write-Host ""

# =========================
# Preparar carpeta temporal
# =========================

$Temp = "$env:TEMP\BlackBones"
New-Item -ItemType Directory -Path $Temp -Force | Out-Null

# =========================
# Descargar SteamTools
# =========================

$SteamToolsURL = "https://github.com/blackbonesgamer-eng/BlackBones-Tools/releases/download/v1.0/st-setup-1.8.30.exe"
$SteamToolsEXE = "$Temp\steamtools.exe"

Write-Host "⬇ Descargando SteamTools..." -ForegroundColor Yellow

try {
    Invoke-WebRequest $SteamToolsURL -OutFile $SteamToolsEXE -UseBasicParsing
}
catch {
    Write-Host "❌ Error descargando SteamTools" -ForegroundColor Red
    exit
}

# =========================
# Instalar SteamTools
# =========================

Write-Host "⚙ Instalando SteamTools..." -ForegroundColor Yellow

Start-Process $SteamToolsEXE -ArgumentList "/S" -Wait

Write-Host "✅ SteamTools instalado correctamente" -ForegroundColor Green

# =========================
# Detectar Steam
# =========================

$SteamPath = (Get-ItemProperty -Path "HKCU:\Software\Valve\Steam" -ErrorAction SilentlyContinue).SteamPath

if (-not $SteamPath) {
    Write-Host "⚠ Steam no detectado en el sistema" -ForegroundColor Yellow
    exit
}

$SteamExe = "$SteamPath\steam.exe"

# =========================
# Reiniciar Steam
# =========================

Write-Host ""
Write-Host "🔄 Reiniciando Steam..." -ForegroundColor Cyan

Get-Process steam -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep 3

if (Test-Path $SteamExe) {
    Start-Process $SteamExe
    Write-Host "✅ Steam iniciado correctamente" -ForegroundColor Green
}
else {
    Write-Host "⚠ No se encontró Steam.exe" -ForegroundColor Yellow
}

# =========================
# Limpieza
# =========================

Remove-Item $Temp -Recurse -Force -ErrorAction SilentlyContinue

# =========================
# Final moderno
# =========================

Write-Host ""
Write-Host "██████╗ ██╗      █████╗  ██████╗██╗  ██╗██████╗  ██████╗ ███╗   ██╗███████╗███████╗" -ForegroundColor Magenta
Write-Host "██╔══██╗██║     ██╔══██╗██╔════╝██║ ██╔╝██╔══██╗██╔═══██╗████╗  ██║██╔════╝██╔════╝" -ForegroundColor Magenta
Write-Host "██████╔╝██║     ███████║██║     █████╔╝ ██████╔╝██║   ██║██╔██╗ ██║█████╗  ███████╗" -ForegroundColor Magenta
Write-Host "██╔══██╗██║     ██╔══██║██║     ██╔═██╗ ██╔══██╗██║   ██║██║╚██╗██║██╔══╝  ╚════██║" -ForegroundColor Magenta
Write-Host "██████╔╝███████╗██║  ██║╚██████╗██║  ██╗██████╔╝╚██████╔╝██║ ╚████║███████╗███████║" -ForegroundColor Magenta
Write-Host "╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚══════╝╚══════╝" -ForegroundColor Magenta

Write-Host ""
Write-Host "🔥 VAPORES AL MAXIMO 🔥" -ForegroundColor Yellow
Write-Host ""
