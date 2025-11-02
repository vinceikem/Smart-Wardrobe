/**
 * Returns a success object.
 * @param {number} status  - Status Code [Default=200].
 * @param {string} message - Success message.
 * @param {object} data - Any relevant object.
 * @returns {object} The success object.
 */

exports.Success = (res,status = 200, message, data ) => {
    return res.status(status).json({success:true,message,data})
};
