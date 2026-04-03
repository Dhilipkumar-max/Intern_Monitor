const multer = require('multer');
const path = require('path');
const db = require('../config/db');

// Configure storage
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        if (file.fieldname === 'resume') {
            cb(null, 'uploads/resumes/');
        } else {
            cb(null, 'uploads/certificates/');
        }
    },
    filename: (req, file, cb) => {
        cb(null, `${Date.now()}-${file.originalname}`);
    }
});

const upload = multer({ storage });

exports.uploadResume = async (req, res) => {
    const { studentId } = req.body;
    if (!req.file) return res.status(400).json({ message: 'No file uploaded' });

    const fileUrl = `/uploads/resumes/${req.file.filename}`;

    try {
        await db.execute('UPDATE students SET resume_url = ? WHERE id = ?', [fileUrl, studentId]);
        res.json({ message: 'Resume uploaded successfully', url: fileUrl });
    } catch (err) {
        res.status(500).json({ message: 'Database error', error: err.message });
    }
};

exports.uploadCertificate = async (req, res) => {
    if (!req.file) return res.status(400).json({ message: 'No file uploaded' });
    const fileUrl = `/uploads/certificates/${req.file.filename}`;
    res.status(201).json({ message: 'Certificate uploaded successfully', url: fileUrl });
};

exports.uploadMiddleware = upload;
