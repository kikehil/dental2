const prisma = require('../config/database');
const moment = require('moment-timezone');
const config = require('../config/config');

// Función auxiliar: Obtener saldos disponibles de todas las fuentes
const obtenerSaldosDisponibles = async () => {
  try {
    const hoy = moment().tz(config.timezone).startOf('day').toDate();
    const mañana = moment().tz(config.timezone).endOf('day').toDate();
    
    // Buscar el último corte del día (si existe)
    const ultimoCorte = await prisma.corteCaja.findFirst({
      where: {
        fecha: { gte: hoy, lte: mañana },
        hora: { not: null }, // Solo cortes, no saldos iniciales
      },
      orderBy: { createdAt: 'desc' },
    });
    
    // Buscar el saldo inicial más reciente
    let saldoInicialDelDia;
    if (ultimoCorte) {
      saldoInicialDelDia = await prisma.corteCaja.findFirst({
        where: {
          fecha: { gte: hoy, lte: mañana },
          hora: null,
          createdAt: { gt: ultimoCorte.createdAt },
        },
        orderBy: { createdAt: 'desc' },
      });
    } else {
      saldoInicialDelDia = await prisma.corteCaja.findFirst({
        where: {
          fecha: { gte: hoy, lte: mañana },
          hora: null,
        },
        orderBy: { createdAt: 'desc' },
      });
    }
    
    let desdeFecha;
    let saldoInicialEfectivo = 0;
    let saldoInicialTarjetaAzteca = 0;
    let saldoInicialTarjetaBbva = 0;
    let saldoInicialTarjetaMp = 0;
    let saldoInicialTransferenciaAzteca = 0;
    let saldoInicialTransferenciaBbva = 0;
    let saldoInicialTransferenciaMp = 0;
    
    if (!saldoInicialDelDia && ultimoCorte) {
      desdeFecha = ultimoCorte.createdAt;
      saldoInicialEfectivo = parseFloat(ultimoCorte.saldoFinalEfectivo || 0);
      saldoInicialTarjetaAzteca = parseFloat(ultimoCorte.saldoFinalTarjetaAzteca || 0);
      saldoInicialTarjetaBbva = parseFloat(ultimoCorte.saldoFinalTarjetaBbva || 0);
      saldoInicialTarjetaMp = parseFloat(ultimoCorte.saldoFinalTarjetaMp || 0);
      saldoInicialTransferenciaAzteca = parseFloat(ultimoCorte.saldoFinalTransferenciaAzteca || 0);
      saldoInicialTransferenciaBbva = parseFloat(ultimoCorte.saldoFinalTransferenciaBbva || 0);
      saldoInicialTransferenciaMp = parseFloat(ultimoCorte.saldoFinalTransferenciaMp || 0);
    } else if (saldoInicialDelDia) {
      desdeFecha = saldoInicialDelDia.createdAt;
      saldoInicialEfectivo = parseFloat(saldoInicialDelDia.saldoInicialEfectivo || 0);
      saldoInicialTarjetaAzteca = parseFloat(saldoInicialDelDia.saldoInicialTarjetaAzteca || 0);
      saldoInicialTarjetaBbva = parseFloat(saldoInicialDelDia.saldoInicialTarjetaBbva || 0);
      saldoInicialTarjetaMp = parseFloat(saldoInicialDelDia.saldoInicialTarjetaMp || 0);
      saldoInicialTransferenciaAzteca = parseFloat(saldoInicialDelDia.saldoInicialTransferenciaAzteca || 0);
      saldoInicialTransferenciaBbva = parseFloat(saldoInicialDelDia.saldoInicialTransferenciaBbva || 0);
      saldoInicialTransferenciaMp = parseFloat(saldoInicialDelDia.saldoInicialTransferenciaMp || 0);
      
      if (ultimoCorte && ultimoCorte.createdAt > saldoInicialDelDia.createdAt) {
        desdeFecha = ultimoCorte.createdAt;
        saldoInicialEfectivo = parseFloat(ultimoCorte.saldoFinalEfectivo || 0);
        saldoInicialTarjetaAzteca = parseFloat(ultimoCorte.saldoFinalTarjetaAzteca || 0);
        saldoInicialTarjetaBbva = parseFloat(ultimoCorte.saldoFinalTarjetaBbva || 0);
        saldoInicialTarjetaMp = parseFloat(ultimoCorte.saldoFinalTarjetaMp || 0);
        saldoInicialTransferenciaAzteca = parseFloat(ultimoCorte.saldoFinalTransferenciaAzteca || 0);
        saldoInicialTransferenciaBbva = parseFloat(ultimoCorte.saldoFinalTransferenciaBbva || 0);
        saldoInicialTransferenciaMp = parseFloat(ultimoCorte.saldoFinalTransferenciaMp || 0);
      }
    } else {
      desdeFecha = hoy;
    }
    
    // Obtener ventas y gastos desde la fecha base
    const [ventas, gastos] = await Promise.all([
      prisma.venta.findMany({
        where: {
          createdAt: { gte: desdeFecha },
          estado: 'completada',
        },
      }),
      prisma.gasto.findMany({
        where: {
          createdAt: { gte: desdeFecha },
        },
      }),
    ]);
    
    // Calcular saldos finales
    let ventasEfectivo = 0;
    let ventasTarjetaAzteca = 0;
    let ventasTarjetaBbva = 0;
    let ventasTarjetaMp = 0;
    let ventasTransferenciaAzteca = 0;
    let ventasTransferenciaBbva = 0;
    let ventasTransferenciaMp = 0;
    
    let gastosEfectivo = 0;
    let gastosTarjetaAzteca = 0;
    let gastosTarjetaBbva = 0;
    let gastosTarjetaMp = 0;
    let gastosTransferenciaAzteca = 0;
    let gastosTransferenciaBbva = 0;
    let gastosTransferenciaMp = 0;
    
    ventas.forEach(v => {
      const monto = parseFloat(v.total);
      if (v.metodoPago === 'efectivo') {
        ventasEfectivo += monto;
      } else if (v.metodoPago === 'tarjeta' && v.banco) {
        if (v.banco === 'Azteca') ventasTarjetaAzteca += monto;
        else if (v.banco === 'BBVA') ventasTarjetaBbva += monto;
        else if (v.banco === 'Mercado Pago') ventasTarjetaMp += monto;
      } else if (v.metodoPago === 'transferencia' && v.banco) {
        if (v.banco === 'Azteca') ventasTransferenciaAzteca += monto;
        else if (v.banco === 'BBVA') ventasTransferenciaBbva += monto;
        else if (v.banco === 'Mercado Pago') ventasTransferenciaMp += monto;
      }
    });
    
    gastos.forEach(g => {
      const monto = parseFloat(g.monto);
      if (g.metodoPago === 'efectivo') {
        gastosEfectivo += monto;
      } else if (g.metodoPago === 'tarjeta' && g.banco) {
        if (g.banco === 'Azteca') gastosTarjetaAzteca += monto;
        else if (g.banco === 'BBVA') gastosTarjetaBbva += monto;
        else if (g.banco === 'Mercado Pago') gastosTarjetaMp += monto;
      } else if (g.metodoPago === 'transferencia' && g.banco) {
        if (g.banco === 'Azteca') gastosTransferenciaAzteca += monto;
        else if (g.banco === 'BBVA') gastosTransferenciaBbva += monto;
        else if (g.banco === 'Mercado Pago') gastosTransferenciaMp += monto;
      }
    });
    
    // Calcular saldos finales por fuente
    const saldoEfectivo = saldoInicialEfectivo + ventasEfectivo - gastosEfectivo;
    const saldoAzteca = (saldoInicialTarjetaAzteca + ventasTarjetaAzteca - gastosTarjetaAzteca) +
                        (saldoInicialTransferenciaAzteca + ventasTransferenciaAzteca - gastosTransferenciaAzteca);
    const saldoBbva = (saldoInicialTarjetaBbva + ventasTarjetaBbva - gastosTarjetaBbva) +
                      (saldoInicialTransferenciaBbva + ventasTransferenciaBbva - gastosTransferenciaBbva);
    const saldoMp = (saldoInicialTarjetaMp + ventasTarjetaMp - gastosTarjetaMp) +
                    (saldoInicialTransferenciaMp + ventasTransferenciaMp - gastosTransferenciaMp);
    
    return {
      efectivo: Math.max(0, saldoEfectivo),
      azteca: Math.max(0, saldoAzteca),
      bbva: Math.max(0, saldoBbva),
      mercadopago: Math.max(0, saldoMp),
    };
  } catch (error) {
    console.error('Error al obtener saldos disponibles:', error);
    return {
      efectivo: 0,
      azteca: 0,
      bbva: 0,
      mercadopago: 0,
    };
  }
};

