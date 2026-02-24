import 'package:flutter/material.dart';

// ── Data Models ──

class EmergencyPatient {
  final String mrNo;
  final String name;
  final String age;
  final String gender;
  final String phone;
  final String address;
  final DateTime admittedSince;
  final String receiptNo;
  final List<String> emergencyServices;

  EmergencyPatient({
    required this.mrNo,
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    required this.address,
    required this.admittedSince,
    this.receiptNo = '',
    this.emergencyServices = const [],
  });
}

class EmergencyService {
  final String id;
  final String name;
  final double price;
  final IconData icon;
  final Color color;

  const EmergencyService({
    required this.id,
    required this.name,
    required this.price,
    required this.icon,
    required this.color,
  });
}

class EmergencyInvestigation {
  final String type;
  final String name;
  EmergencyInvestigation({required this.type, required this.name});
}

class EmergencyMedicine {
  final String name;
  final String dose;
  final String route;
  const EmergencyMedicine({required this.name, required this.dose, required this.route});
}

class EmergencyPrescription {
  final EmergencyMedicine medicine;
  EmergencyPrescription({required this.medicine});
}

// ── Provider ──

class EmergencyProvider extends ChangeNotifier {
  // ── Static MR formatter ──
  static String formatMr(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';
    return int.parse(digits).toString().padLeft(6, '0');
  }

  // ── Queue (mock data + dynamically added from OPD) ──
  final List<EmergencyPatient> _queue = [
    EmergencyPatient(
      mrNo: '000004',
      name: 'Ayesha Siddiqui',
      age: '41',
      gender: 'Female',
      phone: '0345-7778888',
      address: 'Flat 3, Pearl Heights, Clifton',
      admittedSince: DateTime.now().subtract(const Duration(minutes: 45)),
      receiptNo: 'OPD71954',
      emergencyServices: ['Emergency Consultation'],
    ),
    EmergencyPatient(
      mrNo: '000001',
      name: 'Ahmed Hassan',
      age: '35',
      gender: 'Male',
      phone: '0300-1234567',
      address: '12-B Model Town',
      admittedSince: DateTime.now().subtract(const Duration(hours: 1, minutes: 20)),
      receiptNo: 'OPD71957',
      emergencyServices: ['Trauma Care'],
    ),
  ];

  List<EmergencyPatient> get queue => List.unmodifiable(_queue);
  int get queueCount => _queue.length;

