const express = require('express');
const router = express.Router();
const usoMaterialesController = require('../controllers/usoMaterialesController');
const { isAuthenticated, hasModuleAccess } = require('../middleware/auth');

// Página principal de uso de materiales
router.get('/', isAuthenticated, hasModuleAccess('/uso-materiales'), usoMaterialesController.index);

// Registrar uso de material
router.post('/registrar', isAuthenticated, usoMaterialesController.registrarUso);

module.exports = router;








