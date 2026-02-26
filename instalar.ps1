Clear-Host
$ErrorActionPreference = "SilentlyContinue"

# =============================
# LOGO BLACKBONES
# =============================

function LogoPrincipal {

$logo = @"
██████╗ ██╗      █████╗  ██████╗██╗  ██╗██████╗  ██████╗ ███╗   ██╗███████╗███████╗
██╔══██╗██║     ██╔══██╗██╔════╝██║ ██╔╝██╔══██╗██╔═══██╗████╗  ██║██╔════╝██╔════╝
██████╔╝██║     ███████║██║     █████╔╝ ██████╔╝██║   ██║██╔██╗ ██║█████╗  ███████╗
██╔══██╗██║     ██╔══██║██║     ██╔═██╗ ██╔══██╗██║   ██║██║╚██╗██║██╔══╝  ╚════██║
██████╔╝███████╗██║  ██║╚██████╗██║  ██╗██████╔╝╚██████╔╝██║ ╚████║███████╗███████║
╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚══════╝╚══════╝
"@

foreach ($line in $logo.Split("`n")) {
    Write-Host $line -ForegroundColor Magenta
    Start-Sleep -Milliseconds 60
}

Write-Host ""
Write-Host "🔥 BLACKBONES PLUGIN MANAGER 🔥" -ForegroundColor Cyan
Write-Host ""
Start-Sleep -Milliseconds 400
}

# =============================
# SPINNER
# =============================

function Spinner($texto) {

    $chars = @("|","/","-","\")

    for ($i=0; $i -lt 20; $i++) {
        foreach ($c in $chars) {
            Write-Host "`r$texto $c" -NoNewline -ForegroundColor Cyan
            Start-Sleep -Milliseconds 120
        }
    }

    Write-Host "`r$texto ✔" -ForegroundColor Green
}

# =============================
# DETECTAR STEAM
# =============================

function ObtenerSteam {

    try {
        return (Get-ItemProperty "HKCU:\Software\Valve\Steam").SteamPath
    }
    catch {
        Write-Host "❌ Steam no detectado" -ForegroundColor Red
        return $null
    }
}

# =============================
# REINICIAR STEAM
# =============================

function ReiniciarSteam {

    $SteamPath = ObtenerSteam
    if (-not $SteamPath) { return }

    Get-Process steam -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep 2

    $exe = "$SteamPath\steam.exe"
    if (Test-Path $exe) {
        Start-Process $exe
    }
}

# =============================
# INSTALAR PLUGIN
# =============================

function InstalarPlugin {

    Clear-Host
    Write-Host "⚙ PLUGIN INSTALLER" -ForegroundColor Magenta

    Spinner "Preparando..."

    $Temp = "$env:TEMP\BlackBones"
    New-Item -ItemType Directory -Path $Temp -Force | Out-Null

    $URL = "https://github.com/blackbonesgamer-eng/BlackBones-Tools/releases/download/v1.0/st-setup-1.8.30.exe"
    $EXE = "$Temp\plugin.exe"

    Invoke-WebRequest $URL -OutFile $EXE -UseBasicParsing

    Spinner "Instalando..."

    Start-Process $EXE -ArgumentList "/S" -Wait

    Write-Host "✅ Plugin instalado" -ForegroundColor Green

    ReiniciarSteam
    Pause
}

# =============================
# ACTIVAR JUEGOS
# =============================

function ActivarJuegos {

    Clear-Host
    Write-Host "🎮 GAME ACTIVATION CENTER 🎮" -ForegroundColor Cyan

    $SteamPath = ObtenerSteam
    if (-not $SteamPath) { Pause; return }

    $Destino = "$SteamPath\config\stplug-in"
    New-Item -ItemType Directory -Path $Destino -Force | Out-Null

    $Api = "https://api.github.com/repos/blackbonesgamer-eng/BlackBones-Tools/contents/tokens"
    $files = Invoke-RestMethod $Api
    $tokens = $files | Where-Object { $_.name -like "*.lua" }

    for ($i=0; $i -lt $tokens.Count; $i++) {
        Write-Host "$($i+1)) $($tokens[$i].name)"
    }

    $sel = Read-Host "Seleccione números"

    foreach ($n in ($sel -split ",")) {

        $idx = [int]$n - 1
        if ($idx -ge 0 -and $idx -lt $tokens.Count) {

            $file = $tokens[$idx]
            $destFile = "$Destino\$($file.name)"

            Invoke-WebRequest $file.download_url -OutFile $destFile -UseBasicParsing
            Write-Host "Instalado $($file.name)"
        }
    }

    ReiniciarSteam
    Pause
}

# =============================
# MENU PRINCIPAL
# =============================

LogoPrincipal

while ($true) {

    Write-Host ""
    Write-Host "==================================" -ForegroundColor Magenta
    Write-Host "1) Instalar Plugin" -ForegroundColor Cyan
    Write-Host "2) Activar Juegos" -ForegroundColor Cyan
    Write-Host "3) Actualizar Plugin" -ForegroundColor Cyan
    Write-Host "4) Reparar" -ForegroundColor Cyan
    Write-Host "0) Salir" -ForegroundColor Cyan
    Write-Host "==================================" -ForegroundColor Magenta
    Write-Host ""

    $op = Read-Host "Seleccione opción"

    switch ($op) {

        "1" { InstalarPlugin }
        "2" { ActivarJuegos }
        "3" { InstalarPlugin }
        "4" { InstalarPlugin }
        "0" { break }

        default { Write-Host "Opción inválida" -ForegroundColor Red }
    }
}
