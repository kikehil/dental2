const express = require('express');
const router = express.Router();
const laboratoriosController = require('../controllers/laboratoriosController');
const { isAuthenticated, hasModuleAccess } = require('../middleware/auth');

// Vistas
router.get('/', isAuthenticated, hasModuleAccess('/laboratorios'), laboratoriosController.index);
router.get('/crear', isAuthenticated, laboratoriosController.create);
router.post('/crear', isAuthenticated, laboratoriosController.store);
router.get('/:id', isAuthenticated, laboratoriosController.show);
router.get('/:id/editar', isAuthenticated, laboratoriosController.edit);
router.post('/:id/editar', isAuthenticated, laboratoriosController.update);
router.post('/:id/eliminar', isAuthenticated, laboratoriosController.destroy);

module.exports = router;

