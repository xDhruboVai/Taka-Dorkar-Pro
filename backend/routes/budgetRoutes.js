const express = require('express');
const router = express.Router();
const Budget = require('../models/Budget');

// GET /api/budgets?user_id=&month=YYYY-MM
router.get('/', async (req, res) => {
  try {
    const { user_id, month } = req.query;
    if (!user_id || !month) {
      return res.status(400).json({ error: 'user_id and month (YYYY-MM) are required' });
    }
    const [y, m] = month.split('-').map((v) => parseInt(v, 10));
    if (!y || !m) return res.status(400).json({ error: 'Invalid month format' });
    const start = new Date(Date.UTC(y, m - 1, 1));
    const end = new Date(Date.UTC(y, m, 1));
    const rows = await Budget.findByMonth(user_id, start.toISOString().slice(0, 10), end.toISOString().slice(0, 10));
    res.json(rows);
  } catch (error) {
    console.error('Error fetching budgets:', error);
    res.status(500).json({ error: 'Failed to fetch budgets' });
  }
});

// POST /api/budgets
router.post('/', async (req, res) => {
  try {
    const { id, user_id, category_id, amount, period, start_date, end_date } = req.body;
    if (!user_id || !category_id || !amount || !period || !start_date) {
      return res.status(400).json({ error: 'Missing required fields' });
    }
    const created = await Budget.create({ id, user_id, category_id, amount, period, start_date, end_date });
    res.status(201).json(created);
  } catch (error) {
    console.error('Error creating budget:', error);
    res.status(500).json({ error: 'Failed to create budget' });
  }
});

// PATCH /api/budgets/:id
router.patch('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { amount, is_deleted } = req.body;
    let updated;
    if (typeof is_deleted === 'boolean') {
      updated = await Budget.softDelete(id);
    } else if (typeof amount !== 'undefined') {
      updated = await Budget.updateAmount(id, amount);
    }
    if (!updated) return res.status(404).json({ error: 'Budget not found' });
    res.json(updated);
  } catch (error) {
    console.error('Error updating budget:', error);
    res.status(500).json({ error: 'Failed to update budget' });
  }
});

module.exports = router;
