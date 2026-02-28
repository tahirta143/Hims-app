// voucher_provider.dart
// State management provider for Discount Voucher Approval
// Uses ChangeNotifier — add to pubspec: provider: ^6.1.2

import 'package:flutter/material.dart';
import '../../models/voucher_model/voucher_model.dart';
class VoucherProvider extends ChangeNotifier {
  // ─── State ──────────────────────────────────────────────────────────────────
  List<VoucherDetail> _pendingVouchers = [];
  List<VoucherDetail> _approvedVouchers = [];
  List<DiscountAuthority> _authorities = [];
  List<String> _discountReasons = [];

  VoucherDetail? _selectedVoucher;
  DiscountAuthority? _selectedAuthority;
  String? _selectedReason;
  bool _isLoading = false;
  String? _errorMessage;

  // ─── Getters ────────────────────────────────────────────────────────────────
  List<VoucherDetail> get pendingVouchers => List.unmodifiable(_pendingVouchers);
  List<VoucherDetail> get approvedVouchers => List.unmodifiable(_approvedVouchers);
  List<DiscountAuthority> get authorities => List.unmodifiable(_authorities);
  List<String> get discountReasons => List.unmodifiable(_discountReasons);

  VoucherDetail? get selectedVoucher => _selectedVoucher;
  DiscountAuthority? get selectedAuthority => _selectedAuthority;
  String? get selectedReason => _selectedReason;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get pendingCount => _pendingVouchers.length;
  bool get hasPending => _pendingVouchers.isNotEmpty;

  // ─── Init ────────────────────────────────────────────────────────────────────
  VoucherProvider() {
    loadData();
  }

  Future<void> loadData() async {
    _setLoading(true);
    // Simulate network/DB delay
    await Future.delayed(const Duration(milliseconds: 500));

    _pendingVouchers = _MockVoucherData.pendingVouchers;
    _authorities = _MockVoucherData.authorities;
    _discountReasons = _MockVoucherData.discountReasons;

    if (_pendingVouchers.isNotEmpty) {
      _selectedVoucher = _pendingVouchers.first;
    }

    _setLoading(false);
  }

  // ─── Actions ────────────────────────────────────────────────────────────────

