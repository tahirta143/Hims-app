// voucher_model.dart
// Pure model/entity classes for Discount Voucher Approval

class ServiceItem {
  final int srNo;
  final String service;
  final String type;
  final double rate;
  final int qty;

  const ServiceItem({
    required this.srNo,
    required this.service,
    required this.type,
    required this.rate,
    required this.qty,
  });

  double get total => rate * qty;

  ServiceItem copyWith({
    int? srNo,
    String? service,
    String? type,
    double? rate,
    int? qty,
  }) {
    return ServiceItem(
      srNo: srNo ?? this.srNo,
      service: service ?? this.service,
      type: type ?? this.type,
      rate: rate ?? this.rate,
      qty: qty ?? this.qty,
    );
  }

  Map<String, dynamic> toMap() => {
    'srNo': srNo,
    'service': service,
    'type': type,
    'rate': rate,
    'qty': qty,
  };

  factory ServiceItem.fromMap(Map<String, dynamic> map) => ServiceItem(
    srNo: map['srNo'] as int,
    service: map['service'] as String,
    type: map['type'] as String,
    rate: (map['rate'] as num).toDouble(),
    qty: map['qty'] as int,
  );
}

class VoucherDetail {
  final String invoiceId;
  final String date;
  final String time;
  final String patientName;
  final int age;
  final String gender;
  final String phone;
  final String address;
  final List<ServiceItem> services;
  final double discountPercentage;
  final VoucherStatus status;

  const VoucherDetail({
    required this.invoiceId,
    required this.date,
    required this.time,
    required this.patientName,
    required this.age,
    required this.gender,
    required this.phone,
    required this.address,
    required this.services,
    required this.discountPercentage,
    this.status = VoucherStatus.pending,
  });

  double get total => services.fold(0, (sum, s) => sum + s.total);
  double get discountAmount => total * discountPercentage / 100;
  double get payable => total - discountAmount;

  VoucherDetail copyWith({
    String? invoiceId,
    String? date,
    String? time,
    String? patientName,
    int? age,
    String? gender,
    String? phone,
    String? address,
    List<ServiceItem>? services,
    double? discountPercentage,
    VoucherStatus? status,
  }) {
    return VoucherDetail(
      invoiceId: invoiceId ?? this.invoiceId,
      date: date ?? this.date,
      time: time ?? this.time,
      patientName: patientName ?? this.patientName,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      services: services ?? this.services,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() => {
    'invoiceId': invoiceId,
    'date': date,
    'time': time,
    'patientName': patientName,
    'age': age,
    'gender': gender,
    'phone': phone,
    'address': address,
    'services': services.map((s) => s.toMap()).toList(),
    'discountPercentage': discountPercentage,
    'status': status.name,
  };

  factory VoucherDetail.fromMap(Map<String, dynamic> map) => VoucherDetail(
    invoiceId: map['invoiceId'] as String,
    date: map['date'] as String,
    time: map['time'] as String,
    patientName: map['patientName'] as String,
    age: map['age'] as int,
    gender: map['gender'] as String,
    phone: map['phone'] as String,
    address: map['address'] as String,
    services: (map['services'] as List)
        .map((s) => ServiceItem.fromMap(s as Map<String, dynamic>))
        .toList(),
    discountPercentage: (map['discountPercentage'] as num).toDouble(),
    status: VoucherStatus.values.byName(map['status'] as String),
  );
}

enum VoucherStatus { pending, approved, rejected }

class DiscountAuthority {
  final String id;
  final String name;
  final String department;
  final double totalLimit;
  final double usedLimit;

  const DiscountAuthority({
    required this.id,
    required this.name,
    required this.department,
    required this.totalLimit,
    required this.usedLimit,
  });

  double get availableLimit => totalLimit - usedLimit;

  DiscountAuthority copyWith({
    String? id,
    String? name,
    String? department,
    double? totalLimit,
    double? usedLimit,
  }) {
    return DiscountAuthority(
      id: id ?? this.id,
      name: name ?? this.name,
      department: department ?? this.department,
      totalLimit: totalLimit ?? this.totalLimit,
      usedLimit: usedLimit ?? this.usedLimit,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'department': department,
    'totalLimit': totalLimit,
    'usedLimit': usedLimit,
  };

  factory DiscountAuthority.fromMap(Map<String, dynamic> map) =>
      DiscountAuthority(
        id: map['id'] as String,
        name: map['name'] as String,
        department: map['department'] as String,
        totalLimit: (map['totalLimit'] as num).toDouble(),
        usedLimit: (map['usedLimit'] as num).toDouble(),
      );
}