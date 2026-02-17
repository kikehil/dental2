const prisma = require('../config/database');
const bcrypt = require('bcryptjs');
const moment = require('moment-timezone');
const config = require('../config/config');
const { generateFolio, formatCurrency } = require('../utils/helpers');
const { notifyNewSale } = require('../utils/webhooks');

// Función auxiliar para obtener el último corte de caja del día
const getUltimoCorteHoy = async () => {
  const hoy = moment().tz(config.timezone).startOf('day').toDate();
  const mañana = moment().tz(config.timezone).endOf('day').toDate();

  const ultimoCorte = await prisma.corteCaja.findFirst({
    where: {
      fecha: { gte: hoy, lte: mañana },
    },
    orderBy: { createdAt: 'desc' },
  });

  return ultimoCorte;
};

// Función auxiliar para obtener configuración de cortes
const getConfiguracionCortes = async () => {
  let configCortes = await prisma.configuracionCortes.findFirst({
    where: { activo: true },
  });

  // Si no existe configuración, crear una con valores por defecto
  if (!configCortes) {
    configCortes = await prisma.configuracionCortes.create({
      data: {
        horaCorte1: '14:00',
        horaCorte2: '18:00',
        activo: true,
      },
    });
  }

  return configCortes;
};

// Mostrar punto de venta
const index = async (req, res) => {
  try {
    console.log('=== ACCESO A POS ===');
    console.log('Usuario en sesión:', req.session?.user ? JSON.stringify(req.session.user) : 'No hay sesión');
    console.log('Query params:', req.query);
    const ultimoCorte = await getUltimoCorteHoy();

    // Verificar si necesita saldo inicial
    // 1. Si viene del login con el parámetro
    // 2. No hay saldo inicial hoy
    // 3. Si hay cualquier corte hoy (automático o manual), necesita saldo inicial
    //    porque después de cualquier corte, al día siguiente se necesita saldo inicial
    const hoy = moment().tz(config.timezone).startOf('day').toDate();
    const mañana = moment().tz(config.timezone).endOf('day').toDate();
    const ayer = moment().tz(config.timezone).subtract(1, 'day').startOf('day').toDate();
    const finAyer = moment().tz(config.timezone).subtract(1, 'day').endOf('day').toDate();

    // Buscar el último corte del día (si existe)
    const ultimoCorteHoy = await prisma.corteCaja.findFirst({
      where: {
        fecha: { gte: hoy, lte: mañana },
        hora: { not: null }, // Solo cortes, no saldos iniciales
      },
      orderBy: { createdAt: 'desc' },
    });

    // Buscar el saldo inicial más reciente (después del último corte si existe)
    let saldoInicialHoy;
    if (ultimoCorteHoy) {
      // Si hay un corte, buscar el saldo inicial creado DESPUÉS de ese corte
      saldoInicialHoy = await prisma.corteCaja.findFirst({
        where: {
          fecha: { gte: hoy, lte: mañana },
          hora: null,
          createdAt: { gt: ultimoCorteHoy.createdAt }, // Después del último corte
        },
        orderBy: { createdAt: 'desc' },
      });
    } else {
      // Si no hay corte, buscar cualquier saldo inicial del día
      saldoInicialHoy = await prisma.corteCaja.findFirst({
        where: {
          fecha: { gte: hoy, lte: mañana },
          hora: null,
        },
        orderBy: { createdAt: 'desc' },
      });
    }

    // Necesita saldo inicial si:
    // - Viene con el parámetro necesitaSaldoInicial=true (siempre mostrar, sin importar si hay saldo inicial)
    // - No hay saldo inicial después del último corte (si hay corte)
    // - No hay saldo inicial del día (si no hay corte)
    const necesitaSaldoInicial =
      req.query.necesitaSaldoInicial === 'true' ||
      !saldoInicialHoy;

    // PRIORIDAD 1: Si necesita saldo inicial, mostrar modal primero (no importa si necesita corte)
    // El saldo inicial es más importante que el corte - debe ingresarse antes de cualquier corte
    // Si viene con el parámetro necesitaSaldoInicial=true, siempre mostrar el modal
    // Obtener tipo de cambio activo
    const configTipoCambio = await prisma.configuracionTipoCambio.findFirst({
      where: { activo: true },
    });
    const tipoCambio = configTipoCambio ? parseFloat(configTipoCambio.tipoCambio) : 20.0;

    if (necesitaSaldoInicial) {
      // Obtener saldo actual de efectivo después de retiros (si hay corte previo)
      let saldoPredefinido = 0;
      const saldoPredefinidoParam = req.query.saldoPredefinido;

      if (saldoPredefinidoParam) {
        saldoPredefinido = parseFloat(saldoPredefinidoParam) || 0;
      } else if (ultimoCorteHoy) {
        // Si hay corte pero no viene saldo predefinido, calcular el saldo actual después de retiros
        let desdeFecha;
        let saldoInicialEfectivo = 0;

        desdeFecha = ultimoCorteHoy.createdAt;
        saldoInicialEfectivo = parseFloat(ultimoCorteHoy.saldoFinalEfectivo || 0);

        // Obtener ventas y gastos desde el último corte
        const ventas = await prisma.venta.findMany({
          where: {
            createdAt: { gte: desdeFecha },
            metodoPago: 'efectivo',
          },
          select: { total: true },
        });

        const gastos = await prisma.gasto.findMany({
          where: {
            createdAt: { gte: desdeFecha },
            metodoPago: 'efectivo',
          },
          select: { monto: true },
        });

        const ventasEfectivo = ventas.reduce((sum, v) => sum + parseFloat(v.total), 0);
        const gastosEfectivo = gastos.reduce((sum, g) => sum + parseFloat(g.monto), 0);
        saldoPredefinido = saldoInicialEfectivo + ventasEfectivo - gastosEfectivo;
      }

      // Cargar categorías de forma segura (puede no existir aún)
      let categorias = [];
      try {
        if (prisma.categoria && typeof prisma.categoria.findMany === 'function') {
          categorias = await prisma.categoria.findMany({ where: { activo: true }, orderBy: { nombre: 'asc' } });
        }
      } catch (error) {
        console.warn('Categorías no disponibles aún:', error.message);
        categorias = [];
      }

      const [servicios, productos, pacientes, doctores] = await Promise.all([
        prisma.servicio.findMany({
          where: { activo: true },
          include: prisma.categoria ? { categoria: true } : false,
          orderBy: { nombre: 'asc' }
        }),
        prisma.producto.findMany({ where: { activo: true }, orderBy: { nombre: 'asc' } }),
        prisma.paciente.findMany({ where: { activo: true }, take: 100, orderBy: [{ apellido: 'asc' }, { nombre: 'asc' }] }),
        prisma.doctor.findMany({ where: { activo: true }, orderBy: [{ apellido: 'asc' }, { nombre: 'asc' }] }),
      ]);

      // Preparar datos JSON para los componentes de búsqueda
      const pacientesDataJson = JSON.stringify(pacientes.map(p => ({ id: p.id, text: p.nombre + ' ' + p.apellido })));
      const doctoresDataJson = JSON.stringify(doctores.map(d => ({ id: d.id, text: 'Dr. ' + d.nombre + ' ' + d.apellido })));

      return res.render('pos/index', {
        title: 'Punto de Venta',
        servicios,
        productos,
        pacientes,
        doctores,
        categorias,
        formatCurrency,
        tipoCambio,
        necesitaSaldoInicial: true,
        saldoPredefinido: saldoPredefinido,
        ultimoCorte: null,
        pacientesDataJson,
        doctoresDataJson,
      });
    }

    // Cargar categorías de forma segura (puede no existir aún)
    let categorias = [];
    try {
      if (prisma.categoria && typeof prisma.categoria.findMany === 'function') {
        categorias = await prisma.categoria.findMany({ where: { activo: true }, orderBy: { nombre: 'asc' } });
      }
    } catch (error) {
      console.warn('Categorías no disponibles aún:', error.message);
      categorias = [];
    }

    const [servicios, productos, pacientes, doctores] = await Promise.all([
      prisma.servicio.findMany({
        where: { activo: true },
        include: prisma.categoria ? { categoria: true } : false,
        orderBy: { nombre: 'asc' }
      }),
      prisma.producto.findMany({ where: { activo: true }, orderBy: { nombre: 'asc' } }),
      prisma.paciente.findMany({ where: { activo: true }, take: 100, orderBy: [{ apellido: 'asc' }, { nombre: 'asc' }] }),
      prisma.doctor.findMany({ where: { activo: true }, orderBy: [{ apellido: 'asc' }, { nombre: 'asc' }] }),
    ]);

    // Preparar datos JSON para los componentes de búsqueda
    const pacientesDataJson = JSON.stringify(pacientes.map(p => ({ id: p.id, text: p.nombre + ' ' + p.apellido })));
    const doctoresDataJson = JSON.stringify(doctores.map(d => ({ id: d.id, text: 'Dr. ' + d.nombre + ' ' + d.apellido })));

    res.render('pos/index', {
      title: 'Punto de Venta',
      servicios,
      productos,
      pacientes,
      doctores,
      pacientesDataJson,
      doctoresDataJson,
      categorias,
      formatCurrency,
      tipoCambio,
      necesitaSaldoInicial: false,
    });
  } catch (error) {
    console.error('Error al cargar POS:', error);
    res.render('error', { title: 'Error', message: 'Error al cargar punto de venta', error });
  }
};

// Procesar venta
const processSale = async (req, res) => {
  try {
    const { pacienteId, doctorId, items, descuento, metodoPago, banco, moneda, notas } = req.body;

    if (!items || items.length === 0) {
      return res.status(400).json({ error: 'No hay items en la venta' });
    }

    // Calcular totales
    let subtotal = 0;
    const itemsData = [];

    for (const item of items) {
      const itemSubtotal = parseFloat(item.precio) * parseInt(item.cantidad);
      subtotal += itemSubtotal;

      itemsData.push({
        tipo: item.tipo,
        servicioId: item.tipo === 'servicio' ? parseInt(item.id) : null,
        productoId: item.tipo === 'producto' ? parseInt(item.id) : null,
        cantidad: parseInt(item.cantidad),
        precioUnit: parseFloat(item.precio),
        subtotal: itemSubtotal,
      });

      // Actualizar stock si es producto
      if (item.tipo === 'producto') {
        await prisma.producto.update({
          where: { id: parseInt(item.id) },
          data: { stock: { decrement: parseInt(item.cantidad) } },
        });
      }
    }

    const descuentoAmount = parseFloat(descuento) || 0;
    const total = subtotal - descuentoAmount;

    // Guardar método de pago sin modificar (solo 'efectivo', 'tarjeta' o 'transferencia')
    // El banco se guarda por separado en el campo banco
    const metodoPagoFinal = metodoPago || 'efectivo';

    // Crear venta
    const venta = await prisma.venta.create({
      data: {
        folio: generateFolio(),
        pacienteId: pacienteId ? parseInt(pacienteId) : null,
        doctorId: doctorId ? parseInt(doctorId) : null,
        subtotal,
        descuento: descuentoAmount,
        total,
        metodoPago: metodoPagoFinal,
        banco: (metodoPago === 'tarjeta' || metodoPago === 'transferencia') ? (banco || null) : null,
        moneda: moneda || 'MXN',
        notas: notas || null,
        items: { create: itemsData },
      },
      include: {
        items: {
          include: {
            servicio: true,
            producto: true,
          },
        },
        paciente: true,
      },
    });

    // Procesar abonos si existen en el carrito
    const abonosEnCarrito = items.filter(item => item.tipo === 'abono');
    if (abonosEnCarrito.length > 0) {
      for (const abonoItem of abonosEnCarrito) {
        if (abonoItem.abonoId) {
          await prisma.abonoTratamiento.update({
            where: { id: parseInt(abonoItem.abonoId) },
            data: { ventaId: venta.id },
          });
        }
      }
    }

    // Enviar webhook
    await notifyNewSale(venta, venta.items, venta.paciente);

    res.json({
      success: true,
      venta: {
        id: venta.id,
        folio: venta.folio,
        total: formatCurrency(venta.total),
        totalNumero: parseFloat(venta.total), // Valor numérico para cálculos
      },
    });
  } catch (error) {
    console.error('Error al procesar venta:', error);
    res.status(500).json({ error: 'Error al procesar la venta' });
  }
};

// Historial de ventas
const ventas = async (req, res) => {
  try {
    const { fecha } = req.query;

    // Calcular inicio y fin del día
    const hoy = fecha ? new Date(fecha) : new Date();
    const inicioDia = new Date(hoy.getFullYear(), hoy.getMonth(), hoy.getDate(), 0, 0, 0);
    const finDia = new Date(hoy.getFullYear(), hoy.getMonth(), hoy.getDate(), 23, 59, 59);

    // Obtener ventas del día (por defecto solo el día actual)
    const whereClause = {
      createdAt: { gte: inicioDia, lte: finDia }
    };

    const ventasList = await prisma.venta.findMany({
      where: whereClause,
      include: {
        paciente: true,
        items: {
          include: {
            servicio: true,
            producto: true,
          },
        },
        abonosTratamiento: {
          include: {
            tratamientoPlazo: {
              include: {
                paciente: true,
                doctor: true,
                servicio: true,
              },
            },
          },
        },
      },
      orderBy: { createdAt: 'desc' },
      take: 100,
    });

    // Obtener resumen del día de HOY
    const hoyInicio = new Date();
    hoyInicio.setHours(0, 0, 0, 0);
    const hoyFin = new Date();
    hoyFin.setHours(23, 59, 59, 999);

    const ventasHoy = await prisma.venta.findMany({
      where: {
        createdAt: { gte: hoyInicio, lte: hoyFin }
      },
      select: {
        total: true,
        metodoPago: true,
        banco: true,
      },
    });

    // Calcular estadísticas
    const totalHoy = ventasHoy.reduce((sum, v) => sum + parseFloat(v.total), 0);
    const cantidadHoy = ventasHoy.length;
    const promedio = cantidadHoy > 0 ? totalHoy / cantidadHoy : 0;

    // Método más popular
    const metodos = {};
    ventasHoy.forEach(v => {
      metodos[v.metodoPago] = (metodos[v.metodoPago] || 0) + 1;
    });
    const metodoPopular = Object.keys(metodos).length > 0
      ? Object.keys(metodos).reduce((a, b) => metodos[a] > metodos[b] ? a : b)
      : 'N/A';

    // Calcular estado de caja de la sesión actual
    const hoyCaja = moment().tz(config.timezone).startOf('day').toDate();
    const mañanaCaja = moment().tz(config.timezone).endOf('day').toDate();

    const saldoInicialDelDia = await prisma.corteCaja.findFirst({
      where: {
        fecha: { gte: hoyCaja, lte: mañanaCaja },
        hora: null,
      },
    });

    const ultimoCorte = await prisma.corteCaja.findFirst({
      where: {
        fecha: { gte: hoyCaja, lte: mañanaCaja },
        hora: { not: null },
      },
      orderBy: { createdAt: 'desc' },
    });

    let saldoInicial = 0;
    let ventasDesdeUltimoCorte = [];

    if (ultimoCorte) {
      saldoInicial = parseFloat(ultimoCorte.saldoFinal);
      const desdeUltimoCorte = ultimoCorte.createdAt;

      ventasDesdeUltimoCorte = await prisma.venta.findMany({
        where: {
          createdAt: { gte: desdeUltimoCorte },
        },
        select: {
          total: true,
          metodoPago: true,
        },
      });
    } else if (saldoInicialDelDia) {
      saldoInicial = parseFloat(saldoInicialDelDia.saldoInicial);
      const desdeSaldoInicial = saldoInicialDelDia.createdAt;

      ventasDesdeUltimoCorte = await prisma.venta.findMany({
        where: {
          createdAt: { gte: desdeSaldoInicial },
        },
        select: {
          total: true,
          metodoPago: true,
        },
      });
    } else {
      const hoyInicio = moment().tz(config.timezone).startOf('day').toDate();
      ventasDesdeUltimoCorte = await prisma.venta.findMany({
        where: {
          createdAt: { gte: hoyInicio },
        },
        select: {
          total: true,
          metodoPago: true,
        },
      });
    }

    const totalVentasSesion = ventasDesdeUltimoCorte.reduce((sum, v) => sum + parseFloat(v.total), 0);
    const ventasEfectivoSesion = ventasDesdeUltimoCorte
      .filter(v => v.metodoPago === 'efectivo')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);
    const ventasTarjetaSesion = ventasDesdeUltimoCorte
      .filter(v => v.metodoPago === 'tarjeta')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);
    const ventasTransferenciaSesion = ventasDesdeUltimoCorte
      .filter(v => v.metodoPago === 'transferencia')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);

    const saldoEsperado = saldoInicial + ventasEfectivoSesion;

    res.render('pos/ventas', {
      title: 'Historial de Ventas',
      ventas: ventasList,
      formatCurrency,
      resumen: {
        ventasHoy: cantidadHoy,
        totalHoy: formatCurrency(totalHoy),
        promedio: formatCurrency(promedio),
        metodoPopular: metodoPopular,
      },
      estadoCaja: {
        saldoInicial,
        totalVentas: totalVentasSesion,
        ventasEfectivo: ventasEfectivoSesion,
        ventasTarjeta: ventasTarjetaSesion,
        ventasTransferencia: ventasTransferenciaSesion,
        saldoEsperado,
        cantidadVentas: ventasDesdeUltimoCorte.length,
      },
    });
  } catch (error) {
    console.error('Error al cargar ventas:', error);
    res.render('error', { title: 'Error', message: 'Error al cargar ventas', error });
  }
};

