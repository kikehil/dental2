@echo off
REM Script de despliegue para NUEVO VPS (Windows)
REM IP: 85.31.224.248
REM Fecha: Enero 2026

echo ================================================
echo DESPLIEGUE AL NUEVO VPS
echo IP: 85.31.224.248
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
echo   Puerto: %VPS_PORT%
echo   Ruta: %VPS_PATH%
echo.

REM Verificar que SCP esté disponible (viene con OpenSSH en Windows)
where scp >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: SCP no está disponible
    echo Por favor instala OpenSSH o Git para Windows
    echo https://git-scm.com/download/win
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
echo Sincronizando archivos...
echo   (Esto puede tardar varios minutos...)
echo   NOTA: Se te pedirá la contraseña varias veces durante la copia
echo   Para evitar esto, configura claves SSH ejecutando: configurar-ssh-keys.bat
echo.
pause

REM Copiar archivos principales
echo Copiando archivos principales...
scp -P %VPS_PORT% package.json %VPS_USER%@%VPS_HOST%:%VPS_PATH%/
scp -P %VPS_PORT% package-lock.json %VPS_USER%@%VPS_HOST%:%VPS_PATH%/
scp -P %VPS_PORT% ecosystem.config.js %VPS_USER%@%VPS_HOST%:%VPS_PATH%/
scp -P %VPS_PORT% tailwind.config.js %VPS_USER%@%VPS_HOST%:%VPS_PATH%/
scp -P %VPS_PORT% schema.prisma %VPS_USER%@%VPS_HOST%:%VPS_PATH%/
if exist env.example.txt scp -P %VPS_PORT% env.example.txt %VPS_USER%@%VPS_HOST%:%VPS_PATH%/

REM Copiar carpetas principales
echo.
echo Copiando carpeta: src
scp -r -P %VPS_PORT% src %VPS_USER%@%VPS_HOST%:%VPS_PATH%/
echo Copiando carpeta: prisma
scp -r -P %VPS_PORT% prisma %VPS_USER%@%VPS_HOST%:%VPS_PATH%/
if exist scripts (
    echo Copiando carpeta: scripts
    scp -r -P %VPS_PORT% scripts %VPS_USER%@%VPS_HOST%:%VPS_PATH%/
)

echo Archivos sincronizados
echo.

echo Instalando dependencias en el servidor...
ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "cd %VPS_PATH% ; npm install --production"

echo Generando cliente de Prisma...
ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "cd %VPS_PATH% ; npx prisma generate --schema=prisma/schema.prisma"

echo Aplicando migraciones...
set /p aplicar_migraciones="¿Aplicar migraciones de base de datos? (s/n): "
if /i "%aplicar_migraciones%"=="s" (
    ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "cd %VPS_PATH% ; npx prisma db push --accept-data-loss"
)

echo Compilando CSS...
ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "cd %VPS_PATH% ; npm run build"

echo Iniciando aplicación con PM2...
ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "cd %VPS_PATH% ; pm2 stop dentali 2>/dev/null || echo 'Aplicacion no estaba corriendo' ; pm2 start ecosystem.config.js --name dentali ; pm2 save"

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


