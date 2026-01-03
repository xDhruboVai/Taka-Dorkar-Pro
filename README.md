# Taka Dorkar Pro

Simple setup to run the backend (Express) and mobile app (Flutter).

## Prerequisites
- Node.js (LTS)
- Flutter SDK
- Android Studio (emulator/device)
- PostgreSQL

## Quick Start

### Backend
```powershell
node backend/scripts/setup_python.js
cd backend
npm install
npm run dev
```
Create `backend/.env` (example):
```
DB_HOST=localhost
DB_USER=postgres
DB_PASSWORD=yourpassword
DB_NAME=taka_dorkar_pro
DB_PORT=5432
```

If using Security/Fraud Detection for the first time, create the table:
```powershell
cd backend
node create_spam_table.js
```

### Mobile
```powershell
cd mobile
flutter pub get
flutter run
```

## Notes
- See [backend/app.js](backend/app.js) for the server entrypoint.
- See [mobile/lib/views/analysis_view.dart](mobile/lib/views/analysis_view.dart) for analytics UI.
- Build and tool outputs are ignored via [.gitignore](.gitignore).
