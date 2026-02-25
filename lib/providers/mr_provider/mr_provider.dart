import 'package:flutter/material.dart';

// ─── Patient Model ────────────────────────────────────────────────────────────
class PatientModel {
  final String mrNumber;
  final String firstName;
  final String lastName;
  final String guardianName;
  final String relation;
  final String gender;
  final String dateOfBirth;
  final int? age;
  final String bloodGroup;
  final String profession;
  final String phoneNumber;
  final String email;
  final String cnic;
  final String address;
  final String city;
  final DateTime registeredAt;
  int totalVisits;
  int visitsToday;

  PatientModel({
    required this.mrNumber,
    required this.firstName,
    required this.lastName,
    this.guardianName = '',
    this.relation = 'Parent',
    required this.gender,
    this.dateOfBirth = '',
    this.age,
    this.bloodGroup = '',
    this.profession = '',
    this.phoneNumber = '',
    this.email = '',
    this.cnic = '',
    this.address = '',
    this.city = '',
    required this.registeredAt,
    this.totalVisits = 0,
    this.visitsToday = 0,
  });

  String get fullName => '$firstName $lastName'.trim();
}

// ─── MR Provider ─────────────────────────────────────────────────────────────
class MrProvider extends ChangeNotifier {
  /// Tracks the highest numeric MR number used so far.
  /// Starts at 5 since mock data goes 00001–00005.
  int _mrCounter = 5;

  final List<PatientModel> _patients = [
    PatientModel(
      mrNumber: '00001',
      firstName: 'ANAS',
      lastName: 'SHAREEF',
      guardianName: 'Muhammad Shareef',
      relation: 'Parent',
      gender: 'Male',
      age: 25,
      phoneNumber: '03037015072',
      email: 'anas@email.com',
      city: 'Lahore',
      bloodGroup: 'B+',
      profession: 'Engineer',
      address: 'House 12, Street 4, Gulberg',
      registeredAt: DateTime(2025, 4, 20),
      totalVisits: 8,
      visitsToday: 2,
    ),
    PatientModel(
      mrNumber: '00002',
      firstName: 'USAMA',
      lastName: 'ARIF',
      guardianName: 'Muhammad Arif',
      relation: 'Parent',
      gender: 'Male',
      age: 27,
      phoneNumber: '03064423884',
      cnic: '3520264293471',
      city: 'LAHORE',
      bloodGroup: 'O+',
      registeredAt: DateTime(2025, 5, 11),
      totalVisits: 12,
      visitsToday: 1,
    ),
    PatientModel(
      mrNumber: '00003',
      firstName: 'TAHIR',
      lastName: 'M USMAN',
      guardianName: 'Usman',
      relation: 'Parent',
      gender: 'Male',
      age: 24,
      phoneNumber: '03092232631',
      city: 'Kot Radha Kishan',
      bloodGroup: 'A+',
      registeredAt: DateTime(2025, 1, 10),
      totalVisits: 5,
      visitsToday: 1,
    ),
    PatientModel(
      mrNumber: '00004',
      firstName: 'RIDA',
      lastName: '',
      gender: 'Female',
      age: 18,
      phoneNumber: '03014988514',
      city: 'LHR',
      bloodGroup: 'AB+',
      registeredAt: DateTime(2024, 11, 22),
      totalVisits: 3,
      visitsToday: 1,
    ),
    PatientModel(
      mrNumber: '00005',
      firstName: 'FARZANA',
      lastName: 'BIBI',
      guardianName: 'Ahmad Khan',
      relation: 'Spouse',
      gender: 'Female',
      age: 45,
      phoneNumber: '03215602548',
      cnic: '3520112345678',
      city: 'LHR',
      bloodGroup: 'B-',
      profession: 'Teacher',
      address: 'Flat 3, Block A, Model Town',
      registeredAt: DateTime(2024, 10, 5),
      totalVisits: 9,
      visitsToday: 0,
    ),
  ];

  String _searchQuery = '';
  PatientModel? _selectedPatient;

