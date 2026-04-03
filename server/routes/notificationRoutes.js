const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notificationController');
const { verifyToken } = require('../middleware/authMiddleware');

router.get('/student/:studentId', verifyToken, notificationController.getStudentNotifications);
router.put('/:id/read', verifyToken, notificationController.markAsRead);
router.post('/', verifyToken, notificationController.createNotification);

module.exports = router;
