import client from "../../service/client.js";
import bearerAuthenticator from "../../middlewares/isAuth.js";

export async function createProductResolver(args, req) {
  const title = args.productInput.title;
  const price = args.productInput.price;
  const quantity = args.productInput.quantity;
  const shoppingListId = args.productInput.shopping_list_id;

  try {
    const insertionResult = await new Promise((resolve, reject) => {
      const query = `INSERT INTO app.product (product_title, price, quantity, shopping_list_id) VALUES ('${title}', '${price}','${quantity}','${shoppingListId}' ) RETURNING product_id;`;
      console.log(query);
      client.query(query, (err, result) => {
        if (err) reject(err);
        else resolve(result);
      });
    });

    if (insertionResult.rowCount > 0) {
      return insertionResult.rows[0].product_id;
    } else {
      return "Error creating product";
    }
  } catch (error) {
    throw error;
  }
}

export async function getProcuctResolver(args, req, res) {
  const shopping_list_id = args.shoppingListId;
  try {
    await new Promise((resolve, reject) => {
      bearerAuthenticator(req, res, (err) => {
        if (err) reject(err);
        else resolve();
      });
    });

    const products = await getProducts(shopping_list_id);
    return products;
  } catch (error) {
    console.error("Error fetching products:", error);
    throw error;
  }
}

export async function getProducts(shopping_list_id) {
  try {
    const queryResult = await new Promise((resolve, reject) => {
      const query = `SELECT * FROM app.product WHERE shopping_list_id = ${shopping_list_id}`;

      client.query(query, (err, result) => {
        if (err) reject(err);
        else resolve(result);
      });
    });

    if (queryResult.rowCount > 0) {
      const products = queryResult.rows.map((row) => ({
        product_id: row.product_id,
        product_title: row.product_title,
        price: row.price,
        quantity: row.quantity,
        shopping_list_id: row.shopping_list_id,
      }));

      return products;
    } else {
      return [];
    }
  } catch (error) {
    throw error;
  }
}

export async function deleteProductResolver(args, req) {
  const product_id = args.productId;

  const queryResult = await new Promise((resolve, reject) => {
    const query = `DELETE FROM app.product WHERE product_id = ${product_id}`;

    client.query(query, (err, result) => {
      if (err) reject(err);
      else resolve(result);
    });
  });

  if (queryResult.rowCount > 0) return "deleted";
  else return null;
}

export async function updateProductResolver(args, req) {
  const { productInput } = args;
  const { product_id, title, price, quantity } = productInput;

  try {
    const updates = [];
    

    if (title !== undefined) {
      updates.push(`product_title = '${title}'`);
    }
    if (price !== undefined) {
      updates.push(`price = ${price}`);
    }
    if (quantity !== undefined) {
      updates.push(`quantity = ${quantity}`);
    }

    if (updates.length === 0) {
      throw new Error("No valid fields provided for update");
    }

    const query = `UPDATE app.product SET ${updates.join(
      ","
    )} WHERE product_id = ${product_id}`;
    console.log(query);
    const queryResult = await new Promise((resolve, reject) => {
      client.query(query, (err, result) => {
        if (err) reject(err);
        else resolve(result);
      });
    });

    if (queryResult.rowCount > 0) return "updated";
    else return null;
  } catch (error) {
    throw error;
  }
}
