import 'package:crm_app/features/auth/providers/auth_provider.dart';
import 'package:crm_app/features/leads/models/lead_model.dart';
import 'package:crm_app/features/outcome/screens/meeting_outcome_page.dart';
import 'package:crm_app/features/leads/providers/lead_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserLeadAddForm extends ConsumerStatefulWidget {
  const UserLeadAddForm({super.key});

  @override
  ConsumerState<UserLeadAddForm> createState() => _UserLeadAddFormState();
}

class _UserLeadAddFormState extends ConsumerState<UserLeadAddForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController addressCtrl;

  String? selectedSource;

  final List<String> leadSources = ["Direct", "Social Media", "Reference"];

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController();
    phoneCtrl = TextEditingController();
    emailCtrl = TextEditingController();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    super.dispose();
  }

  int? selectedUserId;
  int? selectedProjectId;
  Future<void> _submitForm() async {
    // 1. Validate Form Fields
    final authState = ref.watch(authProvider);
    final user = authState.user;
    if (!_formKey.currentState!.validate()) return;

    // 2. Validate Dropdowns
    if (selectedUserId == null ||
        selectedSource == null ||
        selectedProjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select Lead Type & Source")),
      );
      return;
    }
    final lead = LeadModel(
      customerName: nameCtrl.text.trim(),
      customerEmail: emailCtrl.text.trim(),
      customerPhone: phoneCtrl.text.trim(),
      leadSource: selectedSource.toString(),
      projectsId: selectedProjectId ?? 1,
      assignedUserId: selectedUserId ?? 1,
      organizationId: user!.organizationId,
      leadStatus: "new",
    );
    final response = await ref.read(leadProvider.notifier).createLead(lead);
    if (!mounted) return;

    if (response == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Server error. Please try again.")),
      );
      return;
    }

    if (response.status == 1) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Success: ${response.message}")));

      if (selectedSource == "Direct" || selectedSource == "Reference") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MeetingOutcomePage(
              leadId: response.leadId!,
              projectId: selectedProjectId!,
            ),
          ),
        );
      } else {
        Navigator.pop(context, true);
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (_) => CallOutcomePage(
        //       leadId: response.leadId,
        //     ),
        //   ),
        // );
      }
      _formKey.currentState!.reset();
      nameCtrl.clear();
      phoneCtrl.clear();
      emailCtrl.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${response.message}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(userProvider);
    final projectsAsync = ref.watch(projectProvider);
    final isLoading = ref.watch(leadProvider).isLoading;
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text(
          "Add New Lead",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white, // 👈 This changes the back arrow color
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              /// NAME
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? "Enter Name" : null,
              ),
              const SizedBox(height: 20),

              /// PHONE
              /// PHONE FIELD
              TextFormField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                maxLength: 10, // Limits input to 10 characters
                decoration: const InputDecoration(
                  labelText: "Phone",
                  counterText: "", // Hides the character counter
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter Phone Number";
                  }
                  if (value.length != 10) {
                    return "Phone number must be exactly 10 digits";
                  }
                  // Optional: Check if it's only numbers
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return "Enter a valid number";
                  }

                  return null;
                },
              ),

              // const SizedBox(height: 16),

              /// EMAIL
              // TextFormField(
              //   controller: emailCtrl,
              //   keyboardType: TextInputType.emailAddress,
              //   decoration: const InputDecoration(
              //     labelText: "Email",
              //     border: OutlineInputBorder(),
              //   ),
              //   validator: (value) {
              //     if (value!.isEmpty) return "Enter Email";
              //     if (!value.contains("@")) return "Invalid Email";
              //     return null;
              //   },
              // ),
              const SizedBox(height: 20),

              usersAsync.when(
                data: (users) => DropdownButtonFormField<int>(
                  value: selectedUserId,
                  decoration: const InputDecoration(
                    labelText: "Assigned to",
                    border: OutlineInputBorder(),
                  ),
                  items: users
                      .map(
                        (user) => DropdownMenuItem(
                          value: user.userId,
                          child: Text(user.username),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => selectedUserId = val),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, s) => Text("Error loading users"),
              ),
              const SizedBox(height: 20),

              // /// LEAD TYPE DROPDOWN
              // DropdownButtonFormField<String>(
              //   value: selectedLeadType,
              //   items: userTypes
              //       .map(
              //         (type) =>
              //             DropdownMenuItem(value: type, child: Text(type)),
              //       )
              //       .toList(),
              //   onChanged: (value) {
              //     setState(() {
              //       selectedLeadType = value;
              //     });
              //   },
              //   decoration: const InputDecoration(
              //     labelText: "User Type",
              //     border: OutlineInputBorder(),
              //   ),
              // ),
              // const SizedBox(height: 20),
              projectsAsync.when(
                data: (projects) => DropdownButtonFormField<int>(
                  value: selectedProjectId,
                  decoration: const InputDecoration(
                    labelText: "Select Project",
                    border: OutlineInputBorder(),
                  ),
                  items: projects
                      .map(
                        (proj) => DropdownMenuItem(
                          value: proj.projectId,
                          child: Text(proj.projectName),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => selectedProjectId = val),
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, s) => Text("Error loading projects"),
              ),
              const SizedBox(height: 20),

              /// SOURCE DROPDOWN
              DropdownButtonFormField<String>(
                value: selectedSource,
                items: leadSources
                    .map(
                      (source) =>
                          DropdownMenuItem(value: source, child: Text(source)),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSource = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: "Lead Source",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),

              /// SAVE BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        Colors.blue.shade300, // Light blue when loading
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Add Lead",
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
}
