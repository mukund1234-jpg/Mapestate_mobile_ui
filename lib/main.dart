import 'package:crm_app/rootdecor_page.dart';
import 'package:crm_app/core/network/service/notification_core_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async{
    WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(
      _firebaseMessagingBackgroundHandler);

  await Firebase.initializeApp();
  runApp(ProviderScope(child: CrmApp()));
}

class CrmApp extends StatefulWidget {
  const CrmApp({super.key});

  @override
  State<CrmApp> createState() => _CrmAppState();
}

class _CrmAppState extends State<CrmApp> {
   @override
  void initState() {
    super.initState();
    NotificationService.initialize();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(textTheme: GoogleFonts.montserratTextTheme()),
      debugShowCheckedModeBanner: false,
      title: 'CRM App',
      home: const RootDecider(),
    );
  }
}
