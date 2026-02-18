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

$DestinoFolder = "$SteamPath\ext"
New-Item -ItemType Directory -Path $DestinoFolder -Force | Out-Null

# Obtener lista de tokens desde GitHub
$Api = "https://api.github.com/repos/blackbonesgamer-eng/BlackBones-Tools/contents/tokens"
$files = Invoke-RestMethod $Api

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

Write-Host ""
Write-Host "🔥 TOKENS INSTALADOS 🔥" -ForegroundColor Magenta
