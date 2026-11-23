import 'package:crm_app/features/leads/models/project_media_model.dart';
import 'package:crm_app/features/leads/providers/lead_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareMediaPage extends ConsumerStatefulWidget {
  final int projectId; // Passed from previous page
  final String customerPhone;

  const ShareMediaPage({super.key, required this.projectId, required this.customerPhone});

  @override
  ConsumerState<ShareMediaPage> createState() => _ShareMediaPageState();
}

class _ShareMediaPageState extends ConsumerState<ShareMediaPage> {
  
  @override
  void initState() {
    super.initState();
    // Trigger the API call using the projectId passed to this widget
    Future.microtask(() => 
      ref.read(leadProvider.notifier).loadProjectMedia(widget.projectId)
    );
  }

void _shareToWhatsApp(String message) async {
  final cleanPhone = widget.customerPhone.replaceAll(RegExp(r'[^0-9]'), '');
  
  // Try the custom scheme first (better for deep linking)
  final whatsappUrl = Uri.parse("whatsapp://send?phone=$cleanPhone&text=${Uri.encodeComponent(message)}");
  
  // Fallback to the web link if the app isn't installed
  final httpsUrl = Uri.parse("https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}");

  try {
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(httpsUrl)) {
      await launchUrl(httpsUrl, mode: LaunchMode.externalApplication);
    } else {
      // If neither work, show a snackbar to the user
      debugPrint("Could not launch WhatsApp");
    }
  } catch (e) {
    debugPrint("Error launching URL: $e");
  }
}

  // Method to share all links at once
  void _shareAllMedia(List<ProjectMedia> mediaList) {
    String message = "Hi! Please find the project details below:\n\n";
    for (var item in mediaList) {
      message += "${item.title}: ${item.fileUrl}\n";
    }
    _shareToWhatsApp(message);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(leadProvider); // Watch your StateNotifier provider
    final mediaList = state.projectMedia;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Share Project Media"),
        actions: [
          if (mediaList.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.send, color: Colors.green),
              onPressed: () => _shareAllMedia(mediaList),
              tooltip: "Share All",
            )
        ],
      ),
      body: state.isProjectLoading 
          ? const Center(child: CircularProgressIndicator())
          : mediaList.isEmpty 
              ? const Center(child: Text("No media found for this project"))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // --- PDF SECTION ---
                    if (mediaList.any((m) => m.mediaType == 'pdf')) ...[
                      _mediaSectionTitle("Brochures (PDF)"),
                      ...mediaList.where((m) => m.mediaType == 'pdf').map((m) => 
                        _buildMediaCard(m, Colors.red, Icons.picture_as_pdf)
                      ),
                    ],

                    const SizedBox(height: 20),

                    // --- YOUTUBE SECTION ---
                    if (mediaList.any((m) => m.mediaType == 'youtube')) ...[
                      _mediaSectionTitle("Videos"),
                      ...mediaList.where((m) => m.mediaType == 'youtube').map((m) => 
                        _buildMediaCard(m, Colors.blue, Icons.play_circle_fill)
                      ),
                    ],
                  ],
                ),
    );
  }

  Widget _mediaSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
    );
  }

  Widget _buildMediaCard(ProjectMedia media, Color color, IconData icon) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color),
        ),
        title: Text(media.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text("Type: ${media.mediaType.toUpperCase()}"),
        trailing: const Icon(Icons.send, color: Colors.green),
        onTap: () => _shareToWhatsApp("Check this out: ${media.title}\n${media.fileUrl}"),
      ),
    );
  }
}