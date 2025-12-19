const pool = require('./config/db');

(async () => {
    try {
        const res = await pool.query("SELECT to_regclass('public.users');");
        console.log('User table exists:', res.rows[0].to_regclass !== null);

        if (res.rows[0].to_regclass === null) {
            console.log('Creating tables...');
            const fs = require('fs');
            const path = require('path');

            // Fallback if database.txt is missing or to explicitly add transactions
            const createTransactionsTable = `
                CREATE TABLE IF NOT EXISTS transactions (
                    id SERIAL PRIMARY KEY,
                    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
                    amount DECIMAL(12, 2) NOT NULL,
                    type VARCHAR(20) NOT NULL CHECK (type IN ('income', 'expense', 'transfer')),
                    category VARCHAR(50),
                    account VARCHAR(50),
                    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    note TEXT,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                );
            `;

            try {
                const schema = fs.readFileSync(path.join(__dirname, '../database.txt'), 'utf8');
                await pool.query(schema);
            } catch (e) {
                console.log('database.txt not found, skipping initial schema load (assuming partial existence or manual setup).');
            }

            await pool.query(createTransactionsTable);
            console.log('Tables created successfully.');
        } else {
            // Check if transactions table exists, if not create it
            const resTx = await pool.query("SELECT to_regclass('public.transactions');");
            if (resTx.rows[0].to_regclass === null) {
                console.log('Transactions table missing. Creating...');
                const createTransactionsTable = `
                    CREATE TABLE IF NOT EXISTS transactions (
                        id SERIAL PRIMARY KEY,
                        user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
                        amount DECIMAL(12, 2) NOT NULL,
                        type VARCHAR(20) NOT NULL CHECK (type IN ('income', 'expense', 'transfer')),
                        category VARCHAR(50),
                        account VARCHAR(50),
                        date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                        note TEXT,
                        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                    );
                `;
                await pool.query(createTransactionsTable);
                console.log('Transactions table created.');
            } else {
                console.log('Transactions table already exists.');
            }
        }
    } catch (err) {
        console.error('Error checking/creating tables:', err);
    } finally {
        pool.end();
    }
})();
