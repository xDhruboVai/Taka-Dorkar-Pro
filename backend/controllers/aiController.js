const { GoogleGenerativeAI } = require('@google/generative-ai');
require('dotenv').config();

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const model = genAI.getGenerativeModel({ model: "gemini-2.0-flash" });

exports.chatWithGemini = async (req, res) => {
    try {
        const { message, context } = req.body;

        if (!message) {
            return res.status(400).json({ error: "Message is required" });
        }

        const systemInstruction = `
        You are Jordan Bhai, a helpful and knowledgeable financial assistant. 
        Your goal is to assist the user with their personal finances based on the provided data.
        
        RULES:
        1. Answer ONLY finance-related questions. If the user asks about anything else (e.g., sports, coding, general knowledge), politely refuse and say you only talk about money.
        2. Use the "User Financial Data" provided below to give specific, personalized answers.
        3. Be encouraging, friendly, and use the name "Jordan Bhai" if asked who you are.
        4. Keep answers concise and helpful.

        USER FINANCIAL DATA (JSON):
        ${JSON.stringify(context || {})}
        
        Now answer the user's question.
        `;

        const chat = model.startChat({
            history: [
                {
                    role: "user",
                    parts: [{ text: systemInstruction }],
                },
                {
                    role: "model",
                    parts: [{ text: "Understood. I am Jordan Bhai, ready to help with finances using the provided data." }],
                },
            ],
            generationConfig: {
                maxOutputTokens: 500,
            },
        });

        const result = await chat.sendMessage(message);
        const response = await result.response;
        const text = response.text();

        res.json({ reply: text });

    } catch (error) {
        console.error("Gemini API Error:", error);
        res.status(500).json({ error: "Failed to process request" });
    }
};
