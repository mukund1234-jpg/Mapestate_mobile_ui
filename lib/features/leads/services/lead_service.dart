import 'package:crm_app/features/leads/models/booking_update.dart';
import 'package:crm_app/features/leads/models/bookingdeatails_model.dart';
import 'package:crm_app/features/leads/models/calendore_event.dart';
import 'package:crm_app/features/outcome/models/calloutcome_model.dart';
import 'package:crm_app/features/leads/models/flat_modal.dart';
import 'package:crm_app/features/leads/models/follow_lead_model.dart';
import 'package:crm_app/features/leads/models/lead_data_model.dart';
import 'package:crm_app/features/leads/models/lead_track_model.dart';
import 'package:crm_app/features/leads/models/meeting_model.dart';
import 'package:crm_app/features/outcome/models/meetingoutcomemodel.dart';
import 'package:crm_app/features/leads/models/project_media_model.dart';
import 'package:crm_app/features/leads/models/tracking_model.dart';
import 'package:crm_app/features/leads/services/endpoint/lead_endpoint.dart';
import 'package:flutter/material.dart';
import '../../../core/network/dio_client.dart';
import '../models/lead_model.dart';

class LeadService {
  // create the leads
  Future<LeadResponseModel?> createLead(LeadModel lead) async {
    debugPrint("this is lead create => ${lead.toJson()}");
    try {
      final response = await DioClient.dio.post(
        "/leads/create_lead",
        data: lead.toJson(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return LeadResponseModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint("Lead create error: $e");
      return null;
    }
  }

  Future<LeadListResponse?> _fetchLeads(
    String endpoint, {
    required int userId,
    int? lastId,
    String? status,
    String? search,
    String? date,
  }) async {
    try {
      final response = await DioClient.dio.get(
        endpoint,
        queryParameters: {
          "user_id": userId,
          "limit": 10,
          if (lastId != null) "last_id": lastId,
          if (status != null && status.isNotEmpty) "status": status,
          if (search != null && search.isNotEmpty) "search": search,
          if (date != null && date.isNotEmpty) "date": date,
        },
      );

      if (response.statusCode == 200) {
        final resData = response.data;

        if (resData["status"] != 1) return null;

        return LeadListResponse.fromJson(resData);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<LeadListResponse?> fetchLeads(
    int userId, {
    int? lastId,
    String? status,
    String? search,
    String? date,
  }) {
    return _fetchLeads(
      LeadEndpoints.getLeads(),
      userId: userId,
      lastId: lastId,
      status: status,
      search: search,
      date: date,
    );
  }

  Future<LeadListResponse?> fetchTodayLeads(int userId) {
    return _fetchLeads(LeadEndpoints.getTodayLeads(), userId: userId);
  }

  Future<LeadListResponse?> fetchBookedLeads(int userId) {
    return _fetchLeads(LeadEndpoints.getBookedLeads(), userId: userId);
  }

  Future<List<FlatModel>> fetchFlats(int projectId) async {
    try {
      final response = await DioClient.dio.get("/leads/get_flats/$projectId");
      if (response.data['status'] == 1) {
        List data = response.data['data'];
        return data.map((f) => FlatModel.fromJson(f)).toList();
      }
      return [];
    } catch (e) {
      throw Exception("Failed to load flats: $e");
    }
  }

  Future<bool> submitCallOutcome(CallOutcomeModel outcome) async {
    debugPrint("this is lead create => ${outcome.toJson()}");
    try {
      final response = await DioClient.dio.post(
        "/calls/call-outcome",
        data: outcome.toJson(),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("Call Outcome Error: $e");
      return false;
    }
  }

  Future<bool> submitMeetingOutcome(MeetingOutcomeModel outcome) async {
    debugPrint("this is lead create => ${outcome.toJson()}");
    try {
      final response = await DioClient.dio.post(
        "/calls/complete_meeting",
        data: outcome.toJson(),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("Call Outcome Error: $e");
      return false;
    }
  }

  Future<List<LeadTracking>> fetchLeadTracking(int leadId) async {
    final response = await DioClient.dio.get("/leads/lead_tracking/$leadId");

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = response.data;
      List<dynamic> data = body['data'];
      return data.map((item) => LeadTracking.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load tracking data');
    }
  }

  Future<FollowUpLeadListResponse?> fetchFollowUpLeads(
    int userId, {
    int? lastId,
    String? status,
    String? search,
    String? date,
  }) async {
    final response = await DioClient.dio.get(
      "/leads/get_followup_list",
      queryParameters: {
        "user_id": userId,
        "limit": 10,
        if (lastId != null) "last_id": lastId,
        if (status != null && status.isNotEmpty) "status": status,
        if (search != null && search.isNotEmpty) "search": search,
        if (date != null && date.isNotEmpty) "date": date,
      },
    );

    if (response.statusCode == 200) {
      return FollowUpLeadListResponse.fromJson(response.data);
    } else {
      throw Exception("Failed to load follow-up leads");
    }
  }

  Future<MeetingLeadListResponse?> fetchMeetingList(
    int userId, {
    int? lastId,
    String? status,
    String? search,
    String? date,
  }) async {
    final response = await DioClient.dio.get(
      "/calls/get_meeting_list",
      queryParameters: {
        "user_id": userId,
        "limit": 10,
        if (lastId != null) "last_id": lastId,
        if (status != null && status.isNotEmpty) "status": status,
        if (search != null && search.isNotEmpty) "search": search,
        if (date != null && date.isNotEmpty) "date": date,
      },
    );

    if (response.data['status'] == 1) {
      return MeetingLeadListResponse.fromJson(response.data);
    } else {
      throw Exception("Failed to load follow-up leads");
    }
  }

  Future<List<TrackingHistoryModel>> getTrackingHistory(
    int leadId,
    String type,
  ) async {
    try {
      String url = "";

      // Determine URL based on type
      if (type == "followup") {
        url = "/leads/get_followup_track/$leadId";
      } else if (type == "meeting") {
        url = "/calls/get_meeting_track/$leadId"; // New Meeting URL
      } else {
        url = "/calls/get_callhistory_track/$leadId";
      }

      final response = await DioClient.dio.get(url);

      if (response.statusCode == 200 && response.data['status'] == 1) {
        final List data = response.data['data'] ?? [];
        // Pass the 'type' to the model so it knows which ID key to use
        return data
            .map((item) => TrackingHistoryModel.fromJson(item, type))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint("Error fetching history: $e");
      return [];
    }
  }

  Future<List<ProjectModel>> fetchProjects(organizaitonId, userId) async {
    final response = await DioClient.dio.get(
      '/leads/projects_list?organization_id=$organizaitonId&organization_user_id=$userId',
    );
    if (response.statusCode == 200) {
      List data = response.data['project_list'];
      return data.map((item) => ProjectModel.fromJson(item)).toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> updateBookingStatus(
    BookingUpdateRequest bookingUpdate,
  ) async {
    debugPrint("this is bookingupadate create => ${bookingUpdate.toJson()}");
    final response = await DioClient.dio.post(
      '/leads/update_booking_lifecycle',
      data: bookingUpdate.toJson(),
    );
    return response.data;
  }

  Future<List<UserFetchModel>> fetchUsers(int userId) async {
    final response = await DioClient.dio.get(
      '/users/get-users?user_id=$userId',
    );
    if (response.statusCode == 200) {
      List data = response.data['user_list'];
      return data.map((item) => UserFetchModel.fromJson(item)).toList();
    }
    return [];
  }

  Future<Map<String, int>?> fetchDashboardCounts(int userId) async {
    try {
      final response = await DioClient.dio.get('/leads/counts/$userId');

      if (response.data['status'] == 1) {
        // Extract the nested 'data' object
        final Map<String, dynamic> rawData = response.data['data'];

        // Explicitly map each key to ensure they exist
        return {
          'new_leads_today': rawData['new_leads_today'] ?? 0,
          'followups_today': rawData['followups_today'] ?? 0,
          'meetings_today': rawData['meetings_today'] ?? 0,
          'booked_today':
              rawData['booked_today'] ?? 0, // Ensure this matches JSON
        };
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<BookingDeatails?> fetchBookingDetails(int bookingId) async {
    try {
      final response = await DioClient.dio.get(
        "/calls/booking_deatils?booking_id=$bookingId",
      );

      if (response.statusCode == 200 && response.data['status'] == 1) {
        List dataList = response.data['data'];

        if (dataList.isNotEmpty) {
          return BookingDeatails.fromJson(dataList.first);
        }
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<List<ProjectMedia>> fetchProjectMedia(int projectId) async {
    try {
      final response = await DioClient.dio.get(
        '/leads/get_projects_media/$projectId',
      );
      if (response.statusCode == 200) {
        if (response.data['status'] == 1) {
          final List data = response.data['data'];
          return data.map((item) => ProjectMedia.fromJson(item)).toList();
        } else {
          throw Exception(response.data['message']);
        }
      } else {
        throw Exception("Failed to load media: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("General error: $e");
    }
  }

  // get full lead tracking calendor event
  Future<List<CalendarEvent>> fetchLeadTrack(int leadId) async {
    final response = await DioClient.dio.get("/leads/lead_tracking/$leadId");
    final List data = response.data["data"];
    return data.map((e) => CalendarEvent.fromJson(e)).toList();
  }
}
