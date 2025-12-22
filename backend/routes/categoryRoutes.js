const express = require('express');
const router = express.Router();
const pool = require('../config/db');

// GET /api/categories?user_id=&type=expense
router.get('/', async (req, res) => {
  try {
    const { user_id, type } = req.query;
    const t = type || 'expense';
    if (!user_id) return res.status(400).json({ error: 'user_id is required' });
    // Return user categories; include system categories if the column exists
    let rows;
    try {
      const q = `SELECT id, name, type FROM categories WHERE (user_id = $1 OR is_system = TRUE) AND type = $2 ORDER BY name`;
      const result = await pool.query(q, [user_id, t]);
      rows = result.rows;
    } catch (_) {
      const q = `SELECT id, name, type FROM categories WHERE user_id = $1 AND type = $2 ORDER BY name`;
      const result = await pool.query(q, [user_id, t]);
      rows = result.rows;
    }
    res.json(rows);
  } catch (error) {
    console.error('Error fetching categories:', error);
    res.status(500).json({ error: 'Failed to fetch categories' });
  }
});

module.exports = router;
