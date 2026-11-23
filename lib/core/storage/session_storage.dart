import 'dart:convert';

import 'package:crm_app/features/auth/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionStorage {
  static const String userKey = "USER_SESSION";

  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();

    final jsonData = jsonEncode({
      "user_type": user.userType,
      "user_id": user.userId,
      "user_name": user.userName,
      "email": user.email,
      "phone_number": user.phoneNumber,
      "organization_id": user.organizationId,
      "role_id": user.roleId,
      "role_name": user.roleName,
    });

    await prefs.setString(userKey, jsonData);
  }

  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(userKey);

    if (data == null) {
      return null;
    }

    final jsonData = jsonDecode(data) as Map<String, dynamic>;

    return UserModel.fromJson(jsonData);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(userKey);
  }
}
