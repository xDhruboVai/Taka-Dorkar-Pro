const express = require('express');
const router = express.Router();
const Transaction = require('../models/Transaction');

// Create a new transaction
router.post('/', async (req, res) => {
    try {
        const { user_id, account_id, amount, type, category, date, note } = req.body;
        // Basic validation
        if (!user_id || !amount || !type) {
            return res.status(400).json({ error: 'User ID, Amount, and Type are required' });
        }

        const transaction = await Transaction.create({
            user_id,
            account_id,
            amount,
            type,
            category,
            date,
            note
        });

        res.status(201).json(transaction);
    } catch (error) {
        console.error('Error creating transaction:', error);
        res.status(500).json({ error: 'Failed to create transaction' });
    }
});

// Get all transactions for a user
router.get('/', async (req, res) => {
    try {
        const { user_id } = req.query;
        if (!user_id) {
            return res.status(400).json({ error: 'User ID is required' });
        }

        const transactions = await Transaction.findByUserId(user_id);
        res.json(transactions);
    } catch (error) {
        console.error('Error fetching transactions:', error);
        res.status(500).json({ error: 'Failed to fetch transactions' });
    }
});

module.exports = router;
