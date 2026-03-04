import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../global/global_api.dart';
import 'auth_storage_service.dart';
import '../../models/consultant_payment_model/consultant_payment_model.dart';

class ConsultantPaymentsApiService {
  final AuthStorageService _storage = AuthStorageService();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _storage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<ConsultantPaymentAnalyticsResult> fetchAnalytics({
    required String fromDate,
    required String toDate,
    String? paid,
  }) async {
    try {
      final headers = await _authHeaders();
      final queryParams = {
        'startDate': fromDate,
        'endDate': toDate,
        if (paid != null) 'paid': paid,
      };
      final uri = Uri.parse('${GlobalApi.baseUrl}/consultant-payments/analytics')
          .replace(queryParameters: queryParams);
      
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return ConsultantPaymentAnalyticsResult(
            success: true,
            analytics: ConsultantPaymentAnalytics.fromJson(data['data'] ?? {}),
          );
        }
      }
      return ConsultantPaymentAnalyticsResult(success: false, message: 'Failed to fetch analytics');
    } catch (e) {
      return ConsultantPaymentAnalyticsResult(success: false, message: e.toString());
    }
  }

  Future<DoctorBreakdownResult> fetchDoctorBreakdown({
    required String fromDate,
    required String toDate,
    String? paid,
  }) async {
    try {
      final headers = await _authHeaders();
      final queryParams = {
        'startDate': fromDate,
        'endDate': toDate,
        if (paid != null) 'paid': paid,
      };
      final uri = Uri.parse('${GlobalApi.baseUrl}/consultant-payments/doctor-breakdown')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final list = (data['data'] as List? ?? []).map((json) => DoctorBreakdownModel.fromJson(json)).toList();
          return DoctorBreakdownResult(success: true, breakdown: list);
        }
      }
      return DoctorBreakdownResult(success: false, message: 'Failed to fetch breakdown');
    } catch (e) {
      return DoctorBreakdownResult(success: false, message: e.toString());
    }
  }

  Future<PayoutRecordsResult> fetchPayouts({
    required String fromDate,
    required String toDate,
    String? doctorId,
  }) async {
    try {
      final headers = await _authHeaders();
      // React hits /consultant-payments with ?date= if from == to
      final queryParams = {
        if (fromDate == toDate) 'date': fromDate,
      };
      
      final uri = Uri.parse('${GlobalApi.baseUrl}/consultant-payments')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final list = (data['data'] as List? ?? []).map((json) => PayoutRecordModel.fromJson(json)).toList();
          return PayoutRecordsResult(success: true, records: list);
        }
      }
      return PayoutRecordsResult(success: false, message: 'Failed to fetch payouts');
    } catch (e) {
      return PayoutRecordsResult(success: false, message: e.toString());
    }
  }

  Future<bool> createConsultantPayment(Map<String, dynamic> payload) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse('${GlobalApi.baseUrl}/consultant-payments'),
        headers: headers,
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 15));
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> createDoctorPayout(Map<String, dynamic> payload) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse('${GlobalApi.baseUrl}/consultant-payments/payouts'),
        headers: headers,
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 15));
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> fetchPayoutReceipt(String payoutId) async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse('${GlobalApi.baseUrl}/consultant-payments/payouts/$payoutId'),
        headers: headers,
      ).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) return data['data'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

class ConsultantPaymentAnalyticsResult {
  final bool success;
  final ConsultantPaymentAnalytics? analytics;
  final String? message;
  ConsultantPaymentAnalyticsResult({required this.success, this.analytics, this.message});
}

class DoctorBreakdownResult {
  final bool success;
  final List<DoctorBreakdownModel> breakdown;
  final String? message;
  DoctorBreakdownResult({required this.success, this.breakdown = const [], this.message});
}

class PayoutRecordsResult {
  final bool success;
  final List<PayoutRecordModel> records;
  final String? message;
  PayoutRecordsResult({required this.success, this.records = const [], this.message});
}
