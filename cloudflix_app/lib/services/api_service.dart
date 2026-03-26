import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = "http://localhost:4000"; // for emulator

  // Generic GET request
  static Future<http.Response> get(String endpoint) async {
    final token = await AuthService.getToken();

    return await http.get(
      Uri.parse("$baseUrl$endpoint"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
  }

  // Generic POST request
  static Future<http.Response> post(String endpoint, Map data) async {
    final token = await AuthService.getToken();

    return await http.post(
      Uri.parse("$baseUrl$endpoint"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(data),
    );
  }
}
