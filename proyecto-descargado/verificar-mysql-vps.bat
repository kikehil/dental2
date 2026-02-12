@echo off
REM Script para verificar el estado de MySQL en el VPS
REM IP: 85.31.224.248

echo ================================================
echo VERIFICAR ESTADO DE MYSQL EN EL VPS
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

echo ================================================
echo Información de MySQL
echo ================================================
echo.

echo 1. Versión de MySQL:
ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "mysql --version 2>&1 || echo 'MySQL no está instalado'"

echo.
echo 2. Estado del servicio:
ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "systemctl status mysql --no-pager 2>&1 | head -10 || echo 'Servicio MySQL no encontrado'"

echo.
echo 3. Intentando conectar sin contraseña:
ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "mysql -u root -e 'SELECT \"Conexion exitosa sin contraseña\" AS resultado;' 2>&1"

echo.
echo 4. Bases de datos existentes:
ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "mysql -u root -e 'SHOW DATABASES;' 2>&1 || echo 'No se pudo conectar a MySQL'"

echo.
echo ================================================
echo Verificación completada
echo ================================================
echo.
pause




