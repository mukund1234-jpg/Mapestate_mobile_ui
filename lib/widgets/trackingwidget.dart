import 'package:crm_app/features/leads/screens/share_doccument_page.dart';
import 'package:crm_app/features/leads/providers/lead_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LeadHistoryHelper {
  /// 1. SHOW QUICK ACTIONS DIALOG
  static void showOptions(
    BuildContext context,
    WidgetRef ref,
    int projectId,
    int leadId, {
    String? type,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Dismiss",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: const EdgeInsets.only(top: 80, left: 20, right: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Tracking Lead",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionItem(
                        icon: Icons.directions_walk_outlined,
                        color: Colors.blue,
                        label: "Follow-up",
                        onTap: () {
                          Navigator.pop(context); // Close Dialog
                          showTrackingHistory(context, ref, leadId, "followup");
                        },
                      ),
                      _buildActionItem(
                        icon: Icons.call,
                        color: Colors.orange,
                        label: "Call History",
                        onTap: () {
                          Navigator.pop(context); // Close Dialog
                          showTrackingHistory(context, ref, leadId, "call");
                        },
                      ),

                      _buildActionItem(
                        icon: Icons.share_outlined,
                        color: Colors.green,
                        label: "Share",
                        onTap: () {
                          Navigator.pop(context); // Close current modal
                          // Navigate to the new Share Media Page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ShareMediaPage(
                                projectId: projectId,
                                customerPhone: "8421132638",
                              ),
                            ),
                          );
                        },
                      ),
                      if (type == "meeting")
                        _buildActionItem(
                          icon: Icons.groups_outlined,
                          color: Colors.purple,
                          label: "Meeting",
                          onTap: () {
                            Navigator.pop(context);
                            // Replace with your actual meeting history function if needed
                            showTrackingHistory(
                              context,
                              ref,
                              leadId,
                              "meeting",
                            );
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(
            begin: const Offset(0, -1),
            end: const Offset(0, 0),
          ).animate(anim1),
          child: child,
        );
      },
    );
  }

  /// 2. SHOW TRACKING HISTORY BOTTOM SHEET
  static void showTrackingHistory(
    BuildContext context,
    WidgetRef ref,
    int leadId,
    String type,
  ) {
    ref.read(leadProvider.notifier).fetchTrackingHistory(leadId, type);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          expand: false,
          builder: (_, controller) {
            return Consumer(
              builder: (context, ref, child) {
                final state = ref.watch(leadProvider);

                if (state.isTrackLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = state.trackHistory;
                String title;
                IconData leadingIcon;
                Color themeColor;

                switch (type) {
                  case "meeting":
                    title = "Meeting History";
                    leadingIcon = Icons.groups_outlined;
                    themeColor = Colors.purple;
                    break;
                  case "followup":
                    title = "Follow-up History";
                    leadingIcon = Icons.history;
                    themeColor = Colors.blue;
                    break;
                  default: // 'call'
                    title = "Call History";
                    leadingIcon = Icons.call_received;
                    themeColor = Colors.orange;
                }

                return Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // List
                    Expanded(
                      child: data.isEmpty
                          ? const Center(child: Text("No records found"))
                          : ListView.builder(
                              controller: controller,
                              itemCount: data.length,
                              itemBuilder: (context, index) {
                                final item = data[index];
                                final statusColor = _getStatusColor(
                                  item.status,
                                );

                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: themeColor.withOpacity(
                                      0.1,
                                    ),
                                    child: Icon(leadingIcon, color: themeColor),
                                  ),
                                  title: Text(
                                    item.notes,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "${item.agent} • ${item.date}",
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      item.status.toUpperCase(),
                                      style: TextStyle(
                                        color: statusColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  static Widget _buildActionItem({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  static Color _getStatusColor(dynamic status) {
    String s = status.toString().toLowerCase();
    if (s.contains("completed") || s.contains("answered")) return Colors.green;
    if (s.contains("not") || s.contains("busy")) return Colors.red;
    return Colors.grey;
  }
}
