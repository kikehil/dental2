# Script para descargar el proyecto completo del VPS1 (Windows PowerShell)
# Uso: .\descargar-proyecto-vps1.ps1

# ============================================
# CONFIGURACIÓN DEL VPS1 (ORIGEN)
# ============================================
$VPS1_USER = "root"
$VPS1_HOST = "147.93.118.121"  # ⚠️ CAMBIA POR LA IP DE TU VPS1
$VPS1_PASSWORD = "Netbios+2025"  # ⚠️ CAMBIA POR TU CONTRASEÑA
$VPS1_PATH = "/var/www/html/dentali"  # ⚠️ CAMBIA POR LA RUTA DE TU PROYECTO

# ============================================
# CONFIGURACIÓN LOCAL
# ============================================
$DOWNLOAD_DIR = ".\proyecto-descargado"
$TIMESTAMP = Get-Date -Format "yyyyMMdd_HHmmss"

Write-Host "🔄 Descargando proyecto completo del VPS1..." -ForegroundColor Yellow
Write-Host ""

# Verificar que ssh esté disponible
if (-not (Get-Command ssh -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Error: SSH no está disponible" -ForegroundColor Red
    Write-Host "Instala OpenSSH desde: Configuración > Aplicaciones > Características opcionales > OpenSSH Client" -ForegroundColor Yellow
    exit 1
}

# Verificar que sshpass esté disponible (o usar método alternativo)
$USE_SSHPASS = $false
if (Get-Command sshpass -ErrorAction SilentlyContinue) {
    $USE_SSHPASS = $true
} else {
    Write-Host "⚠️  sshpass no está instalado. Usando método alternativo con expect." -ForegroundColor Yellow
    Write-Host "   Para mejor experiencia, instala sshpass desde: https://sourceforge.net/projects/sshpass/" -ForegroundColor Yellow
    Write-Host ""
}

# Crear directorio de descarga
if (-not (Test-Path $DOWNLOAD_DIR)) {
    New-Item -ItemType Directory -Path $DOWNLOAD_DIR | Out-Null
}

# Función para ejecutar comandos SSH
function Invoke-SSHCommand {
    param([string]$Command)
    
    if ($USE_SSHPASS) {
        $env:SSHPASS = $VPS1_PASSWORD
        sshpass -e ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$VPS1_USER@$VPS1_HOST" $Command
    } else {
        # Método alternativo usando expect (si está disponible)
        # O usar clave SSH configurada
        Write-Host "   Ejecutando: $Command" -ForegroundColor Gray
        ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$VPS1_USER@$VPS1_HOST" $Command
    }
}

# Función para copiar archivos
function Copy-SCPFile {
    param([string]$Source, [string]$Destination)
    
    if ($USE_SSHPASS) {
        $env:SSHPASS = $VPS1_PASSWORD
        sshpass -e scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r $Source $Destination
    } else {
        scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r $Source $Destination
    }
}

Write-Host "1. Verificando conexión con VPS1..." -ForegroundColor Yellow
try {
    $testResult = Invoke-SSHCommand "echo 'Conexión exitosa'" 2>&1
    if ($LASTEXITCODE -ne 0 -and $testResult -notmatch "Conexión exitosa") {
        throw "Error de conexión"
    }
    Write-Host "✅ Conexión exitosa" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: No se pudo conectar al VPS1" -ForegroundColor Red
    Write-Host "Verifica las credenciales en el script" -ForegroundColor Yellow
    Write-Host "Si usas autenticación por clave SSH, configura SSH keys primero" -ForegroundColor Yellow
    exit 1
}
Write-Host ""

Write-Host "2. Verificando que el proyecto existe en VPS1..." -ForegroundColor Yellow
$testDir = Invoke-SSHCommand "test -d $VPS1_PATH && echo 'existe' || echo 'no_existe'"
if ($testDir -notmatch "existe") {
    Write-Host "❌ Error: El directorio $VPS1_PATH no existe en el VPS1" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Proyecto encontrado" -ForegroundColor Green
Write-Host ""

Write-Host "3. Creando backup comprimido en el VPS1..." -ForegroundColor Yellow
$backupCmd = "cd $VPS1_PATH && tar -czf /tmp/proyecto_completo_${TIMESTAMP}.tar.gz --exclude='node_modules' --exclude='.git' --exclude='backups' --exclude='logs' --exclude='*.log' ."
Invoke-SSHCommand $backupCmd | Out-Null

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al crear backup en el VPS1" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Backup creado en el servidor" -ForegroundColor Green
Write-Host ""

Write-Host "4. Descargando proyecto completo..." -ForegroundColor Yellow
$remoteFile = "${VPS1_USER}@${VPS1_HOST}:/tmp/proyecto_completo_${TIMESTAMP}.tar.gz"
$localFile = "$DOWNLOAD_DIR\proyecto_completo_${TIMESTAMP}.tar.gz"

Copy-SCPFile $remoteFile $localFile

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al descargar el proyecto" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Proyecto descargado" -ForegroundColor Green
Write-Host ""

Write-Host "5. Extrayendo proyecto..." -ForegroundColor Yellow
Set-Location $DOWNLOAD_DIR

# Usar tar de Windows 10+ o 7-Zip si está disponible
if (Get-Command tar -ErrorAction SilentlyContinue) {
    tar -xzf "proyecto_completo_${TIMESTAMP}.tar.gz"
} elseif (Get-Command 7z -ErrorAction SilentlyContinue) {
    7z x "proyecto_completo_${TIMESTAMP}.tar.gz"
    # Si es .tar.gz, necesitamos extraer dos veces
    $tarFile = "proyecto_completo_${TIMESTAMP}.tar"
    if (Test-Path $tarFile) {
        7z x $tarFile
        Remove-Item $tarFile
    }
} else {
    Write-Host "⚠️  tar o 7z no están disponibles. Extrae manualmente el archivo .tar.gz" -ForegroundColor Yellow
    Write-Host "   Archivo: proyecto_completo_${TIMESTAMP}.tar.gz" -ForegroundColor Yellow
}

Remove-Item "proyecto_completo_${TIMESTAMP}.tar.gz" -ErrorAction SilentlyContinue
Set-Location ..
Write-Host "✅ Proyecto extraído" -ForegroundColor Green
Write-Host ""

Write-Host "6. Descargando directorio de uploads (si existe)..." -ForegroundColor Yellow
$uploadsTest = Invoke-SSHCommand "test -d $VPS1_PATH/uploads && echo 'existe' || echo 'no_existe'"
if ($uploadsTest -match "existe") {
    Write-Host "   Descargando uploads..."
    $uploadsRemote = "${VPS1_USER}@${VPS1_HOST}:${VPS1_PATH}/uploads"
    $uploadsLocal = "$DOWNLOAD_DIR\uploads"
    Copy-SCPFile $uploadsRemote $uploadsLocal
    Write-Host "✅ Uploads descargados" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Directorio uploads no existe, saltando..." -ForegroundColor Yellow
}
Write-Host ""

Write-Host "7. Limpiando archivos temporales en el VPS1..." -ForegroundColor Yellow
Invoke-SSHCommand "rm -f /tmp/proyecto_completo_${TIMESTAMP}.tar.gz" | Out-Null
Write-Host "✅ Limpieza completada" -ForegroundColor Green
Write-Host ""

Write-Host "✅ Descarga completada exitosamente" -ForegroundColor Green
Write-Host ""
Write-Host "📁 Proyecto descargado en: $DOWNLOAD_DIR" -ForegroundColor Cyan
Write-Host ""
Write-Host "📊 Contenido descargado:" -ForegroundColor Cyan
Get-ChildItem $DOWNLOAD_DIR | Select-Object -First 20 | Format-Table Name, Length, LastWriteTime
Write-Host ""
Write-Host "💡 Próximos pasos:" -ForegroundColor Yellow
Write-Host "   1. Revisa el archivo .env en $DOWNLOAD_DIR" -ForegroundColor White
Write-Host '   2. Ejecuta: .\backup-db-vps1.ps1 para hacer backup de la base de datos' -ForegroundColor White
Write-Host '   3. Luego ejecuta: .\subir-proyecto-vps2.ps1 para subir al VPS2' -ForegroundColor White
Write-Host ""