  /// Select a voucher from the pending list
  void selectVoucher(VoucherDetail voucher) {
    _selectedVoucher = voucher;
    _selectedAuthority = null;
    _selectedReason = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Select a discount authority
  void selectAuthority(DiscountAuthority? authority) {
    _selectedAuthority = authority;
    notifyListeners();
  }

  /// Select a discount reason
  void selectReason(String? reason) {
    _selectedReason = reason;
    notifyListeners();
  }

  /// Validate and approve the current voucher discount
  /// Returns true on success, false if validation fails
  bool approveDiscount() {
    if (_selectedVoucher == null) {
      _errorMessage = 'No voucher selected.';
      notifyListeners();
      return false;
    }
    if (_selectedAuthority == null) {
      _errorMessage = 'Please select a discount authority.';
      notifyListeners();
      return false;
    }
    if (_selectedVoucher!.discountAmount > _selectedAuthority!.availableLimit) {
      _errorMessage =
      'Discount amount exceeds authority\'s available limit (Rs. ${_selectedAuthority!.availableLimit.toInt()}).';
      notifyListeners();
      return false;
    }

    // Move voucher to approved list
    final approvedVoucher = _selectedVoucher!.copyWith(status: VoucherStatus.approved);
    _approvedVouchers.add(approvedVoucher);
    _pendingVouchers.removeWhere((v) => v.invoiceId == _selectedVoucher!.invoiceId);

    // Update authority's used limit
    final authIndex = _authorities.indexWhere((a) => a.id == _selectedAuthority!.id);
    if (authIndex != -1) {
      _authorities[authIndex] = _authorities[authIndex].copyWith(
        usedLimit: _authorities[authIndex].usedLimit + _selectedVoucher!.discountAmount,
      );
    }

    // Select next pending voucher if available
    _selectedVoucher = _pendingVouchers.isNotEmpty ? _pendingVouchers.first : null;
    _selectedAuthority = null;
    _selectedReason = null;
    _errorMessage = null;

    notifyListeners();
    return true;
  }

  /// Reject the current voucher
  bool rejectDiscount() {
    if (_selectedVoucher == null) {
      _errorMessage = 'No voucher selected.';
      notifyListeners();
      return false;
    }

    final rejected = _selectedVoucher!.copyWith(status: VoucherStatus.rejected);
    _pendingVouchers.removeWhere((v) => v.invoiceId == _selectedVoucher!.invoiceId);

    _selectedVoucher = _pendingVouchers.isNotEmpty ? _pendingVouchers.first : null;
    _selectedAuthority = null;
    _selectedReason = null;
    _errorMessage = null;

    notifyListeners();
    return true;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}

// ─── Mock Data (private — only used by VoucherProvider) ──────────────────────
class _MockVoucherData {
  static List<VoucherDetail> get pendingVouchers => [
    VoucherDetail(
      invoiceId: 'OPD71954',
      date: '27 Feb 2026',
      time: '11:52:22',
      patientName: 'ABDUL REHMAN',
      age: 36,
      gender: 'Male',
      phone: '03014709600',
      address: 'House 12, Street 5, Lahore',
      services: [
        const ServiceItem(srNo: 1, service: 'New Service', type: 'Opd', rate: 200, qty: 1),
      ],
      discountPercentage: 10.0,
      status: VoucherStatus.pending,
    ),
    VoucherDetail(
      invoiceId: 'OPD71890',
      date: '27 Feb 2026',
      time: '10:30:15',
      patientName: 'SARA KHAN',
      age: 28,
      gender: 'Female',
      phone: '03001234567',
      address: 'Flat 3B, Model Town, Lahore',
      services: [
        const ServiceItem(srNo: 1, service: 'Consultation', type: 'Opd', rate: 500, qty: 1),
        const ServiceItem(srNo: 2, service: 'Blood Test', type: 'Lab', rate: 300, qty: 2),
      ],
      discountPercentage: 15.0,
      status: VoucherStatus.pending,
    ),
    VoucherDetail(
      invoiceId: 'OPD71800',
      date: '26 Feb 2026',
      time: '09:15:00',
      patientName: 'MUHAMMAD ALI',
      age: 52,
      gender: 'Male',
      phone: '03459876543',
      address: 'Village Kot Lakhpat, Lahore',
      services: [
        const ServiceItem(srNo: 1, service: 'X-Ray', type: 'Radiology', rate: 800, qty: 1),
      ],
      discountPercentage: 20.0,
      status: VoucherStatus.pending,
    ),
    VoucherDetail(
      invoiceId: 'OPD71750',
      date: '25 Feb 2026',
      time: '14:45:30',
      patientName: 'AYESHA SIDDIQUI',
      age: 34,
      gender: 'Female',
      phone: '03211234567',
      address: 'Gulberg III, Lahore',
      services: [
        const ServiceItem(srNo: 1, service: 'Ultrasound', type: 'Radiology', rate: 1500, qty: 1),
        const ServiceItem(srNo: 2, service: 'Consultation', type: 'Opd', rate: 500, qty: 1),
      ],
      discountPercentage: 5.0,
      status: VoucherStatus.pending,
    ),
  ];

  static List<DiscountAuthority> get authorities => [
    const DiscountAuthority(
      id: 'auth_1',
      name: 'Dr. Ahmad Raza',
      department: 'Cardiology',
      totalLimit: 50000,
      usedLimit: 12000,
    ),
    const DiscountAuthority(
      id: 'auth_2',
      name: 'Dr. Fatima Malik',
      department: 'General Medicine',
      totalLimit: 30000,
      usedLimit: 8500,
    ),
    const DiscountAuthority(
      id: 'auth_3',
      name: 'Admin - Usman Tariq',
      department: 'Administration',
      totalLimit: 100000,
      usedLimit: 45000,
    ),
    const DiscountAuthority(
      id: 'auth_4',
      name: 'Dr. Zainab Hussain',
      department: 'Pediatrics',
      totalLimit: 25000,
      usedLimit: 3200,
    ),
  ];

  static List<String> get discountReasons => [
    'Patient financial difficulty',
    'Staff family member',
    'Senior citizen concession',
    'Charity case',
    'Loyalty discount',
    'Medical emergency waiver',
    'Government employee',
  ];
}