const { GoogleGenerativeAI } = require('@google/generative-ai');
require('dotenv').config();

async function testGemini() {
    const apiKey = process.env.GEMINI_API_KEY;
    if (!apiKey) {
        console.error('ERROR: GEMINI_API_KEY is not set in .env');
        process.exit(1);
    }

    try {
        const genAI = new GoogleGenerativeAI(apiKey);
        const model = genAI.getGenerativeModel({ model: "gemini-2.0-flash" });

        console.log('Sending test prompt to Gemini (gemini-2.0-flash)...');
        const result = await model.generateContent("Say 'Hello' if you can hear me.");
        const response = await result.response;
        const text = response.text();

        console.log('SUCCESS: Gemini responded:', text);
    } catch (error) {
        console.error('FAILURE: API check failed.');
        console.error('Error details:', error.message);
        process.exit(1);
    }
}

testGemini();
