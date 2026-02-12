const express = require('express');
const router = express.Router();

const authRoutes = require('./authRoutes');
const dashboardRoutes = require('./dashboardRoutes');
const doctoresRoutes = require('./doctoresRoutes');
const pacientesRoutes = require('./pacientesRoutes');
const posRoutes = require('./posRoutes');
const cortesRoutes = require('./cortesRoutes');
const gastosRoutes = require('./gastosRoutes');
const configuracionRoutes = require('./configuracionRoutes');
const vaultRoutes = require('./vaultRoutes');
const aplazosRoutes = require('./aplazosRoutes');
const laboratoriosRoutes = require('./laboratoriosRoutes');
const retirosRoutes = require('./retirosRoutes');
const usoMaterialesRoutes = require('./usoMaterialesRoutes');

// Ruta principal - redirige al punto de venta o login
router.get('/', (req, res) => {
  if (req.session && req.session.user) {
    res.redirect('/pos');
  } else {
    res.redirect('/login');
  }
});

// Montar rutas
router.use('/', authRoutes);
router.use('/dashboard', dashboardRoutes);
router.use('/doctores', doctoresRoutes);
router.use('/pacientes', pacientesRoutes);
router.use('/laboratorios', laboratoriosRoutes);
router.use('/pos', posRoutes);
router.use('/cortes', cortesRoutes);
router.use('/gastos', gastosRoutes);
router.use('/configuracion', configuracionRoutes);
router.use('/vault', vaultRoutes);
router.use('/aplazos', aplazosRoutes);
router.use('/retiros', retirosRoutes);
router.use('/uso-materiales', usoMaterialesRoutes);

module.exports = router;

