@echo off
REM Script para arreglar MySQL en el VPS
REM IP: 85.31.224.248

echo ================================================
echo ARREGLAR MYSQL EN EL VPS
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
echo PASO 1: Creando directorio necesario...
echo ================================================
echo.

ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "mkdir -p /var/run/mysqld && chown mysql:mysql /var/run/mysqld"

echo.
echo ================================================
echo PASO 2: Iniciando MySQL normalmente...
echo ================================================
echo.

ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "systemctl start mysql"

echo Esperando 5 segundos para que MySQL inicie...
timeout /t 5 /nobreak >nul

echo.
echo ================================================
echo PASO 3: Verificando estado de MySQL...
echo ================================================
echo.

ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "systemctl status mysql --no-pager | head -10"

echo.
echo ================================================
echo PASO 4: Intentando conectar a MySQL...
echo ================================================
echo.

echo Intentando sin contraseña...
ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "mysql -u root -e 'SELECT \"Conexion exitosa sin contrasena\" AS resultado;' 2>&1"

if %errorlevel% equ 0 (
    echo.
    echo ================================================
    echo MySQL está funcionando SIN contraseña
    echo ================================================
    echo.
    echo Ahora puedes:
    echo   1. Configurar una contraseña: configurar-password-mysql-vps.bat
    echo   2. Crear la base de datos: crear-bdd-vps.bat
    echo.
) else (
    echo.
    echo MySQL requiere contraseña. Intentando resetear...
    echo.
    echo ================================================
    echo PASO 5: Reseteando contraseña de MySQL...
    echo ================================================
    echo.
    
    set /p nueva_password="Ingresa la nueva contraseña para MySQL root (dejar vacío para sin contraseña): "
    
    REM Detener MySQL
    echo Deteniendo MySQL...
    ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "systemctl stop mysql"
    
    REM Iniciar en modo seguro
    echo Iniciando MySQL en modo seguro...
    ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "mysqld_safe --skip-grant-tables --skip-networking --user=mysql &"
    
    echo Esperando 5 segundos...
    timeout /t 5 /nobreak >nul
    
    REM Resetear contraseña
    if "%nueva_password%"=="" (
        echo Configurando MySQL root sin contraseña...
        ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "mysql -u root -e \"USE mysql; UPDATE user SET authentication_string='', plugin='mysql_native_password' WHERE User='root' AND Host='localhost'; FLUSH PRIVILEGES;\" 2>&1"
    ) else (
        echo Configurando MySQL root con contraseña...
        ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "mysql -u root -e \"USE mysql; ALTER USER 'root'@'localhost' IDENTIFIED BY '%nueva_password%'; FLUSH PRIVILEGES;\" 2>&1"
    )
    
    REM Detener MySQL en modo seguro
    echo Deteniendo MySQL en modo seguro...
    ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "pkill mysqld"
    
    echo Esperando 3 segundos...
    timeout /t 3 /nobreak >nul
    
    REM Reiniciar MySQL normalmente
    echo Reiniciando MySQL normalmente...
    ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "systemctl start mysql"
    
    echo Esperando 5 segundos...
    timeout /t 5 /nobreak >nul
    
    REM Verificar
    echo Verificando conexión...
    if "%nueva_password%"=="" (
        ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "mysql -u root -e \"SELECT 'Conexion exitosa' AS resultado;\" 2>&1"
    ) else (
        ssh -p %VPS_PORT% %VPS_USER%@%VPS_HOST% "mysql -u root -p'%nueva_password%' -e \"SELECT 'Conexion exitosa' AS resultado;\" 2>&1"
    )
)

echo.
echo ================================================
echo PROCESO COMPLETADO
echo ================================================
echo.
pause




