import 'package:crm_app/features/leads/models/calendore_event.dart';

class CalendarState {
  final List<CalendarEvent> allEvents;
  final DateTime selectedDay;
  final DateTime focusedDay;
  final bool isLoading;

  CalendarState({
    required this.allEvents,
    required this.selectedDay,
    required this.focusedDay,
    this.isLoading = false,
  });
  CalendarState copyWith({
    List<CalendarEvent>? allEvents,
    DateTime? selectedDay,
    DateTime? focusedDay,
    bool? isLoading,
  }) {
    return CalendarState(
      allEvents: allEvents ?? this.allEvents,
      isLoading: isLoading ?? this.isLoading,
      focusedDay: focusedDay ?? this.focusedDay,
      selectedDay: selectedDay ?? this.selectedDay,
    );
  }
}
