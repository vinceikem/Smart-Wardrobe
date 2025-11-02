const AIService = require("../services/ai.service");
const AppError = require("../utils/AppError");
require("dotenv").config()

//POST TO CREATE PROMPT
const ai = new AIService(process.env.GEMINI_API_KEY);
exports.createPrompt = async (req, res, next) => {
    const { event, weather, style } = req.body;
    try {
        const response = await ai.analyze(req.files, { event, weather, style });
        res.status(200).json(JSON.parse(response));
    } catch (err) {
        return next(new AppError(err));
    }
};
