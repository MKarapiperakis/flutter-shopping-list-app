import client from "../../service/client.js";
export async function getUserResolver(args, req) {
  console.log(args);
  const userId = args.userInput;
  try {
    const queryResult = await new Promise((resolve, reject) => {
      const query = `SELECT * FROM app.users WHERE id = ${userId}`;

      client.query(query, (err, result) => {
        if (err) reject(err);
        else resolve(result);
      });
    });

    if (queryResult.rowCount > 0) {
      const user = {
        username: queryResult.rows[0].username,
        email: queryResult.rows[0].username,
      };

      console.log(user);

      return user;
    } else {
      return null;
    }
  } catch (error) {
    throw error;
  }
}
