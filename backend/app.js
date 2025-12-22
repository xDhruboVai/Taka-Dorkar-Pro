const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
require('dotenv').config();

// MVC: Routes Import
const authRoutes = require('./routes/authRoutes');
const accountRoutes = require('./routes/accountRoutes');
const fraudDetectionRoutes = require('./routes/fraudDetectionRoutes');

const app = express();
const PORT = process.env.PORT || 5001;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

app.get('/', (req, res) => {
    res.json({ message: 'Taka Dorkar Pro Backend Running', architecture: 'MVC' });
});

app.use('/api/auth', authRoutes);
app.use('/api/accounts', accountRoutes);
app.use('/api/fraud', fraudDetectionRoutes);
app.use('/api/transactions', require('./routes/transactionRoutes'));
app.use('/api/budgets', require('./routes/budgetRoutes'));
app.use('/api/categories', require('./routes/categoryRoutes'));
app.use('/api/ai', require('./routes/aiRoutes'));

// Server Start
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});

module.exports = app;
