class Video {
  final int id;
  final String title;
  final String description;
  final String? videoUrl;
  final String? thumbnailUrl;
  final int views;

  Video({
    required this.id,
    required this.title,
    required this.description,
    this.videoUrl,
    this.thumbnailUrl,
    required this.views,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json["id"],
      title: json["title"] ?? "Untitled Video",
      description: json["description"] ?? "",
      videoUrl: json["videoUrl"],
      thumbnailUrl: json["thumbnailUrl"],
      views: json["views"] ?? 0,
    );
  }
}
