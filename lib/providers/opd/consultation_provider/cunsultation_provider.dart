import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  MODEL
// ─────────────────────────────────────────────
class ConsultationAppointment {
  final String id;
  final String consultantName;
  final String specialty;
  final String consultationFee;
  final String followUpCharges;
  final List<String> availableDays;
  final String timings;
  final String hospital;
  final String mrNo;
  final String patientName;
  final String contactNo;
  final String address;
  final bool isFirstVisit;
  final DateTime appointmentDate;
  final String timeSlot;
  final String type;
  final String status;

  ConsultationAppointment({
    required this.id,
    required this.consultantName,
    required this.specialty,
    required this.consultationFee,
    required this.followUpCharges,
    required this.availableDays,
    required this.timings,
    required this.hospital,
    required this.mrNo,
    required this.patientName,
    required this.contactNo,
    required this.address,
    required this.isFirstVisit,
    required this.appointmentDate,
    required this.timeSlot,
    required this.type,
    required this.status,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'doctor': consultantName,
    'specialty': specialty,
    'date': _formatDate(appointmentDate),
    'time': timeSlot,
    'type': type,
    'status': status,
    'icon': type == 'Video Call'
        ? Icons.videocam_rounded
        : Icons.local_hospital_rounded,
  };

  static String _formatDate(DateTime d) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

// ─────────────────────────────────────────────
//  PROVIDER
// ─────────────────────────────────────────────
class ConsultationProvider extends ChangeNotifier {
  final List<ConsultationAppointment> _appointments = [
    ConsultationAppointment(
      id: '1',
      consultantName: 'Dr. Greg Thorne',
      specialty: 'General Doctor',
      consultationFee: '3000.00',
      followUpCharges: '1500',
      availableDays: ['Mon', 'Wed', 'Fri'],
      timings: '9:00 AM - 1:00 PM',
      hospital: 'WMCTH',
      mrNo: '00001',
      patientName: 'Ali Hassan',
      contactNo: '0300-1234567',
      address: 'House 12, Lahore',
      isFirstVisit: true,
      appointmentDate: DateTime(2025, 2, 24),
      timeSlot: '10:00 AM',
      type: 'Video Call',
      status: 'Upcoming',
    ),
    ConsultationAppointment(
      id: '2',
      consultantName: 'Dr. Sarah Wang',
      specialty: 'Ophthalmologist',
      consultationFee: '4500.00',
      followUpCharges: '2000',
      availableDays: ['Tue', 'Thu'],
      timings: '10:00 AM - 2:00 PM',
      hospital: 'City Hospital',
      mrNo: '00002',
      patientName: 'Fatima Malik',
      contactNo: '0321-9876543',
      address: 'Flat 5, Gulberg, Lahore',
      isFirstVisit: false,
      appointmentDate: DateTime(2025, 2, 26),
      timeSlot: '02:30 PM',
      type: 'In-Person',
      status: 'Upcoming',
    ),
    ConsultationAppointment(
      id: '3',
      consultantName: 'Dr. James Lee',
      specialty: 'Dentist',
      consultationFee: '2000.00',
      followUpCharges: '1000',
      availableDays: ['Mon', 'Tue', 'Wed'],
      timings: '9:27 AM - 1:30 PM',
      hospital: 'WMCTH',
      mrNo: '00003',
      patientName: 'Usman Ahmed',
      contactNo: '0333-5556666',
      address: 'Street 8, DHA, Lahore',
      isFirstVisit: true,
      appointmentDate: DateTime(2025, 2, 14),
      timeSlot: '11:00 AM',
      type: 'Video Call',
      status: 'Completed',
    ),
    ConsultationAppointment(
      id: '4',
      consultantName: 'Dr. Maria Santos',
      specialty: 'Cardiologist',
      consultationFee: '6000.00',
      followUpCharges: '4200',
      availableDays: ['Wed', 'Thu', 'Fri'],
      timings: '9:00 AM - 12:00 PM',
      hospital: 'Heart Care Center',
      mrNo: '00004',
      patientName: 'Zainab Raza',
      contactNo: '0344-1112222',
      address: 'Block B, Johar Town, Lahore',
      isFirstVisit: false,
      appointmentDate: DateTime(2025, 2, 10),
      timeSlot: '09:00 AM',
      type: 'In-Person',
      status: 'Completed',
    ),
    ConsultationAppointment(
      id: '5',
      consultantName: 'Dr. Alex Kim',
      specialty: 'Neurologist',
      consultationFee: '5000.00',
      followUpCharges: '3000',
      availableDays: ['Tue', 'Fri'],
      timings: '11:00 AM - 3:00 PM',
      hospital: 'Neuro Clinic',
      mrNo: '00005',
      patientName: 'Bilal Khan',
      contactNo: '0311-7778888',
      address: 'Plot 22, Model Town, Lahore',
      isFirstVisit: true,
      appointmentDate: DateTime(2025, 2, 6),
      timeSlot: '03:00 PM',
      type: 'Video Call',
      status: 'Cancelled',
    ),
  ];

  List<ConsultationAppointment> get appointments =>
      List.unmodifiable(_appointments);

  List<Map<String, dynamic>> get appointmentsAsMaps =>
      _appointments.map((a) => a.toMap()).toList();

  // ── Consultants mock data ──
  final List<Map<String, dynamic>> consultants = [
    {
      'name': 'Dr. Greg Thorne',
      'specialty': 'General Doctor',
      'fee': '3000.00',
      'followUp': '1500',
      'days': ['Mon', 'Wed', 'Fri'],
      'timings': '9:00 AM - 1:00 PM',
      'hospital': 'WMCTH',
    },
    {
      'name': 'Dr. Sarah Wang',
      'specialty': 'Ophthalmologist',
      'fee': '4500.00',
      'followUp': '2000',
      'days': ['Tue', 'Thu'],
      'timings': '10:00 AM - 2:00 PM',
      'hospital': 'City Hospital',
    },
    {
      'name': 'Dr. James Lee',
      'specialty': 'Dentist',
      'fee': '2000.00',
      'followUp': '1000',
      'days': ['Mon', 'Tue', 'Wed'],
      'timings': '9:27 AM - 1:30 PM',
      'hospital': 'WMCTH',
    },
    {
      'name': 'Dr. Maria Santos',
      'specialty': 'Cardiologist',
      'fee': '6000.00',
      'followUp': '4200',
      'days': ['Wed', 'Thu', 'Fri'],
      'timings': '9:00 AM - 12:00 PM',
      'hospital': 'Heart Care Center',
    },
    {
      'name': 'Dr. Alex Kim',
      'specialty': 'Neurologist',
      'fee': '5000.00',
      'followUp': '3000',
      'days': ['Tue', 'Fri'],
      'timings': '11:00 AM - 3:00 PM',
      'hospital': 'Neuro Clinic',
    },
    {
      'name': 'Dr. Sumaira Naz',
      'specialty': 'Neuro',
      'fee': '6000.00',
      'followUp': '4200',
      'days': ['Mon', 'Tue', 'Wed'],
      'timings': '9:27 AM - 1:30 PM',
      'hospital': 'WMCTH',
    },
  ];

  // ── Patient mock data (keyed by MR No) with 5-digit format ──
  final List<Map<String, dynamic>> _patients = [
    {'mrNo': '00001', 'name': 'Ali Hassan',       'contact': '0300-1234567', 'address': 'House 12, Gulberg, Lahore',        'isFirstVisit': false},
    {'mrNo': '00002', 'name': 'Fatima Malik',      'contact': '0321-9876543', 'address': 'Flat 5, Johar Town, Lahore',       'isFirstVisit': false},
    {'mrNo': '00003', 'name': 'Usman Ahmed',       'contact': '0333-5556666', 'address': 'Street 8, DHA Phase 5, Lahore',   'isFirstVisit': false},
    {'mrNo': '00004', 'name': 'Zainab Raza',       'contact': '0344-1112222', 'address': 'Block B, Model Town, Lahore',     'isFirstVisit': false},
    {'mrNo': '00005', 'name': 'Bilal Khan',        'contact': '0311-7778888', 'address': 'Plot 22, Wapda Town, Lahore',     'isFirstVisit': false},
    {'mrNo': '00006', 'name': 'Ayesha Siddiqui',   'contact': '0345-3334444', 'address': 'House 7, Bahria Town, Lahore',    'isFirstVisit': true},
    {'mrNo': '00007', 'name': 'Hamza Tariq',       'contact': '0312-6667777', 'address': 'Street 3, Cantt, Lahore',         'isFirstVisit': true},
    {'mrNo': '00008', 'name': 'Sara Nawaz',        'contact': '0322-8889999', 'address': 'Block C, Garden Town, Lahore',    'isFirstVisit': false},
    {'mrNo': '00009', 'name': 'Omar Farooq',       'contact': '0301-2223333', 'address': 'House 45, Allama Iqbal Town',     'isFirstVisit': true},
    {'mrNo': '00010', 'name': 'Nadia Hussain',     'contact': '0335-4445555', 'address': 'Flat 12, Cavalry Ground, Lahore','isFirstVisit': false},
  ];

  /// Format MR No to 5 digits with leading zeros
  String _formatMrNo(String input) {
    // Remove any non-digit characters
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) return '';

    // Parse the number and format to 5 digits with leading zeros
    final number = int.tryParse(digits) ?? 0;
    return number.toString().padLeft(5, '0');
  }

  /// Lookup patient by MR No. Returns null if not found.
  Map<String, dynamic>? lookupPatient(String mrNo) {
    // Format the input to 5 digits with leading zeros
    final formattedMrNo = _formatMrNo(mrNo);

    if (formattedMrNo.isEmpty) return null;

    // Use the formatted number for lookup
    try {
      return _patients.firstWhere(
            (p) => (p['mrNo'] as String) == formattedMrNo,
      );
    } catch (_) {
      return null;
    }
  }

  // ── ADD ──
  void addAppointment(ConsultationAppointment appointment) {
    _appointments.insert(0, appointment);
    notifyListeners();
  }

  // ── DELETE by id ──
  void removeAppointment(String id) {
    _appointments.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  // ── Time slot helpers ──
  List<String> generateTimeSlots(String timings) {
    try {
      final parts = timings.split(' - ');
      if (parts.length != 2) return [];
      final start = _parseTime(parts[0].trim());
      final end = _parseTime(parts[1].trim());
      if (start == null || end == null) return [];
      final slots = <String>[];
      var current = start;
      while (_timeToMinutes(current) < _timeToMinutes(end)) {
        slots.add(_formatTime(current));
        current = _addMinutes(current, 15);
      }
      return slots;
    } catch (_) {
      return [];
    }
  }

  List<String> bookedSlots(DateTime date, String consultantName) {
    return _appointments
        .where((a) =>
    a.consultantName == consultantName &&
        a.appointmentDate.year == date.year &&
        a.appointmentDate.month == date.month &&
        a.appointmentDate.day == date.day &&
        a.status != 'Cancelled')
        .map((a) => a.timeSlot)
        .toList();
  }

  TimeOfDay? _parseTime(String s) {
    try {
      final isPM = s.contains('PM');
      final isAM = s.contains('AM');
      final cleaned = s.replaceAll('AM', '').replaceAll('PM', '').trim();
      final p = cleaned.split(':');
      int hour = int.parse(p[0]);
      int minute = int.parse(p[1]);
      if (isPM && hour != 12) hour += 12;
      if (isAM && hour == 12) hour = 0;
      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return null;
    }
  }

  int _timeToMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  TimeOfDay _addMinutes(TimeOfDay t, int minutes) {
    final total = _timeToMinutes(t) + minutes;
    return TimeOfDay(hour: total ~/ 60, minute: total % 60);
  }

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}