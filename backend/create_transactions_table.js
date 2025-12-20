const pool = require('./config/db');

(async () => {
    try {
        // Drop existing table to create fresh
        await pool.query('DROP TABLE IF EXISTS transactions');

        // Correction: User ID is UUID, Account ID is UUID (stored as string/varchar locally)
        const createTableQuery = `
      CREATE TABLE IF NOT EXISTS transactions (
        id SERIAL PRIMARY KEY,
        user_id UUID REFERENCES users(id) ON DELETE CASCADE,
        account_id VARCHAR(255),
        amount DECIMAL(12, 2) NOT NULL,
        type VARCHAR(20) NOT NULL CHECK (type IN ('income', 'expense', 'transfer')),
        category VARCHAR(50),
        date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        note TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `;
        await pool.query(createTableQuery);
        console.log('Transactions table recreated successfully with UUID user_id and VARCHAR account_id.');
    } catch (err) {
        console.error('Error creating transactions table:', err);
    } finally {
        pool.end();
    }
})();
