# Script para restaurar respaldo de base de datos MySQL
# Uso: .\restaurar-respaldo.ps1 -BackupPath "ruta\al\respaldo.sql" -Database "nombre_db" -User "usuario" -Password "password"

param(
    [Parameter(Mandatory=$true)]
    [string]$BackupPath,
    
    [Parameter(Mandatory=$false)]
    [string]$Database = "clinica_dental",
    
    [Parameter(Mandatory=$false)]
    [string]$User = "root",
    
    [Parameter(Mandatory=$false)]
    [string]$Password = "",
    
    [Parameter(Mandatory=$false)]
    [string]$Host = "localhost",
    
    [Parameter(Mandatory=$false)]
    [int]$Port = 3306
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

Write-Host "Archivo de respaldo: $BackupPath" -ForegroundColor Green
Write-Host "Base de datos: $Database" -ForegroundColor Green
Write-Host "Usuario: $User" -ForegroundColor Green
Write-Host ""

# Buscar MySQL en rutas comunes
$mysqlPaths = @(
    "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe",
    "C:\Program Files\MySQL\MySQL Server 8.1\bin\mysql.exe",
    "C:\Program Files\MySQL\MySQL Server 8.2\bin\mysql.exe",
    "C:\Program Files (x86)\MySQL\MySQL Server 8.0\bin\mysql.exe",
    "C:\xampp\mysql\bin\mysql.exe",
    "C:\wamp64\bin\mysql\mysql8.0.xx\bin\mysql.exe"
)

$mysqlExe = $null
foreach ($path in $mysqlPaths) {
    if (Test-Path $path) {
        $mysqlExe = $path
        Write-Host "MySQL encontrado en: $mysqlExe" -ForegroundColor Green
        break
    }
}

# Si no se encuentra en rutas comunes, intentar desde PATH
if (-not $mysqlExe) {
    try {
        $mysqlExe = (Get-Command mysql -ErrorAction Stop).Source
        Write-Host "MySQL encontrado en PATH: $mysqlExe" -ForegroundColor Green
    } catch {
        Write-Host "ERROR: No se pudo encontrar MySQL." -ForegroundColor Red
        Write-Host "Por favor, proporciona la ruta completa a mysql.exe:" -ForegroundColor Yellow
        $mysqlExe = Read-Host "Ruta a mysql.exe"
        
        if (-not (Test-Path $mysqlExe)) {
            Write-Host "ERROR: La ruta proporcionada no existe: $mysqlExe" -ForegroundColor Red
            exit 1
        }
    }
}

# Si no se proporcionó contraseña, pedirla
if ([string]::IsNullOrEmpty($Password)) {
    Write-Host "Ingresa la contraseña de MySQL para el usuario '$User':" -ForegroundColor Yellow
    $securePassword = Read-Host -AsSecureString
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
    $Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
}

Write-Host ""
Write-Host "Restaurando respaldo..." -ForegroundColor Yellow

try {
    # Configurar proceso para MySQL
    $processInfo = New-Object System.Diagnostics.ProcessStartInfo
    $processInfo.FileName = $mysqlExe
    $processInfo.Arguments = "-h $Host -P $Port -u $User -p$Password $Database"
    $processInfo.UseShellExecute = $false
    $processInfo.RedirectStandardInput = $true
    $processInfo.RedirectStandardOutput = $true
    $processInfo.RedirectStandardError = $true
    $processInfo.CreateNoWindow = $true
    
    $process = New-Object System.Diagnostics.Process
    $process.StartInfo = $processInfo
    
    # Iniciar proceso
    $process.Start() | Out-Null
    
    # Leer y enviar el contenido del archivo SQL
    $sqlContent = Get-Content $BackupPath -Raw -Encoding UTF8
    $process.StandardInput.Write($sqlContent)
    $process.StandardInput.Close()
    
    # Leer salida
    $output = $process.StandardOutput.ReadToEnd()
    $errorOutput = $process.StandardError.ReadToEnd()
    
    # Esperar a que termine
    $process.WaitForExit()
    
    if ($process.ExitCode -eq 0) {
        Write-Host ""
        Write-Host "================================================" -ForegroundColor Green
        Write-Host "  RESPALDO RESTAURADO EXITOSAMENTE" -ForegroundColor Green
        Write-Host "================================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "Base de datos '$Database' restaurada desde:" -ForegroundColor Green
        Write-Host "$BackupPath" -ForegroundColor Cyan
        Write-Host ""
    } else {
        Write-Host ""
        Write-Host "ERROR al restaurar el respaldo:" -ForegroundColor Red
        if ($errorOutput) {
            Write-Host $errorOutput -ForegroundColor Red
        }
        if ($output) {
            Write-Host $output -ForegroundColor Yellow
        }
        exit 1
    }
} catch {
    Write-Host ""
    Write-Host "ERROR al ejecutar MySQL:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

Write-Host "¡Listo! Puedes verificar la base de datos con:" -ForegroundColor Yellow
Write-Host "  npx prisma studio" -ForegroundColor Cyan
Write-Host ""

