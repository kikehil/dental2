# Script de despliegue para NUEVO VPS (PowerShell)
# IP: 85.31.224.248
# Fecha: Enero 2026

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "DESPLIEGUE AL NUEVO VPS" -ForegroundColor Cyan
Write-Host "IP: 85.31.224.248" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Configuración
$VPS_USER = "root"
$VPS_HOST = "85.31.224.248"
$VPS_PORT = "22"
$VPS_PATH = "/var/www/html/dentali"

Write-Host "Configuración:" -ForegroundColor Yellow
Write-Host "  Usuario: $VPS_USER"
Write-Host "  Host: $VPS_HOST"
Write-Host "  Puerto: $VPS_PORT"
Write-Host "  Ruta: $VPS_PATH"
Write-Host ""

# Verificar que SSH esté disponible
$sshPath = Get-Command ssh -ErrorAction SilentlyContinue
if (-not $sshPath) {
    Write-Host "ERROR: SSH no está disponible" -ForegroundColor Red
    Write-Host "Por favor instala OpenSSH o Git para Windows" -ForegroundColor Yellow
    exit 1
}
Write-Host "✓ SSH disponible" -ForegroundColor Green

# Verificar conexión SSH
Write-Host ""
Write-Host "Verificando conexión SSH..." -ForegroundColor Yellow
$testConnection = ssh -p $VPS_PORT -o ConnectTimeout=10 -o StrictHostKeyChecking=no "$VPS_USER@$VPS_HOST" "echo Conexion exitosa" 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: No se puede conectar al servidor SSH" -ForegroundColor Red
    Write-Host "Verifica: usuario, IP, puerto y que el servidor esté accesible" -ForegroundColor Yellow
    exit 1
}
Write-Host "✓ Conexión SSH verificada" -ForegroundColor Green

Write-Host ""
$continuar = Read-Host "¿Continuar con el despliegue? (s/n)"
if ($continuar -ne "s" -and $continuar -ne "S") {
    Write-Host "Despliegue cancelado." -ForegroundColor Yellow
    exit 0
}

# Función para ejecutar comandos SSH
function Invoke-SSHCommand {
    param([string]$Command)
    ssh -p $VPS_PORT "$VPS_USER@$VPS_HOST" $Command
}

# Paso 1: Preparar servidor
Write-Host ""
Write-Host "Paso 1: Verificando preparación del servidor..." -ForegroundColor Blue
Invoke-SSHCommand "which node > /dev/null 2>&1 || (curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - ; sudo apt-get install -y nodejs)"
Invoke-SSHCommand "which pm2 > /dev/null 2>&1 || sudo npm install -g pm2"
Invoke-SSHCommand "mkdir -p $VPS_PATH"
Write-Host "✓ Servidor preparado" -ForegroundColor Green

# Paso 2: Sincronizar archivos usando SCP
Write-Host ""
Write-Host "Paso 2: Sincronizando archivos..." -ForegroundColor Blue
Write-Host "  (Esto puede tardar varios minutos...)" -ForegroundColor Gray

# Copiar archivos principales primero
$mainFiles = @("package.json", "package-lock.json", "ecosystem.config.js", "tailwind.config.js", "schema.prisma", "env.example.txt")
foreach ($file in $mainFiles) {
    if (Test-Path $file) {
        Write-Host "  Copiando: $file" -ForegroundColor Gray
        scp -P $VPS_PORT $file "${VPS_USER}@${VPS_HOST}:${VPS_PATH}/" 2>&1 | Out-Null
    }
}

# Copiar carpetas principales
$mainDirs = @("src", "prisma", "scripts")
foreach ($dir in $mainDirs) {
    if (Test-Path $dir) {
        Write-Host "  Copiando carpeta: $dir" -ForegroundColor Gray
        scp -r -P $VPS_PORT $dir "${VPS_USER}@${VPS_HOST}:${VPS_PATH}/" 2>&1 | Out-Null
    }
}

Write-Host "✓ Archivos sincronizados" -ForegroundColor Green

