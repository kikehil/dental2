# Script para restaurar respaldo de base de datos localmente
# Ajusta las variables según tu configuración de MySQL

param(
    [string]$BackupFile = "D:\WEB\dentali - V3 - copia\backups\db_backup_20260125_103809.sql",
    [string]$MySQLUser = "root",
    [string]$MySQLPassword = "",
    [string]$DatabaseName = "clinica_dental",
    [string]$MySQLHost = "localhost",
    [string]$MySQLPort = "3306"
)

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "RESTAURACIÓN DE RESPALDO DE BASE DE DATOS" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Verificar que el archivo de respaldo existe
if (-not (Test-Path $BackupFile)) {
    Write-Host "ERROR: No se encontró el archivo de respaldo: $BackupFile" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Archivo de respaldo encontrado: $BackupFile" -ForegroundColor Green
Write-Host ""

# Buscar MySQL en ubicaciones comunes
$mysqlPath = $null
if (Test-Path "C:\xampp\mysql\bin\mysql.exe") {
    $mysqlPath = "C:\xampp\mysql\bin\mysql.exe"
} elseif (Test-Path "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe") {
    $mysqlPath = "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
} elseif (Test-Path "C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe") {
    $mysqlPath = "C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe"
} else {
    # Intentar usar mysql del PATH
    $mysqlPath = "mysql"
}

# Construir comando MySQL
$mysqlArgs = "-h$MySQLHost -P$MySQLPort -u$MySQLUser"

if ($MySQLPassword) {
    $mysqlArgs += " -p$MySQLPassword"
}

Write-Host "Configuración:" -ForegroundColor Yellow
Write-Host "  Base de datos: $DatabaseName"
Write-Host "  Usuario: $MySQLUser"
Write-Host "  Host: $MySQLHost"
Write-Host "  Puerto: $MySQLPort"
Write-Host ""

# Verificar conexión a MySQL
Write-Host "Verificando conexión a MySQL..." -ForegroundColor Yellow
$testConnection = & $mysqlPath $mysqlArgs.Split(' ') -e "SELECT 1;" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: No se pudo conectar a MySQL" -ForegroundColor Red
    Write-Host "Verifica que:" -ForegroundColor Yellow
    Write-Host "  1. MySQL esté corriendo"
    Write-Host "  2. Las credenciales sean correctas"
    Write-Host "  3. MySQL esté en el PATH del sistema"
    Write-Host ""
    Write-Host "Puedes ajustar las credenciales editando este script o pasándolas como parámetros:" -ForegroundColor Cyan
    Write-Host "  .\restaurar-backup-local.ps1 -MySQLUser 'root' -MySQLPassword 'tu_password'" -ForegroundColor Cyan
    exit 1
}

Write-Host "✓ Conexión a MySQL exitosa" -ForegroundColor Green
Write-Host ""

# Crear la base de datos si no existe
Write-Host "Creando base de datos '$DatabaseName' si no existe..." -ForegroundColor Yellow
$createDbQuery = "CREATE DATABASE IF NOT EXISTS \`$DatabaseName\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
& $mysqlPath $mysqlArgs.Split(' ') -e $createDbQuery 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: No se pudo crear la base de datos" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Base de datos lista" -ForegroundColor Green
Write-Host ""

# Restaurar el respaldo
Write-Host "Restaurando respaldo (esto puede tardar varios minutos)..." -ForegroundColor Yellow
Write-Host ""

$mysqlArgsWithDb = "$mysqlArgs $DatabaseName"
$restoreCommand = "Get-Content '$BackupFile' | & '$mysqlPath' $mysqlArgsWithDb"

try {
    Invoke-Expression $restoreCommand
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "================================================" -ForegroundColor Green
        Write-Host "✓ RESTAURACIÓN COMPLETADA EXITOSAMENTE" -ForegroundColor Green
        Write-Host "================================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "La base de datos '$DatabaseName' ha sido restaurada desde:" -ForegroundColor Cyan
        Write-Host "  $BackupFile" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Próximos pasos:" -ForegroundColor Yellow
        Write-Host "  1. Verifica que el archivo .env tenga la DATABASE_URL correcta"
        Write-Host "  2. Ejecuta: npx prisma generate"
        Write-Host "  3. Inicia el servidor: npm run dev"
    } else {
        Write-Host ""
        Write-Host "ERROR: La restauración falló" -ForegroundColor Red
        Write-Host "Revisa los mensajes de error arriba" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host ""
    Write-Host "ERROR: Error al restaurar el respaldo" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}
