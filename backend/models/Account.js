const pool = require('../config/db');

class Account {
    static async create({ user_id, name, type, balance = 0, currency = 'BDT', is_default = false, parent_type, include_in_savings = false }) {
        const query = `
      INSERT INTO accounts (user_id, name, type, balance, currency, is_default, parent_type, include_in_savings)
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
      RETURNING *;
    `;
        const values = [user_id, name, type, balance, currency, is_default, parent_type, include_in_savings];
        const { rows } = await pool.query(query, values);
        return rows[0];
    }

    static async findByUserId(user_id) {
        const query = 'SELECT * FROM accounts WHERE user_id = $1 ORDER BY created_at DESC';
        const { rows } = await pool.query(query, [user_id]);
        return rows;
    }

    static async findById(id) {
        const query = 'SELECT * FROM accounts WHERE id = $1';
        const { rows } = await pool.query(query, [id]);
        return rows[0];
    }

    static async update(id, data) {
        const fields = Object.keys(data);
        if (fields.length === 0) return null;

        const setClause = fields.map((field, index) => `${field} = $${index + 2}`).join(', ');
        const query = `
      UPDATE accounts 
      SET ${setClause}, updated_at = NOW() 
      WHERE id = $1 
      RETURNING *;
    `;
        const values = [id, ...Object.values(data)];
        const { rows } = await pool.query(query, values);
        return rows[0];
    }

    static async delete(id) {
        const query = 'DELETE FROM accounts WHERE id = $1';
        await pool.query(query, [id]);
    }
}

module.exports = Account;
