const prisma = require('../config/database');
const moment = require('moment-timezone');
const config = require('../config/config');

// Listar laboratorios
const index = async (req, res) => {
  try {
    const { search } = req.query;
    
    let where = { activo: true };
    if (search) {
      where.OR = [
        { nombre: { contains: search } },
        { contacto: { contains: search } },
        { telefono: { contains: search } },
      ];
    }

    const laboratorios = await prisma.laboratorio.findMany({
      where,
      orderBy: { createdAt: 'desc' },
    });

    // Calcular deudas por laboratorio
    const deudasPorLaboratorio = await prisma.servicioLaboratorio.groupBy({
      by: ['laboratorioId'],
      where: {
        estado: { not: 'cancelado' },
        laboratorio: {
          activo: true,
        },
      },
      _sum: {
        saldoPendiente: true,
        montoPagado: true,
        costo: true,
      },
      _count: {
        id: true,
      },
    });

    // Obtener detalles de los laboratorios con deuda
    const estadisticas = await Promise.all(
      deudasPorLaboratorio.map(async (deuda) => {
        const laboratorio = await prisma.laboratorio.findUnique({
          where: { id: deuda.laboratorioId },
          select: {
            id: true,
            nombre: true,
            contacto: true,
            telefono: true,
          },
        });

        if (!laboratorio) return null;

        return {
          laboratorio,
          totalDeuda: parseFloat(deuda._sum.saldoPendiente || 0),
          totalPagado: parseFloat(deuda._sum.montoPagado || 0),
          totalCosto: parseFloat(deuda._sum.costo || 0),
          cantidadServicios: deuda._count.id,
        };
      })
    );

    // Filtrar nulos y ordenar por deuda descendente
    const estadisticasFiltradas = estadisticas
      .filter(s => s !== null && s.totalDeuda > 0)
      .sort((a, b) => b.totalDeuda - a.totalDeuda);

    // Calcular total general
    const totalGeneral = estadisticasFiltradas.reduce((sum, s) => sum + s.totalDeuda, 0);

    res.render('laboratorios/index', {
      title: 'Laboratorios',
      laboratorios,
      search: search || '',
      estadisticas: estadisticasFiltradas,
      totalGeneral,
    });
  } catch (error) {
    console.error('Error al listar laboratorios:', error);
    res.render('error', { title: 'Error', message: 'Error al cargar laboratorios', error });
  }
};

// Mostrar formulario de crear
const create = async (req, res) => {
  res.render('laboratorios/crear', {
    title: 'Nuevo Laboratorio',
    laboratorio: null,
    error: null,
  });
};

// Guardar nuevo laboratorio
const store = async (req, res) => {
  try {
    const { nombre, contacto, telefono } = req.body;

    if (!nombre || nombre.trim() === '') {
      return res.render('laboratorios/crear', {
        title: 'Nuevo Laboratorio',
        laboratorio: req.body,
        error: 'El nombre es requerido',
      });
    }

    const laboratorio = await prisma.laboratorio.create({
      data: {
        nombre: nombre.trim(),
        contacto: contacto ? contacto.trim() : null,
        telefono: telefono ? telefono.trim() : null,
      },
    });

    res.redirect('/laboratorios');
  } catch (error) {
    console.error('Error al crear laboratorio:', error);
    res.render('laboratorios/crear', {
      title: 'Nuevo Laboratorio',
      laboratorio: req.body,
      error: 'Error al crear el laboratorio',
    });
  }
};

// Alias para compatibilidad
const createLaboratorio = create;
const storeLaboratorio = store;

// Ver detalle de laboratorio
const show = async (req, res) => {
  try {
    const { id } = req.params;
    const laboratorio = await prisma.laboratorio.findUnique({
      where: { id: parseInt(id) },
    });

    if (!laboratorio) {
      return res.status(404).render('error', {
        title: 'Laboratorio no encontrado',
        message: 'El laboratorio solicitado no existe',
      });
    }

    res.render('laboratorios/ver', {
      title: 'Detalle de Laboratorio',
      laboratorio,
    });
  } catch (error) {
    console.error('Error al obtener laboratorio:', error);
    res.render('error', { title: 'Error', message: 'Error al cargar laboratorio', error });
  }
};

