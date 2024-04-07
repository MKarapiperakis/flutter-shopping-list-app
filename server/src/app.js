import dotenv from 'dotenv';
dotenv.config();
import chalk from 'chalk';
import { createServer } from 'http';
import serverInit from './server.js';

const PORT = process.env.PORT || 3010;

const mainErrorHandler = (err) => console.error(err);
process.on("uncaughtException", mainErrorHandler);
process.on("unhandledRejection", mainErrorHandler);

serverInit().then((app) => {
  const server = createServer(app);

  server.listen(PORT, () => {
    console.log(
      "Up & running on http://localhost:" + chalk.blue.underline.bold(PORT)
    );
    console.log(
      "Swagger UI is available on http://localhost:" +
        chalk.blue.underline.bold(`${PORT}/data/api/doc`)
    );
    console.log(
      "GrahpQl UI is available on http://localhost:" +  chalk.blue.underline.bold(`${PORT}/graphql`)
       
    );
    
  });
});