// Lista de préstamos agrupados por doctor
const index = async (req, res) => {
  try {
    // Verificar que el modelo prestamo esté disponible
    if (!prisma.prestamo) {
      console.error('ERROR: prisma.prestamo no está disponible. El cliente de Prisma necesita regenerarse.');
      console.error('Ejecuta: npx prisma generate');
      return res.status(500).render('error', {
        title: 'Error de Configuración',
        message: 'El modelo de préstamos no está disponible. Por favor, ejecuta "npx prisma generate" y reinicia el servidor.',
        error: { message: 'prisma.prestamo is undefined. Run: npx prisma generate' }
      });
    }

    const [prestamos, doctores, conceptos] = await Promise.all([
      prisma.prestamo.findMany({
        include: {
          doctor: true,
          concepto: true,
          usuario: true,
        },
        orderBy: { createdAt: 'desc' },
      }),
      prisma.doctor.findMany({
        where: { activo: true },
        orderBy: [{ apellido: 'asc' }, { nombre: 'asc' }],
      }),
      prisma.conceptoPrestamo.findMany({
        where: { activo: true },
        orderBy: { nombre: 'asc' },
      }),
    ]);

    // Agrupar por doctor y calcular totales
    const prestamosPorDoctor = {};
    prestamos.forEach(prestamo => {
      const doctorId = prestamo.doctorId;
      if (!prestamosPorDoctor[doctorId]) {
        prestamosPorDoctor[doctorId] = {
          doctor: prestamo.doctor,
          prestamos: [],
          totalDeuda: 0,
          totalPendiente: 0,
          totalPagado: 0,
        };
      }
      prestamosPorDoctor[doctorId].prestamos.push(prestamo);
      prestamosPorDoctor[doctorId].totalDeuda += parseFloat(prestamo.monto);
      if (prestamo.estatus === 'pendiente') {
        prestamosPorDoctor[doctorId].totalPendiente += parseFloat(prestamo.monto);
      } else {
        prestamosPorDoctor[doctorId].totalPagado += parseFloat(prestamo.monto);
      }
    });

    // Convertir a array y filtrar solo los que tienen deuda pendiente
    const doctoresConDeuda = Object.values(prestamosPorDoctor)
      .filter(item => item.totalPendiente > 0)
      .sort((a, b) => b.totalPendiente - a.totalPendiente);

    const { formatCurrency } = require('../utils/helpers');

    res.render('gastos/prestamos', {
      title: 'Préstamos al Personal',
      doctoresConDeuda,
      doctores,
      conceptos,
      formatCurrency,
    });
  } catch (error) {
    console.error('Error al cargar préstamos:', error);
    res.render('error', {
      title: 'Error',
      message: 'Error al cargar préstamos',
      error,
    });
  }
};

