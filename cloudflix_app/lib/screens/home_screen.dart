import 'package:flutter/material.dart';
import '../controllers/video_controller.dart';
import '../models/video_model.dart';
import '../widgets/video_card.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Video> videos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadVideos();
  }

  void loadVideos() async {
    videos = await VideoController.getVideos();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("CloudFlix 🎬"), centerTitle: true),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  return VideoCard(video: videos[index]);
                },
              ),
    );
  }
}
