import 'package:flutter/material.dart';
import '../../core/services/consultant_payments_api_service.dart';
import '../../models/consultant_payment_model/consultant_payment_model.dart';
import 'package:intl/intl.dart';

class ConsultantPaymentsProvider extends ChangeNotifier {
  final ConsultantPaymentsApiService _apiService = ConsultantPaymentsApiService();

  ConsultantPaymentAnalytics? _analytics;
  List<DoctorBreakdownModel> _breakdown = [];
  List<PayoutRecordModel> _records = [];

  bool _loadingAnalytics = false;
  bool _loadingBreakdown = false;
  bool _loadingRecords = false;

  ConsultantPaymentAnalytics? get analytics => _analytics;
  List<DoctorBreakdownModel> get breakdown => List.unmodifiable(_breakdown);
  List<PayoutRecordModel> get records => List.unmodifiable(_records);

  bool get isLoading => _loadingAnalytics || _loadingBreakdown || _loadingRecords;

  Future<void> loadDashboardData({
    required DateTime fromDate,
    required DateTime toDate,
    String? paid,
    String? requestId,
  }) async {
    final fromStr = DateFormat('yyyy-MM-dd').format(fromDate);
    final toStr = DateFormat('yyyy-MM-dd').format(toDate);

    _loadingAnalytics = true;
    _loadingBreakdown = true;
    _loadingRecords = true;
    notifyListeners();

    final results = await Future.wait([
      _apiService.fetchAnalytics(fromDate: fromStr, toDate: toStr, paid: paid),
      _apiService.fetchDoctorBreakdown(fromDate: fromStr, toDate: toStr, paid: paid),
      _apiService.fetchPayouts(fromDate: fromStr, toDate: toStr),
    ]);

    final analyticsRes = results[0] as ConsultantPaymentAnalyticsResult;
    final breakdownRes = results[1] as DoctorBreakdownResult;
    final recordsRes = results[2] as PayoutRecordsResult;

    if (analyticsRes.success) _analytics = analyticsRes.analytics;
    if (breakdownRes.success) _breakdown = breakdownRes.breakdown;
    if (recordsRes.success) _records = recordsRes.records;

    _loadingAnalytics = false;
    _loadingBreakdown = false;
    _loadingRecords = false;
    notifyListeners();
  }

  Future<void> refreshPayouts({
    required DateTime fromDate,
    required DateTime toDate,
    String? doctorId,
  }) async {
    final fromStr = DateFormat('yyyy-MM-dd').format(fromDate);
    final toStr = DateFormat('yyyy-MM-dd').format(toDate);

    _loadingRecords = true;
    notifyListeners();

    final res = await _apiService.fetchPayouts(
      fromDate: fromStr,
      toDate: toStr,
      doctorId: doctorId,
    );

    if (res.success) {
      _records = res.records;
    }
    _loadingRecords = false;
    notifyListeners();
  }
}
