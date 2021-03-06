class Post {
  final String id;
  final String name;

  // 追加分
  final String imagePath;
  final String videoPath;
  final String createdAt;

  Post({
    this.id,
    this.name,
    this.imagePath,
    this.videoPath,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imagePath': imagePath,
      'videoPath': videoPath,
      'createdAt': createdAt,
    };
  }

  @override
  String toString() {
    return 'Post{id: $id, name: $name, imagePath: $imagePath, videoPath: $videoPath, createdAt: $createdAt}';
  }
}
