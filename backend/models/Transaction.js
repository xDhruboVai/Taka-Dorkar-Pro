const pool = require('../config/db');

class Transaction {
    static async create({ user_id, amount, type, category, account, date, note }) {
        const query = `
      INSERT INTO transactions (user_id, amount, type, category, account, date, note)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      RETURNING *;
    `;
        const values = [user_id, amount, type, category, account, date, note];
        const { rows } = await pool.query(query, values);
        return rows[0];
    }

    static async findAll(user_id) {
        const query = `
      SELECT * FROM transactions
      WHERE user_id = $1
      ORDER BY date DESC;
    `;
        const { rows } = await pool.query(query, [user_id]);
        return rows;
    }
}

module.exports = Transaction;
