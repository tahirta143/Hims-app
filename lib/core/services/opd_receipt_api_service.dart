import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../global/global_api.dart';
import 'auth_storage_service.dart';
import '../../models/opd_model/opd_service_model.dart';
import '../../models/opd_model/opd_receipt_model.dart';
import '../../models/voucher_model/voucher_model.dart';

class OpdReceiptApiService {
  final AuthStorageService _storage = AuthStorageService();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _storage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // GET /api/opd-services
  Future<OpdServicesResult> fetchOpdServices() async {
    try {
      final headers = await _authHeaders();
      final response = await http
          .get(Uri.parse('${GlobalApi.baseUrl}/opd-services'), headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 401) {
        return OpdServicesResult(
          success: false,
          message: 'Session expired. Please log in again.',
        );
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          final list = data['data'] as List<dynamic>;
          final services = list
              .map(
                (e) => OpdServiceApiModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList();
          return OpdServicesResult(success: true, services: services);
        }
        return OpdServicesResult(
          success: false,
          message: data['message'] as String? ?? 'Failed to fetch OPD services',
        );
      }

      return OpdServicesResult(
        success: false,
        message: 'Server error: ${response.statusCode}',
      );
    } catch (e) {
      return OpdServicesResult(
        success: false,
        message: 'Failed to fetch OPD services: $e',
      );
    }
  }

  // GET /api/opd-receipts
  Future<OpdReceiptsResult> fetchOpdReceipts() async {
    try {
      final headers = await _authHeaders();
      final response = await http
          .get(Uri.parse('${GlobalApi.baseUrl}/opd-patient-data'), headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 401) {
        return OpdReceiptsResult(
          success: false,
          message: 'Session expired. Please log in again.',
        );
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          final list = data['data'] as List<dynamic>;
          final receipts = list
              .map(
                (e) => OpdReceiptApiModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList();
          return OpdReceiptsResult(success: true, receipts: receipts);
        }
        return OpdReceiptsResult(
          success: false,
          message: data['message'] as String? ?? 'Failed to fetch OPD receipts',
        );
      }

      return OpdReceiptsResult(
        success: false,
        message: 'Server error: ${response.statusCode}',
      );
    } catch (e) {
      return OpdReceiptsResult(
        success: false,
        message: 'Failed to fetch OPD receipts: $e',
      );
    }
  }

  // POST /api/opd-receipts
  Future<CreateOpdReceiptResult> createOpdReceipt(
    Map<String, dynamic> payload,
  ) async {
    try {
      final headers = await _authHeaders();
      final response = await http
          .post(
            Uri.parse('${GlobalApi.baseUrl}/opd-patient-data'),
            headers: headers,
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 401) {
        return CreateOpdReceiptResult(
          success: false,
          message: 'Session expired. Please log in again.',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (data['success'] == true) {
          final recJson = data['data'] as Map<String, dynamic>?;
          OpdReceiptApiModel? rec;
          if (recJson != null) {
            rec = OpdReceiptApiModel.fromJson(recJson);
          }
          return CreateOpdReceiptResult(
            success: true,
            message:
                data['message'] as String? ?? 'OPD receipt created successfully',
            receipt: rec,
          );
        }
      }

      return CreateOpdReceiptResult(
        success: false,
        message: data['message'] as String? ?? 'Failed to create OPD receipt',
      );
    } catch (e) {
      return CreateOpdReceiptResult(
        success: false,
        message: 'Failed to create OPD receipt: $e',
      );
    }
  }

  // GET /pending-discount-receipts
  Future<PendingDiscountReceiptsResult> fetchPendingDiscountReceipts() async {
    try {
      final headers = await _authHeaders();
      final response = await http
          .get(Uri.parse('${GlobalApi.baseUrl}/pending-discount-receipts'), headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 401) {
        return PendingDiscountReceiptsResult(success: false, message: 'Session expired. Please log in again.');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          final list = data['data'] ?? [];
          final receipts = (list as List).map((e) => VoucherDetail.fromJson(e)).toList();
          return PendingDiscountReceiptsResult(success: true, receipts: receipts);
        }
        return PendingDiscountReceiptsResult(success: false, message: data['message'] as String? ?? 'Failed to fetch pending discounts');
      }

      return PendingDiscountReceiptsResult(success: false, message: 'Server error: ${response.statusCode}');
    } catch (e) {
      return PendingDiscountReceiptsResult(success: false, message: 'Failed to fetch pending discounts: $e');
    }
  }

  // POST /approve-discount
  Future<ApproveDiscountResult> approveDiscount(int receiptSrlNo, int authoritySrlNo) async {
    try {
      final headers = await _authHeaders();
      final payload = {
        'receipt_srl_no': receiptSrlNo,
        'authority_srl_no': authoritySrlNo,
      };

      final response = await http
          .post(
            Uri.parse('${GlobalApi.baseUrl}/approve-discount'),
            headers: headers,
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 401) {
        return ApproveDiscountResult(success: false, message: 'Session expired. Please log in again.');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          return ApproveDiscountResult(success: true, message: data['message'] as String? ?? 'Discount approved successfully');
        }
        return ApproveDiscountResult(success: false, message: data['message'] as String? ?? 'Failed to approve discount');
      }

      return ApproveDiscountResult(success: false, message: 'Server error: ${response.statusCode}');
    } catch (e) {
      return ApproveDiscountResult(success: false, message: 'Failed to approve discount: $e');
    }
  }
}

class OpdServicesResult {
  final bool success;
  final List<OpdServiceApiModel> services;
  final String? message;

  OpdServicesResult({
    required this.success,
    this.services = const [],
    this.message,
  });
}

class OpdReceiptsResult {
  final bool success;
  final List<OpdReceiptApiModel> receipts;
  final String? message;

  OpdReceiptsResult({
    required this.success,
    this.receipts = const [],
    this.message,
  });
}

class CreateOpdReceiptResult {
  final bool success;
  final String? message;
  final OpdReceiptApiModel? receipt;

  CreateOpdReceiptResult({
    required this.success,
    this.message,
    this.receipt,
  });
}

class PendingDiscountReceiptsResult {
  final bool success;
  final List<VoucherDetail> receipts;
  final String? message;

  PendingDiscountReceiptsResult({
    required this.success,
    this.receipts = const [],
    this.message,
  });
}

class ApproveDiscountResult {
  final bool success;
  final String? message;

  ApproveDiscountResult({required this.success, this.message});
}

