#!/bin/bash

# Script para descargar el proyecto completo del VPS1
# Uso: ./descargar-proyecto-vps1.sh

# ============================================
# CONFIGURACIÓN DEL VPS1 (ORIGEN)
# ============================================
VPS1_USER="root"
VPS1_HOST="147.93.118.121"  # ⚠️ CAMBIA POR LA IP DE TU VPS1
VPS1_PASSWORD="Netbios+2025"  # ⚠️ CAMBIA POR TU CONTRASEÑA
VPS1_PATH="/var/www/html/dentali"  # ⚠️ CAMBIA POR LA RUTA DE TU PROYECTO

# ============================================
# CONFIGURACIÓN LOCAL
# ============================================
DOWNLOAD_DIR="./proyecto-descargado"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}🔄 Descargando proyecto completo del VPS1...${NC}"
echo ""

# Verificar que sshpass esté instalado
if ! command -v sshpass &> /dev/null; then
    echo -e "${RED}❌ Error: sshpass no está instalado${NC}"
    echo "Instala con: sudo apt-get install sshpass (Linux) o brew install hudochenkov/sshpass/sshpass (Mac)"
    exit 1
fi

# Crear directorio de descarga
mkdir -p "$DOWNLOAD_DIR"

# Función para ejecutar comandos SSH
ssh_exec() {
    sshpass -p "$VPS1_PASSWORD" ssh -o StrictHostKeyChecking=no $VPS1_USER@$VPS1_HOST "$1"
}

# Función para copiar archivos
scp_copy() {
    sshpass -p "$VPS1_PASSWORD" scp -o StrictHostKeyChecking=no -r "$1" "$2"
}

echo -e "${YELLOW}1. Verificando conexión con VPS1...${NC}"
if ! ssh_exec "echo 'Conexión exitosa'" &> /dev/null; then
    echo -e "${RED}❌ Error: No se pudo conectar al VPS1${NC}"
    echo "Verifica las credenciales en el script"
    exit 1
fi
echo -e "${GREEN}✅ Conexión exitosa${NC}"
echo ""

echo -e "${YELLOW}2. Verificando que el proyecto existe en VPS1...${NC}"
if ! ssh_exec "test -d $VPS1_PATH"; then
    echo -e "${RED}❌ Error: El directorio $VPS1_PATH no existe en el VPS1${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Proyecto encontrado${NC}"
echo ""

echo -e "${YELLOW}3. Creando backup comprimido en el VPS1...${NC}"
ssh_exec "cd $VPS1_PATH && tar -czf /tmp/proyecto_completo_${TIMESTAMP}.tar.gz \
  --exclude='node_modules' \
  --exclude='.git' \
  --exclude='backups' \
  --exclude='logs' \
  --exclude='*.log' \
  ."

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Error al crear backup en el VPS1${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Backup creado en el servidor${NC}"
echo ""

echo -e "${YELLOW}4. Descargando proyecto completo...${NC}"
scp_copy "$VPS1_USER@$VPS1_HOST:/tmp/proyecto_completo_${TIMESTAMP}.tar.gz" "$DOWNLOAD_DIR/"

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Error al descargar el proyecto${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Proyecto descargado${NC}"
echo ""

echo -e "${YELLOW}5. Extrayendo proyecto...${NC}"
cd "$DOWNLOAD_DIR"
tar -xzf "proyecto_completo_${TIMESTAMP}.tar.gz"
rm -f "proyecto_completo_${TIMESTAMP}.tar.gz"
cd ..
echo -e "${GREEN}✅ Proyecto extraído${NC}"
echo ""

echo -e "${YELLOW}6. Descargando directorio de uploads (si existe)...${NC}"
if ssh_exec "test -d $VPS1_PATH/uploads"; then
    echo "   Descargando uploads..."
    scp_copy "$VPS1_USER@$VPS1_HOST:$VPS1_PATH/uploads" "$DOWNLOAD_DIR/"
    echo -e "${GREEN}✅ Uploads descargados${NC}"
else
    echo "   ⚠️  Directorio uploads no existe, saltando..."
fi
echo ""

echo -e "${YELLOW}7. Limpiando archivos temporales en el VPS1...${NC}"
ssh_exec "rm -f /tmp/proyecto_completo_${TIMESTAMP}.tar.gz"
echo -e "${GREEN}✅ Limpieza completada${NC}"
echo ""

echo -e "${GREEN}✅ Descarga completada exitosamente${NC}"
echo ""
echo "📁 Proyecto descargado en: $DOWNLOAD_DIR"
echo ""
echo "📊 Contenido descargado:"
ls -lh "$DOWNLOAD_DIR" | head -20
echo ""
echo "💡 Próximos pasos:"
echo "   1. Revisa el archivo .env en $DOWNLOAD_DIR"
echo "   2. Ejecuta: ./backup-db-vps1.sh para hacer backup de la base de datos"
echo "   3. Luego ejecuta: ./subir-proyecto-vps2.sh para subir al VPS2"
echo ""

