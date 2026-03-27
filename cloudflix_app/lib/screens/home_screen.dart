import 'package:cloudflix_app/services/api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../controllers/video_controller.dart';
import '../models/video_model.dart';
import '../widgets/video_card.dart';
import 'dart:html' as html;

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
    const Color darkBg = Color(0xFF141414);
    const Color primaryRed = Color(0xFFE50914);

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: darkBg,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.movie_creation, color: primaryRed, size: 32),
            const SizedBox(width: 8),
            Text(
              "CloudFlix",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {}, // Future profile menu (UI only)
            tooltip: "Profile",
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFE50914)),
              )
              : videos.isEmpty
              ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.movie_creation_outlined,
                      size: 80,
                      color: Colors.grey[700],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No videos yet",
                      style: TextStyle(fontSize: 20, color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Upload your first video to get started",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  return VideoCard(video: videos[index]);
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showUploadDialog();
        },
        backgroundColor: primaryRed,
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }

  void showUploadDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    PlatformFile? selectedFile;

    showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1F1F1F),
              title: const Text(
                "Upload New Video",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Title",
                      labelStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Color(0xFF2C2C2C),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Description",
                      labelStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Color(0xFF2C2C2C),
                    ),
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton.icon(
                    onPressed: () async {
                      if (kIsWeb) {
                        final uploadInput = html.FileUploadInputElement();
                        uploadInput.accept = 'video/*';
                        uploadInput.click();

                        uploadInput.onChange.listen((event) {
                          final file = uploadInput.files?.first;
                          if (file != null) {
                            final reader = html.FileReader();
                            reader.readAsArrayBuffer(file);
                            reader.onLoadEnd.listen((event) {
                              setDialogState(() {
                                selectedFile = PlatformFile(
                                  name: file.name,
                                  size: file.size,
                                  bytes: Uint8List.fromList(
                                    reader.result as List<int>,
                                  ),
                                );
                              });
                            });
                          }
                        });
                      } else {
                        FilePickerResult? result = await FilePicker.platform
                            .pickFiles(type: FileType.video);
                        if (result != null) {
                          setDialogState(() {
                            selectedFile = result.files.single;
                          });
                        }
                      }
                    },
                    icon: const Icon(Icons.video_file),
                    label: const Text("Choose Video File"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE50914),
                      foregroundColor: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 12),
                  if (selectedFile != null)
                    Text(
                      "✓ ${selectedFile!.name}",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.greenAccent,
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedFile == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please select a video")),
                      );
                      return;
                    }

                    Navigator.pop(context);

                    bool success = await ApiService.uploadVideo(
                      endpoint: "/videos/s/upload",
                      title: titleController.text,
                      description: descController.text,
                      file: selectedFile!,
                    );

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Upload successful")),
                      );

                      setState(() => isLoading = true);
                      loadVideos();
                    } else {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text("Upload failed")));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE50914),
                  ),
                  child: const Text("Upload to Cloud"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
