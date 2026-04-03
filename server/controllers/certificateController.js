const db = require('../config/db');

exports.createCertificate = async (req, res) => {
    const { student_id, certificate_type, file_url, file_name } = req.body;
    try {
        await db.execute(
            'INSERT INTO certificates (student_id, certificate_type, file_url, file_name, status) VALUES (?, ?, ?, ?, "Pending")',
            [student_id, certificate_type, file_url, file_name]
        );
        res.status(201).json({ message: 'Certificate created successfully' });
    } catch (err) {
        res.status(500).json({ message: 'Error creating certificate', error: err.message });
    }
};

exports.getStudentCertificates = async (req, res) => {
    const { studentId } = req.params;
    try {
        const [rows] = await db.execute('SELECT * FROM certificates WHERE student_id = ? ORDER BY uploaded_at DESC', [studentId]);
        res.json(rows);
    } catch (err) {
        res.status(500).json({ message: 'Error fetching certificates', error: err.message });
    }
};

exports.updateCertificate = async (req, res) => {
    const { id } = req.params;
    const { certificate_type } = req.body;
    try {
        await db.execute('UPDATE certificates SET certificate_type = ? WHERE id = ?', [certificate_type, id]);
        res.json({ message: 'Certificate updated successfully' });
    } catch (err) {
        res.status(500).json({ message: 'Error updating certificate', error: err.message });
    }
};

exports.deleteCertificate = async (req, res) => {
    const { id } = req.params;
    try {
        await db.execute('DELETE FROM certificates WHERE id = ?', [id]);
        res.json({ message: 'Certificate deleted successfully' });
    } catch (err) {
        res.status(500).json({ message: 'Error deleting certificate', error: err.message });
    }
};

exports.getPendingCertificates = async (req, res) => {
    try {
        const [rows] = await db.execute(`
            SELECT c.*, s.name as student_name, s.reg_no 
            FROM certificates c 
            JOIN students s ON c.student_id = s.id 
            WHERE c.status = "Pending"
        `);
        res.json(rows);
    } catch (err) {
        res.status(500).json({ message: 'Error fetching pending certificates', error: err.message });
    }
};

exports.verifyCertificate = async (req, res) => {
    const { id } = req.params;
    try {
        await db.execute('UPDATE certificates SET status = "Verified" WHERE id = ?', [id]);

        // Notify student
        const [cert] = await db.execute('SELECT student_id, certificate_type FROM certificates WHERE id = ?', [id]);
        if (cert.length > 0) {
            await db.execute(
                'INSERT INTO notifications (student_id, title, message, type) VALUES (?, ?, ?, "certificate_status")',
                [cert[0].student_id, 'Certificate Verified', `Your certificate "${cert[0].certificate_type}" has been verified.`,]
            );
        }
        res.json({ message: 'Certificate verified' });
    } catch (err) {
        res.status(500).json({ message: 'Error verifying certificate', error: err.message });
    }
};

exports.rejectCertificate = async (req, res) => {
    const { id } = req.params;
    const { reason } = req.body;
    try {
        await db.execute('UPDATE certificates SET status = "Rejected" WHERE id = ?', [id]);

        // Notify student
        const [cert] = await db.execute('SELECT student_id, certificate_type FROM certificates WHERE id = ?', [id]);
        if (cert.length > 0) {
            await db.execute(
                'INSERT INTO notifications (student_id, title, message, type) VALUES (?, ?, ?, "certificate_status")',
                [cert[0].student_id, 'Certificate Rejected', `Your certificate "${cert[0].certificate_type}" was rejected. Reason: ${reason || 'Not provided'}.`]
            );
        }
        res.json({ message: 'Certificate rejected' });
    } catch (err) {
        res.status(500).json({ message: 'Error rejecting certificate', error: err.message });
    }
};
