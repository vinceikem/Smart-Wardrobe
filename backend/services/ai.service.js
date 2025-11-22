const { GoogleGenAI, Type } = require("@google/genai");
const fs = require("fs");

class AIService {
    constructor(apiKey, model = "gemini-2.5-flash") {
        this.ai = new GoogleGenAI({ apiKey });
        this.model = model;
    }
    getIdFromFileName(fileName) {
        return fileName;
    }
    generativeImages(images) {
        const imageParts = [];
        for (const image of images) {
            imageParts.push({
                inlineData: {
                    data: fs.readFileSync(`${image.path}`).toString("base64"),
                    mimeType: image.mimetype,
                },
                id: this.getIdFromFileName(image.filename),
            });
        }
        return imageParts;
    }

    async generateContent(images, { style, event, weather }) {
        const content = [];
        for (const { id, inlineData } of this.generativeImages(images)) {
            const data = id.split('-');
            content.push({ text: `category:${data[0]}  id:${data[1]}` });
            content.push({ inlineData });
        }
        content.push({
            text: `Config: Style:${style},Event:${event},Weather:${weather} `,
        });
        return content
    }

    async analyze(
        images,
        config = { style: "none", event: "none", weather: "none" }
    ) {
        const result = await this.ai.models.generateContent({
            model: this.model,
            contents: await this.generateContent(images, config),
            config: {
                systemInstruction:
                    "You are a wardrobe matcher/analyzer picking the best combinations based on given parameters.Style,Event and Weather, each field optional. Suggest best combination by the ID Supplied in the prompt. Suggest polite tips to optimize the selection given like stain or crease detection etc. for only selected items. Do not mention ids in description use visual cues instead",
                responseMimeType: "application/json",
                responseJsonSchema: {
                    type: Type.OBJECT,
                    properties: {
                        top: {
                            type: Type.STRING,
                            description: "The best from all top id respond in the full id given including []",
                        },
                        bottom: {
                            type: Type.STRING,
                            description: "The best from all bottom id respond in the full id given including []",
                        },
                        response:{
                            type:Type.STRING,
                            description:"Short description on reason and confidence level"
                        }
                    },
                },
            },
        });
        return result["candidates"][0]["content"]["parts"][0]["text"];
    }
}

module.exports = AIService;
