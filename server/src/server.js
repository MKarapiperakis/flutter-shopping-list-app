import express from "express";
import cors from "cors";
import swaggerUi from "swagger-ui-express";
import yaml from "yamljs";
import drRouter from "./routes/data-read.js";
import dwRouter from "./routes/data-write.js";
import OpenApiValidator from "express-openapi-validator";
import morgan from "morgan";
import { graphqlHTTP } from "express-graphql";
import schema from "./graphql/schema.js";
import resolvers from "./graphql/resolvers.js";
import { rateLimit } from "express-rate-limit";
const swaggerDocument = yaml.load("./swagger.yaml");
import {
  RestError,
  AuthError,
  BadRequestError,
  NotFoundError,
} from "./lib/errors.js";
import {
  bearerAuthenticator,
  basicAuthenticator,
} from "./middlewares/authenticator.js";
import dotenv from "dotenv";

dotenv.config();

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 100,
  standardHeaders: "draft-7",
  legacyHeaders: false,
});

const app = express()
  .use(cors())
  .use(express.json({ limit: "20MB" }))
  .use("/data/api/doc", swaggerUi.serve, swaggerUi.setup(swaggerDocument))
  .use(morgan("combined"))
  .use(limiter)
  .use(
    "/graphql",
    graphqlHTTP({
      schema: schema,
      rootValue: resolvers,
      graphiql: true,
    })
  );

export default async () => {
  app.use(
    OpenApiValidator.middleware({
      apiSpec: "./swagger.yaml",
      validateRequests: true,
      validateSecurity: {
        handlers: {
          BearerAuth: bearerAuthenticator,
          BasicAuth: basicAuthenticator,
        },
      },
    })
  );

  return app
    .use("/data/api", [drRouter, dwRouter])
    .use("*", (req, res, next) => next(new NotFoundError()))
    .use((err, req, res, next) => {
      const isOpenApi = !!err.errors;
      if (!isOpenApi) return next(err);
      switch (err.message) {
        case "not found":
          return next(new NotFoundError());
        default:
          if (!err.status || err.status === 400)
            return next(new BadRequestError(err.message));
          if (err.status === 401) return next(new AuthError(err.message));
          return next(err);
      }
    })
    .use((err, req, res, next) => {
      if (!(err instanceof RestError) && !err.status) {
        err.status = 500;
        err.statusDetail = "Internal Server Error";
      }
      res.status(err.status).send({
        error: true,
        status: err.status,
        statusDetail: err.statusDetail,
        type: err.name,
        message: err.message,
      });
      console.error("error: ", err);
    });
};
