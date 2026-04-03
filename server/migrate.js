const mysql = require('mysql2/promise');
require('dotenv').config();

async function migrate() {
    try {
        const connection = await mysql.createConnection({
            host: process.env.DB_HOST,
            user: process.env.DB_USER,
            password: process.env.DB_PASSWORD,
            database: process.env.DB_NAME
        });

        console.log('Attempting to add columns...');
        try {
            await connection.execute('ALTER TABLE students ADD COLUMN resume_url VARCHAR(255)');
            console.log('Added resume_url to students');
        } catch (e) {
            console.log('resume_url already exists or error:', e.message);
        }

        try {
            await connection.execute('ALTER TABLE students ADD COLUMN github_url VARCHAR(255)');
            console.log('Added github_url to students');
        } catch (e) {
            console.log('github_url already exists or error:', e.message);
        }

        try {
            await connection.execute('ALTER TABLE students ADD COLUMN linkedin_url VARCHAR(255)');
            console.log('Added linkedin_url to students');
        } catch (e) {
            console.log('linkedin_url already exists or error:', e.message);
        }

        try {
            await connection.execute('ALTER TABLE internships ADD COLUMN status VARCHAR(50) DEFAULT "Pending"');
            console.log('Added status to internships');
        } catch (e) {
            console.log('status already exists or error:', e.message);
        }

        console.log('Migration complete!');
        await connection.end();
    } catch (err) {
        console.error('Migration error:', err.message);
    }
}

migrate();
