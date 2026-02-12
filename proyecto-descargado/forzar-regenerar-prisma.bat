@echo off
echo ================================================
echo FORZAR REGENERACION DE CLIENTE DE PRISMA
echo ================================================
echo.
echo Este script:
echo 1. Detendra todos los procesos de Node.js
echo 2. Eliminara el cliente de Prisma existente
echo 3. Regenerara el cliente de Prisma
echo.
echo IMPORTANTE: Cierra Cursor antes de continuar si es posible.
echo.
pause

echo.
echo [1/4] Deteniendo procesos de Node.js...
taskkill /F /IM node.exe >nul 2>&1
if %errorlevel% equ 0 (
    echo Procesos de Node.js detenidos.
) else (
    echo No se encontraron procesos de Node.js ejecutandose.
)

echo.
echo [2/4] Esperando 2 segundos...
timeout /t 2 /nobreak >nul

echo.
echo [3/4] Eliminando cliente de Prisma existente...
if exist "node_modules\.prisma" (
    rmdir /s /q "node_modules\.prisma" 2>nul
    echo Cliente de Prisma eliminado.
) else (
    echo No se encontro cliente de Prisma existente.
)

echo.
echo [4/4] Sincronizando base de datos con el esquema...
npx prisma db push
if %errorlevel% neq 0 (
    echo ERROR: No se pudo sincronizar la base de datos.
    pause
    exit /b 1
)

echo.
echo [5/5] Regenerando cliente de Prisma...
npx prisma generate
if %errorlevel% neq 0 (
    echo ERROR: No se pudo regenerar el cliente de Prisma.
    echo.
    echo Si el error persiste:
    echo 1. Cierra Cursor completamente
    echo 2. Ejecuta este script como Administrador
    echo 3. O ejecuta manualmente: npx prisma generate
    pause
    exit /b 1
)

echo.
echo ================================================
echo COMPLETADO
echo ================================================
echo.
echo El cliente de Prisma ha sido regenerado exitosamente.
echo Ahora puedes reiniciar el servidor con: npm run dev
echo.
pause
