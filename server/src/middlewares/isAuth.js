import jwt from "jsonwebtoken";

export default (req, res, next) => {
  let token = "";
  if (!!req.get("Authorization")) {
    token = req.get("Authorization").split(" ")[1];
  }

  let decodedToken;
  try {
    decodedToken = jwt.verify(token, process.env.JWT_PRIVATE_KEY);
  } catch (err) {
    const error = new Error("Not authenticated");
    error.statusCode = 500;
    throw error;
  }

  if (!decodedToken) {
    const error = new Error("Not authenticated");
    error.statusCode = 401;
    throw error;
  }
  next();
};
