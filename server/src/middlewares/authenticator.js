import jwt from "jsonwebtoken";
import { AuthError } from "../lib/errors.js";

const bearerAuthenticator = (req, scopes, schema) => {
  try {
    const token = req.header("Authorization").replace("Bearer ", "");
    req.jwtPayload = jwt.verify(token, process.env.JWT_PRIVATE_KEY);
    if (req.openapi.schema["x-acl"]) {
      const jwtScopes = new Set(req.jwtPayload.scopes);
      const reqScopes = new Set(req.openapi.schema["x-acl"]);
      const intersection = new Set(
        [...reqScopes].filter((x) => jwtScopes.has(x))
      );
      if (intersection.size > 0) return true;
      else throw new AuthError("Invalid Scopes");
    }
    return true;
  } catch (e) {
    throw new AuthError("Invalid Token");
  }
};

const basicAuthenticator = (req, scopes, schema) => {
  try {
    const header_basic_auth = (req.headers.authorization || "").split(" ")[1] || "";
    const [headerUsername, headerPassword] = Buffer.from(header_basic_auth, "base64")
      .toString()
      .split(":");

    const server_basic_auth = process.env.BASIC_AUTH;
    const [serverUsername, serverPassword] = Buffer.from(server_basic_auth, "base64")
      .toString()
      .split(":");

    
    // Verify login and password are set and correct
    if (headerUsername && headerPassword && headerUsername === serverUsername && headerPassword === serverPassword) {
      return true;
    } else throw new AuthError("Invalid Token");
  } catch (e) {
    throw new AuthError("Invalid Token");
  }
};

export{
  bearerAuthenticator,
  basicAuthenticator,
};
