class BookingUpdateRequest {
  final int leadId;
  final int bookingId;
  final String bookingStatus;
  final String remarks;
  final String feedbackType;

  BookingUpdateRequest({
    required this.leadId,
    required this.bookingId,
    required this.bookingStatus,
    required this.remarks,
    this.feedbackType = "Booking Status Update",
  });

  Map<String, dynamic> toJson() => {
        "lead_id": leadId,
        "booking_id": bookingId,
        "booking_status": bookingStatus,
        "remarks": remarks,
        "feedback_type": feedbackType,
      };
}