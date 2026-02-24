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
    'mrNo': mrNo,
    'patientName': patientName,
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
//  DOCTOR MODEL
// ─────────────────────────────────────────────
class DoctorInfo {
  final String id;
  final String name;
  final String specialty;
  final String consultationFee;
  final String followUpCharges;
  final List<String> availableDays;
  final String timings;
  final String hospital;
  final String imageAsset; // for avatar fallback color/initials
  final Color avatarColor;
  final int totalAppointments;

  const DoctorInfo({
    required this.id,
    required this.name,
    required this.specialty,
    required this.consultationFee,
    required this.followUpCharges,
    required this.availableDays,
    required this.timings,
    required this.hospital,
    required this.imageAsset,
    required this.avatarColor,
    required this.totalAppointments,
  });
}

// ─────────────────────────────────────────────
//  PROVIDER
// ─────────────────────────────────────────────
class ConsultationProvider extends ChangeNotifier {
  // ── Doctors ──
  final List<DoctorInfo> doctors = const [
    DoctorInfo(
      id: 'd1',
      name: 'Dr. Greg Thorne',
      specialty: 'General Physician',
      consultationFee: '3,000',
      followUpCharges: '1,500',
      availableDays: ['Mon', 'Wed', 'Fri'],
      timings: '9:00 AM - 1:00 PM',
      hospital: 'WMCTH',
      imageAsset: '',
      avatarColor: Color(0xFF00B5AD),
      totalAppointments: 142,
    ),
    DoctorInfo(
      id: 'd2',
      name: 'Dr. Sarah Wang',
      specialty: 'Ophthalmologist',
      consultationFee: '4,500',
      followUpCharges: '2,000',
      availableDays: ['Tue', 'Thu'],
      timings: '10:00 AM - 2:00 PM',
      hospital: 'City Hospital',
      imageAsset: '',
      avatarColor: Color(0xFF8E24AA),
      totalAppointments: 98,
    ),
    DoctorInfo(
      id: 'd3',
      name: 'Dr. James Lee',
      specialty: 'Dentist',
      consultationFee: '2,000',
      followUpCharges: '1,000',
      availableDays: ['Mon', 'Tue', 'Wed'],
      timings: '9:00 AM - 1:30 PM',
      hospital: 'WMCTH',
      imageAsset: '',
      avatarColor: Color(0xFF1E88E5),
      totalAppointments: 215,
    ),
    DoctorInfo(
      id: 'd4',
      name: 'Dr. Maria Santos',
      specialty: 'Cardiologist',
      consultationFee: '6,000',
      followUpCharges: '4,200',
      availableDays: ['Wed', 'Thu', 'Fri'],
      timings: '9:00 AM - 12:00 PM',
      hospital: 'Heart Care Center',
      imageAsset: '',
      avatarColor: Color(0xFFE53935),
      totalAppointments: 73,
    ),
    DoctorInfo(
      id: 'd5',
      name: 'Dr. Alex Kim',
      specialty: 'Neurologist',
      consultationFee: '5,000',
      followUpCharges: '3,000',
      availableDays: ['Tue', 'Fri'],
      timings: '11:00 AM - 3:00 PM',
      hospital: 'Neuro Clinic',
      imageAsset: '',
      avatarColor: Color(0xFF43A047),
      totalAppointments: 61,
    ),
    DoctorInfo(
      id: 'd6',
      name: 'Dr. Sumaira Naz',
      specialty: 'Neurologist',
      consultationFee: '6,000',
      followUpCharges: '4,200',
      availableDays: ['Mon', 'Tue', 'Wed'],
      timings: '9:00 AM - 1:30 PM',
      hospital: 'WMCTH',
      imageAsset: '',
      avatarColor: Color(0xFFF4511E),
      totalAppointments: 87,
    ),
  ];

  // ── Appointments ──
  final List<ConsultationAppointment> _appointments = [
    ConsultationAppointment(
      id: '1',
      consultantName: 'Dr. Greg Thorne',
      specialty: 'General Physician',
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
      appointmentDate: DateTime(2026, 2, 24),
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
      appointmentDate: DateTime(2026, 2, 26),
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
      timings: '9:00 AM - 1:30 PM',
      hospital: 'WMCTH',
      mrNo: '00003',
      patientName: 'Usman Ahmed',
      contactNo: '0333-5556666',
      address: 'Street 8, DHA, Lahore',
      isFirstVisit: true,
      appointmentDate: DateTime(2026, 2, 14),
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
      appointmentDate: DateTime(2026, 2, 10),
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
      appointmentDate: DateTime(2026, 2, 6),
      timeSlot: '03:00 PM',
      type: 'Video Call',
      status: 'Cancelled',
    ),
    ConsultationAppointment(
      id: '6',
      consultantName: 'Dr. Greg Thorne',
      specialty: 'General Physician',
      consultationFee: '3000.00',
      followUpCharges: '1500',
      availableDays: ['Mon', 'Wed', 'Fri'],
      timings: '9:00 AM - 1:00 PM',
      hospital: 'WMCTH',
      mrNo: '00006',
      patientName: 'Ayesha Siddiqui',
      contactNo: '0345-3334444',
      address: 'House 7, Bahria Town',
      isFirstVisit: false,
      appointmentDate: DateTime(2026, 2, 24),
      timeSlot: '11:00 AM',
      type: 'In-Person',
      status: 'Upcoming',
    ),
    ConsultationAppointment(
      id: '7',
      consultantName: 'Dr. Sumaira Naz',
      specialty: 'Neurologist',
      consultationFee: '6000.00',
      followUpCharges: '4200',
      availableDays: ['Mon', 'Tue', 'Wed'],
      timings: '9:00 AM - 1:30 PM',
      hospital: 'WMCTH',
      mrNo: '00007',
      patientName: 'Hamza Tariq',
      contactNo: '0312-6667777',
      address: 'Street 3, Cantt, Lahore',
      isFirstVisit: true,
      appointmentDate: DateTime(2026, 2, 25),
      timeSlot: '10:00 AM',
      type: 'In-Person',
      status: 'Upcoming',
    ),
  ];

