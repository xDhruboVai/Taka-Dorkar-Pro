const pool = require('./config/db');

async function checkDb() {
    try {
        console.log('Checking tables...');
        const tables = await pool.query("SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'");
        console.log('Tables in public schema:', tables.rows.map(r => r.table_name));

        if (tables.rows.some(r => r.table_name === 'accounts')) {
            console.log('Checking columns in "accounts" table...');
            const columns = await pool.query("SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'accounts'");
            console.log('Columns in "accounts":');
            columns.rows.forEach(c => console.log(` - ${c.column_name}: ${c.data_type}`));
        } else {
            console.log('Table "accounts" does NOT exist!');
        }

        const userCount = await pool.query("SELECT COUNT(*) FROM users");
        console.log('User count:', userCount.rows[0].count);

        if (tables.rows.some(r => r.table_name === 'accounts')) {
            const accountCount = await pool.query("SELECT COUNT(*) FROM accounts");
            console.log('Account count:', accountCount.rows[0].count);

            const nullParentType = await pool.query("SELECT COUNT(*) FROM accounts WHERE parent_type IS NULL");
            console.log('Accounts with NULL parent_type:', nullParentType.rows[0].count);

            const nullType = await pool.query("SELECT COUNT(*) FROM accounts WHERE type IS NULL");
            console.log('Accounts with NULL type:', nullType.rows[0].count);

            if (parseInt(nullParentType.rows[0].count) > 0) {
                console.log('Sample accounts with NULL parent_type:');
                const samples = await pool.query("SELECT id, name, type, parent_type FROM accounts WHERE parent_type IS NULL LIMIT 5");
                console.table(samples.rows);
            }
        }

    } catch (err) {
        console.error('Error checking DB:', err);
    } finally {
        await pool.end();
    }
}

checkDb();
