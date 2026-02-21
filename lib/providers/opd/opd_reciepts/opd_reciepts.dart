import 'package:flutter/material.dart';

class OpdPatient {
  final String mrNo;
  final String fullName;
  final String phone;
  final String age;
  final String gender;
  final String address;
  final String city;
  final String panel;
  final String reference;

  const OpdPatient({
    required this.mrNo,
    required this.fullName,
    required this.phone,
    required this.age,
    required this.gender,
    required this.address,
    required this.city,
    required this.panel,
    required this.reference,
  });
}

class OpdService {
  final String id;
  final String name;
  final String category;
  final double price;
  final IconData icon;
  final Color color;

  const OpdService({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.icon,
    required this.color,
  });
}

class OpdSelectedService {
  final OpdService service;
  String? doctorName;
  String? doctorSpecialty;
  String? doctorAvatar;

  OpdSelectedService({
    required this.service,
    this.doctorName,
    this.doctorSpecialty,
    this.doctorAvatar,
  });
}

class OpdProvider extends ChangeNotifier {
  // ── Auto MR No counter ──
  int _mrCounter = 1;

  String get nextMrNo => _mrCounter.toString().padLeft(6, '0');

  void incrementMrNo() {
    _mrCounter++;
    notifyListeners();
  }

  // ── Mock Patients ──
  final List<OpdPatient> _patients = const [
    OpdPatient(
      mrNo: '000001',
      fullName: 'Ahmed Hassan',
      phone: '0300-1234567',
      age: '35',
      gender: 'Male',
      address: '12-B Model Town',
      city: 'Lahore',
      panel: 'State Life',
      reference: 'General Physician',
    ),
    OpdPatient(
      mrNo: '000002',
      fullName: 'Fatima Malik',
      phone: '0321-9876543',
      age: '28',
      gender: 'Female',
      address: 'House 5, Block C, Gulberg',
      city: 'Lahore',
      panel: 'EFU',
      reference: 'Specialist',
    ),
    OpdPatient(
      mrNo: '000003',
      fullName: 'Muhammad Ali Khan',
      phone: '0333-5554444',
      age: '52',
      gender: 'Male',
      address: 'Sector G-10, Street 4',
      city: 'Islamabad',
      panel: 'SLIC',
      reference: 'General Physician',
    ),
    OpdPatient(
      mrNo: '000004',
      fullName: 'Ayesha Siddiqui',
      phone: '0345-7778888',
      age: '41',
      gender: 'Female',
      address: 'Flat 3, Pearl Heights, Clifton',
      city: 'Karachi',
      panel: 'Jubilee',
      reference: 'Emergency',
    ),
    OpdPatient(
      mrNo: '000005',
      fullName: 'Usman Tariq',
      phone: '0312-3334455',
      age: '19',
      gender: 'Male',
      address: 'Village Kot Addu, Muzaffargarh',
      city: 'Muzaffargarh',
      panel: 'None',
      reference: 'General Physician',
    ),
  ];

  OpdPatient? lookupPatient(String mrNo) {
    try {
      return _patients.firstWhere((p) => p.mrNo == mrNo);
    } catch (_) {
      return null;
    }
  }

  // ── Panels ──
  final List<String> panels = const [
    'None', 'State Life', 'EFU', 'SLIC', 'Jubilee',
    'Adamjee', 'New Hampshire', 'IGI',
  ];

  // ── References ──
  final List<String> references = const [
    'General Physician', 'Specialist', 'Emergency',
    'Self', 'Referral', 'Online',
  ];

