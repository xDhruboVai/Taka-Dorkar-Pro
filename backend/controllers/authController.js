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

            const defaultAccounts = [
                { name: 'Wallet', parent_type: 'cash', balance: 0, is_default: true },
                { name: 'Bkash', parent_type: 'mobile_banking', balance: 0, is_default: true },
                { name: 'Nagad', parent_type: 'mobile_banking', balance: 0, is_default: true },
                { name: 'EBL', parent_type: 'bank', balance: 0, is_default: true },
                { name: 'Personal Savings', parent_type: 'savings', balance: 1000, is_default: true, include_in_savings: true },
            ];

            for (const acc of defaultAccounts) {
                await Account.create({
                    user_id: newUser.id,
                    name: acc.name,
                    type: acc.parent_type,
                    balance: acc.balance,
                    parent_type: acc.parent_type,
                    is_default: acc.is_default,
                    include_in_savings: acc.include_in_savings || false,
                    currency: 'BDT',
                });
            }

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
        console.log(`Login attempt for email: ${req.body?.email}`);
        try {
            const { email, password } = req.body;

            if (!email || !password) {
                console.log('Login failed: Email or password missing');
                return res.status(400).json({ error: 'Email and password are required' });
            }

            const user = await User.findByEmail(email);
            if (!user) {
                console.log(`Login failed: User not found for ${email}`);
                return res.status(401).json({ error: 'Invalid credentials' });
            }

            const isMatch = await bcrypt.compare(password, user.password_hash);
            if (!isMatch) {
                console.log(`Login failed: Password mismatch for ${email}`);
                return res.status(401).json({ error: 'Invalid credentials' });
            }

            const token = jwt.sign({ id: user.id, role: user.role }, process.env.JWT_SECRET || 'secret', {
                expiresIn: '7d',
            });

            const userResponse = {
                id: user.id,
                name: user.name,
                email: user.email,
                role: user.role,
            };

            const responsePayload = { message: 'Login successful', user: { ...userResponse }, token };
            console.log('Login successful, sending response payload');
            res.json(responsePayload);
        } catch (error) {
            console.error('Login error:', error);
            res.status(500).json({ error: 'Server error during login. Please try again later.' });
        }
    }
}

module.exports = AuthController;
