import 'package:flutter/material.dart';
import '../../core/services/mr_api_service.dart';
import '../../models/mr_model/mr_patient_model.dart';

// ─── MR Provider ─────────────────────────────────────────────────────────────
class MrProvider extends ChangeNotifier {
  final MrApiService _apiService = MrApiService();

  // ── State ──
  bool _isLoading = false;
  bool _isCreating = false;
  String? _errorMessage;
  String? _nextMrNumber;

  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;
  String? get errorMessage => _errorMessage;
  String? get nextMrNumber => _nextMrNumber;
  List<PatientModel> _patients = [];
  String _searchQuery = '';
  PatientModel? _selectedPatient;

  // ── Constructor: Load data on init ──
  MrProvider() {
    loadPatients();
    fetchNextMR();
  }

  // ── Load Patients from API ──
  Future<void> loadPatients() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _apiService.fetchAllPatients(limit: 100);

    if (result.success) {
      _patients = result.patients.map((p) => p.toPatientModel()).toList();
      _errorMessage = null;
    } else {
      _errorMessage = result.message;
      _patients = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Fetch Next MR Number ──
  Future<void> fetchNextMR() async {
    final result = await _apiService.fetchNextMRNumber();
    if (result.success && result.nextMR != null) {
      _nextMrNumber = result.nextMR;
      notifyListeners();
    }
  }

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

  // ── MR number lookup (API call) ──────────────────────────────────────────────────
  Future<PatientModel?> findByMrNumber(String input) async {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    // First check local cache
    final normalised = _normalizeMrNumber(trimmed);
    try {
      final local = _patients.firstWhere(
        (p) => p.mrNumber.toUpperCase() == normalised,
      );
      return local;
    } catch (_) {
      // Not in cache, try API
      final result = await _apiService.fetchPatientByMR(normalised);
      if (result.success && result.patient != null) {
        final patient = result.patient!.toPatientModel();
        // Add to cache if not already there
        if (!_patients.any((p) => p.mrNumber == patient.mrNumber)) {
          _patients.insert(0, patient);
          notifyListeners();
        }
        return patient;
      }
      return null;
    }
  }

  String _normalizeMrNumber(String input) {
    final asInt = int.tryParse(input);
    return asInt != null ? asInt.toString().padLeft(5, '0') : input.toUpperCase();
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

  /// Registers a new patient via API
  Future<PatientModel?> registerPatient({
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
  }) async {
    _isCreating = true;
    _errorMessage = null;
    notifyListeners();

    // Create patient model
    final patient = PatientModel(
      mrNumber: mrNumber.trim().isEmpty ? (_nextMrNumber ?? '00001') : mrNumber.trim(),
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

    // Call API
    final result = await _apiService.createPatient(patient.toApiRequest());

    _isCreating = false;

    if (result.success && result.patient != null) {
      final createdPatient = result.patient!.toPatientModel();
      _patients.insert(0, createdPatient);
      _selectedPatient = createdPatient;
      _errorMessage = null;
      notifyListeners();
      
      // Fetch next MR for future use
      fetchNextMR();
      
      return createdPatient;
    } else {
      _errorMessage = result.message;
      notifyListeners();
      return null;
    }
  }

  /// Update existing patient via API
  Future<bool> updatePatient(PatientModel patient) async {
    _isCreating = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _apiService.updatePatient(
      patient.mrNumber,
      patient.toApiRequest(),
    );

    _isCreating = false;

    if (result.success && result.patient != null) {
      final updatedPatient = result.patient!.toPatientModel();
      final index = _patients.indexWhere((p) => p.mrNumber == patient.mrNumber);
      if (index != -1) {
        _patients[index] = updatedPatient;
      }
      if (_selectedPatient?.mrNumber == patient.mrNumber) {
        _selectedPatient = updatedPatient;
      }
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.message;
      notifyListeners();
      return false;
    }
  }

  /// Delete patient via API
  Future<bool> deletePatient(String mrNumber) async {
    final result = await _apiService.deletePatient(mrNumber);

    if (result.success) {
      _patients.removeWhere((p) => p.mrNumber == mrNumber);
      if (_selectedPatient?.mrNumber == mrNumber) _selectedPatient = null;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result.message;
      notifyListeners();
      return false;
    }
  }
}