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

  // 🎥 Initialize Player
  void initPlayer() {
    videoController = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        chewieController = ChewieController(
          videoPlayerController: videoController,
          autoPlay: true,
        );
        setState(() {});
        startProgressTracking();
      });
  }

  // 📺 Load other videos
  void loadRelatedVideos() async {
    final videos = await VideoController.getVideos();
    setState(() {
      relatedVideos = videos.where((v) => v.id != widget.videoId).toList();
    });
  }

  // ⏱️ Track progress every 5 seconds
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
    return Scaffold(
      appBar: AppBar(title: Text("Now Playing")),
      body: Column(
        children: [
          // 🎥 BIG VIDEO PLAYER
          chewieController == null
              ? Container(
                height: 220,
                child: Center(child: CircularProgressIndicator()),
              )
              : Container(
                height: 220,
                child: Chewie(controller: chewieController!),
              ),

          // 📺 RELATED VIDEOS
          Expanded(
            child: ListView.builder(
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
