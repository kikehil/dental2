# 🚀 Despliegue Simple al VPS - Guía Rápida

**IP del VPS:** `85.31.224.248`

## ✅ Estado Actual

- ✅ Scripts de despliegue creados
- ✅ Configuración lista para el VPS
- ⚠️  Necesitas verificar conexión SSH al VPS

## 📋 Opciones de Despliegue

### Opción 1: Despliegue Manual (Más Confiable)

**Paso 1: Conectar al VPS**
```bash
ssh root@85.31.224.248
```

**Paso 2: En el VPS, preparar el entorno**
```bash
# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar Node.js 18.x
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Instalar PM2
sudo npm install -g pm2

# Instalar MySQL (si no está instalado)
sudo apt install mysql-server -y
```

**Paso 3: Crear base de datos**
```bash
sudo mysql -u root -p
```
```sql
CREATE DATABASE dentali CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'dentali_user'@'localhost' IDENTIFIED BY 'tu_password_segura';
GRANT ALL PRIVILEGES ON dentali.* TO 'dentali_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

**Paso 4: Crear directorio**
```bash
mkdir -p /var/www/html/dentali
cd /var/www/html/dentali
```

**Paso 5: Desde tu máquina local, subir archivos**

**Opción A: Usando WinSCP (Recomendado para Windows)**
1. Descarga WinSCP: https://winscp.net/
2. Conecta a: `root@85.31.224.248`
3. Sube todas las carpetas: `src`, `prisma`, `scripts`
4. Sube los archivos: `package.json`, `package-lock.json`, `ecosystem.config.js`, `tailwind.config.js`, `schema.prisma`, `env.example.txt`
5. **NO subas:** `node_modules`, `.env`, `.git`, `backups`, `uploads`

**Opción B: Usando SCP desde PowerShell**
```powershell
# Copiar carpetas principales
scp -r src root@85.31.224.248:/var/www/html/dentali/
scp -r prisma root@85.31.224.248:/var/www/html/dentali/
scp -r scripts root@85.31.224.248:/var/www/html/dentali/

# Copiar archivos principales
scp package.json root@85.31.224.248:/var/www/html/dentali/
scp package-lock.json root@85.31.224.248:/var/www/html/dentali/
scp ecosystem.config.js root@85.31.224.248:/var/www/html/dentali/
scp tailwind.config.js root@85.31.224.248:/var/www/html/dentali/
scp schema.prisma root@85.31.224.248:/var/www/html/dentali/
scp env.example.txt root@85.31.224.248:/var/www/html/dentali/
```

**Paso 6: En el VPS, configurar y ejecutar**
```bash
cd /var/www/html/dentali

# Crear .env
cp env.example.txt .env
nano .env
# Configura: DATABASE_URL, SESSION_SECRET, PORT

# Instalar dependencias
npm install --production

# Generar Prisma
npx prisma generate --schema=prisma/schema.prisma

# Aplicar migraciones
npx prisma db push --accept-data-loss

# Compilar CSS
npm run build

# Iniciar con PM2
pm2 start ecosystem.config.js --name dentali
pm2 save
pm2 startup
```

### Opción 2: Usar Git (Si tienes repositorio)

```bash
# En el VPS
cd /var/www/html
git clone tu-repositorio.git dentali
cd dentali
cp env.example.txt .env
nano .env  # Configurar credenciales
npm install --production
npx prisma generate
npx prisma db push --accept-data-loss
npm run build
pm2 start ecosystem.config.js --name dentali
pm2 save
```

## 🔍 Verificación

```bash
# Ver estado
pm2 status

# Ver logs
pm2 logs dentali

# Acceder desde navegador
http://85.31.224.248:3005
```

## ⚠️ Problemas Comunes

1. **No se puede conectar por SSH:**
   - Verifica que el puerto 22 esté abierto
   - Verifica que el servidor esté accesible
   - Prueba: `ping 85.31.224.248`

2. **Error de permisos:**
   - Asegúrate de usar `root` o un usuario con permisos sudo

3. **MySQL no conecta:**
   - Verifica que MySQL esté corriendo: `sudo systemctl status mysql`
   - Verifica las credenciales en `.env`

## 📝 Checklist

- [ ] VPS accesible por SSH
- [ ] Node.js instalado en VPS
- [ ] MySQL instalado y base de datos creada
- [ ] Archivos subidos al VPS
- [ ] Archivo `.env` configurado
- [ ] Dependencias instaladas
- [ ] Prisma generado
- [ ] Migraciones aplicadas
- [ ] CSS compilado
- [ ] Aplicación corriendo con PM2
- [ ] Aplicación accesible desde navegador




