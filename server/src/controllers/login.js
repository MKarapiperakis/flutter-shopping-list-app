import client from "../service/client.js";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";

export const login = (req, res, next) => {
  const username = req.body.username;
  const password = req.body.password;

  const query = `SELECT * FROM app.users WHERE username = '${username}' `;
  client.query(query, (err, queryResult) => {
    console.log(queryResult.rows);
    if (!err && queryResult.rows.length > 0) {
      let storedHashedPassword = queryResult.rows[0].password;
      let plainPassword = password;
      bcrypt
        .compare(plainPassword, storedHashedPassword)
        .then((match) => {
          if (match) {
            const token = jwt.sign(
              {
                username: username,
                userId: queryResult.rows[0].id,
                role: queryResult.rows[0].role,
              },
              process.env.JWT_PRIVATE_KEY,
              { expiresIn: "30d" }
            );
            console.log(`token for user ${username} is: ${token}`);
            res.status(200).json({
              token: token,
              username: username,
              userId: queryResult.rows[0].id,
              role: queryResult.rows[0].role,
            });
          } else {
            res.status(500).json({
              error: "Incorrect password",
            });
          }
        })
        .catch((error) => {
          console.error(error);
        });
    } else {
      res.status(402).json({
        error: "User not found",
      });
    }
  });
};
