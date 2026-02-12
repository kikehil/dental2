@echo off
echo ================================================
echo REGENERAR CLIENTE DE PRISMA - VERSION COMPLETA
echo ================================================
echo.

echo Verificando procesos de Node.js...
tasklist /FI "IMAGENAME eq node.exe" 2>NUL | find /I /N "node.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo.
    echo ADVERTENCIA: Se encontraron procesos de Node.js corriendo.
    echo Por favor, deten el servidor antes de continuar.
    echo.
    echo Procesos encontrados:
    tasklist /FI "IMAGENAME eq node.exe"
    echo.
    echo Presiona cualquier tecla para intentar continuar de todas formas...
    pause >nul
)

echo.
echo Sincronizando base de datos con el esquema...
npx prisma db push
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: No se pudo sincronizar la base de datos
    pause
    exit /b 1
)

echo.
echo Regenerando cliente de Prisma...
npx prisma generate
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: No se pudo regenerar el cliente de Prisma
    pause
    exit /b 1
)

echo.
echo ================================================
echo COMPLETADO EXITOSAMENTE
echo ================================================
echo.
echo El cliente de Prisma ha sido regenerado.
echo Ahora puedes reiniciar el servidor con: npm run dev
echo.
pause