// Gestión de servicios
const servicios = async (req, res) => {
  try {
    // Cargar categorías de forma segura (puede no existir aún)
    let categorias = [];
    try {
      if (prisma.categoria && typeof prisma.categoria.findMany === 'function') {
        categorias = await prisma.categoria.findMany({
          where: { activo: true },
          orderBy: { nombre: 'asc' },
        });
      }
    } catch (error) {
      console.warn('Categorías no disponibles aún:', error.message);
      categorias = [];
    }

    const serviciosList = await prisma.servicio.findMany({
      include: prisma.categoria ? { categoria: true } : false,
      orderBy: { nombre: 'asc' },
    });

    res.render('pos/servicios', {
      title: 'Gestión de Servicios',
      servicios: serviciosList,
      categorias,
      formatCurrency,
    });
  } catch (error) {
    console.error('Error al cargar servicios:', error);
    res.render('error', { title: 'Error', message: 'Error al cargar servicios', error });
  }
};

// Crear/Actualizar servicio
const saveServicio = async (req, res) => {
  try {
    const { id, nombre, descripcion, precio, duracion, categoriaId, activo } = req.body;

    const data = {
      nombre,
      descripcion,
      precio: parseFloat(precio),
      duracion: parseInt(duracion),
      activo: activo === 'true',
    };

    // Usar categoriaId si se proporciona
    if (categoriaId && categoriaId !== '' && categoriaId !== 'null') {
      data.categoriaId = parseInt(categoriaId);
    } else {
      data.categoriaId = null;
    }

    if (id) {
      await prisma.servicio.update({
        where: { id: parseInt(id) },
        data,
      });
    } else {
      await prisma.servicio.create({
        data: {
          ...data,
          duracion: parseInt(duracion) || 30,
        },
      });
    }

    res.json({ success: true });
  } catch (error) {
    console.error('Error al guardar servicio:', error);
    res.status(500).json({ error: 'Error al guardar servicio' });
  }
};

// Gestión de productos
const productos = async (req, res) => {
  try {
    const productosList = await prisma.producto.findMany({
      orderBy: { nombre: 'asc' },
    });

    // Alertas de stock bajo
    const stockBajo = productosList.filter(p => p.stock <= p.stockMinimo && p.activo);

    res.render('pos/productos', {
      title: 'Gestión de Productos',
      productos: productosList,
      stockBajo,
      formatCurrency,
    });
  } catch (error) {
    console.error('Error al cargar productos:', error);
    res.render('error', { title: 'Error', message: 'Error al cargar productos', error });
  }
};

// Crear/Actualizar producto
const saveProducto = async (req, res) => {
  try {
    const { id, nombre, descripcion, precio, costo, stock, stockMinimo, categoria, activo } = req.body;

    if (id) {
      await prisma.producto.update({
        where: { id: parseInt(id) },
        data: {
          nombre,
          descripcion,
          precio: parseFloat(precio),
          costo: costo ? parseFloat(costo) : null,
          stock: parseInt(stock),
          stockMinimo: parseInt(stockMinimo),
          categoria,
          activo: activo === 'true',
        },
      });
    } else {
      await prisma.producto.create({
        data: {
          nombre,
          descripcion,
          precio: parseFloat(precio),
          costo: costo ? parseFloat(costo) : null,
          stock: parseInt(stock) || 0,
          stockMinimo: parseInt(stockMinimo) || 5,
          categoria,
        },
      });
    }

    res.json({ success: true });
  } catch (error) {
    console.error('Error al guardar producto:', error);
    res.status(500).json({ error: 'Error al guardar producto' });
  }
};

// Ver detalle de venta
const getVenta = async (req, res) => {
  try {
    const venta = await prisma.venta.findUnique({
      where: { id: parseInt(req.params.id) },
      include: {
        paciente: true,
        items: {
          include: {
            servicio: true,
            producto: true,
          },
        },
      },
    });

    if (!venta) {
      return res.status(404).json({ error: 'Venta no encontrada' });
    }

    res.json(venta);
  } catch (error) {
    console.error('Error al obtener venta:', error);
    res.status(500).json({ error: 'Error al obtener venta' });
  }
};

// Guardar saldo inicial
const guardarSaldoInicial = async (req, res) => {
  try {
    const {
      saldoInicial,
      saldoInicialEfectivo,
      saldoInicialTarjeta,
      saldoInicialTransferencia
    } = req.body;

    // Si vienen saldos individuales, usarlos; si no, usar el saldo inicial único
    let efectivo = 0;
    let tarjeta = 0;
    let transferencia = 0;

    if (saldoInicialEfectivo !== undefined || saldoInicialTarjeta !== undefined || saldoInicialTransferencia !== undefined) {
      efectivo = parseFloat(saldoInicialEfectivo || 0);
      tarjeta = parseFloat(saldoInicialTarjeta || 0);
      transferencia = parseFloat(saldoInicialTransferencia || 0);
    } else {
      // Compatibilidad con frontend antiguo
      const saldo = parseFloat(saldoInicial || 0);
      if (isNaN(saldo) || saldo < 0) {
        return res.status(400).json({ error: 'Saldo inicial inválido. Debe ser un número mayor o igual a 0' });
      }
      efectivo = saldo; // Por defecto, todo va a efectivo
    }

    // Validar que todos los saldos sean números válidos
    if (isNaN(efectivo) || efectivo < 0 || isNaN(tarjeta) || tarjeta < 0 || isNaN(transferencia) || transferencia < 0) {
      return res.status(400).json({ error: 'Los saldos iniciales deben ser números mayores o iguales a 0' });
    }

    // Permitir crear múltiples saldos iniciales en el mismo día
    // Esto es necesario porque después de cada corte se debe crear un nuevo saldo inicial
    // No validamos si ya existe uno, simplemente creamos uno nuevo
    // --- Lógica de Herencia de Bancos para Saldo Inicial ---
    // Si no se proporcionaron saldos de bancos (o son 0), heredamos los actuales para no romper la acumulación multidía
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

    let sTA = tarjeta, sTB = 0, sTM = 0;
    let sTrA = transferencia, sTrB = 0, sTrM = 0;

    if (tarjeta === 0 && ultimoResetBancos) {
      sTA = parseFloat(ultimoResetBancos.saldoFinalTarjetaAzteca || 0);
      sTB = parseFloat(ultimoResetBancos.saldoFinalTarjetaBbva || 0);
      sTM = parseFloat(ultimoResetBancos.saldoFinalTarjetaMp || 0);
    }
    if (transferencia === 0 && ultimoResetBancos) {
      sTrA = parseFloat(ultimoResetBancos.saldoFinalTransferenciaAzteca || 0);
      sTrB = parseFloat(ultimoResetBancos.saldoFinalTransferenciaBbva || 0);
      sTrM = parseFloat(ultimoResetBancos.saldoFinalTransferenciaMp || 0);
    }

    const sTT = sTA + sTB + sTM;
    const sTrT = sTrA + sTrB + sTrM;
    const saldoInicialTotal = efectivo + sTT + sTrT;

    // Crear registro de saldo inicial (sin hora específica)
    await prisma.corteCaja.create({
      data: {
        fecha: new Date(),
        hora: null,
        saldoInicial: saldoInicialTotal,
        saldoInicialEfectivo: efectivo,
        saldoInicialTarjetaAzteca: sTA,
        saldoInicialTarjetaBbva: sTB,
        saldoInicialTarjetaMp: sTM,
        saldoInicialTransferencia: sTrT,
        ventasEfectivo: 0,
        ventasTarjeta: 0,
        ventasTransferencia: 0,
        ventasTarjetaAzteca: 0,
        ventasTarjetaBbva: 0,
        ventasTarjetaMp: 0,
        ventasTransferenciaAzteca: 0,
        ventasTransferenciaBbva: 0,
        ventasTransferenciaMp: 0,
        totalVentas: 0,
        saldoFinal: saldoInicialTotal,
        saldoFinalEfectivo: efectivo,
        saldoFinalTarjetaAzteca: sTA,
        saldoFinalTarjetaBbva: sTB,
        saldoFinalTarjetaMp: sTM,
        saldoFinalTransferencia: sTrT,
        saldoFinalTransferenciaAzteca: sTrA,
        saldoFinalTransferenciaBbva: sTrB,
        saldoFinalTransferenciaMp: sTrM,
        diferencia: 0,
        observaciones: null,
        usuarioId: req.session.user?.id || null,
      },
    });

    res.json({ success: true });
  } catch (error) {
    console.error('Error al guardar saldo inicial:', error);
    // Mostrar mensaje de error más específico
    let mensajeError = 'Error al guardar saldo inicial';

    // Mensajes de error más específicos según el tipo de error
    if (error.code === 'P2002') {
      mensajeError = 'Ya existe un registro con estos datos';
    } else if (error.code === 'P2003') {
      mensajeError = 'Error de referencia en la base de datos';
    } else if (error.message) {
      mensajeError = error.message;
    }

    res.status(500).json({ error: mensajeError });
  }
};

// Funciones helper para manejar método de pago y banco
const getMetodoBase = (metodoPago) => {
  if (!metodoPago) return 'efectivo';
  const metodo = metodoPago.toLowerCase();
  if (metodo === 'efectivo') return 'efectivo';
  if (metodo.includes('tarjeta') || metodo.includes('mercado pago')) return 'tarjeta';
  if (metodo.includes('transferencia')) return 'transferencia';
  return metodoPago;
};

const getBanco = (v) => {
  if (v.banco) return v.banco;
  const metodo = v.metodoPago || '';
  if (metodo.includes('BBVA')) return 'BBVA';
  if (metodo.includes('Azteca')) return 'Azteca';
  if (metodo.includes('Mercado Pago')) return 'Mercado Pago';
  return null;
};

