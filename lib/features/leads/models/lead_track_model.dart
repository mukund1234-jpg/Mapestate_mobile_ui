class LeadTracking {
  final DateTime date;
  final String status;
  final String type;

  LeadTracking({required this.date, required this.status, required this.type});

  factory LeadTracking.fromJson(Map<String, dynamic> json) {
    return LeadTracking(
      date: DateTime.parse(json['date']),
      status: json['status'],
      type: json['type'],
    );
  }
}