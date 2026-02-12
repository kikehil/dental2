// Script alternativo para actualizar contraseñas usando MySQL directamente
// Ejecutar en el VPS: node actualizar-contrasenas-vps-mysql.js

const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');

// Configuración de conexión (ajusta según tu .env)
const dbConfig = {
  host: 'localhost',
  user: 'root',
  password: 'Netbios85*',
  database: 'clinica_dental'
};

async function actualizarContrasenas() {
  let connection;
  
  try {
    console.log('Conectando a la base de datos...\n');
    
    // Conectar a MySQL
    connection = await mysql.createConnection(dbConfig);
    console.log('✓ Conexión exitosa a MySQL\n');
    
    console.log('Actualizando contraseñas de usuarios...\n');

    // Contraseñas conocidas
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
      
      // Actualizar usuario en la base de datos
      const [resultado] = await connection.execute(
        'UPDATE usuarios SET password = ? WHERE email = ?',
        [hashedPassword, usuario.email]
      );

      if (resultado.affectedRows > 0) {
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
    console.error('Error al actualizar contraseñas:', error.message);
    if (error.code === 'ER_ACCESS_DENIED_ERROR') {
      console.error('\nERROR: Credenciales de MySQL incorrectas');
      console.error('Verifica la contraseña en el script o en el archivo .env');
    }
    process.exit(1);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

actualizarContrasenas();




