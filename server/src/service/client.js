import pg from 'pg';

import dotenv from "dotenv";

dotenv.config();

let pool;

if (process.env.NODE_ENV === "dev") {
  pool = new pg.Pool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    port: process.env.DB_PORT,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_DATABASE,
  });
} else {
  pool = new pg.Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: {
      rejectUnauthorized: false,
    },
  });
}

export default pool;
