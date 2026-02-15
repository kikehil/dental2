#!/bin/bash

# Script para restaurar la base de datos en el VPS2
# Uso: ./restaurar-db-vps2.sh

# ============================================
# CONFIGURACIÓN DEL VPS2 (DESTINO)
# ============================================
VPS2_USER="root"
VPS2_HOST="nueva_ip_vps2"  # ⚠️ CAMBIA POR LA IP DE TU VPS2
VPS2_PASSWORD="tu_password"  # ⚠️ CAMBIA POR TU CONTRASEÑA
VPS2_PATH="/var/www/html/dentali"  # ⚠️ CAMBIA POR LA RUTA DE TU PROYECTO

# ============================================
# CONFIGURACIÓN LOCAL
# ============================================
BACKUP_DIR="./backups"
# Si no especificas un archivo, usará el más reciente
BACKUP_FILE=""  # ⚠️ Deja vacío para usar el más reciente, o especifica: "db_backup_20250128_120000.sql"

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}🗄️  Restaurando base de datos en el VPS2...${NC}"
echo ""

# Verificar que sshpass esté instalado
if ! command -v sshpass &> /dev/null; then
    echo -e "${RED}❌ Error: sshpass no está instalado${NC}"
    echo "Instala con: sudo apt-get install sshpass (Linux) o brew install hudochenkov/sshpass/sshpass (Mac)"
    exit 1
fi

# Función para ejecutar comandos SSH
ssh_exec() {
    sshpass -p "$VPS2_PASSWORD" ssh -o StrictHostKeyChecking=no $VPS2_USER@$VPS2_HOST "$1"
}

# Función para copiar archivos
scp_copy() {
    sshpass -p "$VPS2_PASSWORD" scp -o StrictHostKeyChecking=no "$1" "$2"
}

# Determinar qué archivo de backup usar
if [ -z "$BACKUP_FILE" ]; then
    # Buscar el backup más reciente
    BACKUP_FILE=$(ls -t "$BACKUP_DIR"/db_backup_*.sql 2>/dev/null | head -1)
    if [ -z "$BACKUP_FILE" ]; then
        echo -e "${RED}❌ Error: No se encontró ningún backup en $BACKUP_DIR${NC}"
        echo "Primero ejecuta: ./backup-db-vps1.sh"
        exit 1
    fi
    echo -e "${YELLOW}📁 Usando backup más reciente: $(basename $BACKUP_FILE)${NC}"
else
    BACKUP_FILE="$BACKUP_DIR/$BACKUP_FILE"
    if [ ! -f "$BACKUP_FILE" ]; then
        echo -e "${RED}❌ Error: El archivo $BACKUP_FILE no existe${NC}"
        exit 1
    fi
fi

echo -e "${YELLOW}1. Verificando conexión con VPS2...${NC}"
if ! ssh_exec "echo 'Conexión exitosa'" &> /dev/null; then
    echo -e "${RED}❌ Error: No se pudo conectar al VPS2${NC}"
    echo "Verifica las credenciales en el script"
    exit 1
fi
echo -e "${GREEN}✅ Conexión exitosa${NC}"
echo ""

echo -e "${YELLOW}2. Verificando que el proyecto existe en VPS2...${NC}"
if ! ssh_exec "test -d $VPS2_PATH"; then
    echo -e "${RED}❌ Error: El directorio $VPS2_PATH no existe en el VPS2${NC}"
    echo "Primero ejecuta: ./subir-proyecto-vps2.sh"
    exit 1
fi
echo -e "${GREEN}✅ Proyecto encontrado${NC}"
echo ""

echo -e "${YELLOW}3. Obteniendo credenciales de la base de datos del VPS2...${NC}"
# Obtener DATABASE_URL del archivo .env
DB_URL=$(ssh_exec "cd $VPS2_PATH && grep DATABASE_URL .env 2>/dev/null | cut -d '=' -f2- | tr -d '\"' | tr -d \"'\" | tr -d ' '")

if [ -z "$DB_URL" ]; then
    echo -e "${RED}❌ Error: No se pudo obtener DATABASE_URL del archivo .env${NC}"
    echo "Asegúrate de que el archivo .env existe en el VPS2 y tiene DATABASE_URL configurado"
    exit 1
