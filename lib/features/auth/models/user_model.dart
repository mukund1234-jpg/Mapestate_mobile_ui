class UserModel {
  final String userType;
  final int userId;
  final String userName;
  final String email;
  final int organizationId;
  final String phoneNumber;
  final int roleId;
  final String roleName;

  UserModel({
    required this.userType,
    required this.userId,
    required this.userName,
    required this.email,
    required this.organizationId,
    required this.phoneNumber,
    required this.roleId,
    required this.roleName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json["user_id"],
      userName: json["user_name"],
      organizationId: json["organization_id"],
      email: json["email"],
      phoneNumber: json["phone_number"],
      roleId: json["role_id"],
      roleName: json["role_name"],
      userType: json["user_type"],
    );
  }
}
