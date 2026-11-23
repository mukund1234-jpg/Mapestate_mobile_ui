class CallOutcomeModel {
  final int leadId;
  final int agentId;
  final String callStatus;
  final String? actionType;
  final String? followDate;
  final String? followNotes;
  final String? meetingDate;
  final String? meetingNotes;
  final int? budget;
  final String? bhkConfigure;
  final String? location;
  final String? interestLevel; 
  final String? actioninterest; 
  final String? feedbackType; 
  final String? remarks;
  final String? timeLine;
  CallOutcomeModel({
    required this.leadId,
    required this.agentId,
    required this.callStatus,
    this.actionType,
    this.followDate,
    this.followNotes,
    this.meetingDate,
    this.meetingNotes,
    this.budget,
    this.bhkConfigure,
    this.location,
    this.timeLine,
    this.interestLevel,
    this.actioninterest,
    this.feedbackType, 
    this.remarks,      
  });

  Map<String, dynamic> toJson() {
    return {
      'lead_id': leadId,
      'agent_id': agentId,
      'call_status': callStatus,
      'action_type': actionType,
      'follow_date': followDate,
      'follow_notes': followNotes,
      'meeting_date': meetingDate,
      'meeting_notes': meetingNotes,
      'budget': budget,
      'bhk_configure': bhkConfigure,
      'location': location,
      'interest_level': interestLevel,
      'action_interest': actioninterest,
      'timeline':timeLine,
      'feedback_type': feedbackType,
      'remarks': remarks,
    };
  }
}