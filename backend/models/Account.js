const pool = require('../config/db');

class Account {
    static async create({ user_id, name, type, balance = 0, currency = 'BDT', is_default = false }) {
        const query = `
      INSERT INTO accounts (user_id, name, type, balance, currency, is_default)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING *;
    `;
        const values = [user_id, name, type, balance, currency, is_default];
        const { rows } = await pool.query(query, values);
        return rows[0];
    }
}

module.exports = Account;