// Obtener detalle de préstamos de un doctor (API)
const detalle = async (req, res) => {
  try {
    const { doctorId } = req.params;

    // Obtener el doctor primero para asegurarnos de que existe
    const doctor = await prisma.doctor.findUnique({
      where: { id: parseInt(doctorId) },
    });

    if (!doctor) {
      return res.status(404).json({
        success: false,
        error: 'Doctor no encontrado',
      });
    }

    const prestamos = await prisma.prestamo.findMany({
      where: { doctorId: parseInt(doctorId) },
      include: {
        doctor: true,
        concepto: true,
        usuario: true,
      },
      orderBy: { createdAt: 'desc' },
    });

    // Calcular totales
    const totales = prestamos.reduce(
      (acc, prestamo) => {
        const monto = parseFloat(prestamo.monto);
        acc.totalDeuda += monto;
        if (prestamo.estatus === 'pendiente') {
          acc.totalPendiente += monto;
        } else {
          acc.totalPagado += monto;
        }
        return acc;
      },
      { totalDeuda: 0, totalPendiente: 0, totalPagado: 0 }
    );

    res.json({
      success: true,
      doctor,
      prestamos,
      totales,
    });
  } catch (error) {
    console.error('Error al obtener detalle:', error);
    res.status(500).json({
      success: false,
      error: 'Error al obtener detalle de préstamos',
    });
  }
};

