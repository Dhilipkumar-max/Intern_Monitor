const express = require('express');
const router = express.Router();
const skillController = require('../controllers/skillController');
const { verifyToken } = require('../middleware/authMiddleware');

router.get('/', skillController.getAllSkills);
router.get('/student/:studentId', verifyToken, skillController.getStudentSkills);
router.post('/add', verifyToken, skillController.addStudentSkill);
router.put('/update', verifyToken, skillController.updateStudentSkill);
router.delete('/:id', verifyToken, skillController.deleteStudentSkill);

module.exports = router;
