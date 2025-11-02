const AppError = require("../utils/AppError")

const requiresBody = (req,res,next) => {
    if(!req.body || Object.keys(req.body) < 1){
        return next(new AppError("JSON body required",400))
    }
}