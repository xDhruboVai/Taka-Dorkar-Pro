# Backend Fraud Detection Setup

## Environment Variables Required

Add the following to your `backend/.env` file:

```
GEMINI_API_KEY=your_api_key_here
```

To get a free Gemini API key:
1. Visit: https://makersuite.google.com/app/apikey
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy and paste into `.env`

## Database Migration

Run the migration to create the spam_messages table:

```bash
cd backend
node create_spam_table.js
```

## API Endpoints

### POST /api/fraud/detect
Detect spam in an SMS message
```json
{
  "phoneNumber": "+8801234567890",
  "messageText": "আপনার ব্যাংক অ্যাকাউন্টে সমস্যা...",
  "mlPrediction": "smish",
  "mlConfidence": 0.95
}
```

### GET /api/fraud/messages
Get all detected spam messages
Query params: `limit`, `offset`, `unreadOnly`

### GET /api/fraud/stats
Get security statistics

### PATCH /api/fraud/messages/:id/read
Mark message as read

### PATCH /api/fraud/messages/:id/safe
Mark message as false positive

### DELETE /api/fraud/messages/:id
Delete a spam message
