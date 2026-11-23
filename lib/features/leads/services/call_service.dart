// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';

// class PhoneService {
//   static Future<void> makePhoneCall(String phoneNumber) async {
//     debugPrint(" this is phone number == $phoneNumber");
//     final Uri phoneUri = Uri(
//       scheme: 'tel',
//       path: phoneNumber,
//     );

//     if (await canLaunchUrl(phoneUri)) {
//       await launchUrl(phoneUri);
//     } else {
//       throw 'Could not launch $phoneUri';
//     }
//   }
// }

// import 'package:url_launcher/url_launcher.dart';

// class PhoneService {
//   static Future<void> makePhoneCall(String phoneNumber) async {

//     final Uri phoneUri = Uri.parse("tel:$phoneNumber");

//     if (!await launchUrl(phoneUri)) {
//       throw Exception("Could not launch $phoneNumber");
//     }

//   }
// }
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

class PhoneService {
  static Future<void> makeDirectPhoneCall(String phoneNumber, BuildContext context) async {
    try {
      // 1. Check Permission
      var status = await Permission.phone.status;

      if (status.isGranted) {
        await _executeCall(phoneNumber, context);
      } else if (status.isDenied) {
        if (await Permission.phone.request().isGranted) {
          await _executeCall(phoneNumber, context);
        }
      } else if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
    } catch (e) {
      _showError(context, "An unexpected error occurred: $e");
    }
  }

  static Future<void> _executeCall(String phoneNumber, BuildContext context) async {
    final String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    
    if (cleanNumber.isEmpty) {
      _showError(context, "Invalid phone number.");
      return;
    }

    // Attempt the call
    bool? res = await FlutterPhoneDirectCaller.callNumber(cleanNumber);

    // 2. Handle SIM/Service failure
    if (res == null || res == false) {
      _showError(
        context, 
        "Could not place call. Please check if a SIM card is active or Airplane mode is off."
      );
    }
  }

  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}