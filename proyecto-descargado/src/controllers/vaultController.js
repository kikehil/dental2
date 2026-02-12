const prisma = require('../config/database');
const moment = require('moment-timezone');
const config = require('../config/config');
const { formatUsd } = require('../utils/helpers');

const rangoDia = () => {
  const inicio = moment().tz(config.timezone).startOf('day').toDate();
  const fin = moment().tz(config.timezone).endOf('day').toDate();
  return { inicio, fin };
};

const obtenerIngresosUsdHoy = async () => {
  const { inicio, fin } = rangoDia();

  // Ventas registradas en USD
  const ventasUsd = await prisma.venta.findMany({
    where: {
      createdAt: { gte: inicio, lte: fin },
      moneda: 'USD',
    },
    select: { total: true, metodoPago: true, banco: true },
  });

  // Ingresos manuales de Vault
  const ingresosManual = await prisma.vaultMovimiento.findMany({
    where: {
      tipo: 'ingreso',
      createdAt: { gte: inicio, lte: fin },
    },
    select: { monto: true, metodo: true, banco: true },
  });

  const ingresosLista = [
    ...ventasUsd.map(v => ({
      monto: parseFloat(v.total),
      metodo: v.metodoPago,
      banco: v.banco,
    })),
    ...ingresosManual.map(i => ({
      monto: parseFloat(i.monto),
      metodo: i.metodo,
      banco: i.banco,
    })),
  ];

  const resumen = {
    efectivo: 0,
    tarjeta: {
      total: 0,
      bbva: 0,
      azteca: 0,
      mercadopago: 0,
    },
    transferencia: {
      total: 0,
      bbva: 0,
      azteca: 0,
      mercadopago: 0,
    },
  };

  ingresosLista.forEach(i => {
    if (i.metodo === 'efectivo') {
      resumen.efectivo += i.monto;
    } else if (i.metodo === 'tarjeta') {
      resumen.tarjeta.total += i.monto;
      if (i.banco) {
        const bancoLower = i.banco.toLowerCase();
        if (bancoLower === 'bbva') resumen.tarjeta.bbva += i.monto;
        else if (bancoLower === 'azteca') resumen.tarjeta.azteca += i.monto;
        else if (bancoLower === 'mercadopago' || bancoLower === 'mercado pago') resumen.tarjeta.mercadopago += i.monto;
      }
    } else if (i.metodo === 'transferencia') {
      resumen.transferencia.total += i.monto;
      if (i.banco) {
        const bancoLower = i.banco.toLowerCase();
        if (bancoLower === 'bbva') resumen.transferencia.bbva += i.monto;
        else if (bancoLower === 'azteca') resumen.transferencia.azteca += i.monto;
        else if (bancoLower === 'mercadopago' || bancoLower === 'mercado pago') resumen.transferencia.mercadopago += i.monto;
      }
    }
  });

  const total = ingresosLista.reduce((sum, i) => sum + i.monto, 0);

  return { total, resumen };
};

const obtenerTrasladosHoy = async () => {
  const { inicio, fin } = rangoDia();
  const traslados = await prisma.vaultMovimiento.findMany({
    where: {
      tipo: 'traslado_ahorro',
      createdAt: { gte: inicio, lte: fin },
    },
    select: { monto: true },
  });
  return traslados.reduce((sum, t) => sum + parseFloat(t.monto), 0);
};

const obtenerAhorroActual = async () => {
  const movimientos = await prisma.vaultMovimiento.findMany({
    where: {
      tipo: { in: ['traslado_ahorro', 'retiro_ahorro'] },
    },
    select: { tipo: true, monto: true },
  });

  const totalTrasladado = movimientos
    .filter(m => m.tipo === 'traslado_ahorro')
    .reduce((sum, m) => sum + parseFloat(m.monto), 0);

  const totalRetirado = movimientos
    .filter(m => m.tipo === 'retiro_ahorro')
    .reduce((sum, m) => sum + parseFloat(m.monto), 0);

  return totalTrasladado - totalRetirado;
};

