const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');
require('dotenv').config();

async function resetAdmin() {
    try {
        const connection = await mysql.createConnection({
            host: process.env.DB_HOST,
            user: process.env.DB_USER,
            password: process.env.DB_PASSWORD,
            database: process.env.DB_NAME
        });

        const email = 'admin@interninfo.com';
        const password = 'Admin@123';
        const hashedPassword = await bcrypt.hash(password, 10);

        // Check if admin exists
        const [rows] = await connection.execute('SELECT * FROM admins WHERE email = ?', [email]);

        if (rows.length > 0) {
            await connection.execute(
                'UPDATE admins SET password = ? WHERE email = ?',
                [hashedPassword, email]
            );
            console.log(`Successfully updated password for ${email}`);
        } else {
            await connection.execute(
                'INSERT INTO admins (name, email, password, role) VALUES (?, ?, ?, ?)',
                ['System Admin', email, hashedPassword, 'Admin']
            );
            console.log(`Successfully created admin account: ${email}`);
        }

        await connection.end();
        console.log('You can now login with:');
        console.log(`Email: ${email}`);
        console.log(`Password: ${password}`);
    } catch (err) {
        console.error('Error:', err.message);
    }
}

resetAdmin();
