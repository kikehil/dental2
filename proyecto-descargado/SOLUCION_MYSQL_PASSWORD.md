# 🔐 Solución: Acceso Denegado MySQL

## Situación Actual

MySQL está pidiendo contraseña, lo que significa que la contraseña ya está configurada. Necesitas conectarte usando la contraseña.

## Solución: Conectarse con Contraseña

### Opción 1: Conectarse con la contraseña configurada

```bash
# En el VPS, ejecuta:
mysql -u root -p
# Cuando pida la contraseña, ingresa: Netbios85*
```

### Opción 2: Si no recuerdas la contraseña - Resetear

Si no puedes conectarte, resetea la contraseña:

```bash
# 1. Detener MySQL
sudo systemctl stop mysql

# 2. Iniciar MySQL en modo seguro (sin verificación de contraseñas)
sudo mysqld_safe --skip-grant-tables --skip-networking &

# 3. Esperar 3 segundos
sleep 3

# 4. Conectar sin contraseña
mysql -u root

# 5. Dentro de MySQL, ejecutar:
USE mysql;
ALTER USER 'root'@'localhost' IDENTIFIED BY 'Netbios85*';
FLUSH PRIVILEGES;
EXIT;

# 6. Detener MySQL en modo seguro
sudo pkill mysqld

# 7. Reiniciar MySQL normalmente
sudo systemctl start mysql

# 8. Probar conexión
mysql -u root -p
# Ingresa: Netbios85*
```

### Opción 3: Usar mysqladmin (más simple)

Si MySQL está corriendo pero no recuerdas la contraseña:

```bash
# Detener MySQL
sudo systemctl stop mysql

# Iniciar en modo seguro
sudo mysqld_safe --skip-grant-tables --skip-networking &

# Esperar
sleep 3

# Conectar y resetear
mysql -u root << EOF
USE mysql;
ALTER USER 'root'@'localhost' IDENTIFIED BY 'Netbios85*';
FLUSH PRIVILEGES;
EXIT;
EOF

# Detener modo seguro
sudo pkill mysqld

# Reiniciar
sudo systemctl start mysql
```

## Verificar que Funciona

```bash
mysql -u root -p
# Ingresa: Netbios85*
# Si puedes conectarte, está funcionando correctamente
```

## Crear la Base de Datos

Una vez que puedas conectarte:

```bash
mysql -u root -p
# Ingresa: Netbios85*

# Dentro de MySQL:
CREATE DATABASE IF NOT EXISTS clinica_dental CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
SHOW DATABASES;
EXIT;
```

## Nota Importante

La contraseña que configuraste es: **Netbios85***

Guarda esta información para usarla en:
- El archivo `.env` del VPS
- Los scripts de backup
- Cualquier conexión a MySQL




