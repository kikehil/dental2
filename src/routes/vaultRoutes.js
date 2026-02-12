const express = require('express');
const router = express.Router();
const vaultController = require('../controllers/vaultController');
const { isAuthenticated, isAdmin } = require('../middleware/auth');

router.get('/', isAuthenticated, isAdmin, vaultController.index);
router.post('/ingresos', isAuthenticated, isAdmin, vaultController.registrarIngreso);
router.post('/mover-ahorro', isAuthenticated, isAdmin, vaultController.moverAhorro);
router.post('/retiro-ahorro', isAuthenticated, isAdmin, vaultController.retirarAhorro);

module.exports = router;




