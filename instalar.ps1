Write-Host ""
Write-Host "🔥 BlackBones SteamTools Installer 🔥" -ForegroundColor Cyan
Write-Host ""

# Carpeta temporal
$Temp = "$env:TEMP\BlackBones"
New-Item -ItemType Directory -Path $Temp -Force | Out-Null

# URL SteamTools
$SteamToolsURL = "https://github.com/blackbonesgamer-eng/BlackBones-Tools/releases/download/v1.0/st-setup-1.8.30.exe"
$SteamToolsEXE = "$Temp\steamtools.exe"

Write-Host "⬇ Descargando SteamTools..." -ForegroundColor Yellow

Invoke-WebRequest $SteamToolsURL -OutFile $SteamToolsEXE -UseBasicParsing

Write-Host "➡ Instalando SteamTools..." -ForegroundColor Yellow

Start-Process $SteamToolsEXE -ArgumentList "/S" -Wait

Write-Host ""
Write-Host "✅ SteamTools instalado correctamente" -ForegroundColor Green
Write-Host ""

Write-Host "██████╗ ██╗      █████╗  ██████╗██╗  ██╗██████╗  ██████╗ ███╗   ██╗███████╗███████╗" -ForegroundColor Magenta
Write-Host "██╔══██╗██║     ██╔══██╗██╔════╝██║ ██╔╝██╔══██╗██╔═══██╗████╗  ██║██╔════╝██╔════╝" -ForegroundColor Magenta
Write-Host "██████╔╝██║     ███████║██║     █████╔╝ ██████╔╝██║   ██║██╔██╗ ██║█████╗  ███████╗" -ForegroundColor Magenta
Write-Host "██╔══██╗██║     ██╔══██║██║     ██╔═██╗ ██╔══██╗██║   ██║██║╚██╗██║██╔══╝  ╚════██║" -ForegroundColor Magenta
Write-Host "██████╔╝███████╗██║  ██║╚██████╗██║  ██╗██████╔╝╚██████╔╝██║ ╚████║███████╗███████║" -ForegroundColor Magenta
Write-Host "╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚══════╝╚══════╝" -ForegroundColor Magenta
