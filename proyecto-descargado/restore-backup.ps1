# Script para restaurar respaldo de base de datos
# Uso: .\restore-backup.ps1 -BackupPath "ruta\al\respaldo.sql"

param(
    [Parameter(Mandatory=$true)]
    [string]$BackupPath
)

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  RESTAURAR RESPALDO DE BASE DE DATOS" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Verificar que el archivo de respaldo existe
if (-not (Test-Path $BackupPath)) {
    Write-Host "ERROR: El archivo de respaldo no existe: $BackupPath" -ForegroundColor Red
    exit 1
}

Write-Host "Archivo de respaldo encontrado: $BackupPath" -ForegroundColor Green
Write-Host ""

# Buscar MySQL en ubicaciones comunes
$mysqlPaths = @(
    "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe",
    "C:\Program Files\MySQL\MySQL Server 8.1\bin\mysql.exe",
    "C:\Program Files\MySQL\MySQL Server 8.2\bin\mysql.exe",
    "C:\Program Files\MySQL\MySQL Server 8.3\bin\mysql.exe",
    "C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe",
    "C:\xampp\mysql\bin\mysql.exe",
    "C:\wamp64\bin\mysql\mysql8.0.xx\bin\mysql.exe",
    "mysql.exe"  # Si está en PATH
)

$mysqlExe = $null
foreach ($path in $mysqlPaths) {
    if ($path -eq "mysql.exe") {
        try {
            $result = Get-Command mysql -ErrorAction SilentlyContinue
            if ($result) {
                $mysqlExe = "mysql"
                break
            }
        } catch {
            continue
        }
    } elseif (Test-Path $path) {
        $mysqlExe = $path
        break
    }
}

if (-not $mysqlExe) {
    Write-Host "ERROR: No se encontró MySQL en las ubicaciones comunes." -ForegroundColor Red
    Write-Host ""
    Write-Host "Por favor, proporciona la ruta completa a mysql.exe:" -ForegroundColor Yellow
    Write-Host "Ejemplo: C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -ForegroundColor Yellow
    $customPath = Read-Host "Ruta a mysql.exe"
    if (Test-Path $customPath) {
        $mysqlExe = $customPath
    } else {
        Write-Host "ERROR: La ruta proporcionada no existe." -ForegroundColor Red
        exit 1
    }
}

Write-Host "MySQL encontrado: $mysqlExe" -ForegroundColor Green
Write-Host ""

# Solicitar credenciales de MySQL
Write-Host "Ingresa las credenciales de MySQL:" -ForegroundColor Yellow
$mysqlUser = Read-Host "Usuario (por defecto: root)"
if ([string]::IsNullOrWhiteSpace($mysqlUser)) {
    $mysqlUser = "root"
}

$mysqlPassword = Read-Host "Contraseña" -AsSecureString
$mysqlPasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($mysqlPassword)
)

$mysqlHost = Read-Host "Host (por defecto: localhost)"
if ([string]::IsNullOrWhiteSpace($mysqlHost)) {
    $mysqlHost = "localhost"
}

$mysqlPort = Read-Host "Puerto (por defecto: 3306)"
if ([string]::IsNullOrWhiteSpace($mysqlPort)) {
    $mysqlPort = "3306"
}

$databaseName = Read-Host "Nombre de la base de datos (por defecto: clinica_dental)"
if ([string]::IsNullOrWhiteSpace($databaseName)) {
    $databaseName = "clinica_dental"
}

Write-Host ""
Write-Host "Verificando conexión a MySQL..." -ForegroundColor Yellow

# Verificar conexión
$testConnection = & $mysqlExe -h $mysqlHost -P $mysqlPort -u $mysqlUser -p"$mysqlPasswordPlain" -e "SELECT 1;" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: No se pudo conectar a MySQL. Verifica las credenciales." -ForegroundColor Red
    Write-Host "Detalles: $testConnection" -ForegroundColor Red
    exit 1
}

Write-Host "Conexión exitosa a MySQL" -ForegroundColor Green
Write-Host ""

# Crear la base de datos si no existe
Write-Host "Creando base de datos '$databaseName' si no existe..." -ForegroundColor Yellow
& $mysqlExe -h $mysqlHost -P $mysqlPort -u $mysqlUser -p"$mysqlPasswordPlain" -e "CREATE DATABASE IF NOT EXISTS $databaseName CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host "Base de datos '$databaseName' lista" -ForegroundColor Green
} else {
    Write-Host "ADVERTENCIA: No se pudo crear la base de datos (puede que ya exista)" -ForegroundColor Yellow
}

Write-Host ""

# Confirmar antes de restaurar
Write-Host "ADVERTENCIA: Esta operación reemplazará todos los datos en la base de datos '$databaseName'" -ForegroundColor Red
Write-Host "¿Deseas continuar? (S/N)" -ForegroundColor Yellow
$confirm = Read-Host
if ($confirm -ne "S" -and $confirm -ne "s" -and $confirm -ne "Y" -and $confirm -ne "y") {
    Write-Host "Operación cancelada." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Restaurando respaldo..." -ForegroundColor Yellow
Write-Host "Esto puede tardar varios minutos dependiendo del tamaño del respaldo..." -ForegroundColor Yellow
Write-Host ""

# Restaurar el respaldo
$restoreCommand = "& `$mysqlExe -h $mysqlHost -P $mysqlPort -u $mysqlUser -p`"$mysqlPasswordPlain`" $databaseName < `"$BackupPath`""
$env:MYSQL_PWD = $mysqlPasswordPlain

if ($mysqlExe -eq "mysql") {
    Get-Content $BackupPath | & $mysqlExe -h $mysqlHost -P $mysqlPort -u $mysqlUser $databaseName
} else {
    Get-Content $BackupPath | & $mysqlExe -h $mysqlHost -P $mysqlPort -u $mysqlUser $databaseName
}

$restoreResult = $LASTEXITCODE

# Limpiar variable de entorno
Remove-Item Env:\MYSQL_PWD -ErrorAction SilentlyContinue

if ($restoreResult -eq 0) {
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Green
    Write-Host "  RESPALDO RESTAURADO EXITOSAMENTE" -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Base de datos: $databaseName" -ForegroundColor Cyan
    Write-Host "Archivo restaurado: $BackupPath" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Próximos pasos:" -ForegroundColor Yellow
    Write-Host "1. Verifica que el archivo .env tenga la configuración correcta de DATABASE_URL" -ForegroundColor White
    Write-Host "2. Ejecuta: npx prisma generate" -ForegroundColor White
    Write-Host "3. Inicia el servidor: npm run dev" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "ERROR: Hubo un problema al restaurar el respaldo." -ForegroundColor Red
    Write-Host "Código de salida: $restoreResult" -ForegroundColor Red
    Write-Host ""
    Write-Host "Verifica:" -ForegroundColor Yellow
    Write-Host "- Que MySQL esté corriendo" -ForegroundColor White
    Write-Host "- Que las credenciales sean correctas" -ForegroundColor White
    Write-Host "- Que el archivo de respaldo no esté corrupto" -ForegroundColor White
    exit 1
}

