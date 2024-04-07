import 'dart:convert';
import 'package:http/http.dart' as http;

class GetShoppingListRequest {
  static Future<dynamic> getShoppingList(userId) async {
    try {
      const host =
          'https://9bd0-2a02-587-8081-900-a54e-6f1a-21b3-bc5e.ngrok-free.app';
      const url = '$host/graphql';

      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode({
          'query': '''
            query {
              getUser(userInput: "$userId") {
                _id
                title
                user_id
                date
                amount
                products {
                  product_id
                  product_title
                  price
                  quantity
                }
              }
            }
          ''',
        }),
      );

      return response.body;
    } catch (error) {
      throw 'Request error: $error';
    }
  }
}
