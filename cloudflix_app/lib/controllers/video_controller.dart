import 'dart:convert';
import 'package:cloudflix_app/services/auth_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

import '../models/video_model.dart';
import '../services/api_service.dart';
import 'dart:html' as html;

class VideoController {
  static Future<bool> uploadVideo({
    required String title,
    required String description,
  }) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result == null) return false;

    var file = result.files.single;

    return await ApiService.uploadVideo(
      endpoint: "/videos/s/upload",
      title: title,
      description: description,
      file: file,
    );
  }

  static Future<List<Video>> getVideos() async {
    final response = await ApiService.get("/videos/s");

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);

      return data
          .map((e) => Video.fromJson(e))
          .where(
            (video) =>
                video.videoUrl != null &&
                !video.videoUrl!.contains("undefined"),
          )
          .toList();
    } else {
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getVideoStream(int id) async {
    final token = await AuthService.getToken(); // 🔥 get token

    final response = await html.HttpRequest.request(
      "https://d2nj2h7rya12fv.cloudfront.net/videos/s/play/$id",
      method: "GET",
      withCredentials: true,
      requestHeaders: {"Authorization": "Bearer $token"},
    );

    if (response.status == 200) {
      return jsonDecode(response.responseText!);
    } else {
      print("Error: ${response.status} ${response.responseText}");
      return null;
    }
  }

  static Future<void> sendProgress({
    required int videoId,
    required int progress,
    required int durationWatched,
  }) async {
    await ApiService.post("/videos/watch/progress", {
      "videoId": videoId,
      "progress": progress,
      "durationWatched": durationWatched,
    });
  }
}
