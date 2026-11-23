import 'package:crm_app/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const Color headerBlue = Color(0xFF1E4E8E);
const Color accentCyan = Color(0xFF00BCD4);
const Color buttonGreen = Color(0xFF4CAF50);

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final TextEditingController leadController = TextEditingController();

  bool isSearch = false;
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile Info",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              height: 35,
              width: 35,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                padding: const EdgeInsets.all(5.0),
                icon: const Icon(Icons.edit, size: 24, color: Colors.white),
                onPressed: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (_) => const NotificationPage(),
                  //   ),
                  // );
                },
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.blue,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.grey.shade200,
                    ),

                    const SizedBox(height: 30),

                    _field("Username", user?.userName.toUpperCase() ?? ""),
                    const SizedBox(height: 10),

                    _field("Email", user?.email ?? ""),
                    const SizedBox(height: 10),

                    _field("Phone", user?.phoneNumber ?? ""),
                    const SizedBox(height: 10),

                    _field("Role Name", user?.roleName.toString().toUpperCase() ?? ""),

                    // const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, String value) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      enableInteractiveSelection: false,
      decoration: InputDecoration(
        labelText: label, // 🔥 Label inside box
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue.shade300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
    );
  }
}
