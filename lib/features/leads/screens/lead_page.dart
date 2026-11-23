import 'package:crm_app/features/leads/screens/leadtrack_page.dart';
import 'package:crm_app/features/outcome/screens/call_outcome_page.dart';
import 'package:crm_app/features/outcome/screens/meeting_outcome_page.dart';
import 'package:crm_app/widgets/common_header.dart';
import 'package:crm_app/widgets/customer_dailogbox_widget.dart';
import 'package:crm_app/widgets/dotted_line_widget.dart';
import 'package:crm_app/widgets/list_multiple_widget.dart';
import 'package:crm_app/features/leads/providers/lead_provider.dart';
import 'package:crm_app/features/leads/services/call_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color headerBlue = Color(0xFF1E4E8E);
const Color accentCyan = Color(0xFF00BCD4);
const Color buttonGreen = Color(0xFF4CAF50);

class LeadPage extends ConsumerStatefulWidget {
  const LeadPage({super.key});

  @override
  ConsumerState<LeadPage> createState() => _LeadPageState();
}

class _LeadPageState extends ConsumerState<LeadPage> {
  final TextEditingController _searchController = TextEditingController();
  // final _formKey = GlobalKey<FormState>();
  bool isSearch = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(leadProvider.notifier).loadLeads());
  }

  String _selectedTab = 'all';
  DateTime? _appliedFromDate;
  String _searchQuery = "";

  void _clearFilters() {
    setState(() {
      _appliedFromDate = null;
      _searchQuery = "";
      _searchController.clear();
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

    // 3. Refresh list if update was successful
    if (result == true) {
      await ref.read(leadProvider.notifier).loadLeads();
    }
  }

  @override
  Widget build(BuildContext context) {
    final leadState = ref.watch(leadProvider);

    return SafeArea(
      child: Column(
        children: [
          CommonHeader(
            title: "Lead List",
            searchController: _searchController,
            // Show clear button only if a date range OR search is active
            showClearButton:
                _appliedFromDate != null || _searchQuery.isNotEmpty,
            onClearTap: () {
              _clearFilters(); // Calls your existing reset function
            },
            onFilterTap: () => _showFilterModal(context),
            onSearchChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
              ref
                  .read(leadProvider.notifier)
                  .loadLeads(
                    status: _searchQuery == "" ? _selectedTab : null,
                    searchQuery: _searchQuery,
                  );
            },
          ),

          Expanded(
            child: Container(
              padding: const EdgeInsets.only(top: 10.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  // Tabs
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildTopTab("All", "all"),
                          const SizedBox(width: 25),
                          _buildTopTab("New", "new"),
                          const SizedBox(width: 25),
                          _buildTopTab("Attempt", "attempted"),
                          const SizedBox(width: 25),
                          _buildTopTab("Follow", "in_followup"),
                          const SizedBox(width: 25),
                          _buildTopTab("Closed", "close"),
                          const SizedBox(width: 25),
                          _buildTopTab("Lossed", "lost"),
                        ],
                      ),
                    ),
                  ),
                  DottedLine(height: 1, color: Colors.grey.shade400),
                  const SizedBox(height: 20),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        await ref.read(leadProvider.notifier).loadLeads();
                      },
                      child: leadState.isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: headerBlue,
                              ),
                            )
                          : leadState.leads.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(height: 300),
                                _buildEmptyState(),
                              ],
                            ) // Handle empty list case
                          : LeadListWidget(
                              items: leadState.leads
                                  .map(
                                    (lead) => {
                                      'id': lead.leadId,
                                      'name': lead.customerName,
                                      // 'project_id': lead.projectId,
                                      'customer_phone': lead.customerPhone,
                                      'marketingDate': lead.createdDate,
                                      'status': lead.leadStatus,
                                      'original_model': lead,
                                    },
                                  )
                                  .toList(),
                              icon: Icons.phone,
                              hasMore: leadState.hasMore,
                              isLoadingMore: leadState
                                  .isMoreLoading, // Pass the loading state
                              onLoadMore: () {
                                ref
                                    .read(leadProvider.notifier)
                                    .loadLeads(
                                      isLoadMore: true,
                                      status: _selectedTab,
                                      searchQuery: _searchQuery,
                                      selectedDate: _appliedFromDate
                                          ?.toIso8601String()
                                          .split('T')[0],
                                    );
                              },
                              onTap: (data) async {
                                final lead = data['original_model'];

                                await PhoneService.makeDirectPhoneCall(
                                  data['customer_phone'] ?? '',
                                  context,
                                );
                                await Future.delayed(
                                  const Duration(seconds: 1),
                                );
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
                                    onConfirm: () =>
                                        Navigator.pop(context, true),
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
                                                        leadId:
                                                            model.leadId ?? 0,
                                                        projectId:
                                                            model.projectId ??
                                                            0,
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
                                  lable: "lead info",
                                  icon: Icons.keyboard_arrow_right,
                                  color: Colors.blue,
                                  onTap: (data) {
                                    final customerName = data['name'];
                                    final leadId = data['id'];
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LeadtrackPage ( customerName, leadId,),
                                      ),
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
      ),
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
            "No leads found in this category",
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildTopTab(String label, String value) {
    final bool isSelected = _selectedTab == value;
    // final int bellowLine = value.length;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = value;
        });
        // ref.read(leadProvider.notifier).reset();
        ref
            .read(leadProvider.notifier)
            .loadLeads(status: _selectedTab, searchQuery: _searchQuery);
      },
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isSelected ? headerBlue : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterModal(BuildContext context) {
    DateTime? tempFrom = _appliedFromDate;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // Use setModalState for internal UI
            return Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Filter Leads",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  _buildDateField(
                    label: "Search date",
                    date: tempFrom,
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setModalState(() {
                          tempFrom = picked;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: headerBlue,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        // CRITICAL: Update the parent state
                        setState(() {
                          _appliedFromDate = tempFrom;
                        });

                        ref
                            .read(leadProvider.notifier)
                            .loadLeads(
                              status: _appliedFromDate != null
                                  ? null
                                  : _selectedTab,
                              searchQuery: _searchQuery,
                              selectedDate: _appliedFromDate != null
                                  ? _appliedFromDate!.toIso8601String().split(
                                      'T',
                                    )[0]
                                  : null,
                            );
                        Navigator.pop(context);
                      },
                      child: const Text("Apply Filters"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date == null ? label : "${date.day}-${date.month}-${date.year}",
              style: TextStyle(
                color: date == null ? Colors.grey : Colors.black,
              ),
            ),
            const Icon(Icons.calendar_today, size: 18),
          ],
        ),
      ),
    );
  }
}
