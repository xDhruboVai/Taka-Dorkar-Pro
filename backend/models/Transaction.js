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

    static async findByUserId(user_id, { type, category, from, to } = {}) {
        const clauses = ['user_id = $1'];
        const params = [user_id];
        let p = 2;
        if (type) {
            clauses.push(`type = $${p++}`);
            params.push(type);
        }
        if (category) {
            clauses.push(`category = $${p++}`);
            params.push(category);
        }
        if (from) {
            clauses.push(`date >= $${p++}`);
            params.push(from);
        }
        if (to) {
            clauses.push(`date < $${p++}`);
            params.push(to);
        }
        const query = `SELECT * FROM transactions WHERE ${clauses.join(' AND ')} ORDER BY date DESC`;
        const { rows } = await pool.query(query, params);
        return rows;
    }

    static async delete(id, user_id) {
        const query = 'DELETE FROM transactions WHERE id = $1 AND user_id = $2 RETURNING *';
        const { rows } = await pool.query(query, [id, user_id]);
        return rows[0];
    }
}

module.exports = Transaction;
