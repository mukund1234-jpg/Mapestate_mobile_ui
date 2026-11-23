import 'package:crm_app/features/leads/models/booking_update.dart';
import 'package:crm_app/widgets/list_multiple_widget.dart';
import 'package:crm_app/features/leads/providers/lead_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const Color headerBlue = Color(0xFF1E4E8E);
const Color buttonGreen = Color(0xFF4CAF50);

class BookedPage extends ConsumerStatefulWidget {
  const BookedPage({super.key});

  @override
  ConsumerState<BookedPage> createState() => _BookedPageState();
}

class _BookedPageState extends ConsumerState<BookedPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(leadProvider.notifier).loadbookedLeads());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text(
          "Booked Customer",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ExpandedSection(),
    );
  }
}

class ExpandedSection extends ConsumerWidget {
  const ExpandedSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leadState = ref.watch(leadProvider);
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Container(
        padding: const EdgeInsets.only(top: 10.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: RefreshIndicator(
                    onRefresh: () async {
                      await ref.read(leadProvider.notifier).loadbookedLeads();   
                    },
                child: leadState.isBookLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: headerBlue),
                      )
                    : leadState.bookedleads.isEmpty
                    ? _buildEmptyState()
                    : LeadListWidget(
                        items: leadState.bookedleads.map((lead) {
                          return {
                            'id': lead.leadId,
                            'name': lead.customerName,
                            'phone': lead.customerPhone,
                            'marketingDate': lead.createdDate,
                            'status': lead.leadStatus,
                          };
                        }).toList(),
                        actions: [
                          LeadAction(
                            lable: "booking details",
                            icon: Icons.keyboard_arrow_right,
                            color: Colors.blue,
                            onTap: (data) {
                              final int leadId = data['id'];
                              final String name = data['name'];
                              final String phone = data['phone'];
              
                              showBookingDetailsModal(
                                context,
                                ref,
                                leadId,
                                phone,
                                name,
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
    );
  }

 void showBookingDetailsModal(
    BuildContext context,
    WidgetRef ref,
    int leadId,
    String phone,
    String customerName,
  ) {
    ref.read(leadProvider.notifier).getBookingDetail(leadId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final state = ref.watch(leadProvider);
            final booking = state.bookingDeatail;

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              padding: EdgeInsets.only(
                left: 20, right: 20, top: 12, 
                bottom: MediaQuery.of(context).viewInsets.bottom + 30
              ),
              child: SingleChildScrollView( // Added scroll for smaller screens
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                    const SizedBox(height: 20),

                    // Header Section
                    Row(
                      children: [
                        CircleAvatar(backgroundColor: Colors.blue.shade50, child: const Icon(Icons.person, color: Colors.blue)),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(customerName.toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              Text(phone, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                            ],
                          ),
                        ),
                        _statusChip(booking?.leadStatus), // Using booking status instead
                      ],
                    ),
                    const Divider(height: 30),

                    if (state.isBookLoading)
                      const Center(child: Padding(padding: EdgeInsets.all(40.0), child: CircularProgressIndicator()))
                    else if (booking == null)
                      const Center(child: Padding(padding: EdgeInsets.all(40.0), child: Text("No booking details found.")))
                    else ...[
                      // 1. PROJECT DATA CARD
                      _buildDataCard(booking),

                      const SizedBox(height: 20),

                      // 2. BOOKING LIFECYCLE TRACKER (The "Table" visualization)
                      const Text("BOOKING PROGRESS", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: 12)),
                      const SizedBox(height: 10),
                      const Text("remark", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: 10)),
                       Text(booking.bookingRemark ?? "No Remark"),
                        const SizedBox(height: 10),
                      _buildLifecycleProgress(booking.leadStatus),

                      const SizedBox(height: 25),

                      // 3. ACTION BUTTON: Update Status
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () => _showUpdateStatusSheet(context, ref, leadId, booking.bookingId ?? 0, booking.leadStatus ?? "booked"),
                          icon: const Icon(Icons.edit_note, color: Colors.white),
                          label: const Text("UPDATE BOOKING STATUS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                     const SizedBox(height: 25),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
static Widget _buildLifecycleProgress(String? currentStatus) {
  final stages = ["INITIATED", "DOCUMENT_PENDING", "VERIFIED", "CONFIRMED"];
  int currentIndex = stages.indexOf(currentStatus ?? "INITIATED");

  return Row(
    children: List.generate(stages.length, (index) {
      bool isCompleted = index <= currentIndex;
      bool isLast = index == stages.length - 1;

      return Expanded(
        child: Row(
          children: [
            // Circle indicating the stage
            Column(
              children: [
                Icon(
                  isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isCompleted ? Colors.green : Colors.grey[300],
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  stages[index].split('_').first, // Shows "DOCUMENT" instead of "DOCUMENT_PENDING"
                  style: TextStyle(fontSize: 8, color: isCompleted ? Colors.black : Colors.grey),
                )
              ],
            ),
            // Line connecting to next stage
            if (!isLast)
              Expanded(
                child: Container(
                  height: 2,
                  color: isCompleted ? Colors.green : Colors.grey[300],
                ),
              ),
          ],
        ),
      );
    }),
  );
}
  // Modern Status Chip
  static Widget _statusChip(String? status) {
    if (status == null) return const SizedBox();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: status.toLowerCase() == 'booked' ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: status.toLowerCase() == 'booked' ? Colors.green.shade700 : Colors.orange.shade700, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
static void _showUpdateStatusSheet(BuildContext context, WidgetRef ref, int leadId, int bookingId, String currentStatus) {
  final remarksController = TextEditingController();
  String selectedStatus = currentStatus;

  // Define valid next steps
  final Map<String, List<String>> transitions = {
    "INITIATED": ["DOCUMENT_PENDING", "CANCELLED"],
    "DOCUMENT_PENDING": ["VERIFIED", "CANCELLED"],
    "VERIFIED": ["CONFIRMED", "CANCELLED"],
    "CONFIRMED": [],
    "CANCELLED": []
  };

  final availableNextSteps = transitions[currentStatus] ?? [];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("UPDATE PROGRESS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 20),
          
          if (availableNextSteps.isEmpty)
            const Text("This booking has reached its final state.")
          else ...[
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Next Stage", border: OutlineInputBorder()),
              items: availableNextSteps.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => selectedStatus = val!,
            ),
            const SizedBox(height: 15),
            TextField(
              controller: remarksController,
              decoration: const InputDecoration(labelText: "Feedback/Remarks", border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  // Create the request model
                  final request = BookingUpdateRequest(
                    leadId: leadId,
                    bookingId: bookingId,
                    bookingStatus: selectedStatus,
                    remarks: remarksController.text,
                  );

                  // Call your Service via Provider
                  await ref.read(leadProvider.notifier).updateBookingLifecycle(request);
                  
                  Navigator.pop(ctx); // Close update sheet
                  Navigator.pop(context); // Close main modal to refresh
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text("SAVE UPDATE", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
          const SizedBox(height: 40),
        ],
      ),
    ),
  );
}
Widget _buildDataCard(dynamic booking) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      children: [
        _modernRow(Icons.business_rounded, "Project", booking.projectName.toString().toUpperCase()),
        _modernRow(Icons.apartment_rounded, "Wing & Flat", "${booking.wingName} - ${booking.flatNumber}"),
        _modernRow(
          Icons.payments_rounded, 
          "Amount Paid", 
          "₹${booking.bookingAmount}", 
          isBold: true, 
          // textColor: Colors.green.shade700
        ),
        _modernRow(Icons.calendar_month_rounded, "Booking Date", booking.date),
        _modernRow(Icons.support_agent_rounded, "Assigned Agent", booking.agentName),
        // Added a "Source" row as it's common in Mumbai Real Estate
        // _modernRow(Icons.analytics_rounded, "Lead Source", booking.leadSource ?? "Direct"),
      ],
    ),
  );
}
  // Modern Data Row
  static Widget _modernRow(IconData icon, String label, String? value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.blueGrey, fontSize: 14)),
          const Spacer(),
          Text(
            value ?? "N/A",
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isBold ? Colors.green.shade700 : Colors.black87,
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
            "No leads found ",
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
