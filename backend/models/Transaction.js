const pool = require('../config/db');

class Transaction {
    static async create({ user_id, account_id, amount, type, category, date, note }) {
        const query = `
      INSERT INTO transactions (user_id, account_id, amount, type, category, date, note)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      RETURNING *;
    `;
        const values = [user_id, account_id, amount, type, category, date, note];
        const { rows } = await pool.query(query, values);
        return rows[0];
    }

    static async findByUserId(user_id) {
        const query = `
      SELECT * 
      FROM transactions 
      WHERE user_id = $1 
      ORDER BY date DESC
    `;
        const { rows } = await pool.query(query, [user_id]);
        return rows;
    }

    static async delete(id, user_id) {
        const query = 'DELETE FROM transactions WHERE id = $1 AND user_id = $2 RETURNING *';
        const { rows } = await pool.query(query, [id, user_id]);
        return rows[0];
    }
}

module.exports = Transaction;
