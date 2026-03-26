import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class AuthController {
  static const String baseUrl = "http://localhost:4000";

  static Future<bool> register(
    String name,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "email": email, "password": password}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      String token = data["token"];

      // ✅ Save token globally
      await AuthService.saveToken(token);

      return true;
    } else {
      return false;
    }
  }
}
