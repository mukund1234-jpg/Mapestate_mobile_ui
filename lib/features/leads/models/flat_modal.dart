class FlatModel {
  final int flatId;
  final String flatNumber;
  final int floorNumber;
  final String wingName;

  FlatModel({
    required this.flatId,
    required this.flatNumber,
    required this.floorNumber,
    required this.wingName,
  });

  factory FlatModel.fromJson(Map<String, dynamic> json) {
    return FlatModel(
      flatId: json['flat_id'],
      flatNumber: json['flat_number'],
      floorNumber: json['floor_number'],
      wingName: json['wing_name'],
    );
  }

  // Helper for the dropdown display
  String get displayName => "Wing $wingName - Flat $flatNumber (Floor $floorNumber)";
}