  // ── Getters ───────────────────────────────────────────────────────────────
  List<PatientModel> get patients {
    if (_searchQuery.isEmpty) return List.from(_patients);
    final q = _searchQuery.toLowerCase();
    return _patients.where((p) {
      return p.mrNumber.toLowerCase().contains(q) ||
          p.fullName.toLowerCase().contains(q) ||
          p.phoneNumber.contains(q) ||
          p.cnic.contains(q);
    }).toList();
  }

  int get totalPatients => _patients.length;
  String get searchQuery => _searchQuery;
  PatientModel? get selectedPatient => _selectedPatient;

  // ── MR number lookup ──────────────────────────────────────────────────────
  /// Accepts both raw numbers ("3", "03", "003") and full padded ("00003").
  /// Always normalises to 5-digit padded form before matching.
  PatientModel? findByMrNumber(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    // Try to parse as int so "3" → "00003", "03" → "00003"
    final asInt = int.tryParse(trimmed);
    final normalised =
    asInt != null ? asInt.toString().padLeft(5, '0') : trimmed.toUpperCase();

    try {
      return _patients.firstWhere(
            (p) => p.mrNumber.toUpperCase() == normalised,
      );
    } catch (_) {
      return null;
    }
  }

  /// Returns the next auto-generated MR number (zero-padded to 5 digits).
  String _nextMrNumber() {
    _mrCounter++;
    return _mrCounter.toString().padLeft(5, '0');
  }

  // ── State mutations ───────────────────────────────────────────────────────
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  void selectPatient(PatientModel? patient) {
    _selectedPatient = patient;
    notifyListeners();
  }

  /// Registers a new patient.
  /// • If [mrNumber] matches an existing record → returns that record (no duplicate).
  /// • If [mrNumber] is blank → auto-generates the next padded MR number.
  /// • If [mrNumber] is a plain number like "6" → pads to "00006".
  PatientModel registerPatient({
    String mrNumber = '',
    required String firstName,
    required String lastName,
    String guardianName = '',
    String relation = 'Parent',
    required String gender,
    String dateOfBirth = '',
    int? age,
    String bloodGroup = '',
    String profession = '',
    String phoneNumber = '',
    String email = '',
    String cnic = '',
    String address = '',
    String city = '',
  }) {
    // Normalise the MR input
    String resolvedMr;
    final trimmed = mrNumber.trim();
    if (trimmed.isEmpty) {
      resolvedMr = _nextMrNumber();
    } else {
      final asInt = int.tryParse(trimmed);
      resolvedMr =
      asInt != null ? asInt.toString().padLeft(5, '0') : trimmed;
    }

    // If MR already exists, return existing record
    final existing = findByMrNumber(resolvedMr);
    if (existing != null) {
      _selectedPatient = existing;
      notifyListeners();
      return existing;
    }

    // Ensure _mrCounter stays ahead of any manually-typed numeric MR
    final asInt = int.tryParse(resolvedMr);
    if (asInt != null && asInt > _mrCounter) {
      _mrCounter = asInt;
    }

    final patient = PatientModel(
      mrNumber: resolvedMr,
      firstName: firstName.trim().toUpperCase(),
      lastName: lastName.trim().toUpperCase(),
      guardianName: guardianName.trim(),
      relation: relation,
      gender: gender,
      dateOfBirth: dateOfBirth,
      age: age,
      bloodGroup: bloodGroup,
      profession: profession,
      phoneNumber: phoneNumber.trim(),
      email: email.trim(),
      cnic: cnic.trim(),
      address: address.trim(),
      city: city.trim(),
      registeredAt: DateTime.now(),
    );

    _patients.insert(0, patient);
    _selectedPatient = patient;
    notifyListeners();
    return patient;
  }

  void deletePatient(String mrNumber) {
    _patients.removeWhere((p) => p.mrNumber == mrNumber);
    if (_selectedPatient?.mrNumber == mrNumber) _selectedPatient = null;
    notifyListeners();
  }
}