  List<ConsultationAppointment> get appointments =>
      List.unmodifiable(_appointments);

  List<Map<String, dynamic>> get appointmentsAsMaps =>
      _appointments.map((a) => a.toMap()).toList();

  // ── Summary stats ──
  int get totalConsultations => _appointments.length;
  int get upcomingAppointments =>
      _appointments.where((a) => a.status == 'Upcoming').length;
  int get completedAppointments =>
      _appointments.where((a) => a.status == 'Completed').length;

  // ── Appointments for a specific doctor on a specific date ──
  List<ConsultationAppointment> appointmentsForDoctorOnDate(
      String doctorName, DateTime date) {
    return _appointments
        .where((a) =>
    a.consultantName == doctorName &&
        a.appointmentDate.year == date.year &&
        a.appointmentDate.month == date.month &&
        a.appointmentDate.day == date.day &&
        a.status != 'Cancelled')
        .toList();
  }

  // ── Available slots for doctor ──
  int availableSlotsForDoctor(String doctorName, DateTime date) {
    final doctor = doctors.firstWhere(
          (d) => d.name == doctorName,
      orElse: () => doctors.first,
    );
    final allSlots = generateTimeSlots(doctor.timings);
    final booked = bookedSlots(date, doctorName);
    return allSlots.length - booked.length;
  }

  // ── Patient mock data ──
  final List<Map<String, dynamic>> _patients = [
    {'mrNo': '00001', 'name': 'Ali Hassan',     'contact': '0300-1234567', 'address': 'House 12, Gulberg, Lahore',       'isFirstVisit': false},
    {'mrNo': '00002', 'name': 'Fatima Malik',   'contact': '0321-9876543', 'address': 'Flat 5, Johar Town, Lahore',      'isFirstVisit': false},
    {'mrNo': '00003', 'name': 'Usman Ahmed',    'contact': '0333-5556666', 'address': 'Street 8, DHA Phase 5, Lahore',  'isFirstVisit': false},
    {'mrNo': '00004', 'name': 'Zainab Raza',    'contact': '0344-1112222', 'address': 'Block B, Model Town, Lahore',    'isFirstVisit': false},
    {'mrNo': '00005', 'name': 'Bilal Khan',     'contact': '0311-7778888', 'address': 'Plot 22, Wapda Town, Lahore',    'isFirstVisit': false},
    {'mrNo': '00006', 'name': 'Ayesha Siddiqui','contact': '0345-3334444', 'address': 'House 7, Bahria Town, Lahore',   'isFirstVisit': true},
    {'mrNo': '00007', 'name': 'Hamza Tariq',    'contact': '0312-6667777', 'address': 'Street 3, Cantt, Lahore',        'isFirstVisit': true},
    {'mrNo': '00008', 'name': 'Sara Nawaz',     'contact': '0322-8889999', 'address': 'Block C, Garden Town, Lahore',   'isFirstVisit': false},
    {'mrNo': '00009', 'name': 'Omar Farooq',    'contact': '0301-2223333', 'address': 'House 45, Allama Iqbal Town',    'isFirstVisit': true},
    {'mrNo': '00010', 'name': 'Nadia Hussain',  'contact': '0335-4445555', 'address': 'Flat 12, Cavalry Ground, Lahore','isFirstVisit': false},
  ];

  String _formatMrNo(String input) {
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';
    return int.parse(digits).toString().padLeft(5, '0');
  }

  Map<String, dynamic>? lookupPatient(String mrNo) {
    final formatted = _formatMrNo(mrNo);
    if (formatted.isEmpty) return null;
    try {
      return _patients.firstWhere((p) => p['mrNo'] == formatted);
    } catch (_) {
      return null;
    }
  }

  // ── Consultants map list (for backward compat) ──
  List<Map<String, dynamic>> get consultants => doctors.map((d) => {
    'name': d.name,
    'specialty': d.specialty,
    'fee': d.consultationFee,
    'followUp': d.followUpCharges,
    'days': d.availableDays,
    'timings': d.timings,
    'hospital': d.hospital,
  }).toList();

  // ── ADD ──
  void addAppointment(ConsultationAppointment appointment) {
    _appointments.insert(0, appointment);
    notifyListeners();
  }

  // ── DELETE ──
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
  TimeOfDay _addMinutes(TimeOfDay t, int m) {
    final total = _timeToMinutes(t) + m;
    return TimeOfDay(hour: total ~/ 60, minute: total % 60);
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final p = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $p';
  }
}