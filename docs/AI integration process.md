# Implementation Plan - Gemini API Integration

## 1. Get Gemini API Key
To use the Gemini API, you need an API Key from Google AI Studio.

### **How to fetch the API Key:**
1.  Go to [Google AI Studio](https://aistudio.google.com/).
2.  Sign in with your Google Account.
3.  Click on **"Get API key"** in the top left sidebar.
4.  Click **"Create API key"**.
5.  Copy the generated key string.
6.  You will need to add this key to your backend `.env` file as `GEMINI_API_KEY`.

---

## 2. Backend Integration Plan

### **A. Environment Setup**
-   Update `backend/.env` to include `GEMINI_API_KEY=<your_key_here>`.

### **B. Controller (`backend/controllers/aiController.js`)**
-   Create a new controller to handle chat requests.
-   Initialize user model for Generative AI (`gemini-pro`).
-   **System Instruction (Prompt Engineering):**
    -   Configure the model to **ONLY** answer finance-related questions.
    -   Instruct it to refuse off-topic questions (e.g., "I am a finance assistant. I cannot help with...").
    -   Instruct it to use the provided user data context to answer personalized questions.

### **C. Route (`backend/routes/aiRoutes.js`)**
-   Define a POST route `/chat`.
-   Connect it to `aiController.chatWithGemini`.

### **D. App Registration (`backend/app.js`)**
-   Register the new route: `app.use('/api/ai', require('./routes/aiRoutes'));`.

---

## 3. Mobile App Integration Plan

### **A. Data Context (RAG)**
-   **Goal**: Provide local financial data to the AI.
-   **Method**: Before sending the user's message to the backend, the mobile app will fetch a summary of local data.
-   **Data to Fetch**:
    -   Recent Transactions (last 30 days).
    -   Account Balances.
    -   Current Month's Budgets.
-   **Implementation**: Add a helper in `BudgetController` or `AiController` to gather this JSON object.

### **B. UI Update (`AskAiView`)**
-   Update `_handleSend` to:
    1.  Show user message immediately.
    2.  Show "Thinking..." indicator.
    3.  Gather local data context.
    4.  Call Backend API: `POST /api/ai/chat` with `{ message: "...", context: { ... } }`.
    5.  Display Backend response.

---

## 4. Execution Steps
1.  **Backend**: Create Controller and Route.
2.  **Backend**: Update `app.js`.
3.  **Mobile**: Implement data gathering logic.
4.  **Mobile**: Connect UI to new API endpoint.

> **Note on Data Privacy**: We are sending local financial data to the backend to be processed by the AI. Ensure this aligns with your privacy policy.

---

## 5. Local Chat History Implementation

### **A. Database Schema (`local_database.dart`)**
-   **Table `ai_chat_sessions`**:
    -   `id` (TEXT PK)
    -   `user_id` (TEXT) - Ensures privacy/auth isolation.
    -   `title` (TEXT)
    -   `created_at` (TEXT)
    -   `updated_at` (TEXT)
-   **Table `ai_chat_messages`**:
    -   `id` (INTEGER PK AUTOINCREMENT)
    -   `session_id` (TEXT FK)
    -   `role` (TEXT) - 'user' or 'ai'
    -   `text` (TEXT)
    -   `created_at` (TEXT)

### **B. Database Logic**
-   `createChatSession(userId, title)`
-   `saveChatMessage(sessionId, role, text)`
-   `getUserChatSessions(userId)`
-   `getChatMessages(sessionId)`

### **C. UI Updates (`AskAiView`)**
-   **Top Right Dropdown**:
    -   Fetch sessions filtering by `currentUser.id`.
    -   On tap: Clear current messages, load messages from DB, set `currentSessionId`.
-   **Save on Exit**:
    -   Wrap `Scaffold` in `WillPopScope`.
    -   Check if messages > initial greeting.
    -   Show Dialog: "Save chat?" -> "Yes" (Prompt Title), "No" (Discard), "Cancel".
    -   If "Yes": Insert Session -> Insert Messages -> Pop.

---

## 6. Execution Steps
1.  **Backend**: Create Controller and Route. [DONE]
2.  **Backend**: Update `app.js`. [DONE]
3.  **Mobile**: Implement data gathering logic. [DONE]
4.  **Mobile**: Connect UI to new API endpoint. [DONE]
5.  **Mobile (History)**: Update `LocalDatabase` with new tables.
6.  **Mobile (History)**: Update `AskAiView` with Save/Load logic.


I have executed the AI integration!

Backend Changes:

Created backend/controllers/aiController.js logic to talk to Gemini and enforce finance-only rules.
The system prompt includes instructions to use the provided user data context.
Registered routes in backend/app.js.
Mobile Changes:

Updated LocalDatabase to fetch a "Financial Context" (last 30 days transactions, balances, budgets).
Updated AskAiView to:
Show "Thinking..."
Send the user message + financial context to the backend.
Display the real AI response.
Next Steps for You:

Restart the Backend: You need to restart the node server for the new routes to load (npm run dev or similar).
Add API Key: Ensure GEMINI_API_KEY is in your backend/.env file.
Test: Open the app, go to "Ask AI", and ask "How much did I spend on food this month?". It should use your local data to answer.

Verifying Gemini API Key
Verified API key is working with gemini-2.0-flash. Updating backend controller to use this model and cleaning up test scripts.


Great news! The API key is working.

I successfully connected to Gemini using the gemini-2.0-flash model.

I have updated your backend/controllers/aiController.js to use gemini-2.0-flash as well, so the app will use this verified model.

You are all set. Just remember to restart your backend (node app.js or npm run dev) for the changes to take effect. Then you can test the "Ask AI" feature in the mobile app.

