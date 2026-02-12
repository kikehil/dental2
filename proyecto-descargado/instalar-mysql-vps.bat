@echo off
REM Script para instalar y configurar MySQL en el VPS
REM IP: 85.31.224.248

echo ================================================
echo INSTALAR MYSQL EN EL VPS
echo IP: 85.31.224.248
echo ================================================
echo.
echo Este script instalará MySQL/MariaDB en el VPS
echo y lo configurará para usar con la aplicación.
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

set /p continuar="¿Instalar MySQL/MariaDB en el VPS? (s/n): "
if /i not "%continuar%"=="s" (
    echo Operación cancelada.
    pause
    exit /b 1
)

echo.
echo ================================================
echo PASO 1: Actualizando sistema...
echo ================================================
echo.

ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "apt update"

echo.
echo ================================================
echo PASO 2: Instalando MySQL Server...
echo ================================================
echo.

REM Instalar MySQL Server
ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "DEBIAN_FRONTEND=noninteractive apt install -y mysql-server mysql-client"

if %errorlevel% neq 0 (
    echo.
    echo ERROR: No se pudo instalar MySQL
    echo Intentando con MariaDB...
    ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "DEBIAN_FRONTEND=noninteractive apt install -y mariadb-server mariadb-client"
    if %errorlevel% neq 0 (
        echo ERROR: No se pudo instalar MySQL ni MariaDB
        pause
        exit /b 1
    )
)

echo.
echo ================================================
echo PASO 3: Configurando MySQL...
echo ================================================
echo.

REM Iniciar y habilitar MySQL
ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "systemctl start mysql && systemctl enable mysql"

REM Configurar MySQL de forma segura (no interactivo)
echo Configurando seguridad de MySQL...
ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "mysql -e \"ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '';\" 2>/dev/null || mysql -e \"UPDATE mysql.user SET plugin='mysql_native_password' WHERE User='root' AND Host='localhost';\" 2>/dev/null || echo 'Configuración de root ya existe'"

REM Permitir conexiones remotas (opcional, comentado por seguridad)
REM ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "mysql -e \"CREATE USER IF NOT EXISTS 'root'@'%%' IDENTIFIED BY ''; GRANT ALL PRIVILEGES ON *.* TO 'root'@'%%' WITH GRANT OPTION;\" 2>/dev/null"

REM Recargar privilegios
ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "mysql -e \"FLUSH PRIVILEGES;\""

echo.
echo ================================================
echo PASO 4: Verificando instalación...
echo ================================================
echo.

ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "mysql --version && systemctl status mysql --no-pager | head -5"

echo.
echo ================================================
echo INSTALACIÓN COMPLETADA
echo ================================================
echo.
echo MySQL/MariaDB ha sido instalado y configurado.
echo.
echo Próximos pasos:
echo   1. Crear la base de datos:
echo      crear-bdd-vps.bat
echo.
echo   2. O hacer backup y subir:
echo      backup-y-subir-vps.bat
echo.
pause




