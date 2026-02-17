const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function check() {
    const lastCortes = await prisma.corteCaja.findMany({
        take: 5,
        orderBy: { createdAt: 'desc' },
        select: {
            id: true,
            createdAt: true,
            hora: true,
            ventasEfectivo: true,
            ventasTarjeta: true,
            ventasTransferencia: true,
            saldoFinalEfectivo: true,
            saldoFinalTarjetaAzteca: true
        }
    });

    console.log('Last 5 Cortes:');
    console.log(JSON.stringify(lastCortes, null, 2));

    // Simulating the query for ultimoResetBancos
    const ultimoResetBancos = await prisma.corteCaja.findFirst({
        where: {
            OR: [
                { hora: null },
                { AND: [{ hora: { not: null } }, { OR: [{ ventasTarjeta: { gt: 0 } }, { ventasTransferencia: { gt: 0 } }] }] },
                { AND: [{ hora: { not: null } }, { ventasEfectivo: 0 }] }
            ]
        },
        orderBy: { createdAt: 'desc' }
    });

    console.log('Detected ultimoResetBancos:', ultimoResetBancos ? { id: ultimoResetBancos.id, createdAt: ultimoResetBancos.createdAt } : 'none');
}

check().catch(console.error).finally(() => prisma.$disconnect());