// Crear nuevo préstamo (API)
const store = async (req, res) => {
  try {
    const { doctorId, conceptoId, monto, notas, metodoPago, banco } = req.body;

    // Validaciones
    if (!doctorId || !conceptoId || !monto || !metodoPago) {
      return res.status(400).json({
        success: false,
        error: 'Doctor, concepto, monto y método de pago son requeridos',
      });
    }

    const montoNum = parseFloat(monto);
    if (isNaN(montoNum) || montoNum <= 0) {
      return res.status(400).json({
        success: false,
        error: 'El monto debe ser mayor a 0',
      });
    }

    // Validar que si es tarjeta o transferencia, debe tener banco
    if ((metodoPago === 'tarjeta' || metodoPago === 'transferencia') && !banco) {
      return res.status(400).json({
        success: false,
        error: 'Debe seleccionar un banco para este método de pago',
      });
    }

    // Verificar que el doctor existe
    const doctor = await prisma.doctor.findUnique({
      where: { id: parseInt(doctorId) },
    });

    if (!doctor) {
      return res.status(404).json({
        success: false,
        error: 'Doctor no encontrado',
      });
    }

    // Verificar que el concepto existe
    const concepto = await prisma.conceptoPrestamo.findUnique({
      where: { id: parseInt(conceptoId) },
    });

    if (!concepto) {
      return res.status(404).json({
        success: false,
        error: 'Concepto no encontrado',
      });
    }

    // Obtener saldos disponibles
    const saldos = await obtenerSaldosDisponibles();
    
    // Validar saldo disponible según el método de pago seleccionado
    let saldoDisponible = 0;
    if (metodoPago === 'efectivo') {
      saldoDisponible = saldos.efectivo;
    } else if (metodoPago === 'tarjeta' || metodoPago === 'transferencia') {
      if (banco === 'Azteca') {
        saldoDisponible = saldos.azteca;
      } else if (banco === 'BBVA') {
        saldoDisponible = saldos.bbva;
      } else if (banco === 'Mercado Pago') {
        saldoDisponible = saldos.mercadopago;
      }
    }

    if (montoNum > saldoDisponible) {
      return res.status(400).json({
        success: false,
        error: `El monto a prestar (${montoNum.toFixed(2)}) es mayor al saldo disponible (${saldoDisponible.toFixed(2)}) en ${metodoPago === 'efectivo' ? 'EFECTIVO' : banco}`,
      });
    }

    // Crear préstamo y gasto en una transacción
    const resultado = await prisma.$transaction(async (tx) => {
      // Crear préstamo
      const prestamo = await tx.prestamo.create({
        data: {
          doctorId: parseInt(doctorId),
          conceptoId: parseInt(conceptoId),
          monto: montoNum,
          metodoPago: metodoPago || 'efectivo',
          banco: (metodoPago === 'tarjeta' || metodoPago === 'transferencia') ? banco : null,
          notas: notas || null,
          estatus: 'pendiente',
          usuarioId: req.session.user?.id || null,
        },
        include: {
          doctor: true,
          concepto: true,
          usuario: true,
        },
      });

      // Crear gasto asociado al préstamo
      const motivoGasto = `Préstamo a Dr. ${doctor.nombre} ${doctor.apellido} - ${concepto.nombre}`;
      const gasto = await tx.gasto.create({
        data: {
          motivo: motivoGasto,
          monto: montoNum,
          metodoPago: metodoPago || 'efectivo',
          banco: (metodoPago === 'tarjeta' || metodoPago === 'transferencia') ? banco : null,
          observaciones: notas || `Préstamo ID: ${prestamo.id}`,
          tipo: 'general',
          usuarioId: req.session.user?.id || null,
        },
      });

      // Descontar del saldo del método de pago seleccionado
      const hoy = moment().tz(config.timezone).startOf('day').toDate();
      const mañana = moment().tz(config.timezone).endOf('day').toDate();

      const ultimoCorte = await tx.corteCaja.findFirst({
        where: {
          fecha: { gte: hoy, lte: mañana },
        },
        orderBy: { createdAt: 'desc' },
      });

      if (ultimoCorte) {
        const updateData = {};
        
        if (metodoPago === 'efectivo') {
          const nuevoSaldo = parseFloat(ultimoCorte.saldoFinalEfectivo || 0) - montoNum;
          updateData.saldoFinalEfectivo = nuevoSaldo;
          const saldoTarjetaTotal = parseFloat(ultimoCorte.saldoFinalTarjetaAzteca || 0) + 
            parseFloat(ultimoCorte.saldoFinalTarjetaBbva || 0) + 
            parseFloat(ultimoCorte.saldoFinalTarjetaMp || 0);
          const saldoTransferenciaTotal = parseFloat(ultimoCorte.saldoFinalTransferenciaAzteca || 0) + 
            parseFloat(ultimoCorte.saldoFinalTransferenciaBbva || 0) + 
            parseFloat(ultimoCorte.saldoFinalTransferenciaMp || 0);
          updateData.saldoFinal = nuevoSaldo + saldoTarjetaTotal + saldoTransferenciaTotal;
        } else if (metodoPago === 'tarjeta') {
          if (banco === 'Azteca') {
            const nuevoSaldo = parseFloat(ultimoCorte.saldoFinalTarjetaAzteca || 0) - montoNum;
            updateData.saldoFinalTarjetaAzteca = nuevoSaldo;
            const saldoTarjetaTotal = nuevoSaldo + 
              parseFloat(ultimoCorte.saldoFinalTarjetaBbva || 0) + 
              parseFloat(ultimoCorte.saldoFinalTarjetaMp || 0);
            updateData.saldoFinal = parseFloat(ultimoCorte.saldoFinalEfectivo || 0) + 
              saldoTarjetaTotal + 
              parseFloat(ultimoCorte.saldoFinalTransferencia || 0);
          } else if (banco === 'BBVA') {
            const nuevoSaldo = parseFloat(ultimoCorte.saldoFinalTarjetaBbva || 0) - montoNum;
            updateData.saldoFinalTarjetaBbva = nuevoSaldo;
            const saldoTarjetaTotal = parseFloat(ultimoCorte.saldoFinalTarjetaAzteca || 0) + 
              nuevoSaldo + 
              parseFloat(ultimoCorte.saldoFinalTarjetaMp || 0);
            updateData.saldoFinal = parseFloat(ultimoCorte.saldoFinalEfectivo || 0) + 
              saldoTarjetaTotal + 
              parseFloat(ultimoCorte.saldoFinalTransferencia || 0);
          } else if (banco === 'Mercado Pago') {
            const nuevoSaldo = parseFloat(ultimoCorte.saldoFinalTarjetaMp || 0) - montoNum;
            updateData.saldoFinalTarjetaMp = nuevoSaldo;
            const saldoTarjetaTotal = parseFloat(ultimoCorte.saldoFinalTarjetaAzteca || 0) + 
              parseFloat(ultimoCorte.saldoFinalTarjetaBbva || 0) + 
              nuevoSaldo;
            updateData.saldoFinal = parseFloat(ultimoCorte.saldoFinalEfectivo || 0) + 
              saldoTarjetaTotal + 
              parseFloat(ultimoCorte.saldoFinalTransferencia || 0);
          }
        } else if (metodoPago === 'transferencia') {
          if (banco === 'Azteca') {
            const nuevoSaldo = parseFloat(ultimoCorte.saldoFinalTransferenciaAzteca || 0) - montoNum;
            updateData.saldoFinalTransferenciaAzteca = nuevoSaldo;
            const saldoTransferenciaTotal = nuevoSaldo + 
              parseFloat(ultimoCorte.saldoFinalTransferenciaBbva || 0) + 
              parseFloat(ultimoCorte.saldoFinalTransferenciaMp || 0);
            updateData.saldoFinalTransferencia = saldoTransferenciaTotal;
            const saldoTarjetaTotal = parseFloat(ultimoCorte.saldoFinalTarjetaAzteca || 0) + 
              parseFloat(ultimoCorte.saldoFinalTarjetaBbva || 0) + 
              parseFloat(ultimoCorte.saldoFinalTarjetaMp || 0);
            updateData.saldoFinal = parseFloat(ultimoCorte.saldoFinalEfectivo || 0) + 
              saldoTarjetaTotal + 
              saldoTransferenciaTotal;
          } else if (banco === 'BBVA') {
            const nuevoSaldo = parseFloat(ultimoCorte.saldoFinalTransferenciaBbva || 0) - montoNum;
            updateData.saldoFinalTransferenciaBbva = nuevoSaldo;
            const saldoTransferenciaTotal = parseFloat(ultimoCorte.saldoFinalTransferenciaAzteca || 0) + 
              nuevoSaldo + 
              parseFloat(ultimoCorte.saldoFinalTransferenciaMp || 0);
            updateData.saldoFinalTransferencia = saldoTransferenciaTotal;
            const saldoTarjetaTotal = parseFloat(ultimoCorte.saldoFinalTarjetaAzteca || 0) + 
              parseFloat(ultimoCorte.saldoFinalTarjetaBbva || 0) + 
              parseFloat(ultimoCorte.saldoFinalTarjetaMp || 0);
            updateData.saldoFinal = parseFloat(ultimoCorte.saldoFinalEfectivo || 0) + 
              saldoTarjetaTotal + 
              saldoTransferenciaTotal;
          } else if (banco === 'Mercado Pago') {
            const nuevoSaldo = parseFloat(ultimoCorte.saldoFinalTransferenciaMp || 0) - montoNum;
            updateData.saldoFinalTransferenciaMp = nuevoSaldo;
            const saldoTransferenciaTotal = parseFloat(ultimoCorte.saldoFinalTransferenciaAzteca || 0) + 
              parseFloat(ultimoCorte.saldoFinalTransferenciaBbva || 0) + 
              nuevoSaldo;
            updateData.saldoFinalTransferencia = saldoTransferenciaTotal;
            const saldoTarjetaTotal = parseFloat(ultimoCorte.saldoFinalTarjetaAzteca || 0) + 
              parseFloat(ultimoCorte.saldoFinalTarjetaBbva || 0) + 
              parseFloat(ultimoCorte.saldoFinalTarjetaMp || 0);
            updateData.saldoFinal = parseFloat(ultimoCorte.saldoFinalEfectivo || 0) + 
              saldoTarjetaTotal + 
              saldoTransferenciaTotal;
          }
        }

        await tx.corteCaja.update({
          where: { id: ultimoCorte.id },
          data: updateData,
        });
      }

      return { prestamo, gasto };
    });

    res.json({
      success: true,
      prestamo: resultado.prestamo,
      message: 'Préstamo registrado exitosamente',
    });
  } catch (error) {
    console.error('Error al crear préstamo:', error);
    res.status(500).json({
      success: false,
      error: error.message || 'Error al crear préstamo',
      details: process.env.NODE_ENV === 'development' ? error.stack : undefined,
    });
  }
};

