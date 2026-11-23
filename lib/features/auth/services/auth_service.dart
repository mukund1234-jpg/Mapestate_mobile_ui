import 'dart:io';

import 'package:crm_app/core/network/dio_client.dart';
import 'package:crm_app/features/auth/models/user_model.dart';
import 'package:flutter/material.dart';

class AuthService {
  Future<UserModel?> loginUser(String phone, String password) async {
    try {
      final response = await DioClient.dio.post(
        "/auth/login-user",
        data: {"phone_number": phone, "password": password},
      );
      debugPrint("FCM Token saved to backend ${response.data["user"]}");
      return UserModel.fromJson(response.data["user"]);
    } catch (e) {
      debugPrint("Login error: $e");
      return null;
    }
  }

  Future<void> saveFcmToken(int userId, String token) async {
    try {
      final response = await DioClient.dio.post(
        "/users/fcm_tokan_save",
        data: {
          "user_id": userId,
          "fcm_token": token,
          "device_type": Platform.isAndroid ? "android" : "ios",
        },
      );

      if (response.statusCode == 200) {
        debugPrint("FCM Token saved to backend");
      } else {
        debugPrint("Failed to save token: ${response.data}");
      }
    } catch (e) {
      debugPrint("Error calling saveFcmToken API: $e");
    }
  }
}
