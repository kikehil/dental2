@echo off
REM Script para subir cambios del módulo de préstamos al VPS
REM Archivo modificado: src/views/gastos/prestamos.ejs

echo ================================================
echo SUBIR CAMBIOS - MÓDULO DE PRÉSTAMOS
echo ================================================
echo.

REM Configuración
set VPS_USER=root
set VPS_HOST=85.31.224.248
set VPS_PORT=22
set VPS_PATH=/var/www/html/dentali

echo Configuración:
echo   Usuario: %VPS_USER%
echo   Host: %VPS_HOST%
echo   Ruta: %VPS_PATH%
echo.

REM Verificar conexión
echo Verificando conexión SSH...
ssh -p %VPS_PORT% -o ConnectTimeout=10 %VPS_USER%@%VPS_HOST% "echo Conexion exitosa" >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: No se puede conectar al servidor SSH
    pause
    exit /b 1
)
echo Conexión SSH verificada
echo.

set /p continuar="¿Continuar con la subida? (s/n): "
if /i not "%continuar%"=="s" (
    echo Operación cancelada.
    pause
    exit /b 1
)

echo.
echo Subiendo archivo modificado...
echo   Archivo: src/views/gastos/prestamos.ejs
scp -P %VPS_PORT% src\views\gastos\prestamos.ejs %VPS_USER%@%VPS_HOST%:%VPS_PATH%/src/views/gastos/prestamos.ejs

if %errorlevel% neq 0 (
    echo ERROR: No se pudo subir el archivo
    pause
    exit /b 1
)

echo.
echo Archivo subido exitosamente
echo.

echo Reiniciando aplicación con PM2...
ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "cd %VPS_PATH% ; pm2 restart dentali"

if %errorlevel% neq 0 (
    echo ADVERTENCIA: No se pudo reiniciar PM2 automáticamente
    echo Reinicia manualmente con: ssh %VPS_USER%@%VPS_HOST% "cd %VPS_PATH% ; pm2 restart dentali"
) else (
    echo Aplicación reiniciada exitosamente
)

echo.
echo ================================================
echo CAMBIOS SUBIDOS Y APLICADOS
echo ================================================
echo.
echo El archivo prestamos.ejs ha sido actualizado en el VPS
echo La aplicación ha sido reiniciada
echo.
pause

