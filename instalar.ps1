Clear-Host

# =========================
# LOGO
# =========================

function MostrarLogo {

Write-Host ""
Write-Host "██████╗ ██╗      █████╗  ██████╗██╗  ██╗██████╗  ██████╗ ███╗   ██╗███████╗███████╗" -ForegroundColor Magenta
Write-Host "██╔══██╗██║     ██╔══██╗██╔════╝██║ ██╔╝██╔══██╗██╔═══██╗████╗  ██║██╔════╝██╔════╝" -ForegroundColor Magenta
Write-Host "██████╔╝██║     ███████║██║     █████╔╝ ██████╔╝██║   ██║██╔██╗ ██║█████╗  ███████╗" -ForegroundColor Magenta
Write-Host "██╔══██╗██║     ██╔══██║██║     ██╔═██╗ ██╔══██╗██║   ██║██║╚██╗██║██╔══╝  ╚════██║" -ForegroundColor Magenta
Write-Host "██████╔╝███████╗██║  ██║╚██████╗██║  ██╗██████╔╝╚██████╔╝██║ ╚████║███████╗███████║" -ForegroundColor Magenta
Write-Host "╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚══════╝╚══════╝" -ForegroundColor Magenta
Write-Host ""
}

# =========================
# BARRA PROGRESO
# =========================

function Barra($texto) {

    Write-Host ""
    Write-Host $texto -ForegroundColor Cyan

    for ($i=0; $i -le 100; $i+=5) {
        Write-Progress -Activity $texto -Status "$i% Completado" -PercentComplete $i
        Start-Sleep -Milliseconds 80
    }

    Write-Progress -Activity $texto -Completed
}

# =========================
# DETECTAR STEAM
# =========================

function ObtenerSteam {

    $SteamPath = (Get-ItemProperty "HKCU:\Software\Valve\Steam" -ErrorAction SilentlyContinue).SteamPath

    if (-not $SteamPath) {
        Write-Host "❌ Steam no está instalado" -ForegroundColor Red
        return $null
    }

    return $SteamPath
}

# =========================
# REINICIAR STEAM
# =========================

function ReiniciarSteam {

    $SteamPath = ObtenerSteam
    if (-not $SteamPath) { return }

    $SteamExe = "$SteamPath\steam.exe"

    Write-Host "🔄 Reiniciando Steam..." -ForegroundColor Yellow

    Get-Process steam -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep 2

    if (Test-Path $SteamExe) {
        Start-Process $SteamExe
        Write-Host "✅ Steam iniciado correctamente" -ForegroundColor Green
    }
}

# =========================
# INSTALAR PLUGIN
# =========================

function InstalarPlugin {

    MostrarLogo
    Barra "Descargando Plugin..."

    $Temp = "$env:TEMP\BlackBones"
    New-Item -ItemType Directory -Path $Temp -Force | Out-Null

    $URL = "https://github.com/blackbonesgamer-eng/BlackBones-Tools/releases/download/v1.0/st-setup-1.8.30.exe"
    $EXE = "$Temp\plugin.exe"

    Invoke-WebRequest $URL -OutFile $EXE -UseBasicParsing

    Barra "Instalando Plugin..."

    Start-Process $EXE -ArgumentList "/S" -Wait

    Write-Host "✅ Plugin instalado correctamente" -ForegroundColor Green

    ReiniciarSteam
    Finalizar
}

# =========================
# ACTIVAR JUEGOS
# =========================

function ActivarJuegos {

    MostrarLogo

    $SteamPath = ObtenerSteam
    if (-not $SteamPath) { return }

    $Destino = "$SteamPath\config\stplug-in"
    New-Item -ItemType Directory -Path $Destino -Force | Out-Null

    $Api = "https://api.github.com/repos/blackbonesgamer-eng/BlackBones-Tools/contents/tokens"
    $files = Invoke-RestMethod $Api
    $tokens = $files | Where-Object { $_.name -like "*.lua" }

    Write-Host ""
    Write-Host "Tokens disponibles:" -ForegroundColor Yellow

    for ($i=0; $i -lt $tokens.Count; $i++) {
        Write-Host "$($i+1)) $($tokens[$i].name)"
    }

    $sel = Read-Host "Seleccione números"

    foreach ($n in ($sel -split ",")) {

        $idx = [int]$n - 1
        if ($idx -ge 0 -and $idx -lt $tokens.Count) {

            $file = $tokens[$idx]
            $destFile = "$Destino\$($file.name)"

            Barra "Instalando $($file.name)..."

            Invoke-WebRequest $file.download_url -OutFile $destFile -UseBasicParsing

            Write-Host "✅ $($file.name) instalado"
        }
    }

    ReiniciarSteam
    Finalizar
}

# =========================
# REPARAR
# =========================

function RepararPlugin {

    Write-Host "🛠 Reparando Plugin..." -ForegroundColor Cyan
    InstalarPlugin
}

# =========================
# SONIDO FINAL
# =========================

function Finalizar {

    [console]::beep(1000,300)
    [console]::beep(1200,300)

    Write-Host ""
    Write-Host "🔥 PROCESO COMPLETADO 🔥" -ForegroundColor Green
    Write-Host ""
}

# =========================
# MENU
# =========================

while ($true) {

    MostrarLogo

    Write-Host "==================================" -ForegroundColor Magenta
    Write-Host "        PLUGIN MANAGER" -ForegroundColor Cyan
    Write-Host "==================================" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "1) Instalar Plugin"
    Write-Host "2) Activar Juegos"
    Write-Host "3) Actualizar Plugin"
    Write-Host "4) Reparar"
    Write-Host "0) Salir"
    Write-Host ""

    $op = Read-Host "Seleccione opción"

    switch ($op) {

        "1" { InstalarPlugin }
        "2" { ActivarJuegos }
        "3" { InstalarPlugin }
        "4" { RepararPlugin }
        "0" { break }

        default { Write-Host "Opción inválida" -ForegroundColor Red }
    }
}
