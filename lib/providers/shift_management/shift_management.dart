import 'package:flutter/material.dart';

// ─── Model ───────────────────────────────────────────────────────────────────
class ShiftModel {
  final int shiftId;
  final String shiftType;
  final String startDate;
  final String openedBy;
  final double grossAmount;
  final double totalCollected;
  final String receiptsRange;
  final int receiptCount;
  bool isLive;

  ShiftModel({
    required this.shiftId,
    required this.shiftType,
    required this.startDate,
    required this.openedBy,
    required this.grossAmount,
    required this.totalCollected,
    required this.receiptsRange,
    required this.receiptCount,
    this.isLive = true,
  });
}

// ─── Provider ────────────────────────────────────────────────────────────────
class ShiftProvider extends ChangeNotifier {
  ShiftModel _shift = ShiftModel(
    shiftId: 6013,
    shiftType: 'Morning',
    startDate: '23 Feb 2026',
    openedBy: 'System Auto-Start',
    grossAmount: 12000,
    totalCollected: 12000,
    receiptsRange: 'OPD71945-OPD71949',
    receiptCount: 5,
  );

  bool _isClosed = false;
  bool _isLoading = false;

  ShiftModel get shift => _shift;
  bool get isClosed => _isClosed;
  bool get isLoading => _isLoading;

  void closeShift(String closedBy, double cashInHand) {
    _isLoading = true;
    notifyListeners();

    // Simulate API call delay
    Future.delayed(const Duration(milliseconds: 800), () {
      _shift.isLive = false;
      _isClosed = true;
      _isLoading = false;
      notifyListeners();
    });
  }

  void resetShift() {
    _shift = ShiftModel(
      shiftId: 6014,
      shiftType: 'Evening',
      startDate: '23 Feb 2026',
      openedBy: 'System Auto-Start',
      grossAmount: 0,
      totalCollected: 0,
      receiptsRange: '-',
      receiptCount: 0,
    );
    _isClosed = false;
    notifyListeners();
  }
}