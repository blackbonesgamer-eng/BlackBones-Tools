Clear-Host
$ErrorActionPreference = "SilentlyContinue"

# =============================
# LOGO BLACKBONES STORE
# =============================

function LogoPrincipal {

$logo = @"
██████╗ ██╗      █████╗  ██████╗██╗  ██╗██████╗  ██████╗ ███╗   ██╗███████╗███████╗
██╔══██╗██║     ██╔══██╗██╔════╝██║ ██╔╝██╔══██╗██╔═══██╗████╗  ██║██╔════╝██╔════╝
██████╔╝██║     ███████║██║     █████╔╝ ██████╔╝██║   ██║██╔██╗ ██║█████╗  ███████╗
██╔══██╗██║     ██╔══██║██║     ██╔═██╗ ██╔══██╗██║   ██║██║╚██╗██║██╔══╝  ╚════██║
██████╔╝███████╗██║  ██║╚██████╗██║  ██╗██████╔╝╚██████╔╝██║ ╚████║███████╗███████║
╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚══════╝╚══════╝

                ███████╗████████╗ ██████╗ ██████╗ ███████╗
                ██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗██╔════╝
                ███████╗   ██║   ██║   ██║██████╔╝█████╗
                ╚════██║   ██║   ██║   ██║██╔══██╗██╔══╝
                ███████║   ██║   ╚██████╔╝██║  ██║███████╗
                ╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝
"@

foreach ($line in $logo.Split("`n")) {
    Write-Host $line -ForegroundColor Magenta
}

Write-Host ""
Write-Host "🔥 BLACKBONES STORE TOOL 🔥" -ForegroundColor Cyan
Write-Host ""
}

# =============================
# DETECTAR STEAM
# =============================

