@echo off
REM Script para crear backup de la base de datos local
REM Genera un archivo SQL con timestamp

echo ================================================
echo BACKUP DE BASE DE DATOS LOCAL
echo ================================================
echo.

REM Verificar que MySQL esté disponible
where mysql >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: MySQL no está disponible en el PATH
    echo.
    echo Buscando MySQL en ubicaciones comunes...
    if exist "C:\xampp\mysql\bin\mysql.exe" (
        set MYSQL_PATH=C:\xampp\mysql\bin
        set MYSQLDUMP_PATH=C:\xampp\mysql\bin\mysqldump.exe
        set MYSQL_EXE=C:\xampp\mysql\bin\mysql.exe
        echo MySQL encontrado en: %MYSQL_PATH%
    ) else if exist "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" (
        set MYSQL_PATH=C:\Program Files\MySQL\MySQL Server 8.0\bin
        set MYSQLDUMP_PATH=C:\Program Files\MySQL\MySQL Server 8.0\bin\mysqldump.exe
        set MYSQL_EXE=C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe
        echo MySQL encontrado en: %MYSQL_PATH%
    ) else (
        echo ERROR: No se encontró MySQL
        echo Por favor instala MySQL o agrega MySQL al PATH
        pause
        exit /b 1
    )
) else (
    set MYSQLDUMP_PATH=mysqldump
    set MYSQL_EXE=mysql
)

REM Leer configuración del .env si existe
set DB_NAME=clinica_dental
set DB_USER=root
set DB_PASS=
set DB_HOST=localhost
set DB_PORT=3306

if exist .env (
    echo Leyendo configuración de .env...
    for /f "tokens=2 delims==" %%a in ('findstr /C:"DATABASE_URL" .env') do (
        set DATABASE_URL=%%a
        set DATABASE_URL=!DATABASE_URL:"=!
    )
    
    REM Extraer información de DATABASE_URL
    REM Formato: mysql://usuario:password@host:puerto/nombre_bd
    for /f "tokens=2 delims=@" %%a in ("%DATABASE_URL%") do set DB_PART=%%a
    for /f "tokens=1 delims=/" %%a in ("%DB_PART%") do set DB_CRED=%%a
    for /f "tokens=2 delims=/" %%a in ("%DB_PART%") do set DB_NAME=%%a
    for /f "tokens=1 delims=:" %%a in ("%DB_CRED%") do set DB_USER=%%a
    for /f "tokens=2 delims=:" %%a in ("%DB_CRED%") do set DB_PASS=%%a
    for /f "tokens=1 delims=:" %%a in ("%DB_CRED%") do set DB_HOST_PORT=%%a
    for /f "tokens=2 delims=:" %%a in ("%DB_HOST_PORT%") do set DB_PORT=%%a
)

echo.
echo Configuración detectada:
echo   Base de datos: %DB_NAME%
echo   Usuario: %DB_USER%
echo   Host: %DB_HOST%
echo   Puerto: %DB_PORT%
echo.

REM Permitir modificar configuración
set /p confirmar="¿Usar esta configuración? (s/n): "
if /i not "%confirmar%"=="s" (
    set /p DB_NAME="Nombre de la base de datos: "
    set /p DB_USER="Usuario MySQL: "
    set /p DB_PASS="Contraseña MySQL (dejar vacío si no tiene): "
    set /p DB_HOST="Host (default localhost): "
    if "%DB_HOST%"=="" set DB_HOST=localhost
    set /p DB_PORT="Puerto (default 3306): "
    if "%DB_PORT%"=="" set DB_PORT=3306
)

REM Crear carpeta de backups si no existe
if not exist backups mkdir backups

REM Generar nombre de archivo con timestamp
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do set mydate=%%c-%%a-%%b
for /f "tokens=1-2 delims=: " %%a in ('time /t') do set mytime=%%a%%b
set mytime=%mytime: =0%
set BACKUP_FILE=backups\db_backup_%mydate%_%mytime%.sql

echo.
echo Creando backup...
echo   Archivo: %BACKUP_FILE%
echo.

REM Crear backup
if "%DB_PASS%"=="" (
    "%MYSQLDUMP_PATH%" -h %DB_HOST% -P %DB_PORT% -u %DB_USER% --single-transaction --routines --triggers %DB_NAME% > "%BACKUP_FILE%" 2>nul
) else (
    "%MYSQLDUMP_PATH%" -h %DB_HOST% -P %DB_PORT% -u %DB_USER% -p%DB_PASS% --single-transaction --routines --triggers %DB_NAME% > "%BACKUP_FILE%" 2>nul
)

if %errorlevel% neq 0 (
    echo.
    echo ERROR: No se pudo crear el backup
    echo Verifica:
    echo   - Que la base de datos exista
    echo   - Que las credenciales sean correctas
    echo   - Que MySQL esté corriendo
    pause
    exit /b 1
)

REM Verificar que el archivo se creó y tiene contenido
if not exist "%BACKUP_FILE%" (
    echo ERROR: El archivo de backup no se creó
    pause
    exit /b 1
)

for %%A in ("%BACKUP_FILE%") do set SIZE=%%~zA
if %SIZE% LSS 100 (
    echo ERROR: El archivo de backup está vacío o es muy pequeño
    pause
    exit /b 1
)

echo.
echo ================================================
echo BACKUP COMPLETADO EXITOSAMENTE
echo ================================================
echo.
echo Archivo: %BACKUP_FILE%
for %%A in ("%BACKUP_FILE%") do echo Tamaño: %%~zA bytes
echo.
echo El backup está listo para subir al VPS
echo.
pause




