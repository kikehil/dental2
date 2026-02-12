const prisma = require('../config/database');
const moment = require('moment-timezone');
const config = require('../config/config');
const { formatCurrency } = require('../utils/helpers');

// Mostrar página de tratamientos a plazos
const index = async (req, res) => {
  try {
    const pacientes = await prisma.paciente.findMany({
      where: { activo: true },
      orderBy: [{ apellido: 'asc' }, { nombre: 'asc' }],
    });

    const doctores = await prisma.doctor.findMany({
      where: { activo: true },
      orderBy: [{ apellido: 'asc' }, { nombre: 'asc' }],
    });

    const servicios = await prisma.servicio.findMany({
      where: { activo: true },
      include: { categoria: true },
      orderBy: { nombre: 'asc' },
    });

    // Obtener todos los tratamientos a plazos con su información relacionada
    const tratamientos = await prisma.tratamientoPlazo.findMany({
      include: {
        paciente: true,
        doctor: true,
        servicio: true,
      },
      orderBy: { createdAt: 'desc' },
    });

    res.render('aplazos/index', {
      title: 'Tratamientos a Plazos',
      pacientes,
      doctores,
      servicios,
      tratamientos,
      formatCurrency,
    });
  } catch (error) {
    console.error('Error al cargar tratamientos a plazos:', error);
    res.status(500).send('Error al cargar la página');
  }
};

// Crear nuevo tratamiento a plazos
const crearTratamiento = async (req, res) => {
  try {
    const { pacienteId, doctorId, servicioId, notas } = req.body;

    if (!pacienteId || !doctorId || !servicioId) {
      return res.status(400).json({ error: 'Faltan datos requeridos' });
    }

    // Obtener el servicio para obtener el precio
    const servicio = await prisma.servicio.findUnique({
      where: { id: parseInt(servicioId) },
    });

    if (!servicio) {
      return res.status(404).json({ error: 'Servicio no encontrado' });
    }

    const montoTotal = parseFloat(servicio.precio);
    const montoAdeudado = montoTotal;

    // Crear el tratamiento a plazos
    const tratamiento = await prisma.tratamientoPlazo.create({
      data: {
        pacienteId: parseInt(pacienteId),
        doctorId: parseInt(doctorId),
        servicioId: parseInt(servicioId),
        montoTotal,
        montoPagado: 0,
        montoAdeudado,
        estado: 'pendiente',
        notas: notas || null,
      },
      include: {
        paciente: true,
        doctor: true,
        servicio: true,
      },
    });

    res.json({ success: true, tratamiento });
  } catch (error) {
    console.error('Error al crear tratamiento a plazos:', error);
    res.status(500).json({ error: 'Error al crear el tratamiento' });
  }
};

// Buscar pacientes para abonos (desde POS)
const buscarPacientes = async (req, res) => {
  try {
    const { q } = req.query;
    
    if (!q || q.trim() === '') {
      return res.json([]);
    }

    const pacientes = await prisma.paciente.findMany({
      where: {
        activo: true,
        OR: [
          { nombre: { contains: q } },
          { apellido: { contains: q } },
        ],
      },
      orderBy: [{ apellido: 'asc' }, { nombre: 'asc' }],
      take: 20,
      orderBy: [{ apellido: 'asc' }, { nombre: 'asc' }],
    });

    res.json(pacientes);
  } catch (error) {
    console.error('Error al buscar pacientes:', error);
    res.status(500).json({ error: 'Error al buscar pacientes' });
  }
};

