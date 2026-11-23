import 'package:crm_app/core/storage/session_storage.dart';
import 'package:crm_app/features/auth/providers/states/auth_state.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

final authProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController();
});

class AuthController extends StateNotifier<AuthState> {
  AuthController() : super(AuthState()) {
    _init();
  }

  final AuthService _authService = AuthService();
  Future<void> _init() async {
    await checkLogin();
  }

  Future<bool> login(String phone, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _authService.loginUser(phone, password);
      if (user != null) {
        await SessionStorage.saveUser(user);
        state = state.copyWith(user: user, isLoading: false);
        await linkFcmTokenToUser();
        return true;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return false;
    }
    state = state.copyWith(isLoading: false);
    return false;
  }

  Future<void> linkFcmTokenToUser() async {
    final currentUser = state.user;
    if (currentUser == null) return;

    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      // 1. Store locally for backup
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);

      // 2. Push to Python Backend (Crucial)
      await _authService.saveFcmToken(currentUser.userId, token);
      debugPrint("FCM Token synced for User: ${currentUser.userId}");
    }
  }

  Future<void> checkLogin() async {
    await Future.delayed(const Duration(seconds: 2));
    final user = await SessionStorage.getUser();
    state = state.copyWith(user: user, isInitialized: true);
  }

  Future<void> logout() async {
    await SessionStorage.clearSession();
    state = AuthState(isInitialized: true);
  }
}
