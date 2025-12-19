const Transaction = require('../models/Transaction');

exports.getTransactions = async (req, res) => {
    try {
        // Assuming user_id is available from auth middleware, or passed in query for now if auth not fully set up
        // Ideally: const user_id = req.user.id;
        // For now, let's assume a default user_id or extract from headers/body if needed by the current auth setup.
        // Looking at authRoutes, there might be a middleware verification.
        // Let's assume the user is authenticated and req.user exists.
        // If not, we might need to adjust.
        const user_id = req.user ? req.user.id : req.query.user_id;

        if (!user_id) {
            return res.status(400).json({ error: 'User ID is required' });
        }

        const transactions = await Transaction.findAll(user_id);
        res.json(transactions);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Server error' });
    }
};

exports.createTransaction = async (req, res) => {
    try {
        const { amount, type, category, account, date, note } = req.body;
        const user_id = req.user ? req.user.id : req.body.user_id;

        if (!user_id || !amount || !type || !category || !account || !date) {
            return res.status(400).json({ error: 'Missing required fields' });
        }

        const transaction = await Transaction.create({
            user_id,
            amount,
            type,
            category,
            account,
            date,
            note,
        });
        res.status(201).json(transaction);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Server error' });
    }
};