fi

# Extraer componentes de la URL de conexión
DB_USER=$(echo $DB_URL | sed -n 's|.*://\([^:]*\):.*|\1|p')
DB_PASS=$(echo $DB_URL | sed -n 's|.*://[^:]*:\([^@]*\)@.*|\1|p')
DB_HOST=$(echo $DB_URL | sed -n 's|.*@\([^:]*\):.*|\1|p')
DB_PORT=$(echo $DB_URL | sed -n 's|.*:\([0-9]*\)/.*|\1|p')
DB_NAME=$(echo $DB_URL | sed -n 's|.*/\([^?]*\).*|\1|p')

# Si no se especificó puerto, usar el predeterminado
if [ -z "$DB_PORT" ]; then
    DB_PORT="3306"
fi

echo "   Usuario: $DB_USER"
echo "   Host: $DB_HOST"
echo "   Puerto: $DB_PORT"
echo "   Base de datos: $DB_NAME"
echo -e "${GREEN}✅ Credenciales obtenidas${NC}"
echo ""

echo -e "${YELLOW}4. Verificando que la base de datos existe...${NC}"
DB_EXISTS=$(ssh_exec "mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS -e 'SHOW DATABASES LIKE \"$DB_NAME\"' 2>/dev/null | grep -c $DB_NAME")
if [ "$DB_EXISTS" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  La base de datos no existe, creándola...${NC}"
    ssh_exec "mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS -e 'CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci' 2>/dev/null"
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Error al crear la base de datos${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Base de datos creada${NC}"
else
    echo -e "${GREEN}✅ Base de datos existe${NC}"
fi
echo ""

echo -e "${YELLOW}5. Subiendo backup al VPS2...${NC}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
scp_copy "$BACKUP_FILE" "$VPS2_USER@$VPS2_HOST:/tmp/db_restore_${TIMESTAMP}.sql"

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Error al subir el backup${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Backup subido${NC}"
echo ""

echo -e "${YELLOW}6. Restaurando base de datos...${NC}"
echo "   Esto puede tardar varios minutos dependiendo del tamaño de la base de datos..."
ssh_exec "mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS $DB_NAME < /tmp/db_restore_${TIMESTAMP}.sql 2>&1"

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Error al restaurar la base de datos${NC}"
    echo "Verifica las credenciales y que MySQL esté corriendo en el VPS2"
    ssh_exec "rm -f /tmp/db_restore_${TIMESTAMP}.sql"
    exit 1
fi
echo -e "${GREEN}✅ Base de datos restaurada${NC}"
echo ""

echo -e "${YELLOW}7. Limpiando archivo temporal en el VPS2...${NC}"
ssh_exec "rm -f /tmp/db_restore_${TIMESTAMP}.sql"
echo -e "${GREEN}✅ Limpieza completada${NC}"
echo ""

echo -e "${YELLOW}8. Verificando restauración...${NC}"
# Verificar que hay datos en algunas tablas importantes
TABLES=$(ssh_exec "mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS $DB_NAME -e 'SHOW TABLES' 2>/dev/null | wc -l")
if [ "$TABLES" -gt 1 ]; then
    echo -e "${GREEN}✅ Base de datos restaurada correctamente (${TABLES} tablas encontradas)${NC}"
else
    echo -e "${YELLOW}⚠️  Advertencia: Pocas tablas encontradas, verifica manualmente${NC}"
fi
echo ""

echo -e "${GREEN}✅ Restauración de base de datos completada exitosamente${NC}"
echo ""
echo "💡 Próximos pasos en el VPS2:"
echo "   1. Verifica que el archivo .env tenga las credenciales correctas"
echo "   2. Ejecuta: cd $VPS2_PATH"
echo "   3. Ejecuta: npm ci --production"
echo "   4. Ejecuta: npx prisma generate"
echo "   5. Ejecuta: npx prisma migrate deploy"
echo "   6. Ejecuta: npm run build"
echo "   7. Ejecuta: pm2 start ecosystem.config.js"
echo "   8. Verifica que la aplicación funcione correctamente"
echo ""





