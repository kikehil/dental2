@echo off
REM Script alternativo para actualizar contraseñas usando MySQL directamente
REM IP: 85.31.224.248

echo ================================================
echo ACTUALIZAR CONTRASEÑAS (MÉTODO ALTERNATIVO)
echo IP: 85.31.224.248
echo ================================================
echo.
echo Este script usa MySQL directamente en lugar
echo de Prisma para evitar problemas de conexión.
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
scp -P %VPS_PORT% actualizar-contrasenas-vps-mysql.js %VPS_USER%@%VPS_HOST%:%VPS_PATH%/

if %errorlevel% neq 0 (
    echo ERROR: No se pudo copiar el script
    pause
    exit /b 1
)

echo Script copiado exitosamente
echo.

REM Verificar que mysql2 esté instalado
echo Verificando dependencias...
ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "cd %VPS_PATH% && npm list mysql2 2>/dev/null || echo 'mysql2 no encontrado, instalando...' && npm install mysql2"

echo.
echo ================================================
echo PASO 2: Ejecutando script en el VPS...
echo ================================================
echo.

REM Ejecutar el script en el VPS
ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "cd %VPS_PATH% && node actualizar-contrasenas-vps-mysql.js"

if %errorlevel% neq 0 (
    echo.
    echo ERROR: No se pudo ejecutar el script
    echo Verifica:
    echo   - Que Node.js esté instalado en el VPS
    echo   - Que las credenciales de MySQL sean correctas
    echo   - Que la base de datos 'clinica_dental' exista
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
pause




