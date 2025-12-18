const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

app.get('/', (req, res) => {
    res.json({ message: 'Taka Dorkar Pro Backend Running', architecture: 'MVC' });
});

// Server Start
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});

module.exports = app;
