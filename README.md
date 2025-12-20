# Taka Dorkar Pro

**AI-Driven Finance & Business Management System with Local SMS Fraud Detection**

---

## ⚡ Quick Start (Windows)

### Prerequisites
- Node.js (LTS)
- Flutter SDK
- Android Studio with emulator
- PostgreSQL (or Supabase account)
- Python 3.10+ (Optional, for ML training)

---

## 🚀 Setup & Run

### 1. Backend Setup (Express.js)

Open **PowerShell/Command Prompt** and run:

```powershell
cd backend
npm install
```

Create a `.env` file in `backend/` with your database credentials:
```
DB_HOST=your_host
DB_USER=your_user
DB_PASSWORD=your_password
DB_NAME=taka_dorkar_pro
DB_PORT=5432
```

**Start the backend:**
```powershell
npm run dev
```

The server will run on `http://localhost:5001`

---

### 2. Security Backend (Fraud Detection) ⚠️

The security system needs the `spam_messages` table. Run this **once**:

```powershell
cd backend
node create_spam_table.js
```

This creates:
- `spam_messages` table with all fraud detection fields
- Indexes for performance
- Ready for SMS monitoring

**Only run this once!** After that, just use `npm run dev` to start the server.

---

### 3. Mobile Setup (Flutter)

Open **new PowerShell/Command Prompt** and run:

```powershell
cd mobile
flutter pub get
```

Start an emulator in Android Studio, then run:

```powershell
flutter run
```

**First launch:**
1. Grant SMS permissions when prompted
2. Grant notification permissions
3. Security tab will be ready to receive spam detections

---

## 🔒 Security Tab Features (New Hybrid System)

The app now uses a **Hybrid Detection Engine** that combines:
1.  **Local Heuristics (Offline)**: Instantly detects known threats using regex and keyword matching (English & Bangla).
2.  **Gemini AI (Online)**: Uses Google's Gemini API for deep context analysis and advanced anomaly detection.

**Features:**
- **Real-time SMS Detection**: Scans incoming messages instantly.
- **Threat Levels**: High, Medium, Low.
- **Dashboard**: View all detected spam, statistics, and AI confidence scores.
- **Manual Testing**: Test fraud detection with custom messages (bug icon in Security tab).

### How to Test Fraud Detection

1. Open the app and go to Security tab (drawer menu).
2. Click the **bug icon** (🐛) in top right.
3. Click "Load Test Message" to get a sample spam SMS.
4. Click "Test Now" to run detection.
5. Wait 2 seconds and see results appear in the list.

**Test Message (Bangla Spam):**
```
সোনালী ব্যাংক অ্যাকাউন্টে সমস্যা হয়েছে। কল করুন: +8801818788890
```
This will be detected as **HIGH** threat smishing attempt.

---

## 🧠 ML Training (Optional)

If you want to train your own custom models or explore the dataset:

1.  Navigate to the training folder:
    ```powershell
    cd ml_training
    ```
2.  Create a virtual environment:
    ```powershell
    python -m venv venv
    .\venv\Scripts\activate
    ```
3.  Install dependencies:
    ```powershell
    pip install -r requirements.txt
    ```
    *Note: TensorFlow requires Python < 3.12. If you are on Python 3.14, some ML scripts may not run, but the app's hybrid system works independently.*

---

## 📂 Project Structure

```
backend/
├── controllers/fraudDetectionController.js    # Spam detection API
├── routes/fraudDetectionRoutes.js             # Security endpoints
├── models/SpamMessage.js                      # Database model
├── create_spam_table.js                       # ⭐ Run once for security
└── .env                                       # Your API keys

mobile/
├── lib/
│   ├── views/security_view.dart               # Security dashboard
│   ├── controllers/security_controller.dart   # State management
│   ├── services/fraud_detection_service.dart  # Hybrid Detection Logic
│   ├── services/gemini_service.dart           # AI Integration
│   └── services/sms_monitor_service.dart      # SMS interception
└── assets/
    └── fraud_model.tflite                     # Legacy ML model (Fallback)

ml_training/
├── train_model.py                             # Model training script
├── test_model.py                              # Model testing script
└── requirements.txt                           # Python dependencies
```

---

## 🛠️ Common Commands

```powershell
# Backend
cd backend
npm run dev           # Start server
npm install           # Install dependencies

# Mobile  
cd mobile
flutter run           # Run on emulator/device
flutter clean         # Clean build cache
flutter pub get       # Install dependencies

# Security (one-time setup)
cd backend
node create_spam_table.js   # Create fraud detection table
```

---

## ❓ Troubleshooting

**Backend won't start?**
- Check `.env` file exists with all credentials
- Verify PostgreSQL is running
- Check port 5001 is available

**Mobile won't run?**
- Run `flutter clean` then `flutter pub get`
- Make sure Android emulator is running
- Check backend is running on localhost:5001

**SMS detection not working?**
- Grant SMS permissions in app
- Make sure backend is running
- Check Gemini API key is set in `.env` (for backend) and configured in app

**Security table error?**
- Run `node create_spam_table.js` in backend folder
- Only needs to be done once
- If error persists, check database connection
