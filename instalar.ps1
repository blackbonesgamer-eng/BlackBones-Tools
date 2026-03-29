
# =============================
# INSTALAR TOKENS (VERSIÓN LIMPIA)
# =============================

function InstalarZipToken {
    param(
        [string]$ZipUrl,
        [string]$NombrePaquete = "Paquete"
    )

    $SteamPath = "C:\Program Files (x86)\Steam"

    $DestinoLua   = Join-Path $SteamPath "config\stplug-in"
    $DestinoResto = Join-Path $SteamPath "depotcache"

    New-Item -ItemType Directory -Path $DestinoLua -Force | Out-Null
    New-Item -ItemType Directory -Path $DestinoResto -Force | Out-Null

    $TempRoot    = Join-Path $env:TEMP "BlackBonesZipToken"
    $TempZip     = Join-Path $TempRoot "paquete.zip"
    $TempExtract = Join-Path $TempRoot "extraido"

    if (Test-Path $TempRoot) {
        Remove-Item $TempRoot -Recurse -Force -ErrorAction SilentlyContinue
    }

    New-Item -ItemType Directory -Path $TempRoot -Force | Out-Null
    New-Item -ItemType Directory -Path $TempExtract -Force | Out-Null

    Clear-Host
    Write-Host "Instalando tokens..." -ForegroundColor Cyan
    Write-Host ""

    Write-Host "Descargando: $NombrePaquete" -ForegroundColor Yellow
    Invoke-WebRequest $ZipUrl -OutFile $TempZip

    Write-Host "Extrayendo paquete..." -ForegroundColor Cyan
    Expand-Archive -Path $TempZip -DestinationPath $TempExtract -Force

    $archivos = @(Get-ChildItem -Path $TempExtract -Recurse -File)

    foreach ($archivo in $archivos) {
        if ($archivo.Extension.ToLower() -eq ".lua") {
            $destinoFinal = Join-Path $DestinoLua $archivo.Name
            Copy-Item $archivo.FullName $destinoFinal -Force
        }
        else {
            $destinoFinal = Join-Path $DestinoResto $archivo.Name
            Copy-Item $archivo.FullName $destinoFinal -Force
        }
    }

    Write-Host "✔ Instalado: $NombrePaquete" -ForegroundColor Green
    Start-Sleep -Milliseconds 400

    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    Write-Host "✅ Tokens instalados correctamente" -ForegroundColor Green
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    Write-Host ""

    Pause
}
