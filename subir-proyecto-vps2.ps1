# Script para subir el proyecto completo al VPS2 (Windows PowerShell)
# Uso: .\subir-proyecto-vps2.ps1

# ============================================
# CONFIGURACIÓN DEL VPS2 (DESTINO)
# ============================================
$VPS2_USER = "root"
$VPS2_HOST = "nueva_ip_vps2"  # ⚠️ CAMBIA POR LA IP DE TU VPS2
$VPS2_PASSWORD = "tu_password"  # ⚠️ CAMBIA POR TU CONTRASEÑA
$VPS2_PATH = "/var/www/html/dentali"  # ⚠️ CAMBIA POR LA RUTA DONDE QUIERES EL PROYECTO

# ============================================
# CONFIGURACIÓN LOCAL
# ============================================
$PROYECTO_DIR = ".\proyecto-descargado"  # Directorio con el proyecto descargado del VPS1
$TIMESTAMP = Get-Date -Format "yyyyMMdd_HHmmss"

Write-Host "📤 Subiendo proyecto completo al VPS2..." -ForegroundColor Yellow
Write-Host ""

# Verificar que ssh esté disponible
if (-not (Get-Command ssh -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Error: SSH no está disponible" -ForegroundColor Red
    exit 1
}

# Verificar sshpass
$USE_SSHPASS = $false
if (Get-Command sshpass -ErrorAction SilentlyContinue) {
    $USE_SSHPASS = $true
}

# Verificar que el directorio del proyecto existe
if (-not (Test-Path $PROYECTO_DIR)) {
    Write-Host "❌ Error: El directorio $PROYECTO_DIR no existe" -ForegroundColor Red
    Write-Host "Primero ejecuta: .\descargar-proyecto-vps1.ps1" -ForegroundColor Yellow
    exit 1
}

# Función para ejecutar comandos SSH
function Invoke-SSHCommand {
    param([string]$Command)
    
    if ($USE_SSHPASS) {
        $env:SSHPASS = $VPS2_PASSWORD
        sshpass -e ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$VPS2_USER@$VPS2_HOST" $Command
    } else {
        ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$VPS2_USER@$VPS2_HOST" $Command
    }
}

# Función para copiar archivos
function Copy-SCPFile {
    param([string]$Source, [string]$Destination)
    
    if ($USE_SSHPASS) {
        $env:SSHPASS = $VPS2_PASSWORD
        sshpass -e scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r $Source $Destination
    } else {
        scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r $Source $Destination
    }
}

Write-Host "1. Verificando conexión con VPS2..." -ForegroundColor Yellow
try {
    $testResult = Invoke-SSHCommand "echo 'Conexión exitosa'" 2>&1
    if ($LASTEXITCODE -ne 0 -and $testResult -notmatch "Conexión exitosa") {
        throw "Error de conexión"
    }
    Write-Host "✅ Conexión exitosa" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: No se pudo conectar al VPS2" -ForegroundColor Red
    Write-Host "Verifica las credenciales en el script" -ForegroundColor Yellow
    exit 1
}
Write-Host ""

Write-Host "2. Creando directorio en el VPS2..." -ForegroundColor Yellow
Invoke-SSHCommand "mkdir -p $VPS2_PATH" | Out-Null
Write-Host "✅ Directorio creado" -ForegroundColor Green
Write-Host ""

Write-Host "3. Creando backup comprimido del proyecto local..." -ForegroundColor Yellow
Set-Location $PROYECTO_DIR

$tempTarFile = "$env:TEMP\proyecto_para_vps2_${TIMESTAMP}.tar.gz"

# Usar tar de Windows 10+ o 7-Zip
if (Get-Command tar -ErrorAction SilentlyContinue) {
    tar -czf $tempTarFile --exclude='node_modules' --exclude='.git' --exclude='backups' --exclude='logs' --exclude='*.log' --exclude='.env' .
} elseif (Get-Command 7z -ErrorAction SilentlyContinue) {
    # Usar 7z como alternativa
    $tempDir = "$env:TEMP\proyecto_temp_$TIMESTAMP"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    Copy-Item -Path . -Destination $tempDir -Recurse -Exclude @('node_modules', '.git', 'backups', 'logs', '*.log', '.env')
    Set-Location $tempDir
    7z a -ttar "$env:TEMP\proyecto_para_vps2_${TIMESTAMP}.tar" .
    7z a -tgzip "$tempTarFile" "$env:TEMP\proyecto_para_vps2_${TIMESTAMP}.tar"
    Remove-Item "$env:TEMP\proyecto_para_vps2_${TIMESTAMP}.tar" -ErrorAction SilentlyContinue
    Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    Set-Location $PROYECTO_DIR
} else {
    Write-Host "❌ Error: tar o 7z no están disponibles" -ForegroundColor Red
    Write-Host "Instala 7-Zip desde: https://www.7-zip.org/" -ForegroundColor Yellow
    Set-Location ..
    exit 1
}

Set-Location ..

if (-not (Test-Path $tempTarFile)) {
    Write-Host "❌ Error al crear backup comprimido" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Backup comprimido creado" -ForegroundColor Green
Write-Host ""

Write-Host "4. Subiendo proyecto al VPS2..." -ForegroundColor Yellow
$remoteDest = "${VPS2_USER}@${VPS2_HOST}:/tmp/proyecto_para_vps2_${TIMESTAMP}.tar.gz"
Copy-SCPFile $tempTarFile $remoteDest

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al subir el proyecto" -ForegroundColor Red
    Remove-Item $tempTarFile -ErrorAction SilentlyContinue
    exit 1
}
Write-Host "✅ Proyecto subido" -ForegroundColor Green
Write-Host ""

Write-Host "5. Extrayendo proyecto en el VPS2..." -ForegroundColor Yellow
$extractCmd = "cd $VPS2_PATH && tar -xzf /tmp/proyecto_para_vps2_${TIMESTAMP}.tar.gz && rm -f /tmp/proyecto_para_vps2_${TIMESTAMP}.tar.gz"
Invoke-SSHCommand $extractCmd | Out-Null

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al extraer el proyecto" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Proyecto extraído" -ForegroundColor Green
Write-Host ""

Write-Host "6. Subiendo directorio de uploads (si existe)..." -ForegroundColor Yellow
$uploadsPath = Join-Path $PROYECTO_DIR "uploads"
if (Test-Path $uploadsPath) {
    Write-Host "   Subiendo uploads..."
    $uploadsRemote = "${VPS2_USER}@${VPS2_HOST}:${VPS2_PATH}/"
    Copy-SCPFile $uploadsPath $uploadsRemote
    Write-Host "✅ Uploads subidos" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Directorio uploads no existe localmente, saltando..." -ForegroundColor Yellow
}
Write-Host ""

Write-Host "7. Configurando permisos en el VPS2..." -ForegroundColor Yellow
Invoke-SSHCommand "cd $VPS2_PATH && chown -R $VPS2_USER:$VPS2_USER . && chmod -R 755 ." | Out-Null
Write-Host "✅ Permisos configurados" -ForegroundColor Green
Write-Host ""

# Limpiar archivo temporal local
Remove-Item $tempTarFile -ErrorAction SilentlyContinue

Write-Host "✅ Proyecto subido exitosamente al VPS2" -ForegroundColor Green
Write-Host ""
Write-Host "📁 Proyecto ubicado en: $VPS2_PATH" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚠️  IMPORTANTE: Ahora necesitas:" -ForegroundColor Yellow
Write-Host "   1. Crear el archivo .env en el VPS2 con las credenciales correctas" -ForegroundColor White
Write-Host '   2. Ejecutar: .\restaurar-db-vps2.ps1 para restaurar la base de datos' -ForegroundColor White
Write-Host "   3. En el VPS2, ejecutar:" -ForegroundColor White
Write-Host "      cd $VPS2_PATH" -ForegroundColor Gray
Write-Host "      npm ci --production" -ForegroundColor Gray
Write-Host "      npx prisma generate" -ForegroundColor Gray
Write-Host "      npm run build" -ForegroundColor Gray
Write-Host "      pm2 start ecosystem.config.js" -ForegroundColor Gray
Write-Host ""

