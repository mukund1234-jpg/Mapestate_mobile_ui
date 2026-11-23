class BookingDeatails {
  final int? bookingId;
  final int? leadId;
  final String? customerName;
  final String? date;
  final int? bookingAmount;
  final String? projectName;
  final String? agentName;
  final int? flatId;
  final String? flatNumber;
  final String? wingName;
  final String? flatType;
  final int? floor;
  final String? leadStatus;
  final String? bookingRemark;

  BookingDeatails({
    this.bookingId,
    this.leadId,
    this.customerName,
    this.date,
    this.bookingAmount,
    this.projectName,
    this.agentName,
    this.flatId,
    this.flatNumber,
    this.wingName,
    this.flatType,
    this.floor,
    this.leadStatus,
    this.bookingRemark
  });

  factory BookingDeatails.fromJson(Map<String, dynamic> json) {
    return BookingDeatails(
      bookingId: json['booking_id'],
      leadId: json['lead_id'],
      customerName: json['customer_name'],
      date: json['date'],
      bookingAmount: json['booking_amount'],
      projectName: json['project_name'],
      agentName: json['agent_name'], // Fixed: matches JSON agent_name
      flatId: json['flat_id'],
      flatNumber: json['flat_number'], // Fixed: matches JSON flat_number
      wingName: json['wing_name'],
      flatType: json['flat_type'],
      floor: json['floor'],
      leadStatus: json['lead_status'],
      bookingRemark: json['feedback_note'],
    );
  }
}