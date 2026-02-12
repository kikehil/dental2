# Script para restaurar la base de datos en el VPS2 (Windows PowerShell)
# Uso: .\restaurar-db-vps2.ps1

# ============================================
# CONFIGURACIÓN DEL VPS2 (DESTINO)
# ============================================
$VPS2_USER = "root"
$VPS2_HOST = "nueva_ip_vps2"  # ⚠️ CAMBIA POR LA IP DE TU VPS2
$VPS2_PASSWORD = "tu_password"  # ⚠️ CAMBIA POR TU CONTRASEÑA
$VPS2_PATH = "/var/www/html/dentali"  # ⚠️ CAMBIA POR LA RUTA DE TU PROYECTO

# ============================================
# CONFIGURACIÓN LOCAL
# ============================================
$BACKUP_DIR = ".\backups"
# Si no especificas un archivo, usará el más reciente
$BACKUP_FILE = ""  # ⚠️ Deja vacío para usar el más reciente, o especifica: "db_backup_20250128_120000.sql"

Write-Host "🗄️  Restaurando base de datos en el VPS2..." -ForegroundColor Yellow
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
        sshpass -e scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $Source $Destination
    } else {
        scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $Source $Destination
    }
}

# Determinar qué archivo de backup usar
if ([string]::IsNullOrEmpty($BACKUP_FILE)) {
    # Buscar el backup más reciente
    $backups = Get-ChildItem -Path $BACKUP_DIR -Filter "db_backup_*.sql" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending
    if ($backups.Count -eq 0) {
        Write-Host "❌ Error: No se encontró ningún backup en $BACKUP_DIR" -ForegroundColor Red
        Write-Host "Primero ejecuta: .\backup-db-vps1.ps1" -ForegroundColor Yellow
        exit 1
    }
    $BACKUP_FILE = $backups[0].FullName
    Write-Host "📁 Usando backup más reciente: $($backups[0].Name)" -ForegroundColor Yellow
} else {
    $BACKUP_FILE = Join-Path $BACKUP_DIR $BACKUP_FILE
    if (-not (Test-Path $BACKUP_FILE)) {
        Write-Host "❌ Error: El archivo $BACKUP_FILE no existe" -ForegroundColor Red
        exit 1
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

Write-Host "2. Verificando que el proyecto existe en VPS2..." -ForegroundColor Yellow
$testDir = Invoke-SSHCommand "test -d $VPS2_PATH && echo 'existe' || echo 'no_existe'"
if ($testDir -notmatch "existe") {
    Write-Host "❌ Error: El directorio $VPS2_PATH no existe en el VPS2" -ForegroundColor Red
    Write-Host "Primero ejecuta: .\subir-proyecto-vps2.ps1" -ForegroundColor Yellow
    exit 1
}
Write-Host "✅ Proyecto encontrado" -ForegroundColor Green
Write-Host ""

Write-Host "3. Obteniendo credenciales de la base de datos del VPS2..." -ForegroundColor Yellow
$dbUrlCommand = 'cd ' + $VPS2_PATH + ' && grep DATABASE_URL .env 2>/dev/null | cut -d "=" -f2- | tr -d "\"" | tr -d "\047" | tr -d " "'
$DB_URL = (Invoke-SSHCommand $dbUrlCommand).Trim()

if ([string]::IsNullOrEmpty($DB_URL)) {
    Write-Host "❌ Error: No se pudo obtener DATABASE_URL del archivo .env" -ForegroundColor Red
    Write-Host "Asegúrate de que el archivo .env existe en el VPS2 y tiene DATABASE_URL configurado" -ForegroundColor Yellow
    exit 1
}

# Extraer componentes de la URL de conexión
if ($DB_URL -match "mysql://([^:]+):([^@]+)@([^:]+):?(\d*)/([^?]+)") {
    $DB_USER = $matches[1]
    $DB_PASS = $matches[2]
    $DB_HOST = $matches[3]
    $DB_PORT = if ($matches[4]) { $matches[4] } else { "3306" }
    $DB_NAME = $matches[5]
} else {
    Write-Host "❌ Error: No se pudo parsear DATABASE_URL" -ForegroundColor Red
    exit 1
}

Write-Host "   Usuario: $DB_USER"
Write-Host "   Host: $DB_HOST"
Write-Host "   Puerto: $DB_PORT"
Write-Host "   Base de datos: $DB_NAME"
Write-Host "✅ Credenciales obtenidas" -ForegroundColor Green
Write-Host ""

Write-Host "4. Verificando que la base de datos existe..." -ForegroundColor Yellow
$dbExistsCmd = "mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS -e 'SHOW DATABASES LIKE \"$DB_NAME\"' 2>/dev/null | grep -c $DB_NAME"
$dbExists = (Invoke-SSHCommand $dbExistsCmd).Trim()

if ([int]$dbExists -eq 0) {
    Write-Host "⚠️  La base de datos no existe, creándola..." -ForegroundColor Yellow
    $createDbCmd = "mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS -e 'CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci' 2>/dev/null"
    Invoke-SSHCommand $createDbCmd | Out-Null
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Error al crear la base de datos" -ForegroundColor Red
        exit 1
    }
    Write-Host "✅ Base de datos creada" -ForegroundColor Green
} else {
    Write-Host "✅ Base de datos existe" -ForegroundColor Green
}
Write-Host ""

Write-Host "5. Subiendo backup al VPS2..." -ForegroundColor Yellow
$restoreTimestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$remoteBackup = "${VPS2_USER}@${VPS2_HOST}:/tmp/db_restore_${restoreTimestamp}.sql"

# Convertir ruta de Windows a formato compatible con scp
$backupPathUnix = $BACKUP_FILE -replace '\\', '/'
Copy-SCPFile $backupPathUnix $remoteBackup

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al subir el backup" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Backup subido" -ForegroundColor Green
Write-Host ""

Write-Host "6. Restaurando base de datos..." -ForegroundColor Yellow
Write-Host "   Esto puede tardar varios minutos dependiendo del tamaño de la base de datos..." -ForegroundColor Gray
$restoreCmd = "mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS $DB_NAME < /tmp/db_restore_${restoreTimestamp}.sql 2>&1"
Invoke-SSHCommand $restoreCmd | Out-Null

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al restaurar la base de datos" -ForegroundColor Red
    Write-Host "Verifica las credenciales y que MySQL esté corriendo en el VPS2" -ForegroundColor Yellow
    Invoke-SSHCommand "rm -f /tmp/db_restore_${restoreTimestamp}.sql" | Out-Null
    exit 1
}
Write-Host "✅ Base de datos restaurada" -ForegroundColor Green
Write-Host ""

