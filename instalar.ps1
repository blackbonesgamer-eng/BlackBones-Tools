Clear-Host

# =============================
# LOGO BLACKBONES ANIMADO
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
    Start-Sleep -Milliseconds 80
}

Write-Host ""
Write-Host "🔥 BLACKBONES PLUGIN MANAGER 🔥" -ForegroundColor Cyan
Write-Host ""

Start-Sleep -Milliseconds 500
}

# =============================
# SPINNER NEON
# =============================

function Spinner($texto, $loops=25) {

    $chars = @("|","/","-","\")

    for ($i=0; $i -lt $loops; $i++) {

        foreach ($c in $chars) {
            Write-Host "`r$texto $c" -NoNewline -ForegroundColor Cyan
            Start-Sleep -Milliseconds 120
        }
    }

    Write-Host "`r$texto ✔" -ForegroundColor Green
}

# =============================
# BARRA PROGRESO REAL
# =============================

function Progreso($texto) {

    for ($i=0; $i -le 100; $i+=2) {

        Write-Progress -Activity $texto `
        -Status "$i% Completado" `
        -PercentComplete $i

        Start-Sleep -Milliseconds 35
    }

    Write-Progress -Activity $texto -Completed
}

# =============================
# DETECTAR STEAM
# =============================

function ObtenerSteam {

    $SteamPath = (Get-ItemProperty "HKCU:\Software\Valve\Steam" -ErrorAction SilentlyContinue).SteamPath

    if (-not $SteamPath) {
        Write-Host ""
        Write-Host "❌ Steam no detectado en el sistema" -ForegroundColor Red
        Pause
        return $null
    }

    return $SteamPath
}

# =============================
# REINICIAR STEAM
# =============================

function ReiniciarSteam {

    $SteamPath = ObtenerSteam
    if (-not $SteamPath) { return }

    $SteamExe = "$SteamPath\steam.exe"

    Write-Host ""
    Write-Host "🔄 Reiniciando Steam..." -ForegroundColor Yellow

    Get-Process steam -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep -Seconds 2

    if (Test-Path $SteamExe) {
        Start-Process $SteamExe
        Write-Host "✅ Steam iniciado correctamente" -ForegroundColor Green
    }
}

# =============================
# INSTALAR PLUGIN
# =============================

function InstalarPlugin {

    Clear-Host
    Write-Host "⚙ PLUGIN INSTALLER" -ForegroundColor Magenta
    Write-Host ""

    Spinner "Preparando instalación..."
    Progreso "Descargando Plugin..."

    $Temp = "$env:TEMP\BlackBones"
    New-Item -ItemType Directory -Path $Temp -Force | Out-Null

    $URL = "https://github.com/blackbonesgamer-eng/BlackBones-Tools/releases/download/v1.0/st-setup-1.8.30.exe"
    $EXE = "$Temp\plugin.exe"

    Invoke-WebRequest $URL -OutFile $EXE -UseBasicParsing

    Progreso "Instalando Plugin..."

    Start-Process $EXE -ArgumentList "/S" -Wait

    Write-Host ""
    Write-Host "✅ Plugin instalado correctamente" -ForegroundColor Green

    ReiniciarSteam
    Finalizar
}

# =============================
# ACTIVAR JUEGOS
# =============================

function ActivarJuegos {

    Clear-Host
    Write-Host "🎮 GAME ACTIVATION CENTER 🎮" -ForegroundColor Cyan
    Write-Host ""

    $SteamPath = ObtenerSteam
    if (-not $SteamPath) { return }

    $Destino = "$SteamPath\config\stplug-in"
    New-Item -ItemType Directory -Path $Destino -Force | Out-Null

    $Api = "https://api.github.com/repos/blackbonesgamer-eng/BlackBones-Tools/contents/tokens"
    $files = Invoke-RestMethod $Api
    $tokens = $files | Where-Object { $_.name -like "*.lua" }

    Write-Host "Tokens disponibles:" -ForegroundColor Yellow
    Write-Host ""

    for ($i=0; $i -lt $tokens.Count; $i++) {
        Write-Host "$($i+1)) $($tokens[$i].name)"
    }

    $sel = Read-Host "`nSeleccione números (ej: 1,2)"

    foreach ($n in ($sel -split ",")) {

        $idx = [int]$n - 1
        if ($idx -ge 0 -and $idx -lt $tokens.Count) {

            $file = $tokens[$idx]
            $destFile = "$Destino\$($file.name)"

            Spinner "Instalando $($file.name)..."
            Progreso "Copiando archivos..."

            Invoke-WebRequest $file.download_url -OutFile $destFile -UseBasicParsing

            Write-Host "✅ $($file.name) instalado"
        }
    }

    ReiniciarSteam
    Finalizar
}

# =============================
# FINAL
# =============================

function Finalizar {

    [console]::beep(900,200)
    [console]::beep(1200,200)

    Write-Host ""
    Write-Host "🔥 PROCESO COMPLETADO 🔥" -ForegroundColor Magenta
    Write-Host ""

    Pause
}

# =============================
# MENU PRINCIPAL
# =============================

LogoPrincipal

while ($true) {

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