// Mostrar vista de corte de caja
const mostrarCorte = async (req, res) => {
  try {
    const { hora } = req.query;

    // Si no viene hora, redirigir al POS
    if (!hora) {
      return res.redirect('/pos');
    }

    // Validar formato de hora (HH:MM) - permitir cualquier hora, no solo las configuradas
    const horaRegex = /^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/;
    if (!horaRegex.test(hora)) {
      return res.redirect('/pos');
    }

    // Verificar que haya saldo inicial antes de permitir hacer un corte
    const hoy = moment().tz(config.timezone).startOf('day').toDate();
    const mañana = moment().tz(config.timezone).endOf('day').toDate();
    const saldoInicialHoy = await prisma.corteCaja.findFirst({
      where: {
        fecha: { gte: hoy, lte: mañana },
        hora: null,
      },
    });

    // Si no hay saldo inicial, redirigir al POS para que lo ingrese primero
    if (!saldoInicialHoy) {
      return res.redirect('/pos?necesitaSaldoInicial=true');
    }

    // Obtener configuración de cortes para verificar si es el segundo corte (fin día)
    const configCortes = await getConfiguracionCortes();
    const esFinDia = hora === configCortes.horaCorte2;

    // Buscar el saldo inicial del día o el último corte
    const saldoInicialDelDia = await prisma.corteCaja.findFirst({
      where: {
        fecha: { gte: hoy, lte: mañana },
        hora: null,
      },
    });

    const ultimoCorte = await prisma.corteCaja.findFirst({
      where: {
        fecha: { gte: hoy, lte: mañana },
        hora: { not: null },
      },
      orderBy: { createdAt: 'desc' },
    });

    // Determinar desde cuándo contar las ventas
    let desdeFecha;
    let saldoInicial;
    let saldoInicialEfectivo;

    if (ultimoCorte) {
      desdeFecha = ultimoCorte.createdAt;
      saldoInicial = parseFloat(ultimoCorte.saldoFinal);
      saldoInicialEfectivo = parseFloat(ultimoCorte.saldoFinalEfectivo || 0);
    } else if (saldoInicialDelDia) {
      desdeFecha = saldoInicialDelDia.createdAt;
      saldoInicial = parseFloat(saldoInicialDelDia.saldoInicial);
      saldoInicialEfectivo = parseFloat(saldoInicialDelDia.saldoInicialEfectivo || 0);
    } else {
      // No hay saldo inicial ni cortes, usar inicio del día
      desdeFecha = hoy;
      saldoInicial = 0;
      saldoInicialEfectivo = 0;
    }

    // Obtener ventas desde el último corte o saldo inicial
    const ventas = await prisma.venta.findMany({
      where: {
        createdAt: { gte: desdeFecha },
      },
      include: {
        paciente: true,
        doctor: true,
        items: {
          include: {
            servicio: true,
            producto: true,
          },
        },
      },
      orderBy: { createdAt: 'asc' },
    });

    // Obtener gastos del período
    const gastos = await prisma.gasto.findMany({
      where: {
        createdAt: { gte: desdeFecha },
      },
      include: {
        usuario: {
          select: {
            nombre: true,
          },
        },
      },
      orderBy: { createdAt: 'asc' },
    });

    // Agrupar ventas por doctor
    const ventasPorDoctor = {};
    ventas.forEach(v => {
      const doctorId = v.doctorId || 0;
      const doctorNombre = v.doctor ? `${v.doctor.nombre} ${v.doctor.apellido}` : 'Sin Doctor';

      if (!ventasPorDoctor[doctorId]) {
        ventasPorDoctor[doctorId] = {
          doctorId,
          doctorNombre,
          efectivo: 0,
          tarjeta: {
            total: 0,
            Azteca: 0,
            BBVA: 0,
            'Mercado Pago': 0,
          },
          transferencia: {
            total: 0,
            Azteca: 0,
            BBVA: 0,
            'Mercado Pago': 0,
          },
        };
      }

      const total = parseFloat(v.total);
      const metodoBase = getMetodoBase(v.metodoPago);
      const bancoVenta = getBanco(v);

      if (metodoBase === 'efectivo') {
        ventasPorDoctor[doctorId].efectivo += total;
      } else if (metodoBase === 'tarjeta') {
        ventasPorDoctor[doctorId].tarjeta.total += total;
        if (bancoVenta && ventasPorDoctor[doctorId].tarjeta[bancoVenta] !== undefined) {
          ventasPorDoctor[doctorId].tarjeta[bancoVenta] += total;
        }
      } else if (metodoBase === 'transferencia') {
        ventasPorDoctor[doctorId].transferencia.total += total;
        if (bancoVenta && ventasPorDoctor[doctorId].transferencia[bancoVenta] !== undefined) {
          ventasPorDoctor[doctorId].transferencia[bancoVenta] += total;
        }
      }
    });

    // Convertir a array y ordenar por nombre de doctor
    const ventasPorDoctorArray = Object.values(ventasPorDoctor).sort((a, b) =>
      a.doctorNombre.localeCompare(b.doctorNombre)
    );

    // Calcular totales
    const ventasEfectivo = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'efectivo')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);
    const ventasTarjeta = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'tarjeta')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);
    const ventasTransferencia = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'transferencia')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);

    // Calcular ventas por banco - Tarjeta
    const ventasTarjetaAzteca = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'tarjeta' && getBanco(v) === 'Azteca')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);
    const ventasTarjetaBbva = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'tarjeta' && getBanco(v) === 'BBVA')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);
    const ventasTarjetaMp = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'tarjeta' && getBanco(v) === 'Mercado Pago')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);

    // Calcular ventas por banco - Transferencia
    const ventasTransferenciaAzteca = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'transferencia' && getBanco(v) === 'Azteca')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);
    const ventasTransferenciaBbva = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'transferencia' && getBanco(v) === 'BBVA')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);
    const ventasTransferenciaMp = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'transferencia' && getBanco(v) === 'Mercado Pago')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);

    const totalVentas = ventas.reduce((sum, v) => sum + parseFloat(v.total), 0);

    // Separar retiros de otros gastos
    const retiros = gastos.filter(g => g.motivo === 'Retiro de efectivo' && g.metodoPago === 'efectivo');
    const otrosGastos = gastos.filter(g => !(g.motivo === 'Retiro de efectivo' && g.metodoPago === 'efectivo'));

    // Calcular gastos en efectivo del período (incluyendo retiros)
    const gastosEfectivo = gastos
      .filter(g => g.metodoPago === 'efectivo')
      .reduce((sum, g) => sum + parseFloat(g.monto), 0);

    // Calcular total de retiros
    const totalRetiros = retiros.reduce((sum, r) => sum + parseFloat(r.monto), 0);

    // Calcular saldo esperado: saldo inicial de efectivo + ventas en efectivo - gastos en efectivo
    const saldoEsperado = saldoInicialEfectivo + ventasEfectivo - gastosEfectivo;

    res.render('pos/corte', {
      title: `Corte de Caja - ${hora}`,
      hora,
      esManual: false, // Es un corte automático programado
      esFinDia: esFinDia, // Si es el corte de las 6pm (fin día)
      ultimoCorte: ultimoCorte || saldoInicialDelDia,
      ventas,
      gastos: otrosGastos, // Solo otros gastos (sin retiros)
      retiros: retiros || [], // Retiros separados, siempre un array
      ventasPorDoctor: ventasPorDoctorArray,
      desdeFecha,
      formatCurrency,
      moment,
      config,
      now: () => moment().tz(config.timezone),
      resumen: {
        saldoInicial,
        ventasEfectivo,
        ventasTarjeta,
        ventasTransferencia,
        ventasTarjetaAzteca,
        ventasTarjetaBbva,
        ventasTarjetaMp,
        ventasTransferenciaAzteca,
        ventasTransferenciaBbva,
        ventasTransferenciaMp,
        totalVentas,
        saldoEsperado,
        cantidadVentas: ventas.length,
        gastosEfectivo,
        totalRetiros,
      },
    });
  } catch (error) {
    console.error('Error al mostrar corte:', error);
    res.render('error', { title: 'Error', message: 'Error al cargar corte de caja', error });
  }
};

// Procesar corte de caja
const procesarCorte = async (req, res) => {
  try {
    const { hora, saldoFinal, observaciones } = req.body;

    // Validar formato de hora (HH:MM)
    const horaRegex = /^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/;
    if (!horaRegex.test(hora)) {
      return res.status(400).json({ error: 'Formato de hora inválido. Use HH:MM (ejemplo: 14:00)' });
    }

    // Obtener configuración de cortes para verificar si es el segundo corte (fin día)
    const configCortes = await getConfiguracionCortes();
    const esFinDia = hora === configCortes.horaCorte2;

    const hoy = moment().tz(config.timezone).startOf('day').toDate();
    const mañana = moment().tz(config.timezone).endOf('day').toDate();

    // Verificar si ya existe un corte a esta hora
    const corteExistente = await prisma.corteCaja.findFirst({
      where: {
        fecha: { gte: hoy, lte: mañana },
        hora: hora,
      },
    });

    if (corteExistente) {
      return res.status(400).json({
        error: 'Ya se realizó un corte a las ' + hora + ' hoy. Si necesitas hacer otro corte, usa "Corte Manual" con una hora diferente.'
      });
    }

    // --- Lógica de Reseteo Independiente para Corte General (MULTIDÍA) ---
    const ultimoResetEfectivo = await prisma.corteCaja.findFirst({
      where: {
        OR: [
          { hora: null },
          { AND: [{ hora: { not: null } }, { ventasEfectivo: { gt: 0 } }] },
          { AND: [{ hora: { not: null } }, { ventasTarjeta: 0 }, { ventasTransferencia: 0 }] }
        ]
      },
      orderBy: { createdAt: 'desc' }
    });

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

    const desdeFechaEfectivo = ultimoResetEfectivo ? ultimoResetEfectivo.createdAt : hoy;
    const desdeFechaBancos = ultimoResetBancos ? ultimoResetBancos.createdAt : new Date(0);

    // Obtener ventas por separado
    const ventasEfectivoLista = await prisma.venta.findMany({
      where: { createdAt: { gte: desdeFechaEfectivo }, metodoPago: 'efectivo' },
      select: { total: true }
    });
    const ventasBancosLista = await prisma.venta.findMany({
      where: { createdAt: { gte: desdeFechaBancos }, metodoPago: { in: ['tarjeta', 'transferencia'] } },
      select: { total: true, metodoPago: true, banco: true }
    });

    // Obtener gastos por separado
    const gastosEfectivoLista = await prisma.gasto.findMany({
      where: { createdAt: { gte: desdeFechaEfectivo }, metodoPago: 'efectivo' },
      select: { monto: true }
    });
    const gastosBancosLista = await prisma.gasto.findMany({
      where: { createdAt: { gte: desdeFechaBancos }, metodoPago: { in: ['tarjeta', 'transferencia'] } },
      select: { monto: true, metodoPago: true, banco: true }
    });

    const saldoInicialEfectivo = ultimoResetEfectivo ? parseFloat(ultimoResetEfectivo.saldoFinalEfectivo || ultimoResetEfectivo.saldoInicialEfectivo || 0) : 0;
    const saldoInicialTarjetaAzteca = ultimoResetBancos ? parseFloat(ultimoResetBancos.saldoFinalTarjetaAzteca || 0) : 0;
    const saldoInicialTarjetaBbva = ultimoResetBancos ? parseFloat(ultimoResetBancos.saldoFinalTarjetaBbva || 0) : 0;
    const saldoInicialTarjetaMp = ultimoResetBancos ? parseFloat(ultimoResetBancos.saldoFinalTarjetaMp || 0) : 0;
    const saldoInicialTransferencia = ultimoResetBancos ? parseFloat(ultimoResetBancos.saldoFinalTransferencia || 0) : 0;

    // Unir para compatibilidad con código existente
    const ventas = [
      ...ventasEfectivoLista.map(v => ({ ...v, metodoPago: 'efectivo' })),
      ...ventasBancosLista
    ];
    const gastos = [
      ...gastosEfectivoLista.map(g => ({ ...g, metodoPago: 'efectivo' })),
      ...gastosBancosLista
    ];

    // Calcular totales (saldoInicial ya fue asignado arriba)
    const ventasEfectivo = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'efectivo')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);
    const ventasTarjeta = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'tarjeta')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);
    const ventasTransferencia = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'transferencia')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);
    const totalVentas = ventas.reduce((sum, v) => sum + parseFloat(v.total), 0);

    // Calcular gastos en efectivo del período
    const gastosEfectivo = gastos
      .filter(g => g.metodoPago === 'efectivo')
      .reduce((sum, g) => sum + parseFloat(g.monto), 0);

    // Calcular gastos por banco - Tarjeta
    const gastosTarjetaAzteca = gastos
      .filter(g => g.metodoPago === 'tarjeta' && g.banco === 'Azteca')
      .reduce((sum, g) => sum + parseFloat(g.monto), 0);
    const gastosTarjetaBbva = gastos
      .filter(g => g.metodoPago === 'tarjeta' && g.banco === 'BBVA')
      .reduce((sum, g) => sum + parseFloat(g.monto), 0);
    const gastosTarjetaMp = gastos
      .filter(g => g.metodoPago === 'tarjeta' && g.banco === 'Mercado Pago')
      .reduce((sum, g) => sum + parseFloat(g.monto), 0);

    // Calcular gastos por banco - Transferencia
    const gastosTransferenciaAzteca = gastos
      .filter(g => g.metodoPago === 'transferencia' && g.banco === 'Azteca')
      .reduce((sum, g) => sum + parseFloat(g.monto), 0);
    const gastosTransferenciaBbva = gastos
      .filter(g => g.metodoPago === 'transferencia' && g.banco === 'BBVA')
      .reduce((sum, g) => sum + parseFloat(g.monto), 0);
    const gastosTransferenciaMp = gastos
      .filter(g => g.metodoPago === 'transferencia' && g.banco === 'Mercado Pago')
      .reduce((sum, g) => sum + parseFloat(g.monto), 0);

    const saldoFinalCalculado = parseFloat(saldoFinal);
    // Calcular diferencia: saldo final - (saldo inicial de efectivo + ventas en efectivo - gastos en efectivo)
    const diferencia = saldoFinalCalculado - (saldoInicialEfectivo + ventasEfectivo - gastosEfectivo);

    // Calcular ventas por banco - Tarjeta
    const ventasTarjetaAzteca = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'tarjeta' && getBanco(v) === 'Azteca')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);
    const ventasTarjetaBbva = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'tarjeta' && getBanco(v) === 'BBVA')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);
    const ventasTarjetaMp = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'tarjeta' && getBanco(v) === 'Mercado Pago')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);

    // Calcular ventas por banco - Transferencia
    const ventasTransferenciaAzteca = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'transferencia' && getBanco(v) === 'Azteca')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);
    const ventasTransferenciaBbva = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'transferencia' && getBanco(v) === 'BBVA')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);
    const ventasTransferenciaMp = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'transferencia' && getBanco(v) === 'Mercado Pago')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);

    // Calcular saldos finales restando gastos por banco
    const saldoFinalTarjetaAzteca = saldoInicialTarjetaAzteca + ventasTarjetaAzteca - gastosTarjetaAzteca;
    const saldoFinalTarjetaBbva = saldoInicialTarjetaBbva + ventasTarjetaBbva - gastosTarjetaBbva;
    const saldoFinalTarjetaMp = saldoInicialTarjetaMp + ventasTarjetaMp - gastosTarjetaMp;
    const saldoFinalTransferenciaAzteca = saldoInicialTransferencia + ventasTransferenciaAzteca - gastosTransferenciaAzteca;
    const saldoFinalTransferenciaBbva = 0 + ventasTransferenciaBbva - gastosTransferenciaBbva;
    const saldoFinalTransferenciaMp = 0 + ventasTransferenciaMp - gastosTransferenciaMp;
    const saldoFinalTransferencia = saldoFinalTransferenciaAzteca + saldoFinalTransferenciaBbva + saldoFinalTransferenciaMp;

    // Crear corte de caja
    await prisma.corteCaja.create({
      data: {
        fecha: new Date(),
        hora: hora,
        saldoInicial: saldoInicial,
        saldoInicialEfectivo: saldoInicialEfectivo,
        saldoInicialTarjetaAzteca: saldoInicialTarjetaAzteca,
        saldoInicialTarjetaBbva: saldoInicialTarjetaBbva,
        saldoInicialTarjetaMp: saldoInicialTarjetaMp,
        saldoInicialTransferencia: saldoInicialTransferencia,
        ventasEfectivo: ventasEfectivo,
        ventasTarjeta: ventasTarjeta,
        ventasTransferencia: ventasTransferencia,
        ventasTarjetaAzteca: ventasTarjetaAzteca,
        ventasTarjetaBbva: ventasTarjetaBbva,
        ventasTarjetaMp: ventasTarjetaMp,
        ventasTransferenciaAzteca: ventasTransferenciaAzteca,
        ventasTransferenciaBbva: ventasTransferenciaBbva,
        ventasTransferenciaMp: ventasTransferenciaMp,
        totalVentas: totalVentas,
        saldoFinal: saldoFinalCalculado,
        saldoFinalEfectivo: saldoFinalCalculado,
        saldoFinalTarjetaAzteca: saldoFinalTarjetaAzteca,
        saldoFinalTarjetaBbva: saldoFinalTarjetaBbva,
        saldoFinalTarjetaMp: saldoFinalTarjetaMp,
        saldoFinalTransferencia: saldoFinalTransferencia,
        saldoFinalTransferenciaAzteca: saldoFinalTransferenciaAzteca,
        saldoFinalTransferenciaBbva: saldoFinalTransferenciaBbva,
        saldoFinalTransferenciaMp: saldoFinalTransferenciaMp,
        diferencia: diferencia,
        observaciones: observaciones || null,
        usuarioId: req.session.user?.id || null,
      },
    });

    // Después de CUALQUIER corte, se debe solicitar saldo inicial inmediatamente
    // Si es fin de día (corte de las 6pm), también mostrar opción de fin día

    // Obtener saldo final de efectivo después del corte
    const saldoFinalEfectivoDespuesCorte = parseFloat(saldoFinalCalculado);

    res.json({
      success: true,
      requiereSaldoInicial: true,
      esFinDia: esFinDia,
      saldoFinalEfectivo: saldoFinalEfectivoDespuesCorte,
      preguntaRetiro: true // Indicar que debe preguntar si desea hacer retiro
    });
  } catch (error) {
    console.error('Error al procesar corte:', error);
    res.status(500).json({ error: 'Error al procesar corte de caja' });
  }
};

// Verificar contraseña de administrador
const verificarPasswordAdmin = async (req, res) => {
  try {
    const { password } = req.body;

    if (!password) {
      return res.status(400).json({ error: 'Contraseña requerida' });
    }

    // Buscar usuario administrador
    const admin = await prisma.usuario.findFirst({
      where: {
        rol: 'admin',
        activo: true,
      },
    });

    if (!admin) {
      return res.status(404).json({ error: 'No se encontró un administrador activo' });
    }

    // Verificar contraseña
    const isValid = await bcrypt.compare(password, admin.password);

    if (!isValid) {
      return res.status(401).json({ error: 'Contraseña incorrecta' });
    }

    res.json({ success: true });
  } catch (error) {
    console.error('Error al verificar contraseña:', error);
    res.status(500).json({ error: 'Error al verificar contraseña' });
  }
};

