const db = require('../config/db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
require('dotenv').config();

exports.studentRegister = async (req, res) => {
    const { reg_no, name, email, phone, department_id, department_name, year, password } = req.body;

    try {
        let finalDeptId = department_id;

        // If department_name is provided but no id, look it up
        if (!finalDeptId && department_name) {
            const [deps] = await db.execute('SELECT id FROM departments WHERE department_name = ?', [department_name]);
            if (deps.length > 0) {
                finalDeptId = deps[0].id;
            } else {
                console.warn('Department not found by name:', department_name);
            }
        }

        finalDeptId = finalDeptId || null;
        console.log('Final Dept ID for registration:', finalDeptId);

        // Sanitize inputs (convert undefined to null)
        const params = [
            reg_no || null,
            name || null,
            email || null,
            phone || null,
            finalDeptId,
            year || null,
            await bcrypt.hash(password, 10)
        ];

        const [result] = await db.execute(
            'INSERT INTO students (reg_no, name, email, phone, department_id, year, password) VALUES (?, ?, ?, ?, ?, ?, ?)',
            params
        );

        res.status(201).json({ message: 'Student registered successfully', studentId: result.insertId });
    } catch (err) {
        console.error('Registration Error details:', err);
        res.status(500).json({ message: 'Error registering student', error: err.message, stack: err.stack });
    }
};

exports.studentLogin = async (req, res) => {
    const { reg_no, password } = req.body;

    console.log('Login attempt:', reg_no);
    try {
        const [rows] = await db.execute('SELECT * FROM students WHERE reg_no = ? OR email = ?', [reg_no, reg_no]);

        if (rows.length === 0) {
            console.log('Student not found for identifier:', reg_no);
            return res.status(404).json({ message: 'Student not found' });
        }

        const student = rows[0];
        const isMatch = await bcrypt.compare(password, student.password);

        if (!isMatch) {
            return res.status(401).json({ message: 'Invalid credentials' });
        }

        const token = jwt.sign(
            { id: student.id, reg_no: student.reg_no, role: 'Student' },
            process.env.JWT_SECRET,
            { expiresIn: '24h' }
        );

        res.json({
            token,
            user: {
                id: student.id,
                reg_no: student.reg_no,
                name: student.name,
                email: student.email,
                role: 'Student'
            }
        });
    } catch (err) {
        res.status(500).json({ message: 'Login error', error: err.message });
    }
};

exports.adminRegister = async (req, res) => {
    const { name, email, password, role } = req.body;

    try {
        const hashedPassword = await bcrypt.hash(password, 10);
        const [result] = await db.execute(
            'INSERT INTO admins (name, email, password, role) VALUES (?, ?, ?, ?)',
            [name, email, hashedPassword, role || 'Admin']
        );

        res.status(201).json({ message: 'Admin registered successfully', adminId: result.insertId });
    } catch (err) {
        res.status(500).json({ message: 'Error registering admin', error: err.message });
    }
};

exports.adminLogin = async (req, res) => {
    const { email, password } = req.body;

    console.log('Admin Login attempt:', email);
    try {
        const [rows] = await db.execute('SELECT * FROM admins WHERE email = ?', [email]);

        if (rows.length === 0) {
            return res.status(404).json({ message: 'Admin not found' });
        }

        const admin = rows[0];
        console.log('Found admin:', admin.email);
        const isMatch = await bcrypt.compare(password, admin.password);
        console.log('Password match:', isMatch);

        if (!isMatch) {
            return res.status(401).json({ message: 'Invalid credentials' });
        }

        const token = jwt.sign(
            { id: admin.id, email: admin.email, role: 'Admin', isAdmin: true },
            process.env.JWT_SECRET,
            { expiresIn: '24h' }
        );

        res.json({
            token,
            user: {
                id: admin.id,
                name: admin.name,
                email: admin.email,
                role: admin.role,
                isAdmin: true
            }
        });
    } catch (err) {
        res.status(500).json({ message: 'Login error', error: err.message });
    }
};
