@echo off
REM Script completo: Backup local + Subir e importar al VPS
REM IP: 85.31.224.248

echo ================================================
echo BACKUP Y DESPLIEGUE DE BASE DE DATOS AL VPS
echo IP: 85.31.224.248
echo ================================================
echo.
echo Este script:
echo   1. Creará un backup de tu base de datos local
echo   2. Creará la base de datos en el VPS (si no existe)
echo   3. Subirá el backup al VPS
echo   4. Lo importará en la base de datos del VPS
echo.
pause

REM Paso 1: Crear backup local
echo.
echo ================================================
echo PASO 1: Creando backup local...
echo ================================================
call backup-db-local.bat
if %errorlevel% neq 0 (
    echo ERROR: Falló la creación del backup local
    pause
    exit /b 1
)

REM Paso 2: Crear BD en VPS (si no existe)
echo.
echo ================================================
echo PASO 2: Verificando/Creando base de datos en el VPS...
echo ================================================
set /p crear_bd="¿Crear la base de datos en el VPS ahora? (s/n): "
if /i "%crear_bd%"=="s" (
    call crear-bdd-vps.bat
    if %errorlevel% neq 0 (
        echo ADVERTENCIA: No se pudo crear la base de datos
        echo Continuando de todas formas...
    )
)

REM Paso 3: Subir e importar
echo.
echo ================================================
echo PASO 3: Subiendo e importando al VPS...
echo ================================================
call subir-backup-vps.bat
if %errorlevel% neq 0 (
    echo ERROR: Falló la subida o importación al VPS
    pause
    exit /b 1
)

echo.
echo ================================================
echo PROCESO COMPLETADO
echo ================================================
echo.
echo La base de datos ha sido respaldada y desplegada
echo exitosamente en el VPS.
echo.
pause

