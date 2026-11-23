class MeetingOutcomeModel {
  final int leadId;
  final int agentId;
  final String nextAction;

  // Feedback fields (New)
  final String? remarks;       // Captured from _notesController
  final String? feedbackType;  // Captured from the Reason Dropdown

  // Date/Notes logic
  final String? followDate;
  final String? followNotes;
  final String? meetingDate;
  final String? meetingNotes;

  // Booking specific fields
  final int? projectId;
  final int? bookingAmount;
  final String? flatNumber;
  final int? flatId;

  MeetingOutcomeModel({
    required this.leadId,
    required this.agentId,
    required this.nextAction,
    this.remarks,         // Add these
    this.feedbackType,    // Add these
    this.followDate,
    this.followNotes,
    this.meetingDate,
    this.meetingNotes,
    this.projectId,
    this.bookingAmount,
    this.flatNumber,
    this.flatId
  });

  Map<String, dynamic> toJson() {
    return {
      'lead_id': leadId,
      'agent_id': agentId,
      'next_action': nextAction,
      
      // Send remarks and feedback_type for ALL statuses (especially Lost/Booked)
      'remarks': remarks, 
      'feedback_type': feedbackType,

      // Specific logic for scheduling
      'follow_date': nextAction == "followup" ? followDate : null,
      'follow_notes': nextAction == "followup" ? followNotes : null,
      'meeting_date': nextAction == "meeting" ? meetingDate : null,
      'meeting_notes': nextAction == "meeting" ? meetingNotes : null,
      
      // Booking details
      'project_id': nextAction == "booked" ? projectId : null,
      'booking_amount': nextAction == "booked" ? bookingAmount : null,
      'flat_id': nextAction == "booked" ? flatId : null,
    };
  }
}