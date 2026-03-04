import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/services/auth_storage_service.dart';
import '../../global/global_api.dart';
import '../../models/shift_model/shift_model.dart';

export '../../models/shift_model/shift_model.dart';

class ShiftProvider extends ChangeNotifier {
  static const String _baseUrl = '${GlobalApi.baseUrl}/shifts';

  final AuthStorageService _storage = AuthStorageService();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _storage.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── State ──────────────────────────────────────────────────────────────────
  ShiftModel _currentShift = ShiftModel.empty();
  List<ShiftModel> _allShifts = [];
  bool isLoading = false;
  bool isClosing = false;
  String? errorMessage;

  // ── Getters ────────────────────────────────────────────────────────────────
  ShiftModel get shift => _currentShift;
  List<ShiftModel> get allShifts => _allShifts;
  bool get isClosed => _currentShift.isClosed;

  // Legacy getters kept for screen compatibility
  double get grossAmount => 0.0;
  double get totalCollected => 0.0;
  int get receiptCount => 0;
  String get receiptsRange => '--';

  ShiftProvider() {
    fetchCurrentShift();
    fetchAllShifts();
  }

  // ── GET current open shift ─────────────────────────────────────────────────
  Future<void> fetchCurrentShift() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final headers = await _authHeaders();
      developer.log('📡 GET $_baseUrl/current', name: 'ShiftProvider');

      final response =
      await http.get(Uri.parse('$_baseUrl/current'), headers: headers);

      developer.log('📥 Status: ${response.statusCode}', name: 'ShiftProvider');
      developer.log('📥 Body: ${response.body}', name: 'ShiftProvider');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true && json['data'] != null) {
          _currentShift = ShiftModel.fromJson(json['data']);
          developer.log('✅ Current shift loaded: ${_currentShift.shiftId}',
              name: 'ShiftProvider');
        } else {
          errorMessage = json['message'] ?? 'No active shift found.';
          developer.log('❌ ${response.body}', name: 'ShiftProvider');
        }
      } else if (response.statusCode == 404) {
        errorMessage = 'No active shift found.';
        developer.log('⚠️ 404 No current shift', name: 'ShiftProvider');
      } else if (response.statusCode == 401) {
        errorMessage = 'Session expired. Please log in again.';
      } else {
        errorMessage = 'Server error: ${response.statusCode}';
      }
    } catch (e, stack) {
      errorMessage = 'Network error. Check your connection.';
      developer.log('💥 $e', name: 'ShiftProvider', error: e, stackTrace: stack);
    }

    isLoading = false;
    notifyListeners();
  }

  // ── GET all shifts ─────────────────────────────────────────────────────────
  Future<void> fetchAllShifts() async {
    try {
      final headers = await _authHeaders();
      developer.log('📡 GET $_baseUrl', name: 'ShiftProvider');

      final response =
      await http.get(Uri.parse(_baseUrl), headers: headers);

      developer.log('📥 All shifts status: ${response.statusCode}',
          name: 'ShiftProvider');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true) {
          _allShifts = (json['data'] as List)
              .map((e) => ShiftModel.fromJson(e))
              .toList();
          developer.log('✅ Loaded ${_allShifts.length} shifts',
              name: 'ShiftProvider');
          notifyListeners();
        }
      }
    } catch (e, stack) {
      developer.log('💥 fetchAllShifts: $e',
          name: 'ShiftProvider', error: e, stackTrace: stack);
    }
  }

  // ── PUT close shift ────────────────────────────────────────────────────────
  Future<bool> closeShift(String closedBy, double cashInHand) async {
    if (_currentShift.shiftId == 0) return false;

    isClosing = true;
    notifyListeners();

    final body = jsonEncode({
      'closed_by': closedBy,
      'cash_in_hand': cashInHand,
    });

    try {
      final headers = await _authHeaders();
      final url = '$_baseUrl/${_currentShift.shiftId}/close';
      developer.log('📡 PUT $url\n📤 Body: $body', name: 'ShiftProvider');

      final response =
      await http.put(Uri.parse(url), headers: headers, body: body);

      developer.log('📥 Status: ${response.statusCode}\n📥 Body: ${response.body}',
          name: 'ShiftProvider');

      if (response.statusCode == 200) {
        developer.log('✅ Shift closed', name: 'ShiftProvider');
        // Refresh data after closing
        await fetchCurrentShift();
        await fetchAllShifts();
        isClosing = false;
        notifyListeners();
        return true;
      }

      developer.log('❌ Close failed ${response.statusCode}: ${response.body}',
          name: 'ShiftProvider');
    } catch (e, stack) {
      developer.log('💥 $e', name: 'ShiftProvider', error: e, stackTrace: stack);
    }

    isClosing = false;
    notifyListeners();
    return false;
  }

  // ── Refresh ────────────────────────────────────────────────────────────────
  Future<void> refresh() async {
    await fetchCurrentShift();
    await fetchAllShifts();
  }
}