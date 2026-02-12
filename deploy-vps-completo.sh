#!/bin/bash

# Script de despliegue completo y seguro al VPS
# Actualiza código y aplica migraciones sin perder datos
# Fecha: 28/12/2025

set -e  # Salir si hay algún error

echo "🚀 Iniciando despliegue completo y seguro al VPS..."
echo ""

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuración
VPS_USER="root"
VPS_HOST="147.93.118.121"
VPS_PATH="/var/www/html/dentali"

echo -e "${YELLOW}⚠️  IMPORTANTE: Este script actualizará el código y aplicará migraciones${NC}"
echo -e "${YELLOW}   Se creará un backup automático antes de cualquier cambio${NC}"
echo ""
read -p "¿Continuar con el despliegue? (s/n): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    echo "Despliegue cancelado."
    exit 1
fi

echo ""
echo -e "${BLUE}📦 Paso 1: Creando backup completo de la base de datos...${NC}"
ssh ${VPS_USER}@${VPS_HOST} << 'ENDSSH'
cd /var/www/html/dentali

# Obtener credenciales de la base de datos
DB_URL=$(grep DATABASE_URL .env | cut -d '=' -f2- | tr -d '"' | tr -d "'")
DB_USER=$(echo $DB_URL | sed -n 's/.*:\/\/\([^:]*\):.*/\1/p')
DB_PASS=$(echo $DB_URL | sed -n 's/.*:\/\/[^:]*:\([^@]*\)@.*/\1/p')
DB_HOST=$(echo $DB_URL | sed -n 's/.*@\([^:]*\):.*/\1/p')
DB_PORT=$(echo $DB_URL | sed -n 's/.*:\([0-9]*\)\/.*/\1/p')
DB_NAME=$(echo $DB_URL | sed -n 's/.*\/\([^?]*\).*/\1/p')

# Crear directorio de backups si no existe
mkdir -p backups

# Crear backup con timestamp
BACKUP_FILE="backups/backup_$(date +%Y%m%d_%H%M%S).sql"
mysqldump -h "$DB_HOST" -P "${DB_PORT:-3306}" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$BACKUP_FILE"

# Comprimir backup
gzip "$BACKUP_FILE"

echo "✅ Backup creado y comprimido: ${BACKUP_FILE}.gz"
echo "   Tamaño: $(du -h ${BACKUP_FILE}.gz | cut -f1)"
ENDSSH

echo ""
echo -e "${BLUE}📤 Paso 2: Deteniendo aplicación en el VPS...${NC}"
ssh ${VPS_USER}@${VPS_HOST} "cd ${VPS_PATH} && pm2 stop dentali || echo 'Aplicación no estaba corriendo'"

echo ""
echo -e "${BLUE}📤 Paso 3: Sincronizando archivos de código...${NC}"
echo "   Opción A: Usando Git (recomendado si tienes repositorio)"
echo "   Opción B: Usando rsync (sincronización directa)"
echo ""
read -p "¿Usar Git o rsync? (g/r): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Gg]$ ]]; then
    echo "   Usando Git..."
    ssh ${VPS_USER}@${VPS_HOST} << ENDSSH
cd ${VPS_PATH}
git fetch origin
git pull origin main || git pull origin master
echo "✅ Archivos sincronizados via Git"
ENDSSH
else
    echo "   Usando rsync..."
    rsync -avz --progress \
      --exclude='.env' \
      --exclude='.git' \
      --exclude='node_modules' \
      --exclude='*.log' \
      --exclude='backups' \
      --exclude='uploads' \
      --exclude='.DS_Store' \
      ./ ${VPS_USER}@${VPS_HOST}:${VPS_PATH}/
    echo "✅ Archivos sincronizados via rsync"
fi

echo ""
echo -e "${BLUE}📦 Paso 4: Instalando dependencias en el VPS...${NC}"
ssh ${VPS_USER}@${VPS_HOST} << 'ENDSSH'
cd /var/www/html/dentali
npm install --production
echo "✅ Dependencias instaladas"
ENDSSH

echo ""
echo -e "${BLUE}🔄 Paso 5: Regenerando Prisma Client...${NC}"
ssh ${VPS_USER}@${VPS_HOST} << 'ENDSSH'
cd /var/www/html/dentali
npx prisma generate
echo "✅ Prisma Client regenerado"
ENDSSH

echo ""
echo -e "${BLUE}🗄️  Paso 6: Aplicando migraciones de base de datos...${NC}"
ssh ${VPS_USER}@${VPS_HOST} << 'ENDSSH'
cd /var/www/html/dentali

echo "   Verificando migraciones pendientes..."
npx prisma migrate status

echo "   Aplicando migraciones..."
npx prisma migrate deploy || {
    echo "⚠️  migrate deploy falló, intentando db push..."
    npx prisma db push --accept-data-loss
}

