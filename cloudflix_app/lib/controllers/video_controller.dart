import 'dart:convert';
import '../models/video_model.dart';
import '../services/api_service.dart';

class VideoController {
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
    final response = await ApiService.get("/videos/s/play/$id");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
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
