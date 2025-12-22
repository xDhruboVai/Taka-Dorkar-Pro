const pool = require('../config/db');

class Budget {
  static async create({ id, user_id, category_id, amount, period, start_date, end_date }) {
    const query = `
      INSERT INTO budgets (id, user_id, category_id, amount, period, start_date, end_date)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      RETURNING *;
    `;
    const values = [id, user_id, category_id, amount, period, start_date, end_date || null];
    const { rows } = await pool.query(query, values);
    return rows[0];
  }

  static async updateAmount(id, amount) {
    const { rows } = await pool.query(
      'UPDATE budgets SET amount = $1, updated_at = NOW() WHERE id = $2 RETURNING *',
      [amount, id],
    );
    return rows[0];
  }

  static async softDelete(id) {
    const { rows } = await pool.query(
      'UPDATE budgets SET is_deleted = TRUE, updated_at = NOW() WHERE id = $1 RETURNING *',
      [id],
    );
    return rows[0];
  }

  static async findByMonth(user_id, monthStart, monthEnd) {
    const query = `
      SELECT * FROM budgets
      WHERE user_id = $1 AND is_deleted = FALSE AND period = 'monthly'
        AND start_date >= $2 AND start_date < $3
      ORDER BY created_at DESC
    `;
    const { rows } = await pool.query(query, [user_id, monthStart, monthEnd]);
    return rows;
  }
}

module.exports = Budget;
