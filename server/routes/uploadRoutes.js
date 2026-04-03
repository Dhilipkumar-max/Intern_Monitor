const express = require('express');
const router = express.Router();
const uploadController = require('../controllers/uploadController');
const { verifyToken } = require('../middleware/authMiddleware');

router.post('/resume', verifyToken, uploadController.uploadMiddleware.single('resume'), uploadController.uploadResume);
router.post('/certificate', verifyToken, uploadController.uploadMiddleware.single('certificate'), uploadController.uploadCertificate);

module.exports = router;
