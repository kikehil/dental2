const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');
require('dotenv').config();

const prisma = new PrismaClient();

async function resetPassword() {
    const email = process.argv[2] || 'admin@clinica.com';
    const newPassword = process.argv[3] || 'admin123';

    if (!email) {
        console.log('Uso: node reset-password.js <email> <nueva_password>');
        process.exit(1);
    }

    try {
        const hashedPassword = await bcrypt.hash(newPassword, 10);

        const usuario = await prisma.usuario.update({
            where: { email: email },
            data: { password: hashedPassword }
        });

        console.log(`✅ Contraseña actualizada exitosamente para: ${email}`);
        console.log(`🔑 Nueva contraseña: ${newPassword}`);
    } catch (error) {
        if (error.code === 'P2025') {
            console.error(`❌ Error: No se encontró el usuario con email: ${email}`);
        } else {
            console.error('❌ Error al actualizar la contraseña:', error);
        }
    } finally {
        await prisma.$disconnect();
    }
}

resetPassword();
