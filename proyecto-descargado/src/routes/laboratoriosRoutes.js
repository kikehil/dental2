const express = require('express');
const router = express.Router();
const laboratoriosController = require('../controllers/laboratoriosController');
const { isAuthenticated, hasModuleAccess } = require('../middleware/auth');

// Vistas principales
router.get('/', isAuthenticated, hasModuleAccess('/laboratorios'), laboratoriosController.index);
router.get('/crear-laboratorio', isAuthenticated, laboratoriosController.createLaboratorio);
router.post('/crear-laboratorio', isAuthenticated, laboratoriosController.storeLaboratorio);
router.get('/crear-servicio', isAuthenticated, laboratoriosController.createServicio);
router.post('/crear-servicio', isAuthenticated, laboratoriosController.storeServicio);
router.get('/punto-venta', isAuthenticated, hasModuleAccess('/laboratorios'), laboratoriosController.puntoVenta);

// APIs
router.get('/api/buscar-pacientes-deuda', isAuthenticated, laboratoriosController.buscarPacientesConDeuda);
router.get('/api/buscar-paciente/:pacienteId', isAuthenticated, laboratoriosController.buscarPorPaciente);
router.get('/api/buscar-laboratorio/:laboratorioId', isAuthenticated, laboratoriosController.buscarPorLaboratorio);
router.post('/api/registrar-pago', isAuthenticated, laboratoriosController.registrarPago);

// Rutas de edición (mantener compatibilidad)
router.get('/crear', isAuthenticated, laboratoriosController.create);
router.post('/crear', isAuthenticated, laboratoriosController.store);
router.get('/:id', isAuthenticated, laboratoriosController.show);
router.get('/:id/editar', isAuthenticated, laboratoriosController.edit);
router.post('/:id/editar', isAuthenticated, laboratoriosController.update);
router.post('/:id/eliminar', isAuthenticated, laboratoriosController.destroy);

module.exports = router;

