const express = require("express");
const errorHandler = require("./middleware/errorHandler");
const app = express();
app.use(express.json());

app.get("/", (req, res) => {
    res.json({ success: true, message: "HOME" });
});

app.use(errorHandler);
app.listen(3000, () => {
    console.log("Server listening on port 3000");
});
