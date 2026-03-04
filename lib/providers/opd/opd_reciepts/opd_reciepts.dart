import 'package:flutter/material.dart';

import '../../../core/services/opd_receipt_api_service.dart';
import '../../../core/services/consultation_api_service.dart';
import '../../../core/services/consultant_payments_api_service.dart';
import '../../../global/global_api.dart';
import '../../shift_management/shift_management.dart';
import '../../../models/consultation_model/doctor_model.dart';

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
  final String? imageUrl;

  const OpdService({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.icon,
    required this.color,
    this.imageUrl,
  });
}

class OpdSelectedService {
  final OpdService service;
  String? doctorName;
  String? doctorSpecialty;
  String? doctorAvatar;
  String? doctorDepartment;
  String? doctorSrlNo;

  OpdSelectedService({
    required this.service,
    this.doctorName,
    this.doctorSpecialty,
    this.doctorAvatar,
    this.doctorDepartment,
    this.doctorSrlNo,
  });
}

class OpdProvider extends ChangeNotifier {
  final OpdReceiptApiService _apiService = OpdReceiptApiService();
  final ConsultantPaymentsApiService _paymentApiService =
  ConsultantPaymentsApiService();

  List<DoctorModel> _availableDoctorModels = [];

  // ── Loading / error state ──
  bool _loadingServices = false;
  bool _loadingReceipts = false;
  String? _errorMessage;

  bool get isLoadingServices => _loadingServices;
  bool get isLoadingReceipts => _loadingReceipts;
  String? get errorMessage => _errorMessage;

  OpdProvider() {
    _initStaticServices();
    loadOpdServices();
    loadDoctors();
    loadReceipts();
  }

