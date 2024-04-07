import { createUserResolver } from "./resolvers/createUser.js";
import {
  createShoppingListResolver,
  deleteShoppingListResolver,
  getShoppingListResolver,
} from "./resolvers/ShoppingList.js";
import {
  createProductResolver,
  deleteProductResolver,
  getProcuctResolver,
  updateProductResolver,
} from "./resolvers/product.js";
import { getUserResolver } from "./resolvers/getUser.js";

export default {
  createUser: createUserResolver,
  createShoppingList: createShoppingListResolver,
  getShoppingList: getShoppingListResolver,
  createProduct: createProductResolver,
  getProduct: getProcuctResolver,
  deleteProduct: deleteProductResolver,
  deleteShoppingList: deleteShoppingListResolver,
  updateProduct: updateProductResolver,
  getUser: getUserResolver,
};
