import "package:crm_app/features/outcome/models/meetingoutcomemodel.dart";
import "package:crm_app/widgets/customeChoiceChips.dart";
import "package:crm_app/features/auth/providers/auth_provider.dart";
import "package:crm_app/features/leads/providers/lead_provider.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

class MeetingOutcomePage extends ConsumerStatefulWidget {
  final int leadId;
  final int projectId;

  const MeetingOutcomePage({
    super.key,
    required this.leadId,
    required this.projectId,
  });

  @override
  ConsumerState<MeetingOutcomePage> createState() => _MeetingOutcomePageState();
}

class _MeetingOutcomePageState extends ConsumerState<MeetingOutcomePage> {
  final _formKey = GlobalKey<FormState>();

  String? _nextAction;
  DateTime? _selectedDateTime;
  String? _feedbackType;
  final List<String> _lostReasons = [
    "Price Too High",
    "Location Issue",
    "Competitor Selected",
    "Budget Issue",
    "Property Size",
    "Other",
  ];
  final _notesController = TextEditingController();
  final _amountController = TextEditingController();
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(leadProvider.notifier).fetchProjectFlats(widget.projectId);
    });
  }

  void _submitData() async {
    if (_nextAction == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a meeting proceed")),
      );
      return;
    }

    final String noteText = _notesController.text.trim();
    if (noteText.isEmpty) {
      String errorMessage = "Please add notes for this outcome";

      if (_nextAction == "booked") {
        errorMessage = "Please add booking remarks";
      } else if (_nextAction == "lost") {
        errorMessage = "Please add a remark explaining why the lead was lost";
      } else if (_nextAction == "followup") {
        errorMessage = "Please add a folloup note";
      } else if (_nextAction == "meeting") {
        errorMessage = "Please add a meeting note";
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
      return;
    }

    if (_nextAction == "lost" && _feedbackType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a reason for losing this lead"),
        ),
      );
      return;
    }

    final user = ref.read(authProvider).user;
    final currentState = ref.read(leadProvider);
    if (_nextAction == "booked") {
      if (currentState.selectedFlatId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select the flat to be booked")),
        );
        return;
      }
      if (_amountController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter the booking amount")),
        );
        return;
      }
    }
    final outcome = MeetingOutcomeModel(
      leadId: widget.leadId,
      agentId: user!.userId,
      nextAction: _nextAction!,
      remarks: _notesController.text,
      feedbackType: _nextAction == "lost"
          ? _feedbackType
          : _nextAction!.toUpperCase(),
      followDate: _nextAction == "followup"
          ? _selectedDateTime?.toIso8601String()
          : null,
      followNotes: _nextAction == "followup" ? _notesController.text : null,
      meetingDate: _nextAction == "meeting"
          ? _selectedDateTime?.toIso8601String()
          : null,
      meetingNotes: _nextAction == "meeting" ? _notesController.text : null,
      projectId: widget.projectId,
      bookingAmount: int.tryParse(_amountController.text),
      flatId: _nextAction == "booked" ? currentState.selectedFlatId : null,
    );

    await ref.read(leadProvider.notifier).completeMeetingOutcome(outcome);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Meeting Outcome")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSectionTitle("How do you want to proceed?"),
            const SizedBox(height: 12),
            CustomChoiceChips(
              options: ["followup", "meeting", "negotiation", "booked", "lost"],
              selectedOption: _nextAction ?? "",
              onSelected: (val) => setState(() {
                _nextAction = val;
                _feedbackType = null;
              }),
            ),

            const Divider(height: 40),

            // 1. DATE PICKER (For Followup or Meeting)
            if (_nextAction == "followup" || _nextAction == "meeting") ...[
              _buildDateTimePicker(),
              const SizedBox(height: 16),
            ],
            if (_nextAction == "lost") ...[
              _buildSectionTitle("Reason for Closing (Lost)"),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _feedbackType,
                items: _lostReasons
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (val) => setState(() => _feedbackType = val),
                decoration: _inputDecoration("Select Reason", Icons.report_off),
              ),
              const SizedBox(height: 20),
            ],
            // 2. BOOKING FORM (Only if Booked is selected)
            if (_nextAction == "booked") ...[
              _buildSectionTitle("Booking Details"),
              const SizedBox(height: 12),

              _buildTextField(
                _amountController,
                "Booking Amount (₹)",
                Icons.payments,
                isNum: true,
              ),
              const SizedBox(height: 16),

              const Text(
                "Select Flat",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),

              Consumer(
                builder: (context, ref, child) {
                  // 1. Watch the lead state
                  final state = ref.watch(leadProvider);
                  final notifier = ref.read(leadProvider.notifier);

                  // 2. Show loader if flats are being fetched
                  if (state.isFlateLoading) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: LinearProgressIndicator(minHeight: 2),
                    );
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value:
                            state.flats.any(
                              (f) => f.flatId == state.selectedFlatId,
                            )
                            ? state.selectedFlatId
                            : null,
                        items: state.flats.map((flat) {
                          return DropdownMenuItem<int>(
                            value: flat.flatId,
                            child: Text(
                              "Wing ${flat.wingName} - floor ${flat.floorNumber} - ${flat.flatNumber}",
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          notifier.onFlatSelected(value);
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
            // 3. NOTES (Used for Followup/Meeting notes)
            _buildSectionTitle("Meeting Notes"),
            const SizedBox(height: 8),
            _buildTextField(
              _notesController,
              "Describe the discussion...",
              Icons.edit_note,
              maxLines: 3,
            ),

            const SizedBox(height: 40),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }

  Widget _buildDateTimePicker() {
    return Card(
      color: Colors.blue.shade50,
      elevation: 0,
      child: ListTile(
        leading: const Icon(Icons.event),
        title: Text(
          _selectedDateTime == null
              ? "Select Next Action Date"
              : "Scheduled: ${_selectedDateTime.toString()}",
        ),
        onTap: () async {
          final d = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2030),
          );
          if (d != null) {
            final t = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (t != null) {
              setState(
                () => _selectedDateTime = DateTime(
                  d.year,
                  d.month,
                  d.day,
                  t.hour,
                  t.minute,
                ),
              );
            }
          }
        },
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNum = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey,
      ),
    );
  }

  Widget _buildSaveButton() {
    final isLoading = ref.watch(leadProvider).isLoading;
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        onPressed: isLoading
            ? null
            : (_nextAction == null ? null : _submitData),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text("SUBMIT"),
      ),
    );
  }
}
