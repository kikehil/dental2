const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function fixMigration() {
  try {
    console.log('🔧 Resolviendo problema de migraciones...\n');

    // Eliminar la migración fallida que no existe localmente
    console.log('🗑️  Eliminando migración fallida 20251210212941_add_transferencia_banco_saldos...');
    
    const result = await prisma.$executeRawUnsafe(`
      DELETE FROM _prisma_migrations 
      WHERE migration_name = '20251210212941_add_transferencia_banco_saldos'
    `);

    console.log(`✅ Migración fallida eliminada (${result} registro(s) eliminado(s))\n`);

    console.log('✅ Problema resuelto!');
    console.log('\n📋 Próximos pasos:');
    console.log('   1. Ejecuta: npx prisma migrate deploy');
    console.log('   2. Ejecuta: npx prisma generate');
    console.log('   3. Verifica: npx prisma migrate status\n');

  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  } finally {
    await prisma.$disconnect();
  }
}

fixMigration();