// Mostrar formulario de editar
const edit = async (req, res) => {
  try {
    const { id } = req.params;
    const laboratorio = await prisma.laboratorio.findUnique({
      where: { id: parseInt(id) },
    });

    if (!laboratorio) {
      return res.status(404).render('error', {
        title: 'Laboratorio no encontrado',
        message: 'El laboratorio solicitado no existe',
      });
    }

    res.render('laboratorios/editar', {
      title: 'Editar Laboratorio',
      laboratorio,
      error: null,
    });
  } catch (error) {
    console.error('Error al obtener laboratorio:', error);
    res.render('error', { title: 'Error', message: 'Error al cargar laboratorio', error });
  }
};

// Actualizar laboratorio
const update = async (req, res) => {
  try {
    const { id } = req.params;
    const { nombre, contacto, telefono } = req.body;

    if (!nombre || nombre.trim() === '') {
      const laboratorio = await prisma.laboratorio.findUnique({
        where: { id: parseInt(id) },
      });
      return res.render('laboratorios/editar', {
        title: 'Editar Laboratorio',
        laboratorio: { ...laboratorio, ...req.body },
        error: 'El nombre es requerido',
      });
    }

    await prisma.laboratorio.update({
      where: { id: parseInt(id) },
      data: {
        nombre: nombre.trim(),
        contacto: contacto ? contacto.trim() : null,
        telefono: telefono ? telefono.trim() : null,
      },
    });

    res.redirect('/laboratorios');
  } catch (error) {
    console.error('Error al actualizar laboratorio:', error);
    const laboratorio = await prisma.laboratorio.findUnique({
      where: { id: parseInt(req.params.id) },
    });
    res.render('laboratorios/editar', {
      title: 'Editar Laboratorio',
      laboratorio: { ...laboratorio, ...req.body },
      error: 'Error al actualizar el laboratorio',
    });
  }
};

// Eliminar laboratorio (soft delete)
const destroy = async (req, res) => {
  try {
    const { id } = req.params;
    await prisma.laboratorio.update({
      where: { id: parseInt(id) },
      data: { activo: false },
    });

    res.redirect('/laboratorios');
  } catch (error) {
    console.error('Error al eliminar laboratorio:', error);
    res.redirect('/laboratorios');
  }
};

// Mostrar formulario crear servicio de laboratorio
const createServicio = async (req, res) => {
  try {
    const laboratorios = await prisma.laboratorio.findMany({
      where: { activo: true },
      orderBy: { nombre: 'asc' },
    });

    const servicios = await prisma.servicio.findMany({
      where: { activo: true },
      include: { categoria: true },
      orderBy: { nombre: 'asc' },
    });

    const doctores = await prisma.doctor.findMany({
      where: { activo: true },
      orderBy: [{ apellido: 'asc' }, { nombre: 'asc' }],
    });

    const pacientes = await prisma.paciente.findMany({
      where: { activo: true },
      orderBy: [{ apellido: 'asc' }, { nombre: 'asc' }],
    });

    // Preparar variables JSON para los componentes de búsqueda
    const pacientesDataJsonStr = JSON.stringify(pacientes.map(function(p) { 
      return { id: p.id, text: p.nombre + ' ' + p.apellido }; 
    }));
    const doctoresDataJsonStr = JSON.stringify(doctores.map(function(d) { 
      return { id: d.id, text: d.nombre + ' ' + d.apellido }; 
    }));
    const serviciosDataJsonStr = JSON.stringify(servicios.map(function(s) { 
      return { id: s.id, text: s.nombre + (s.categoria ? ' (' + s.categoria.nombre + ')' : '') }; 
    }));

    res.render('laboratorios/crear-servicio', {
      title: 'Nuevo Servicio de Laboratorio',
      laboratorios,
      servicios,
      doctores,
      pacientes,
      pacientesDataJsonStr,
      doctoresDataJsonStr,
      serviciosDataJsonStr,
      error: null,
    });
  } catch (error) {
    console.error('Error al cargar formulario de servicio:', error);
    res.render('error', { title: 'Error', message: 'Error al cargar formulario', error });
  }
};

