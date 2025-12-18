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
## 🚀 Getting Started

### 1. Backend Setup (Express.js)

The backend is the heart of the application. It connects to the Supabase PostgreSQL database.

**Prerequisites:**
- Node.js installed.
- A `.env` file in the `backend/` directory with `DB_HOST`, `DB_USER`, `DB_PASSWORD` (See `env.example`).

**Steps:**
1.  Open a terminal.
2.  Navigate to the backend folder:
    ```bash
    cd backend
    ```
3.  Install dependencies:
    ```bash
    npm install
    ```
4.  **Run the server:**
    ```bash
    npm run dev
    ```
    *Do not run `node server.js`. The entry point is `app.js` managed by `nodemon`.*

### 2. Mobile App Setup (Flutter)

**Prerequisites:**
- Flutter SDK installed.
- Android Emulator running or Physical Device connected.

**Steps:**
1.  Open a **new** terminal.
2.  Navigate to the mobile folder:
    ```bash
    cd mobile
    ```
3.  Get dependencies:
    ```bash
    flutter pub get
    ```
4.  **Run the app:**
    ```bash
    flutter run
    ```

---

## 🛠 Troubleshooting

**Backend Connection Error:**
If you see `getaddrinfo ENOTFOUND`, your `DB_HOST` in `.env` is incorrect. Ensure you are using the correct Supabase Connection String (Transaction Pooler or Direct).

**Android Build Failure:**
Run `flutter clean` and then `flutter run` to look for specific errors.
**"Android License Status Unknown"**
*   Run: `flutter doctor --android-licenses` and accept all licenses by typing `y`.
