class TrackingHistoryModel {
  final int id;
  final String status;
  final String date;
  final String notes;
  final String agent;

  TrackingHistoryModel({
    required this.id,
    required this.status,
    required this.date,
    required this.notes,
    required this.agent,
  });

  factory TrackingHistoryModel.fromJson(Map<String, dynamic> json, String type) {
  return TrackingHistoryModel(
    id: type == "followup" 
        ? (json['follow_id'] ?? 0) 
        : type == "meeting" 
            ? (json['meeting_id'] ?? 0) 
            : (json['history_id'] ?? 0),
    status: json['status'] ?? 'unknown',
    date: json['date'] ?? '',
    notes: json['notes'] ?? 'No notes provided',
    agent: json['agent'] ?? 'Unknown Agent',
  );
}
}