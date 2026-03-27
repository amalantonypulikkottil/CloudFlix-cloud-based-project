import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import '../controllers/video_controller.dart';
import '../models/video_model.dart';
import '../widgets/video_card.dart';

class VideoPlayerScreen extends StatefulWidget {
  final int videoId;
  final String videoUrl;
  final String thumbnailUrl;

  const VideoPlayerScreen({
    required this.videoId,
    required this.videoUrl,
    required this.thumbnailUrl,
  });

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController videoController;
  ChewieController? chewieController;

  List<Video> relatedVideos = [];

  Timer? progressTimer;

  @override
  void initState() {
    super.initState();
    initPlayer();
    loadRelatedVideos();
  }

  void initPlayer() async {
    await VideoController.getVideoStream(widget.videoId);

    videoController = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        chewieController = ChewieController(
          videoPlayerController: videoController,
          autoPlay: true,
          aspectRatio: 16 / 9,
          showControls: true,
        );
        setState(() {});
        startProgressTracking();
      });
  }

  void loadRelatedVideos() async {
    final videos = await VideoController.getVideos();
    setState(() {
      relatedVideos = videos.where((v) => v.id != widget.videoId).toList();
    });
  }

  void startProgressTracking() {
    progressTimer = Timer.periodic(Duration(seconds: 5), (_) async {
      if (!videoController.value.isInitialized) return;

      int current = videoController.value.position.inSeconds;
      int duration = videoController.value.duration.inSeconds;

      await VideoController.sendProgress(
        videoId: widget.videoId,
        progress: current,
        durationWatched: current,
      );
    });
  }

  @override
  void dispose() {
    progressTimer?.cancel();
    videoController.dispose();
    chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color darkBg = Color(0xFF141414);

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: darkBg,
        elevation: 0,
        title: const Text(
          "Now Playing",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Professional video player with proper aspect ratio
          chewieController == null
              ? Container(
                height: MediaQuery.of(context).size.height * 0.35,
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFFE50914)),
                ),
              )
              : Container(
                color: Colors.black,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Chewie(controller: chewieController!),
                ),
              ),

          // Related videos section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              children: [
                const Text(
                  "More like this",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Text(
                  "${relatedVideos.length} videos",
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ],
            ),
          ),

          Expanded(
            child:
                relatedVideos.isEmpty
                    ? const Center(
                      child: Text(
                        "No related videos yet",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: relatedVideos.length,
                      itemBuilder: (context, index) {
                        return VideoCard(video: relatedVideos[index]);
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
