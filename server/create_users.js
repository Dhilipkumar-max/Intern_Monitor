const db = require('./config/db');
const bcrypt = require('bcryptjs');

async function createUsers() {
    try {
        console.log('Starting user creation...');
        
        // 1. Create Admin: admin@ritchennai.edu.in / admin123
        const adminPassword = await bcrypt.hash('admin123', 10);
        await db.execute(
            'INSERT INTO admins (name, email, password, role) VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE password = VALUES(password)',
            ['System Admin', 'admin@ritchennai.edu.in', adminPassword, 'Admin']
        );
        console.log('Admin admin@ritchennai.edu.in created/updated.');

        // 2. Create Student: dhilipkumar.240086@cse.ritchennai.edu.in / 2117240020086
        const studentPassword = await bcrypt.hash('2117240020086', 10);
        await db.execute(
            'INSERT INTO students (reg_no, name, email, password, year) VALUES (?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE password = VALUES(password)',
            ['2117240020086', 'Dhilip Kumar', 'dhilipkumar.240086@cse.ritchennai.edu.in', studentPassword, 2]
        );
        console.log('Student dhilipkumar.240086@cse.ritchennai.edu.in created/updated.');

        console.log('All users created successfully.');
        process.exit(0);
    } catch (err) {
        console.error('Error creating users:', err);
        process.exit(1);
    }
}

createUsers();
