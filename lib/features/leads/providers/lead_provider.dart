import 'package:crm_app/features/leads/models/booking_update.dart';
import 'package:crm_app/features/outcome/models/calloutcome_model.dart';
import 'package:crm_app/features/leads/models/lead_data_model.dart'
    show ProjectModel, UserFetchModel;
import 'package:crm_app/features/outcome/models/meetingoutcomemodel.dart';
import 'package:crm_app/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lead_model.dart';
import '../services/lead_service.dart';
import 'states/lead_state.dart';

// Assuming your authProvider returns a user object or an ID
final leadProvider = StateNotifierProvider<LeadController, LeadState>((ref) {
  final authState = ref.watch(authProvider);
  final userId = authState.user?.userId ?? 0;
  return LeadController(userId);
});

class LeadController extends StateNotifier<LeadState> {
  final int userId;
  LeadController(this.userId) : super(LeadState());

  final LeadService _leadService = LeadService();

  Future<LeadResponseModel?> createLead(LeadModel lead) async {
    state = state.copyWith(isLoading: true);
    final response = await _leadService.createLead(lead);
    if (response?.status == 1) {
      await Future.wait([
        loadTodayLeads(),
        loadLeads(),
        loadMeetingLeads(),
        loadFollowLeads(),
      ]);
    }
    state = state.copyWith(isLoading: false);
    return response;
  }

  Future<void> loadLeads({
    bool isLoadMore = false,
    String? status,
    String? searchQuery,
    String? selectedDate,
  }) async {
    // Prevent duplicate calls
    if (state.isMoreLoading || (isLoadMore && !state.hasMore)) return;

    if (isLoadMore) {
      // Only set the "More" loading state for the button
      state = state.copyWith(isMoreLoading: true);
    } else {
      state = state.copyWith(isLoading: true, leads: []);
    }

    final res = await _leadService.fetchLeads(
      userId,
      lastId: isLoadMore ? state.nextCursor : null,
      status: status,
      search: searchQuery,
      date: selectedDate,
    );

    if (res != null) {
      state = state.copyWith(
        isLoading: false,
        isMoreLoading: false,
        leads: isLoadMore ? [...state.leads, ...res.leads] : res.leads,
        hasMore: res.hasMore,
        nextCursor: res.nextCursor,
      );
    } else {
      state = state.copyWith(isLoading: false, isMoreLoading: false);
    }
  }

