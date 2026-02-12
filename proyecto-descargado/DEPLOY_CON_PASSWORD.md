# 🔐 Despliegue con Contraseña SSH

Si el script está pidiendo la contraseña en cada operación, tienes dos opciones:

## Opción 1: Configurar Claves SSH (Recomendado)

### Paso 1: Generar clave SSH (si no tienes una)
```powershell
ssh-keygen -t rsa -b 4096
```
Presiona Enter para usar la ubicación por defecto y opcionalmente agrega una frase de contraseña.

### Paso 2: Copiar clave al servidor
```powershell
# Opción A: Usar ssh-copy-id (si está disponible)
ssh-copy-id -p 22 root@85.31.224.248

# Opción B: Manual
type $env:USERPROFILE\.ssh\id_rsa.pub | ssh root@85.31.224.248 "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

### Paso 3: Verificar
```powershell
ssh root@85.31.224.248
```
Si no pide contraseña, está configurado correctamente.

## Opción 2: Usar Script con Contraseña (Temporal)

Si no puedes configurar claves SSH, puedes modificar el script para que pida la contraseña una sola vez y la use para todas las operaciones. Sin embargo, esto es menos seguro.

### Alternativa: Despliegue Manual con WinSCP

1. **Descarga WinSCP**: https://winscp.net/
2. **Conecta al servidor**:
   - Protocolo: SFTP
   - Host: 85.31.224.248
   - Usuario: root
   - Contraseña: (tu contraseña)
3. **Sube los archivos**:
   - Arrastra las carpetas: `src`, `prisma`, `scripts`
   - Arrastra los archivos: `package.json`, `package-lock.json`, `ecosystem.config.js`, `tailwind.config.js`, `schema.prisma`, `env.example.txt`
   - Destino: `/var/www/html/dentali`
4. **Luego ejecuta los comandos manualmente en el servidor** (ver guía completa)

## Opción 3: Usar Git (Si tienes repositorio)

```bash
# En el VPS
ssh root@85.31.224.248
cd /var/www/html
git clone tu-repositorio.git dentali
cd dentali
# ... resto de configuración
```

## 🔑 Configuración Rápida de Claves SSH

Ejecuta este comando en PowerShell (te pedirá la contraseña UNA VEZ):

```powershell
# Generar clave si no existe
if (-not (Test-Path "$env:USERPROFILE\.ssh\id_rsa.pub")) {
    ssh-keygen -t rsa -b 4096 -f "$env:USERPROFILE\.ssh\id_rsa" -N '""'
}

# Copiar clave al servidor
type $env:USERPROFILE\.ssh\id_rsa.pub | ssh root@85.31.224.248 "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys && chmod 700 ~/.ssh"
```

Después de esto, el script de despliegue funcionará sin pedir contraseña.




