import 'package:flutter/material.dart';

enum ModalType { success, warning, danger }

class CustomModal extends StatelessWidget {
  final String title;
  final String message;
  final String primaryButtonText;
  final String secondaryButtonText;
  final ModalType type;
  final VoidCallback onConfirm;

  const CustomModal({
    super.key,
    required this.title,
    required this.message,
    required this.primaryButtonText,
    required this.secondaryButtonText,
    required this.type,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    // Determine color and icon based on type
    Color primaryColor;
    IconData iconData;
    
    switch (type) {
      case ModalType.success:
        primaryColor = Colors.green;
        iconData = Icons.check_circle_outline;
        break;
      case ModalType.warning:
        primaryColor = Colors.orange;
        iconData = Icons.priority_high;
        break;
      case ModalType.danger:
        primaryColor = const Color(0xFFF04438); // Red from your image
        iconData = Icons.error_outline;
        break;
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with soft background circle
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: primaryColor, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                // Secondary (Cancel) Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(secondaryButtonText, style: const TextStyle(color: Colors.black54)),
                  ),
                ),
                const SizedBox(width: 12),
                // Primary Action Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(primaryButtonText, style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}