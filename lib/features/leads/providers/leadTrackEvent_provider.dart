import 'package:crm_app/features/leads/models/calendore_event.dart';
import 'package:crm_app/features/auth/providers/auth_provider.dart';
import 'package:crm_app/features/leads/services/lead_service.dart';
import 'package:crm_app/features/leads/providers/states/leadCalendorTrack_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
final calendarProvider = StateNotifierProvider<CalendarNotifier, CalendarState>((ref) {
    final authState = ref.watch(authProvider);
  final userId = authState.user?.userId ?? 0;
  return CalendarNotifier(userId);
});


class CalendarNotifier extends StateNotifier<CalendarState> {
   final int userId;
  
  CalendarNotifier( this.userId) : super(CalendarState(
    allEvents: [],
    selectedDay: DateTime.now(),
    focusedDay: DateTime.now(),
  )) ;
  final LeadService _leadService = LeadService();

  Future<void> loadEvents(int leadId) async {
    state = state.copyWith(isLoading: true,allEvents: []);
    try {
      final events = await _leadService.fetchLeadTrack(leadId);
      state = state.copyWith(allEvents: events, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
  List<CalendarEvent> getEventsForDay(DateTime day) {
    return state.allEvents
        .where(
          (event) =>
              event.date.year == day.year &&
              event.date.month == day.month &&
              event.date.day == day.day,
        )
        .toList();
  }
  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    state = CalendarState(allEvents: state.allEvents, selectedDay: selectedDay, focusedDay: focusedDay);
  }
}