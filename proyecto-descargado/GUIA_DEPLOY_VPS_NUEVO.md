# 🚀 Guía de Despliegue al Nuevo VPS

**IP del VPS:** `85.31.224.248`  
**Fecha:** Enero 2026

## 📋 Requisitos Previos

### En el VPS necesitas tener:
- ✅ Ubuntu 20.04+ o Debian 11+
- ✅ Node.js 18.x o superior
- ✅ MySQL 8.0 o superior
- ✅ PM2 instalado globalmente
- ✅ Acceso SSH con usuario `root` (o el usuario que uses)

### En tu máquina local:
- ✅ Acceso SSH al VPS
- ✅ Claves SSH configuradas (recomendado)
- ✅ `rsync` instalado (viene con Git en Windows)

---

## ⚡ Despliegue Rápido (Automático)

### Paso 1: Preparar el script

El script `deploy-vps-nuevo.sh` ya está configurado para tu VPS, pero puedes verificar/ajustar:

```bash
# Editar si necesitas cambiar usuario, puerto o ruta
nano deploy-vps-nuevo.sh
```

Variables configurables:
- `VPS_USER="root"` - Usuario SSH
- `VPS_HOST="85.31.224.248"` - IP del VPS
- `VPS_PORT="22"` - Puerto SSH
- `VPS_PATH="/var/www/html/dentali"` - Ruta en el servidor

### Paso 2: Dar permisos de ejecución

**En Windows (Git Bash o WSL):**
```bash
chmod +x deploy-vps-nuevo.sh
```

### Paso 3: Ejecutar el despliegue

```bash
./deploy-vps-nuevo.sh
```

El script automáticamente:
1. ✅ Verifica conexión SSH
2. ✅ Prepara el servidor (instala Node.js, PM2 si faltan)
3. ✅ Sincroniza archivos (excluyendo node_modules, .env, etc.)
4. ✅ Instala dependencias
5. ✅ Genera cliente de Prisma
6. ✅ Aplica migraciones de base de datos
7. ✅ Compila CSS
8. ✅ Inicializa módulos
9. ✅ Inicia/reinicia la aplicación con PM2

---

## 🔧 Despliegue Manual (Paso a Paso)

Si prefieres hacerlo manualmente o el script automático falla:

### Paso 1: Conectar al VPS

```bash
ssh root@85.31.224.248
```

### Paso 2: Preparar el servidor

```bash
# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar Node.js 18.x (si no está instalado)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Instalar PM2 (si no está instalado)
sudo npm install -g pm2

# Instalar MySQL (si no está instalado)
sudo apt install mysql-server -y
sudo mysql_secure_installation
```

### Paso 3: Crear base de datos

```bash
sudo mysql -u root -p
```

Dentro de MySQL:
```sql
CREATE DATABASE dentali CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'dentali_user'@'localhost' IDENTIFIED BY 'tu_password_segura';
GRANT ALL PRIVILEGES ON dentali.* TO 'dentali_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### Paso 4: Crear directorio del proyecto

```bash
mkdir -p /var/www/html/dentali
cd /var/www/html/dentali
```

### Paso 5: Subir archivos desde tu máquina local

**Opción A: Usando rsync (desde tu máquina local)**
```bash
rsync -avz --progress \
  -e "ssh -p 22" \
  --exclude='.env' \
  --exclude='.git' \
  --exclude='node_modules' \
  --exclude='*.log' \
  --exclude='backups' \
  --exclude='uploads' \
  ./ root@85.31.224.248:/var/www/html/dentali/
