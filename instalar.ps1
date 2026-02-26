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
# INSTALAR COMPLEMENTOS
# =============================

function InstalarComplementos {

    Clear-Host
    Write-Host "🧩 INSTALACIÓN DE COMPLEMENTOS" -ForegroundColor Cyan
    Write-Host ""

    $Api = "https://api.github.com/repos/blackbonesgamer-eng/BlackBones-Tools/contents/complementos"

    try {
        $mods = Invoke-RestMethod -Uri $Api -Headers @{ "User-Agent" = "PowerShell" }
    }
    catch {
        Write-Host "❌ Error conectando con el repositorio"
        Pause
        return
    }

    $mods = $mods | Where-Object { $_.type -eq "dir" }

    if (!$mods) {
        Write-Host "❌ No hay complementos disponibles"
        Pause
        return
    }

    Write-Host "Mods disponibles:`n"

    for ($i = 0; $i -lt $mods.Count; $i++) {
        Write-Host "$($i+1)) $($mods[$i].name)" -ForegroundColor Yellow
    }

    $sel = Read-Host "`nSeleccione número"

    if (-not ($sel -match '^\d+$')) { return }

    $mod = $mods[[int]$sel - 1]

    # Detectar Steam
    $SteamPath = ObtenerSteam
    if (-not $SteamPath) { return }

    $LibrariesFile = "$SteamPath\steamapps\libraryfolders.vdf"
    $content = Get-Content $LibrariesFile

    $paths = @()
    foreach ($line in $content) {
        if ($line -match '"path"\s+"(.+)"') {
            $paths += $matches[1].Replace("\\","\")
        }
    }

    $GamePath = $null
    $modName = $mod.name.ToLower()

    foreach ($lib in $paths) {

        $common = "$lib\steamapps\common"
        if (!(Test-Path $common)) { continue }

        $games = Get-ChildItem $common -Directory

        foreach ($game in $games) {
            if ($game.Name.ToLower() -like "*$modName*") {
                $GamePath = $game.FullName
                break
            }
        }

        if ($GamePath) { break }
    }

    if (-not $GamePath) {
        Write-Host "❌ Juego no encontrado"
        Pause
        return
    }

    Write-Host "Juego detectado: $GamePath" -ForegroundColor Green

    # =============================
    # DESCARGA RECURSIVA
    # =============================

    function DescargarContenido($url, $destino) {

        $items = Invoke-RestMethod -Uri $url -Headers @{ "User-Agent" = "PowerShell" }

        foreach ($item in $items) {

            $rutaDestino = Join-Path $destino $item.name

            if ($item.type -eq "dir") {

                if (!(Test-Path $rutaDestino)) {
                    New-Item -ItemType Directory -Path $rutaDestino | Out-Null
                }

                DescargarContenido $item.url $rutaDestino
            }
            else {

                Write-Host "Descargando $($item.name)..."
                Invoke-WebRequest $item.download_url -OutFile $rutaDestino -UseBasicParsing
            }
        }
    }

    DescargarContenido $mod.url $GamePath

    Write-Host "`n✅ Complemento instalado correctamente" -ForegroundColor Cyan
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
    Write-Host "5) Instalar Complementos" -ForegroundColor Cyan
    Write-Host "0) Salir" -ForegroundColor Cyan
    Write-Host "==================================" -ForegroundColor Magenta
    Write-Host ""

    $op = Read-Host "Seleccione opción"

    switch ($op) {

        "1" { InstalarPlugin }
        "2" { ActivarJuegos }
        "3" { InstalarPlugin }
        "4" { InstalarPlugin }
        "5" { InstalarComplementos }
        "0" { break }

        default { Write-Host "Opción inválida" -ForegroundColor Red }
    }
}