// Vista principal de Vault
const index = async (req, res) => {
  try {
    const { inicio, fin } = rangoDia();

    const [ingresos, trasladadoHoy, ahorroActual, movimientosHoy] =
      await Promise.all([
        obtenerIngresosUsdHoy(),
        obtenerTrasladosHoy(),
        obtenerAhorroActual(),
        prisma.vaultMovimiento.findMany({
          where: { createdAt: { gte: inicio, lte: fin } },
          orderBy: { createdAt: 'desc' },
        }),
      ]);

    const saldoDisponible = Math.max(0, ingresos.total - trasladadoHoy);

    res.render('vault/index', {
      title: 'Vault',
      ingresosTotal: ingresos.total,
      ingresosDetalle: ingresos.resumen,
      saldoDisponible,
      ahorroActual,
      trasladadoHoy,
      movimientosHoy,
      formatUsd,
      moment,
      config,
    });
  } catch (error) {
    console.error('Error al cargar Vault:', error);
    res.render('error', {
      title: 'Error',
      message: 'No se pudo cargar Vault',
      error,
    });
  }
};

// Registrar ingreso manual en USD
const registrarIngreso = async (req, res) => {
  try {
    const { monto, metodo, banco, nota } = req.body;
    const cantidad = parseFloat(monto);
    const metodosValidos = ['efectivo', 'tarjeta', 'transferencia'];
    const bancosValidos = ['bbva', 'azteca', 'mercadopago', 'mercado pago'];

    if (isNaN(cantidad) || cantidad <= 0) {
      return res.status(400).json({ error: 'Monto inválido' });
    }

    if (!metodosValidos.includes(metodo)) {
      return res.status(400).json({ error: 'Método de ingreso no permitido' });
    }

    // Validar banco si es tarjeta o transferencia
    if ((metodo === 'tarjeta' || metodo === 'transferencia') && banco) {
      const bancoLower = banco.toLowerCase();
      if (!bancosValidos.includes(bancoLower)) {
        return res.status(400).json({ error: 'Banco no válido' });
      }
    }

    await prisma.vaultMovimiento.create({
      data: {
        tipo: 'ingreso',
        metodo,
        banco: (metodo === 'tarjeta' || metodo === 'transferencia') && banco ? banco : null,
        monto: cantidad,
        nota: nota || null,
        usuarioId: req.session.user?.id || null,
      },
    });

    res.json({ success: true });
  } catch (error) {
    console.error('Error al registrar ingreso USD:', error);
    res.status(500).json({ error: 'No se pudo registrar el ingreso' });
  }
};

// Trasladar saldo diario a ahorro
const moverAhorro = async (req, res) => {
  try {
    const { monto, nota } = req.body;
    const cantidad = parseFloat(monto);

    if (isNaN(cantidad) || cantidad <= 0) {
      return res.status(400).json({ error: 'Monto inválido' });
    }

    const ingresos = await obtenerIngresosUsdHoy();
    const trasladadoHoy = await obtenerTrasladosHoy();
    const saldoDisponible = Math.max(0, ingresos.total - trasladadoHoy);

    if (cantidad > saldoDisponible) {
      return res.status(400).json({ error: 'El monto supera el saldo disponible del día' });
    }

    await prisma.vaultMovimiento.create({
      data: {
        tipo: 'traslado_ahorro',
        metodo: 'ahorro',
        monto: cantidad,
        nota: nota || 'Traslado a ahorro desde saldo diario',
        usuarioId: req.session.user?.id || null,
      },
    });

    res.json({ success: true });
  } catch (error) {
    console.error('Error al mover a ahorro:', error);
    res.status(500).json({ error: 'No se pudo mover a ahorro' });
  }
};

// Retirar desde ahorro a efectivo o bancos
const retirarAhorro = async (req, res) => {
  try {
    const { monto, metodo, nota } = req.body;
    const cantidad = parseFloat(monto);
    const metodosValidos = ['efectivo', 'bbva', 'mercadopago', 'azteca'];

    if (isNaN(cantidad) || cantidad <= 0) {
      return res.status(400).json({ error: 'Monto inválido' });
    }

    if (!metodosValidos.includes(metodo)) {
      return res.status(400).json({ error: 'Selecciona un método de retiro válido' });
    }

    const ahorroActual = await obtenerAhorroActual();
    if (cantidad > ahorroActual) {
      return res.status(400).json({ error: 'El monto supera el ahorro disponible' });
    }

    // Guardar movimiento de retiro
    await prisma.vaultMovimiento.create({
      data: {
        tipo: 'retiro_ahorro',
        metodo,
        banco: metodo !== 'efectivo' ? metodo : null,
        monto: cantidad,
        nota: nota || 'Retiro desde ahorro',
        usuarioId: req.session.user?.id || null,
      },
    });

    res.json({ success: true });
  } catch (error) {
    console.error('Error al retirar ahorro:', error);
    res.status(500).json({ error: 'No se pudo registrar el retiro' });
  }
};

module.exports = {
  index,
  registrarIngreso,
  moverAhorro,
  retirarAhorro,
};




