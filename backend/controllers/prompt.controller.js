const AIService = require("../services/ai.service");
const AppError = require("../utils/AppError");
const { Success } = require("../utils/Success");
require("dotenv").config()

//POST TO CREATE PROMPT
const ai = new AIService(process.env.GEMINI_API_KEY);
exports.createPrompt = async (req, res, next) => {
    const { event, weather, style } = req.body;
    console.log("User Calls")
    try {
        const response = await ai.analyze(req.files, { event, weather, style });
        Success(res,200,"Analyzed Image",JSON.parse(response))
    } catch (err) {
        return next(new AppError(err));
    }
};
