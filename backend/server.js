const express = require("express");
const errorHandler = require("./middleware/errorHandler");
const promptRouter = require("./routes/prompt.route");
const app = express();
app.use(express.json());
app.use("/v1/api",promptRouter);
app.get("/", (req, res) => {
    res.json({ success: true, message: "HOME" });
});

app.get("/health",(req,res)=>{
    const uptimeSeconds = process.uptime();
  const uptimeFormatted = new Date(uptimeSeconds * 1000).toISOString().substr(11, 8);
    res.json({success:true,message:"Server Health Check",data:{status:"OK",uptime:uptimeFormatted}})
})



app.use(errorHandler);
app.listen(3000, () => {
    console.log("Server listening on port 3000");
});
