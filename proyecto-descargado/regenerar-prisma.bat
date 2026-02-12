@echo off
echo ================================================
echo REGENERAR CLIENTE DE PRISMA
echo ================================================
echo.
echo IMPORTANTE: Asegurate de que el servidor este detenido antes de continuar.
echo.
pause

echo.
echo Sincronizando base de datos con el esquema...
npx prisma db push

echo.
echo Regenerando cliente de Prisma...
npx prisma generate

echo.
echo ================================================
echo COMPLETADO
echo ================================================
echo.
echo Ahora puedes reiniciar el servidor con: npm run dev
echo.
pause

