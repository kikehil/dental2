const prisma = require('../config/database');
const { formatCurrency } = require('../utils/helpers');

// Mostrar historial de uso de materiales
const index = async (req, res) => {
  try {
    const { fechaInicio, fechaFin, pacienteId, doctorId, materialId } = req.query;

    const where = {};
    
    if (fechaInicio && fechaFin) {
      where.createdAt = {
        gte: new Date(fechaInicio),
        lte: new Date(fechaFin + 'T23:59:59'),
      };
    }
    
    if (pacienteId) where.pacienteId = parseInt(pacienteId);
    if (doctorId) where.doctorId = parseInt(doctorId);
    if (materialId) where.materialId = parseInt(materialId);

    const usos = await prisma.usoMaterial.findMany({
      where,
      include: {
        material: true,
        paciente: true,
        doctor: true,
        usuario: true,
      },
      orderBy: { createdAt: 'desc' },
    });

    // Obtener materiales para el select
    const materiales = await prisma.material.findMany({
      where: { activo: true },
      orderBy: { nombre: 'asc' },
    });

    // Obtener pacientes para el select
    const pacientes = await prisma.paciente.findMany({
      where: { activo: true },
      orderBy: { nombre: 'asc' },
    });

    // Obtener doctores para el select
    const doctores = await prisma.doctor.findMany({
      where: { activo: true },
      orderBy: { nombre: 'asc' },
    });

    res.render('uso-materiales/index', {
      title: 'Uso de Materiales',
      usos,
      materiales,
      pacientes,
      doctores,
      formatCurrency,
      req, // Pasar req para acceder a query params en la vista
    });
  } catch (error) {
    console.error('Error al cargar uso de materiales:', error);
    res.render('error', {
      title: 'Error',
      message: 'Error al cargar uso de materiales',
      error,
    });
  }
};

// Registrar uso de material(es)
const registrarUso = async (req, res) => {
  try {
    const { materiales, pacienteId, doctorId, tratamientoId, observaciones } = req.body;

    // Validar datos requeridos
    if (!pacienteId || !doctorId) {
      return res.status(400).json({ error: 'Paciente y Doctor son requeridos' });
    }

    // Si viene un array de materiales (nuevo formato)
    if (materiales && Array.isArray(materiales) && materiales.length > 0) {
      const usuarioId = req.session && req.session.user ? req.session.user.id : null;
      const usosCreados = [];

      // Verificar stock de todos los materiales antes de procesar
      for (const item of materiales) {
        const material = await prisma.material.findUnique({
          where: { id: parseInt(item.materialId) },
        });

        if (!material) {
          return res.status(404).json({ 
            error: `Material con ID ${item.materialId} no encontrado` 
          });
        }

        if (material.stock < parseInt(item.cantidad)) {
          return res.status(400).json({ 
            error: `Stock insuficiente para ${material.nombre}. Stock disponible: ${material.stock}` 
          });
        }
      }

      // Si todo está bien, crear los registros y descontar stock
      for (const item of materiales) {
        // Crear registro de uso
        const uso = await prisma.usoMaterial.create({
          data: {
            materialId: parseInt(item.materialId),
            pacienteId: parseInt(pacienteId),
            doctorId: parseInt(doctorId),
            tratamientoId: tratamientoId ? parseInt(tratamientoId) : null,
            cantidad: parseInt(item.cantidad),
            observaciones: observaciones || null,
            usuarioId: usuarioId,
          },
        });

        // Descontar stock del material
        await prisma.material.update({
          where: { id: parseInt(item.materialId) },
          data: {
            stock: {
              decrement: parseInt(item.cantidad),
            },
          },
        });

        usosCreados.push(uso);
      }

      return res.json({ 
        success: true, 
        usos: usosCreados,
        message: `Se registró el uso de ${usosCreados.length} material(es)` 
      });
    }

    // Formato antiguo (un solo material) - mantener compatibilidad
    const { materialId, cantidad } = req.body;
    if (!materialId || !cantidad) {
      return res.status(400).json({ error: 'Faltan datos requeridos' });
    }

    // Verificar stock disponible
    const material = await prisma.material.findUnique({
      where: { id: parseInt(materialId) },
    });

    if (!material) {
      return res.status(404).json({ error: 'Material no encontrado' });
    }

    if (material.stock < parseInt(cantidad)) {
      return res.status(400).json({ 
        error: `Stock insuficiente. Stock disponible: ${material.stock}` 
      });
    }

    // Crear registro de uso
    const uso = await prisma.usoMaterial.create({
      data: {
        materialId: parseInt(materialId),
        pacienteId: parseInt(pacienteId),
        doctorId: parseInt(doctorId),
        tratamientoId: tratamientoId ? parseInt(tratamientoId) : null,
        cantidad: parseInt(cantidad),
        observaciones: observaciones || null,
        usuarioId: req.session && req.session.user ? req.session.user.id : null,
      },
    });

    // Descontar stock del material
    await prisma.material.update({
      where: { id: parseInt(materialId) },
      data: {
        stock: {
          decrement: parseInt(cantidad),
        },
      },
    });

    res.json({ success: true, uso });
  } catch (error) {
    console.error('Error al registrar uso de material:', error);
    res.status(500).json({ error: 'Error al registrar uso de material' });
  }
};

module.exports = {
  index,
  registrarUso,
};

