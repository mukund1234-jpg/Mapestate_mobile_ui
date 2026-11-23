class ProjectMedia {
  final int mediaId;
  final int projectId;
  final String title;
  final String mediaType;
  final String fileUrl;
  final String createdDate;

  ProjectMedia({
    required this.mediaId,
    required this.projectId,
    required this.title,
    required this.mediaType,
    required this.fileUrl,
    required this.createdDate,
  });

  factory ProjectMedia.fromJson(Map<String, dynamic> json) {
    return ProjectMedia(
      mediaId: json['media_id'],
      projectId: json['project_id'],
      title: json['title'],
      mediaType: json['media_type'],
      fileUrl: json['file_url'],
      createdDate: json['created_date'],
    );
  }
}