// Guardar servicio de laboratorio
const storeServicio = async (req, res) => {
  try {
    const { laboratorioId, servicioId, pacienteId, doctorId, costo } = req.body;

    // Validaciones
    if (!laboratorioId || !servicioId || !pacienteId || !doctorId || !costo) {
      const laboratorios = await prisma.laboratorio.findMany({
        where: { activo: true },
        orderBy: { nombre: 'asc' },
      });
      const servicios = await prisma.servicio.findMany({
        where: { activo: true },
        include: { categoria: true },
        orderBy: { nombre: 'asc' },
      });
      const doctores = await prisma.doctor.findMany({
        where: { activo: true },
        orderBy: [{ apellido: 'asc' }, { nombre: 'asc' }],
      });
      const pacientes = await prisma.paciente.findMany({
        where: { activo: true },
        orderBy: [{ apellido: 'asc' }, { nombre: 'asc' }],
      });

      // Preparar variables JSON
      const pacientesDataJsonStr = JSON.stringify(pacientes.map(function(p) { 
        return { id: p.id, text: p.nombre + ' ' + p.apellido }; 
      }));
      const doctoresDataJsonStr = JSON.stringify(doctores.map(function(d) { 
        return { id: d.id, text: d.nombre + ' ' + d.apellido }; 
      }));
      const serviciosDataJsonStr = JSON.stringify(servicios.map(function(s) { 
        return { id: s.id, text: s.nombre + (s.categoria ? ' (' + s.categoria.nombre + ')' : '') }; 
      }));

      return res.render('laboratorios/crear-servicio', {
        title: 'Nuevo Servicio de Laboratorio',
        laboratorios,
        servicios,
        doctores,
        pacientes,
        pacientesDataJsonStr,
        doctoresDataJsonStr,
        serviciosDataJsonStr,
        error: 'Todos los campos son requeridos',
      });
    }

    const costoNum = parseFloat(costo);
    if (isNaN(costoNum) || costoNum <= 0) {
      const laboratorios = await prisma.laboratorio.findMany({
        where: { activo: true },
        orderBy: { nombre: 'asc' },
      });
      const servicios = await prisma.servicio.findMany({
        where: { activo: true },
        include: { categoria: true },
        orderBy: { nombre: 'asc' },
      });
      const doctores = await prisma.doctor.findMany({
        where: { activo: true },
        orderBy: [{ apellido: 'asc' }, { nombre: 'asc' }],
      });
      const pacientes = await prisma.paciente.findMany({
        where: { activo: true },
        orderBy: [{ apellido: 'asc' }, { nombre: 'asc' }],
      });

      // Preparar variables JSON
      const pacientesDataJsonStr = JSON.stringify(pacientes.map(function(p) { 
        return { id: p.id, text: p.nombre + ' ' + p.apellido }; 
      }));
      const doctoresDataJsonStr = JSON.stringify(doctores.map(function(d) { 
        return { id: d.id, text: d.nombre + ' ' + d.apellido }; 
      }));
      const serviciosDataJsonStr = JSON.stringify(servicios.map(function(s) { 
        return { id: s.id, text: s.nombre + (s.categoria ? ' (' + s.categoria.nombre + ')' : '') }; 
      }));

      return res.render('laboratorios/crear-servicio', {
        title: 'Nuevo Servicio de Laboratorio',
        laboratorios,
        servicios,
        doctores,
        pacientes,
        pacientesDataJsonStr,
        doctoresDataJsonStr,
        serviciosDataJsonStr,
        error: 'El costo debe ser un número mayor a 0',
      });
    }

    // Crear servicio de laboratorio
    await prisma.servicioLaboratorio.create({
      data: {
        laboratorioId: parseInt(laboratorioId),
        servicioId: parseInt(servicioId),
        pacienteId: parseInt(pacienteId),
        doctorId: parseInt(doctorId),
        costo: costoNum,
        montoPagado: 0,
        saldoPendiente: costoNum,
        estado: 'pendiente',
      },
    });

    res.redirect('/laboratorios/punto-venta');
  } catch (error) {
    console.error('Error al crear servicio de laboratorio:', error);
    const laboratorios = await prisma.laboratorio.findMany({
      where: { activo: true },
      orderBy: { nombre: 'asc' },
    });
    const servicios = await prisma.servicio.findMany({
      where: { activo: true },
      include: { categoria: true },
      orderBy: { nombre: 'asc' },
    });
    const doctores = await prisma.doctor.findMany({
      where: { activo: true },
      orderBy: [{ apellido: 'asc' }, { nombre: 'asc' }],
    });
    const pacientes = await prisma.paciente.findMany({
      where: { activo: true },
      orderBy: [{ apellido: 'asc' }, { nombre: 'asc' }],
    });

    // Preparar variables JSON
    const pacientesDataJsonStr = JSON.stringify(pacientes.map(function(p) { 
      return { id: p.id, text: p.nombre + ' ' + p.apellido }; 
    }));
    const doctoresDataJsonStr = JSON.stringify(doctores.map(function(d) { 
      return { id: d.id, text: d.nombre + ' ' + d.apellido }; 
    }));
    const serviciosDataJsonStr = JSON.stringify(servicios.map(function(s) { 
      return { id: s.id, text: s.nombre + (s.categoria ? ' (' + s.categoria.nombre + ')' : '') }; 
    }));

    res.render('laboratorios/crear-servicio', {
      title: 'Nuevo Servicio de Laboratorio',
      laboratorios,
      servicios,
      doctores,
      pacientes,
      pacientesDataJsonStr,
      doctoresDataJsonStr,
      serviciosDataJsonStr,
      error: 'Error al crear el servicio de laboratorio',
    });
  }
};

