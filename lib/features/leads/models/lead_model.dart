import 'package:intl/intl.dart';

class LeadModel {
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String leadSource;
  final int projectsId;
  final int assignedUserId;
  final int organizationId;
  final String leadStatus;

  LeadModel({
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.leadSource,
    required this.projectsId,
    required this.assignedUserId,
    required this.leadStatus,
    required this.organizationId,
  });

  Map<String, dynamic> toJson() {
    return {
      "customer_name": customerName,
      "customer_email": customerEmail,
      "customer_phone": customerPhone,
      "lead_source": leadSource,
      "project_id": projectsId,
      "assigned_user_id": assignedUserId,
      "lead_status": leadStatus,
      "organization_id": organizationId,
    };
  }
}

class LeadResponseModel {
  final int status;
  final String message;
  final int? leadId;

  LeadResponseModel({required this.status, required this.message, this.leadId});

  factory LeadResponseModel.fromJson(Map<String, dynamic> json) {
    return LeadResponseModel(
      status: json["status"] ?? 0,
      message: json["message"] ?? "",
      leadId: json["lead_id"],
    );
  }
}

class LeadListResponse {
  final List<LeadFetchModel> leads;
  final int? totalCount;
  final int? nextCursor;
  final bool hasMore;

  LeadListResponse({
    required this.leads,
    this.totalCount,
    this.nextCursor,
    this.hasMore = false,
  });

  factory LeadListResponse.fromJson(Map<String, dynamic> json) {
    final List data = json["data"] ?? [];

    return LeadListResponse(
      leads: data.map((e) => LeadFetchModel.fromJson(e)).toList(),
      totalCount: json["total_count"], // optional
      nextCursor: json["next_cursor"], // optional
      hasMore: json["has_more"] ?? false, // safe default
    );
  }
}

class LeadFetchModel {
  final int leadId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String leadStatus;
  final String createdDate;
  final int? projectId;
  // New Buyer Info Fields
  final int? budget;
  final String? location;
  final String? timeline;
  final String? interestLevel;
  final String? bhkConfigure;

  LeadFetchModel({
    required this.leadId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.createdDate,
    required this.leadStatus,
    this.projectId,
    this.budget,
    this.location,
    this.timeline,
    this.interestLevel,
    this.bhkConfigure,
  });

  factory LeadFetchModel.fromJson(Map<String, dynamic> json) {
    String rawDate = json['created_date'] ?? "";

    DateTime? parsedDate = parseDate(rawDate);

    String formattedDate = parsedDate != null
        ? DateFormat("yyyy-MM-dd").format(parsedDate)
        : rawDate;

    return LeadFetchModel(
      leadId: json["lead_id"],
      customerName: json["customer_name"] ?? "",
      leadStatus: json["lead_status"] ?? "",
      budget: json["budget"],
      customerEmail: json["customer_email"] ?? "",
      customerPhone: json["customer_phone"] ?? "",
      createdDate: formattedDate,
      projectId: json['project_id'],
      location: json["location"],
      timeline: json["timeline"],
      interestLevel: json["interest_level"],
      bhkConfigure: json["bhk_configure"]?.toString(),
    );
  }
}

DateTime? parseDate(String rawDate) {
  if (rawDate.isEmpty) return null;

  List<String> formats = [
    "yyyy-MM-dd hh:mm:ss a", // 2026-03-27 06:08:04 AM
    "yyyy-MM-dd HH:mm:ss", // 2026-03-27 18:08:04
    "yyyy-MM-ddTHH:mm:ss", // ISO without Z
    "yyyy-MM-dd", // only date
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
