const express = require('express');
const router = express.Router();
const internshipController = require('../controllers/internshipController');
const { verifyToken, isAdmin } = require('../middleware/authMiddleware');

router.post('/', verifyToken, internshipController.createInternship);
router.get('/student/:studentId', verifyToken, internshipController.getStudentInternships);
router.get('/all', verifyToken, isAdmin, internshipController.getAllInternships);
router.get('/stats', verifyToken, isAdmin, internshipController.getDashboardStats);
router.put('/:id/status', verifyToken, isAdmin, internshipController.updateInternshipStatus);
router.post('/upload-certificate', verifyToken, internshipController.uploadMiddleware, internshipController.uploadCertificate);

module.exports = router;
