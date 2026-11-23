import 'package:crm_app/features/leads/models/bookingdeatails_model.dart';
import 'package:crm_app/features/leads/models/flat_modal.dart';
import 'package:crm_app/features/leads/models/follow_lead_model.dart';
import 'package:crm_app/features/leads/models/lead_model.dart';
import 'package:crm_app/features/leads/models/lead_track_model.dart';
import 'package:crm_app/features/leads/models/meeting_model.dart';
import 'package:crm_app/features/leads/models/project_media_model.dart';
import 'package:crm_app/features/leads/models/tracking_model.dart';

class LeadState {
  final bool isLoading;
  final bool isMeetingLoading;
  final bool isFollowLoading;
  final bool isBookLoading;
  final bool isTodayLoading;
  final bool isSubmittingOutcome;
  final bool isTrackLoading;
  final bool isProjectLoading;
  final bool isFlateLoading;
  final bool isMoreLoading;
  final List<ProjectMedia> projectMedia;
  final List<FlatModel> flats;
  final List<LeadFetchModel> bookedleads;
  final List<LeadFetchModel> leads;
  final List<LeadTracking> leadTrack;
  final List<FollowUpLead> followLeads;
  final List<MeetingLeadModel> meetingLeads;
  final List<TrackingHistoryModel> trackHistory;
  final List<LeadFetchModel> todayLeads;
  final Map<String, int> counts;
  final BookingDeatails? bookingDeatail;
   final int? selectedFlatId;
   final bool hasMore;
  final int? nextCursor;
  LeadState({
    this.isLoading = false,
    this.isMeetingLoading = false,
    this.isFollowLoading = false,
    this.isTrackLoading = false,
    this.isTodayLoading = false,
    this.isBookLoading = false,
    this.isSubmittingOutcome = false,
    this.isFlateLoading=false,
    this.isProjectLoading = false,
    this.isMoreLoading = false,
    this.projectMedia = const [],
    this.leads = const [],
    this.leadTrack = const [],
    this.followLeads = const [],
    this.meetingLeads = const [],
    this.trackHistory = const [],
    this.bookedleads = const [],
    this.todayLeads = const [],
    this.bookingDeatail,
    this.flats = const [],
    this.counts = const {
      "new_leads_today": 0,
      "followups_today": 0,
      "meetings_today": 0,
      "booked_today": 0,
    },
     this.selectedFlatId,
     this.hasMore = true,
this.nextCursor,
  });

  LeadState copyWith({
    bool? isLoading,
    bool? isMeetingLoading,
    bool? isFollowLoading,
    bool? isTrackLoading,
    bool? isTodayLoading,
    bool? isBookLoading,
    bool? isSubmittingOutcome,
    bool? isFlateLoading,
    bool? isProjectLoading,
    List<ProjectMedia>? projectMedia,
    List<LeadFetchModel>? leads,
    List<LeadTracking>? leadTrack,
    List<FollowUpLead>? followLeads,
    List<MeetingLeadModel>? meetingLeads,
    List<LeadFetchModel>? bookedleads,
    List<LeadFetchModel>? todayLeads,
    List<TrackingHistoryModel>? trackHistory,
     List<FlatModel>? flats,
    Map<String, int>? counts,
    BookingDeatails? bookingDeatail,
    int? selectedFlatId,
   bool? hasMore,
   bool?isMoreLoading,
int? nextCursor,
  }) {
    return LeadState(
      isLoading: isLoading ?? this.isLoading,
      isMeetingLoading: isMeetingLoading ?? this.isMeetingLoading,
      isFollowLoading: isFollowLoading ?? this.isFollowLoading,
      isTrackLoading: isTrackLoading ?? this.isTrackLoading,
      isBookLoading: isBookLoading ?? this.isBookLoading,
      isTodayLoading: isTodayLoading ?? this.isTodayLoading,
      isFlateLoading: isFlateLoading ?? this.isFlateLoading,
      isProjectLoading: isProjectLoading ?? this.isProjectLoading,
      isSubmittingOutcome:isSubmittingOutcome ?? this.isSubmittingOutcome,
      leads: leads ?? this.leads,
      leadTrack: leadTrack ?? this.leadTrack,
      followLeads: followLeads ?? this.followLeads,
      bookedleads: bookedleads ?? this.bookedleads,
      meetingLeads: meetingLeads ?? this.meetingLeads,
      trackHistory: trackHistory ?? this.trackHistory,
      counts: counts ?? this.counts,
      bookingDeatail: bookingDeatail ?? this.bookingDeatail,
      todayLeads: todayLeads ?? this.todayLeads,
      flats:flats ?? this.flats,
      selectedFlatId: selectedFlatId ?? this.selectedFlatId,
      projectMedia: projectMedia ?? this.projectMedia,
      hasMore:hasMore?? this.hasMore,
      nextCursor:nextCursor ?? this.nextCursor,
      isMoreLoading:isMoreLoading??this.isMoreLoading
    );
  }
}
