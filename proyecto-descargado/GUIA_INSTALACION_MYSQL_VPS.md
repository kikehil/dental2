# 🗄️ Guía: Instalar MySQL en el VPS

## Opción 1: Script Automático (Recomendado)

Ejecuta desde Windows:
```cmd
instalar-mysql-vps.bat
```

Este script:
- ✅ Actualiza el sistema
- ✅ Instala MySQL Server y Client
- ✅ Configura MySQL para uso local
- ✅ Inicia y habilita el servicio

## Opción 2: Instalación Manual

Si prefieres hacerlo manualmente, conecta al VPS:

```bash
ssh root@85.31.224.248
```

### Paso 1: Actualizar sistema
```bash
apt update
```

### Paso 2: Instalar MySQL
```bash
# Opción A: MySQL
DEBIAN_FRONTEND=noninteractive apt install -y mysql-server mysql-client

# Opción B: MariaDB (alternativa)
DEBIAN_FRONTEND=noninteractive apt install -y mariadb-server mariadb-client
```

### Paso 3: Iniciar y habilitar MySQL
```bash
systemctl start mysql
systemctl enable mysql
```

### Paso 4: Configurar MySQL
```bash
# Verificar que MySQL esté corriendo
systemctl status mysql

# Probar conexión
mysql -u root
```

Si pide contraseña y no la tienes configurada, puedes resetearla:

```bash
# Detener MySQL
systemctl stop mysql

# Iniciar MySQL en modo seguro
mysqld_safe --skip-grant-tables &

# Conectar sin contraseña
mysql -u root

# Dentro de MySQL, ejecutar:
USE mysql;
UPDATE user SET authentication_string=PASSWORD('') WHERE User='root';
UPDATE user SET plugin='mysql_native_password' WHERE User='root';
FLUSH PRIVILEGES;
EXIT;

# Reiniciar MySQL normalmente
systemctl restart mysql
```

### Paso 5: Crear base de datos
```bash
mysql -u root -e "CREATE DATABASE dentali CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
```

O si tu base de datos tiene otro nombre:
```bash
mysql -u root -e "CREATE DATABASE clinica_dental CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
```

## Verificar Instalación

```bash
# Ver versión
mysql --version

# Ver estado del servicio
systemctl status mysql

# Listar bases de datos
mysql -u root -e "SHOW DATABASES;"
```

## Solución de Problemas

### Error: "Access denied for user 'root'@'localhost'"

```bash
# Resetear contraseña de root
sudo mysql
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '';
FLUSH PRIVILEGES;
EXIT;
```

### Error: "Can't connect to local MySQL server"

```bash
# Verificar que MySQL esté corriendo
systemctl status mysql

# Si no está corriendo, iniciarlo
systemctl start mysql
```

### Error: "Package 'mysql-server' has no installation candidate"

```bash
# Actualizar repositorios
apt update
apt upgrade

# Intentar con MariaDB
apt install mariadb-server mariadb-client
```

## Configuración de Seguridad (Opcional)

Para mejorar la seguridad, ejecuta:
```bash
mysql_secure_installation
```

Esto te permitirá:
- Establecer contraseña para root
- Remover usuarios anónimos
- Deshabilitar login remoto de root
- Remover base de datos de prueba

## Próximos Pasos

Una vez instalado MySQL:

1. **Crear la base de datos:**
   ```cmd
   crear-bdd-vps.bat
   ```

2. **Hacer backup y subir:**
   ```cmd
   backup-y-subir-vps.bat
   ```

3. **Configurar .env en el VPS:**
   - Asegúrate de que `DATABASE_URL` apunte a la base de datos correcta
   - Ejemplo: `DATABASE_URL="mysql://root:@localhost:3306/dentali"`




