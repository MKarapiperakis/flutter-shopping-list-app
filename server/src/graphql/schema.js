import { buildSchema } from "graphql";

export default buildSchema(`
type User {
    _id: ID!
    username: String!
    password: String
    email: String!
}

type ShoppingList {
    _id: ID!
    title: String
    user_id: Int!
    date: String
    amount: Float
    products: [Product!]!
}

type Product {
    product_id: ID!
    product_title: String!
    price: Float!
    quantity: Int!
    shopping_list_id: ID!
}

input ShoppingListInputData {
    title: String!
    amount: Float!
    user_id: ID!
}

input ProductInputData {
    title: String!
    price: Float!
    quantity: Int!
    shopping_list_id: ID!
}

input UpdateProductInputData {
    title: String
    price: Float
    quantity: Int
    product_id: ID
}

input UserInputData {
    username: String!
    password: String
    email: String!
}

type RootQuery {
    getShoppingList(userId: String): [ShoppingList!]!
    getProduct(shoppingListId: String): [Product!]!
    getUser(userInput: ID!): User
}

type RootMutation{
    createUser(userInput: UserInputData): String!
    createShoppingList(shoppingListInput: ShoppingListInputData): String!
    createProduct(productInput: ProductInputData): String!
    deleteShoppingList(shoppingListId: ID!): String
    deleteProduct(productId: ID!): String
    updateProduct(productInput: UpdateProductInputData): String
    
}

schema{
    query: RootQuery
    mutation: RootMutation
}
`);
