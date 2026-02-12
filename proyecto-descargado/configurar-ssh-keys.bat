@echo off
REM Script para configurar claves SSH y evitar pedir contraseña
REM IP: 85.31.224.248

echo ================================================
echo CONFIGURACIÓN DE CLAVES SSH
echo ================================================
echo.
echo Este script configurará claves SSH para que no
echo tengas que ingresar la contraseña en cada operación.
echo.

set VPS_USER=root
set VPS_HOST=85.31.224.248

REM Verificar si ya existe clave SSH
if exist "%USERPROFILE%\.ssh\id_rsa.pub" (
    echo Clave SSH encontrada: %USERPROFILE%\.ssh\id_rsa.pub
    echo.
    set /p usar_existente="¿Usar la clave existente? (s/n): "
    if /i not "%usar_existente%"=="s" (
        goto generar_nueva
    )
    goto copiar_clave
)

:generar_nueva
echo Generando nueva clave SSH...
echo.
ssh-keygen -t rsa -b 4096 -f "%USERPROFILE%\.ssh\id_rsa" -N ""
if %errorlevel% neq 0 (
    echo ERROR: No se pudo generar la clave SSH
    pause
    exit /b 1
)
echo.
echo Clave SSH generada exitosamente
echo.

:copiar_clave
echo Copiando clave pública al servidor...
echo.
echo IMPORTANTE: Se te pedirá la contraseña UNA VEZ para copiar la clave
echo.
ssh-copy-id -p 22 %VPS_USER%@%VPS_HOST%
if %errorlevel% neq 0 (
    echo.
    echo ERROR: No se pudo copiar la clave
    echo Puedes hacerlo manualmente:
    echo   1. Copia el contenido de: %USERPROFILE%\.ssh\id_rsa.pub
    echo   2. Conecta al servidor: ssh %VPS_USER%@%VPS_HOST%
    echo   3. Ejecuta: mkdir -p ~/.ssh
    echo   4. Ejecuta: echo "TU_CLAVE_PUBLICA" >> ~/.ssh/authorized_keys
    echo   5. Ejecuta: chmod 600 ~/.ssh/authorized_keys
    echo   6. Ejecuta: chmod 700 ~/.ssh
    pause
    exit /b 1
)

echo.
echo ================================================
echo CONFIGURACIÓN COMPLETADA
echo ================================================
echo.
echo Ahora puedes ejecutar deploy-vps-nuevo.bat sin
echo tener que ingresar la contraseña en cada operación.
echo.
pause




