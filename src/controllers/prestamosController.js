const prisma = require('../config/database');
const moment = require('moment-timezone');
const config = require('../config/config');
const { formatCurrency } = require('../utils/helpers');

// Lista de préstamos agrupados por doctor
const index = async (req, res) => {
  try {
    // Obtener todos los préstamos con información del doctor y concepto
    const prestamos = await prisma.prestamo.findMany({
      include: {
        doctor: true,
        concepto: true,
        usuario: {
          select: {
            nombre: true,
            email: true,
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });

    // Agrupar por doctor y calcular deudas
    const deudasPorDoctor = {};
    
    prestamos.forEach(prestamo => {
      const doctorId = prestamo.doctorId;
      const doctorNombre = `${prestamo.doctor.nombre} ${prestamo.doctor.apellido}`;
      
      if (!deudasPorDoctor[doctorId]) {
        deudasPorDoctor[doctorId] = {
          doctorId: doctorId,
          doctorNombre: doctorNombre,
          doctor: prestamo.doctor,
          prestamos: [],
          totalDeuda: 0,
          totalPendiente: 0,
          totalPagado: 0,
        };
      }
      
      deudasPorDoctor[doctorId].prestamos.push(prestamo);
      
      const monto = parseFloat(prestamo.monto);
      deudasPorDoctor[doctorId].totalDeuda += monto;
      
      if (prestamo.estatus === 'pendiente') {
        deudasPorDoctor[doctorId].totalPendiente += monto;
      } else if (prestamo.estatus === 'pagado') {
        deudasPorDoctor[doctorId].totalPagado += monto;
      }
    });

    // Convertir a array y filtrar solo los que tienen deuda activa (pendiente > 0)
    const deudasActivas = Object.values(deudasPorDoctor)
      .filter(d => d.totalPendiente > 0)
      .sort((a, b) => b.totalPendiente - a.totalPendiente);

    // Obtener todos los doctores para el select
    const doctores = await prisma.doctor.findMany({
      where: { activo: true },
      orderBy: [{ apellido: 'asc' }, { nombre: 'asc' }],
    });

    // Obtener conceptos activos
    const conceptos = await prisma.conceptoPrestamo.findMany({
      where: { activo: true },
      orderBy: { nombre: 'asc' },
    });

    res.render('gastos/prestamos', {
      title: 'Préstamos al Personal',
      deudasActivas,
      doctores,
      conceptos,
      success: req.query.success,
      error: req.query.error,
      tab: 'prestamos',
      formatCurrency,
      moment,
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

// Obtener detalle de préstamos de un doctor (para modal)
const detalle = async (req, res) => {
  try {
    const { doctorId } = req.params;

    const doctor = await prisma.doctor.findUnique({
      where: { id: parseInt(doctorId) },
    });

    if (!doctor) {
      return res.status(404).json({ error: 'Doctor no encontrado' });
    }

    const prestamos = await prisma.prestamo.findMany({
      where: { doctorId: parseInt(doctorId) },
      include: {
        concepto: true,
        usuario: {
          select: {
            nombre: true,
            email: true,
          },
        },
      },
      orderBy: {
        createdAt: 'desc',
      },
    });

    // Calcular totales
    const totales = {
      total: prestamos.reduce((sum, p) => sum + parseFloat(p.monto), 0),
      pendiente: prestamos
        .filter(p => p.estatus === 'pendiente')
        .reduce((sum, p) => sum + parseFloat(p.monto), 0),
      pagado: prestamos
        .filter(p => p.estatus === 'pagado')
        .reduce((sum, p) => sum + parseFloat(p.monto), 0),
    };

    res.json({
      success: true,
      doctor: {
        id: doctor.id,
        nombre: `${doctor.nombre} ${doctor.apellido}`,
      },
      prestamos,
      totales,
    });
  } catch (error) {
    console.error('Error al obtener detalle de préstamos:', error);
    res.status(500).json({ error: 'Error al obtener detalle de préstamos' });
  }
};

// Crear nuevo préstamo
const store = async (req, res) => {
  try {
    const { doctorId, conceptoId, monto, notas } = req.body;

    // Validaciones
    if (!doctorId || !conceptoId || !monto) {
      return res.status(400).json({ error: 'Doctor, concepto y monto son requeridos' });
    }

    const montoNum = parseFloat(monto);
    if (isNaN(montoNum) || montoNum <= 0) {
      return res.status(400).json({ error: 'Monto inválido' });
    }

    // Verificar que el doctor existe
    const doctor = await prisma.doctor.findUnique({
      where: { id: parseInt(doctorId) },
    });

    if (!doctor) {
      return res.status(400).json({ error: 'Doctor no encontrado' });
    }

    // Verificar que el concepto existe
    const concepto = await prisma.conceptoPrestamo.findUnique({
      where: { id: parseInt(conceptoId) },
    });

    if (!concepto) {
      return res.status(400).json({ error: 'Concepto no encontrado' });
    }

    // Crear el préstamo
    const prestamo = await prisma.prestamo.create({
      data: {
        doctorId: parseInt(doctorId),
        conceptoId: parseInt(conceptoId),
        monto: montoNum,
        estatus: 'pendiente',
        notas: notas || null,
        usuarioId: req.session.user?.id || null,
      },
      include: {
        doctor: true,
        concepto: true,
      },
    });

    res.json({ success: true, prestamo });
  } catch (error) {
    console.error('Error al crear préstamo:', error);
    res.status(500).json({ error: 'Error al crear préstamo' });
  }
};

// Actualizar estatus de un préstamo
const updateEstatus = async (req, res) => {
  try {
    const { prestamoId } = req.params;
    const { estatus } = req.body;

    if (!estatus || !['pendiente', 'pagado'].includes(estatus)) {
      return res.status(400).json({ error: 'Estatus inválido' });
    }

    const prestamo = await prisma.prestamo.update({
      where: { id: parseInt(prestamoId) },
      data: { estatus },
      include: {
        doctor: true,
        concepto: true,
      },
    });

    res.json({ success: true, prestamo });
  } catch (error) {
    console.error('Error al actualizar estatus:', error);
    res.status(500).json({ error: 'Error al actualizar estatus' });
  }
};

// Gestionar conceptos - Lista
const indexConceptos = async (req, res) => {
  try {
    const conceptos = await prisma.conceptoPrestamo.findMany({
      orderBy: { nombre: 'asc' },
    });

    res.render('gastos/conceptos-prestamos', {
      title: 'Gestionar Conceptos de Préstamos',
      conceptos,
      success: req.query.success,
      error: req.query.error,
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

// Gestionar conceptos - Crear
const storeConcepto = async (req, res) => {
  try {
    const { nombre, descripcion } = req.body;

    if (!nombre) {
      return res.status(400).json({ error: 'El nombre es requerido' });
    }

    const concepto = await prisma.conceptoPrestamo.create({
      data: {
        nombre,
        descripcion: descripcion || null,
        activo: true,
      },
    });

    res.json({ success: true, concepto });
  } catch (error) {
    console.error('Error al crear concepto:', error);
    res.status(500).json({ error: 'Error al crear concepto' });
  }
};

// Gestionar conceptos - Actualizar
const updateConcepto = async (req, res) => {
  try {
    const { conceptoId } = req.params;
    const { nombre, descripcion, activo } = req.body;

    if (!nombre) {
      return res.status(400).json({ error: 'El nombre es requerido' });
    }

    const concepto = await prisma.conceptoPrestamo.update({
      where: { id: parseInt(conceptoId) },
      data: {
        nombre,
        descripcion: descripcion || null,
        activo: activo === 'true' || activo === true,
      },
    });

    res.json({ success: true, concepto });
  } catch (error) {
    console.error('Error al actualizar concepto:', error);
    res.status(500).json({ error: 'Error al actualizar concepto' });
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
};

