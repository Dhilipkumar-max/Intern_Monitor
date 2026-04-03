const db = require('../config/db');

exports.searchStudents = async (req, res) => {
    const { skill_name, skill_level, department } = req.query;

    try {
        let query = `
            SELECT s.*, d.department_name, ss.skill_level, sk.skill_name 
            FROM students s 
            LEFT JOIN departments d ON s.department_id = d.id 
            JOIN student_skills ss ON s.id = ss.student_id 
            JOIN skills sk ON ss.skill_id = sk.id 
            WHERE 1=1
        `;
        const params = [];

        if (skill_name) {
            query += ' AND sk.skill_name LIKE ?';
            params.push(`%${skill_name}%`);
        }
        if (skill_level) {
            query += ' AND ss.skill_level = ?';
            params.push(skill_level);
        }
        if (department) {
            query += ' AND d.department_name LIKE ?';
            params.push(`%${department}%`);
        }

        const [rows] = await db.execute(query, params);

        // Format response to match Flutter expectations
        const formatted = rows.map(r => ({
            student: {
                id: r.student_id || r.id,
                name: r.name,
                email: r.email,
                reg_no: r.reg_no,
                department_name: r.department_name,
                year: r.year,
                role: 'Student',
                resume_file: r.resume_url
            },
            skill_level: r.skill_level
        }));

        res.json(formatted);
    } catch (err) {
        res.status(500).json({ message: 'Error searching students', error: err.message });
    }
};

exports.getStats = async (req, res) => {
    try {
        const [totalStudents] = await db.execute('SELECT COUNT(*) as count FROM students');
        const [studentsWithInternship] = await db.execute('SELECT COUNT(DISTINCT student_id) as count FROM internships');
        const [pendingCerts] = await db.execute('SELECT COUNT(*) as count FROM certificates WHERE status = "Pending"');
        const [completedInternships] = await db.execute('SELECT COUNT(*) as count FROM internships WHERE status = "Approved"');

        res.json({
            totalStudents: totalStudents[0].count,
            studentsWithoutInternships: totalStudents[0].count - studentsWithInternship[0].count,
            pendingCertificates: pendingCerts[0].count,
            completedInternships: completedInternships[0].count
        });
    } catch (err) {
        res.status(500).json({ message: 'Error fetching stats', error: err.message });
    }
};

exports.assignInternship = async (req, res) => {
    const { student_ids, title, company, role, duration, required_skills, admin_id } = req.body;

    try {
        await db.query('START TRANSACTION');

        for (const studentId of student_ids) {
            await db.execute(
                'INSERT INTO internships (student_id, company_name, role, description, start_date, end_date, status) VALUES (?, ?, ?, ?, ?, ?, "Approved")',
                [studentId, company, title, role, new Date(), new Date(),] // Simplified dates for now
            );

            await db.execute(
                'INSERT INTO notifications (student_id, title, message, type) VALUES (?, ?, ?, "internship_assigned")',
                [studentId, 'New Internship Assigned', `You have been assigned to ${title} at ${company}.`]
            );
        }

        await db.query('COMMIT');
        res.status(201).json({ message: 'Internships assigned successfully' });
    } catch (err) {
        await db.query('ROLLBACK');
        res.status(500).json({ message: 'Error assigning internships', error: err.message });
    }
};
