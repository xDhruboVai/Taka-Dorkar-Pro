const User = require('../models/User');
const Account = require('../models/Account');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

class AuthController {
    static async signup(req, res) {
        try {
            const { name, email, phone, password } = req.body;

            if (!name || !email || !password || !phone) {
                return res.status(400).json({ error: 'All fields are required' });
            }

            const existingUser = await User.findByEmail(email);
            if (existingUser) {
                return res.status(409).json({ error: 'User already exists' });
            }

            const salt = await bcrypt.genSalt(10);
            const hashedPassword = await bcrypt.hash(password, salt);

            const newUser = await User.create({
                name,
                email,
                phone,
                password: hashedPassword,
            });

            await Account.create({
                user_id: newUser.id,
                name: 'Personal Account',
                type: 'cash',
                balance: 0,
                currency: 'BDT',
                is_default: true,
            });

            const token = jwt.sign({ id: newUser.id, role: newUser.role }, process.env.JWT_SECRET || 'secret', {
                expiresIn: '7d',
            });

            res.status(201).json({ message: 'User registered successfully', user: newUser, token });
        } catch (error) {
            console.error(error);
            res.status(500).json({ error: 'Server error during signup' });
        }
    }

    static async login(req, res) {
        try {
            const { email, password } = req.body;

            if (!email || !password) {
                return res.status(400).json({ error: 'Email and password are required' });
            }

            const user = await User.findByEmail(email);
            if (!user) {
                return res.status(401).json({ error: 'Invalid credentials' });
            }

            const isMatch = await bcrypt.compare(password, user.password_hash);
            if (!isMatch) {
                return res.status(401).json({ error: 'Invalid credentials' });
            }

            const token = jwt.sign({ id: user.id, role: user.role }, process.env.JWT_SECRET || 'secret', {
                expiresIn: '7d',
            });

            delete user.password_hash;

            res.json({ message: 'Login successful', user, token });
        } catch (error) {
            console.error(error);
            res.status(500).json({ error: 'Server error during login' });
        }
    }
}

module.exports = AuthController;
