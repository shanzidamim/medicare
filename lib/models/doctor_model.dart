class Doctor {
  final int id;
  final String fullName;
  final String contact;
  final String degrees;
  final String specialtyDetail;
  final String clinicOrHospital;
  final String address;
  final String visitDays;
  final String visitingTime;
  final String categoryName;
  final String divisionName;
  final String imageUrl;

  Doctor({
    required this.id,
    required this.fullName,
    required this.contact,
    required this.degrees,
    required this.specialtyDetail,
    required this.clinicOrHospital,
    required this.address,
    required this.visitDays,
    required this.visitingTime,
    required this.categoryName,
    required this.divisionName,
    required this.imageUrl,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      fullName: json['full_name'] ?? '',
      contact: json['contact'] ?? '',
      degrees: json['degrees'] ?? '',
      specialtyDetail: json['specialty_detail'] ?? '',
      clinicOrHospital: json['clinic_or_hospital'] ?? '',
      address: json['address'] ?? '',
      visitDays: json['visit_days'] ?? '',
      visitingTime: json['visiting_time'] ?? '',
      categoryName: json['category_name'] ?? '',
      divisionName: json['division_name'] ?? '',
      imageUrl: json['image_url'] ?? '',
    );
  }
}
