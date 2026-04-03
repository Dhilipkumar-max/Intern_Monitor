const db = require('../config/db');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Multer setup for file uploads
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        let dest = 'uploads/';
        if (file.fieldname === 'resume') dest += 'resumes/';
        if (file.fieldname === 'certificate') dest += 'certificates/';

        if (!fs.existsSync(dest)) {
            fs.mkdirSync(dest, { recursive: true });
        }
        cb(null, dest);
    },
    filename: (req, file, cb) => {
        cb(null, Date.now() + path.extname(file.originalname));
    }
});

const upload = multer({ storage: storage });

exports.uploadMiddleware = upload.fields([
    { name: 'resume', maxCount: 1 },
    { name: 'certificate', maxCount: 1 }
]);

exports.createInternship = async (req, res) => {
    const { student_id, company_name, role, start_date, end_date, description } = req.body;

    try {
        const [result] = await db.execute(
            'INSERT INTO internships (student_id, company_name, role, start_date, end_date, description) VALUES (?, ?, ?, ?, ?, ?)',
            [student_id, company_name, role, start_date, end_date, description]
        );

        res.status(201).json({ message: 'Internship submitted successfully', internshipId: result.insertId });
    } catch (err) {
        res.status(500).json({ message: 'Error submitting internship', error: err.message });
    }
};

exports.getStudentInternships = async (req, res) => {
    const { studentId } = req.params;

    try {
        const [rows] = await db.execute('SELECT * FROM internships WHERE student_id = ?', [studentId]);
        res.json(rows);
    } catch (err) {
        res.status(500).json({ message: 'Error fetching internships', error: err.message });
    }
};

exports.getAllInternships = async (req, res) => {
    try {
        const [rows] = await db.execute(`
      SELECT i.*, s.name as student_name, s.reg_no 
      FROM internships i 
      JOIN students s ON i.student_id = s.id
    `);
        res.json(rows);
    } catch (err) {
        res.status(500).json({ message: 'Error fetching all internships', error: err.message });
    }
};

exports.updateInternshipStatus = async (req, res) => {
    const { id } = req.params;
    const { status } = req.body;

    try {
        await db.execute('UPDATE internships SET status = ? WHERE id = ?', [status, id]);

        // Create notification for student
        const [internship] = await db.execute('SELECT student_id, company_name FROM internships WHERE id = ?', [id]);
        if (internship.length > 0) {
            const message = `Your internship at ${internship[0].company_name} has been ${status}.`;
            await db.execute('INSERT INTO notifications (student_id, message) VALUES (?, ?)', [internship[0].student_id, message]);
        }

        res.json({ message: 'Internship status updated successfully' });
    } catch (err) {
        res.status(500).json({ message: 'Error updating status', error: err.message });
    }
};

exports.uploadCertificate = async (req, res) => {
    const { internship_id } = req.body;
    const certificate_file = req.files['certificate'] ? req.files['certificate'][0].path : null;

    if (!certificate_file) {
        return res.status(400).json({ message: 'No certificate file uploaded' });
    }

    try {
        await db.execute(
            'INSERT INTO certificates (internship_id, certificate_file) VALUES (?, ?)',
            [internship_id, certificate_file]
        );
        res.json({ message: 'Certificate uploaded successfully', filePath: certificate_file });
    } catch (err) {
        res.status(500).json({ message: 'Error uploading certificate', error: err.message });
    }
};

exports.getDashboardStats = async (req, res) => {
    try {
        const [totalStudents] = await db.execute('SELECT COUNT(*) as count FROM students');
        const [studentsWithInternship] = await db.execute('SELECT COUNT(DISTINCT student_id) as count FROM internships');
        const [pendingCerts] = await db.execute('SELECT COUNT(*) as count FROM certificates'); // Simplified for now
        const [completedInternships] = await db.execute('SELECT COUNT(*) as count FROM internships WHERE status = "Approved"');

        res.json({
            totalStudents: totalStudents[0].count,
            studentsWithoutInternships: totalStudents[0].count - studentsWithInternship[0].count,
            pendingCertificates: pendingCerts[0].count,
            completedInternships: completedInternships[0].count
        });
    } catch (err) {
        res.status(500).json({ message: 'Error fetching admin stats', error: err.message });
    }
};
