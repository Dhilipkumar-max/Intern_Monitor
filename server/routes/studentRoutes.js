const express = require('express');
const router = express.Router();
const studentController = require('../controllers/studentController');
const { verifyToken } = require('../middleware/authMiddleware');

router.get('/', verifyToken, studentController.getAllStudents);
router.get('/:id', verifyToken, studentController.getStudentById);
router.get('/profile/:id', verifyToken, studentController.getStudentProfile);
router.put('/profile/:id', verifyToken, studentController.updateProfile);
router.get('/departments', studentController.getDepartments);
router.post('/', verifyToken, studentController.createStudent);
router.get('/stats/:id', verifyToken, studentController.getDashboardStats);

module.exports = router;