  /// Called from OpdProvider via bridge — adds newly admitted patient
  void addPatientFromOpd(Map<String, dynamic> data) {
    final already = _queue.any((p) =>
    p.mrNo == data['mrNo'] &&
        p.admittedSince == data['admittedSince']);
    if (already) return;

    _queue.insert(0, EmergencyPatient(
      mrNo: data['mrNo'] ?? '',
      name: data['name'] ?? '',
      age: data['age'] ?? '',
      gender: data['gender'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      admittedSince: data['admittedSince'] ?? DateTime.now(),
      receiptNo: data['receiptNo'] ?? '',
      emergencyServices: List<String>.from(data['emergencyServices'] ?? []),
    ));
    notifyListeners();
  }

  EmergencyPatient? lookupPatient(String mrNo) {
    try {
      return _queue.firstWhere((p) => p.mrNo == mrNo);
    } catch (_) {
      return null;
    }
  }

  void refresh() => notifyListeners();

  // ── Emergency Services (as list for dropdown) ──
  final List<EmergencyService> emergencyServices = const [
    EmergencyService(
      id: 'es1', name: 'IV Line', price: 300,
      icon: Icons.vaccines_rounded, color: Color(0xFFE53935),
    ),
    EmergencyService(
      id: 'es2', name: 'O₂ Therapy', price: 500,
      icon: Icons.air_rounded, color: Color(0xFF1E88E5),
    ),
    EmergencyService(
      id: 'es3', name: 'Nebulization', price: 400,
      icon: Icons.cloud_rounded, color: Color(0xFF8E24AA),
    ),
    EmergencyService(
      id: 'es4', name: 'ECG', price: 600,
      icon: Icons.monitor_heart_rounded, color: Color(0xFFE53935),
    ),
    EmergencyService(
      id: 'es5', name: 'Catheter', price: 350,
      icon: Icons.water_drop_rounded, color: Color(0xFF43A047),
    ),
    EmergencyService(
      id: 'es6', name: 'Dressing', price: 250,
      icon: Icons.healing_rounded, color: Color(0xFFF4511E),
    ),
    EmergencyService(
      id: 'es7', name: 'Injection', price: 200,
      icon: Icons.medication_rounded, color: Color(0xFF00B5AD),
    ),
    EmergencyService(
      id: 'es8', name: 'Drip', price: 450,
      icon: Icons.local_drink_rounded, color: Color(0xFF1E88E5),
    ),
  ];

  // ── Selected emergency services ──
  final List<EmergencyService> _selectedServices = [];
  List<EmergencyService> get selectedServices => List.unmodifiable(_selectedServices);

  bool isServiceSelected(String id) => _selectedServices.any((s) => s.id == id);

  void toggleService(EmergencyService svc) {
    if (isServiceSelected(svc.id)) {
      _selectedServices.removeWhere((s) => s.id == svc.id);
    } else {
      _selectedServices.add(svc);
    }
    notifyListeners();
  }

  void removeSelectedService(String id) {
    _selectedServices.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  double get servicesTotalPrice =>
      _selectedServices.fold(0.0, (sum, s) => sum + s.price);

  // ── Investigations ──
  final Map<String, List<String>> investigations = const {
    'Lab': [
      'CBC (Complete Blood Count)',
      'LFTs (Liver Function Test)',
      'RFTs (Renal Function Test)',
      'Blood Sugar (Random)',
      'Blood Sugar (Fasting)',
      'HbA1c',
      'Lipid Profile',
      'Urine Analysis',
      'Blood Culture',
      'PT/APTT',
      'Serum Electrolytes',
    ],
    'Ultra Sound': [
      'Abdominal Ultrasound',
      'Pelvic Ultrasound',
      'Thyroid Ultrasound',
      'Cardiac Echo',
      'Renal Ultrasound',
    ],
    'X-Rays': [
      'Chest X-Ray',
      'Spine X-Ray',
      'Hand/Wrist X-Ray',
      'Skull X-Ray',
      'Pelvis X-Ray',
      'Knee X-Ray',
    ],
  };

  final List<EmergencyInvestigation> _addedInvestigations = [];
  List<EmergencyInvestigation> get addedInvestigations => List.unmodifiable(_addedInvestigations);

  void addInvestigation(String type, String name) {
    if (_addedInvestigations.any((i) => i.name == name)) {
      _addedInvestigations.removeWhere((i) => i.name == name);
    } else {
      _addedInvestigations.add(EmergencyInvestigation(type: type, name: name));
    }
    notifyListeners();
  }

  void removeInvestigation(String name) {
    _addedInvestigations.removeWhere((i) => i.name == name);
    notifyListeners();
  }

  // ── Medicines ──
  final List<EmergencyMedicine> medicinesList = const [
    EmergencyMedicine(name: 'Paracetamol 500mg', dose: '1 tab', route: 'Oral'),
    EmergencyMedicine(name: 'Metoclopramide', dose: '10mg', route: 'IV'),
    EmergencyMedicine(name: 'Ondansetron', dose: '4mg', route: 'IV'),
    EmergencyMedicine(name: 'Diclofenac', dose: '75mg', route: 'IM'),
    EmergencyMedicine(name: 'Hydrocortisone', dose: '100mg', route: 'IV'),
    EmergencyMedicine(name: 'Salbutamol', dose: '2.5mg', route: 'Neb'),
    EmergencyMedicine(name: 'Ringer Lactate', dose: '1000ml', route: 'IV Drip'),
    EmergencyMedicine(name: 'Normal Saline', dose: '500ml', route: 'IV Drip'),
    EmergencyMedicine(name: 'Dextrose 5%', dose: '500ml', route: 'IV Drip'),
    EmergencyMedicine(name: 'Ceftriaxone', dose: '1g', route: 'IV'),
    EmergencyMedicine(name: 'Omeprazole', dose: '40mg', route: 'IV'),
    EmergencyMedicine(name: 'Tramadol', dose: '50mg', route: 'IM'),
  ];

  final List<EmergencyPrescription> _prescribedMedicines = [];
  List<EmergencyPrescription> get prescribedMedicines => List.unmodifiable(_prescribedMedicines);

  bool isMedicinePrescribed(String name) =>
      _prescribedMedicines.any((p) => p.medicine.name == name);

  void toggleMedicine(EmergencyMedicine med) {
    if (isMedicinePrescribed(med.name)) {
      _prescribedMedicines.removeWhere((p) => p.medicine.name == med.name);
    } else {
      _prescribedMedicines.add(EmergencyPrescription(medicine: med));
    }
    notifyListeners();
  }

  // ── Save record ──
  void saveRecord({
    required String mrNo,
    required String name,
    required String age,
    required String gender,
    required String phone,
    required String address,
    required String mo,
    required String bed,
    required String complaint,
    required String moNotes,
    required String dischargeOpt,
    required List<EmergencyService> services,
    required List<EmergencyInvestigation> investigations,
    required List<EmergencyPrescription> medicines,
  }) {
    // Remove from queue on discharge
    _queue.removeWhere((p) => p.mrNo == mrNo);
    notifyListeners();
  }

  void clearAll() {
    _selectedServices.clear();
    _addedInvestigations.clear();
    _prescribedMedicines.clear();
    notifyListeners();
  }
}