// Mostrar vista de corte manual
const mostrarCorteManual = async (req, res) => {
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

    // Buscar el saldo inicial más reciente (después del último corte si existe)
    let saldoInicialDelDia;
    if (ultimoCorte) {
      // Si hay un corte, buscar el saldo inicial creado DESPUÉS de ese corte
      saldoInicialDelDia = await prisma.corteCaja.findFirst({
        where: {
          fecha: { gte: hoy, lte: mañana },
          hora: null,
          createdAt: { gt: ultimoCorte.createdAt }, // Después del último corte
        },
        orderBy: { createdAt: 'desc' },
      });
    } else {
      // Si no hay corte, buscar cualquier saldo inicial del día
      saldoInicialDelDia = await prisma.corteCaja.findFirst({
        where: {
          fecha: { gte: hoy, lte: mañana },
          hora: null,
        },
        orderBy: { createdAt: 'desc' },
      });
    }

    // Si no hay saldo inicial después del último corte, pero hay un último corte,
    // usar el saldo final del último corte como referencia temporal
    // Esto permite hacer el corte, y después se pedirá el nuevo saldo inicial
    let desdeFecha;
    let saldoInicial;
    let saldoInicialEfectivo, saldoInicialTarjetaAzteca, saldoInicialTarjetaBbva, saldoInicialTarjetaMp, saldoInicialTransferencia;

    if (!saldoInicialDelDia && ultimoCorte) {
      // No hay saldo inicial después del último corte, usar el saldo final del último corte como referencia
      desdeFecha = ultimoCorte.createdAt;
      saldoInicialEfectivo = parseFloat(ultimoCorte.saldoFinalEfectivo || 0);
      saldoInicialTarjetaAzteca = parseFloat(ultimoCorte.saldoFinalTarjetaAzteca || 0);
      saldoInicialTarjetaBbva = parseFloat(ultimoCorte.saldoFinalTarjetaBbva || 0);
      saldoInicialTarjetaMp = parseFloat(ultimoCorte.saldoFinalTarjetaMp || 0);
      saldoInicialTransferencia = parseFloat(ultimoCorte.saldoFinalTransferencia || 0);
      saldoInicial = saldoInicialEfectivo + saldoInicialTarjetaAzteca + saldoInicialTarjetaBbva + saldoInicialTarjetaMp + saldoInicialTransferencia;
    } else if (saldoInicialDelDia) {
      // Hay saldo inicial, usarlo
      desdeFecha = saldoInicialDelDia.createdAt;
      saldoInicialEfectivo = parseFloat(saldoInicialDelDia.saldoInicialEfectivo || 0);
      saldoInicialTarjetaAzteca = parseFloat(saldoInicialDelDia.saldoInicialTarjetaAzteca || 0);
      saldoInicialTarjetaBbva = parseFloat(saldoInicialDelDia.saldoInicialTarjetaBbva || 0);
      saldoInicialTarjetaMp = parseFloat(saldoInicialDelDia.saldoInicialTarjetaMp || 0);
      saldoInicialTransferencia = parseFloat(saldoInicialDelDia.saldoInicialTransferencia || 0);
      saldoInicial = saldoInicialEfectivo + saldoInicialTarjetaAzteca + saldoInicialTarjetaBbva + saldoInicialTarjetaMp + saldoInicialTransferencia;

      // Si hay un corte después del saldo inicial, contar ventas desde ese corte
      if (ultimoCorte && ultimoCorte.createdAt > saldoInicialDelDia.createdAt) {
        desdeFecha = ultimoCorte.createdAt;
      }
    } else {
      // No hay saldo inicial ni corte, redirigir a pedir saldo inicial
      return res.redirect('/pos?necesitaSaldoInicial=true');
    }

    // Obtener ventas desde el último corte o saldo inicial
    const ventas = await prisma.venta.findMany({
      where: {
        createdAt: { gte: desdeFecha },
      },
      include: {
        paciente: true,
        doctor: true,
        items: {
          include: {
            servicio: true,
            producto: true,
          },
        },
      },
      orderBy: { createdAt: 'asc' },
    });

    // Obtener gastos del período
    const gastos = await prisma.gasto.findMany({
      where: {
        createdAt: { gte: desdeFecha },
      },
      include: {
        usuario: {
          select: {
            nombre: true,
          },
        },
      },
      orderBy: { createdAt: 'asc' },
    });

    // Agrupar ventas por doctor
    const ventasPorDoctor = {};
    ventas.forEach(v => {
      const doctorId = v.doctorId || 0;
      const doctorNombre = v.doctor ? `${v.doctor.nombre} ${v.doctor.apellido}` : 'Sin Doctor';

      if (!ventasPorDoctor[doctorId]) {
        ventasPorDoctor[doctorId] = {
          doctorId,
          doctorNombre,
          efectivo: 0,
          tarjeta: {
            total: 0,
            Azteca: 0,
            BBVA: 0,
            'Mercado Pago': 0,
          },
          transferencia: {
            total: 0,
            Azteca: 0,
            BBVA: 0,
            'Mercado Pago': 0,
          },
        };
      }

      const total = parseFloat(v.total);
      const metodoBase = getMetodoBase(v.metodoPago);
      const bancoVenta = getBanco(v);

      if (metodoBase === 'efectivo') {
        ventasPorDoctor[doctorId].efectivo += total;
      } else if (metodoBase === 'tarjeta') {
        ventasPorDoctor[doctorId].tarjeta.total += total;
        if (bancoVenta && ventasPorDoctor[doctorId].tarjeta[bancoVenta] !== undefined) {
          ventasPorDoctor[doctorId].tarjeta[bancoVenta] += total;
        }
      } else if (metodoBase === 'transferencia') {
        ventasPorDoctor[doctorId].transferencia.total += total;
        if (bancoVenta && ventasPorDoctor[doctorId].transferencia[bancoVenta] !== undefined) {
          ventasPorDoctor[doctorId].transferencia[bancoVenta] += total;
        }
      }
    });

    // Convertir a array y ordenar por nombre de doctor
    const ventasPorDoctorArray = Object.values(ventasPorDoctor).sort((a, b) =>
      a.doctorNombre.localeCompare(b.doctorNombre)
    );

    // Calcular totales
    const ventasEfectivo = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'efectivo')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);
    const ventasTarjeta = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'tarjeta')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);
    const ventasTransferencia = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'transferencia')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);

    // Calcular ventas por banco - Tarjeta
    const ventasTarjetaAzteca = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'tarjeta' && getBanco(v) === 'Azteca')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);
    const ventasTarjetaBbva = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'tarjeta' && getBanco(v) === 'BBVA')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);
    const ventasTarjetaMp = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'tarjeta' && getBanco(v) === 'Mercado Pago')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);

    // Calcular ventas por banco - Transferencia
    const ventasTransferenciaAzteca = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'transferencia' && getBanco(v) === 'Azteca')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);
    const ventasTransferenciaBbva = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'transferencia' && getBanco(v) === 'BBVA')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);
    const ventasTransferenciaMp = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'transferencia' && getBanco(v) === 'Mercado Pago')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);

    const totalVentas = ventas.reduce((sum, v) => sum + parseFloat(v.total), 0);

    // Separar retiros de otros gastos
    const retiros = gastos.filter(g => g.motivo === 'Retiro de efectivo' && g.metodoPago === 'efectivo');
    const otrosGastos = gastos.filter(g => !(g.motivo === 'Retiro de efectivo' && g.metodoPago === 'efectivo'));

    // Calcular gastos en efectivo del período (incluyendo retiros)
    const gastosEfectivo = gastos
      .filter(g => g.metodoPago === 'efectivo')
      .reduce((sum, g) => sum + parseFloat(g.monto), 0);

    // Calcular total de retiros
    const totalRetiros = retiros.reduce((sum, r) => sum + parseFloat(r.monto), 0);

    // Calcular saldo esperado: saldo inicial de efectivo + ventas en efectivo - gastos en efectivo
    const saldoEsperado = saldoInicialEfectivo + ventasEfectivo - gastosEfectivo;

    // Obtener hora actual para el corte manual
    const horaActual = moment().tz(config.timezone).format('HH:mm');

    res.render('pos/corte', {
      title: 'Corte Manual de Caja',
      hora: horaActual,
      esManual: true,
      esFinDia: false,
      ultimoCorte: saldoInicialDelDia || ultimoCorte,
      ventas,
      gastos: otrosGastos, // Solo otros gastos (sin retiros)
      retiros: retiros || [], // Retiros separados, siempre un array
      ventasPorDoctor: ventasPorDoctorArray,
      desdeFecha,
      formatCurrency,
      moment,
      config,
      now: () => moment().tz(config.timezone),
      resumen: {
        saldoInicial,
        ventasEfectivo,
        ventasTarjeta,
        ventasTransferencia,
        ventasTarjetaAzteca,
        ventasTarjetaBbva,
        ventasTarjetaMp,
        ventasTransferenciaAzteca,
        ventasTransferenciaBbva,
        ventasTransferenciaMp,
        totalVentas,
        saldoEsperado,
        cantidadVentas: ventas.length,
        gastosEfectivo,
        totalRetiros,
      },
    });
  } catch (error) {
    console.error('Error al mostrar corte manual:', error);
    res.render('error', { title: 'Error', message: 'Error al cargar corte de caja', error });
  }
};

// Procesar corte manual
const procesarCorteManual = async (req, res) => {
  try {
    const { hora, saldoFinal, observaciones } = req.body;

    if (!hora) {
      return res.status(400).json({ error: 'Hora requerida' });
    }

    if (!saldoFinal || isNaN(parseFloat(saldoFinal))) {
      return res.status(400).json({ error: 'Saldo final requerido y debe ser un número válido' });
    }

    // Validar formato de hora (HH:MM)
    const horaRegex = /^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/;
    if (!horaRegex.test(hora)) {
      return res.status(400).json({ error: 'Formato de hora inválido. Use HH:MM (ejemplo: 14:00)' });
    }

    const hoy = moment().tz(config.timezone).startOf('day').toDate();
    const mañana = moment().tz(config.timezone).endOf('day').toDate();

    // Verificar si ya existe un corte a esta hora exacta HOY
    const corteExistente = await prisma.corteCaja.findFirst({
      where: {
        fecha: { gte: hoy, lte: mañana },
        hora: hora, // Misma hora exacta
      },
    });

    if (corteExistente) {
      return res.status(400).json({
        error: 'Ya se realizó un corte a las ' + hora + ' hoy. Si necesitas hacer otro corte, usa una hora diferente.'
      });
    }

    // Buscar el último corte del día (si existe)
    const ultimoCorte = await prisma.corteCaja.findFirst({
      where: {
        fecha: { gte: hoy, lte: mañana },
        hora: { not: null }, // Solo cortes, no saldos iniciales
      },
      orderBy: { createdAt: 'desc' },
    });

    // Buscar el saldo inicial más reciente (después del último corte si existe)
    let saldoInicialDelDia;
    // --- Lógica de Reseteo Independiente para Corte Manual (MULTIDÍA) ---
    const ultimoResetEfectivo = await prisma.corteCaja.findFirst({
      where: {
        OR: [
          { hora: null },
          { AND: [{ hora: { not: null } }, { ventasEfectivo: { gt: 0 } }] },
          { AND: [{ hora: { not: null } }, { ventasTarjeta: 0 }, { ventasTransferencia: 0 }] }
        ]
      },
      orderBy: { createdAt: 'desc' }
    });

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

    if (!ultimoResetEfectivo || !ultimoResetBancos) {
      return res.status(400).json({ error: 'No se encontró el saldo inicial del día o el último reset.' });
    }

    const desdeFechaEfectivo = ultimoResetEfectivo.createdAt;
    const desdeFechaBancos = ultimoResetBancos.createdAt;

    // Obtener ventas por separado
    const ventasEfectivoLista = await prisma.venta.findMany({
      where: { createdAt: { gte: desdeFechaEfectivo }, metodoPago: 'efectivo' },
      select: { total: true }
    });
    const ventasBancosLista = await prisma.venta.findMany({
      where: { createdAt: { gte: desdeFechaBancos }, metodoPago: { in: ['tarjeta', 'transferencia'] } },
      select: { total: true, metodoPago: true, banco: true }
    });

    const saldoInicialEfectivoVal = parseFloat(ultimoResetEfectivo.saldoFinalEfectivo || ultimoResetEfectivo.saldoInicialEfectivo || 0);
    const saldoInicialTarjetaAztecaVal = parseFloat(ultimoResetBancos.saldoFinalTarjetaAzteca || ultimoResetBancos.saldoInicialTarjetaAzteca || 0);
    const saldoInicialTarjetaBbvaVal = parseFloat(ultimoResetBancos.saldoFinalTarjetaBbva || ultimoResetBancos.saldoInicialTarjetaBbva || 0);
    const saldoInicialTarjetaMpVal = parseFloat(ultimoResetBancos.saldoFinalTarjetaMp || ultimoResetBancos.saldoInicialTarjetaMp || 0);
    const saldoInicialTransferenciaVal = parseFloat(ultimoResetBancos.saldoFinalTransferencia || 0);

    const desdeFecha = desdeFechaEfectivo < desdeFechaBancos ? desdeFechaEfectivo : desdeFechaBancos; // Para compatibilidad de consultas posteriores

    // Unir para compatibilidad
    const ventas = [
      ...ventasEfectivoLista.map(v => ({ ...v, metodoPago: 'efectivo' })),
      ...ventasBancosLista
    ];

    // Obtener gastos del período combinados
    const gastos = await prisma.gasto.findMany({
      where: {
        createdAt: { gte: desdeFecha },
      },
      select: {
        monto: true,
        metodoPago: true,
        banco: true,
      },
    });

    // Calcular totales
    const ventasEfectivo = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'efectivo')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);
    const ventasTarjeta = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'tarjeta')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);
    const ventasTransferencia = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'transferencia')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);
    const totalVentas = ventas.reduce((sum, v) => sum + parseFloat(v.total), 0);

    // Calcular gastos por banco - Tarjeta
    const gastosTarjetaAzteca = gastos
      .filter(g => g.metodoPago === 'tarjeta' && g.banco === 'Azteca')
      .reduce((sum, g) => sum + parseFloat(g.monto), 0);
    const gastosTarjetaBbva = gastos
      .filter(g => g.metodoPago === 'tarjeta' && g.banco === 'BBVA')
      .reduce((sum, g) => sum + parseFloat(g.monto), 0);
    const gastosTarjetaMp = gastos
      .filter(g => g.metodoPago === 'tarjeta' && g.banco === 'Mercado Pago')
      .reduce((sum, g) => sum + parseFloat(g.monto), 0);

    // Calcular gastos por banco - Transferencia
    const gastosTransferenciaAzteca = gastos
      .filter(g => g.metodoPago === 'transferencia' && g.banco === 'Azteca')
      .reduce((sum, g) => sum + parseFloat(g.monto), 0);
    const gastosTransferenciaBbva = gastos
      .filter(g => g.metodoPago === 'transferencia' && g.banco === 'BBVA')
      .reduce((sum, g) => sum + parseFloat(g.monto), 0);
    const gastosTransferenciaMp = gastos
      .filter(g => g.metodoPago === 'transferencia' && g.banco === 'Mercado Pago')
      .reduce((sum, g) => sum + parseFloat(g.monto), 0);

    // Calcular ventas por banco (solo para tarjeta)
    const ventasTarjetaAzteca = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'tarjeta' && getBanco(v) === 'Azteca')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);
    const ventasTarjetaBbva = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'tarjeta' && getBanco(v) === 'BBVA')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);
    const ventasTarjetaMp = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'tarjeta' && getBanco(v) === 'Mercado Pago')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);

    // Calcular ventas por banco - Transferencia
    const ventasTransferenciaAzteca = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'transferencia' && getBanco(v) === 'Azteca')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);
    const ventasTransferenciaBbva = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'transferencia' && getBanco(v) === 'BBVA')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);
    const ventasTransferenciaMp = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'transferencia' && getBanco(v) === 'Mercado Pago')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);

    const saldoFinalCalculado = parseFloat(saldoFinal);
    const diferencia = saldoFinalCalculado - (saldoInicial + ventasEfectivo);

    // Calcular saldos finales restando gastos por banco
    const saldoFinalTarjetaAzteca = saldoInicialTarjetaAztecaVal + ventasTarjetaAzteca - gastosTarjetaAzteca;
    const saldoFinalTarjetaBbva = saldoInicialTarjetaBbvaVal + ventasTarjetaBbva - gastosTarjetaBbva;
    const saldoFinalTarjetaMp = saldoInicialTarjetaMpVal + ventasTarjetaMp - gastosTarjetaMp;
    const saldoFinalTransferenciaAzteca = saldoInicialTransferenciaAztecaVal + ventasTransferenciaAzteca - gastosTransferenciaAzteca;
    const saldoFinalTransferenciaBbva = saldoInicialTransferenciaBbvaVal + ventasTransferenciaBbva - gastosTransferenciaBbva;
    const saldoFinalTransferenciaMp = saldoInicialTransferenciaMpVal + ventasTransferenciaMp - gastosTransferenciaMp;
    const saldoFinalTransferencia = saldoFinalTransferenciaAzteca + saldoFinalTransferenciaBbva + saldoFinalTransferenciaMp;

    // Los saldos iniciales ya están calculados arriba en las variables saldoInicialEfectivoVal, etc.

    // Crear corte de caja manual (hora personalizada)
    await prisma.corteCaja.create({
      data: {
        fecha: new Date(),
        hora: hora, // Hora manual
        saldoInicial: saldoInicial,
        saldoInicialEfectivo: saldoInicialEfectivoVal,
        saldoInicialTarjetaAzteca: saldoInicialTarjetaAztecaVal,
        saldoInicialTarjetaBbva: saldoInicialTarjetaBbvaVal,
        saldoInicialTarjetaMp: saldoInicialTarjetaMpVal,
        saldoInicialTransferencia: saldoInicialTransferenciaVal,
        ventasEfectivo: ventasEfectivo,
        ventasTarjeta: ventasTarjeta,
        ventasTransferencia: ventasTransferencia,
        ventasTarjetaAzteca: ventasTarjetaAzteca,
        ventasTarjetaBbva: ventasTarjetaBbva,
        ventasTarjetaMp: ventasTarjetaMp,
        ventasTransferenciaAzteca: ventasTransferenciaAzteca,
        ventasTransferenciaBbva: ventasTransferenciaBbva,
        ventasTransferenciaMp: ventasTransferenciaMp,
        totalVentas: totalVentas,
        saldoFinal: saldoFinalCalculado,
        saldoFinalEfectivo: saldoFinalCalculado,
        saldoFinalTarjetaAzteca: saldoFinalTarjetaAzteca,
        saldoFinalTarjetaBbva: saldoFinalTarjetaBbva,
        saldoFinalTarjetaMp: saldoFinalTarjetaMp,
        saldoFinalTransferencia: saldoFinalTransferencia,
        saldoFinalTransferenciaAzteca: saldoFinalTransferenciaAzteca,
        saldoFinalTransferenciaBbva: saldoFinalTransferenciaBbva,
        saldoFinalTransferenciaMp: saldoFinalTransferenciaMp,
        diferencia: diferencia,
        observaciones: observaciones || null,
        usuarioId: req.session.user?.id || null,
      },
    });

    // Obtener saldo final de efectivo después del corte
    const saldoFinalEfectivoDespuesCorte = parseFloat(saldoFinalCalculado);

    // Después de CUALQUIER corte, se debe solicitar saldo inicial inmediatamente
    res.json({
      success: true,
      requiereSaldoInicial: true,
      esFinDia: false, // Los cortes manuales no son fin de día
      saldoFinalEfectivo: saldoFinalEfectivoDespuesCorte,
      preguntaRetiro: true // Indicar que debe preguntar si desea hacer retiro
    });
  } catch (error) {
    console.error('Error al procesar corte manual:', error);
    console.error('Error stack:', error.stack);
    res.status(500).json({ error: 'Error al procesar corte de caja: ' + error.message });
  }
};

