import '../../models/user_model.dart';

class AuthState {

  final UserModel? user;
  final bool isLoading;
 final bool isInitialized;

  AuthState({
    this.user,
    this.isLoading = false,
    this.isInitialized = false
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    bool? isInitialized
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}