class OpdReceiptApiModel {
  final int id;
  final String receiptId;
  final String patientMrNumber;
  final String patientName;
  final String phoneNumber;
  final int? patientAge;
  final String patientGender;
  final String? patientAddress;
  final String date; // YYYY-MM-DD
  final String time; // HH:MM:SS
  final String opdService;
  final String serviceDetail;
  final double totalAmount;
  final double discount;
  final double paid;
  final String status;

  OpdReceiptApiModel({
    required this.id,
    required this.receiptId,
    required this.patientMrNumber,
    required this.patientName,
    required this.phoneNumber,
    required this.patientAge,
    required this.patientGender,
    required this.patientAddress,
    required this.date,
    required this.time,
    required this.opdService,
    required this.serviceDetail,
    required this.totalAmount,
    required this.discount,
    required this.paid,
    required this.status,
  });

  factory OpdReceiptApiModel.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic v) =>
        double.tryParse(v?.toString() ?? '0') ?? 0.0;

    return OpdReceiptApiModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id'] ?? 0}') ?? 0,
      receiptId: json['receipt_id'] as String? ?? '',
      patientMrNumber: json['patient_mr_number'] as String? ??
          json['mr_number'] as String? ??
          '',
      patientName: json['patient_name'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ??
          json['phone'] as String? ??
          '',
      patientAge: json['patient_age'] is int
          ? json['patient_age'] as int
          : int.tryParse('${json['patient_age'] ?? ''}'),
      patientGender: json['patient_gender'] as String? ??
          json['gender'] as String? ??
          '',
      patientAddress: json['patient_address'] as String? ??
          json['address'] as String?,
      date: json['date'] as String? ?? '',
      time: json['time'] as String? ?? '',
      opdService: json['opd_service'] as String? ?? '',
      serviceDetail: json['service_detail'] as String? ?? '',
      totalAmount: _toDouble(json['total_amount']),
      discount: _toDouble(json['discount']),
      paid: _toDouble(json['paid']),
      status: json['status'] as String? ?? 'Active',
    );
  }
}

