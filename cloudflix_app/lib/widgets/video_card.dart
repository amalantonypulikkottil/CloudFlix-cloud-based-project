import 'package:cloudflix_app/controllers/video_controller.dart';
import 'package:flutter/material.dart';
import '../models/video_model.dart';
import '../screens/video_player_screen.dart';

class VideoCard extends StatelessWidget {
  final Video video;

  const VideoCard({required this.video});

  @override
  Widget build(BuildContext context) {
    String imageUrl =
        (video.thumbnailUrl == null ||
                video.thumbnailUrl!.contains("undefined"))
            ? "https://via.placeholder.com/300x200.png?text=No+Thumbnail"
            : video.thumbnailUrl!;

    return GestureDetector(
      onTap: () async {
        final data = await VideoController.getVideoStream(video.id);

        if (data == null) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => VideoPlayerScreen(
                  videoId: video.id,
                  videoUrl: data["videoUrl"],
                  thumbnailUrl: data["thumbnailUrl"],
                ),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.network(
                imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            // Info
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 5),

                  Text(
                    video.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 5),

                  Row(
                    children: [
                      Icon(Icons.remove_red_eye, size: 16),
                      SizedBox(width: 5),
                      Text("${video.views} views"),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
