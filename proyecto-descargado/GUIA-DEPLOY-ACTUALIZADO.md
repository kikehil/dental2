# Guía de Despliegue Actualizado al VPS

## 🚀 Despliegue Seguro sin Perder Datos

Esta guía te ayudará a subir las actualizaciones del proyecto al VPS sin perder información de la base de datos.

### ⚠️ IMPORTANTE ANTES DE EMPEZAR

1. **Asegúrate de haber probado todo localmente**
2. **Haz commit de tus cambios** (si usas Git)
3. **Verifica que las migraciones funcionen localmente**

---

## 📋 Opción 1: Script Automático (Recomendado)

### Para Linux/Mac:

```bash
chmod +x deploy-vps-completo.sh
./deploy-vps-completo.sh
```

### Para Windows:

```cmd
deploy-vps-windows-completo.bat
```

El script automáticamente:
1. ✅ Crea backup de la base de datos
2. ✅ Detiene la aplicación
3. ✅ Sincroniza archivos (Git o rsync)
4. ✅ Instala dependencias
5. ✅ Regenera Prisma Client
6. ✅ Aplica migraciones
7. ✅ Verifica tablas nuevas
8. ✅ Reinicia la aplicación

---

## 📋 Opción 2: Pasos Manuales

Si prefieres hacerlo paso a paso:

### Paso 1: Backup de Base de Datos

**En el VPS:**
```bash
ssh root@147.93.118.121
cd /var/www/html/dentali

# Obtener credenciales
DB_URL=$(grep DATABASE_URL .env | cut -d '=' -f2- | tr -d '"' | tr -d "'")
DB_USER=$(echo $DB_URL | sed -n 's/.*:\/\/\([^:]*\):.*/\1/p')
DB_PASS=$(echo $DB_URL | sed -n 's/.*:\/\/[^:]*:\([^@]*\)@.*/\1/p')
DB_HOST=$(echo $DB_URL | sed -n 's/.*@\([^:]*\):.*/\1/p')
DB_PORT=$(echo $DB_URL | sed -n 's/.*:\([0-9]*\)\/.*/\1/p')
DB_NAME=$(echo $DB_URL | sed -n 's/.*\/\([^?]*\).*/\1/p')

# Crear backup
mkdir -p backups
mysqldump -h "$DB_HOST" -P "${DB_PORT:-3306}" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > backups/backup_$(date +%Y%m%d_%H%M%S).sql
gzip backups/backup_*.sql
```

### Paso 2: Detener Aplicación

```bash
pm2 stop dentali
```

### Paso 3: Sincronizar Archivos

**Opción A: Usando Git (si tienes repositorio)**
```bash
cd /var/www/html/dentali
git fetch origin
git pull origin main
```

**Opción B: Usando rsync (desde tu máquina local)**
```bash
rsync -avz --progress \
  --exclude='.env' \
  --exclude='.git' \
  --exclude='node_modules' \
  --exclude='*.log' \
  --exclude='backups' \
  --exclude='uploads' \
  ./ root@147.93.118.121:/var/www/html/dentali/
```

### Paso 4: Instalar Dependencias

```bash
cd /var/www/html/dentali
npm install --production
```

### Paso 5: Regenerar Prisma Client

```bash
npx prisma generate
```

### Paso 6: Aplicar Migraciones

```bash
# Verificar estado
npx prisma migrate status

# Aplicar migraciones
npx prisma migrate deploy
```

Si `migrate deploy` falla, usar:
```bash
npx prisma db push --accept-data-loss
```

### Paso 7: Verificar Tablas Nuevas

```bash
# Verificar que la tabla laboratorios existe
mysql -h "$DB_HOST" -P "${DB_PORT:-3306}" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "SHOW TABLES LIKE 'laboratorios';"

# Si no existe, crearla manualmente (ver script deploy-vps-completo.sh)
```

### Paso 8: Reiniciar Aplicación

```bash
pm2 restart dentali
# O si no existe:
pm2 start ecosystem.config.js --name dentali
pm2 save
```

---

## 🔍 Verificación Post-Despliegue

1. **Verificar que la aplicación esté corriendo:**
   ```bash
   pm2 status
   pm2 logs dentali --lines 50
   ```

2. **Verificar tablas nuevas:**
   ```bash
   mysql -h "$DB_HOST" -P "${DB_PORT:-3306}" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "SHOW TABLES;"
   ```

3. **Verificar columnas nuevas en gastos:**
   ```bash
   mysql -h "$DB_HOST" -P "${DB_PORT:-3306}" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "SHOW COLUMNS FROM gastos;"
   ```

4. **Probar funcionalidades nuevas:**
   - Acceder a `/laboratorios`
   - Acceder a `/gastos/laboratorio`
   - Verificar que los pagos a laboratorios se registren correctamente

---

## 🆘 Solución de Problemas

### Error: "Unknown field `laboratorio` for include"

**Solución:** Regenerar Prisma Client
```bash
npx prisma generate
```

### Error: "Table `laboratorios` does not exist"

**Solución:** Crear la tabla manualmente (ver Paso 7)

### Error: "Migration failed"

**Solución:** Usar `db push` en lugar de `migrate deploy`
```bash
npx prisma db push --accept-data-loss
```

### Error: "Cannot read properties of undefined"

**Solución:** Verificar que Prisma Client esté actualizado
```bash
npx prisma generate
pm2 restart dentali
```

---

## 📝 Migraciones que se Aplicarán

1. **20251228230418_add_tratamientos_plazo** - Tablas de tratamientos a plazos
2. **20250101000001_add_laboratorios** - Tabla de laboratorios
3. **20250101000002_add_gasto_laboratorio** - Campos nuevos en gastos (tipo, laboratorioId, pacienteId)

---

## ✅ Checklist Final

- [ ] Backup creado exitosamente
- [ ] Archivos sincronizados
- [ ] Dependencias instaladas
- [ ] Prisma Client regenerado
- [ ] Migraciones aplicadas
- [ ] Tablas nuevas verificadas
- [ ] Aplicación reiniciada
- [ ] Funcionalidades nuevas probadas

---

## 🔄 Restaurar desde Backup (si es necesario)

Si algo sale mal, puedes restaurar el backup:

```bash
cd /var/www/html/dentali
gunzip backups/backup_YYYYMMDD_HHMMSS.sql.gz
mysql -h "$DB_HOST" -P "${DB_PORT:-3306}" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < backups/backup_YYYYMMDD_HHMMSS.sql
```

---

**Nota:** Los scripts están configurados para el VPS en `147.93.118.121`. Si tu VPS tiene otra IP, edita las variables `VPS_HOST` en los scripts.



