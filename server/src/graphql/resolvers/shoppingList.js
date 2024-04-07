import client from "../../service/client.js";
import bearerAuthenticator from "../../middlewares/isAuth.js";

export async function createShoppingListResolver(args, req) {
  const title = args.shoppingListInput.title;
  const amount = args.shoppingListInput.amount;
  const userId = args.shoppingListInput.user_id;
  const date = new Date().toDateString();

  try {
    const insertionResult = await new Promise((resolve, reject) => {
      const query = `INSERT INTO app.shopping_list (title, amount, date, user_id) VALUES ('${title}','${amount}','${date}', ${userId} ) RETURNING id;`;

      client.query(query, (err, result) => {
        if (err) reject(err);
        else resolve(result);
      });
    });

    if (insertionResult.rowCount > 0) {
      return insertionResult.rows[0].id;
    } else {
      return "Error creating shopping list";
    }
  } catch (error) {
    throw error;
  }
}

export async function getShoppingListResolver(args, req, res) {
  const userId = args.userId;
  try {
    await new Promise((resolve, reject) => {
      bearerAuthenticator(req, res, (err) => {
        if (err) reject(err);
        else resolve();
      });
    });

    const shoppingLists = await getShoppingLists(userId);
    return shoppingLists;
  } catch (error) {
    console.error("Error fetching shopping lists:", error);
    throw error;
  }
}

async function getShoppingLists(userId) {
  try {
    const queryResult = await new Promise((resolve, reject) => {
      const query = `
        SELECT *
        FROM app.shopping_list
        LEFT JOIN app.product ON shopping_list.id = product.shopping_list_id
        WHERE shopping_list.user_id = ${userId}
      `;

      client.query(query, (err, result) => {
        if (err) reject(err);
        else resolve(result);
      });
    });

    if (queryResult.rowCount > 0) {
      const shoppingListsMap = new Map();

      queryResult.rows.forEach((row) => {
        const {
          id,
          title,
          user_id,
          date,
          amount,
          product_id,
          price,
          quantity,
          shopping_list_id,
          product_title,
        } = row;

        if (!shoppingListsMap.has(id)) {
          shoppingListsMap.set(id, {
            _id: id,
            title: title,
            user_id: user_id,
            date: date,
            amount: amount,
            products: [],
          });
        }

        if (product_id) {
          shoppingListsMap.get(id).products.push({
            product_id: product_id,
            price: price,
            quantity: quantity,
            shopping_list_id: shopping_list_id,
            product_title: product_title,
          });
        }
      });

      const shoppingLists = Array.from(shoppingListsMap.values());

      return shoppingLists;
    } else {
      return [];
    }
  } catch (error) {
    throw error;
  }
}

export async function deleteShoppingListResolver(args, req) {
  const shopping_list_id = args.shoppingListId;
  const queryResult = await new Promise((resolve, reject) => {
    const query = `DELETE FROM app.shopping_list WHERE id = ${shopping_list_id}`;
    console.log(query);

    client.query(query, (err, result) => {
      if (err) reject(err);
      else resolve(result);
    });
  });

  const relatedProducts = await new Promise((resolve, reject) => {
    const query = `SELECT * FROM app.product WHERE shopping_list_id = ${shopping_list_id}`;

    client.query(query, (err, result) => {
      if (err) reject(err);
      else resolve(result);
    });
  });

  if (queryResult.rowCount > 0) {
    if (relatedProducts.rowCount > 0) {
      const deleteProducts = await new Promise((resolve, reject) => {
        const deleteProductsQuery = `DELETE FROM app.product WHERE shopping_list_id = ${shopping_list_id}`;

        client.query(deleteProductsQuery, (err, result) => {
          if (err) reject(err);
          else resolve(result);
        });
      });
    }
    return "Shopping list deleted";
  } else return null;
}