  // ── Auto MR No counter ──
  int _mrCounter = 6; // starts after 5 mock patients

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
        reference: 'General Physician'),
    OpdPatient(
        mrNo: '000002',
        fullName: 'Fatima Malik',
        phone: '0321-9876543',
        age: '28',
        gender: 'Female',
        address: 'House 5, Block C, Gulberg',
        city: 'Lahore',
        panel: 'EFU',
        reference: 'Specialist'),
    OpdPatient(
        mrNo: '000003',
        fullName: 'Muhammad Ali Khan',
        phone: '0333-5554444',
        age: '52',
        gender: 'Male',
        address: 'Sector G-10, Street 4',
        city: 'Islamabad',
        panel: 'SLIC',
        reference: 'General Physician'),
    OpdPatient(
        mrNo: '000004',
        fullName: 'Ayesha Siddiqui',
        phone: '0345-7778888',
        age: '41',
        gender: 'Female',
        address: 'Flat 3, Pearl Heights, Clifton',
        city: 'Karachi',
        panel: 'Jubilee',
        reference: 'Emergency'),
    OpdPatient(
        mrNo: '000005',
        fullName: 'Usman Tariq',
        phone: '0312-3334455',
        age: '19',
        gender: 'Male',
        address: 'Village Kot Addu',
        city: 'Muzaffargarh',
        panel: 'None',
        reference: 'General Physician'),
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
    'None',
    'State Life',
    'EFU',
    'SLIC',
    'Jubilee',
    'Adamjee',
    'New Hampshire',
    'IGI',
  ];

  // ── References ──
  final List<String> references = const [
    'General Physician',
    'Specialist',
    'Emergency',
    'Self',
    'Referral',
    'Online',
  ];

  // ── OPD Service Categories ──
  final List<Map<String, dynamic>> serviceCategories = const [
    {
      'id': 'opd',
      'label': 'OPD',
      'icon': Icons.local_hospital_rounded,
      'color': Color(0xFFE53935)
    },
    {
      'id': 'consultation',
      'label': 'Consultation',
      'icon': Icons.medical_information_rounded,
      'color': Color(0xFF00B5AD)
    },
    {
      'id': 'xray',
      'label': 'X-Ray',
      'icon': Icons.radio_rounded,
      'color': Color(0xFF1E88E5)
    },
    {
      'id': 'ctscan',
      'label': 'CT-Scan',
      'icon': Icons.document_scanner_rounded,
      'color': Color(0xFF8E24AA)
    },
    {
      'id': 'mri',
      'label': 'MRI',
      'icon': Icons.blur_circular_rounded,
      'color': Color(0xFF00ACC1)
    },
    {
      'id': 'ultrasound',
      'label': 'Ultrasound',
      'icon': Icons.sensors_rounded,
      'color': Color(0xFF43A047)
    },
    {
      'id': 'laboratory',
      'label': 'Laboratory',
      'icon': Icons.biotech_rounded,
      'color': Color(0xFFF4511E)
    },
    {
      'id': 'emergency',
      'label': 'Emergency',
      'icon': Icons.emergency_rounded,
      'color': Color(0xFFE53935)
    },
  ];

  // ── Services per Category (API + static) ──
  final Map<String, List<OpdService>> services = {};

  void _initStaticServices() {
    services.clear();
    services.addAll({
      'consultation': [],
      'xray': [
        OpdService(
            id: 'xr1',
            name: 'Chest X-Ray',
            category: 'xray',
            price: 800,
            icon: Icons.radio_rounded,
            color: Color(0xFF1E88E5)),
        OpdService(
            id: 'xr2',
            name: 'Spine X-Ray',
            category: 'xray',
            price: 1000,
            icon: Icons.radio_rounded,
            color: Color(0xFF1E88E5)),
        OpdService(
            id: 'xr3',
            name: 'Hand/Wrist X-Ray',
            category: 'xray',
            price: 600,
            icon: Icons.radio_rounded,
            color: Color(0xFF1E88E5)),
      ],
      'ctscan': [
        OpdService(
            id: 'ct1',
            name: 'CT Head',
            category: 'ctscan',
            price: 5000,
            icon: Icons.document_scanner_rounded,
            color: Color(0xFF8E24AA)),
        OpdService(
            id: 'ct2',
            name: 'CT Chest',
            category: 'ctscan',
            price: 6000,
            icon: Icons.document_scanner_rounded,
            color: Color(0xFF8E24AA)),
        OpdService(
            id: 'ct3',
            name: 'CT Abdomen',
            category: 'ctscan',
            price: 7000,
            icon: Icons.document_scanner_rounded,
            color: Color(0xFF8E24AA)),
      ],
      'mri': [
        OpdService(
            id: 'mr1',
            name: 'MRI Brain',
            category: 'mri',
            price: 8000,
            icon: Icons.blur_circular_rounded,
            color: Color(0xFF00ACC1)),
        OpdService(
            id: 'mr2',
            name: 'MRI Spine',
            category: 'mri',
            price: 9000,
            icon: Icons.blur_circular_rounded,
            color: Color(0xFF00ACC1)),
        OpdService(
            id: 'mr3',
            name: 'MRI Knee',
            category: 'mri',
            price: 7500,
            icon: Icons.blur_circular_rounded,
            color: Color(0xFF00ACC1)),
      ],
      'ultrasound': [
        OpdService(
            id: 'us1',
            name: 'Abdominal Ultrasound',
            category: 'ultrasound',
            price: 1500,
            icon: Icons.sensors_rounded,
            color: Color(0xFF43A047)),
        OpdService(
            id: 'us2',
            name: 'Pelvic Ultrasound',
            category: 'ultrasound',
            price: 1500,
            icon: Icons.sensors_rounded,
            color: Color(0xFF43A047)),
        OpdService(
            id: 'us3',
            name: 'Thyroid Ultrasound',
            category: 'ultrasound',
            price: 1200,
            icon: Icons.sensors_rounded,
            color: Color(0xFF43A047)),
      ],
      'laboratory': [
        OpdService(
            id: 'lb1',
            name: 'CBC (Complete Blood Count)',
            category: 'laboratory',
            price: 500,
            icon: Icons.biotech_rounded,
            color: Color(0xFFF4511E)),
        OpdService(
            id: 'lb2',
            name: 'LFTs (Liver Function Test)',
            category: 'laboratory',
            price: 800,
            icon: Icons.biotech_rounded,
            color: Color(0xFFF4511E)),
        OpdService(
            id: 'lb3',
            name: 'RFTs (Renal Function Test)',
            category: 'laboratory',
            price: 800,
            icon: Icons.biotech_rounded,
            color: Color(0xFFF4511E)),
        OpdService(
            id: 'lb4',
            name: 'Blood Sugar (Fasting)',
            category: 'laboratory',
            price: 200,
            icon: Icons.biotech_rounded,
            color: Color(0xFFF4511E)),
        OpdService(
            id: 'lb5',
            name: 'HbA1c',
            category: 'laboratory',
            price: 1200,
            icon: Icons.biotech_rounded,
            color: Color(0xFFF4511E)),
        OpdService(
            id: 'lb6',
            name: 'Lipid Profile',
            category: 'laboratory',
            price: 1000,
            icon: Icons.biotech_rounded,
            color: Color(0xFFF4511E)),
        OpdService(
            id: 'lb7',
            name: 'Urine Analysis',
            category: 'laboratory',
            price: 300,
            icon: Icons.biotech_rounded,
            color: Color(0xFFF4511E)),
      ],
      'emergency': [
        OpdService(
            id: 'em1',
            name: 'Emergency Consultation',
            category: 'emergency',
            price: 2500,
            icon: Icons.emergency_rounded,
            color: Color(0xFFE53935)),
        OpdService(
            id: 'em2',
            name: 'Trauma Care',
            category: 'emergency',
            price: 5000,
            icon: Icons.emergency_rounded,
            color: Color(0xFFE53935)),
        OpdService(
            id: 'em3',
            name: 'Resuscitation',
            category: 'emergency',
            price: 3500,
            icon: Icons.emergency_rounded,
            color: Color(0xFFE53935)),
        OpdService(
            id: 'em4',
            name: 'Emergency Surgery Prep',
            category: 'emergency',
            price: 4000,
            icon: Icons.emergency_rounded,
            color: Color(0xFFE53935)),
      ],
    });
  }

  // ── Load OPD Services from API ──
  Future<void> loadOpdServices() async {
    _loadingServices = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _apiService.fetchOpdServices();

    if (result.success) {
      final apiServices = result.services
          .where((s) =>
      s.isActive == 1 &&
          (s.allowOpdService != 0 ||
              s.serviceHead.toLowerCase() == 'opd'))
          .map((s) {
        final rate = double.tryParse(s.serviceRate) ?? 0.0;
        Color color;
        IconData icon;
        switch (s.serviceHead.toLowerCase()) {
          case 'emergency':
            color = const Color(0xFFE53935);
            icon = Icons.emergency_rounded;
            break;
          case 'opd':
          default:
            color = const Color(0xFFE53935);
            icon = Icons.local_hospital_rounded;
        }
        final baseUrlRoot = GlobalApi.baseUrl.replaceAll('/api', '');
        final imageUrl = s.imageUrl != null && s.imageUrl!.isNotEmpty
            ? (s.imageUrl!.startsWith('http')
            ? s.imageUrl
            : '$baseUrlRoot${s.imageUrl}')
            : null;

        return OpdService(
          id: s.serviceId,
          name: s.serviceName,
          category: 'opd',
          price: rate,
          icon: icon,
          color: color,
          imageUrl: imageUrl,
        );
      }).toList();

      services['opd'] = apiServices;
      _errorMessage = null;
    } else {
      _errorMessage = result.message;
    }

    _loadingServices = false;
    notifyListeners();
  }

  // ── Load Doctors (Consultation category) ──
  final ConsultationApiService _consultationApi = ConsultationApiService();

  Future<void> loadDoctors() async {
    final result = await _consultationApi.fetchDoctors();
    if (result.success && result.doctors.isNotEmpty) {
      final colors = [
        const Color(0xFF00B5AD),
        const Color(0xFF8E24AA),
        const Color(0xFF1E88E5),
        const Color(0xFFE53935),
        const Color(0xFF43A047),
        const Color(0xFFF4511E),
        const Color(0xFF00897B),
        const Color(0xFFD81B60),
      ];
      final doctorServices = result.doctors
          .where((d) => d.isActive == 1)
          .toList()
          .asMap()
          .entries
          .map((entry) {
        final i = entry.key;
        final d = entry.value;
        final fee = double.tryParse(d.consultationFee) ?? 0.0;
        final spec = d.doctorSpecialization.isNotEmpty
            ? ' (${d.doctorSpecialization})'
            : '';
        final baseUrlRoot = GlobalApi.baseUrl.replaceAll('/api', '');
        final imageUrl = d.imageUrl != null && d.imageUrl!.isNotEmpty
            ? (d.imageUrl!.startsWith('http')
            ? d.imageUrl
            : '$baseUrlRoot${d.imageUrl}')
            : null;

        return OpdService(
          id: d.doctorId,
          name: 'Dr. ${d.doctorName}$spec',
          category: 'consultation',
          price: fee,
          icon: Icons.person_rounded,
          color: colors[i % colors.length],
          imageUrl: imageUrl,
        );
      }).toList();
      services['consultation'] = doctorServices;
      _availableDoctorModels = result.doctors;
      notifyListeners();
    }
  }

  // ── Selected Services ──
  final List<OpdSelectedService> _selectedServices = [];

  List<OpdSelectedService> get selectedServices =>
      List.unmodifiable(_selectedServices);

  void addService(OpdService service) {
    if (!_selectedServices.any((s) => s.service.id == service.id)) {
      String? dept;
      String? srl;
      String? dName;

      if (service.category == 'consultation') {
        final doc = _availableDoctorModels.firstWhere(
          (d) => d.doctorId == service.id,
          orElse: () => _availableDoctorModels.firstWhere((d) => 'Dr. ${d.doctorName}' == service.name.split(' (')[0], orElse: () => _availableDoctorModels.first),
        );
        dept = doc.doctorDepartment;
        srl = doc.srlNo.toString();
        dName = doc.doctorName;
      }

      _selectedServices.add(OpdSelectedService(
        service: service,
        doctorName: dName,
        doctorDepartment: dept,
        doctorSrlNo: srl,
      ));
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

  // ── Check if any emergency service is selected ──
  bool get hasEmergencyService =>
      _selectedServices.any((s) => s.service.category == 'emergency');

  // ── Emergency Admission flag ──
  bool _emergencyAdmission = false;
  bool get emergencyAdmission => _emergencyAdmission;
  set emergencyAdmission(bool val) {
    _emergencyAdmission = val;
    notifyListeners();
  }

  // ── Admitted Emergency Patients ──
  final List<Map<String, dynamic>> _admittedEmergencyPatients = [];
  List<Map<String, dynamic>> get admittedEmergencyPatients =>
      List.unmodifiable(_admittedEmergencyPatients);

  void admitEmergencyPatient(Map<String, dynamic> patientData) {
    _admittedEmergencyPatients.add(patientData);
    notifyListeners();
  }

  // ── Saved Receipts ──
  final List<Map<String, dynamic>> _receipts = [
    {
      'receiptNo': 'OPD71946',
      'mrNo': '000003',
      'patientName': 'Usama Arif',
      'age': '27',
      'gender': 'Male',
      'date': DateTime(2026, 2, 21),
      'services': ['Consultation'],
      'details': 'CANCELLED - Dr. Tahir',
      'total': 3000.0,
      'discount': 500.0,
      'paid': 0.0,
      'status': 'Cancelled',
    },
    {
      'receiptNo': 'OPD71947',
      'mrNo': '100003',
      'patientName': 'Tahir',
      'age': '23',
      'gender': 'Male',
      'date': DateTime(2026, 2, 21),
      'services': ['Consultation'],
      'details': 'Dr. Tahir',
      'total': 3000.0,
      'discount': 0.0,
      'paid': 3000.0,
      'status': 'Active',
    },
    {
      'receiptNo': 'OPD71948',
      'mrNo': '000002',
      'patientName': 'Mazhar Shahid',
      'age': '19',
      'gender': 'Male',
      'date': DateTime(2026, 2, 21),
      'services': ['Consultation'],
      'details': 'CANCELLED - Dr. Tahir',
      'total': 3000.0,
      'discount': 0.0,
      'paid': 0.0,
      'status': 'Cancelled',
    },
    {
      'receiptNo': 'OPD71949',
      'mrNo': '100004',
      'patientName': 'M Tahir M Usman',
      'age': '21',
      'gender': 'Male',
      'date': DateTime(2026, 2, 21),
      'services': ['Consultation'],
      'details': 'Dr. Tahir',
      'total': 3000.0,
      'discount': 3000.0,
      'paid': 0.0,
      'status': 'Active',
    },
    {
      'receiptNo': 'OPD71950',
      'mrNo': '100003',
      'patientName': 'Tahir',
      'age': '23',
      'gender': 'Male',
      'date': DateTime(2026, 2, 21),
      'services': ['Consultation'],
      'details': 'Dr. Tahir',
      'total': 3000.0,
      'discount': 3000.0,
      'paid': 0.0,
      'status': 'Active',
    },
    {
      'receiptNo': 'OPD71951',
      'mrNo': '100003',
      'patientName': 'Tahir',
      'age': '23',
      'gender': 'Male',
      'date': DateTime(2026, 2, 22),
      'services': ['OPD'],
      'details': 'Drip',
      'total': 2000.0,
      'discount': 0.0,
      'paid': 2000.0,
      'status': 'Active',
    },
    {
      'receiptNo': 'OPD71952',
      'mrNo': '000001',
      'patientName': 'Ahmed Hassan',
      'age': '35',
      'gender': 'Male',
      'date': DateTime(2026, 2, 22),
      'services': ['Laboratory'],
      'details': 'CBC, LFTs',
      'total': 1300.0,
      'discount': 0.0,
      'paid': 1300.0,
      'status': 'Active',
    },
    {
      'receiptNo': 'OPD71953',
      'mrNo': '000002',
      'patientName': 'Fatima Malik',
      'age': '28',
      'gender': 'Female',
      'date': DateTime(2026, 2, 22),
      'services': ['Consultation'],
      'details': 'Dr. Nida (Gynae)',
      'total': 1200.0,
      'discount': 200.0,
      'paid': 1000.0,
      'status': 'Active',
    },
    {
      'receiptNo': 'OPD71954',
      'mrNo': '000004',
      'patientName': 'Ayesha Siddiqui',
      'age': '41',
      'gender': 'Female',
      'date': DateTime(2026, 2, 23),
      'services': ['X-Ray'],
      'details': 'Chest X-Ray',
      'total': 800.0,
      'discount': 0.0,
      'paid': 800.0,
      'status': 'Active',
    },
    {
      'receiptNo': 'OPD71955',
      'mrNo': '000005',
      'patientName': 'Usman Tariq',
      'age': '19',
      'gender': 'Male',
      'date': DateTime(2026, 2, 23),
      'services': ['OPD'],
      'details': 'OPD Registration',
      'total': 200.0,
      'discount': 0.0,
      'paid': 200.0,
      'status': 'Active',
    },
    {
      'receiptNo': 'OPD71956',
      'mrNo': '000003',
      'patientName': 'Muhammad Ali Khan',
      'age': '52',
      'gender': 'Male',
      'date': DateTime(2026, 2, 23),
      'services': ['MRI'],
      'details': 'MRI Spine',
      'total': 9000.0,
      'discount': 500.0,
      'paid': 8500.0,
      'status': 'Active',
    },
    {
      'receiptNo': 'OPD71957',
      'mrNo': '000001',
      'patientName': 'Ahmed Hassan',
      'age': '35',
      'gender': 'Male',
      'date': DateTime(2026, 2, 23),
      'services': ['Emergency'],
      'details': 'Emergency Consultation',
      'total': 2500.0,
      'discount': 0.0,
      'paid': 2500.0,
      'status': 'Refunded',
    },
    {
      'receiptNo': 'OPD71958',
      'mrNo': '000002',
      'patientName': 'Fatima Malik',
      'age': '28',
      'gender': 'Female',
      'date': DateTime(2026, 2, 23),
      'services': ['Ultrasound'],
      'details': 'Abdominal Ultrasound',
      'total': 1500.0,
      'discount': 0.0,
      'paid': 1500.0,
      'status': 'Active',
    },
    {
      'receiptNo': 'OPD71959',
      'mrNo': '000004',
      'patientName': 'Ayesha Siddiqui',
      'age': '41',
      'gender': 'Female',
      'date': DateTime(2026, 2, 24),
      'services': ['CT-Scan'],
      'details': 'CT Head',
      'total': 5000.0,
      'discount': 500.0,
      'paid': 4500.0,
      'status': 'Active',
    },
  ];

  List<Map<String, dynamic>> get receipts => List.unmodifiable(_receipts);

  Future<void> loadReceipts() async {
    _loadingReceipts = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _apiService.fetchOpdReceipts();

    if (result.success && result.receipts.isNotEmpty) {
      _receipts
        ..clear()
        ..addAll(result.receipts.map((r) {
          DateTime parsedDate;
          try {
            parsedDate = DateTime.parse(r.date);
          } catch (_) {
            parsedDate = DateTime.now();
          }

          return {
            'receiptNo': r.receiptId,
            'mrNo': r.patientMrNumber,
            'patientName': r.patientName,
            'age': r.patientAge?.toString() ?? '',
            'gender': r.patientGender,
            'date': parsedDate,
            'services': r.serviceDetail.isNotEmpty
                ? r.serviceDetail.split(',').map((e) => e.trim()).toList()
                : (r.opdService.isNotEmpty
                ? r.opdService.split(',').map((e) => e.trim()).toList()
                : <String>[]),
            'details': r.serviceDetail,
            'total': r.totalAmount,
            'discount': r.discount,
            'paid': r.paid,
            'status': r.status,
          };
        }));
      _errorMessage = null;
    } else if (!result.success) {
      _errorMessage = result.message;
    }

    _loadingReceipts = false;
    notifyListeners();
  }

  // ── Update receipt status (cancel / refund) ──
  void updateReceiptStatus(int index, String status) {
    if (index < 0 || index >= _receipts.length) return;
    _receipts[index]['status'] = status;
    if (status == 'Cancelled') {
      _receipts[index]['details'] =
      'CANCELLED - ${_receipts[index]['details']}';
    }
    notifyListeners();
  }

  // ── Save new receipt ──
  int _receiptCounter = 71960;

  Future<bool> saveReceipt({
    required OpdPatient patient,
    required List<OpdSelectedService> services,
    required double discount,
    required double amountPaid,
    ShiftModel? currentShift,
  }) async {
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    // ── Snapshot totals BEFORE any clearing ──
    final double totalAmount =
    services.fold(0.0, (sum, s) => sum + s.service.price);
    final double payableAmount =
    (totalAmount - discount).clamp(0.0, double.infinity);
    final double balanceAmount =
    (payableAmount - amountPaid).clamp(0.0, double.infinity);

    final servicesHeads =
    services.map((s) => s.service.category).toSet().toList();
    final detailsList = services.map((s) => s.service.name).toList();

    // ── Doctor info ──
    String? firstDoctorId;
    final consSvc =
    services.where((s) => s.service.category == 'consultation').toList();
    if (consSvc.isNotEmpty) {
      firstDoctorId = consSvc.first.service.id;
    }

    // ── Average dr share (matches React logic) ──
    double avgDrShare = 0;
    if (consSvc.isNotEmpty) {
      // Consultation services get 100% dr share by default
      avgDrShare = 100.0;
    }

    // ── Dr share amount ──
    double totalDrShare = 0;
    final serviceDetails = services.map((s) {
      double drShare = 0;
      if (s.service.category == 'consultation') {
        drShare = s.service.price; // full price goes to doctor
      }
      totalDrShare += drShare;

      return {
        'id': s.service.id,
        'name': s.service.name,
        'rate': s.service.price,
        'qty': 1,
        'total': s.service.price,
        'type': s.service.category,
        'drShare': drShare > 0 ? 100 : 0, // percentage
      };
    }).toList();

    // ── Build payload exactly matching React's handleSubmit ──
    final payload = {
      // NOTE: receipt_id is NOT sent — React does not send it
      'patient_mr_number': patient.mrNo,
      'patient_name': patient.fullName,
      'phone_number': patient.phone.isEmpty ? 'N/A' : patient.phone,
      'patient_age': patient.age, // String — matches React's age.toString()
      'patient_gender': patient.gender,
      'patient_address': patient.address.isEmpty ? 'N/A' : patient.address,
      'city': patient.city.isEmpty ? 'N/A' : patient.city,
      'panel': (patient.panel == 'None' || patient.panel.isEmpty)
          ? 'Private'
          : patient.panel,
      'reference': (patient.reference == 'None' || patient.reference.isEmpty)
          ? 'Self'
          : patient.reference,
      'doctor_id': firstDoctorId,
      'date': dateStr,
      'time': timeStr,
      // ── Service fields ──
      'opd_service': servicesHeads.join(', '),
      'service_detail': detailsList.join(', '),
      'service_details': serviceDetails,
      // ── Amount fields (matches React exactly) ──
      'total_amount': totalAmount,
      'service_amount': totalAmount,
      'discount': discount,
      'payable': payableAmount,          // FIXED: was totalAmount, now after discount
      'paid': amountPaid,                // FIXED: was paid_amount+paid, now just paid
      'balance': balanceAmount,          // FIXED: correct calculation
      // ── Dr share fields ──
      'dr_share': avgDrShare,            // ADDED: was missing
      'dr_share_amount': totalDrShare,
      'hospital_share': totalAmount - totalDrShare,
      // ── Discount meta fields (ADDED — React sends all these) ──
      'opd_discount': discount > 0,
      'discount_amount': discount,
      'discount_reason': null,
      'discount_id': null,
      // ── Patient flags (ADDED — React sends all these) ──
      'patient_token_appointment': false,
      'patient_checked': false,
      'patient_requested_discount': discount > 0,
      // ── Status & payment ──
      'status': 'Active',
      'payment_mode': 'Cash',
      'receipt_type': 'Small',
      // ── Shift ──
      'shift_id': currentShift?.shiftId ?? 0,
      'shift_type': currentShift?.shiftType ?? 'N/A',
      'shift_date': currentShift?.shiftDate ?? dateStr,
      // ── Emergency ──
      'emergency_paid':
      servicesHeads.any((h) => h.toLowerCase() == 'emergency'),
    };

    // ── Debug: log request before sending ──
    debugPrint('══ OPD RECEIPT PAYLOAD ══');
    debugPrint(payload.toString());

    final apiResult = await _apiService.createOpdReceipt(payload);

    // ── Debug: log response ──
    debugPrint('══ OPD RECEIPT RESULT ══');
    debugPrint('success: ${apiResult.success}');
    debugPrint('message: ${apiResult.message}');

    if (!apiResult.success) {
      _errorMessage = apiResult.message;
      notifyListeners();
      return false;
    }

    // ── Create consultant payment records if applicable ──
    for (var svc in services) {
      double drShareAmount = 0;
      if (svc.service.category == 'consultation') {
        drShareAmount = svc.service.price; // 100% share for consultation in this logic
      }

      if (drShareAmount > 0) {
        // Use either svc specific doctor metadata OR fallback to firstDoctorId info
        final dName = svc.doctorName ?? (services.firstWhere((s) => s.doctorName != null, orElse: () => services.first).doctorName ?? 'Unknown');
        final dDept = svc.doctorDepartment ?? '';
        final dId = svc.doctorSrlNo ?? firstDoctorId;

        await _paymentApiService.createConsultantPayment({
          'payment_date': dateStr,
          'payment_time': timeStr,
          'doctor_name': dName,
          'payment_department': dDept,
          'total': svc.service.price,
          'payment_share': 100, // percentage
          'payment_amount': drShareAmount,
          'patient_id': patient.mrNo,
          'patient_date': dateStr,
          'patient_service': svc.service.name,
          'patient_name': patient.fullName,
          'shift_id': currentShift?.shiftId ?? 0,
          'shift_type': currentShift?.shiftType ?? 'N/A',
          'shift_date': currentShift?.shiftDate ?? dateStr,
        });
      }
    }

    final receiptNo = apiResult.receipt?.receiptId ?? 'OPD$_receiptCounter';

    // ── Add to local receipts list BEFORE clearing state ──
    _receipts.add({
      'receiptNo': receiptNo,
      'mrNo': patient.mrNo,
      'patientName': patient.fullName,
      'age': patient.age,
      'gender': patient.gender,
      'date': DateTime.now(),
      'services': services.map((s) => s.service.name).toList(),
      'details': detailsList.join(', '),
      'total': totalAmount,        // uses snapshotted value — safe
      'discount': discount,
      'paid': amountPaid,
      'status': 'Active',
    });
    _receiptCounter++;

    // ── Emergency admission ──
    if (_emergencyAdmission &&
        services.any((s) => s.service.category == 'emergency')) {
      _admittedEmergencyPatients.add({
        'mrNo': patient.mrNo,
        'name': patient.fullName,
        'age': patient.age,
        'gender': patient.gender,
        'phone': patient.phone,
        'address': patient.address,
        'admittedSince': DateTime.now(),
        'receiptNo': receiptNo,
        'emergencyServices': services
            .where((s) => s.service.category == 'emergency')
            .map((s) => s.service.name)
            .toList(),
      });
    }

    // ── Clear state AFTER all local mutations ──
    _emergencyAdmission = false;
    incrementMrNo();
    _selectedServices.clear();
    notifyListeners();
    return true;
  }
}