  Future<void> loadFollowLeads({
    bool isLoadMore = false,
    String? status,
    String? searchQuery,
    String? selectedDate,
  }) async {
    if (state.isMoreLoading || (isLoadMore && !state.hasMore)) return;

    if (isLoadMore) {
      state = state.copyWith(isMoreLoading: true);
    } else {
      state = state.copyWith(isFollowLoading: true, followLeads: []);
    }

    try {
      final res = await _leadService.fetchFollowUpLeads(
        userId,
        lastId: isLoadMore ? state.nextCursor : null,
        status: status,
        search: searchQuery,
        date: selectedDate,
      );
      if (res != null) {
        state = state.copyWith(
          isFollowLoading: false,
          isMoreLoading: false,
          followLeads: isLoadMore
              ? [...state.followLeads, ...res.leads]
              : res.leads,
          hasMore: res.hasMore,
          nextCursor: res.nextCursor,
        );
      } else {
        state = state.copyWith(isFollowLoading: false, isMoreLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isFollowLoading: false);
    }
  }

  Future<void> loadMeetingLeads({
    bool isLoadMore = false,
    String? status,
    String? searchQuery,
    String? selectedDate,
  }) async {
    if (state.isMoreLoading || (isLoadMore && !state.hasMore)) return;

    if (isLoadMore) {
      state = state.copyWith(isMoreLoading: true);
    } else {
      state = state.copyWith(isMeetingLoading: true, meetingLeads: []);
    }
    try {
      final res = await _leadService.fetchMeetingList(
        userId,
        lastId: isLoadMore ? state.nextCursor : null,
        status: status,
        search: searchQuery,
        date: selectedDate,
      );
      if (res != null) {
        state = state.copyWith(
          isMeetingLoading: false,
          isMoreLoading: false,
          meetingLeads: isLoadMore
              ? [...state.meetingLeads, ...res.leads]
              : res.leads,
          hasMore: res.hasMore,
          nextCursor: res.nextCursor,
        );
      } else {
        state = state.copyWith(isMeetingLoading: false, isMoreLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isMeetingLoading: false, isMoreLoading: false);
    }
  }

  Future<void> loadTodayLeads() async {
    state = state.copyWith(isTodayLoading: true);

    final res = await _leadService.fetchTodayLeads(userId);

    state = state.copyWith(isTodayLoading: false, todayLeads: res?.leads);
  }

  Future<void> loadbookedLeads() async {
    state = state.copyWith(isBookLoading: true);

    final res = await _leadService.fetchBookedLeads(userId);

    state = state.copyWith(isBookLoading: false, bookedleads: res?.leads);
  }

  Future<void> getBookingDetail(int bookingId) async {
    state = state.copyWith(isBookLoading: true);
    try {
      final detail = await _leadService.fetchBookingDetails(bookingId);
      state = state.copyWith(bookingDeatail: detail, isBookLoading: false);
    } catch (e) {
      debugPrint("Error fetching booking: $e");
    }
    state = state.copyWith(isBookLoading: false, bookingDeatail: null);
  }

  Future<void> loadLeadsTrack(int id) async {
    state = state.copyWith(isLoading: true);

    final leads = await _leadService.fetchLeadTracking(id);

    state = state.copyWith(isLoading: false, leadTrack: leads);
  }

  Future<void> saveCallOutcome(CallOutcomeModel outcome) async {
    state = state.copyWith(isSubmittingOutcome: true);

    final success = await _leadService.submitCallOutcome(outcome);

    if (success) {
      await Future.wait([loadLeads(), loadMeetingLeads(), loadFollowLeads()]);
    } else {
      state = state.copyWith(isSubmittingOutcome: false);
    }
    state = state.copyWith(isSubmittingOutcome: false);
  }

  Future<void> completeMeetingOutcome(MeetingOutcomeModel outcome) async {
    state = state.copyWith(isLoading: true);

    final success = await _leadService.submitMeetingOutcome(outcome);

    if (success) {
      await Future.wait([loadLeads(), loadMeetingLeads(), loadFollowLeads()]);
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> fetchTrackingHistory(int leadId, String type) async {
    state = state.copyWith(isTrackLoading: true, trackHistory: []);

    try {
      final history = await _leadService.getTrackingHistory(leadId, type);
      state = state.copyWith(isTrackLoading: false, trackHistory: history);
    } catch (e) {
      state = state.copyWith(isTrackLoading: false);
    }
  }

  Future<void> loadDashboardCounts() async {
    final data = await _leadService.fetchDashboardCounts(userId);
    if (data != null) {
      state = state.copyWith(counts: data);
    }
  }

  Future<void> fetchProjectFlats(int projectId) async {
    // 1. Set loading to true
    state = state.copyWith(isFlateLoading: true);

    try {
      final fetchedFlats = await _leadService.fetchFlats(projectId);

      final isValid = fetchedFlats.any((f) => f.flatId == state.selectedFlatId);

      state = state.copyWith(
        flats: fetchedFlats,
        selectedFlatId: isValid ? state.selectedFlatId : null,
        isFlateLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isFlateLoading: false);
    }
  }

  void onFlatSelected(int? flatId) {
    state = state.copyWith(selectedFlatId: flatId);
  }

  // You should call this inside your refresh or init logic
  Future<void> refreshDashboard() async {
    state = state.copyWith(isLoading: true);
    await Future.wait([loadLeads(), loadDashboardCounts()]);
    state = state.copyWith(isLoading: false);
  }

  Future<void> loadProjectMedia(projectId) async {
    state = state.copyWith(isProjectLoading: true);
    try {
      final media = await _leadService.fetchProjectMedia(projectId);
      state = state.copyWith(isProjectLoading: false, projectMedia: media);
    } catch (e) {
      state = state.copyWith(isProjectLoading: false);
    }
  }

  Future<void> updateBookingLifecycle(BookingUpdateRequest book) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _leadService.updateBookingStatus(book);
      return response["message"];
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final apiServiceProvider = Provider((ref) => LeadService());

final projectProvider = FutureProvider<List<ProjectModel>>((ref) async {
  final authState = ref.watch(authProvider);
  final user = authState.user;
  return ref
      .read(apiServiceProvider)
      .fetchProjects(user!.organizationId, user.userId);
});

final userProvider = FutureProvider<List<UserFetchModel>>((ref) async {
  final authState = ref.watch(authProvider);
  final userId = authState.user?.userId ?? 0;
  return ref.read(apiServiceProvider).fetchUsers(userId);
});

final navIndexProvider = StateProvider<int>((ref) => 0);
