#!/bin/bash

# Script de despliegue para NUEVO VPS
# IP: 85.31.224.248
# Fecha: Enero 2026

set -e  # Salir si hay algún error

echo "🚀 Iniciando despliegue al NUEVO VPS..."
echo ""

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================
# CONFIGURACIÓN - MODIFICA ESTOS VALORES
# ============================================
VPS_USER="root"
VPS_HOST="85.31.224.248"
VPS_PORT="22"
VPS_PATH="/var/www/html/dentali"

echo -e "${BLUE}📋 Configuración del despliegue:${NC}"
echo -e "   Usuario: ${VPS_USER}"
echo -e "   Host: ${VPS_HOST}"
echo -e "   Puerto: ${VPS_PORT}"
echo -e "   Ruta: ${VPS_PATH}"
echo ""

# ============================================
# Verificaciones previas
# ============================================
echo -e "${BLUE}🔍 Verificando requisitos...${NC}"

# Verificar conexión SSH
echo "   Verificando conexión SSH..."
if ! ssh -p $VPS_PORT -o ConnectTimeout=10 -o StrictHostKeyChecking=no $VPS_USER@$VPS_HOST "echo 'Conexión exitosa'" 2>/dev/null; then
    echo -e "${RED}❌ No se puede conectar al servidor SSH${NC}"
    echo "   Verifica: usuario, IP, puerto y que el servidor esté accesible"
    exit 1
fi
echo -e "${GREEN}✅ Conexión SSH verificada${NC}"

# Verificar que existe .env local (opcional)
if [ ! -f .env ]; then
    echo -e "${YELLOW}⚠️  ADVERTENCIA: No se encontró archivo .env local${NC}"
    echo "   Se usará el .env del servidor"
fi

echo ""
read -p "¿Continuar con el despliegue? (s/n): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    echo "Despliegue cancelado."
    exit 1
fi

# ============================================
# Paso 1: Preparar servidor (solo primera vez)
# ============================================
echo ""
echo -e "${BLUE}📦 Paso 1: Verificando preparación del servidor...${NC}"
ssh -p $VPS_PORT $VPS_USER@$VPS_HOST << 'ENDSSH'
# Verificar Node.js
if ! command -v node &> /dev/null; then
    echo "⚠️  Node.js no está instalado. Instalando..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# Verificar PM2
if ! command -v pm2 &> /dev/null; then
    echo "⚠️  PM2 no está instalado. Instalando..."
    sudo npm install -g pm2
fi

# Verificar MySQL
if ! command -v mysql &> /dev/null; then
    echo "⚠️  MySQL no está instalado. Necesitas instalarlo manualmente."
fi

# Crear directorio si no existe
mkdir -p /var/www/html/dentali
echo "✅ Servidor preparado"
ENDSSH

# ============================================
# Paso 2: Sincronizar archivos
# ============================================
echo ""
echo -e "${BLUE}📤 Paso 2: Sincronizando archivos...${NC}"

# Excluir archivos que no deben subirse
rsync -avz --progress \
  -e "ssh -p $VPS_PORT" \
  --exclude='.env' \
  --exclude='.git' \
  --exclude='node_modules' \
  --exclude='*.log' \
  --exclude='backups' \
  --exclude='uploads' \
  --exclude='.DS_Store' \
  --exclude='*.swp' \
  --exclude='*.swo' \
  --exclude='.vscode' \
  --exclude='.idea' \
  ./ $VPS_USER@$VPS_HOST:$VPS_PATH/

echo -e "${GREEN}✅ Archivos sincronizados${NC}"

# ============================================
# Paso 3: Configurar .env en el servidor
# ============================================
echo ""
echo -e "${BLUE}⚙️  Paso 3: Configurando variables de entorno...${NC}"

# Verificar si existe .env en el servidor
if ssh -p $VPS_PORT $VPS_USER@$VPS_HOST "[ -f $VPS_PATH/.env ]"; then
    echo "   .env ya existe en el servidor, se mantendrá"
else
    echo "   Creando .env desde env.example.txt..."
    ssh -p $VPS_PORT $VPS_USER@$VPS_HOST << ENDSSH
cd $VPS_PATH
if [ -f env.example.txt ]; then
    cp env.example.txt .env
    echo "⚠️  IMPORTANTE: Edita el archivo .env con tus credenciales:"
    echo "   nano $VPS_PATH/.env"
    echo ""
    echo "   Configura especialmente:"
    echo "   - DATABASE_URL"
    echo "   - SESSION_SECRET"
    echo "   - PORT"