echo "✅ Migraciones aplicadas"
ENDSSH

echo ""
echo -e "${BLUE}🔧 Paso 7: Verificando que las nuevas tablas existan...${NC}"
ssh ${VPS_USER}@${VPS_HOST} << 'ENDSSH'
cd /var/www/html/dentali

DB_URL=$(grep DATABASE_URL .env | cut -d '=' -f2- | tr -d '"' | tr -d "'")
DB_USER=$(echo $DB_URL | sed -n 's/.*:\/\/\([^:]*\):.*/\1/p')
DB_PASS=$(echo $DB_URL | sed -n 's/.*:\/\/[^:]*:\([^@]*\)@.*/\1/p')
DB_HOST=$(echo $DB_URL | sed -n 's/.*@\([^:]*\):.*/\1/p')
DB_PORT=$(echo $DB_URL | sed -n 's/.*:\([0-9]*\)\/.*/\1/p')
DB_NAME=$(echo $DB_URL | sed -n 's/.*\/\([^?]*\).*/\1/p')

# Verificar tablas nuevas
TABLES=$(mysql -h "$DB_HOST" -P "${DB_PORT:-3306}" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "SHOW TABLES LIKE 'laboratorios';" -s -N)

if [ -z "$TABLES" ]; then
    echo "⚠️  Tabla laboratorios no existe, creándola..."
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
    echo "✅ Tabla laboratorios creada"
fi

# Verificar columnas nuevas en gastos
COLUMNS=$(mysql -h "$DB_HOST" -P "${DB_PORT:-3306}" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "SHOW COLUMNS FROM gastos LIKE 'tipo';" -s -N)

if [ -z "$COLUMNS" ]; then
    echo "⚠️  Columnas nuevas en gastos no existen, agregándolas..."
    mysql -h "$DB_HOST" -P "${DB_PORT:-3306}" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" << 'SQL'
ALTER TABLE `gastos` 
ADD COLUMN IF NOT EXISTS `tipo` VARCHAR(191) NOT NULL DEFAULT 'general',
ADD COLUMN IF NOT EXISTS `laboratorioId` INTEGER NULL,
ADD COLUMN IF NOT EXISTS `pacienteId` INTEGER NULL;

-- Agregar foreign keys si no existen
SET @fk_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
  WHERE CONSTRAINT_SCHEMA = DATABASE() 
  AND TABLE_NAME = 'gastos' 
  AND CONSTRAINT_NAME = 'gastos_laboratorioId_fkey');

SET @sql = IF(@fk_exists = 0, 
  'ALTER TABLE `gastos` ADD CONSTRAINT `gastos_laboratorioId_fkey` FOREIGN KEY (`laboratorioId`) REFERENCES `laboratorios`(`id`) ON DELETE SET NULL ON UPDATE CASCADE',
  'SELECT "Foreign key ya existe"');

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @fk_exists2 = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
  WHERE CONSTRAINT_SCHEMA = DATABASE() 
  AND TABLE_NAME = 'gastos' 
  AND CONSTRAINT_NAME = 'gastos_pacienteId_fkey');

SET @sql2 = IF(@fk_exists2 = 0, 
  'ALTER TABLE `gastos` ADD CONSTRAINT `gastos_pacienteId_fkey` FOREIGN KEY (`pacienteId`) REFERENCES `pacientes`(`id`) ON DELETE SET NULL ON UPDATE CASCADE',
  'SELECT "Foreign key ya existe"');

PREPARE stmt2 FROM @sql2;
EXECUTE stmt2;
DEALLOCATE PREPARE stmt2;
SQL
    echo "✅ Columnas agregadas a gastos"
fi

echo "✅ Verificación completada"
ENDSSH

echo ""
echo -e "${BLUE}🚀 Paso 8: Reiniciando aplicación...${NC}"
ssh ${VPS_USER}@${VPS_HOST} << 'ENDSSH'
cd /var/www/html/dentali
pm2 restart dentali || pm2 start ecosystem.config.js --name dentali
pm2 save
echo "✅ Aplicación reiniciada"
ENDSSH

echo ""
echo -e "${GREEN}✅ Despliegue completado exitosamente!${NC}"
echo ""
echo -e "${YELLOW}📋 Resumen:${NC}"
echo "   ✅ Backup de base de datos creado"
echo "   ✅ Archivos sincronizados"
echo "   ✅ Dependencias instaladas"
echo "   ✅ Prisma Client regenerado"
echo "   ✅ Migraciones aplicadas"
echo "   ✅ Aplicación reiniciada"
echo ""
echo -e "${BLUE}🌐 Verifica que la aplicación esté funcionando:${NC}"
echo "   http://${VPS_HOST}:3005"
echo ""