```

**Opción B: Usando SCP (desde tu máquina local)**
```bash
scp -r * root@85.31.224.248:/var/www/html/dentali/
```

**Opción C: Usando Git (si tienes repositorio)**
```bash
# En el VPS
cd /var/www/html/dentali
git clone tu-repositorio.git .
```

### Paso 6: Configurar variables de entorno

```bash
# En el VPS
cd /var/www/html/dentali
cp env.example.txt .env
nano .env
```

Configura especialmente:
```env
PORT=3005
NODE_ENV=production
DATABASE_URL="mysql://dentali_user:tu_password@localhost:3306/dentali"
SESSION_SECRET="genera_una_clave_secreta_muy_segura_aqui"
USE_SECURE_COOKIES=false
TZ=America/Mexico_City
```

### Paso 7: Instalar dependencias

```bash
cd /var/www/html/dentali
npm install --production
```

### Paso 8: Generar cliente de Prisma

```bash
npx prisma generate --schema=prisma/schema.prisma
```

### Paso 9: Aplicar migraciones

```bash
npx prisma db push --accept-data-loss
```

### Paso 10: Compilar CSS

```bash
npm run build
```

### Paso 11: Inicializar módulos

```bash
node scripts/init-modulos.js
```

### Paso 12: Iniciar con PM2

```bash
pm2 start ecosystem.config.js --name dentali
pm2 save
pm2 startup  # Para iniciar automáticamente al reiniciar el servidor
```

---

## 🔍 Verificación Post-Despliegue

### Verificar que la aplicación está corriendo:

```bash
ssh root@85.31.224.248 'pm2 status'
```

Deberías ver `dentali` con estado `online`.

### Ver logs:

```bash
ssh root@85.31.224.248 'pm2 logs dentali'
```

### Verificar que responde:

```bash
curl http://localhost:3005
```

O desde tu navegador:
```
http://85.31.224.248:3005
```

---

## 🌐 Configurar Nginx como Reverse Proxy (Opcional)

Si quieres usar un dominio y HTTPS:

### 1. Instalar Nginx

```bash
sudo apt install nginx -y
```

### 2. Crear configuración

```bash
sudo nano /etc/nginx/sites-available/dentali
```

Contenido:
```nginx
server {
    listen 80;
    server_name tu-dominio.com www.tu-dominio.com;

    location / {
        proxy_pass http://localhost:3005;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 3. Activar sitio

```bash
sudo ln -s /etc/nginx/sites-available/dentali /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 4. Configurar SSL con Let's Encrypt (opcional)

```bash
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d tu-dominio.com -d www.tu-dominio.com
```

---

## 🔄 Actualizaciones Futuras

Para actualizar el código en el futuro:

### Opción 1: Usar el script automático
```bash
./deploy-vps-nuevo.sh
```

### Opción 2: Manual rápido
```bash
# Sincronizar archivos
rsync -avz --exclude='node_modules' --exclude='.env' ./ root@85.31.224.248:/var/www/html/dentali/

# En el VPS
ssh root@85.31.224.248
cd /var/www/html/dentali
npm install --production
npx prisma generate
npx prisma db push
npm run build
pm2 restart dentali
```

---

## 🐛 Solución de Problemas

### Error: "Cannot connect to MySQL"
- Verifica que MySQL esté corriendo: `sudo systemctl status mysql`
- Verifica las credenciales en `.env`
- Verifica que el usuario tenga permisos: `GRANT ALL PRIVILEGES ON dentali.* TO 'dentali_user'@'localhost';`

### Error: "Port 3005 already in use"
- Cambia el puerto en `.env` o detén el proceso: `pm2 stop dentali`

### Error: "Prisma Client not generated"
- Ejecuta: `npx prisma generate --schema=prisma/schema.prisma`

### La aplicación no inicia
- Revisa logs: `pm2 logs dentali`
- Verifica `.env`: `cat .env`
- Verifica que Node.js esté instalado: `node --version`

---

## 📞 Comandos Útiles

```bash
# Ver estado de PM2
pm2 status

# Ver logs en tiempo real
pm2 logs dentali

# Reiniciar aplicación
pm2 restart dentali

# Detener aplicación
pm2 stop dentali

# Ver información del proceso
pm2 info dentali

# Ver uso de recursos
pm2 monit
```

---

## ✅ Checklist Final

- [ ] Servidor preparado (Node.js, MySQL, PM2)
- [ ] Base de datos creada
- [ ] Archivos subidos al servidor
- [ ] Archivo `.env` configurado
- [ ] Dependencias instaladas
- [ ] Cliente de Prisma generado
- [ ] Migraciones aplicadas
- [ ] CSS compilado
- [ ] Módulos inicializados
- [ ] Aplicación corriendo con PM2
- [ ] Aplicación accesible desde el navegador

---

**¡Listo! Tu aplicación debería estar funcionando en el VPS.** 🎉





