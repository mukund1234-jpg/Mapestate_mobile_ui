class CalendarEvent {
  final String type;
  final DateTime date;
  final String status;
  final String? notes;

  CalendarEvent({required this.type, required this.date, required this.status, this.notes});

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    // Format: "2026-04-17 05:53:28 AM"
    // Using a simpler parse or intl package is recommended
    return CalendarEvent(
      type: json['type'],
      date: DateTime.parse(json['date'].replaceAll(RegExp(r' [AP]M'), '')), 
      status: json['status'],
      notes: json['notes'],
    );
  }
}

