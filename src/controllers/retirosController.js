const prisma = require('../config/database');
const moment = require('moment-timezone');
const config = require('../config/config');
const { formatCurrency } = require('../utils/helpers');

// Mostrar historial de retiros
const index = async (req, res) => {
  try {
    const { fechaInicio, fechaFin } = req.query;
    
    let fechaInicioDate, fechaFinDate;
    
    if (fechaInicio && fechaFin) {
      fechaInicioDate = moment(fechaInicio, 'YYYY-MM-DD').tz(config.timezone).startOf('day').toDate();
      fechaFinDate = moment(fechaFin, 'YYYY-MM-DD').tz(config.timezone).endOf('day').toDate();
    } else {
      // Por defecto, últimos 30 días
      fechaInicioDate = moment().tz(config.timezone).subtract(30, 'days').startOf('day').toDate();
      fechaFinDate = moment().tz(config.timezone).endOf('day').toDate();
    }

    // Obtener retiros (gastos con motivo "Retiro de efectivo")
    const retiros = await prisma.gasto.findMany({
      where: {
        motivo: 'Retiro de efectivo',
        createdAt: { gte: fechaInicioDate, lte: fechaFinDate },
        metodoPago: 'efectivo',
      },
      include: {
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
    const totalRetiros = retiros.reduce((sum, r) => sum + parseFloat(r.monto), 0);
    
    // Calcular totales por día
    const retirosPorDia = {};
    retiros.forEach(retiro => {
      const fecha = moment(retiro.createdAt).tz(config.timezone).format('YYYY-MM-DD');
      if (!retirosPorDia[fecha]) {
        retirosPorDia[fecha] = { cantidad: 0, total: 0 };
      }
      retirosPorDia[fecha].cantidad++;
      retirosPorDia[fecha].total += parseFloat(retiro.monto);
    });

    res.render('retiros/index', {
      title: 'Historial de Retiros',
      retiros,
      totalRetiros,
      retirosPorDia,
      fechaInicio: fechaInicio || moment(fechaInicioDate).format('YYYY-MM-DD'),
      fechaFin: fechaFin || moment(fechaFinDate).format('YYYY-MM-DD'),
      formatCurrency,
      moment,
      config,
      success: req.query.success,
      error: req.query.error,
    });
  } catch (error) {
    console.error('Error al cargar historial de retiros:', error);
    res.render('error', {
      title: 'Error',
      message: 'Error al cargar historial de retiros',
      error,
    });
  }
};

module.exports = {
  index,
};