  // ── OPD Service Categories ──
  final List<Map<String, dynamic>> serviceCategories = const [
    {'id': 'opd',          'label': 'OPD',         'icon': Icons.local_hospital_rounded,   'color': Color(0xFFE53935)},
    {'id': 'consultation', 'label': 'Consultation', 'icon': Icons.medical_information_rounded, 'color': Color(0xFF00B5AD)},
    {'id': 'xray',         'label': 'X-Ray',        'icon': Icons.radio_rounded,            'color': Color(0xFF1E88E5)},
    {'id': 'ctscan',       'label': 'CT-Scan',      'icon': Icons.document_scanner_rounded, 'color': Color(0xFF8E24AA)},
    {'id': 'mri',          'label': 'MRI',          'icon': Icons.blur_circular_rounded,    'color': Color(0xFF00ACC1)},
    {'id': 'ultrasound',   'label': 'Ultrasound',   'icon': Icons.sensors_rounded,          'color': Color(0xFF43A047)},
    {'id': 'lab',          'label': 'Lab Tests',    'icon': Icons.biotech_rounded,          'color': Color(0xFFF4511E)},
    {'id': 'pharmacy',     'label': 'Pharmacy',     'icon': Icons.medication_rounded,       'color': Color(0xFF039BE5)},
    {'id': 'ecg',          'label': 'ECG',          'icon': Icons.monitor_heart_rounded,    'color': Color(0xFFE67E22)},
    {'id': 'physiotherapy','label': 'Physiotherapy','icon': Icons.self_improvement_rounded, 'color': Color(0xFF26A69A)},
  ];

  // ── Services per Category ──
  final Map<String, List<OpdService>> services = const {
    'opd': [
      OpdService(id: 'opd1', name: 'OPD Registration', category: 'opd', price: 200, icon: Icons.app_registration_rounded, color: Color(0xFFE53935)),
      OpdService(id: 'opd2', name: 'OPD Follow-Up', category: 'opd', price: 100, icon: Icons.repeat_rounded, color: Color(0xFFE53935)),
    ],
    'consultation': [
      OpdService(id: 'con1', name: 'Dr. Tahir (Neuro)', category: 'consultation', price: 1500, icon: Icons.person_rounded, color: Color(0xFF00B5AD)),
      OpdService(id: 'con2', name: 'Dr. Sara (Cardio)', category: 'consultation', price: 2000, icon: Icons.person_rounded, color: Color(0xFF00B5AD)),
      OpdService(id: 'con3', name: 'Dr. Raza (Ortho)', category: 'consultation', price: 1800, icon: Icons.person_rounded, color: Color(0xFF00B5AD)),
      OpdService(id: 'con4', name: 'Dr. Nida (Gynae)', category: 'consultation', price: 1200, icon: Icons.person_rounded, color: Color(0xFF00B5AD)),
    ],
    'xray': [
      OpdService(id: 'xr1', name: 'Chest X-Ray', category: 'xray', price: 800, icon: Icons.radio_rounded, color: Color(0xFF1E88E5)),
      OpdService(id: 'xr2', name: 'Spine X-Ray', category: 'xray', price: 1000, icon: Icons.radio_rounded, color: Color(0xFF1E88E5)),
      OpdService(id: 'xr3', name: 'Hand/Wrist X-Ray', category: 'xray', price: 600, icon: Icons.radio_rounded, color: Color(0xFF1E88E5)),
    ],
    'ctscan': [
      OpdService(id: 'ct1', name: 'CT Head', category: 'ctscan', price: 5000, icon: Icons.document_scanner_rounded, color: Color(0xFF8E24AA)),
      OpdService(id: 'ct2', name: 'CT Chest', category: 'ctscan', price: 6000, icon: Icons.document_scanner_rounded, color: Color(0xFF8E24AA)),
      OpdService(id: 'ct3', name: 'CT Abdomen', category: 'ctscan', price: 7000, icon: Icons.document_scanner_rounded, color: Color(0xFF8E24AA)),
    ],
    'mri': [
      OpdService(id: 'mr1', name: 'MRI Brain', category: 'mri', price: 8000, icon: Icons.blur_circular_rounded, color: Color(0xFF00ACC1)),
      OpdService(id: 'mr2', name: 'MRI Spine', category: 'mri', price: 9000, icon: Icons.blur_circular_rounded, color: Color(0xFF00ACC1)),
      OpdService(id: 'mr3', name: 'MRI Knee', category: 'mri', price: 7500, icon: Icons.blur_circular_rounded, color: Color(0xFF00ACC1)),
    ],
    'ultrasound': [
      OpdService(id: 'us1', name: 'Abdominal Ultrasound', category: 'ultrasound', price: 1500, icon: Icons.sensors_rounded, color: Color(0xFF43A047)),
      OpdService(id: 'us2', name: 'Pelvic Ultrasound', category: 'ultrasound', price: 1500, icon: Icons.sensors_rounded, color: Color(0xFF43A047)),
      OpdService(id: 'us3', name: 'Thyroid Ultrasound', category: 'ultrasound', price: 1200, icon: Icons.sensors_rounded, color: Color(0xFF43A047)),
    ],
    'lab': [
      OpdService(id: 'lb1', name: 'CBC (Complete Blood Count)', category: 'lab', price: 500, icon: Icons.biotech_rounded, color: Color(0xFFF4511E)),
      OpdService(id: 'lb2', name: 'LFTs', category: 'lab', price: 800, icon: Icons.biotech_rounded, color: Color(0xFFF4511E)),
      OpdService(id: 'lb3', name: 'RFTs', category: 'lab', price: 800, icon: Icons.biotech_rounded, color: Color(0xFFF4511E)),
      OpdService(id: 'lb4', name: 'Blood Sugar (Fasting)', category: 'lab', price: 200, icon: Icons.biotech_rounded, color: Color(0xFFF4511E)),
      OpdService(id: 'lb5', name: 'HbA1c', category: 'lab', price: 1200, icon: Icons.biotech_rounded, color: Color(0xFFF4511E)),
    ],
    'pharmacy': [
      OpdService(id: 'ph1', name: 'Paracetamol 500mg (10)', category: 'pharmacy', price: 50, icon: Icons.medication_rounded, color: Color(0xFF039BE5)),
      OpdService(id: 'ph2', name: 'Amoxicillin 500mg (14)', category: 'pharmacy', price: 350, icon: Icons.medication_rounded, color: Color(0xFF039BE5)),
    ],
    'ecg': [
      OpdService(id: 'ec1', name: 'ECG (12-Lead)', category: 'ecg', price: 600, icon: Icons.monitor_heart_rounded, color: Color(0xFFE67E22)),
      OpdService(id: 'ec2', name: 'Holter Monitoring', category: 'ecg', price: 3000, icon: Icons.monitor_heart_rounded, color: Color(0xFFE67E22)),
    ],
    'physiotherapy': [
      OpdService(id: 'pt1', name: 'Initial Assessment', category: 'physiotherapy', price: 800, icon: Icons.self_improvement_rounded, color: Color(0xFF26A69A)),
      OpdService(id: 'pt2', name: 'Session (30 min)', category: 'physiotherapy', price: 500, icon: Icons.self_improvement_rounded, color: Color(0xFF26A69A)),
    ],
  };

