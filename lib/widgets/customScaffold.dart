import 'package:flutter/material.dart';

class CustomScaffoldMessager  {
  final String title;
  final Widget body;

  const CustomScaffoldMessager({ required this.title, required this.body});

 void showCustomSnackBar(BuildContext context, String title) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(title),
    ),
  );
}
  }
