const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function main() {
    const lastCortes = await prisma.corteCaja.findMany({
        take: 5,
        orderBy: { createdAt: 'desc' },
        select: {
            id: true,
            fecha: true,
            hora: true,
            ventasEfectivo: true,
            ventasTarjeta: true,
            ventasTransferencia: true,
            saldoFinalEfectivo: true,
            saldoFinalTarjetaAzteca: true,
            saldoFinalTarjetaBbva: true,
            saldoFinalTarjetaMp: true,
            saldoFinalTransferencia: true,
            createdAt: true
        }
    });

    console.log('Last 5 Cortes:');
    console.log(JSON.stringify(lastCortes, null, 2));

    // Also check if there are sales after the last bank reset
    const ultimoResetBancos = await prisma.corteCaja.findFirst({
        where: {
            OR: [
                { AND: [{ hora: { not: null } }, { OR: [{ ventasTarjeta: { gt: 0 } }, { ventasTransferencia: { gt: 0 } }] }] },
                { AND: [{ hora: { not: null } }, { ventasEfectivo: 0 }] },
                { AND: [{ hora: null }, { OR: [{ saldoInicialTarjetaAzteca: { gt: 0 } }, { saldoInicialTarjetaBbva: { gt: 0 } }, { saldoInicialTarjetaMp: { gt: 0 } }, { saldoInicialTransferencia: { gt: 0 } }] }] }
            ]
        },
        orderBy: { createdAt: 'desc' }
    });

    if (ultimoResetBancos) {
        console.log('\nUltimo Reset Bancos found:', {
            id: ultimoResetBancos.id,
            createdAt: ultimoResetBancos.createdAt,
            saldoFinalTarjetaAzteca: ultimoResetBancos.saldoFinalTarjetaAzteca
        });
        const ventasBancos = await prisma.venta.findMany({
            where: { createdAt: { gte: ultimoResetBancos.createdAt }, metodoPago: { in: ['tarjeta', 'transferencia'] } }
        });
        console.log(`Ventas since last reset: ${ventasBancos.length}`);
        ventasBancos.forEach(v => console.log(`- Venta: ${v.total} (${v.metodoPago}) at ${v.createdAt}`));
    } else {
        console.log('\nNo bank reset found.');
    }
}

main().catch(console.error).finally(() => prisma.$disconnect());
