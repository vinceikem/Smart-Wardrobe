const express = require("express");
const requiresBody = require("../middleware/requiresBody");
const Upload = require("../utils/MulterConfig");
const { createPrompt } = require("../controllers/prompt.controller");
const promptRouter = express.Router();

promptRouter.post("/prompt",Upload.array("wardrobe",10),createPrompt);

module.exports = promptRouter;