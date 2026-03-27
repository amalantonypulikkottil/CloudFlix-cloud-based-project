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
            : Uri.decodeFull(video.thumbnailUrl!);

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
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1F1F1F),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with subtle play overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.network(
                    Uri.decodeFull(imageUrl),
                    height: 210,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 210,
                        color: const Color(0xFF2C2C2C),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFE50914),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 210,
                        color: Colors.grey[800],
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Play icon overlay (Netflix style)
                Positioned.fill(
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(14),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        size: 52,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Video info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    video.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.remove_red_eye,
                        size: 18,
                        color: Color(0xFFE50914),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "${video.views} views",
                        style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                      ),
                      const Spacer(),
                      // Optional duration badge if you ever add it
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
