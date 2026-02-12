#!/bin/bash

# Script para subir el proyecto completo al VPS2
# Uso: ./subir-proyecto-vps2.sh

# ============================================
# CONFIGURACIÓN DEL VPS2 (DESTINO)
# ============================================
VPS2_USER="root"
VPS2_HOST="nueva_ip_vps2"  # ⚠️ CAMBIA POR LA IP DE TU VPS2
VPS2_PASSWORD="tu_password"  # ⚠️ CAMBIA POR TU CONTRASEÑA
VPS2_PATH="/var/www/html/dentali"  # ⚠️ CAMBIA POR LA RUTA DONDE QUIERES EL PROYECTO

# ============================================
# CONFIGURACIÓN LOCAL
# ============================================
PROYECTO_DIR="./proyecto-descargado"  # Directorio con el proyecto descargado del VPS1
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}📤 Subiendo proyecto completo al VPS2...${NC}"
echo ""

# Verificar que sshpass esté instalado
if ! command -v sshpass &> /dev/null; then
    echo -e "${RED}❌ Error: sshpass no está instalado${NC}"
    echo "Instala con: sudo apt-get install sshpass (Linux) o brew install hudochenkov/sshpass/sshpass (Mac)"
    exit 1
fi

# Verificar que el directorio del proyecto existe
if [ ! -d "$PROYECTO_DIR" ]; then
    echo -e "${RED}❌ Error: El directorio $PROYECTO_DIR no existe${NC}"
    echo "Primero ejecuta: ./descargar-proyecto-vps1.sh"
    exit 1
fi

# Función para ejecutar comandos SSH
ssh_exec() {
    sshpass -p "$VPS2_PASSWORD" ssh -o StrictHostKeyChecking=no $VPS2_USER@$VPS2_HOST "$1"
}

# Función para copiar archivos
scp_copy() {
    sshpass -p "$VPS2_PASSWORD" scp -o StrictHostKeyChecking=no -r "$1" "$2"
}

echo -e "${YELLOW}1. Verificando conexión con VPS2...${NC}"
if ! ssh_exec "echo 'Conexión exitosa'" &> /dev/null; then
    echo -e "${RED}❌ Error: No se pudo conectar al VPS2${NC}"
    echo "Verifica las credenciales en el script"
    exit 1
fi
echo -e "${GREEN}✅ Conexión exitosa${NC}"
echo ""

echo -e "${YELLOW}2. Creando directorio en el VPS2...${NC}"
ssh_exec "mkdir -p $VPS2_PATH"
echo -e "${GREEN}✅ Directorio creado${NC}"
echo ""

echo -e "${YELLOW}3. Creando backup comprimido del proyecto local...${NC}"
cd "$PROYECTO_DIR"
tar -czf "/tmp/proyecto_para_vps2_${TIMESTAMP}.tar.gz" \
  --exclude='node_modules' \
  --exclude='.git' \
  --exclude='backups' \
  --exclude='logs' \
  --exclude='*.log' \
  --exclude='.env' \
  .

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Error al crear backup comprimido${NC}"
    exit 1
fi
cd ..
echo -e "${GREEN}✅ Backup comprimido creado${NC}"
echo ""

echo -e "${YELLOW}4. Subiendo proyecto al VPS2...${NC}"
scp_copy "/tmp/proyecto_para_vps2_${TIMESTAMP}.tar.gz" "$VPS2_USER@$VPS2_HOST:/tmp/"

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Error al subir el proyecto${NC}"
    rm -f "/tmp/proyecto_para_vps2_${TIMESTAMP}.tar.gz"
    exit 1
fi
echo -e "${GREEN}✅ Proyecto subido${NC}"
echo ""

echo -e "${YELLOW}5. Extrayendo proyecto en el VPS2...${NC}"
ssh_exec "cd $VPS2_PATH && tar -xzf /tmp/proyecto_para_vps2_${TIMESTAMP}.tar.gz && rm -f /tmp/proyecto_para_vps2_${TIMESTAMP}.tar.gz"

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Error al extraer el proyecto${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Proyecto extraído${NC}"
echo ""

echo -e "${YELLOW}6. Subiendo directorio de uploads (si existe)...${NC}"
if [ -d "$PROYECTO_DIR/uploads" ]; then
    echo "   Subiendo uploads..."
    scp_copy "$PROYECTO_DIR/uploads" "$VPS2_USER@$VPS2_HOST:$VPS2_PATH/"
    echo -e "${GREEN}✅ Uploads subidos${NC}"
else
    echo "   ⚠️  Directorio uploads no existe localmente, saltando..."
fi
echo ""

echo -e "${YELLOW}7. Configurando permisos en el VPS2...${NC}"
ssh_exec "cd $VPS2_PATH && chown -R $VPS2_USER:$VPS2_USER . && chmod -R 755 ."
echo -e "${GREEN}✅ Permisos configurados${NC}"
echo ""

# Limpiar archivo temporal local
rm -f "/tmp/proyecto_para_vps2_${TIMESTAMP}.tar.gz"

echo -e "${GREEN}✅ Proyecto subido exitosamente al VPS2${NC}"
echo ""
echo "📁 Proyecto ubicado en: $VPS2_PATH"
echo ""
echo "⚠️  IMPORTANTE: Ahora necesitas:"
echo "   1. Crear el archivo .env en el VPS2 con las credenciales correctas"
echo "   2. Ejecutar: ./restaurar-db-vps2.sh para restaurar la base de datos"
echo "   3. En el VPS2, ejecutar:"
echo "      cd $VPS2_PATH"
echo "      npm ci --production"
echo "      npx prisma generate"
echo "      npm run build"
echo "      pm2 start ecosystem.config.js"
echo ""


