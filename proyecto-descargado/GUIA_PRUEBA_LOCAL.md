# 🧪 Guía para Probar el Proyecto Localmente

Esta guía te ayudará a configurar y ejecutar el sistema de clínica dental en tu máquina local.

## 📋 Requisitos Previos

Antes de comenzar, asegúrate de tener instalado:

1. **Node.js 18 o superior**
   - Descarga desde: https://nodejs.org/
   - Verifica la instalación: `node --version`
   - Verifica npm: `npm --version`

2. **MySQL 8 o superior**
   - Descarga desde: https://dev.mysql.com/downloads/mysql/
   - Asegúrate de que el servicio MySQL esté corriendo
   - En Windows: `net start MySQL80` (o el nombre de tu servicio MySQL)

3. **Git** (opcional, si vas a clonar desde un repositorio)

## 🚀 Pasos para Configurar el Proyecto

### Paso 1: Verificar que estás en el directorio correcto

Abre PowerShell o Terminal en la carpeta del proyecto:
```powershell
cd "D:\WEB\dentali - V3 - copia\proyecto-descargado"
```

### Paso 2: Crear la base de datos MySQL

1. Abre MySQL (MySQL Workbench, phpMyAdmin, o línea de comandos)
2. Ejecuta el siguiente comando SQL:

```sql
CREATE DATABASE clinica_dental CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

O si prefieres otro nombre, puedes usar:
```sql
CREATE DATABASE dentali CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### Paso 3: Configurar variables de entorno

1. Copia el archivo de ejemplo:
   ```powershell
   copy env.example.txt .env
   ```

2. Edita el archivo `.env` con tus credenciales de MySQL:

```env
PORT=3005
NODE_ENV=development

# Base de datos - AJUSTA ESTOS VALORES
DATABASE_URL="mysql://usuario:password@localhost:3306/clinica_dental"

# Seguridad - Genera una clave secreta segura
SESSION_SECRET=tu_secret_key_muy_segura_aqui_cambiar_esto

# Cookies (false para desarrollo local)
USE_SECURE_COOKIES=false

# Zona horaria
TZ=America/Mexico_City

# Webhook (opcional)
# N8N_WEBHOOK_URL=https://tu-n8n-instance.com/webhook/xxx
```

**Importante:** 
- Reemplaza `usuario` y `password` con tus credenciales de MySQL
- Reemplaza `clinica_dental` con el nombre de tu base de datos si usaste otro
- Cambia `SESSION_SECRET` por una cadena aleatoria segura (puedes usar: `openssl rand -base64 32` o generar una aleatoria)

### Paso 4: Instalar dependencias

```powershell
npm install
```

Esto instalará todas las dependencias necesarias (Express, Prisma, Tailwind, etc.)

### Paso 5: Generar cliente de Prisma

```powershell
npx prisma generate
```

Esto genera el cliente de Prisma basado en el esquema de la base de datos.

### Paso 6: Ejecutar migraciones

```powershell
npx prisma migrate deploy
```

O si prefieres aplicar todas las migraciones pendientes:

```powershell
npx prisma migrate dev
```

Esto creará todas las tablas en tu base de datos MySQL.

### Paso 7: (Opcional) Ejecutar seed para datos de prueba

```powershell
npm run seed
```

Esto creará usuarios de prueba y datos iniciales en la base de datos.

### Paso 8: Compilar CSS de Tailwind

```powershell
npm run build
```

Esto compila los estilos de Tailwind CSS.

## ▶️ Iniciar el Servidor

### Modo Desarrollo (con recarga automática)

```powershell
npm run dev
```

### Modo Producción

```powershell
npm start
```

El servidor debería iniciar en: **http://localhost:3005**

## 👤 Usuarios de Prueba

Si ejecutaste el seed, puedes usar estos usuarios:

| Rol | Email | Contraseña |
|-----|-------|------------|
| Administrador | admin@clinica.com | admin123 |
| Doctor | doctor@clinica.com | doctor123 |
| Recepcionista | recepcion@clinica.com | recepcion123 |

## 🔧 Comandos Útiles

```powershell
# Iniciar servidor en desarrollo (con nodemon)
npm run dev

# Iniciar servidor en producción
npm start

# Compilar CSS de Tailwind
npm run build

# Ver base de datos en Prisma Studio (interfaz web)
npx prisma studio

# Generar cliente de Prisma
npx prisma generate

# Aplicar migraciones
npx prisma migrate deploy

# Ejecutar seed
npm run seed

# Ver ayuda de Prisma
npx prisma --help
```

