const pool = require('./config/db');

async function migrate() {
    try {
        console.log('Starting data migration for accounts...');

        const res1 = await pool.query("UPDATE accounts SET parent_type = type WHERE parent_type IS NULL");
        console.log(`Updated ${res1.rowCount} rows: setting parent_type = type`);

        const res2 = await pool.query("UPDATE accounts SET include_in_savings = false WHERE include_in_savings IS NULL");
        console.log(`Updated ${res2.rowCount} rows: setting include_in_savings = false`);

        console.log('Migration completed successfully.');
    } catch (err) {
        console.error('Error during migration:', err);
    } finally {
        await pool.end();
    }
}

migrate();
