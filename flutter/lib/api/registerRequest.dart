import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterRequest {
  static Future<dynamic> register(
      String username, String password, String email) async {
    try {
      const host =
          'https://9bd0-2a02-587-8081-900-a54e-6f1a-21b3-bc5e.ngrok-free.app';
      const url = '$host/graphql';

      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'query': '''
            mutation {
              createUser(userInput: {
                username: "$username",
                password: "$password",
                email: "$email"
              })
            }
          ''',
        }),
      );

      if (response.statusCode == 200) {
        return response.statusCode;
      } else {
        final responseData = json.decode(response.body);
        final errors = responseData['errors'] as List<dynamic>;
        final errorMessages = errors.map((error) => error['message']).toList();

        if (errorMessages.contains('User already exists')) {
          return Future.error('User already exists');
          // return 'User already exists';
        } else {
          return null;
        }
      }
    } catch (error) {
      throw 'Request error: $error';
    }
  }
}
