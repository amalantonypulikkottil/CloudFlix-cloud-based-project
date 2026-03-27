import 'dart:convert';
import 'package:file_picker/file_picker.dart';
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

  static Future<bool> uploadVideo({
    required String endpoint,
    required String title,
    required String description,
    required PlatformFile file,
  }) async {
    final token = await AuthService.getToken();

    var request = http.MultipartRequest("POST", Uri.parse("$baseUrl$endpoint"));

    // 🔐 Auth header
    request.headers["Authorization"] = "Bearer $token";

    // 📦 Form fields
    request.fields["title"] = title;
    request.fields["description"] = description;

    // 🔥 Safe filename (remove spaces + normalize)
    final safeFileName = file.name
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'[^a-z0-9.\-_]'), '');

    // 🎬 Attach file (Web + Mobile support)
    if (file.bytes != null) {
      // 🌐 Web
      request.files.add(
        http.MultipartFile.fromBytes(
          "video",
          file.bytes!,
          filename: safeFileName,
        ),
      );
    } else {
      // 📱 Mobile
      request.files.add(
        await http.MultipartFile.fromPath(
          "video",
          file.path!,
          filename: safeFileName,
        ),
      );
    }

    // 🚀 Send request
    var response = await request.send();

    // ✅ Success check
    return response.statusCode == 200 || response.statusCode == 201;
  }
}