  // ── Selected Services ──
  final List<OpdSelectedService> _selectedServices = [];
  List<OpdSelectedService> get selectedServices => List.unmodifiable(_selectedServices);

  void addService(OpdService service) {
    if (!_selectedServices.any((s) => s.service.id == service.id)) {
      _selectedServices.add(OpdSelectedService(service: service));
      notifyListeners();
    }
  }

  void removeService(String serviceId) {
    _selectedServices.removeWhere((s) => s.service.id == serviceId);
    notifyListeners();
  }

  bool isSelected(String serviceId) =>
      _selectedServices.any((s) => s.service.id == serviceId);

  double get servicesTotal =>
      _selectedServices.fold(0.0, (sum, s) => sum + s.service.price);

  void clearServices() {
    _selectedServices.clear();
    notifyListeners();
  }

  // ── Saved Receipts ──
  final List<Map<String, dynamic>> _receipts = [];
  List<Map<String, dynamic>> get receipts => List.unmodifiable(_receipts);

  void saveReceipt({
    required OpdPatient patient,
    required List<OpdSelectedService> services,
    required double discount,
    required double amountPaid,
  }) {
    _receipts.add({
      'mrNo': patient.mrNo,
      'patientName': patient.fullName,
      'date': DateTime.now(),
      'services': services.map((s) => s.service.name).toList(),
      'total': servicesTotal,
      'discount': discount,
      'paid': amountPaid,
    });
    incrementMrNo();
    _selectedServices.clear();
    notifyListeners();
  }
}