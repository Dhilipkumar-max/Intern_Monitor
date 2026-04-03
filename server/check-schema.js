const mysql = require('mysql2/promise');
require('dotenv').config();
const fs = require('fs');

async function checkSchema() {
    try {
        const connection = await mysql.createConnection({
            host: process.env.DB_HOST,
            user: process.env.DB_USER,
            password: process.env.DB_PASSWORD,
            database: process.env.DB_NAME
        });

        let output = '';
        const tables = ['students', 'departments', 'skills', 'student_skills', 'notifications', 'internships', 'certificates'];

        for (const table of tables) {
            output += `\n--- ${table.toUpperCase()} TABLE ---\n`;
            try {
                const [cols] = await connection.execute(`DESCRIBE ${table}`);
                cols.forEach(c => {
                    output += `${c.Field} | ${c.Type} | ${c.Null} | ${c.Key} | ${c.Extra}\n`;
                });
            } catch (e) {
                output += `Error: ${e.message}\n`;
            }
        }

        fs.writeFileSync('schema.txt', output);
        console.log('Schema written to schema.txt');

        await connection.end();
    } catch (err) {
        console.error('Error:', err.message);
    }
}

checkSchema();