// Obtener saldos actuales en tiempo real
const obtenerSaldosActuales = async (req, res) => {
  try {
    const hoy = moment().tz(config.timezone).startOf('day').toDate();
    const mañana = moment().tz(config.timezone).endOf('day').toDate();

    // --- Lógica de Reseteo Independiente ---

    // 1. Encontrar el punto de partida para EFECTIVO
    // Es el último registro que haya procesado efectivo (Manual, Efectivo o Saldo Inicial)
    // --- Lógica de Reseteo Independiente (MULTIDÍA) ---
    // 1. Encontrar el punto de partida para EFECTIVO
    const ultimoResetEfectivo = await prisma.corteCaja.findFirst({
      where: {
        OR: [
          { hora: null },
          { AND: [{ hora: { not: null } }, { ventasEfectivo: { gt: 0 } }] },
          { AND: [{ hora: { not: null } }, { ventasTarjeta: 0 }, { ventasTransferencia: 0 }] }
        ]
      },
      orderBy: { createdAt: 'desc' }
    });

    // 2. Encontrar el punto de partida para BANCOS
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

    const desdeFechaEfectivo = ultimoResetEfectivo ? ultimoResetEfectivo.createdAt : hoy;
    const desdeFechaBancos = ultimoResetBancos ? ultimoResetBancos.createdAt : new Date(0);

    // --- Cálculos de EFECTIVO ---
    let saldoInicialEfectivo = ultimoResetEfectivo ? parseFloat(ultimoResetEfectivo.saldoFinalEfectivo || ultimoResetEfectivo.saldoInicialEfectivo || 0) : 0;

    const ventasEfectivoLista = await prisma.venta.findMany({
      where: { createdAt: { gte: desdeFechaEfectivo }, metodoPago: 'efectivo' },
      select: { total: true }
    });
    const gastosEfectivoLista = await prisma.gasto.findMany({
      where: { createdAt: { gte: desdeFechaEfectivo }, metodoPago: 'efectivo' },
      select: { monto: true }
    });

    const sumVentasEfectivo = ventasEfectivoLista.reduce((sum, v) => sum + parseFloat(v.total), 0);
    const sumGastosEfectivo = gastosEfectivoLista.reduce((sum, g) => sum + parseFloat(g.monto), 0);
    const saldoFinalEfectivo = saldoInicialEfectivo + sumVentasEfectivo - sumGastosEfectivo;

    // --- Cálculos de BANCOS ---
    let saldoInicialAzteca = ultimoResetBancos ? parseFloat(ultimoResetBancos.saldoFinalTarjetaAzteca || ultimoResetBancos.saldoFinalTransferenciaAzteca || ultimoResetBancos.saldoInicialTarjetaAzteca || 0) : 0;
    let saldoInicialBbva = ultimoResetBancos ? parseFloat(ultimoResetBancos.saldoFinalTarjetaBbva || ultimoResetBancos.saldoFinalTransferenciaBbva || ultimoResetBancos.saldoInicialTarjetaBbva || 0) : 0;
    let saldoFinalMp = ultimoResetBancos ? parseFloat(ultimoResetBancos.saldoFinalTarjetaMp || ultimoResetBancos.saldoFinalTransferenciaMp || ultimoResetBancos.saldoInicialTarjetaMp || 0) : 0;

    // Nota: El modelo parece guardar saldos por banco unificados en algunos registros. 
    // Usamos los campos saldoFinal... si existen, que son los más actualizados de ese reset.

    const ventasBancosLista = await prisma.venta.findMany({
      where: { createdAt: { gte: desdeFechaBancos }, metodoPago: { in: ['tarjeta', 'transferencia'] } },
      select: { total: true, metodoPago: true, banco: true }
    });
    const gastosBancosLista = await prisma.gasto.findMany({
      where: { createdAt: { gte: desdeFechaBancos }, metodoPago: { in: ['tarjeta', 'transferencia'] } },
      select: { monto: true, metodoPago: true, banco: true }
    });

    // Agrupar ventas y gastos por banco
    const getBancoNormalizado = (obj) => {
      const b = (obj.banco || '').toLowerCase();
      if (b.includes('azteca')) return 'azteca';
      if (b.includes('bbva')) return 'bbva';
      if (b.includes('mercado') || b.includes('mp')) return 'mp';
      return 'otros';
    };

    let vAzteca = 0, vBbva = 0, vMp = 0;
    ventasBancosLista.forEach(v => {
      const b = getBancoNormalizado(v);
      if (b === 'azteca') vAzteca += parseFloat(v.total);
      else if (b === 'bbva') vBbva += parseFloat(v.total);
      else if (b === 'mp') vMp += parseFloat(v.total);
    });

    let gAzteca = 0, gBbva = 0, gMp = 0;
    gastosBancosLista.forEach(g => {
      const b = getBancoNormalizado(g);
      if (b === 'azteca') gAzteca += parseFloat(g.monto);
      else if (b === 'bbva') gBbva += parseFloat(g.monto);
      else if (b === 'mp') gMp += parseFloat(g.monto);
    });

    const saldoFinalAzteca = (ultimoResetBancos ? parseFloat(ultimoResetBancos.saldoFinalTarjetaAzteca || 0) + parseFloat(ultimoResetBancos.saldoFinalTransferenciaAzteca || 0) : 0) + vAzteca - gAzteca;
    const saldoFinalBbva = (ultimoResetBancos ? parseFloat(ultimoResetBancos.saldoFinalTarjetaBbva || 0) + parseFloat(ultimoResetBancos.saldoFinalTransferenciaBbva || 0) : 0) + vBbva - gBbva;
    const saldoFinalMercadoPago = (ultimoResetBancos ? parseFloat(ultimoResetBancos.saldoFinalTarjetaMp || 0) + parseFloat(ultimoResetBancos.saldoFinalTransferenciaMp || 0) : 0) + vMp - gMp;

    const respuesta = {
      success: true,
      saldos: {
        efectivo: saldoFinalEfectivo,
        azteca: saldoFinalAzteca,
        bbva: saldoFinalBbva,
        mercadoPago: saldoFinalMercadoPago,
      },
    };

    console.log('Saldos actuales calculados:', respuesta);
    res.json(respuesta);
  } catch (error) {
    console.error('Error al obtener saldos actuales:', error);
    res.status(500).json({ error: 'Error al obtener saldos actuales' });
  }
};

// Obtener límite de efectivo y saldo actual
const obtenerLimiteEfectivo = async (req, res) => {
  try {
    // Obtener configuración de retiros
    const configRetiros = await prisma.configuracionRetiros.findFirst({
      where: { activo: true },
    });

    const montoMaximoEfectivo = configRetiros ? parseFloat(configRetiros.montoMaximoEfectivo) : 0;

    // Obtener saldo actual de efectivo usando la misma lógica que obtenerSaldosActuales
    const hoy = moment().tz(config.timezone).startOf('day').toDate();
    const mañana = moment().tz(config.timezone).endOf('day').toDate();

    const ultimoResetEfectivo = await prisma.corteCaja.findFirst({
      where: {
        OR: [
          { hora: null },
          { AND: [{ hora: { not: null } }, { ventasEfectivo: { gt: 0 } }] },
          { AND: [{ hora: { not: null } }, { ventasTarjeta: 0 }, { ventasTransferencia: 0 }] }
        ]
      },
      orderBy: { createdAt: 'desc' }
    });

    if (!ultimoResetEfectivo) {
      return res.json({ success: true, saldoActual: 0, limiteMaximo: montoMaximoEfectivo, necesitaRetiro: false });
    }

    const desdeFecha = ultimoResetEfectivo.createdAt;
    const saldoInicialEfectivo = parseFloat(ultimoResetEfectivo.saldoFinalEfectivo || ultimoResetEfectivo.saldoInicialEfectivo || 0);

    // Obtener ventas en efectivo desde la fecha base
    const ventas = await prisma.venta.findMany({
      where: {
        createdAt: { gte: desdeFecha },
        metodoPago: 'efectivo',
      },
      select: { total: true },
    });

    // Obtener gastos en efectivo desde la fecha base
    const gastos = await prisma.gasto.findMany({
      where: {
        createdAt: { gte: desdeFecha },
        metodoPago: 'efectivo',
      },
      select: { monto: true },
    });

    const ventasEfectivo = ventas.reduce((sum, v) => sum + parseFloat(v.total), 0);
    const gastosEfectivo = gastos.reduce((sum, g) => sum + parseFloat(g.monto), 0);

    // El saldo actual es: saldo inicial + ventas - gastos
    // Los retiros se registran como gastos, por lo que ya están incluidos en gastosEfectivo
    const saldoActualEfectivo = saldoInicialEfectivo + ventasEfectivo - gastosEfectivo;

    res.json({
      success: true,
      saldoActual: saldoActualEfectivo,
      limiteMaximo: montoMaximoEfectivo,
      necesitaRetiro: montoMaximoEfectivo > 0 && saldoActualEfectivo >= montoMaximoEfectivo,
    });
  } catch (error) {
    console.error('Error al obtener límite de efectivo:', error);
    res.status(500).json({ error: 'Error al obtener límite de efectivo' });
  }
};

