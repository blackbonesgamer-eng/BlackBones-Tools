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
    Write-Host \$line -ForegroundColor Magenta
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
        return \$null
    }
}

# =============================
# REINICIAR STEAM
# =============================

function ReiniciarSteam {

    \$SteamPath = ObtenerSteam
    if (-not \$SteamPath) { return }

    Get-Process steam -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep 2

    $exe = "$SteamPath\steam.exe"
    if (Test-Path \$exe) {
        Start-Process \$exe
    }
}

function DescargarArchivo(\$url, \$destino) {

    $request = [System.Net.HttpWebRequest]::Create($url)
    $response = $request.GetResponse()

    $total = $response.ContentLength
    $stream = $response.GetResponseStream()

    $file = [System.IO.File]::Create($destino)

    \$buffer = New-Object byte[] 8192
    \$totalRead = 0

    while (($read = $stream.Read(\$buffer, 0, \$buffer.Length)) -gt 0) {

        \$file.Write(\$buffer, 0, \$read)
        $totalRead += $read

        if (\$total -gt 0) {

            $percent = [math]::Round(($totalRead / \$total) * 100)
            $bars = [math]::Floor($percent / 4)
            $line = "[" + ("█" * $bars) + ("░" * (25 - \$bars)) + "]"

            Write-Host "`rDescargando $line $percent%" -NoNewline -ForegroundColor Cyan
        }
    }

    $file.Close()
    $stream.Close()
    $response.Close()

    Write-Host ""
}

# =============================
# PREPARAR MOD UNIVERSAL
# =============================

function PrepararModUniversal($GamePath) {

    Write-Host ""
    Write-Host "🔧 Preparando entorno universal..." -ForegroundColor Cyan

    try {
        Get-ChildItem $GamePath -Recurse -Force | Unblock-File -ErrorAction SilentlyContinue
    } catch {}

    try {
        icacls $GamePath /grant Everyone:F /T /C | Out-Null
    } catch {}

    $vcInstalled = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* `
        | Where-Object { \$_.DisplayName -like "*Visual C++*" }

    if (-not \$vcInstalled) {

        Write-Host "Instalando Visual C++..." -ForegroundColor Yellow

        \$vcUrl = "https://aka.ms/vs/17/release/vc_redist.x64.exe"
        $vcExe = "$env:TEMP\vc_redist.exe"

        DescargarArchivo \$vcUrl \$vcExe
        Start-Process \$vcExe -ArgumentList "/install /quiet /norestart" -Wait
    }

    if (!(Test-Path "\$env:SystemRoot\System32\d3dx9_43.dll")) {

        Write-Host "Instalando DirectX..." -ForegroundColor Yellow

        \$dxUrl = "https://download.microsoft.com/download/1/1/C/11C8C1E3-7E52-4F9F-AE1F-CE2C7C3A6F2E/directx_Jun2010_redist.exe"
        $dxExe = "$env:TEMP\directx.exe"
        $dxFolder = "$env:TEMP\directx"

        DescargarArchivo \$dxUrl \$dxExe
        Start-Process \$dxExe -ArgumentList "/Q /T:\$dxFolder" -Wait
        Start-Process "\$dxFolder\DXSETUP.exe" -ArgumentList "/silent" -Wait
    }

    Write-Host "✔ Entorno listo" -ForegroundColor Green
}

# =============================
# EJECUTAR PLUGIN OCULTO
# =============================

function EjecutarPluginAuto {

    \$SteamPath = ObtenerSteam
    if (-not \$SteamPath) { return }

    $pluginExe = "$SteamPath\config\stplug-in\stplug.exe"

    if (!(Test-Path \$pluginExe)) { return }

    try {

        Write-Host "Inicializando sistema..." -ForegroundColor DarkGray

        \$psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = $pluginExe
        \$psi.WindowStyle = "Hidden"
        $psi.CreateNoWindow = $true
        $psi.UseShellExecute = $false

        $proc = [System.Diagnostics.Process]::Start($psi)

        Start-Sleep 6

        if (\$proc -and !\$proc.HasExited) {
            \$proc.Kill()
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
    New-Item -ItemType Directory -Path \$Temp -Force | Out-Null

    \$URL = "https://github.com/blackbonesgamer-eng/BlackBones-Tools/releases/download/v1.0/st-setup-1.8.30.exe"
    $EXE = "$Temp\plugin.exe"

    Invoke-WebRequest \$URL -OutFile \$EXE -UseBasicParsing
    Start-Process \$EXE -ArgumentList "/S" -Wait

    Write-Host "✅ Plugin instalado" -ForegroundColor Green

    AplicarSteamToolsFix

    # eliminar accesos directos
    \$desktop = [Environment]::GetFolderPath("Desktop")

    Get-ChildItem \$desktop -Filter "*.lnk" -ErrorAction SilentlyContinue |
    Where-Object { \$_.Name -match "stplug|steamtool|blackbones" } |
    Remove-Item -Force -ErrorAction SilentlyContinue

    EjecutarPluginAuto

    ReiniciarSteam
}

# =============================
# ACTUALIZAR PLUGIN
# =============================

function ActualizarPlugin {
    InstalarPlugin
}

# =============================
# NUEVA FUNCIÓN: INSTALAR TOKEN DESDE ZIP
# =============================

function InstalarTokenDesdeZip {

    Clear-Host
    Write-Host "📦 INSTALAR TOKEN DESDE ZIP" -ForegroundColor Cyan
   