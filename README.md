# Taka Dorkar Pro

**AI-Driven Finance & Business Management System**

This repository contains the source code for Taka Dorkar Pro, a mobile application built with **Flutter** (Frontend) and **Express.js** (Backend)

---

## 🏗 Project Architecture (Strict MVC)

This project is mandated to follow the Model-View-Controller (MVC) pattern.

### 1. Mobile (Flutter)
Located in `mobile/`.
*   **Models (`mobile/lib/models`)**: Defines data structures (e.g., `Transaction`, `User`) and handles JSON serialization.
*   **Views (`mobile/lib/views`)**: UI components and screens. These **only** display data and capture user input. They contain NO business logic.
*   **Controllers (`mobile/lib/controllers`)**: Handle business logic, manage state, and communicate between the View and the Backend Services.

### 2. Backend (Express.js)
Located in `backend/`.
*   **Models (`backend/models`)**: Database schemas and direct SQL interactions.
*   **Controllers (`backend/controllers`)**: Request processing, validation, and business rules.
*   **Routes (`backend/routes`)**: API endpoints mapping URLs to Controllers.
*   **Views**: API JSON responses.

---

## 🚀 Setup Guide

### prerequisites
Ensure you have the following installed:
1.  **Node.js** (LTS Version)
2.  **Flutter SDK** (Latest Stable)
3.  **Android Studio** (with Android SDK & Command-line Tools)
4.  **PostgreSQL** (or access to a cloud instance like Supabase)

### 💻 1. Windows Setup
**Step 1: Environment Variables**
Ensure `flutter/bin` and `android/platform-tools` are in your System `PATH`.

**Step 2: Install Dependencies**
Open PowerShell/Command Prompt:
```powershell
# Backend
cd backend
npm install

# Mobile
cd ../mobile
flutter pub get
```

**Step 3: Run**
*   **Backend**: `cd backend` -> `npm run dev`
*   **Mobile**: Open Android Emulator via Android Studio, then `cd mobile` -> `flutter run`

---

### 🍎 2. Mac Setup
**Step 1: Environment Configuration**
Add these to your shell config (`~/.zshrc` or `~/.bash_profile`) to identify the Android SDK:
```bash
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
```
*Run `source ~/.zshrc` after saving.*

**Step 2: Install Dependencies**
Open Terminal:
```bash
# Backend
cd backend
npm install

# Mobile
cd ../mobile
flutter pub get
```

**Step 3: Run**
1.  **Start Backend**:
    ```bash
    cd backend
    npm run dev
    ```
2.  **Start Mobile**:
    *   List Emulators: `flutter emulators`
    *   Launch Emulator: `flutter emulators --launch <EMULATOR_ID>`
    *   Run App: `cd mobile` -> `flutter run`

---

## 🛠 Troubleshooting

**"Dependencies not found / Pub get failed"**
*   Run `flutter clean` inside the `mobile` folder.
*   Run `flutter pub get` again to re-fetch all packages.

**"Gradle task assembleDebug failed"**
*   This often happens on the first run if the internet is slow. Gradle is downloading the Android SDK/Tools.
*   **Fix**: Wait for it to finish (can take 10+ mins). If it fails, check your internet and try again.

**"Android License Status Unknown"**
*   Run: `flutter doctor --android-licenses` and accept all licenses by typing `y`.
