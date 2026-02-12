@echo off
REM Script para configurar archivo .env en el VPS
REM IP: 85.31.224.248

echo ================================================
echo CONFIGURAR ARCHIVO .ENV EN EL VPS
echo IP: 85.31.224.248
echo ================================================
echo.

REM Configuración
set VPS_USER=root
set VPS_HOST=85.31.224.248
set VPS_PORT=22
set VPS_PATH=/var/www/html/dentali

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

REM Leer configuración local si existe
set DB_NAME=clinica_dental
set DB_USER=root
set DB_PASS=Netbios85*
set DB_HOST=localhost
set DB_PORT=3306

if exist .env (
    echo Leyendo configuración de .env local...
    for /f "tokens=2 delims==" %%a in ('findstr /C:"DATABASE_URL" .env') do (
        set DATABASE_URL=%%a
        set DATABASE_URL=!DATABASE_URL:"=!
    )
    
    REM Extraer información de DATABASE_URL
    for /f "tokens=2 delims=@" %%a in ("%DATABASE_URL%") do set DB_PART=%%a
    for /f "tokens=2 delims=/" %%a in ("%DB_PART%") do set DB_NAME=%%a
    for /f "tokens=1 delims=:" %%a in ("%DB_PART%") do set DB_CRED=%%a
    for /f "tokens=1 delims=:" %%a in ("%DB_CRED%") do set DB_USER=%%a
    for /f "tokens=2 delims=:" %%a in ("%DB_CRED%") do set DB_PASS=%%a
)

echo.
echo Configuración detectada:
echo   Base de datos: %DB_NAME%
echo   Usuario: %DB_USER%
echo   Host: %DB_HOST%
echo   Puerto: %DB_PORT%
echo.

REM Permitir modificar
set /p usar_detectado="¿Usar esta configuración para el VPS? (s/n): "
if /i not "%usar_detectado%"=="s" (
    set /p DB_NAME="Nombre de la base de datos: "
    set /p DB_USER="Usuario MySQL: "
    set /p DB_PASS="Contraseña MySQL: "
    set /p DB_HOST="Host (default localhost): "
    if "%DB_HOST%"=="" set DB_HOST=localhost
    set /p DB_PORT="Puerto (default 3306): "
    if "%DB_PORT%"=="" set DB_PORT=3306
)

REM Construir DATABASE_URL
set DATABASE_URL=mysql://%DB_USER%:%DB_PASS%@%DB_HOST%:%DB_PORT%/%DB_NAME%

echo.
echo Configuración para el VPS:
echo   DATABASE_URL: %DATABASE_URL%
echo.

set /p continuar="¿Crear archivo .env en el VPS con esta configuración? (s/n): "
if /i not "%continuar%"=="s" (
    echo Operación cancelada.
    pause
    exit /b 1
)

echo.
echo ================================================
echo Creando archivo .env en el VPS...
echo ================================================
echo.

REM Crear archivo temporal local
set TEMP_ENV=temp_env_vps.txt

echo PORT=3005 > %TEMP_ENV%
echo NODE_ENV=production >> %TEMP_ENV%
echo. >> %TEMP_ENV%
echo DATABASE_URL="%DATABASE_URL%" >> %TEMP_ENV%
echo. >> %TEMP_ENV%
echo SESSION_SECRET=tu_secret_key_muy_segura_aqui_cambiar_en_produccion >> %TEMP_ENV%
echo USE_SECURE_COOKIES=false >> %TEMP_ENV%
echo TZ=America/Mexico_City >> %TEMP_ENV%

REM Copiar archivo al VPS
echo Copiando archivo .env al VPS...
scp -P %VPS_PORT% %TEMP_ENV% %VPS_USER%@%VPS_HOST%:%VPS_PATH%/.env

REM Limpiar archivo temporal
if exist %TEMP_ENV% del %TEMP_ENV%

if %errorlevel% neq 0 (
    echo ERROR: No se pudo copiar el archivo .env
    pause
    exit /b 1
)

echo.
echo Verificando archivo .env creado...
ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "cat %VPS_PATH%/.env"

echo.
echo ================================================
echo ARCHIVO .ENV CREADO EXITOSAMENTE
echo ================================================
echo.
echo El archivo .env ha sido creado en el VPS.
echo.
echo IMPORTANTE: 
echo   - Verifica que la configuración sea correcta
echo   - Cambia SESSION_SECRET por una clave segura
echo.
echo Próximos pasos:
echo   1. Actualizar contraseñas de usuarios:
echo      actualizar-contrasenas-vps.bat
echo.
pause

