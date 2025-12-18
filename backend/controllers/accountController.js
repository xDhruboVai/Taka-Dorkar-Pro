const Account = require('../models/Account');

class AccountController {
    static async getAccounts(req, res) {
        try {
            const accounts = await Account.findByUserId(req.user.id);
            res.json(accounts);
        } catch (error) {
            console.error(error);
            res.status(500).json({ error: 'Server error while fetching accounts' });
        }
    }

    static async createAccount(req, res) {
        try {
            const { name, type, balance, parent_type } = req.body;
            const user_id = req.user.id;

            if (!name || !type || !parent_type) {
                return res.status(400).json({ error: 'Name, type, and parent_type are required' });
            }

            const newAccount = await Account.create({
                user_id,
                name,
                type,
                balance: balance || 0,
                parent_type,
                currency: 'BDT',
            });

            res.status(201).json(newAccount);
        } catch (error) {
            console.error(error);
            res.status(500).json({ error: 'Server error while creating account' });
        }
    }

    static async updateAccount(req, res) {
        try {
            const { id } = req.params;
            const { name, balance } = req.body;

            const account = await Account.findById(id);

            if (!account) {
                return res.status(404).json({ error: 'Account not found' });
            }

            if (account.user_id.toString() !== req.user.id.toString()) {
                return res.status(403).json({ error: 'User not authorized to update this account' });
            }

            const updatedData = {};
            if (name) updatedData.name = name;
            if (balance !== undefined) updatedData.balance = balance;

            const updatedAccount = await Account.update(id, updatedData);

            res.json(updatedAccount);
        } catch (error) {
            console.error(error);
            res.status(500).json({ error: 'Server error while updating account' });
        }
    }

    static async deleteAccount(req, res) {
        try {
            const { id } = req.params;
            const account = await Account.findById(id);

            if (!account) {
                return res.status(404).json({ error: 'Account not found' });
            }

            if (account.user_id.toString() !== req.user.id.toString()) {
                return res.status(403).json({ error: 'User not authorized to delete this account' });
            }

            if (account.is_default) {
                return res.status(400).json({ error: 'Default accounts cannot be deleted' });
            }

            await Account.delete(id);

            res.status(204).send();
        } catch (error) {
            console.error(error);
            res.status(500).json({ error: 'Server error while deleting account' });
        }
    }
}

module.exports = AccountController;
