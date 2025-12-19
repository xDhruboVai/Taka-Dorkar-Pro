const pool = require('./config/db');

(async () => {
    try {
        const res = await pool.query("SELECT to_regclass('public.users');");
        console.log('User table exists:', res.rows[0].to_regclass !== null);

        if (res.rows[0].to_regclass === null) {
            console.log('Creating tables...');
            const fs = require('fs');
            const path = require('path');
            const schema = fs.readFileSync(path.join(__dirname, '../database.txt'), 'utf8');
            // Simple splitting might be fragile, but let's try executing the whole block if possible or split by semicolon
            // The provided database.txt has CREATE TABLE statements suitable for direct execution if the DB user has permissions.
            await pool.query(schema);
            console.log('Tables created successfully.');
        }
    } catch (err) {
        console.error('Error checking/creating tables:', err);
    } finally {
        pool.end();
    }
})();