// Obtener tratamientos pendientes de un paciente
const obtenerTratamientosPaciente = async (req, res) => {
  try {
    const { pacienteId } = req.params;

    const tratamientos = await prisma.tratamientoPlazo.findMany({
      where: {
        pacienteId: parseInt(pacienteId),
        estado: 'pendiente',
      },
      include: {
        doctor: true,
        servicio: true,
        abonos: {
          orderBy: { createdAt: 'desc' },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    res.json(tratamientos);
  } catch (error) {
    console.error('Error al obtener tratamientos:', error);
    res.status(500).json({ error: 'Error al obtener tratamientos' });
  }
};

// Registrar abono
const registrarAbono = async (req, res) => {
  try {
    const { tratamientoPlazoId, monto, notas } = req.body;

    if (!tratamientoPlazoId || !monto) {
      return res.status(400).json({ error: 'Faltan datos requeridos' });
    }

    const montoAbono = parseFloat(monto);

    if (montoAbono <= 0) {
      return res.status(400).json({ error: 'El monto debe ser mayor a cero' });
    }

    // Obtener el tratamiento
    const tratamiento = await prisma.tratamientoPlazo.findUnique({
      where: { id: parseInt(tratamientoPlazoId) },
    });

    if (!tratamiento) {
      return res.status(404).json({ error: 'Tratamiento no encontrado' });
    }

    if (tratamiento.estado !== 'pendiente') {
      return res.status(400).json({ error: 'El tratamiento no está pendiente' });
    }

    const saldoAnterior = parseFloat(tratamiento.montoAdeudado);

    if (montoAbono > saldoAnterior) {
      return res.status(400).json({ error: 'El abono no puede ser mayor al adeudo' });
    }

    const nuevoSaldo = saldoAnterior - montoAbono;
    const nuevoMontoPagado = parseFloat(tratamiento.montoPagado) + montoAbono;

    // Actualizar el tratamiento
    const tratamientoActualizado = await prisma.tratamientoPlazo.update({
      where: { id: tratamiento.id },
      data: {
        montoPagado: nuevoMontoPagado,
        montoAdeudado: nuevoSaldo,
        estado: nuevoSaldo <= 0 ? 'pagado' : 'pendiente',
      },
    });

    // Crear el abono (sin ventaId por ahora, se actualizará cuando se procese la venta)
    const abono = await prisma.abonoTratamiento.create({
      data: {
        tratamientoPlazoId: tratamiento.id,
        monto: montoAbono,
        saldoAnterior,
        saldoNuevo: nuevoSaldo,
        notas: notas || null,
        usuarioId: req.session.user?.id || null,
      },
      include: {
        tratamientoPlazo: {
          include: {
            paciente: true,
            doctor: true,
            servicio: true,
          },
        },
      },
    });

    res.json({ success: true, abono, tratamiento: tratamientoActualizado });
  } catch (error) {
    console.error('Error al registrar abono:', error);
    res.status(500).json({ error: 'Error al registrar el abono' });
  }
};

// Obtener historial de abonos de un tratamiento
const obtenerHistorialAbonos = async (req, res) => {
  try {
    const { tratamientoPlazoId } = req.params;

    const abonos = await prisma.abonoTratamiento.findMany({
      where: {
        tratamientoPlazoId: parseInt(tratamientoPlazoId),
      },
      include: {
        usuario: true,
        venta: true,
      },
      orderBy: { createdAt: 'desc' },
    });

    res.json(abonos);
  } catch (error) {
    console.error('Error al obtener historial de abonos:', error);
    res.status(500).json({ error: 'Error al obtener historial' });
  }
};

// Listar tratamientos pendientes (para POS)
const pendientes = async (req, res) => {
  try {
    const pendientes = await prisma.tratamientoPlazo.findMany({
      where: {
        AND: [
          {
            estado: {
              in: ['pendiente', 'Pendiente', 'PENDIENTE'],
            },
          },
          {
            montoAdeudado: {
              gt: 0,
            },
          },
        ],
      },
      include: {
        paciente: true,
        doctor: true,
        servicio: true,
      },
      orderBy: { createdAt: 'desc' },
    });

    res.json(pendientes);
  } catch (error) {
    console.error('Error al obtener pendientes:', error);
    res.status(500).json({ error: 'Error al obtener pendientes' });
  }
};

module.exports = {
  index,
  crearTratamiento,
  buscarPacientes,
  obtenerTratamientosPaciente,
  registrarAbono,
  obtenerHistorialAbonos,
  pendientes,
};

