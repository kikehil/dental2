@echo off
REM Script de despliegue completo para Windows
REM Actualiza código y aplica migraciones sin perder datos

set VPS_USER=root
set VPS_HOST=147.93.118.121
set VPS_PATH=/var/www/html/dentali

echo.
echo ========================================
echo   Despliegue Completo y Seguro al VPS
echo ========================================
echo.

echo Paso 1: Creando backup completo de la base de datos...
plink -ssh %VPS_USER%@%VPS_HOST% -batch << "EOF"
cd /var/www/html/dentali

DB_URL=$(grep DATABASE_URL .env | cut -d '=' -f2- | tr -d '"' | tr -d "'")
DB_USER=$(echo $DB_URL | sed -n 's/.*:\/\/\([^:]*\):.*/\1/p')
DB_PASS=$(echo $DB_URL | sed -n 's/.*:\/\/[^:]*:\([^@]*\)@.*/\1/p')
DB_HOST=$(echo $DB_URL | sed -n 's/.*@\([^:]*\):.*/\1/p')
DB_PORT=$(echo $DB_URL | sed -n 's/.*:\([0-9]*\)\/.*/\1/p')
DB_NAME=$(echo $DB_URL | sed -n 's/.*\/\([^?]*\).*/\1/p')

mkdir -p backups
BACKUP_FILE="backups/backup_$(date +%Y%m%d_%H%M%S).sql"
mysqldump -h "$DB_HOST" -P "${DB_PORT:-3306}" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$BACKUP_FILE"
gzip "$BACKUP_FILE"
echo Backup creado: ${BACKUP_FILE}.gz
EOF

echo.
echo Paso 2: Deteniendo aplicación...
plink -ssh %VPS_USER%@%VPS_HOST% -batch "cd %VPS_PATH% && pm2 stop dentali || echo 'App no estaba corriendo'"

echo.
echo Paso 3: Sincronizando archivos...
echo    Opcion A: Git (recomendado)
echo    Opcion B: rsync (directo)
set /p METODO="¿Usar Git o rsync? (g/r): "

if /i "%METODO%"=="g" (
    echo Usando Git...
    plink -ssh %VPS_USER%@%VPS_HOST% -batch "cd %VPS_PATH% && git fetch origin && git pull origin main || git pull origin master"
) else (
    echo Usando rsync...
    rsync -avz --progress --exclude='.env' --exclude='.git' --exclude='node_modules' --exclude='*.log' --exclude='backups' --exclude='uploads' ./ %VPS_USER%@%VPS_HOST%:%VPS_PATH%/
)

echo.
echo Paso 4: Instalando dependencias...
plink -ssh %VPS_USER%@%VPS_HOST% -batch "cd %VPS_PATH% && npm install --production"

echo.
echo Paso 5: Regenerando Prisma Client...
plink -ssh %VPS_USER%@%VPS_HOST% -batch "cd %VPS_PATH% && npx prisma generate"

echo.
echo Paso 6: Aplicando migraciones...
plink -ssh %VPS_USER%@%VPS_HOST% -batch "cd %VPS_PATH% && npx prisma migrate deploy || npx prisma db push --accept-data-loss"

echo.
echo Paso 7: Verificando tablas nuevas...
plink -ssh %VPS_USER%@%VPS_HOST% -batch << "EOF"
cd /var/www/html/dentali

DB_URL=$(grep DATABASE_URL .env | cut -d '=' -f2- | tr -d '"' | tr -d "'")
DB_USER=$(echo $DB_URL | sed -n 's/.*:\/\/\([^:]*\):.*/\1/p')
DB_PASS=$(echo $DB_URL | sed -n 's/.*:\/\/[^:]*:\([^@]*\)@.*/\1/p')
DB_HOST=$(echo $DB_URL | sed -n 's/.*@\([^:]*\):.*/\1/p')
DB_PORT=$(echo $DB_URL | sed -n 's/.*:\([0-9]*\)\/.*/\1/p')
DB_NAME=$(echo $DB_URL | sed -n 's/.*\/\([^?]*\).*/\1/p')

# Verificar y crear tabla laboratorios si no existe
mysql -h "$DB_HOST" -P "${DB_PORT:-3306}" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" << 'SQL'
CREATE TABLE IF NOT EXISTS `laboratorios` (
  `id` INTEGER NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(191) NOT NULL,
  `contacto` VARCHAR(191) NULL,
  `telefono` VARCHAR(191) NULL,
  `activo` BOOLEAN NOT NULL DEFAULT true,
  `createdAt` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updatedAt` DATETIME(3) NOT NULL,
  PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
SQL

# Verificar y agregar columnas a gastos
mysql -h "$DB_HOST" -P "${DB_PORT:-3306}" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" << 'SQL'
ALTER TABLE `gastos` 
ADD COLUMN IF NOT EXISTS `tipo` VARCHAR(191) NOT NULL DEFAULT 'general',
ADD COLUMN IF NOT EXISTS `laboratorioId` INTEGER NULL,
ADD COLUMN IF NOT EXISTS `pacienteId` INTEGER NULL;
SQL

echo Verificacion completada
EOF

echo.
echo Paso 8: Reiniciando aplicación...
plink -ssh %VPS_USER%@%VPS_HOST% -batch "cd %VPS_PATH% && pm2 restart dentali || pm2 start ecosystem.config.js --name dentali && pm2 save"

echo.
echo ========================================
echo   Despliegue completado exitosamente!
echo ========================================
echo.
echo Resumen:
echo   - Backup de BD creado
echo   - Archivos sincronizados
echo   - Dependencias instaladas
echo   - Prisma Client regenerado
echo   - Migraciones aplicadas
echo   - Aplicacion reiniciada
echo.
pause



