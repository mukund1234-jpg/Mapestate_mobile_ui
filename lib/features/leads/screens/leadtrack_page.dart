import 'package:crm_app/features/leads/providers/leadTrackEvent_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class LeadtrackPage extends ConsumerStatefulWidget {
  final String customerName;
  final int leadId;

  const LeadtrackPage( this.customerName, this.leadId, {super.key,});

  @override
  ConsumerState<LeadtrackPage> createState() => _LeadtrackScreenState();
}
class _LeadtrackScreenState extends ConsumerState<LeadtrackPage> {

    @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(calendarProvider.notifier).loadEvents(widget.leadId));
  }
@override
Widget build(BuildContext context) {
  final calendarState = ref.watch(calendarProvider);
  final notifier = ref.read(calendarProvider.notifier);

  return Scaffold(
    appBar: AppBar(
      title: Text(widget.customerName),

    ),
    body: Column(
      children: [
        // 1. Progress Bar (Optional but looks great)
        if (calendarState.isLoading)
          const LinearProgressIndicator(minHeight: 2),

        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: calendarState.focusedDay,
          selectedDayPredicate: (day) => isSameDay(calendarState.selectedDay, day),
          onDaySelected: notifier.onDaySelected,
          availableCalendarFormats: const {CalendarFormat.month: 'Month'},
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
          
          eventLoader: (day) => notifier.getEventsForDay(day),
        ),
        
        const Divider(),
        
        // 2. Handle the Event List loading state
        Expanded(
          child: calendarState.isLoading && calendarState.allEvents.isEmpty
              ? const Center(child: Text("Fetching timeline..."))
              : _buildEventList(ref),
        ),
        const SizedBox(height: 40),
      ],
    ),
  );
}
  Widget _buildEventList(WidgetRef ref) {
    final state = ref.watch(calendarProvider);
    final notifier = ref.read(calendarProvider.notifier);
    final events = notifier.getEventsForDay(state.selectedDay);

    if (events.isEmpty) return const Center(child: Text("No events today"));

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];

        // Determine Icon based on Type
        IconData eventIcon;
        Color iconColor;

        switch (event.type.toUpperCase()) {
          case 'BOOKING':
            eventIcon = Icons.account_balance_wallet;
            iconColor = Colors.green;
            break;
          case 'MEETING':
            eventIcon = Icons.groups;
            iconColor = Colors.blue;
            break;
          case 'FOLLOWUP':
            eventIcon = Icons.event_repeat;
            iconColor = Colors.orange;
            break;
          case 'CALL':
            eventIcon = Icons.call;
            iconColor = Colors.indigo;
            break;
          default:
            eventIcon = Icons.notifications;
            iconColor = Colors.grey;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: iconColor.withOpacity(0.1),
                child: Icon(eventIcon, color: iconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.type,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      event.status,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    if (event.notes != null)
                      Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          event.notes!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat('hh:mm a').format(event.date),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
