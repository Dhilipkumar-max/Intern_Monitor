const express = require('express');
const router = express.Router();
const certificateController = require('../controllers/certificateController');
const { verifyToken, isAdmin } = require('../middleware/authMiddleware');

router.post('/', verifyToken, certificateController.createCertificate);
router.get('/student/:studentId', verifyToken, certificateController.getStudentCertificates);
router.get('/pending', verifyToken, isAdmin, certificateController.getPendingCertificates);
router.put('/:id', verifyToken, certificateController.updateCertificate);
router.delete('/:id', verifyToken, certificateController.deleteCertificate);
router.put('/:id/verify', verifyToken, isAdmin, certificateController.verifyCertificate);
router.put('/:id/reject', verifyToken, isAdmin, certificateController.rejectCertificate);

module.exports = router;
