import "package:crm_app/features/outcome/models/calloutcome_model.dart";
import "package:crm_app/widgets/customeChoiceChips.dart";
import "package:crm_app/features/auth/providers/auth_provider.dart";
import "package:crm_app/features/leads/providers/lead_provider.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:intl/intl.dart";
import "package:shared_preferences/shared_preferences.dart";

class CallOutcomePage extends ConsumerStatefulWidget {
  final int leadId;
  final String? budget;
  final String? location;
  final String? interestLevel;
  final String? timeline;
  final String? bhk;
  final String? status;

  const CallOutcomePage({
    super.key,
    required this.leadId,
    this.budget,
    this.location,
    this.interestLevel,
    this.timeline,
    this.bhk,
    this.status,
  });

  @override
  ConsumerState<CallOutcomePage> createState() => _CallOutcomePageState();
}

class _CallOutcomePageState extends ConsumerState<CallOutcomePage> {
  final _formKey = GlobalKey<FormState>();
  String? _callStatus;
  String? _interest;
  String? _nextAction;
  DateTime? _selectedDate;
  late TextEditingController _notesController;
  late TextEditingController _budgetController;
  late TextEditingController _locationController;
  String? selectedRequirement;
  String? _selectedTimeline;
  String? _interestLevel;
  final List<String> requirementList = [
    "1 RK",
    "1 BHK",
    "1.5 BHK",
    "2 BHK",
    "2.5 BHK",
    "3 BHK",
    "3.5 BHK",
    "4 BHK",
    "4+ BHK",
  ];
  String? _feedbackType; // To store "Price Issue", "Location Issue", etc.
  final List<String> feedbackOptions = [
    "Price Issue",
    "Location Issue",
    "Not Interested",
    "Budget Low",
    "Delay",
    "Already Purchased",
    "Other",
  ];
  @override
  void initState() {
    super.initState();
    _budgetController = TextEditingController(text: widget.budget ?? "");
    _locationController = TextEditingController(text: widget.location ?? "");
    _notesController = TextEditingController();

    _interestLevel = widget.interestLevel;
    _selectedTimeline = widget.timeline;
    selectedRequirement = widget.bhk;
    if (widget.status?.toLowerCase() == "in_followup" ||
        widget.status == "pending") {
      _callStatus = "Answered";
      _interest = "Interested";
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _budgetController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _submitData() async {
    if (_callStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a call status")),
      );
      return;
    }
    if (_callStatus == "Wrong Number" && _notesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add a remark for Wrong Number")),
      );
      return;
    }
    final String noteText = _notesController.text.trim();

    if (noteText.isEmpty) {
      String errorMessage = "Please add a note";
      if (_callStatus == "Wrong Number") {
        errorMessage = "Please add a remark for Wrong Number";
      } else if (_nextAction == "followup") {
        errorMessage = "Please add followup instructions in notes";
      } else if (_nextAction == "meeting") {
        errorMessage = "Please add meeting details in notes";
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
      return;
    }
    if (_callStatus != "Wrong Number" &&
        _nextAction != null &&
        _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a date and time")),
      );
      return;
    }

    final authState = ref.read(authProvider);
    final user = authState.user;

    final outcome = CallOutcomeModel(
      leadId: widget.leadId,
      agentId: user!.userId,
      callStatus: _callStatus!.toLowerCase().replaceAll(" ", "_"),
      actionType: _nextAction,
      actioninterest: _interest,
      followDate: (_callStatus != "Wrong Number" && _nextAction == "followup")
          ? _selectedDate?.toIso8601String()
          : null,
      meetingDate: (_callStatus != "Wrong Number" && _nextAction == "meeting")
          ? _selectedDate?.toIso8601String()
          : null,
      followNotes: _nextAction == "followup" ? noteText : null,

      meetingNotes: _nextAction == "meeting" ? noteText : null,
      remarks: (_callStatus == "Wrong Number" || _interest == "Not Interested")
          ? noteText
          : null,
      feedbackType: _interest == "Not Interested" ? _feedbackType : null,
      budget: int.tryParse(_budgetController.text),
      location: _locationController.text,
      interestLevel: _interestLevel,
      bhkConfigure: selectedRequirement,
      timeLine: _selectedTimeline,
    );

    await ref.read(leadProvider.notifier).saveCallOutcome(outcome);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("pending_lead_id");
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final leadState = ref.watch(leadProvider);
    final bool isProviderLoading = leadState.isSubmittingOutcome;
    return PopScope(
      canPop: false, // 🔥 blocks back
      onPopInvoked: (didPop) {
        if (didPop) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please submit the form first")),
        );
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Call Outcome"), elevation: 0),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildSectionTitle("How was the call?"),
              const SizedBox(height: 12),
              CustomChoiceChips(
                options: ["Not Picked", "Busy", "Answered", "Wrong Number"],
                selectedOption: _callStatus ?? "",
                onSelected: (val) {
                  setState(() {
                    _callStatus = val;
                    // Reset logic
                    if (val == "Wrong Number") {
                      _nextAction = null; // No follow-up/meeting
                      _interest = null; // No interest level
                      _selectedDate = null; // Clear date
                    } else if (val != "Answered") {
                      _nextAction =
                          "followup"; // Auto-set follow-up for Busy/Not Picked
                      _interest = null;
                    } else if (val == "Busy" || val == "Not Picked") {
                      _nextAction = "followup"; // Auto-set  the followup
                      _interest = null;
                    }
                  });
                },
              ),
              if (_callStatus == "Answered") ...[
                const Divider(height: 40),
                _buildSectionTitle("Customer Interest"),
                const SizedBox(height: 12),
                _buildChoiceChips(
                  options: ["Interested", "Not Interested"],
                  selected: _interest,
                  onSelected: (val) {
                    setState(() {
                      _interest = val;
                      // Reset logic
                      _notesController.clear();
                      if (val == "Not Interested") {
                        _nextAction = null;
                        _selectedDate = null;
                        _feedbackType = null;
                      } else {
                        _feedbackType =
                            null; // Clear feedback if they become interested
                      }
                    });
                  },
                ),

                if (_interest == "Interested") ...[
                  const SizedBox(height: 16),

                  // 1. INTEREST LEVEL (The "Temperature" of the lead)
                  _buildSectionTitle("Lead Temperature"),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildTemperatureChip("Hot", Colors.red, Icons.whatshot),
                      const SizedBox(width: 8),
                      _buildTemperatureChip(
                        "Warm",
                        Colors.orange,
                        Icons.wb_sunny,
                      ),
                      const SizedBox(width: 8),
                      _buildTemperatureChip("Cold", Colors.blue, Icons.ac_unit),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 2. TIMELINE DROPDOWN
                  DropdownButtonFormField<String>(
                    value: _selectedTimeline,
                    items:
                        [
                              "Immediate",
                              "Within 15 Days",
                              "1 Month",
                              "3 Months",
                              "Just Researching",
                            ]
                            .map(
                              (time) => DropdownMenuItem(
                                value: time,
                                child: Text(time),
                              ),
                            )
                            .toList(),
                    onChanged: (val) => setState(() => _selectedTimeline = val),
                    decoration: _inputDecoration(
                      "Buying Timeline",
                      Icons.history_toggle_off,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 3. BUDGET & LOCATION
                  _buildTextField(
                    _budgetController,
                    "Budget (₹)",
                    TextInputType.number,
                    Icons.currency_ruble,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    _locationController,
                    "Preferred Location",
                    TextInputType.text,
                    Icons.location_on,
                  ),

                  const SizedBox(height: 12),

                  // 4. REQUIREMENT (BHK)
                  DropdownButtonFormField<String>(
                    value: selectedRequirement,
                    items: requirementList
                        .map(
                          (req) =>
                              DropdownMenuItem(value: req, child: Text(req)),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => selectedRequirement = value),
                    decoration: _inputDecoration(
                      "Requirement (BHK)",
                      Icons.home_work,
                    ),
                  ),
                ],
                if (_interest == "Not Interested") ...[
                  const SizedBox(height: 20),
                  _buildSectionTitle("Reason for Not Interested"),
                  const SizedBox(height: 12),

                  // Reason Dropdown
                  DropdownButtonFormField<String>(
                    value: _feedbackType,
                    items: feedbackOptions
                        .map(
                          (reason) => DropdownMenuItem(
                            value: reason,
                            child: Text(reason),
                          ),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => _feedbackType = val),
                    decoration: _inputDecoration(
                      "Select Reason",
                      Icons.report_problem,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Remarks
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration:
                        _inputDecoration(
                          "Additional Remarks",
                          Icons.comment,
                        ).copyWith(
                          hintText:
                              "Enter details about why they aren't interested...",
                        ),
                  ),
                ],
                const Divider(height: 40),
                _buildSectionTitle("What's the Next Action?"),
                const SizedBox(height: 12),
                CustomChoiceChips(
                  options: ["followup", "meeting"],
                  selectedOption: _nextAction ?? "",
                  onSelected: (val) => setState(() => _nextAction = val),
                ),
              ],
              if (_callStatus == "Wrong Number") ...[
                const Divider(height: 40),
                _buildSectionTitle("Remarks (Required)"),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration:
                      _inputDecoration(
                        "Internal Note",
                        Icons.error_outline,
                      ).copyWith(
                        hintText: "Mention details about the wrong number...",
                      ),
                ),
              ],
              if (_nextAction != null) ...[
                const SizedBox(height: 20),
                Card(
                  elevation: 0,
                  color: Colors.grey[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.calendar_today, size: 20),
                        title: Text(
                          _selectedDate == null
                              ? "Select Date & Time"
                              // 2. This formats to: Month Day, Year, 12-hour:min AM/PM
                              : "Scheduled for: ${DateFormat('dd-MM-yyyy hh:mm a').format(_selectedDate!)}",
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          // 1. Pick Date
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2027),
                          );

                          if (pickedDate != null) {
                            // 2. Pick Time
                            if (!mounted) return;
                            final TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );

                            if (pickedTime != null) {
                              setState(() {
                                // 3. Merge Date and Time into one DateTime object
                                _selectedDate = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );
                              });
                            }
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: TextField(
                          controller: _notesController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: "Add internal notes here...",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: (_callStatus == null) ? null : _submitData,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: isProviderLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Save Outcome",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // UI Helper methods to keep the build method clean
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.blueGrey,
      ),
    );
  }

  Widget _buildChoiceChips({
    required List<String> options,
    required String? selected,
    required Function(String) onSelected,
  }) {
    return Wrap(
      spacing: 8,
      children: options
          .map(
            (s) => ChoiceChip(
              label: Text(s),
              selected: selected == s,
              onSelected: (_) => onSelected(s),
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
            ),
          )
          .toList(),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    TextInputType type,
    IconData icon,
  ) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  // Helper for the Hot/Warm/Cold chips
  Widget _buildTemperatureChip(String label, Color color, IconData icon) {
    bool isSelected = _interestLevel == label;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _interestLevel = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : color, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable Input Decoration
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.white,
    );
  }
}
