@echo off
REM Script para actualizar contraseñas de usuarios en el VPS
REM IP: 85.31.224.248

echo ================================================
echo ACTUALIZAR CONTRASEÑAS DE USUARIOS EN EL VPS
echo IP: 85.31.224.248
echo ================================================
echo.
echo Este script actualizará las contraseñas de los
echo usuarios para que puedas iniciar sesión.
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

set /p continuar="¿Actualizar contraseñas de usuarios en el VPS? (s/n): "
if /i not "%continuar%"=="s" (
    echo Operación cancelada.
    pause
    exit /b 1
)

echo.
echo ================================================
echo PASO 1: Copiando script al VPS...
echo ================================================
echo.

REM Copiar el script al VPS
scp -P %VPS_PORT% actualizar-contrasenas-vps.js %VPS_USER%@%VPS_HOST%:%VPS_PATH%/

if %errorlevel% neq 0 (
    echo ERROR: No se pudo copiar el script
    pause
    exit /b 1
)

echo Script copiado exitosamente
echo.

echo ================================================
echo PASO 2: Verificando archivo .env...
echo ================================================
echo.

REM Verificar que el archivo .env existe
ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "test -f %VPS_PATH%/.env && echo 'Archivo .env encontrado' || echo 'ERROR: Archivo .env no encontrado'"

echo.
echo ================================================
echo PASO 3: Ejecutando script en el VPS...
echo ================================================
echo.

REM Ejecutar el script en el VPS
ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "cd %VPS_PATH% && node actualizar-contrasenas-vps.js"

if %errorlevel% neq 0 (
    echo.
    echo ERROR: No se pudo ejecutar el script
    echo Verifica:
    echo   - Que Node.js esté instalado en el VPS
    echo   - Que las dependencias estén instaladas (npm install)
    echo   - Que Prisma esté configurado correctamente
    pause
    exit /b 1
)

echo.
echo ================================================
echo ACTUALIZACIÓN COMPLETADA
echo ================================================
echo.
echo Las contraseñas han sido actualizadas.
echo.
echo Credenciales de acceso:
echo ------------------------
echo Admin:
echo   Email: admin@clinica.com
echo   Contraseña: admin123
echo.
echo Doctor:
echo   Email: doctor@clinica.com
echo   Contraseña: doctor123
echo.
echo Recepcionista:
echo   Email: recepcion@clinica.com
echo   Contraseña: recepcion123
echo.
pause

