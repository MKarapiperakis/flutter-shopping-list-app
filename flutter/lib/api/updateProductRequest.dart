import 'dart:convert';
import 'package:http/http.dart' as http;

class UpdateProductRequest {
  static Future<dynamic> updateProduct(
      {productId, title, price, quantity}) async {
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
            mutation {
              updateProduct(productInput: {
                product_id: "$productId",
                title: "${title ?? ''}",
                price: ${price ?? 0},
                quantity: ${quantity ?? 0}
              })
            }
          ''',
        }),
      );

      return jsonDecode(response.body);
    } catch (error) {
      throw 'Request error: $error';
    }
  }
}