function ObtenerSteam {
    try {
        return (Get-ItemProperty "HKCU:\Software\Valve\Steam").SteamPath
    } catch {
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

function DescargarArchivo($url, $destino) {

    $request = [System.Net.HttpWebRequest]::Create($url)
    $response = $request.GetResponse()

    $total = $response.ContentLength
    $stream = $response.GetResponseStream()

    $file = [System.IO.File]::Create($destino)

    $buffer = New-Object byte[] 8192
    $totalRead = 0

    while (($read = $stream.Read($buffer, 0, $buffer.Length)) -gt 0) {

        $file.Write($buffer, 0, $read)
        $totalRead += $read

        if ($total -gt 0) {

            $percent = [math]::Round(($totalRead / $total) * 100)
            $bars = [math]::Floor($percent / 4)
            $line = "[" + ("█" * $bars) + ("░" * (25 - $bars)) + "]"

            Write-Host "`rDescargando $line $percent%" -NoNewline -ForegroundColor Cyan
        }
    }

    $file.Close()
    $stream.Close()
    $response.Close()

    Write-Host ""
}

# =============================
# EJECUTAR PLUGIN OCULTO
# =============================

function EjecutarPluginAuto {

    $SteamPath = ObtenerSteam
    if (-not $SteamPath) { return }

    $pluginExe = "$SteamPath\config\stplug-in\stplug.exe"

    if (!(Test-Path $pluginExe)) { return }

    try {

        Write-Host "Inicializando sistema..." -ForegroundColor DarkGray

        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = $pluginExe
        $psi.WindowStyle = "Hidden"
        $psi.CreateNoWindow = $true
        $psi.UseShellExecute = $false

        $proc = [System.Diagnostics.Process]::Start($psi)

        Start-Sleep 6

        if ($proc -and !$proc.HasExited) {
            $proc.Kill()
        }

    } catch {}
}

# =============================
# INSTALAR PLUGIN
# =============================

function InstalarPlugin {

    Clear-Host
    Write-Host "⚙ INSTALANDO PLUGIN..." -ForegroundColor Cyan

    $Temp = "$env:TEMP\BlackBones"
    New-Item -ItemType Directory -Path $Temp -Force | Out-Null

    $URL = "https://github.com/blackbonesgamer-eng/BlackBones-Tools/releases/download/v1.0/st-setup-1.8.30.exe"
    $EXE = "$Temp\plugin.exe"

    Invoke-WebRequest $URL -OutFile $EXE -UseBasicParsing
    Start-Process $EXE -ArgumentList "/S" -Wait

    Write-Host "✅ Plugin instalado" -ForegroundColor Green

    # 🔥 ELIMINAR SOLO ACCESOS DEL PLUGIN (SEGURO)
    $desktop = [Environment]::GetFolderPath("Desktop")

    Get-ChildItem $desktop -Filter "*.lnk" -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -match "stplug|steamtool|blackbones" } |
    Remove-Item -Force -ErrorAction SilentlyContinue

    EjecutarPluginAuto
    ReiniciarSteam
    Pause
}

# =============================
# ACTUALIZAR PLUGIN
# =============================

function ActualizarPlugin {
    InstalarPlugin
}

# =============================
# ACTIVAR JUEGOS (TOKENS)
# =============================

function ActivarJuegos {

    Clear-Host
    Write-Host "🎮 GAME ACTIVATION CENTER 🎮" -ForegroundColor Cyan
    Write-Host ""

    $SteamPath = ObtenerSteam
    if (-not $SteamPath) { Pause; return }

    $Destino = "$SteamPath\config\stplug-in"
    New-Item -ItemType Directory -Path $Destino -Force | Out-Null

    $Api = "https://api.github.com/repos/blackbonesgamer-eng/BlackBones-Tools/contents/tokens"
    $files = @(Invoke-RestMethod $Api -Headers @{ "User-Agent" = "PowerShell" })

    $tokens = $files | Where-Object { $_.name -like "*.lua" }

    for ($i = 0; $i -lt $tokens.Count; $i++) {
        Write-Host "$($i+1)) $($tokens[$i].name)" -ForegroundColor Yellow
    }

    Write-Host ""
    $sel = Read-Host "Seleccione números (ej: 1,3)"

    foreach ($n in ($sel -split ",")) {

        $idx = [int]$n - 1

        if ($idx -ge 0 -and $idx -lt $tokens.Count) {

            $file = $tokens[$idx]
            $destFile = "$Destino\$($file.name)"

            Invoke-WebRequest $file.download_url -OutFile $destFile -UseBasicParsing
        }
    }

    EjecutarPluginAuto
    ReiniciarSteam

    Write-Host "✅ Tokens instalados correctamente" -ForegroundColor Green
    Pause
}

# =============================
# ELIMINAR TOKENS
# =============================

function EliminarTokens {

    Clear-Host
    Write-Host "🗑 ELIMINAR TOKENS" -ForegroundColor Red
    Write-Host ""

    $SteamPath = ObtenerSteam
    if (-not $SteamPath) { Pause; return }

    $Destino = "$SteamPath\config\stplug-in"
    $files = Get-ChildItem $Destino -Filter *.lua

    for ($i = 0; $i -lt $files.Count; $i++) {
        Write-Host "$($i+1)) $($files[$i].Name)" -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "A) Eliminar todos"

    $sel = Read-Host "Seleccione número o A"

    if ($sel -eq "A") {
        Remove-Item "$Destino\*.lua" -Force
        Write-Host "✅ Tokens eliminados"
        Pause
        return
    }

    $index = [int]$sel - 1

    if ($index -ge 0 -and $index -lt $files.Count) {
        Remove-Item $files[$index].FullName -Force
        Write-Host "✅ Token eliminado"
    }

    Pause
}

# =============================
# INSTALAR COMPLEMENTOS (MODS)
# =============================

function InstalarComplementos {

    Clear-Host
    Write-Host "🧩 INSTALACIÓN DE COMPLEMENTOS" -ForegroundColor Cyan
    Write-Host ""

    $Api = "https://api.github.com/repos/blackbonesgamer-eng/BlackBones-Tools/contents/complementos"
    $items = @(Invoke-RestMethod -Uri $Api -Headers @{ "User-Agent" = "PowerShell" })

    $mods = $items | Where-Object { $_.type -eq "dir" }

    for ($i = 0; $i -lt $mods.Count; $i++) {
        Write-Host "$($i+1)) $($mods[$i].name)"
    }

    $sel = Read-Host "Seleccione número"
    $mod = $mods[[int]$sel - 1]

    $modName = $mod.name.ToLower()

    # =============================
    # DETECTAR JUEGO
    # =============================

    $SteamPath = ObtenerSteam
    $LibrariesFile = "$SteamPath\steamapps\libraryfolders.vdf"
    $content = Get-Content $LibrariesFile

    $paths = @()
    foreach ($line in $content) {
        if ($line -match '"path"\s+"(.+)"') {
            $paths += $matches[1].Replace("\\","\")
        }
    }

    $GamePath = $null

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

    Write-Host "🎮 Juego detectado: $GamePath" -ForegroundColor Green

    # =============================
    # DESCARGAR REPO COMPLETO
    # =============================

    $repoZip = "$env:TEMP\bb_repo.zip"
    $repoExtract = "$env:TEMP\bb_repo"
    $extractTemp = "$env:TEMP\bb_extract"

    if (Test-Path $repoExtract) { Remove-Item $repoExtract -Recurse -Force }
    if (Test-Path $extractTemp) { Remove-Item $extractTemp -Recurse -Force }

    $zipUrl = "https://codeload.github.com/blackbonesgamer-eng/BlackBones-Tools/zip/refs/heads/main"

    Write-Host "Descargando archivos..." -ForegroundColor Cyan
    DescargarArchivo $zipUrl $repoZip

    Expand-Archive $repoZip -DestinationPath $repoExtract -Force

    $repoFolder = Get-ChildItem $repoExtract | Select-Object -First 1
    $modSource = Join-Path $repoFolder.FullName "complementos\$($mod.name)"

    # =============================
    # SI HAY ZIP → EXTRAER
    # =============================

    $zipInside = Get-ChildItem $modSource -Filter *.zip -Recurse | Select-Object -First 1

    if ($zipInside) {

        Write-Host "Extrayendo mod..." -ForegroundColor Cyan

        New-Item -ItemType Directory -Path $extractTemp | Out-Null

        Expand-Archive -Path $zipInside.FullName -DestinationPath $extractTemp -Force

        $files = Get-ChildItem $extractTemp

        foreach ($item in $files) {
            Copy-Item $item.FullName $GamePath -Recurse -Force
        }
    }
    else {

        Copy-Item "$modSource\*" $GamePath -Recurse -Force
    }

    Write-Host "✅ Complemento instalado correctamente" -ForegroundColor Green
    Pause
}

# =============================
# MENU
# =============================

LogoPrincipal

while ($true) {

    Write-Host ""
    Write-Host "==================================" -ForegroundColor Magenta
    Write-Host "1) Instalar Plugin"
    Write-Host "2) Actualizar Plugin"
    Write-Host "3) Activar Juegos"
    Write-Host "4) Eliminar Tokens"
    Write-Host "5) Instalar Complementos"
    Write-Host "0) Salir"
    Write-Host "==================================" -ForegroundColor Magenta
    Write-Host ""

    $op = Read-Host "Seleccione opción"

    switch ($op) {

        "1" { InstalarPlugin }
        "2" { ActualizarPlugin }
        "3" { ActivarJuegos }
        "4" { EliminarTokens }
        "5" { InstalarComplementos }
        "0" { break }

        default { Write-Host "Opción inválida" }
    }
}





















