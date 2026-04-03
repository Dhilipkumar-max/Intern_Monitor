const mysql = require('mysql2/promise');
require('dotenv').config();

async function checkDB() {
    try {
        const connection = await mysql.createConnection({
            host: process.env.DB_HOST,
            user: process.env.DB_USER,
            password: process.env.DB_PASSWORD,
            database: process.env.DB_NAME
        });

        console.log('--- TABLES ---');
        const [tables] = await connection.execute('SHOW TABLES');
        console.log(tables);

        console.log('\n--- DEPARTMENTS ---');
        const [deps] = await connection.execute('SELECT * FROM departments');
        console.log(deps);

        console.log('\n--- STUDENTS (First 5) ---');
        const [students] = await connection.execute('SELECT id, reg_no, email, name FROM students LIMIT 5');
        console.log(students);

        await connection.end();
    } catch (err) {
        console.error('Error:', err.message);
    }
}

checkDB();
