const db = require('../config/db');

exports.getAllStudents = async (req, res) => {
    try {
        const [rows] = await db.execute(`
            SELECT s.id, s.reg_no, s.name, s.email, s.phone, s.year, d.department_name, 'Student' as role, s.resume_url, s.github_url, s.linkedin_url 
            FROM students s 
            LEFT JOIN departments d ON s.department_id = d.id
        `);
        res.json(rows);
    } catch (err) {
        res.status(500).json({ message: 'Error fetching students', error: err.message });
    }
};

exports.getStudentById = async (req, res) => {
    const { id } = req.params;
    try {
        const [rows] = await db.execute(`
            SELECT s.id, s.reg_no, s.name, s.email, s.phone, s.year, d.department_name, 'Student' as role, s.resume_url, s.github_url, s.linkedin_url 
            FROM students s 
            LEFT JOIN departments d ON s.department_id = d.id 
            WHERE s.id = ?
        `, [id]);

        if (rows.length === 0) {
            return res.status(404).json({ message: 'Student not found' });
        }
        res.json(rows[0]);
    } catch (err) {
        res.status(500).json({ message: 'Error fetching student', error: err.message });
    }
};

exports.getStudentProfile = async (req, res) => {
    const { id } = req.params;

    try {
        const [rows] = await db.execute(`
      SELECT s.id, s.reg_no, s.name, s.email, s.phone, s.year, d.department_name, d.department_code, s.resume_url, s.github_url, s.linkedin_url 
      FROM students s 
      LEFT JOIN departments d ON s.department_id = d.id 
      WHERE s.id = ?
            `, [id]);

        if (rows.length === 0) {
            return res.status(404).json({ message: 'Student not found' });
        }

        // Fetch skills
        const [skills] = await db.execute(`
      SELECT sk.skill_name 
      FROM student_skills ss 
      JOIN skills sk ON ss.skill_id = sk.id 
      WHERE ss.student_id = ?
            `, [id]);

        const profile = rows[0];
        profile.role = 'Student'; // Added to prevent Flutter JSON parsing error
        profile.skills = skills.map(s => s.skill_name);

        res.json(profile);
    } catch (err) {
        res.status(500).json({ message: 'Error fetching profile', error: err.message });
    }
};

exports.updateProfile = async (req, res) => {
    const { id } = req.params;

    const allowedFields = ['name', 'email', 'phone', 'year', 'resume_url', 'github_url', 'linkedin_url'];
    const updates = [];
    const values = [];

    for (const key of Object.keys(req.body)) {
        if (allowedFields.includes(key)) {
            updates.push(`${key} = ?`);
            values.push(req.body[key]);
        }
    }

    if (updates.length === 0) {
        return res.json({ message: 'No valid fields to update' });
    }

    values.push(id);

    try {
        await db.execute(
            `UPDATE students SET ${updates.join(', ')} WHERE id = ? `,
            values
        );
        res.json({ message: 'Profile updated successfully' });
    } catch (err) {
        res.status(500).json({ message: 'Error updating profile', error: err.message });
    }
};

exports.getDepartments = async (req, res) => {
    try {
        const [rows] = await db.execute('SELECT * FROM departments');
        res.json(rows);
    } catch (err) {
        res.status(500).json({ message: 'Error fetching departments', error: err.message });
    }
};

exports.getDashboardStats = async (req, res) => {
    const { id } = req.params;

    try {
        const [skills] = await db.execute('SELECT COUNT(*) as count FROM student_skills WHERE student_id = ?', [id]);
        const [certs] = await db.execute('SELECT COUNT(*) as count FROM certificates c JOIN internships i ON c.internship_id = i.id WHERE i.student_id = ?', [id]);
        const [notifs] = await db.execute('SELECT COUNT(*) as count FROM notifications WHERE student_id = ? AND status = "Unread"', [id]);
        const [internship] = await db.execute('SELECT status FROM internships WHERE student_id = ? ORDER BY created_at DESC LIMIT 1', [id]);

        res.json({
            skillsCount: skills[0].count,
            certificatesCount: certs[0].count,
            unreadNotifications: notifs[0].count,
            internshipStatus: internship.length > 0 ? internship[0].status : 'Not Assigned'
        });
    } catch (err) {
        res.status(500).json({ message: 'Error fetching stats', error: err.message });
    }
};
exports.createStudent = async (req, res) => {
    const { reg_no, name, email, phone, department_id, department_name, year, password } = req.body;

    try {
        let finalDeptId = department_id;

        // Lookup department ID by name if needed
        if (!finalDeptId && department_name) {
            const [deps] = await db.execute('SELECT id FROM departments WHERE department_name = ?', [department_name]);
            if (deps.length > 0) {
                finalDeptId = deps[0].id;
            }
        }

        finalDeptId = finalDeptId || null;
        console.log('Final Dept ID for student creation:', finalDeptId);

        const bcrypt = require('bcryptjs');
        const hashedPassword = await bcrypt.hash(password || 'password123', 10);

        // Sanitize inputs (convert undefined to null)
        const params = [
            reg_no || null,
            name || null,
            email || null,
            phone || null,
            finalDeptId,
            year || null,
            hashedPassword
        ];

        const [result] = await db.execute(
            'INSERT INTO students (reg_no, name, email, phone, department_id, year, password) VALUES (?, ?, ?, ?, ?, ?, ?)',
            params
        );

        res.status(201).json({ message: 'Student created successfully', studentId: result.insertId });
    } catch (err) {
        console.error('Error creating student:', err);
        res.status(500).json({ message: 'Error creating student', error: err.message });
    }
};
