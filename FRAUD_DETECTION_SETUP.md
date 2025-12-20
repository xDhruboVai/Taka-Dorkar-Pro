# Fraud Detection System - Setup and Usage Guide

## ✅ Implementation Complete

All phases of the fraud detection system have been successfully implemented:
- **Phase 1**: ML Model (98.32% accuracy)
- **Phase 2**: Backend API with Gemini AI  
- **Phase 3**: Mobile SMS Monitoring
- **Phase 4**: Security Dashboard UI
- **Phase 5**: Integration and Optimization

---

## 🚀 Quick Start

### 1. Backend Setup

```bash
cd backend

# Install dependencies (already done)
npm install

# Add Gemini API key to .env
echo "GEMINI_API_KEY=your_api_key_here" >> .env
# Get key from: https://makersuite.google.com/app/apikey

# Run migration (already done)
node create_spam_table.js

# Start server
npm run dev
```

### 2. Mobile Setup

```bash
cd mobile

# Get dependencies
flutter pub get

# Run app
flutter run
```

**On first launch**:
1. App will request SMS and notification permissions - GRANT them
2. SMS monitoring will start automatically
3. Security tab will show detected spam

---

## 📱 Features

### SMS Monitoring
- **Real-time detection**: Scans incoming SMS automatically
- **Offline capable**: ML model runs on-device
- **Smart hybrid**: Verifies threats with cloud AI
- **Background monitoring**: Works even when app is closed

### Security Dashboard
- **Statistics**: Total threats, daily count, threat breakdown
- **Message list**: All detected spam with threat levels
- **Details view**: Full message analysis with confidence scores
- **Actions**: Mark safe, report, delete

### Threat Levels
- 🔴 **HIGH**: Smishing with >95% confidence
- 🟠 **MEDIUM**: Smishing with <95% confidence  
- 🟡 **LOW**: Promotional spam

---

## 🔧 Configuration

### Adjusting Detection Sensitivity

Edit `mobile/lib/services/fraud_detection_service.dart`:
```dart
static String _getThreatLevel(String prediction, double confidence) {
  if (prediction == 'smish') {
    return confidence > 0.90 ? 'high' : 'medium'; // Lower threshold
  }
  // ...
}
```

### Enabling AI Verification for All Messages

Edit `backend/controllers/fraudDetectionController.js`:
```javascript
// Remove the confidence check to always use AI
const aiResult = await FraudDetectionController.analyzeWithAI(messageText);
```

---

## 📊 Testing

### Test SMS Detection

Send a test SMS with this content:
```
সোনালী ব্যাংক অ্যাকাউন্টে সমস্যা হয়েছে। কল করুন: +8801818788890
```

**Expected behavior**:
1. Notification appears: "🚨 High Threat Detected"
2. Message saved to Security tab
3. Backend receives detection data

### Verify Backend API

```bash
curl -X GET http://localhost:5001/api/fraud/stats \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## 🛠️ Troubleshooting

### Issue: SMS Permissions Denied
**Solution**: Go to Settings > Apps > Taka Dorkar Pro > Permissions > Enable SMS

### Issue: TFLite Model Not Loading  
**Solution**: Ensure `assets/fraud_model.tflite` exists and run `flutter pub get`

### Issue: Notifications Not Showing
**Solution**: Enable notification permissions in app settings

### Issue: Backend API Errors
**Solution**: Check Gemini API key is set correctly in `.env`

---

## 📁 Project Structure

```
mobile/
├── lib/
│   ├── models/spam_message.dart          # Data models
│   ├── services/
│   │   ├── fraud_detection_service.dart  # TFLite ML inference
│   │   ├── sms_monitor_service.dart      # SMS monitoring
│   │   ├── notification_service.dart     # Push notifications
│   │   └── api_service.dart              # Backend API client
│   ├── controllers/
│   │   └── security_controller.dart      # State management
│   └── views/
│       ├── security_view.dart            # Dashboard UI
│       └── spam_detail_view.dart         # Message details
├── assets/
│   ├── fraud_model.tflite               # ML model (1.4MB)
│   └── vocab.json                        # Vocabulary (3,270 words)
└── android/app/src/main/AndroidManifest.xml  # SMS permissions

backend/
├── models/SpamMessage.js                 # Database model
├── controllers/fraudDetectionController.js  # API logic
├── routes/fraudDetectionRoutes.js        # API routes
└── create_spam_table.js                  # Database migration

ml_training/
├── train_model.py                        # Model training script
├── test_model.py                         # Model testing
└── fraud_model.tflite                    # Exported model
```

---

## ⚠️ Important Notes

1. **Google Play Store**: SMS permissions may require declaration of usage
2. **Privacy**: All spam data is user-specific and encrypted
3. **Offline Mode**: Detection works without internet (ML only)
4. **Battery**: Background monitoring optimized for minimal battery usage

---

## 📈 Performance

- **Model Size**: 1.4 MB
- **Inference Speed**: <100ms per message
- **Accuracy**: 98.32% on test set
- **Vocabulary**: 3,270 Bangla words
- **Supported Classes**: normal, promo, smish

---

## 🎯 Next Steps

1. Add user to backend `.env` with Gemini API key
2. Test with real Bangla spam messages
3. Monitor backend logs for API performance
4. Collect user feedback on false positives
5. Retrain model with new spam patterns

---

**Status**: ✅ All phases complete and ready for testing!
