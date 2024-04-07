import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginRequest {
  static Future<dynamic> login(String username, String password) async {
    try {
      const host =
          'https://9bd0-2a02-587-8081-900-a54e-6f1a-21b3-bc5e.ngrok-free.app';
      const url = '$host/data/api/login';

      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        return null;
      }
    } catch (error) {
      throw 'Request error: $error';
    }
  }
}
