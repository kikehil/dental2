@echo off
setlocal enabledelayedexpansion
REM Script para crear la base de datos en el VPS
REM IP: 85.31.224.248

echo ================================================
echo CREAR BASE DE DATOS EN EL VPS
echo IP: 85.31.224.248
echo ================================================
echo.

REM Configuración
set VPS_USER=root
set VPS_HOST=85.31.224.248
set VPS_PORT=22

REM Verificar conexión SSH
echo Verificando conexión SSH...
ssh -p %VPS_PORT% -o ConnectTimeout=10 %VPS_USER%@%VPS_HOST% "echo Conexion exitosa" >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: No se puede conectar al servidor SSH
    pause
    exit /b 1
)
echo Conexión SSH verificada
echo.

REM Intentar detectar nombre de BD local
set DB_NAME=clinica_dental
set DB_USER=root
set DB_PASS=

if exist .env (
    echo Leyendo configuración de .env local...
    for /f "tokens=2 delims==" %%a in ('findstr /C:"DATABASE_URL" .env') do (
        set DATABASE_URL=%%a
        set DATABASE_URL=!DATABASE_URL:"=!
    )
    
    REM Extraer información de DATABASE_URL
    REM Formato: mysql://usuario:password@host:puerto/nombre_bd
    for /f "tokens=2 delims=@" %%a in ("%DATABASE_URL%") do set DB_PART=%%a
    for /f "tokens=2 delims=/" %%a in ("%DB_PART%") do set DB_NAME=%%a
    for /f "tokens=1 delims=:" %%a in ("%DB_PART%") do set DB_CRED=%%a
    for /f "tokens=1 delims=:" %%a in ("%DB_CRED%") do set DB_USER=%%a
    for /f "tokens=2 delims=:" %%a in ("%DB_CRED%") do set DB_PASS=%%a
)

echo.
echo Configuración detectada desde .env local:
echo   Nombre de BD: %DB_NAME%
echo   Usuario MySQL: %DB_USER%
echo.

REM Permitir modificar
set /p usar_detectado="¿Usar esta configuración? (s/n): "
if /i not "%usar_detectado%"=="s" (
    set /p DB_NAME="Nombre de la base de datos a crear: "
    set /p DB_USER="Usuario MySQL en el VPS: "
)

echo.
echo Configuración para el VPS:
echo   Base de datos: %DB_NAME%
echo   Usuario MySQL: %DB_USER%
echo.

set /p VPS_DB_PASS="Contraseña del usuario MySQL '%DB_USER%' en el VPS (dejar vacío si no tiene): "

echo.
set /p continuar="¿Crear la base de datos '%DB_NAME%' en el VPS? (s/n): "
if /i not "%continuar%"=="s" (
    echo Operación cancelada.
    pause
    exit /b 1
)

echo.
echo ================================================
echo Creando base de datos en el VPS...
echo ================================================
echo.

REM Ejecutar comandos SQL directamente
echo Ejecutando comandos SQL...
echo Intentando conectar a MySQL...

REM Intentar primero sin contraseña
if "%VPS_DB_PASS%"=="" (
    ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "mysql -u %DB_USER% -e \"CREATE DATABASE IF NOT EXISTS %DB_NAME% CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;\" 2>&1"
    set MYSQL_ERROR=%errorlevel%
) else (
    REM Intentar con contraseña usando --password= en lugar de -p
    ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "mysql -u %DB_USER% --password='%VPS_DB_PASS%' -e \"CREATE DATABASE IF NOT EXISTS %DB_NAME% CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;\" 2>&1"
    set MYSQL_ERROR=%errorlevel%
    
    REM Si falla, intentar sin contraseña (puede que no tenga contraseña configurada)
    if %MYSQL_ERROR% neq 0 (
        echo.
        echo Advertencia: Falló con contraseña, intentando sin contraseña...
        ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "mysql -u %DB_USER% -e \"CREATE DATABASE IF NOT EXISTS %DB_NAME% CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;\" 2>&1"
        set MYSQL_ERROR=%errorlevel%
    )
)

if %MYSQL_ERROR% neq 0 (
    echo.
    echo ERROR: No se pudo crear la base de datos
    echo.
    echo Posibles soluciones:
    echo   1. Verifica que MySQL esté instalado y corriendo:
    echo      ssh %VPS_USER%@%VPS_HOST% "systemctl status mysql"
    echo.
    echo   2. Intenta conectarte manualmente:
    echo      ssh %VPS_USER%@%VPS_HOST% "mysql -u root"
    echo.
    echo   3. Si necesitas resetear la contraseña de root, ejecuta:
    echo      resetear-password-mysql-vps.bat
    echo.
    pause
    exit /b 1
)

echo.
echo ================================================
echo BASE DE DATOS CREADA EXITOSAMENTE
echo ================================================
echo.
echo Base de datos '%DB_NAME%' creada en el VPS
echo.
echo Próximos pasos:
echo   1. Verifica que la base de datos existe:
echo      ssh %VPS_USER%@%VPS_HOST% "mysql -u %DB_USER% -e 'SHOW DATABASES;'"
echo.
echo   2. Ahora puedes importar el backup:
echo      subir-backup-vps.bat
echo.
pause