// Actualizar estatus de préstamo (API)
const updateEstatus = async (req, res) => {
  try {
    const { prestamoId } = req.params;
    const { estatus } = req.body;

    // Validaciones
    if (!estatus || !['pendiente', 'pagado'].includes(estatus)) {
      return res.status(400).json({
        success: false,
        error: 'Estatus inválido. Debe ser "pendiente" o "pagado"',
      });
    }

    // Actualizar préstamo
    const prestamo = await prisma.prestamo.update({
      where: { id: parseInt(prestamoId) },
      data: { estatus },
      include: {
        doctor: true,
        concepto: true,
        usuario: true,
      },
    });

    res.json({
      success: true,
      prestamo,
      message: 'Estatus actualizado exitosamente',
    });
  } catch (error) {
    console.error('Error al actualizar estatus:', error);
    res.status(500).json({
      success: false,
      error: 'Error al actualizar estatus',
    });
  }
};

// Lista de conceptos de préstamos
const indexConceptos = async (req, res) => {
  try {
    const conceptos = await prisma.conceptoPrestamo.findMany({
      orderBy: { nombre: 'asc' },
    });

    res.render('gastos/conceptos-prestamos', {
      title: 'Conceptos de Préstamos',
      conceptos,
    });
  } catch (error) {
    console.error('Error al cargar conceptos:', error);
    res.render('error', {
      title: 'Error',
      message: 'Error al cargar conceptos',
      error,
    });
  }
};

