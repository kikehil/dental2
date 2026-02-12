@echo off
REM Script para subir backup de BD al VPS e importarlo
REM IP: 85.31.224.248

echo ================================================
echo SUBIR E IMPORTAR BACKUP AL VPS
echo IP: 85.31.224.248
echo ================================================
echo.

REM Configuración
set VPS_USER=root
set VPS_HOST=85.31.224.248
set VPS_PORT=22
set VPS_PATH=/var/www/html/dentali

REM Verificar que SCP esté disponible
where scp >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: SCP no está disponible
    pause
    exit /b 1
)

REM Buscar el backup más reciente
if not exist backups (
    echo ERROR: No existe la carpeta 'backups'
    echo Ejecuta primero: backup-db-local.bat
    pause
    exit /b 1
)

echo Buscando backup más reciente...
for /f "delims=" %%i in ('dir /b /o-d backups\db_backup_*.sql 2^>nul') do (
    set BACKUP_FILE=backups\%%i
    goto :found
)

echo ERROR: No se encontró ningún backup en la carpeta 'backups'
echo Ejecuta primero: backup-db-local.bat
pause
exit /b 1

:found
echo Backup encontrado: %BACKUP_FILE%
echo.

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

set /p continuar="¿Continuar con la subida e importación? (s/n): "
if /i not "%continuar%"=="s" (
    echo Operación cancelada.
    pause
    exit /b 1
)

echo.
echo ================================================
echo PASO 1: Subiendo backup al servidor...
echo ================================================
echo.

REM Crear directorio de backups en el servidor
ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "mkdir -p %VPS_PATH%/backups"

REM Copiar backup al servidor
echo Copiando %BACKUP_FILE% al servidor...
scp -P %VPS_PORT% "%BACKUP_FILE%" %VPS_USER%@%VPS_HOST%:%VPS_PATH%/backups/

if %errorlevel% neq 0 (
    echo ERROR: No se pudo copiar el backup
    pause
    exit /b 1
)

echo Backup copiado exitosamente
echo.

REM Obtener nombre del archivo sin ruta
for %%F in ("%BACKUP_FILE%") do set BACKUP_NAME=%%~nxF

echo.
echo ================================================
echo PASO 2: Importando backup en la base de datos...
echo ================================================
echo.

REM Leer configuración de BD del servidor
echo Configuración de base de datos en el servidor:
set /p VPS_DB_NAME="Nombre de la base de datos en el VPS (default: dentali): "
if "%VPS_DB_NAME%"=="" set VPS_DB_NAME=dentali

set /p VPS_DB_USER="Usuario MySQL en el VPS (default: root): "
if "%VPS_DB_USER%"=="" set VPS_DB_USER=root

set /p VPS_DB_PASS="Contraseña MySQL (dejar vacío si no tiene): "

echo.
echo IMPORTANTE: Esto reemplazará TODOS los datos de la base de datos '%VPS_DB_NAME%'
set /p confirmar="¿Estás seguro de continuar? (escribe 'SI' para confirmar): "
if /i not "%confirmar%"=="SI" (
    echo Operación cancelada.
    pause
    exit /b 1
)

echo.
echo Importando backup...
echo   Esto puede tardar varios minutos dependiendo del tamaño...
echo.

REM Importar backup
if "%VPS_DB_PASS%"=="" (
    ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "cd %VPS_PATH%/backups && mysql -u %VPS_DB_USER% %VPS_DB_NAME% < %BACKUP_NAME%"
) else (
    ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "cd %VPS_PATH%/backups && mysql -u %VPS_DB_USER% -p%VPS_DB_PASS% %VPS_DB_NAME% < %BACKUP_NAME%"
)

if %errorlevel% neq 0 (
    echo.
    echo ERROR: No se pudo importar el backup
    echo Verifica:
    echo   - Que la base de datos exista en el servidor
    echo   - Que las credenciales sean correctas
    echo   - Que MySQL esté corriendo en el servidor
    pause
    exit /b 1
)

echo.
echo ================================================
echo IMPORTACIÓN COMPLETADA EXITOSAMENTE
echo ================================================
echo.
echo El backup ha sido importado en la base de datos '%VPS_DB_NAME%'
echo.
echo Próximos pasos:
echo   1. Verifica que la aplicación funcione correctamente
echo   2. Reinicia la aplicación si es necesario:
echo      ssh %VPS_USER%@%VPS_HOST% "cd %VPS_PATH% && pm2 restart dentali"
echo.
pause

