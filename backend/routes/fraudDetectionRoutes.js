const express = require('express');
const router = express.Router();
const fraudDetectionController = require('../controllers/fraudDetectionController');
const authMiddleware = require('../middleware/authMiddleware');

// All routes require authentication
router.use(authMiddleware);

// Detect spam message
router.post('/detect', fraudDetectionController.detectSpam);

// Get detected messages
router.get('/messages', fraudDetectionController.getDetectedMessages);

// Get specific message
router.get('/messages/:id', fraudDetectionController.getMessageById);

// Mark message as read
router.patch('/messages/:id/read', fraudDetectionController.markAsRead);

// Mark message as false positive (safe)
router.patch('/messages/:id/safe', fraudDetectionController.markAsSafe);

// Delete message
router.delete('/messages/:id', fraudDetectionController.deleteMessage);

// Get security statistics
router.get('/stats', fraudDetectionController.getSecurityStats);

module.exports = router;