// Vista punto de venta
const puntoVenta = async (req, res) => {
  try {
    // Solo obtener laboratorios que tienen deuda pendiente
    const serviciosConDeuda = await prisma.servicioLaboratorio.groupBy({
      by: ['laboratorioId'],
      where: {
        estado: { not: 'cancelado' },
        saldoPendiente: { gt: 0 },
      },
      _sum: {
        saldoPendiente: true,
      },
    });

    const laboratoriosIds = serviciosConDeuda.map(s => s.laboratorioId);

    const laboratorios = await prisma.laboratorio.findMany({
      where: {
        id: { in: laboratoriosIds },
        activo: true,
      },
      orderBy: { nombre: 'asc' },
    });

    res.render('laboratorios/punto-venta', {
      title: 'Pago a Laboratorio',
      laboratorios,
    });
  } catch (error) {
    console.error('Error al cargar punto de venta:', error);
    res.render('error', { title: 'Error', message: 'Error al cargar punto de venta', error });
  }
};

// API: Buscar pacientes con servicios pendientes
const buscarPacientesConDeuda = async (req, res) => {
  try {
    const { q } = req.query;
    
    // Obtener pacientes que tienen servicios con deuda pendiente
    const serviciosConDeuda = await prisma.servicioLaboratorio.findMany({
      where: {
        estado: { not: 'cancelado' },
        saldoPendiente: { gt: 0 },
        paciente: {
          activo: true,
          OR: q ? [
            { nombre: { contains: q } },
            { apellido: { contains: q } },
          ] : undefined,
        },
      },
      include: {
        paciente: {
          select: {
            id: true,
            nombre: true,
            apellido: true,
            telefono: true,
          },
        },
      },
      distinct: ['pacienteId'],
    });

    // Extraer pacientes únicos
    const pacientesUnicos = serviciosConDeuda.map(s => s.paciente);
    const pacientesMap = new Map();
    pacientesUnicos.forEach(p => {
      if (!pacientesMap.has(p.id)) {
        pacientesMap.set(p.id, p);
      }
    });

    const pacientes = Array.from(pacientesMap.values());

    res.json(pacientes.map(p => ({
      id: p.id,
      nombre: p.nombre,
      apellido: p.apellido,
      telefono: p.telefono,
      text: p.nombre + ' ' + p.apellido,
    })));
  } catch (error) {
    console.error('Error al buscar pacientes con deuda:', error);
    res.status(500).json({ error: 'Error en búsqueda' });
  }
};

