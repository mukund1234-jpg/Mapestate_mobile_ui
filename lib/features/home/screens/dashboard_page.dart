import 'package:crm_app/features/leads/models/lead_model.dart';
import 'package:crm_app/features/home/screens/booked_page.dart';
import 'package:crm_app/features/outcome/screens/call_outcome_page.dart';
import 'package:crm_app/features/home/screens/lead_form_page.dart';
import 'package:crm_app/features/outcome/screens/meeting_outcome_page.dart';
import 'package:crm_app/widgets/customer_dailogbox_widget.dart';
import 'package:crm_app/widgets/dotted_line_widget.dart';
import 'package:crm_app/widgets/list_multiple_widget.dart';
import 'package:crm_app/widgets/trackingwidget.dart';
import 'package:crm_app/features/leads/providers/lead_provider.dart';
import 'package:crm_app/features/leads/services/call_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color headerBlue = Color(0xFF1E4E8E);
const Color accentCyan = Color(0xFF00BCD4);
const Color buttonGreen = Color(0xFF4CAF50);

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(leadProvider.notifier).loadTodayLeads();
      ref.read(leadProvider.notifier).loadDashboardCounts();
    });
  }

  Future<void> _navigateToCallOutcome(
    BuildContext context,
    dynamic lead,
  ) async {
    // 1. Save pending ID for crash recovery/tracking
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("pending_lead_id", lead.leadId);

    // 2. Navigate to Outcome Page
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallOutcomePage(
          leadId: lead.leadId,
          budget: lead.budget?.toString(),
          location: lead.location,
          interestLevel: lead.interestLevel,
          timeline: lead.timeline,
          bhk: lead.bhkConfigure,
          status: lead.leadStatus,
        ),
      ),
    );
    if (result == true) {
      await ref.read(leadProvider.notifier).loadTodayLeads();
    }
  }

  @override
  Widget build(BuildContext context) {
    final leadState = ref.watch(leadProvider);
    final counts = leadState.counts;
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusRow(
                  counts['new_leads_today'] ?? 0,
                  counts['followups_today'] ?? 0,
                  counts['meetings_today'] ?? 0,
                  counts['booked_today'] ?? 0,
                ),
                DottedLine(
                  height: 1,
                  dashWidth: 4,
                  dashSpace: 4,
                  color: Colors.grey.shade400,
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment
                        .spaceBetween, // Pushes icon to the far right
                    children: [
                      Text(
                        'Today Leads',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: headerBlue,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: headerBlue.withOpacity(0.2),
                          ),
                        ),

                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserLeadAddForm(),
                              ),
                            );
                          },
                          child: Icon(
                            Icons.person_add_alt_1_rounded,
                            color: headerBlue,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await ref.read(leadProvider.notifier).loadTodayLeads();
                      await ref
                          .read(leadProvider.notifier)
                          .loadDashboardCounts();
                    },
                    child: leadState.isTodayLoading
                        ? const Center(
                            child: CircularProgressIndicator(color: headerBlue),
                          )
                        : leadState.todayLeads.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(height: 300),
                              _buildEmptyState(),
                            ],
                          )
                        : LeadListWidget(
                            items: leadState.todayLeads.map((lead) {
                              return {
                                'id': lead.leadId,
                                'name': lead.customerName,
                                'customer_phone': lead.customerPhone,
                                'marketingDate': lead.createdDate,
                                'status': lead.leadStatus,
                                'original_model': lead,
                              };
                            }).toList(),
                            icon: Icons.phone,
                            onTap: (data) async {
                              // final String phone = data['customer_phone'];
                              final LeadFetchModel lead =
                                  data['original_model'];
                              await PhoneService.makeDirectPhoneCall(
                                data['customer_phone'] ?? '',
                                context,
                              );
                              await Future.delayed(const Duration(seconds: 1));
                              if (!context.mounted) return;
                              final callDone = await showDialog(
                                context: context,
                                builder: (context) => CustomModal(
                                  type: ModalType.success,
                                  title: "Call Completed",
                                  message:
                                      "The call record has been saved successfully.",
                                  primaryButtonText: "Done",
                                  secondaryButtonText: "Back",
                                  onConfirm: () => Navigator.pop(context, true),
                                ),
                              );

                              if (callDone == true) {
                                _navigateToCallOutcome(context, lead);
                              }
                            },
                            actions: [
                              LeadAction(
                                lable: "Manual",
                                icon: Icons.edit_note,
                                color: Colors.green,
                                onTap: (data) {
                                  final model = data['original_model'];
                                  
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text("Select Action"),
                                      content: const Text(
                                        "Would you like to log a Call Outcome or a Meeting?",
                                      ),
                                      actions: [
                                        // OPTION 1: Call Outcome
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(
                                              context,
                                            ); // Close dialog
                                            _navigateToCallOutcome(
                                              context,
                                              model,
                                            );
                                          },
                                          child: const Text(
                                            "Manual Call",
                                            style: TextStyle(
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),

                                        // OPTION 2: Meeting Outcome
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(
                                              context,
                                            ); // Close dialog
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    MeetingOutcomePage(
                                                      leadId: model.leadId ?? 0,
                                                      projectId:
                                                          model.projectId ?? 0,
                                                    ),
                                              ),
                                            );
                                          },
                                          child: const Text(
                                            "Complete Meeting",
                                            style: TextStyle(
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              LeadAction(
                                lable: "more",
                                icon: Icons.keyboard_arrow_right,
                                color: Colors.blue,
                                onTap: (data) {
                                  final int leadId = data['id'];
                                   final model = data['original_model'];
                                     final int projectId=  model.projectId ;
                                  LeadHistoryHelper.showOptions(
                                    context,
                                    ref,
                                    projectId,
                                    leadId,
                                    
                                  );
                                },
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 50, color: Colors.grey.shade400),
          const SizedBox(height: 10),
          Text(
            "No leads found ",
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(int pending, int complete, int canceled, int booked) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statusBox(
              "New",
              pending,
              Colors.orange,
              Icons.incomplete_circle,
              () {
                ref.read(navIndexProvider.notifier).state = 1;
              }, // 👈 LeadPage
            ),

            _statusBox(
              "follow",
              complete,
              Colors.green,
              Icons.check_circle_outline,
              () {
                ref.read(navIndexProvider.notifier).state = 2;
              }, // 👈 FollowUpPage
            ),

            _statusBox(
              "site visits",
              canceled,
              Colors.red,
              Icons.exit_to_app,
              () {
                ref.read(navIndexProvider.notifier).state = 3;
              }, // 👈 MeetingPage
            ),

            _statusBox(
              "booked",
              booked,
              Color.fromARGB(255, 41, 98, 223),
              Icons.book_online,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BookedPage()),
                );
              }, // or custom page
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBox(
    String title,
    int count,
    Color color,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                Text(
                  "$count",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
