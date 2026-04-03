const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const { verifyToken, isAdmin } = require('../middleware/authMiddleware');

router.get('/search-students', verifyToken, isAdmin, adminController.searchStudents);
router.get('/stats', verifyToken, isAdmin, adminController.getStats);
router.post('/assign-internship', verifyToken, isAdmin, adminController.assignInternship);

module.exports = router;