## 🐛 Solución de Problemas Comunes

### Error: "Cannot connect to MySQL"

**Solución:**
1. Verifica que MySQL esté corriendo:
   ```powershell
   net start MySQL80
   ```
2. Verifica las credenciales en el archivo `.env`
3. Verifica que la base de datos exista:
   ```sql
   SHOW DATABASES;
   ```

### Error: "Port 3005 already in use" o "EADDRINUSE"

**Solución:**

**Opción 1: Cerrar el proceso que está usando el puerto**

1. Encuentra qué proceso está usando el puerto:
   ```powershell
   netstat -ano | findstr :3005
   ```
   Esto mostrará el PID (número de proceso) que está usando el puerto.

2. Cierra el proceso (reemplaza `PID` con el número que encontraste):
   ```powershell
   taskkill /PID [PID] /F
   ```
   Por ejemplo: `taskkill /PID 6968 /F`

3. Intenta iniciar el servidor nuevamente.

**Opción 2: Cambiar el puerto del proyecto**

1. Edita el archivo `.env` y cambia el puerto:
   ```env
   PORT=3006
   ```
   (O cualquier otro puerto disponible como 3007, 3008, etc.)

2. Reinicia el servidor.

### Error: "npm no se reconoce como comando"

**Solución:**
1. Instala Node.js desde https://nodejs.org/
2. **REINICIA** PowerShell después de instalar
3. Verifica con: `npm --version`

### Error: "Prisma Client not generated"

**Solución:**
```powershell
npx prisma generate
```

### Error: "Migration failed"

**Solución:**
1. Verifica que la base de datos exista
2. Verifica las credenciales en `.env`
3. Intenta resetear las migraciones (¡CUIDADO! Esto borrará datos):
   ```powershell
   npx prisma migrate reset
   ```

### Error: "Module not found"

**Solución:**
```powershell
npm install
```

### El CSS no se ve correctamente

**Solución:**
```powershell
npm run build
```

O en modo desarrollo, ejecuta en otra terminal:
```powershell
npm run watch:css
```

## 📁 Estructura del Proyecto

```
proyecto-descargado/
├── prisma/
│   ├── schema.prisma          # Esquema de base de datos
│   ├── migrations/            # Migraciones de Prisma
│   └── seed.js                # Datos iniciales
├── src/
│   ├── config/                # Configuración
│   ├── controllers/           # Controladores
│   ├── middleware/            # Middlewares
│   ├── routes/                # Rutas
│   ├── views/                 # Vistas EJS
│   ├── public/                # Archivos estáticos
│   └── server.js              # Servidor principal
├── .env                       # Variables de entorno (crear desde env.example.txt)
├── package.json               # Dependencias y scripts
└── tailwind.config.js         # Configuración de Tailwind
```

## ✅ Checklist de Verificación

Antes de reportar problemas, verifica:

- [ ] Node.js 18+ está instalado (`node --version`)
- [ ] MySQL está corriendo
- [ ] La base de datos `clinica_dental` existe
- [ ] El archivo `.env` existe y tiene las credenciales correctas
- [ ] Se ejecutó `npm install`
- [ ] Se ejecutó `npx prisma generate`
- [ ] Se ejecutaron las migraciones (`npx prisma migrate deploy`)
- [ ] Se compiló el CSS (`npm run build`)
- [ ] El puerto 3005 está disponible (o cambiaste el puerto en `.env`)

## 🎯 Próximos Pasos

Una vez que el servidor esté corriendo:

1. Abre tu navegador en: http://localhost:3005
2. Inicia sesión con uno de los usuarios de prueba
3. Explora las diferentes funcionalidades del sistema
4. Revisa Prisma Studio para ver los datos: `npx prisma studio`

## 📚 Recursos Adicionales

- **README.md** - Documentación general del proyecto
- **LEEME_PRIMERO.txt** - Información rápida del proyecto
- **GUIA_INSTALACION_COMPLETA.md** - Guía detallada de instalación
- **INICIO_RAPIDO.md** - Guía de inicio rápido

## 💡 Tips

- Usa `npm run dev` durante el desarrollo para recarga automática
- Usa `npx prisma studio` para ver y editar datos directamente desde el navegador
- Mantén una terminal separada con `npm run watch:css` para compilar CSS automáticamente
- Revisa los logs en la consola para identificar errores

---

¡Listo! Ahora deberías poder probar el proyecto localmente. Si tienes algún problema, revisa la sección de "Solución de Problemas Comunes" o consulta la documentación adicional.

