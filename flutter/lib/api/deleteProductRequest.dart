import 'dart:convert';
import 'package:http/http.dart' as http;

class DeleteProductRequest {
  static Future<dynamic> deleteProduct(productId) async {
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
              deleteProduct(productId: "$productId")
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
