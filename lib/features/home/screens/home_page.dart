import 'package:crm_app/features/auth/screens/login_page.dart';
import 'package:crm_app/features/home/screens/booked_page.dart';
import 'package:crm_app/features/leads/screens/lead_page.dart';
import 'package:crm_app/features/home/screens/dashboard_page.dart';
import 'package:crm_app/features/leads/screens/follow_up_page.dart';
import 'package:crm_app/features/home/screens/profile_page.dart';
import 'package:crm_app/features/leads/screens/meeting_page.dart';
import 'package:crm_app/features/outcome/screens/call_outcome_page.dart';
import 'package:crm_app/features/auth/providers/auth_provider.dart';
import 'package:crm_app/features/leads/providers/lead_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Colors
const Color headerBlue = Color.fromARGB(255, 8, 101, 222);
const Color accentCyan = Color(0xFF00BCD4);

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

//  with WidgetsBindingObserver
class _HomePageState extends ConsumerState<HomePage> {
  // int _index = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
     _checkPendingOutcome();
  }
Future<void> _checkPendingOutcome() async {
  final prefs = await SharedPreferences.getInstance();
  final pendingLeadId = prefs.getInt("pending_lead_id");

  if (pendingLeadId != null) {
    Future.microtask(() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CallOutcomePage(
            leadId: pendingLeadId,
          ),
        ),
      );
    });
  }
}
  @override
  void dispose() {
    super.dispose();
  }
   final List<Widget> _pages =  [
    DashboardPage(),
    LeadPage(),
    FollowUpPage(),
    MeetingPage(),
    ProfilePage(),
  ];
  @override
  Widget build(BuildContext context) {
  final index = ref.watch(navIndexProvider);
    // final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _scaffoldKey,
      appBar: index == 0 ? _buildCustomAppBar(context) : null,
      body: IndexedStack(
        index: index,
        children: _pages,
      ),
      backgroundColor: Colors.blue,
      endDrawer: index == 0
          ? Drawer(
              width: MediaQuery.of(context).size.width * 0.75,
              child: _buildAccountDrawer(context),
            )
          : null,

       bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,

        onTap: (newIndex) {
          ref.read(navIndexProvider.notifier).state = newIndex;
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: "Leads",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_walk),
            label: "FollowUp",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.handshake),
            label: "Meeting",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget _buildAccountDrawer(BuildContext context) {
    return Column(
      children: [
        // Profile Section (Top Circle Area)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          width: double.infinity,
          color: Colors.blue,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Avatar
              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.grey),
              ),

              // Active Badge (Above)
              Positioned(
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Active",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text("Profile"),
                onTap: () {
              
            ref.read(navIndexProvider.notifier).state = 4;
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.bookmark),
                title: const Text("Booked"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BookedPage()),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.description),
                title: const Text("Terms & Conditions"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.support_agent),
                title: const Text("Support"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              const Divider(),

              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showLogoutDialog(context);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final stateNotifier = ref.read(authProvider.notifier);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.pop(context);
                await stateNotifier.logout();
                if (!mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(), 
                  ),
                );
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  PreferredSizeWidget _buildCustomAppBar(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user?.userName.toUpperCase() ?? "",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          Text(
            user?.roleName.toString().toLowerCase() ?? "",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      // elevation: 2,
      leading: Builder(
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(5.0),
            child: GestureDetector(
              onTap: () {
                Scaffold.of(context).openEndDrawer();
              },
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[300],
                child: const Text("MA"),
              ),
            ),
          );
        },
      ),

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
              icon: const Icon(
                Icons.notifications,
                size: 24,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
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
    );
  }

  // Widget _buildBottomNavigationBar(BuildContext context) {
  //   return BottomAppBar(
  //     // ✅ correct way
  //     shape: const CircularNotchedRectangle(),
  //     notchMargin: 1,
  //     color: const Color.fromARGB(255, 255, 255, 255),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceAround,
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: [
  //         _navItem(
  //           icon: Icons.home_sharp,
  //           isActive: _index == 0,
  //           onTap: () => setState(() => _index = 0),
  //         ),
  //         _navItem(
  //           icon: Icons.list_alt_outlined,
  //           isActive: _index == 1,
  //           onTap: () => setState(() => _index = 1),
  //         ),
  //         _navItem(
  //           icon: Icons.directions_walk_outlined,
  //           isActive: _index == 2,
  //           onTap: () => setState(() => _index = 2),
  //         ),
  //         _navItem(
  //           icon: Icons.handshake_outlined,
  //           isActive: _index == 3,
  //           onTap: () => setState(() => _index = 3),
  //         ),
  //         _navItem(
  //           icon: Icons.person_3_outlined,
  //           isActive: _index == 4,
  //           onTap: () => setState(() => _index = 4),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _navItem({
  //   required IconData icon,
  //   required bool isActive,
  //   required VoidCallback onTap,
  // }) {
  //   return InkWell(
  //     onTap: onTap,
  //     borderRadius: BorderRadius.circular(8),
  //     child: Container(
  //       padding: const EdgeInsets.all(10),
  //       decoration: BoxDecoration(
  //         color: isActive ? Colors.black : Colors.transparent,
  //         borderRadius: BorderRadius.circular(8),
  //       ),
  //       child: Icon(icon, color: isActive ? Colors.white : Colors.black),
  //     ),
  //   );
  // }
}
