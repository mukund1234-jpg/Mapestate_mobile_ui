import 'package:intl/intl.dart';
class MeetingLeadListResponse {
  final List<MeetingLeadModel> leads;
  final int? totalCount;
  final int? nextCursor;
  final bool hasMore;

  MeetingLeadListResponse({
    required this.leads,
    this.totalCount,
    this.nextCursor,
    this.hasMore = false,
  });

  factory MeetingLeadListResponse.fromJson(Map<String, dynamic> json) {
    final List data = json["data"] ?? [];

    return MeetingLeadListResponse(
      leads: data.map((e) => MeetingLeadModel.fromJson(e)).toList(),
      totalCount: json["total_count"], 
      nextCursor: json["next_cursor"], 
      hasMore: json["has_more"] ?? false,
    );
  }
}
class MeetingLeadModel {
  final int leadId;
  final String customerName;
  final String customerPhone;
  final int? projectId;
  final String project;
  final String agent;
  final String notes;
  final String meetingDate;
  final String status;

  MeetingLeadModel({
    required this.leadId,
    required this.customerName,
    required this.customerPhone,
    required this.project,
    this.projectId,
    required this.agent,
    required this.notes,
    required this.meetingDate,
    required this.status,
  });

  factory MeetingLeadModel.fromJson(Map<String, dynamic> json) {
          String rawDate = json['latest_meeting_date'] ?? "";

  DateTime? parsedDate = parseDate(rawDate);

  String formattedDate = parsedDate != null
      ? DateFormat("yyyy-MM-dd hh:mm:ss a").format(parsedDate)
      : rawDate;
    return MeetingLeadModel(
      leadId: json['lead_id'] ?? 0,
      customerName: json['customer_name'] ?? "",
      customerPhone: json['customer_phone'] ?? "",
      project: json['project'] ?? "",
      agent: json['agent'] ?? "",
      notes: json['notes'] ?? "",
      projectId: json["project_id"] is int ? json["project_id"] : null,
      meetingDate:formattedDate,
      status: json['status'] ?? "",
    );
  }
}

DateTime? parseDate(String rawDate) {
  if (rawDate.isEmpty) return null;

  try {
    // Normalize AM/PM spacing issue
    rawDate = rawDate.replaceAll(RegExp(r'\s+'), ' ').trim();

    return DateFormat("yyyy-MM-dd hh:mm:ss a", "en_US").parseStrict(rawDate);
  } catch (e) {
    try {
      return DateFormat("yyyy-MM-dd HH:mm:ss").parseStrict(rawDate);
    } catch (_) {
      try {
        return DateTime.parse(rawDate);
      } catch (_) {
        // print("❌ Date parse failed: $rawDate"); // STOP hiding errors
        return null;
      }
    }
  }
}