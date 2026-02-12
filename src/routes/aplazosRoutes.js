const express = require('express');
const router = express.Router();
const aplazosController = require('../controllers/aplazosController');
const { isAuthenticated, hasModuleAccess } = require('../middleware/auth');

// Página principal de tratamientos a plazos
router.get('/', isAuthenticated, hasModuleAccess('/aplazos'), aplazosController.index);

// Crear tratamiento a plazos
router.post('/tratamiento', isAuthenticated, aplazosController.crearTratamiento);

// Buscar pacientes (para POS)
router.get('/buscar-pacientes', isAuthenticated, aplazosController.buscarPacientes);

// Obtener tratamientos de un paciente
router.get('/paciente/:pacienteId/tratamientos', isAuthenticated, aplazosController.obtenerTratamientosPaciente);

// Registrar abono
router.post('/abono', isAuthenticated, aplazosController.registrarAbono);

// Obtener historial de abonos
router.get('/tratamiento/:tratamientoPlazoId/abonos', isAuthenticated, aplazosController.obtenerHistorialAbonos);

module.exports = router;



