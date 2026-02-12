const express = require('express');
const router = express.Router();
const gastosController = require('../controllers/gastosController');
const prestamosController = require('../controllers/prestamosController');
const { isAuthenticated, hasModuleAccess } = require('../middleware/auth');

// Rutas de gastos
router.get('/', isAuthenticated, hasModuleAccess('/gastos'), gastosController.index);
router.get('/crear', isAuthenticated, gastosController.create);
router.post('/', isAuthenticated, gastosController.store);
router.get('/reporte', isAuthenticated, gastosController.reporte);

// Rutas de pagos a laboratorios
router.get('/laboratorio', isAuthenticated, hasModuleAccess('/gastos'), gastosController.indexLaboratorio);
router.get('/laboratorio/crear', isAuthenticated, gastosController.createLaboratorio);
router.post('/laboratorio', isAuthenticated, gastosController.storeLaboratorio);

// Rutas de préstamos al personal
router.get('/prestamos', isAuthenticated, hasModuleAccess('/gastos'), prestamosController.index);
router.get('/prestamos/detalle/:doctorId', isAuthenticated, prestamosController.detalle);
router.get('/prestamos/saldos', isAuthenticated, prestamosController.obtenerSaldos);
router.post('/prestamos', isAuthenticated, prestamosController.store);
router.put('/prestamos/:prestamoId/estatus', isAuthenticated, prestamosController.updateEstatus);

// Rutas de gestión de conceptos de préstamos
router.get('/prestamos/conceptos', isAuthenticated, hasModuleAccess('/gastos'), prestamosController.indexConceptos);
router.post('/prestamos/conceptos', isAuthenticated, prestamosController.storeConcepto);
router.put('/prestamos/conceptos/:conceptoId', isAuthenticated, prestamosController.updateConcepto);

module.exports = router;















