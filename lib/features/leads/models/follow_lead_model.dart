import 'package:intl/intl.dart';
class FollowUpLeadListResponse {
  final List<FollowUpLead> leads;
  final int? totalCount;
  final int? nextCursor;
  final bool hasMore;

  FollowUpLeadListResponse({
    required this.leads,
    this.totalCount,
    this.nextCursor,
    this.hasMore = false,
  });

  factory FollowUpLeadListResponse.fromJson(Map<String, dynamic> json) {
    final List data = json["data"] ?? [];

    return FollowUpLeadListResponse(
      leads: data.map((e) => FollowUpLead.fromJson(e)).toList(),
      totalCount: json["total_count"], // optional
      nextCursor: json["next_cursor"], // optional
      hasMore: json["has_more"] ?? false, // safe default
    );
  }
}
class FollowUpLead {
  final int leadId;
  final int followId;
  final String customerName;
  final String customerPhone;
  final String followDate;
  final String status; 
  final String? followNotes;
  // New Fields
  final int? projectId;
  final int? budget;
  final String? location;
  final String? timeline;
  final String? interestLevel;
  final String? bhkConfigure;

  FollowUpLead({
    required this.leadId,
    required this.followId,
    required this.customerName,
    required this.customerPhone,
    required this.followDate,
    required this.status,
    required this.followNotes,
    this.budget,
    this.projectId,
    this.location,
    this.timeline,
    this.interestLevel,
    this.bhkConfigure,
  });

  factory FollowUpLead.fromJson(Map<String, dynamic> json) {
      String rawDate = json['follow_date'] ?? "";

  DateTime? parsedDate = parseDate(rawDate);

  String formattedDate = parsedDate != null
      ? DateFormat("yyyy-MM-dd").format(parsedDate)
      : rawDate;
    return FollowUpLead(
      leadId: json['lead_id'] ?? 0,
      followId: json['follow_id'] ?? 0,
      customerName: json['customer_name'] ?? '',
      customerPhone: json['customer_phone'] ?? '',
      followDate:formattedDate,
      status: json['status'] ?? '',
      followNotes: json['follow_notes'] ?? '',
      projectId: json['project_id'],
      budget: json['budget'],
      location: json['location'],
      timeline: json['timeline'],
      interestLevel: json['interest_level'],
      bhkConfigure: json['bhk_configure'],
    );
  }
}

DateTime? parseDate(String rawDate) {
  if (rawDate.isEmpty) return null;

  List<String> formats = [
    "yyyy-MM-dd hh:mm:ss a", // 2026-03-27 06:08:04 AM
    "yyyy-MM-dd HH:mm:ss",   // 2026-03-27 18:08:04
    "yyyy-MM-ddTHH:mm:ss",   // ISO without Z
    "yyyy-MM-dd",            // only date
  ];

  for (var format in formats) {
    try {
      return DateFormat(format).parse(rawDate);
    } catch (_) {}
  }

  // last fallback (important)
  try {
    return DateTime.parse(rawDate);
  } catch (_) {}

  return null;
}