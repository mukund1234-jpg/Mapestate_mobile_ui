import 'package:crm_app/features/auth/screens/login_page.dart';
import 'package:crm_app/features/home/screens/home_page.dart';
import 'package:crm_app/features/auth/providers/auth_provider.dart';
import 'package:crm_app/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class RootDecider extends ConsumerWidget {
  const RootDecider({super.key});

//   @override
  @override
  Widget build(BuildContext context ,WidgetRef ref) {
   final authState = ref.watch(authProvider);
    if (!authState.isInitialized) {
      return const SplashScreen(); 
    }
    if (authState.user != null) {
      return HomePage();
    } else {
      return LoginPage();
    }
  }
}
