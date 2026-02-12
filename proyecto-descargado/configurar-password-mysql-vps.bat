@echo off
REM Script para configurar contraseña del usuario root de MySQL en el VPS
REM IP: 85.31.224.248

echo ================================================
echo CONFIGURAR CONTRASEÑA DE MYSQL ROOT EN EL VPS
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

echo Primero, intentemos conectar sin contraseña para verificar...
ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "mysql -u root -e 'SELECT \"Conexion exitosa\" AS resultado;' 2>&1"
if %errorlevel% neq 0 (
    echo.
    echo ERROR: No se puede conectar a MySQL sin contraseña
    echo Puede que MySQL no esté instalado o necesite configuración
    pause
    exit /b 1
)

echo.
echo Conexión exitosa. Ahora configuraremos la contraseña.
echo.

set /p nueva_password="Ingresa la nueva contraseña para MySQL root: "
if "%nueva_password%"=="" (
    echo ERROR: La contraseña no puede estar vacía
    pause
    exit /b 1
)

set /p confirmar_password="Confirma la contraseña: "
if not "%nueva_password%"=="%confirmar_password%" (
    echo ERROR: Las contraseñas no coinciden
    pause
    exit /b 1
)

echo.
set /p continuar="¿Configurar la contraseña '%nueva_password%' para MySQL root? (s/n): "
if /i not "%continuar%"=="s" (
    echo Operación cancelada.
    pause
    exit /b 1
)

echo.
echo ================================================
echo Configurando contraseña de MySQL root...
echo ================================================
echo.

REM Configurar contraseña usando un archivo temporal SQL (más seguro para caracteres especiales)
echo Configurando contraseña...
REM Crear script SQL temporal en el servidor
ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "echo \"ALTER USER 'root'@'localhost' IDENTIFIED BY '%nueva_password%';\" > /tmp/set_password.sql && echo \"FLUSH PRIVILEGES;\" >> /tmp/set_password.sql"

REM Ejecutar el script SQL
ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "mysql -u root < /tmp/set_password.sql 2>&1 && rm /tmp/set_password.sql"

if %errorlevel% neq 0 (
    echo.
    echo Advertencia: ALTER USER falló, intentando método alternativo...
    REM Método alternativo: usar mysqladmin
    ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "mysqladmin -u root password '%nueva_password%' 2>&1"
    
    if %errorlevel% neq 0 (
        echo.
        echo ERROR: No se pudo configurar la contraseña
        echo Intenta usar el script de reseteo: resetear-password-mysql-vps.bat
        pause
        exit /b 1
    )
)

echo.
echo Verificando nueva contraseña...
REM Crear script de verificación
ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "echo \"SELECT 'Contrasena configurada correctamente' AS resultado;\" > /tmp/verify_password.sql"
ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "mysql -u root -p'%nueva_password%' < /tmp/verify_password.sql 2>&1 && rm /tmp/verify_password.sql"

if %errorlevel% neq 0 (
    echo.
    echo ERROR: No se pudo verificar la contraseña
    echo La contraseña puede no haberse configurado correctamente
    pause
    exit /b 1
)

echo.
echo ================================================
echo CONTRASEÑA CONFIGURADA EXITOSAMENTE
echo ================================================
echo.
echo La contraseña para MySQL root ha sido configurada.
echo.
echo IMPORTANTE: Guarda esta información:
echo   Usuario: root
echo   Contraseña: %nueva_password%
echo.
echo Próximos pasos:
echo   1. Actualiza tu archivo .env en el VPS con esta contraseña
echo   2. Ahora puedes crear la base de datos:
echo      crear-bdd-vps.bat
echo.
pause

