import client from "../../service/client.js";
import bcrypt from "bcryptjs";
import validator from "validator";
import { BadRequestError } from "../../lib/errors.js";

export async function createUserResolver(args, req) {
  const username = args.userInput.username;
  const password = args.userInput.password;
  const firstName = args.userInput.firstName;
  const lastName = args.userInput.lastName;
  const email = args.userInput.email;

  const errors = [];
  if (!validator.isEmail(email)) {
    errors.push({ error: "invalid email" });
  }
  if (
    validator.isEmpty(password) ||
    !validator.isLength(password, { min: 8 })
  ) {
    errors.push({ error: "password too short" });
  }
  const query = `SELECT * FROM app.users WHERE username = '${username}' `;

  if (errors.length > 0) {
    throw new BadRequestError(JSON.stringify(errors));
  }

  try {
    const queryResult = await new Promise((resolve, reject) => {
      client.query(query, (err, result) => {
        if (err) reject(err);
        else resolve(result);
      });
    });

    console.log(query);
    if (queryResult.rows.length > 0) {
      throw new Error("User already exists");
    } else {
      const hashedPw = await bcrypt.hash(password, 12);
      const insertQuery = `INSERT INTO app.users (username, first_name, last_name, email, password) VALUES ('${username}','${firstName}','${lastName}','${email}','${hashedPw}' ) RETURNING id;`;

      const insertionResult = await new Promise((resolve, reject) => {
        client.query(insertQuery, (err, result) => {
          if (err) reject(err);
          else resolve(result);
        });
      });

      if (insertionResult.rowCount > 0) {
        console.log("User created successfully");
        return insertionResult.rows[0].id;
      } else {
        console.log("Error creating user");
        return "Error creating user";
      }
    }
  } catch (error) {
    console.error("Error in createUser resolver:", error);
    throw error;
  }
}
