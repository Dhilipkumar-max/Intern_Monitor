const mysql = require('mysql2/promise');
require('dotenv').config();

const departments = [
    'Computer Science and Engineering',
    'Artificial Intelligence & Machine Learning',
    'Electronics and Communication Engineering',
    'Artificial Intelligence & Data Science',
    'Computer Communication Engineering',
    'Computer Science and Business System',
    'BioTech',
    'VLSI',
    'Mechanical Engineering'
];

async function seed() {
    try {
        const connection = await mysql.createConnection({
            host: process.env.DB_HOST,
            user: process.env.DB_USER,
            password: process.env.DB_PASSWORD,
            database: process.env.DB_NAME
        });

        console.log('Seeding departments...');
        for (const dept of departments) {
            // Check if exists
            const [rows] = await connection.execute('SELECT id FROM departments WHERE department_name = ?', [dept]);
            if (rows.length === 0) {
                await connection.execute('INSERT INTO departments (department_name, department_code) VALUES (?, ?)', [dept, dept.split(' ').map(w => w[0]).join('')]);
                console.log(`Added: ${dept}`);
            } else {
                console.log(`Exists: ${dept}`);
            }
        }

        await connection.end();
        console.log('Seeding complete!');
    } catch (err) {
        console.error('Error:', err.message);
    }
}

seed();