// Retirar efectivo directamente de la caja
const retirarEfectivo = async (req, res) => {
  try {
    const { monto, observaciones } = req.body;
    const cantidad = parseFloat(monto);

    if (isNaN(cantidad) || cantidad <= 0) {
      return res.status(400).json({ error: 'Monto inválido' });
    }

    // Obtener saldo actual de efectivo
    // Obtener saldo actual de efectivo usando la misma lógica (MULTIDÍA)
    const ultimoResetEfectivo = await prisma.corteCaja.findFirst({
      where: {
        OR: [
          { hora: null },
          { AND: [{ hora: { not: null } }, { ventasEfectivo: { gt: 0 } }] },
          { AND: [{ hora: { not: null } }, { ventasTarjeta: 0 }, { ventasTransferencia: 0 }] }
        ]
      },
      orderBy: { createdAt: 'desc' }
    });

    if (!ultimoResetEfectivo) {
      return res.status(400).json({ error: 'No se puede retirar sin un saldo inicial o corte previo.' });
    }

    const desdeFecha = ultimoResetEfectivo.createdAt;
    const saldoInicialEfectivo = parseFloat(ultimoResetEfectivo.saldoFinalEfectivo || ultimoResetEfectivo.saldoInicialEfectivo || 0);

    // Obtener ventas y gastos desde la fecha base
    const ventas = await prisma.venta.findMany({
      where: {
        createdAt: { gte: desdeFecha },
        metodoPago: 'efectivo',
      },
      select: { total: true },
    });

    const gastos = await prisma.gasto.findMany({
      where: {
        createdAt: { gte: desdeFecha },
        metodoPago: 'efectivo',
      },
      select: { monto: true },
    });

    const ventasEfectivo = ventas.reduce((sum, v) => sum + parseFloat(v.total), 0);
    const gastosEfectivo = gastos.reduce((sum, g) => sum + parseFloat(g.monto), 0);
    const saldoActualEfectivo = saldoInicialEfectivo + ventasEfectivo - gastosEfectivo;

    // Validar que haya suficiente efectivo
    if (cantidad > saldoActualEfectivo) {
      return res.status(400).json({ error: 'El monto supera el efectivo disponible en caja' });
    }

    // Registrar el retiro como un gasto
    const gasto = await prisma.gasto.create({
      data: {
        motivo: 'Retiro de efectivo',
        monto: cantidad,
        metodoPago: 'efectivo',
        observaciones: observaciones || 'Retiro automático por límite de efectivo alcanzado',
        tipo: 'general',
        usuarioId: req.session.user?.id || null,
      },
    });

    // Actualizar el saldo de efectivo en el último corte
    const ultimoCorteActual = await prisma.corteCaja.findFirst({
      where: {
        fecha: { gte: hoy, lte: mañana },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });

    if (ultimoCorteActual) {
      const nuevoSaldoEfectivo = parseFloat(ultimoCorteActual.saldoFinalEfectivo || 0) - cantidad;
      const saldoTarjetaTotal = parseFloat(ultimoCorteActual.saldoFinalTarjetaAzteca || 0) +
        parseFloat(ultimoCorteActual.saldoFinalTarjetaBbva || 0) +
        parseFloat(ultimoCorteActual.saldoFinalTarjetaMp || 0);
      const saldoTransferenciaTotal = parseFloat(ultimoCorteActual.saldoFinalTransferenciaAzteca || 0) +
        parseFloat(ultimoCorteActual.saldoFinalTransferenciaBbva || 0) +
        parseFloat(ultimoCorteActual.saldoFinalTransferenciaMp || 0);

      await prisma.corteCaja.update({
        where: { id: ultimoCorteActual.id },
        data: {
          saldoFinalEfectivo: nuevoSaldoEfectivo,
          saldoFinal: nuevoSaldoEfectivo + saldoTarjetaTotal + saldoTransferenciaTotal,
        },
      });
    }

    res.json({ success: true, gastoId: gasto.id });
  } catch (error) {
    console.error('Error al retirar efectivo:', error);
    res.status(500).json({ error: 'No se pudo realizar el retiro' });
  }
};

// Verificar contraseña del usuario logueado
const verificarPasswordUsuario = async (req, res) => {
  try {
    const { password } = req.body;

    if (!password) {
      return res.status(400).json({ error: 'Contraseña requerida' });
    }

    if (!req.session.user || !req.session.user.id) {
      return res.status(401).json({ error: 'Usuario no autenticado' });
    }

    // Buscar usuario logueado
    const usuario = await prisma.usuario.findUnique({
      where: { id: req.session.user.id },
    });

    if (!usuario) {
      return res.status(404).json({ error: 'Usuario no encontrado' });
    }

    // Verificar contraseña
    const isValid = await bcrypt.compare(password, usuario.password);

    if (!isValid) {
      return res.status(401).json({ error: 'Contraseña incorrecta' });
    }

    res.json({ success: true });
  } catch (error) {
    console.error('Error al verificar contraseña:', error);
    res.status(500).json({ error: 'Error al verificar contraseña' });
  }
};

// Mostrar vista de corte de efectivo
const mostrarCorteEfectivo = async (req, res) => {
  try {
    const hoy = moment().tz(config.timezone).startOf('day').toDate();
    const mañana = moment().tz(config.timezone).endOf('day').toDate();

    // --- Lógica de Reseteo Independiente para Efectivo ---
    const ultimoResetEfectivo = await prisma.corteCaja.findFirst({
      where: {
        OR: [
          { hora: null },
          { AND: [{ hora: { not: null } }, { ventasEfectivo: { gt: 0 } }] },
          { AND: [{ hora: { not: null } }, { ventasTarjeta: 0 }, { ventasTransferencia: 0 }] }
        ]
      },
      orderBy: { createdAt: 'desc' }
    });

    if (!ultimoResetEfectivo) {
      return res.redirect('/pos?necesitaSaldoInicial=true');
    }

    const desdeFecha = ultimoResetEfectivo.createdAt;
    const saldoInicialEfectivo = parseFloat(ultimoResetEfectivo.saldoFinalEfectivo || ultimoResetEfectivo.saldoInicialEfectivo || 0);

    // Buscar cualquier registro previo para referencia
    const ultimoCorte = await prisma.corteCaja.findFirst({
      where: { fecha: { gte: hoy, lte: mañana }, hora: { not: null } },
      orderBy: { createdAt: 'desc' }
    });
    const saldoInicialDelDia = await prisma.corteCaja.findFirst({
      where: { fecha: { gte: hoy, lte: mañana }, hora: null },
      orderBy: { createdAt: 'desc' }
    });

    // Obtener ventas en efectivo desde el último corte o saldo inicial
    const ventas = await prisma.venta.findMany({
      where: {
        createdAt: { gte: desdeFecha },
        metodoPago: 'efectivo',
      },
      include: {
        paciente: true,
        doctor: true,
        items: {
          include: {
            servicio: true,
            producto: true,
          },
        },
      },
      orderBy: { createdAt: 'asc' },
    });

    // Obtener gastos en efectivo del período
    const gastos = await prisma.gasto.findMany({
      where: {
        createdAt: { gte: desdeFecha },
        metodoPago: 'efectivo',
      },
      include: {
        usuario: {
          select: {
            nombre: true,
          },
        },
      },
      orderBy: { createdAt: 'asc' },
    });

    // Separar retiros de otros gastos
    const retiros = gastos.filter(g => g.motivo === 'Retiro de efectivo' && g.metodoPago === 'efectivo');
    const otrosGastos = gastos.filter(g => !(g.motivo === 'Retiro de efectivo' && g.metodoPago === 'efectivo'));

    // Calcular totales
    const ventasEfectivo = ventas.reduce((sum, v) => sum + parseFloat(v.total), 0);
    const gastosEfectivo = gastos.reduce((sum, g) => sum + parseFloat(g.monto), 0);
    const totalRetiros = retiros.reduce((sum, r) => sum + parseFloat(r.monto), 0);
    const saldoEsperado = saldoInicialEfectivo + ventasEfectivo - gastosEfectivo;

    // Logging detallado para depuración
    console.log('=== MOSTRAR CORTE EFECTIVO ===');
    console.log('Ultimo corte:', ultimoCorte ? { id: ultimoCorte.id, hora: ultimoCorte.hora, createdAt: ultimoCorte.createdAt, saldoFinalEfectivo: ultimoCorte.saldoFinalEfectivo } : 'null');
    console.log('Saldo inicial del día:', saldoInicialDelDia ? { id: saldoInicialDelDia.id, createdAt: saldoInicialDelDia.createdAt, saldoInicialEfectivo: saldoInicialDelDia.saldoInicialEfectivo } : 'null');
    console.log('Desde fecha:', desdeFecha);
    console.log('Saldo inicial efectivo:', saldoInicialEfectivo);
    console.log('Ventas efectivo:', ventasEfectivo);
    console.log('Gastos efectivo:', gastosEfectivo);
    console.log('Total retiros:', totalRetiros);
    console.log('Saldo esperado:', saldoEsperado);
    console.log('Cantidad de ventas:', ventas.length);
    console.log('Cantidad de gastos:', gastos.length);
    console.log('Cantidad de retiros:', retiros.length);

    // Obtener hora actual
    const horaActual = moment().tz(config.timezone).format('HH:mm');

    res.render('pos/corte', {
      title: 'Corte de Efectivo',
      hora: horaActual,
      esManual: true,
      tipoCorte: 'efectivo',
      esFinDia: false,
      ultimoCorte: saldoInicialDelDia || ultimoCorte,
      ventas,
      gastos: otrosGastos, // Solo otros gastos (sin retiros)
      retiros: retiros || [], // Retiros separados, siempre un array
      ventasPorDoctor: [],
      desdeFecha,
      formatCurrency,
      moment,
      config,
      now: () => moment().tz(config.timezone),
      resumen: {
        saldoInicial: saldoInicialEfectivo,
        saldoInicialEfectivo: saldoInicialEfectivo,
        ventasEfectivo,
        ventasTarjeta: 0,
        ventasTransferencia: 0,
        ventasTarjetaAzteca: 0,
        ventasTarjetaBbva: 0,
        ventasTarjetaMp: 0,
        ventasTransferenciaAzteca: 0,
        ventasTransferenciaBbva: 0,
        ventasTransferenciaMp: 0,
        totalVentas: ventasEfectivo,
        gastosEfectivo,
        saldoEsperado,
        cantidadVentas: ventas.length,
        totalRetiros,
      },
    });
  } catch (error) {
    console.error('Error al mostrar corte de efectivo:', error);
    res.render('error', { title: 'Error', message: 'Error al cargar corte de efectivo', error });
  }
};

// Procesar corte de efectivo
const procesarCorteEfectivo = async (req, res) => {
  try {
    const { hora, saldoFinal, observaciones } = req.body;

    if (!hora) {
      return res.status(400).json({ error: 'Hora requerida' });
    }

    if (!saldoFinal || isNaN(parseFloat(saldoFinal))) {
      return res.status(400).json({ error: 'Saldo final requerido y debe ser un número válido' });
    }

    const horaRegex = /^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/;
    if (!horaRegex.test(hora)) {
      return res.status(400).json({ error: 'Formato de hora inválido. Use HH:MM (ejemplo: 14:00)' });
    }

    const hoy = moment().tz(config.timezone).startOf('day').toDate();
    const mañana = moment().tz(config.timezone).endOf('day').toDate();

    // Verificar si ya existe un corte de efectivo a esta hora exacta HOY
    const corteExistente = await prisma.corteCaja.findFirst({
      where: {
        fecha: { gte: hoy, lte: mañana },
        hora: hora,
      },
    });

    if (corteExistente) {
      return res.status(400).json({
        error: 'Ya se realizó un corte a las ' + hora + ' hoy. Si necesitas hacer otro corte, usa una hora diferente.'
      });
    }

    // --- Lógica de Reseteo Independiente para Efectivo ---
    const ultimoResetEfectivo = await prisma.corteCaja.findFirst({
      where: {
        OR: [
          { hora: null },
          { AND: [{ hora: { not: null } }, { ventasEfectivo: { gt: 0 } }] },
          { AND: [{ hora: { not: null } }, { ventasTarjeta: 0 }, { ventasTransferencia: 0 }] }
        ]
      },
      orderBy: { createdAt: 'desc' }
    });

    if (!ultimoResetEfectivo) {
      return res.status(400).json({ error: 'No se encontró el saldo inicial del día o el último reset de efectivo.' });
    }

    const desdeFecha = ultimoResetEfectivo.createdAt;
    const saldoInicialEfectivo = parseFloat(ultimoResetEfectivo.saldoFinalEfectivo || ultimoResetEfectivo.saldoInicialEfectivo || 0);

    // Buscar ultimo corte general para llevar saldos de bancos
    const ultimoCorte = await prisma.corteCaja.findFirst({
      where: { fecha: { gte: hoy, lte: mañana }, hora: { not: null } },
      orderBy: { createdAt: 'desc' }
    });
    const saldoInicialDelDia = await prisma.corteCaja.findFirst({
      where: { fecha: { gte: hoy, lte: mañana }, hora: null },
      orderBy: { createdAt: 'desc' }
    });

    // Obtener ventas en efectivo
    const ventas = await prisma.venta.findMany({
      where: {
        createdAt: { gte: desdeFecha },
        metodoPago: 'efectivo',
      },
      select: {
        total: true,
      },
    });

    // Obtener gastos en efectivo
    const gastos = await prisma.gasto.findMany({
      where: {
        createdAt: { gte: desdeFecha },
        metodoPago: 'efectivo',
      },
      select: {
        monto: true,
      },
    });

    const ventasEfectivo = ventas.reduce((sum, v) => sum + parseFloat(v.total), 0);
    const gastosEfectivo = gastos.reduce((sum, g) => sum + parseFloat(g.monto), 0);
    const saldoFinalCalculado = parseFloat(saldoFinal);
    const diferencia = saldoFinalCalculado - (saldoInicialEfectivo + ventasEfectivo - gastosEfectivo);

    // --- Calcular saldos de bancos para el snapshot (MULTIDÍA) ---
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

    const desdeFechaBancos = ultimoResetBancos ? ultimoResetBancos.createdAt : new Date(0);
    const ventasBancosSnapshot = await prisma.venta.findMany({
      where: { createdAt: { gte: desdeFechaBancos }, metodoPago: { in: ['tarjeta', 'transferencia'] } },
      select: { total: true, banco: true, metodoPago: true }
    });
    const gastosBancosSnapshot = await prisma.gasto.findMany({
      where: { createdAt: { gte: desdeFechaBancos }, metodoPago: { in: ['tarjeta', 'transferencia'] } },
      select: { monto: true, banco: true, metodoPago: true }
    });

    const getB = (obj) => {
      const b = (obj.banco || '').toLowerCase();
      if (b.includes('azteca')) return 'azteca';
      if (b.includes('bbva')) return 'bbva';
      if (b.includes('mercado') || b.includes('mp')) return 'mp';
      return 'otros';
    };

    let saldoFinalTarjetaAzteca = ultimoResetBancos ? parseFloat(ultimoResetBancos.saldoFinalTarjetaAzteca || 0) : 0;
    let saldoFinalTarjetaBbva = ultimoResetBancos ? parseFloat(ultimoResetBancos.saldoFinalTarjetaBbva || 0) : 0;
    let saldoFinalTarjetaMp = ultimoResetBancos ? parseFloat(ultimoResetBancos.saldoFinalTarjetaMp || 0) : 0;
    let saldoFinalTransferenciaAzteca = ultimoResetBancos ? parseFloat(ultimoResetBancos.saldoFinalTransferenciaAzteca || 0) : 0;
    let saldoFinalTransferenciaBbva = ultimoResetBancos ? parseFloat(ultimoResetBancos.saldoFinalTransferenciaBbva || 0) : 0;
    let saldoFinalTransferenciaMp = ultimoResetBancos ? parseFloat(ultimoResetBancos.saldoFinalTransferenciaMp || 0) : 0;

    ventasBancosSnapshot.forEach(v => {
      const b = getB(v);
      const m = (v.metodoPago || '').toLowerCase();
      if (m === 'tarjeta') {
        if (b === 'azteca') saldoFinalTarjetaAzteca += parseFloat(v.total);
        else if (b === 'bbva') saldoFinalTarjetaBbva += parseFloat(v.total);
        else if (b === 'mp') saldoFinalTarjetaMp += parseFloat(v.total);
      } else {
        if (b === 'azteca') saldoFinalTransferenciaAzteca += parseFloat(v.total);
        else if (b === 'bbva') saldoFinalTransferenciaBbva += parseFloat(v.total);
        else if (b === 'mp') saldoFinalTransferenciaMp += parseFloat(v.total);
      }
    });

    gastosBancosSnapshot.forEach(g => {
      const b = getB(g);
      const m = (g.metodoPago || '').toLowerCase();
      if (m === 'tarjeta') {
        if (b === 'azteca') saldoFinalTarjetaAzteca -= parseFloat(g.monto);
        else if (b === 'bbva') saldoFinalTarjetaBbva -= parseFloat(g.monto);
        else if (b === 'mp') saldoFinalTarjetaMp -= parseFloat(g.monto);
      } else {
        if (b === 'azteca') saldoFinalTransferenciaAzteca -= parseFloat(g.monto);
        else if (b === 'bbva') saldoFinalTransferenciaBbva -= parseFloat(g.monto);
        else if (b === 'mp') saldoFinalTransferenciaMp -= parseFloat(g.monto);
      }
    });

    const saldoFinalTransferencia = saldoFinalTransferenciaAzteca + saldoFinalTransferenciaBbva + saldoFinalTransferenciaMp;
    const saldoFinalTotal = saldoFinalCalculado + saldoFinalTarjetaAzteca + saldoFinalTarjetaBbva + saldoFinalTarjetaMp + saldoFinalTransferencia;

    // Crear corte de efectivo (VentasTarjeta y Transferencia se guardan como 0 para no resetear la acumulación)
    await prisma.corteCaja.create({
      data: {
        fecha: new Date(),
        hora: hora,
        saldoInicial: saldoInicialEfectivo,
        saldoInicialEfectivo: saldoInicialEfectivo,
        saldoInicialTarjetaAzteca: 0,
        saldoInicialTarjetaBbva: 0,
        saldoInicialTarjetaMp: 0,
        saldoInicialTransferencia: 0,
        ventasEfectivo: ventasEfectivo,
        ventasTarjeta: 0, // MARCADOR: No resetea acumulación de bancos
        ventasTransferencia: 0,
        ventasTarjetaAzteca: 0,
        ventasTarjetaBbva: 0,
        ventasTarjetaMp: 0,
        ventasTransferenciaAzteca: 0,
        ventasTransferenciaBbva: 0,
        ventasTransferenciaMp: 0,
        totalVentas: ventasEfectivo,
        saldoFinal: saldoFinalTotal,
        saldoFinalEfectivo: saldoFinalCalculado,
        saldoFinalTarjetaAzteca: saldoFinalTarjetaAzteca,
        saldoFinalTarjetaBbva: saldoFinalTarjetaBbva,
        saldoFinalTarjetaMp: saldoFinalTarjetaMp,
        saldoFinalTransferencia: saldoFinalTransferencia,
        saldoFinalTransferenciaAzteca: saldoFinalTransferenciaAzteca,
        saldoFinalTransferenciaBbva: saldoFinalTransferenciaBbva,
        saldoFinalTransferenciaMp: saldoFinalTransferenciaMp,
        diferencia: diferencia,
        observaciones: observaciones || null,
        usuarioId: req.session.user?.id || null,
      },
    });

    // Obtener saldo final de efectivo después del corte
    const saldoFinalEfectivoDespuesCorte = parseFloat(saldoFinalCalculado);

    res.json({
      success: true,
      requiereSaldoInicial: true,
      esFinDia: false,
      saldoFinalEfectivo: saldoFinalEfectivoDespuesCorte,
      preguntaRetiro: true // Indicar que debe preguntar si desea hacer retiro
    });
  } catch (error) {
    console.error('Error al procesar corte de efectivo:', error);
    res.status(500).json({ error: 'Error al procesar corte de efectivo' });
  }
};

// Mostrar vista de corte de bancos
const mostrarCorteBancos = async (req, res) => {
  try {
    const hoy = moment().tz(config.timezone).startOf('day').toDate();
    const mañana = moment().tz(config.timezone).endOf('day').toDate();

    // --- Lógica de Reseteo Independiente para Bancos ---
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

    if (!ultimoResetBancos) {
      return res.redirect('/pos?necesitaSaldoInicial=true');
    }

    const desdeFecha = ultimoResetBancos.createdAt;

    let saldoInicialTarjetaAzteca = parseFloat(ultimoResetBancos.saldoFinalTarjetaAzteca || ultimoResetBancos.saldoInicialTarjetaAzteca || 0);
    let saldoInicialTarjetaBbva = parseFloat(ultimoResetBancos.saldoFinalTarjetaBbva || ultimoResetBancos.saldoInicialTarjetaBbva || 0);
    let saldoInicialTarjetaMp = parseFloat(ultimoResetBancos.saldoFinalTarjetaMp || ultimoResetBancos.saldoInicialTarjetaMp || 0);

    let saldoInicialTransferenciaAzteca = parseFloat(ultimoResetBancos.saldoFinalTransferenciaAzteca || 0);
    let saldoInicialTransferenciaBbva = parseFloat(ultimoResetBancos.saldoFinalTransferenciaBbva || 0);
    let saldoInicialTransferenciaMp = parseFloat(ultimoResetBancos.saldoFinalTransferenciaMp || 0);

    // Compatibilidad con saldos iniciales planos
    if (ultimoResetBancos.hora === null && saldoInicialTransferenciaAzteca === 0 && parseFloat(ultimoResetBancos.saldoInicialTransferencia || 0) > 0) {
      const t = parseFloat(ultimoResetBancos.saldoInicialTransferencia);
      saldoInicialTransferenciaAzteca = t / 3;
      saldoInicialTransferenciaBbva = t / 3;
      saldoInicialTransferenciaMp = t / 3;
    }

    // Buscar ultimo corte general/saldo inicial para referencia
    const ultimoCorte = await prisma.corteCaja.findFirst({
      where: { fecha: { gte: hoy, lte: mañana }, hora: { not: null } },
      orderBy: { createdAt: 'desc' }
    });
    const saldoInicialDelDia = await prisma.corteCaja.findFirst({
      where: { fecha: { gte: hoy, lte: mañana }, hora: null },
      orderBy: { createdAt: 'desc' }
    });

    // Obtener ventas con tarjeta y transferencia
    const ventas = await prisma.venta.findMany({
      where: {
        createdAt: { gte: desdeFecha },
        metodoPago: { in: ['tarjeta', 'transferencia'] },
      },
      include: {
        paciente: true,
        doctor: true,
        items: {
          include: {
            servicio: true,
            producto: true,
          },
        },
      },
      orderBy: { createdAt: 'asc' },
    });

    // Obtener gastos con tarjeta y transferencia
    const gastos = await prisma.gasto.findMany({
      where: {
        createdAt: { gte: desdeFecha },
        metodoPago: { in: ['tarjeta', 'transferencia'] },
      },
      include: {
        usuario: {
          select: {
            nombre: true,
          },
        },
      },
      orderBy: { createdAt: 'asc' },
    });

    // Calcular ventas por banco - Tarjeta
    const ventasTarjetaAzteca = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'tarjeta' && getBanco(v) === 'Azteca')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);
    const ventasTarjetaBbva = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'tarjeta' && getBanco(v) === 'BBVA')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);
    const ventasTarjetaMp = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'tarjeta' && getBanco(v) === 'Mercado Pago')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);

    // Calcular ventas por banco - Transferencia
    const ventasTransferenciaAzteca = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'transferencia' && getBanco(v) === 'Azteca')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);
    const ventasTransferenciaBbva = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'transferencia' && getBanco(v) === 'BBVA')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);
    const ventasTransferenciaMp = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'transferencia' && getBanco(v) === 'Mercado Pago')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);

    // Calcular gastos por banco - Tarjeta
    const gastosTarjetaAzteca = gastos
      .filter(g => g.metodoPago === 'tarjeta' && g.banco === 'Azteca')
      .reduce((sum, g) => sum + parseFloat(g.monto), 0);
    const gastosTarjetaBbva = gastos
      .filter(g => g.metodoPago === 'tarjeta' && g.banco === 'BBVA')
      .reduce((sum, g) => sum + parseFloat(g.monto), 0);
    const gastosTarjetaMp = gastos
      .filter(g => g.metodoPago === 'tarjeta' && g.banco === 'Mercado Pago')
      .reduce((sum, g) => sum + parseFloat(g.monto), 0);

    // Calcular gastos por banco - Transferencia
    const gastosTransferenciaAzteca = gastos
      .filter(g => g.metodoPago === 'transferencia' && g.banco === 'Azteca')
      .reduce((sum, g) => sum + parseFloat(g.monto), 0);
    const gastosTransferenciaBbva = gastos
      .filter(g => g.metodoPago === 'transferencia' && g.banco === 'BBVA')
      .reduce((sum, g) => sum + parseFloat(g.monto), 0);
    const gastosTransferenciaMp = gastos
      .filter(g => g.metodoPago === 'transferencia' && g.banco === 'Mercado Pago')
      .reduce((sum, g) => sum + parseFloat(g.monto), 0);

    // Calcular saldos esperados por banco
    const saldoEsperadoAzteca = saldoInicialTarjetaAzteca + saldoInicialTransferenciaAzteca +
      ventasTarjetaAzteca + ventasTransferenciaAzteca - gastosTarjetaAzteca - gastosTransferenciaAzteca;
    const saldoEsperadoBbva = saldoInicialTarjetaBbva + saldoInicialTransferenciaBbva +
      ventasTarjetaBbva + ventasTransferenciaBbva - gastosTarjetaBbva - gastosTransferenciaBbva;
    const saldoEsperadoMp = saldoInicialTarjetaMp + saldoInicialTransferenciaMp +
      ventasTarjetaMp + ventasTransferenciaMp - gastosTarjetaMp - gastosTransferenciaMp;

    const horaActual = moment().tz(config.timezone).format('HH:mm');

    res.render('pos/corte', {
      title: 'Corte de Bancos',
      hora: horaActual,
      esManual: true,
      tipoCorte: 'bancos',
      esFinDia: false,
      ultimoCorte: saldoInicialDelDia || ultimoCorte,
      ventas,
      gastos: gastos || [],
      retiros: [], // No hay retiros en corte de bancos
      ventasPorDoctor: [],
      desdeFecha,
      formatCurrency,
      moment,
      config,
      now: () => moment().tz(config.timezone),
      resumen: {
        saldoInicial: 0,
        saldoInicialEfectivo: 0,
        saldoInicialTarjetaAzteca,
        saldoInicialTarjetaBbva,
        saldoInicialTarjetaMp,
        saldoInicialTransferenciaAzteca,
        saldoInicialTransferenciaBbva,
        saldoInicialTransferenciaMp,
        ventasEfectivo: 0,
        ventasTarjeta: ventasTarjetaAzteca + ventasTarjetaBbva + ventasTarjetaMp,
        ventasTransferencia: ventasTransferenciaAzteca + ventasTransferenciaBbva + ventasTransferenciaMp,
        ventasTarjetaAzteca,
        ventasTarjetaBbva,
        ventasTarjetaMp,
        ventasTransferenciaAzteca,
        ventasTransferenciaBbva,
        ventasTransferenciaMp,
        gastosTarjetaAzteca,
        gastosTarjetaBbva,
        gastosTarjetaMp,
        gastosTransferenciaAzteca,
        gastosTransferenciaBbva,
        gastosTransferenciaMp,
        totalVentas: ventasTarjetaAzteca + ventasTarjetaBbva + ventasTarjetaMp + ventasTransferenciaAzteca + ventasTransferenciaBbva + ventasTransferenciaMp,
        saldoEsperadoAzteca,
        saldoEsperadoBbva,
        saldoEsperadoMp,
        cantidadVentas: ventas.length,
      },
    });
  } catch (error) {
    console.error('Error al mostrar corte de bancos:', error);
    res.render('error', { title: 'Error', message: 'Error al cargar corte de bancos', error });
  }
};