// API: Buscar servicios por paciente
const buscarPorPaciente = async (req, res) => {
  try {
    const { pacienteId } = req.params;

    const servicios = await prisma.servicioLaboratorio.findMany({
      where: {
        pacienteId: parseInt(pacienteId),
        estado: { not: 'cancelado' },
        saldoPendiente: { gt: 0 }, // Solo servicios con deuda pendiente
      },
      include: {
        laboratorio: true,
        servicio: true,
        paciente: true,
        doctor: true,
        pagos: {
          orderBy: { createdAt: 'desc' },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    res.json({ success: true, servicios });
  } catch (error) {
    console.error('Error al buscar servicios por paciente:', error);
    res.status(500).json({ success: false, error: 'Error al buscar servicios' });
  }
};

// API: Buscar servicios por laboratorio
const buscarPorLaboratorio = async (req, res) => {
  try {
    const { laboratorioId } = req.params;

    const servicios = await prisma.servicioLaboratorio.findMany({
      where: {
        laboratorioId: parseInt(laboratorioId),
        estado: { not: 'cancelado' },
        saldoPendiente: { gt: 0 }, // Solo servicios con deuda pendiente
      },
      include: {
        laboratorio: true,
        servicio: true,
        paciente: true,
        doctor: true,
        pagos: {
          orderBy: { createdAt: 'desc' },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    // Calcular totales
    const totalDeuda = servicios.reduce((sum, s) => sum + parseFloat(s.saldoPendiente), 0);
    const totalPagado = servicios.reduce((sum, s) => sum + parseFloat(s.montoPagado), 0);

    res.json({
      success: true,
      servicios,
      totales: {
        deuda: totalDeuda,
        pagado: totalPagado,
      },
    });
  } catch (error) {
    console.error('Error al buscar servicios por laboratorio:', error);
    res.status(500).json({ success: false, error: 'Error al buscar servicios' });
  }
};

// Función auxiliar: Descontar del saldo del método de pago en cortes de caja
// Obtener saldo disponible en efectivo
const obtenerSaldoDisponibleEfectivo = async () => {
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
    
    if (!saldoInicialDelDia && ultimoCorte) {
      desdeFecha = ultimoCorte.createdAt;
      saldoInicialEfectivo = parseFloat(ultimoCorte.saldoFinalEfectivo || 0);
    } else if (saldoInicialDelDia) {
      desdeFecha = saldoInicialDelDia.createdAt;
      saldoInicialEfectivo = parseFloat(saldoInicialDelDia.saldoInicialEfectivo || 0);
      
      if (ultimoCorte && ultimoCorte.createdAt > saldoInicialDelDia.createdAt) {
        desdeFecha = ultimoCorte.createdAt;
        saldoInicialEfectivo = parseFloat(ultimoCorte.saldoFinalEfectivo || 0);
      }
    } else {
      desdeFecha = hoy;
      saldoInicialEfectivo = 0;
    }
    
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
    
    // El saldo disponible es: saldo inicial + ventas - gastos
    const saldoDisponibleEfectivo = saldoInicialEfectivo + ventasEfectivo - gastosEfectivo;
    
    return saldoDisponibleEfectivo;
  } catch (error) {
    console.error('Error al obtener saldo disponible en efectivo:', error);
    return 0;
  }
};

const descontarDelCorte = async (monto, metodoPago, banco) => {
  try {
    const montoNum = parseFloat(monto);
    if (isNaN(montoNum) || montoNum <= 0) return;

    // Solo procesar si es tarjeta o transferencia
    if (metodoPago !== 'tarjeta' && metodoPago !== 'transferencia') return;
    if (!banco) return;

    const hoy = moment().tz(config.timezone).startOf('day').toDate();
    const mañana = moment().tz(config.timezone).endOf('day').toDate();

    // Buscar el último corte de caja del día actual
    const ultimoCorte = await prisma.corteCaja.findFirst({
      where: {
        fecha: { gte: hoy, lte: mañana },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });

    if (!ultimoCorte) return;

    const updateData = {};

    if (metodoPago === 'tarjeta') {
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

    // Actualizar el último corte con los nuevos saldos
    if (Object.keys(updateData).length > 0) {
      await prisma.corteCaja.update({
        where: { id: ultimoCorte.id },
        data: updateData,
      });
    }
  } catch (error) {
    console.error('Error al descontar del corte:', error);
  }
};

// API: Registrar pago/abono
const registrarPago = async (req, res) => {
  try {
    const { servicioLaboratorioId, monto, metodoPago, banco, observaciones } = req.body;

    // Validaciones
    if (!servicioLaboratorioId || !monto || !metodoPago) {
      return res.status(400).json({
        success: false,
        error: 'Faltan campos requeridos',
      });
    }

    const montoNum = parseFloat(monto);
    if (isNaN(montoNum) || montoNum <= 0) {
      return res.status(400).json({
        success: false,
        error: 'El monto debe ser un número mayor a 0',
      });
    }

    // Validar banco si es tarjeta o transferencia
    if ((metodoPago === 'tarjeta' || metodoPago === 'transferencia') && !banco) {
      return res.status(400).json({
        success: false,
        error: 'Debe seleccionar un banco para tarjeta o transferencia',
      });
    }

    // Obtener el servicio de laboratorio
    const servicioLaboratorio = await prisma.servicioLaboratorio.findUnique({
      where: { id: parseInt(servicioLaboratorioId) },
      include: {
        paciente: true,
        laboratorio: true,
      },
    });

    if (!servicioLaboratorio) {
      return res.status(404).json({
        success: false,
        error: 'Servicio de laboratorio no encontrado',
      });
    }

    if (servicioLaboratorio.estado === 'cancelado') {
      return res.status(400).json({
        success: false,
        error: 'No se pueden registrar pagos en servicios cancelados',
      });
    }

    // Validar que el monto no exceda el saldo pendiente
    const saldoPendiente = parseFloat(servicioLaboratorio.saldoPendiente);
    if (montoNum > saldoPendiente) {
      return res.status(400).json({
        success: false,
        error: `El monto excede el saldo pendiente ($${saldoPendiente.toFixed(2)})`,
      });
    }

    // Validar saldo disponible en efectivo si el método de pago es efectivo
    if (metodoPago === 'efectivo') {
      const saldoDisponibleEfectivo = await obtenerSaldoDisponibleEfectivo();
      if (montoNum > saldoDisponibleEfectivo) {
        return res.status(400).json({
          success: false,
          error: `El monto excede el saldo disponible en efectivo ($${saldoDisponibleEfectivo.toFixed(2)})`,
        });
      }
    }

    // Calcular nuevos valores
    const nuevoMontoPagado = parseFloat(servicioLaboratorio.montoPagado) + montoNum;
    const nuevoSaldoPendiente = saldoPendiente - montoNum;
    const nuevoEstado = nuevoSaldoPendiente <= 0 ? 'pagado' : 'pendiente';

    // Crear el pago
    await prisma.pagoLaboratorio.create({
      data: {
        servicioLaboratorioId: parseInt(servicioLaboratorioId),
        monto: montoNum,
        metodoPago,
        banco: banco || null,
        observaciones: observaciones || null,
        usuarioId: req.session.user?.id || null,
      },
    });

    // Actualizar el servicio de laboratorio
    await prisma.servicioLaboratorio.update({
      where: { id: parseInt(servicioLaboratorioId) },
      data: {
        montoPagado: nuevoMontoPagado,
        saldoPendiente: nuevoSaldoPendiente,
        estado: nuevoEstado,
      },
    });

    // Crear registro en gastos para que aparezca en el histórico
    const motivo = `Pago a laboratorio - ${servicioLaboratorio.laboratorio.nombre} - Paciente: ${servicioLaboratorio.paciente.nombre} ${servicioLaboratorio.paciente.apellido}`;
    await prisma.gasto.create({
      data: {
        motivo,
        monto: montoNum,
        metodoPago: metodoPago || 'efectivo',
        banco: (metodoPago === 'tarjeta' || metodoPago === 'transferencia') ? banco : null,
        tipo: 'laboratorio',
        laboratorioId: servicioLaboratorio.laboratorioId,
        pacienteId: servicioLaboratorio.pacienteId,
        observaciones: observaciones || null,
        usuarioId: req.session.user?.id || null,
      },
    });

    // Descontar del corte de caja si es tarjeta o transferencia
    if (metodoPago === 'tarjeta' || metodoPago === 'transferencia') {
      await descontarDelCorte(montoNum, metodoPago, banco);
    }

    res.json({
      success: true,
      message: 'Pago registrado correctamente',
    });
  } catch (error) {
    console.error('Error al registrar pago:', error);
    res.status(500).json({
      success: false,
      error: 'Error al registrar el pago',
    });
  }
};

module.exports = {
  index,
  create,
  store,
  createLaboratorio,
  storeLaboratorio,
  createServicio,
  storeServicio,
  puntoVenta,
  buscarPacientesConDeuda,
  buscarPorPaciente,
  buscarPorLaboratorio,
  registrarPago,
  descontarDelCorte,
  show,
  edit,
  update,
  destroy,
};



