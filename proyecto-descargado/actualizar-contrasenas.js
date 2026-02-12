const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');

const prisma = new PrismaClient();

async function main() {
  console.log('🔐 Actualizando contraseñas de usuarios...');

  // Contraseñas que queremos establecer
  const passwordAdmin = await bcrypt.hash('admin123', 10);
  const passwordDoctor = await bcrypt.hash('doctor123', 10);
  const passwordRecepcion = await bcrypt.hash('recepcion123', 10);

  // Actualizar admin
  const admin = await prisma.usuario.update({
    where: { email: 'admin@clinica.com' },
    data: { password: passwordAdmin },
  });
  console.log('✅ Contraseña actualizada para:', admin.email);

  // Actualizar doctor
  const doctor = await prisma.usuario.update({
    where: { email: 'doctor@clinica.com' },
    data: { password: passwordDoctor },
  });
  console.log('✅ Contraseña actualizada para:', doctor.email);

  // Actualizar recepcionista
  const recepcion = await prisma.usuario.update({
    where: { email: 'recepcion@clinica.com' },
    data: { password: passwordRecepcion },
  });
  console.log('✅ Contraseña actualizada para:', recepcion.email);

  console.log('');
  console.log('📋 Credenciales de acceso:');
  console.log('   - admin@clinica.com / admin123');
  console.log('   - doctor@clinica.com / doctor123');
  console.log('   - recepcion@clinica.com / recepcion123');
  console.log('');
  console.log('✅ ¡Contraseñas actualizadas exitosamente!');
}

main()
  .catch((e) => {
    console.error('❌ Error:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });





