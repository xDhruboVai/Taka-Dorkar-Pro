const express = require('express');
const router = express.Router();
const AccountController = require('../controllers/accountController');
const authMiddleware = require('../middleware/authMiddleware');

router.use(authMiddleware);

router.get('/', AccountController.getAccounts);
router.post('/', AccountController.createAccount);
router.put('/:id', AccountController.updateAccount);
router.delete('/:id', AccountController.deleteAccount);

module.exports = router;