// Procesar corte de bancos
const procesarCorteBancos = async (req, res) => {
  try {
    const { hora, saldoFinalAzteca, saldoFinalBbva, saldoFinalMp, observaciones } = req.body;

    if (!hora) {
      return res.status(400).json({ error: 'Hora requerida' });
    }

    const horaRegex = /^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/;
    if (!horaRegex.test(hora)) {
      return res.status(400).json({ error: 'Formato de hora inválido. Use HH:MM (ejemplo: 14:00)' });
    }

    // Validar que los saldos finales sean números válidos (permitir 0)
    // Usar !== null y !== undefined para permitir 0, pero rechazar valores inválidos
    if (saldoFinalAzteca === null || saldoFinalAzteca === undefined || saldoFinalAzteca === '' || isNaN(parseFloat(saldoFinalAzteca))) {
      return res.status(400).json({ error: 'Saldo final Azteca requerido (puede ser 0.00)' });
    }
    if (saldoFinalBbva === null || saldoFinalBbva === undefined || saldoFinalBbva === '' || isNaN(parseFloat(saldoFinalBbva))) {
      return res.status(400).json({ error: 'Saldo final BBVA requerido (puede ser 0.00)' });
    }
    if (saldoFinalMp === null || saldoFinalMp === undefined || saldoFinalMp === '' || isNaN(parseFloat(saldoFinalMp))) {
      return res.status(400).json({ error: 'Saldo final Mercado Pago requerido (puede ser 0.00)' });
    }

    const hoy = moment().tz(config.timezone).startOf('day').toDate();
    const mañana = moment().tz(config.timezone).endOf('day').toDate();

    // Verificar si ya existe un corte de bancos a esta hora exacta HOY
    const corteExistente = await prisma.corteCaja.findFirst({
      where: {
        fecha: { gte: hoy, lte: mañana },
        hora: hora,
      },
    });

    if (corteExistente) {
      return res.status(400).json({
        error: 'Ya se realizó un corte a las ' + hora + ' hoy. Si necesitas hacer otro corte, usa una hora diferente.'
      });
    }

    // --- Lógica de Reseteo Independiente para Bancos ---
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

    if (!ultimoResetBancos) {
      return res.status(400).json({ error: 'No se encontró el saldo inicial del día o el último reset de bancos.' });
    }

    const desdeFecha = ultimoResetBancos.createdAt;

    let saldoInicialTarjetaAzteca = parseFloat(ultimoResetBancos.saldoFinalTarjetaAzteca || ultimoResetBancos.saldoInicialTarjetaAzteca || 0);
    let saldoInicialTarjetaBbva = parseFloat(ultimoResetBancos.saldoFinalTarjetaBbva || ultimoResetBancos.saldoInicialTarjetaBbva || 0);
    let saldoInicialTarjetaMp = parseFloat(ultimoResetBancos.saldoFinalTarjetaMp || ultimoResetBancos.saldoInicialTarjetaMp || 0);

    let saldoInicialTransferenciaAzteca = parseFloat(ultimoResetBancos.saldoFinalTransferenciaAzteca || 0);
    let saldoInicialTransferenciaBbva = parseFloat(ultimoResetBancos.saldoFinalTransferenciaBbva || 0);
    let saldoInicialTransferenciaMp = parseFloat(ultimoResetBancos.saldoFinalTransferenciaMp || 0);

    // Buscar ultimo corte general para referencia
    const ultimoCorte = await prisma.corteCaja.findFirst({
      where: { fecha: { gte: hoy, lte: mañana }, hora: { not: null } },
      orderBy: { createdAt: 'desc' }
    });
    const saldoInicialDelDia = await prisma.corteCaja.findFirst({
      where: { fecha: { gte: hoy, lte: mañana }, hora: null },
      orderBy: { createdAt: 'desc' }
    });

    // Obtener ventas con tarjeta y transferencia
    const ventas = await prisma.venta.findMany({
      where: {
        createdAt: { gte: desdeFecha },
        metodoPago: { in: ['tarjeta', 'transferencia'] },
      },
      select: {
        total: true,
        metodoPago: true,
        banco: true,
      },
    });

    // Obtener gastos con tarjeta y transferencia
    const gastos = await prisma.gasto.findMany({
      where: {
        createdAt: { gte: desdeFecha },
        metodoPago: { in: ['tarjeta', 'transferencia'] },
      },
      select: {
        monto: true,
        metodoPago: true,
        banco: true,
      },
    });

    // Calcular ventas por banco
    const ventasTarjetaAzteca = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'tarjeta' && getBanco(v) === 'Azteca')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);
    const ventasTarjetaBbva = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'tarjeta' && getBanco(v) === 'BBVA')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);
    const ventasTarjetaMp = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'tarjeta' && getBanco(v) === 'Mercado Pago')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);
    const ventasTransferenciaAzteca = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'transferencia' && getBanco(v) === 'Azteca')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);
    const ventasTransferenciaBbva = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'transferencia' && getBanco(v) === 'BBVA')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);
    const ventasTransferenciaMp = ventas
      .filter(v => getMetodoBase(v.metodoPago) === 'transferencia' && getBanco(v) === 'Mercado Pago')
      .reduce((sum, v) => sum + parseFloat(v.total), 0);

    // Calcular gastos por banco
    const gastosTarjetaAzteca = gastos
      .filter(g => g.metodoPago === 'tarjeta' && g.banco === 'Azteca')
      .reduce((sum, g) => sum + parseFloat(g.monto), 0);
    const gastosTarjetaBbva = gastos
      .filter(g => g.metodoPago === 'tarjeta' && g.banco === 'BBVA')
      .reduce((sum, g) => sum + parseFloat(g.monto), 0);
    const gastosTarjetaMp = gastos
      .filter(g => g.metodoPago === 'tarjeta' && g.banco === 'Mercado Pago')
      .reduce((sum, g) => sum + parseFloat(g.monto), 0);
    const gastosTransferenciaAzteca = gastos
      .filter(g => g.metodoPago === 'transferencia' && g.banco === 'Azteca')
      .reduce((sum, g) => sum + parseFloat(g.monto), 0);
    const gastosTransferenciaBbva = gastos
      .filter(g => g.metodoPago === 'transferencia' && g.banco === 'BBVA')
      .reduce((sum, g) => sum + parseFloat(g.monto), 0);
    const gastosTransferenciaMp = gastos
      .filter(g => g.metodoPago === 'transferencia' && g.banco === 'Mercado Pago')
      .reduce((sum, g) => sum + parseFloat(g.monto), 0);

    // Calcular saldos finales por banco
    const saldoFinalTarjetaAzteca = saldoInicialTarjetaAzteca + ventasTarjetaAzteca - gastosTarjetaAzteca;
    const saldoFinalTarjetaBbva = saldoInicialTarjetaBbva + ventasTarjetaBbva - gastosTarjetaBbva;
    const saldoFinalTarjetaMp = saldoInicialTarjetaMp + ventasTarjetaMp - gastosTarjetaMp;
    const saldoFinalTransferenciaAzteca = saldoInicialTransferenciaAzteca + ventasTransferenciaAzteca - gastosTransferenciaAzteca;
    const saldoFinalTransferenciaBbva = saldoInicialTransferenciaBbva + ventasTransferenciaBbva - gastosTransferenciaBbva;
    const saldoFinalTransferenciaMp = saldoInicialTransferenciaMp + ventasTransferenciaMp - gastosTransferenciaMp;

    // Los saldos finales ingresados por el usuario son TOTALES (tarjeta + transferencia)
    const saldoFinalAztecaTotal = parseFloat(saldoFinalAzteca);
    const saldoFinalBbvaTotal = parseFloat(saldoFinalBbva);
    const saldoFinalMpTotal = parseFloat(saldoFinalMp);

    // Calcular los saldos finales calculados (tarjeta + transferencia)
    const saldoFinalAztecaCalculado = saldoFinalTarjetaAzteca + saldoFinalTransferenciaAzteca;
    const saldoFinalBbvaCalculado = saldoFinalTarjetaBbva + saldoFinalTransferenciaBbva;
    const saldoFinalMpCalculado = saldoFinalTarjetaMp + saldoFinalTransferenciaMp;

    console.log('=== DEBUG PROCESAR CORTE BANCOS ===');
    console.log('Saldo Final Azteca Total (usuario):', saldoFinalAztecaTotal);
    console.log('Saldo Final Azteca Calculado:', saldoFinalAztecaCalculado);
    console.log('Saldo Final Tarjeta Azteca:', saldoFinalTarjetaAzteca);
    console.log('Saldo Final Transferencia Azteca:', saldoFinalTransferenciaAzteca);
    console.log('Saldo Inicial Tarjeta Azteca:', saldoInicialTarjetaAzteca);
    console.log('Saldo Inicial Transferencia Azteca:', saldoInicialTransferenciaAzteca);
    console.log('Ventas Tarjeta Azteca:', ventasTarjetaAzteca);
    console.log('Ventas Transferencia Azteca:', ventasTransferenciaAzteca);

    // Distribuir el saldo final total ingresado por el usuario proporcionalmente entre tarjeta y transferencia
    // IMPORTANTE: Si el usuario ingresó 0, ambos (tarjeta y transferencia) deben ser 0
    let saldoFinalTarjetaAztecaGuardar = 0;
    let saldoFinalTarjetaBbvaGuardar = 0;
    let saldoFinalTarjetaMpGuardar = 0;
    let saldoFinalTransferenciaAztecaGuardar = 0;
    let saldoFinalTransferenciaBbvaGuardar = 0;
    let saldoFinalTransferenciaMpGuardar = 0;

    // Si el usuario ingresó 0, ambos (tarjeta y transferencia) deben ser 0
    if (Math.abs(saldoFinalAztecaTotal) < 0.01) {
      console.log('Usuario ingresó 0 para Azteca, estableciendo ambos en 0');
      saldoFinalTarjetaAztecaGuardar = 0;
      saldoFinalTransferenciaAztecaGuardar = 0;
    } else if (Math.abs(saldoFinalAztecaCalculado) > 0.01) {
      // Si hay saldo calculado, distribuir proporcionalmente
      const factorAzteca = saldoFinalAztecaTotal / saldoFinalAztecaCalculado;
      saldoFinalTarjetaAztecaGuardar = saldoFinalTarjetaAzteca * factorAzteca;
      saldoFinalTransferenciaAztecaGuardar = saldoFinalTransferenciaAzteca * factorAzteca;
    } else {
      // Si no hay saldo calculado (ambos son 0), el usuario ingresó el total, dividirlo proporcionalmente
      // Usar los saldos iniciales como base para la proporción
      const totalInicialAzteca = saldoInicialTarjetaAzteca + saldoInicialTransferenciaAzteca;
      if (totalInicialAzteca > 0) {
        saldoFinalTarjetaAztecaGuardar = (saldoInicialTarjetaAzteca / totalInicialAzteca) * saldoFinalAztecaTotal;
        saldoFinalTransferenciaAztecaGuardar = (saldoInicialTransferenciaAzteca / totalInicialAzteca) * saldoFinalAztecaTotal;
      } else {
        // Si no hay saldo inicial, dividir 50/50
        saldoFinalTarjetaAztecaGuardar = saldoFinalAztecaTotal / 2;
        saldoFinalTransferenciaAztecaGuardar = saldoFinalAztecaTotal / 2;
      }
    }

    // Si el usuario ingresó 0, ambos (tarjeta y transferencia) deben ser 0
    if (Math.abs(saldoFinalBbvaTotal) < 0.01) {
      console.log('Usuario ingresó 0 para BBVA, estableciendo ambos en 0');
      saldoFinalTarjetaBbvaGuardar = 0;
      saldoFinalTransferenciaBbvaGuardar = 0;
    } else if (Math.abs(saldoFinalBbvaCalculado) > 0.01) {
      // Si hay saldo calculado, distribuir proporcionalmente
      const factorBbva = saldoFinalBbvaTotal / saldoFinalBbvaCalculado;
      saldoFinalTarjetaBbvaGuardar = saldoFinalTarjetaBbva * factorBbva;
      saldoFinalTransferenciaBbvaGuardar = saldoFinalTransferenciaBbva * factorBbva;
    } else {
      // Si no hay saldo calculado (ambos son 0), el usuario ingresó el total, dividirlo proporcionalmente
      const totalInicialBbva = saldoInicialTarjetaBbva + saldoInicialTransferenciaBbva;
      if (totalInicialBbva > 0) {
        saldoFinalTarjetaBbvaGuardar = (saldoInicialTarjetaBbva / totalInicialBbva) * saldoFinalBbvaTotal;
        saldoFinalTransferenciaBbvaGuardar = (saldoInicialTransferenciaBbva / totalInicialBbva) * saldoFinalBbvaTotal;
      } else {
        saldoFinalTarjetaBbvaGuardar = saldoFinalBbvaTotal / 2;
        saldoFinalTransferenciaBbvaGuardar = saldoFinalBbvaTotal / 2;
      }
    }

    // Si el usuario ingresó 0, ambos (tarjeta y transferencia) deben ser 0
    if (Math.abs(saldoFinalMpTotal) < 0.01) {
      console.log('Usuario ingresó 0 para Mercado Pago, estableciendo ambos en 0');
      saldoFinalTarjetaMpGuardar = 0;
      saldoFinalTransferenciaMpGuardar = 0;
    } else if (Math.abs(saldoFinalMpCalculado) > 0.01) {
      // Si hay saldo calculado, distribuir proporcionalmente
      const factorMp = saldoFinalMpTotal / saldoFinalMpCalculado;
      saldoFinalTarjetaMpGuardar = saldoFinalTarjetaMp * factorMp;
      saldoFinalTransferenciaMpGuardar = saldoFinalTransferenciaMp * factorMp;
    } else {
      // Si no hay saldo calculado (ambos son 0), el usuario ingresó el total, dividirlo proporcionalmente
      const totalInicialMp = saldoInicialTarjetaMp + saldoInicialTransferenciaMp;
      if (totalInicialMp > 0) {
        saldoFinalTarjetaMpGuardar = (saldoInicialTarjetaMp / totalInicialMp) * saldoFinalMpTotal;
        saldoFinalTransferenciaMpGuardar = (saldoInicialTransferenciaMp / totalInicialMp) * saldoFinalMpTotal;
      } else {
        saldoFinalTarjetaMpGuardar = saldoFinalMpTotal / 2;
        saldoFinalTransferenciaMpGuardar = saldoFinalMpTotal / 2;
      }
    }

    // --- Calcular saldo de efectivo para el snapshot (MULTIDÍA) ---
    const ultimoResetEfectivo = await prisma.corteCaja.findFirst({
      where: {
        OR: [
          { hora: null },
          { AND: [{ hora: { not: null } }, { ventasEfectivo: { gt: 0 } }] },
          { AND: [{ hora: { not: null } }, { ventasTarjeta: 0 }, { ventasTransferencia: 0 }] }
        ]
      },
      orderBy: { createdAt: 'desc' }
    });

    const desdeFechaEfectivo = ultimoResetEfectivo ? ultimoResetEfectivo.createdAt : hoy;
    const ventasEfectivoSnapshot = await prisma.venta.findMany({
      where: { createdAt: { gte: desdeFechaEfectivo }, metodoPago: 'efectivo' },
      select: { total: true }
    });
    const gastosEfectivoSnapshot = await prisma.gasto.findMany({
      where: { createdAt: { gte: desdeFechaEfectivo }, metodoPago: 'efectivo' },
      select: { monto: true }
    });

    const sumVE = ventasEfectivoSnapshot.reduce((sum, v) => sum + parseFloat(v.total), 0);
    const sumGE = gastosEfectivoSnapshot.reduce((sum, g) => sum + parseFloat(g.monto), 0);
    const saldoFinalEfectivoActual = (ultimoResetEfectivo ? parseFloat(ultimoResetEfectivo.saldoFinalEfectivo || ultimoResetEfectivo.saldoInicialEfectivo || 0) : 0) + sumVE - sumGE;

    const saldoFinalTransferencia = saldoFinalTransferenciaAztecaGuardar + saldoFinalTransferenciaBbvaGuardar + saldoFinalTransferenciaMpGuardar;
    const saldoFinalTotal = saldoFinalEfectivoActual + saldoFinalAztecaTotal + saldoFinalBbvaTotal + saldoFinalMpTotal;
    const totalVentas = ventasTarjetaAzteca + ventasTarjetaBbva + ventasTarjetaMp + ventasTransferenciaAzteca + ventasTransferenciaBbva + ventasTransferenciaMp;

    console.log('=== VALORES A GUARDAR ===');
    console.log('saldoFinalTarjetaAztecaGuardar:', saldoFinalTarjetaAztecaGuardar);
    console.log('saldoFinalTransferenciaAztecaGuardar:', saldoFinalTransferenciaAztecaGuardar);
    console.log('saldoFinalTarjetaBbvaGuardar:', saldoFinalTarjetaBbvaGuardar);
    console.log('saldoFinalTransferenciaBbvaGuardar:', saldoFinalTransferenciaBbvaGuardar);
    console.log('saldoFinalTarjetaMpGuardar:', saldoFinalTarjetaMpGuardar);
    console.log('saldoFinalTransferenciaMpGuardar:', saldoFinalTransferenciaMpGuardar);

    // Crear corte de bancos
    await prisma.corteCaja.create({
      data: {
        fecha: new Date(),
        hora: hora,
        saldoInicial: 0,
        saldoInicialEfectivo: 0,
        saldoInicialTarjetaAzteca: saldoInicialTarjetaAzteca,
        saldoInicialTarjetaBbva: saldoInicialTarjetaBbva,
        saldoInicialTarjetaMp: saldoInicialTarjetaMp,
        saldoInicialTransferencia: saldoInicialTransferenciaAzteca + saldoInicialTransferenciaBbva + saldoInicialTransferenciaMp,
        ventasEfectivo: 0,
        ventasTarjeta: ventasTarjetaAzteca + ventasTarjetaBbva + ventasTarjetaMp,
        ventasTransferencia: ventasTransferenciaAzteca + ventasTransferenciaBbva + ventasTransferenciaMp,
        ventasTarjetaAzteca: ventasTarjetaAzteca,
        ventasTarjetaBbva: ventasTarjetaBbva,
        ventasTarjetaMp: ventasTarjetaMp,
        ventasTransferenciaAzteca: ventasTransferenciaAzteca,
        ventasTransferenciaBbva: ventasTransferenciaBbva,
        ventasTransferenciaMp: ventasTransferenciaMp,
        totalVentas: totalVentas,
        saldoFinal: saldoFinalTotal,
        saldoFinalEfectivo: saldoFinalEfectivoActual,
        saldoFinalTarjetaAzteca: 0,
        saldoFinalTarjetaBbva: 0,
        saldoFinalTarjetaMp: 0,
        saldoFinalTransferencia: 0,
        saldoFinalTransferenciaAzteca: 0,
        saldoFinalTransferenciaBbva: 0,
        saldoFinalTransferenciaMp: 0,
        diferencia: 0, // No hay diferencia en corte de bancos
        observaciones: observaciones || null,
        usuarioId: req.session.user?.id || null,
      },
    });

    res.json({
      success: true,
      requiereSaldoInicial: false, // Los cortes de bancos no reinician el cajón de efectivo
      esFinDia: false,
      saldoFinalEfectivo: saldoFinalEfectivoActual
    });
  } catch (error) {
    console.error('Error al procesar corte de bancos:', error);
    res.status(500).json({ error: 'Error al procesar corte de bancos' });
  }
};

module.exports = {
  index,
  processSale,
  ventas,
  servicios,
  saveServicio,
  productos,
  saveProducto,
  getVenta,
  guardarSaldoInicial,
  mostrarCorte,
  procesarCorte,
  verificarPasswordAdmin,
  mostrarCorteManual,
  procesarCorteManual,
  mostrarCorteEfectivo,
  procesarCorteEfectivo,
  mostrarCorteBancos,
  procesarCorteBancos,
  obtenerSaldosActuales,
  obtenerLimiteEfectivo,
  retirarEfectivo,
  verificarPasswordUsuario,
};

