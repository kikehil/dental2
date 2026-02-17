const fs = require('fs');
const path = 'd:\\WEB\\dentali - V3 - copia\\src\\controllers\\posController.js';
let content = fs.readFileSync(path, 'utf8');

const newBankResetQuery = `      where: {
        OR: [
          { AND: [{ hora: { not: null } }, { OR: [{ ventasTarjeta: { gt: 0 } }, { ventasTransferencia: { gt: 0 } }] }] },
          { AND: [{ hora: { not: null } }, { ventasEfectivo: 0 }] },
          { AND: [{ hora: null }, { OR: [{ saldoInicialTarjetaAzteca: { gt: 0 } }, { saldoInicialTarjetaBbva: { gt: 0 } }, { saldoInicialTarjetaMp: { gt: 0 } }, { saldoInicialTransferencia: { gt: 0 } }] }] }
        ]
      },`;

const bankQueryRegex = /const ultimoResetBancos = await prisma\.corteCaja\.findFirst\(\{\s+where: \{\s+OR: \[\s+\{ hora: null \},\s+\{ AND: \[\{ hora: \{ not: null \} \}, \{ OR: \[\{ ventasTarjeta: \{ gt: 0 \} \}, \{ ventasTransferencia: \{ gt: 0 \} \}\] \}\] \},\s+\{ AND: \[\{ hora: \{ not: null \} \}, \{ ventasEfectivo: 0 \}\] \}\s+\]\s+\},\s+orderBy: \{ createdAt: 'desc' \}\s+\}\);/g;

const beforeCount = (content.match(bankQueryRegex) || []).length;
content = content.replace(bankQueryRegex, `const ultimoResetBancos = await prisma.corteCaja.findFirst({
${newBankResetQuery}
      orderBy: { createdAt: 'desc' }
    });`);

content = content.replace(/const desdeFechaBancos = ultimoResetBancos \? ultimoResetBancos\.createdAt : hoy;/g, "const desdeFechaBancos = ultimoResetBancos ? ultimoResetBancos.createdAt : new Date(0);");

fs.writeFileSync(path, content, 'utf8');
console.log(`Replaced ${beforeCount} bank reset blocks. Fallbacks updated.`);
