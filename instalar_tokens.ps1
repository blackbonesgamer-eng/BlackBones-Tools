Write-Host ""
Write-Host "🔥 BlackBones Token Manager 🔥" -ForegroundColor Cyan
Write-Host ""

# Detectar Steam
$SteamPath = (Get-ItemProperty -Path "HKCU:\Software\Valve\Steam" -ErrorAction SilentlyContinue).SteamPath

if (-not $SteamPath) {
    Write-Host "❌ Steam no encontrado" -ForegroundColor Red
    exit
}

Write-Host "✅ Steam encontrado en: $SteamPath" -ForegroundColor Green

# Ruta correcta de tokens
$DestinoFolder = "$SteamPath\config\stplug-in"
New-Item -ItemType Directory -Path $DestinoFolder -Force | Out-Null

# Obtener lista de tokens desde GitHub
$Api = "https://api.github.com/repos/blackbonesgamer-eng/BlackBones-Tools/contents/tokens"

try {
    $files = Invoke-RestMethod $Api
} catch {
    Write-Host "❌ Error conectando con GitHub" -ForegroundColor Red
    exit
}

$tokens = @()

foreach ($file in $files) {
    if ($file.name -like "*.lua") {
        $tokens += $file
    }
}

if ($tokens.Count -eq 0) {
    Write-Host "❌ No hay tokens disponibles" -ForegroundColor Red
    exit
}

Write-Host ""
Write-Host "Tokens disponibles:" -ForegroundColor Yellow

for ($i = 0; $i -lt $tokens.Count; $i++) {
    Write-Host "$($i+1)) $($tokens[$i].name)"
}

Write-Host ""
$seleccion = Read-Host "Seleccione números separados por coma (ej: 1,3,5)"

$indices = $seleccion -split ","

foreach ($index in $indices) {

    $i = [int]$index - 1

    if ($i -ge 0 -and $i -lt $tokens.Count) {

        $file = $tokens[$i]

        $url = $file.download_url
        $dest = "$DestinoFolder\$($file.name)"

        Write-Host "⬇ Instalando $($file.name)..." -ForegroundColor Yellow

        try {
            Invoke-WebRequest $url -OutFile $dest -UseBasicParsing | Out-Null
            Write-Host "✅ Instalado" -ForegroundColor Green
        }
        catch {
            Write-Host "❌ Error" -ForegroundColor Red
        }
    }
}

# Reiniciar Steam para aplicar tokens
Write-Host ""
Write-Host "🔄 Reiniciando Steam..." -ForegroundColor Cyan

Get-Process steam -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep 2

$SteamExe = "$SteamPath\steam.exe"

if (Test-Path $SteamExe) {
    Start-Process $SteamExe
}

Write-Host ""
Write-Host "🔥 TOKENS INSTALADOS CORRECTAMENTE 🔥" -ForegroundColor Magenta