fi
ENDSSH
    echo -e "${YELLOW}⚠️  Necesitas editar el .env en el servidor antes de continuar${NC}"
    read -p "¿Ya configuraste el .env? (s/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        echo "Por favor configura el .env y vuelve a ejecutar el script"
        exit 1
    fi
fi

# ============================================
# Paso 4: Instalar dependencias
# ============================================
echo ""
echo -e "${BLUE}📦 Paso 4: Instalando dependencias...${NC}"
ssh -p $VPS_PORT $VPS_USER@$VPS_HOST << 'ENDSSH'
cd /var/www/html/dentali
npm install --production
echo "✅ Dependencias instaladas"
ENDSSH

# ============================================
# Paso 5: Generar cliente de Prisma
# ============================================
echo ""
echo -e "${BLUE}🔧 Paso 5: Generando cliente de Prisma...${NC}"
ssh -p $VPS_PORT $VPS_USER@$VPS_HOST << 'ENDSSH'
cd /var/www/html/dentali
npx prisma generate --schema=prisma/schema.prisma
echo "✅ Cliente de Prisma generado"
ENDSSH

# ============================================
# Paso 6: Aplicar migraciones de base de datos
# ============================================
echo ""
echo -e "${BLUE}🗄️  Paso 6: Aplicando migraciones de base de datos...${NC}"
echo -e "${YELLOW}⚠️  Esto creará las tablas si no existen${NC}"
read -p "¿Continuar con las migraciones? (s/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Ss]$ ]]; then
    ssh -p $VPS_PORT $VPS_USER@$VPS_HOST << 'ENDSSH'
cd /var/www/html/dentali
npx prisma db push --accept-data-loss
echo "✅ Migraciones aplicadas"
ENDSSH
else
    echo "   Migraciones omitidas"
fi

# ============================================
# Paso 7: Compilar CSS
# ============================================
echo ""
echo -e "${BLUE}🎨 Paso 7: Compilando CSS...${NC}"
ssh -p $VPS_PORT $VPS_USER@$VPS_HOST << 'ENDSSH'
cd /var/www/html/dentali
npm run build
echo "✅ CSS compilado"
ENDSSH

# ============================================
# Paso 8: Inicializar módulos (si no existen)
# ============================================
echo ""
echo -e "${BLUE}🔐 Paso 8: Inicializando módulos y permisos...${NC}"
ssh -p $VPS_PORT $VPS_USER@$VPS_HOST << 'ENDSSH'
cd /var/www/html/dentali
if [ -f scripts/init-modulos.js ]; then
    node scripts/init-modulos.js || echo "⚠️  Error al inicializar módulos (puede que ya existan)"
fi
echo "✅ Módulos verificados"
ENDSSH

# ============================================
# Paso 9: Iniciar/Reiniciar aplicación con PM2
# ============================================
echo ""
echo -e "${BLUE}🚀 Paso 9: Iniciando aplicación con PM2...${NC}"
ssh -p $VPS_PORT $VPS_USER@$VPS_HOST << 'ENDSSH'
cd /var/www/html/dentali

# Detener si ya está corriendo
pm2 stop dentali 2>/dev/null || echo "Aplicación no estaba corriendo"

# Iniciar o reiniciar
if pm2 list | grep -q "dentali"; then
    pm2 restart dentali
    echo "✅ Aplicación reiniciada"
else
    pm2 start ecosystem.config.js --name dentali
    pm2 save
    echo "✅ Aplicación iniciada"
fi

# Mostrar estado
pm2 status
ENDSSH

# ============================================
# Resumen final
# ============================================
echo ""
echo -e "${GREEN}════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ DESPLIEGUE COMPLETADO EXITOSAMENTE${NC}"
echo -e "${GREEN}════════════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}📋 Próximos pasos:${NC}"
echo "   1. Verifica que la aplicación esté corriendo:"
echo "      ssh $VPS_USER@$VPS_HOST 'pm2 status'"
echo ""
echo "   2. Verifica los logs:"
echo "      ssh $VPS_USER@$VPS_HOST 'pm2 logs dentali'"
echo ""
echo "   3. Si necesitas configurar Nginx como reverse proxy,"
echo "      consulta la guía en GUIA_DESPLIEGUE_VPS.md"
echo ""
echo -e "${GREEN}🎉 ¡Listo! Tu aplicación debería estar corriendo en el VPS${NC}"





