const SpamMessage = require('../models/SpamMessage');
const { GoogleGenerativeAI } = require('@google/generative-ai');

// Initialize Gemini AI
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const model = genAI.getGenerativeModel({ model: 'gemini-pro' });

class FraudDetectionController {
    static async detectSpam(req, res) {
        try {
            const { phoneNumber, messageText, mlPrediction, mlConfidence } = req.body;
            const userId = req.user.id;

            if (!phoneNumber || !messageText) {
                return res.status(400).json({
                    error: 'Phone number and message text are required'
                });
            }

            let threatLevel = 'low';
            let detectionMethod = 'ml';
            let aiConfidence = null;
            let finalPrediction = mlPrediction || 'unknown';

            // Use AI for verification if confidence is low or smish detected
            if ((mlConfidence && mlConfidence < 0.85) || finalPrediction === 'smish') {
                try {
                    const aiResult = await FraudDetectionController.analyzeWithAI(messageText);
                    aiConfidence = aiResult.confidence;
                    detectionMethod = 'both';

                    // Update prediction if AI has different opinion
                    if (aiResult.isSpam) {
                        finalPrediction = 'smish';
                        threatLevel = aiResult.threatLevel;
                    }
                } catch (error) {
                    console.error('AI analysis failed:', error);
                    // Continue with ML prediction
                }
            }

            // Determine threat level based on prediction
            if (finalPrediction === 'smish') {
                threatLevel = mlConfidence > 0.95 ? 'high' : 'medium';
            } else if (finalPrediction === 'promo') {
                threatLevel = 'low';
            }

            // Save the spam message
            const spamMessage = await SpamMessage.create({
                user_id: userId,
                phone_number: phoneNumber,
                message_text: messageText,
                detection_method: detectionMethod,
                threat_level: threatLevel,
                ai_confidence: aiConfidence,
                ml_confidence: mlConfidence
            });

            res.status(201).json({
                success: true,
                data: spamMessage,
                prediction: finalPrediction
            });

        } catch (error) {
            console.error('Spam detection error:', error);
            res.status(500).json({ error: 'Failed to detect spam' });
        }
    }

    static async analyzeWithAI(messageText) {
        const prompt = `Analyze the following SMS message for fraud/smishing attempts. Return only a JSON object with these fields:
        
{
  "isSpam": boolean,
  "threatLevel": "low"|"medium"|"high",
  "confidence": 0.0-1.0,
  "reason": "brief explanation"
}

SMS Message (in Bangla): "${messageText}"

Look for:
- Requests for personal/banking information
- Fake prize/lottery notifications
- Urgent calls to action with threats
- Suspicious links or phone numbers
- Fake authority impersonation (bank, government)`;

        const result = await model.generateContent(prompt);
        const response = await result.response;
        const text = response.text();

        // Extract JSON from response
        const jsonMatch = text.match(/\{[\s\S]*\}/);
        if (jsonMatch) {
            return JSON.parse(jsonMatch[0]);
        }

        // Fallback
        return {
            isSpam: false,
            threatLevel: 'low',
            confidence: 0.5,
            reason: 'Unable to analyze'
        };
    }

    static async getDetectedMessages(req, res) {
        try {
            const userId = req.user.id;
            const { limit = 50, offset = 0, unreadOnly = false } = req.query;

            const messages = await SpamMessage.findByUserId(userId, {
                limit: parseInt(limit),
                offset: parseInt(offset),
                unreadOnly: unreadOnly === 'true'
            });

            res.json({
                success: true,
                data: messages,
                count: messages.length
            });

        } catch (error) {
            console.error('Get messages error:', error);
            res.status(500).json({ error: 'Failed to fetch messages' });
        }
    }

    static async markAsRead(req, res) {
        try {
            const userId = req.user.id;
            const { id } = req.params;

            const message = await SpamMessage.markAsRead(id, userId);

            if (!message) {
                return res.status(404).json({ error: 'Message not found' });
            }

            res.json({
                success: true,
                data: message
            });

        } catch (error) {
            console.error('Mark as read error:', error);
            res.status(500).json({ error: 'Failed to mark as read' });
        }
    }

    static async markAsSafe(req, res) {
        try {
            const userId = req.user.id;
            const { id } = req.params;

            const message = await SpamMessage.markAsFalsePositive(id, userId);

            if (!message) {
                return res.status(404).json({ error: 'Message not found' });
            }

            res.json({
                success: true,
                data: message
            });

        } catch (error) {
            console.error('Mark as safe error:', error);
            res.status(500).json({ error: 'Failed to mark as safe' });
        }
    }

    static async getSecurityStats(req, res) {
        try {
            const userId = req.user.id;

            const stats = await SpamMessage.getStats(userId);

            res.json({
                success: true,
                data: stats
            });

        } catch (error) {
            console.error('Get stats error:', error);
            res.status(500).json({ error: 'Failed to fetch statistics' });
        }
    }

    static async deleteMessage(req, res) {
        try {
            const userId = req.user.id;
            const { id } = req.params;

            const message = await SpamMessage.deleteById(id, userId);

            if (!message) {
                return res.status(404).json({ error: 'Message not found' });
            }

            res.json({
                success: true,
                message: 'Message deleted successfully'
            });

        } catch (error) {
            console.error('Delete message error:', error);
            res.status(500).json({ error: 'Failed to delete message' });
        }
    }
}

module.exports = FraudDetectionController;
