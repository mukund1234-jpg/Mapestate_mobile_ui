class ProjectModel {
  final int projectId;
  final String projectName;

  ProjectModel({required this.projectId, required this.projectName});

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      projectId: json['project_id'] ?? 0,
      projectName: json['project_name'] ?? '',
    );
  }
}




class UserFetchModel {
  final int userId;
  final String username;

  UserFetchModel({required this.userId, required this.username});

  factory UserFetchModel.fromJson(Map<String, dynamic> json) {
    return UserFetchModel(
      userId: json['user_id'] ?? 0,
      username: json['user_name'] ?? '',
    );
  }
}