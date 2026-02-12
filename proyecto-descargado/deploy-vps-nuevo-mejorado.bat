@echo off
REM Script de despliegue MEJORADO - Empaqueta todo en un archivo
REM IP: 85.31.224.248
REM Esto reduce las peticiones de contraseña a solo 1-2 veces

echo ================================================
echo DESPLIEGUE AL NUEVO VPS (VERSION MEJORADA)
echo IP: 85.31.224.248
echo ================================================
echo.
echo Esta versión empaqueta todo en un archivo para
echo reducir las peticiones de contraseña.
echo.

REM Configuración
set VPS_USER=root
set VPS_HOST=85.31.224.248
set VPS_PORT=22
set VPS_PATH=/var/www/html/dentali
set TEMP_PACKAGE=deploy-temp.tar.gz

echo Configuración:
echo   Usuario: %VPS_USER%
echo   Host: %VPS_HOST%
echo   Puerto: %VPS_PORT%
echo   Ruta: %VPS_PATH%
echo.

REM Verificar que SCP esté disponible
where scp >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: SCP no está disponible
    echo Por favor instala OpenSSH o Git para Windows
    pause
    exit /b 1
)

REM Verificar que PowerShell esté disponible
powershell -Command "exit 0" >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: PowerShell no está disponible
    pause
    exit /b 1
)

echo Verificando conexión SSH...
ssh -p %VPS_PORT% -o ConnectTimeout=10 %VPS_USER%@%VPS_HOST% "echo Conexion exitosa" >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: No se puede conectar al servidor SSH
    echo Verifica: usuario, IP, puerto y que el servidor esté accesible
    pause
    exit /b 1
)
echo Conexión SSH verificada
echo.

set /p continuar="¿Continuar con el despliegue? (s/n): "
if /i not "%continuar%"=="s" (
    echo Despliegue cancelado.
    pause
    exit /b 1
)

echo.
echo ================================================
echo PASO 1: Empaquetando archivos...
echo ================================================
echo.

REM Limpiar archivo temporal anterior si existe
if exist %TEMP_PACKAGE% del %TEMP_PACKAGE%

REM Crear archivo tar.gz usando tar (disponible en Windows 10+)
echo Creando paquete de despliegue (tar.gz)...
REM Usar PowerShell para construir lista de archivos existentes y crear tar.gz
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$files = @('package.json', 'package-lock.json', 'ecosystem.config.js', 'tailwind.config.js', 'schema.prisma', 'src', 'prisma');" ^
    "if (Test-Path 'env.example.txt') { $files += 'env.example.txt' };" ^
    "if (Test-Path 'scripts') { $files += 'scripts' };" ^
    "$existing = $files | Where-Object { Test-Path $_ };" ^
    "if ($existing.Count -eq 0) { Write-Error 'No se encontraron archivos para empaquetar'; exit 1 };" ^
    "& tar -czf '%TEMP_PACKAGE%' $existing;" ^
    "if ($LASTEXITCODE -ne 0) { Write-Error 'Error al crear tar.gz'; exit 1 };" ^
    "Write-Host 'Paquete creado: %TEMP_PACKAGE%'"

if not exist %TEMP_PACKAGE% (
    echo ERROR: No se pudo crear el paquete
    pause
    exit /b 1
)

echo.
echo ================================================
echo PASO 2: Copiando paquete al servidor...
echo ================================================
echo.
echo NOTA: Se te pedirá la contraseña UNA VEZ aquí
echo.

REM Crear directorio en el servidor si no existe
ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "mkdir -p %VPS_PATH%"

REM Copiar el paquete (solo una petición de contraseña)
echo Copiando %TEMP_PACKAGE% al servidor...
scp -P %VPS_PORT% %TEMP_PACKAGE% %VPS_USER%@%VPS_HOST%:%VPS_PATH%/

if %errorlevel% neq 0 (
    echo ERROR: No se pudo copiar el paquete
    if exist %TEMP_PACKAGE% del %TEMP_PACKAGE%
    pause
    exit /b 1
)

echo.
echo ================================================
echo PASO 3: Extrayendo y configurando en el servidor...
echo ================================================
echo.

REM Extraer y configurar en el servidor
echo Extrayendo archivos...
ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "cd %VPS_PATH% && tar -xzf %TEMP_PACKAGE% && rm -f %TEMP_PACKAGE%"

if %errorlevel% neq 0 (
    echo ERROR: No se pudo extraer el paquete en el servidor
    echo Verifica que 'tar' esté disponible en el servidor
    pause
    exit /b 1
)

echo.
echo Instalando dependencias...
ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "cd %VPS_PATH% && npm install --production"

echo.
echo Generando cliente de Prisma...
ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "cd %VPS_PATH% && npx prisma generate --schema=prisma/schema.prisma"

echo.
echo Aplicando migraciones...
set /p aplicar_migraciones="¿Aplicar migraciones de base de datos? (s/n): "
if /i "%aplicar_migraciones%"=="s" (
    ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "cd %VPS_PATH% && npx prisma db push --accept-data-loss"
)

echo.
echo Compilando CSS...
ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "cd %VPS_PATH% && npm run build"

echo.
echo Iniciando aplicación con PM2...
ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "cd %VPS_PATH% && pm2 stop dentali 2>/dev/null || true && pm2 start ecosystem.config.js --name dentali && pm2 save"

REM Limpiar archivo temporal local
if exist %TEMP_PACKAGE% del %TEMP_PACKAGE%

echo.
echo ================================================
echo DESPLIEGUE COMPLETADO
echo ================================================
echo.
echo Próximos pasos:
echo   1. Verifica que la aplicación esté corriendo:
echo      ssh %VPS_USER%@%VPS_HOST% "pm2 status"
echo.
echo   2. Verifica los logs:
echo      ssh %VPS_USER%@%VPS_HOST% "pm2 logs dentali"
echo.
echo   3. Accede a: http://%VPS_HOST%:3005
echo.
pause

