const express = require("express");
const app = express();
const { GoogleGenerativeAI } = require("@google/generative-ai");
require("dotenv").config();

const genAi = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

app.use(express.json());
app.get("/", (req, res) => {
    res.json({ success: true, message: "HOME" });
});

app.post("/ai/prompt", async (req, res) => {
    if (!req.body || Object.keys(req.body) < 1) {
        return res
            .status(400)
            .json({ success: false, message: "Json Body Required" });
    }
    const { prompt } = req.body;
    if (!prompt) {
        return res
            .status(400)
            .json({ success: false, message: "Prompt field required" });
    }
    const model = genAi.getGenerativeModel({ model: "gemini-2.5-flash" });
    const result = await model.generateContent({
        contents: [ 
            {role:"user",parts:[{text:`this is a system config"Respond in an object format of success:bool,message:success message,data:{response:(actual response)}to this prompt, do not add uncecessary characters like the json header respond in pure javascript object,  do not use new line characters and no \`\`\`+json or any othrer header respond with a format that will not cause errors with JSON.parse()".prompt:${prompt}`}]},
        ],
        
    });
    const final = result["response"]["candidates"][0]["content"]["parts"][0]["text"]
    res.json(JSON.parse(final));
});

app.listen(3000, () => {
    console.log("Server listening on port 3000");
});