# Paso 3: Configurar .env
Write-Host ""
Write-Host "Paso 3: Configurando variables de entorno..." -ForegroundColor Blue
$envCheck = Invoke-SSHCommand "if [ -f $VPS_PATH/.env ]; then echo exists; else echo not_exists; fi"
if ($envCheck -match "not_exists") {
    Write-Host "  Creando .env desde env.example.txt..." -ForegroundColor Gray
    Invoke-SSHCommand "cd $VPS_PATH ; cp env.example.txt .env 2>/dev/null || echo env.example.txt no encontrado"
    Write-Host "⚠️  IMPORTANTE: Edita el archivo .env con tus credenciales:" -ForegroundColor Yellow
    Write-Host "   ssh $VPS_USER@$VPS_HOST 'nano $VPS_PATH/.env'" -ForegroundColor Cyan
    $configurado = Read-Host "¿Ya configuraste el .env? (s/n)"
    if ($configurado -ne "s" -and $configurado -ne "S") {
        Write-Host "Por favor configura el .env y vuelve a ejecutar el script" -ForegroundColor Yellow
        exit 1
    }
} else {
    Write-Host "  .env ya existe en el servidor" -ForegroundColor Gray
}

# Paso 4: Instalar dependencias
Write-Host ""
Write-Host "Paso 4: Instalando dependencias..." -ForegroundColor Blue
Invoke-SSHCommand "cd $VPS_PATH ; npm install --production"
Write-Host "✓ Dependencias instaladas" -ForegroundColor Green

# Paso 5: Generar cliente de Prisma
Write-Host ""
Write-Host "Paso 5: Generando cliente de Prisma..." -ForegroundColor Blue
Invoke-SSHCommand "cd $VPS_PATH ; npx prisma generate --schema=prisma/schema.prisma"
Write-Host "✓ Cliente de Prisma generado" -ForegroundColor Green

# Paso 6: Aplicar migraciones
Write-Host ""
Write-Host "Paso 6: Aplicando migraciones de base de datos..." -ForegroundColor Blue
$aplicar = Read-Host "¿Aplicar migraciones? (s/n)"
if ($aplicar -eq "s" -or $aplicar -eq "S") {
    Invoke-SSHCommand "cd $VPS_PATH ; npx prisma db push --accept-data-loss"
    Write-Host "✓ Migraciones aplicadas" -ForegroundColor Green
} else {
    Write-Host "  Migraciones omitidas" -ForegroundColor Gray
}

# Paso 7: Compilar CSS
Write-Host ""
Write-Host "Paso 7: Compilando CSS..." -ForegroundColor Blue
Invoke-SSHCommand "cd $VPS_PATH ; npm run build"
Write-Host "✓ CSS compilado" -ForegroundColor Green

# Paso 8: Iniciar con PM2
Write-Host ""
Write-Host "Paso 8: Iniciando aplicación con PM2..." -ForegroundColor Blue
Invoke-SSHCommand "cd $VPS_PATH ; pm2 stop dentali 2>/dev/null || echo Aplicacion no estaba corriendo"
Invoke-SSHCommand "cd $VPS_PATH ; pm2 start ecosystem.config.js --name dentali ; pm2 save"
Write-Host "✓ Aplicación iniciada" -ForegroundColor Green

# Resumen final
Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host "DESPLIEGUE COMPLETADO" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Próximos pasos:" -ForegroundColor Yellow
Write-Host "  1. Verifica que la aplicación esté corriendo:"
Write-Host "     ssh $VPS_USER@$VPS_HOST 'pm2 status'" -ForegroundColor Cyan
Write-Host ""
Write-Host "  2. Verifica los logs:"
Write-Host "     ssh $VPS_USER@$VPS_HOST 'pm2 logs dentali'" -ForegroundColor Cyan
Write-Host ""
$appUrl = "http://$VPS_HOST" + ":3005"
Write-Host "  3. Accede a: $appUrl" -ForegroundColor Cyan
Write-Host ""




