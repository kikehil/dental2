// Script para actualizar contraseñas de usuarios en el VPS
// Ejecutar en el VPS: node actualizar-contrasenas-vps.js

// Cargar variables de entorno
require('dotenv').config({ path: '.env' });

const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');

const prisma = new PrismaClient();

async function actualizarContrasenas() {
  try {
    console.log('Actualizando contraseñas de usuarios...\n');

    // Contraseñas conocidas (las mismas que usamos localmente)
    const usuarios = [
      {
        email: 'admin@clinica.com',
        password: 'admin123',
        nombre: 'Administrador'
      },
      {
        email: 'doctor@clinica.com',
        password: 'doctor123',
        nombre: 'Dr. Juan Martínez'
      },
      {
        email: 'recepcion@clinica.com',
        password: 'recepcion123',
        nombre: 'María García'
      }
    ];

    for (const usuario of usuarios) {
      // Generar hash de la contraseña
      const hashedPassword = await bcrypt.hash(usuario.password, 10);
      
      // Buscar y actualizar usuario
      const resultado = await prisma.usuario.updateMany({
        where: {
          email: usuario.email
        },
        data: {
          password: hashedPassword
        }
      });

      if (resultado.count > 0) {
        console.log(`✓ Contraseña actualizada para: ${usuario.email}`);
        console.log(`  Contraseña: ${usuario.password}`);
      } else {
        console.log(`✗ Usuario no encontrado: ${usuario.email}`);
      }
    }

    console.log('\n========================================');
    console.log('ACTUALIZACIÓN COMPLETADA');
    console.log('========================================');
    console.log('\nCredenciales de acceso:');
    console.log('------------------------');
    console.log('Admin:');
    console.log('  Email: admin@clinica.com');
    console.log('  Contraseña: admin123');
    console.log('\nDoctor:');
    console.log('  Email: doctor@clinica.com');
    console.log('  Contraseña: doctor123');
    console.log('\nRecepcionista:');
    console.log('  Email: recepcion@clinica.com');
    console.log('  Contraseña: recepcion123');
    console.log('\n');

  } catch (error) {
    console.error('Error al actualizar contraseñas:', error);
    process.exit(1);
  } finally {
    await prisma.$disconnect();
  }
}

actualizarContrasenas();