Write-Host "7. Limpiando archivo temporal en el VPS2..." -ForegroundColor Yellow
Invoke-SSHCommand "rm -f /tmp/db_restore_${restoreTimestamp}.sql" | Out-Null
Write-Host "✅ Limpieza completada" -ForegroundColor Green
Write-Host ""

Write-Host "8. Verificando restauración..." -ForegroundColor Yellow
$tablesCmd = "mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS $DB_NAME -e 'SHOW TABLES' 2>/dev/null | wc -l"
$tables = (Invoke-SSHCommand $tablesCmd).Trim()

if ([int]$tables -gt 1) {
    Write-Host "✅ Base de datos restaurada correctamente ($tables tablas encontradas)" -ForegroundColor Green
} else {
    Write-Host "⚠️  Advertencia: Pocas tablas encontradas, verifica manualmente" -ForegroundColor Yellow
}
Write-Host ""

Write-Host "✅ Restauración de base de datos completada exitosamente" -ForegroundColor Green
Write-Host ""
Write-Host "💡 Próximos pasos en el VPS2:" -ForegroundColor Yellow
Write-Host "   1. Verifica que el archivo .env tenga las credenciales correctas" -ForegroundColor White
Write-Host "   2. Ejecuta: cd $VPS2_PATH" -ForegroundColor Gray
Write-Host "   3. Ejecuta: npm ci --production" -ForegroundColor Gray
Write-Host "   4. Ejecuta: npx prisma generate" -ForegroundColor Gray
Write-Host "   5. Ejecuta: npx prisma migrate deploy" -ForegroundColor Gray
Write-Host "   6. Ejecuta: npm run build" -ForegroundColor Gray
Write-Host "   7. Ejecuta: pm2 start ecosystem.config.js" -ForegroundColor Gray
Write-Host "   8. Verifica que la aplicación funcione correctamente" -ForegroundColor Gray
Write-Host ""

