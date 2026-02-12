const express = require('express');
const router = express.Router();
const retirosController = require('../controllers/retirosController');
const { isAuthenticated, isAdmin } = require('../middleware/auth');

// Historial de retiros (solo admin)
router.get('/', isAuthenticated, isAdmin, retirosController.index);

module.exports = router;