// Crear concepto (API)
const storeConcepto = async (req, res) => {
  try {
    const { nombre, descripcion } = req.body;

    if (!nombre || nombre.trim() === '') {
      return res.status(400).json({
        success: false,
        error: 'El nombre es requerido',
      });
    }

    const concepto = await prisma.conceptoPrestamo.create({
      data: {
        nombre: nombre.trim(),
        descripcion: descripcion?.trim() || null,
        activo: true,
      },
    });

    res.json({
      success: true,
      concepto,
      message: 'Concepto creado exitosamente',
    });
  } catch (error) {
    console.error('Error al crear concepto:', error);
    res.status(500).json({
      success: false,
      error: 'Error al crear concepto',
    });
  }
};

// Actualizar concepto (API)
const updateConcepto = async (req, res) => {
  try {
    const { conceptoId } = req.params;
    const { nombre, descripcion, activo } = req.body;

    if (!nombre || nombre.trim() === '') {
      return res.status(400).json({
        success: false,
        error: 'El nombre es requerido',
      });
    }

    const concepto = await prisma.conceptoPrestamo.update({
      where: { id: parseInt(conceptoId) },
      data: {
        nombre: nombre.trim(),
        descripcion: descripcion?.trim() || null,
        activo: activo === true || activo === 'true',
      },
    });

    res.json({
      success: true,
      concepto,
      message: 'Concepto actualizado exitosamente',
    });
  } catch (error) {
    console.error('Error al actualizar concepto:', error);
    res.status(500).json({
      success: false,
      error: 'Error al actualizar concepto',
    });
  }
};

// Obtener saldos disponibles (API)
const obtenerSaldos = async (req, res) => {
  try {
    const saldos = await obtenerSaldosDisponibles();
    res.json({
      success: true,
      saldos,
    });
  } catch (error) {
    console.error('Error al obtener saldos:', error);
    res.status(500).json({
      success: false,
      error: 'Error al obtener saldos disponibles',
    });
  }
};

module.exports = {
  index,
  detalle,
  store,
  updateEstatus,
  indexConceptos,
  storeConcepto,
  updateConcepto,
  obtenerSaldos,
};

