require('dotenv').config();
const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

async function test() {
  try {
    console.log('Probando conexión a la base de datos...');
    console.log('DATABASE_URL:', process.env.DATABASE_URL ? 'Configurada' : 'NO configurada');
    
    const usuarios = await prisma.usuario.findMany({
      select: {
        email: true,
        nombre: true,
        rol: true,
        activo: true,
      },
      take: 5,
    });
    
    console.log('✅ Conexión exitosa!');
    console.log('Usuarios encontrados:', usuarios.length);
    usuarios.forEach(u => {
      console.log(`  - ${u.email} (${u.nombre}) - Rol: ${u.rol} - Activo: ${u.activo}`);
    });
  } catch (error) {
    console.error('❌ Error de conexión:', error.message);
  } finally {
    await prisma.$disconnect();
  }
}

test();





