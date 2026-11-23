import 'package:crm_app/features/outcome/screens/meeting_outcome_page.dart';
import 'package:crm_app/widgets/common_header.dart';
import 'package:crm_app/widgets/dotted_line_widget.dart';
import 'package:crm_app/widgets/list_multiple_widget.dart';
import 'package:crm_app/widgets/trackingwidget.dart';
import 'package:crm_app/features/leads/providers/lead_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const Color headerBlue = Color(0xFF1E4E8E);
const Color accentCyan = Color(0xFF00BCD4);
const Color buttonGreen = Color(0xFF4CAF50);

class MeetingPage extends ConsumerStatefulWidget {
  const MeetingPage({super.key});

  @override
  ConsumerState<MeetingPage> createState() => _MeetingPageState();
}

class _MeetingPageState extends ConsumerState<MeetingPage> {
  final TextEditingController _searchController = TextEditingController();
  // final _formKey = GlobalKey<FormState>();
  bool isSearch = false;
  @override
  void dispose() {
    super.dispose();
  }

  String _selectedTab = 'all';
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(leadProvider.notifier).loadMeetingLeads());
  }

  DateTime? _appliedFromDate;
  String _searchQuery = "";
  @override
  Widget build(BuildContext context) {
    final leadState = ref.watch(leadProvider);
  
    return SafeArea(
      child: Column(
        // Change from Scaffold/Stack to a simple Column
        children: [
          CommonHeader(
            title: "Lead List",
            searchController: _searchController,
            // Show clear button only if a date range OR search is active
            showClearButton:
                _appliedFromDate != null || _searchQuery.isNotEmpty,
            onClearTap: () {
              _clearFilters(); 
            },
            onFilterTap: () => _showFilterModal(context),
            onSearchChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
               ref
                  .read(leadProvider.notifier)
                  .loadMeetingLeads(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                         _buildTopTab("All", "all"),
                        const SizedBox(width: 20),
                        _buildTopTab("Today", "daily"),
                        const SizedBox(width: 20),
                        _buildTopTab("Scheduled", "scheduled"),
                        const SizedBox(width: 20),
                        _buildTopTab("Completed", "completed"),
                      ],
                    ),
                  ),
                  DottedLine(height: 1, color: Colors.grey.shade400),
                  const SizedBox(height: 10),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                      await ref.read(leadProvider.notifier).loadMeetingLeads();
                    },
                      child: leadState.isMeetingLoading
                          ? const Center(
                              child: CircularProgressIndicator(color: headerBlue),
                            )
                          : leadState.meetingLeads.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(height: 300),
                                _buildEmptyState(),
                              ],
                            )
                          : LeadListWidget(
                              items: leadState.meetingLeads.map((lead) {
                                return {
                                  'id': lead.leadId,
                                  'name': lead.customerName,
                                  'marketingDate':
                                      lead.meetingDate,
                                  'status': lead.status,
                                  'project_id': lead.projectId ?? 0,
                                  'customer_phone': lead.customerPhone,
                                };
                              }).toList(),
                              icon: Icons.check,
                              hasMore: leadState.hasMore,
                              isLoadingMore:
                                  leadState.isMoreLoading, // Pass the loading state
                              onLoadMore: () {
                                ref
                                    .read(leadProvider.notifier)
                                    .loadMeetingLeads(
                                      isLoadMore: true,
                                      status: _selectedTab,
                                      searchQuery: _searchQuery,
                                      selectedDate: _appliedFromDate
                                          ?.toIso8601String()
                                          .split('T')[0],
                                    );
                              },
                              onTap: (data) {
                                // 1. PREVENT TAP IF COMPLETED
                                if (data['status'].toString().toLowerCase() ==
                                    'completed') {
                                  // Show a message or simply return to do nothing
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "This meeting is already completed",
                                      ),
                                    ),
                                  );
                                  return;
                                }
                    
                                // 2. NORMAL NAVIGATION
                                int leadId = data['id'];
                                int projectId = data['project_id'];
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MeetingOutcomePage(
                                      leadId: leadId,
                                      projectId: projectId,
                                    ),
                                  ),
                                );
                              },
                              actions: [
                                LeadAction(
                                  lable: "more",
                                  icon: Icons.keyboard_arrow_right,
                                  color: Colors.blue,
                                  onTap: (data) {
                                    final int leadId = data['id'];
                                    int projectId = data['project_id'];
                                    LeadHistoryHelper.showOptions(
                                      context,
                                      ref,
                                      projectId,
                                      leadId,
                                      type: "meeting",
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

  Widget _buildTopTab(String label, String value) {
    final bool isSelected = _selectedTab == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = value;
        });
         ref
            .read(leadProvider.notifier)
            .loadMeetingLeads(status: _selectedTab, searchQuery: _searchQuery);

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
          const SizedBox(height: 6),
          // Container(
          //   height: 3,
          //   width: 60,
          //   decoration: BoxDecoration(
          //     color: isSelected ? headerBlue : Colors.transparent,
          //     borderRadius: BorderRadius.circular(10),
          //   ),
          // )
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
            "No leads found ",
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  void _showFilterModal(BuildContext context) {
    // Use temporary local variables for the modal UI
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

                  // From Date Field
                  _buildDateField(
                    label: "From Date",
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
                  // APPLY BUTTON
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
                       
                        setState(() {
                          _appliedFromDate = tempFrom;
                        });
                        ref
                            .read(leadProvider.notifier)
                            .loadMeetingLeads(
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
                    const SizedBox(height: 15),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _clearFilters() {
    setState(() {
      _appliedFromDate = null;
      _searchQuery = "";
      _searchController.clear();
    });
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
