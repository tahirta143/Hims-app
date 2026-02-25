import 'package:flutter/material.dart';

// ─── Expense Model ────────────────────────────────────────────────────────────
class ExpenseModel {
  final String id;
  final String category;
  final double amount;
  final String expenseBy;
  final String description;
  final DateTime recordedAt;

  ExpenseModel({
    required this.id,
    required this.category,
    required this.amount,
    required this.expenseBy,
    this.description = '',
    required this.recordedAt,
  });

  String get formattedTime {
    final h = recordedAt.hour > 12 ? recordedAt.hour - 12 : recordedAt.hour == 0 ? 12 : recordedAt.hour;
    final m = recordedAt.minute.toString().padLeft(2, '0');
    final period = recordedAt.hour >= 12 ? 'PM' : 'AM';
    final day = recordedAt.day.toString().padLeft(2, '0');
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '$h:$m $period | $day ${months[recordedAt.month - 1]} ${recordedAt.year}';
  }

  String get formattedAmount => 'PKR ${_formatNum(amount)}';

  static String _formatNum(double n) {
    if (n >= 1000) {
      final parts = n.toStringAsFixed(0).split('');
      final result = StringBuffer();
      for (int i = 0; i < parts.length; i++) {
        if (i > 0 && (parts.length - i) % 3 == 0) result.write(',');
        result.write(parts[i]);
      }
      return result.toString();
    }
    return n.toStringAsFixed(0);
  }
}

// ─── Expenses Provider ────────────────────────────────────────────────────────
class ExpensesProvider extends ChangeNotifier {
  // Expense categories
  static const List<String> categories = [
    'Ambulance',
    'Medicines',
    'Lab Supplies',
    'Maintenance',
    'Electricity',
    'Water & Gas',
    'Staff Salary',
    'Equipment',
    'Cleaning',
    'Catering',
    'Security',
    'Other',
  ];

  // Shift info (mock)
  final String shiftName = 'Morning';
  final String shiftDate = '23 Feb 2026';

  // Mock initial transactions
  final List<ExpenseModel> _expenses = [
    ExpenseModel(
      id: 'EXP0001',
      category: 'Medicines',
      amount: 1500,
      expenseBy: 'System Administrator',
      description: 'Monthly medicine stock',
      recordedAt: DateTime(2026, 2, 25, 9, 15),
    ),
    ExpenseModel(
      id: 'EXP0002',
      category: 'Electricity',
      amount: 8500,
      expenseBy: 'System Administrator',
      description: 'February electricity bill',
      recordedAt: DateTime(2026, 2, 25, 10, 42),
    ),
    ExpenseModel(
      id: 'EXP0003',
      category: 'Ambulance',
      amount: 2333,
      expenseBy: 'System Administrator',
      description: '',
      recordedAt: DateTime(2026, 2, 25, 11, 38),
    ),
    ExpenseModel(
      id: 'EXP0004',
      category: 'Cleaning',
      amount: 700,
      expenseBy: 'System Administrator',
      description: 'Cleaning supplies for ward',
      recordedAt: DateTime(2026, 2, 25, 12, 5),
    ),
  ];

  String _searchQuery = '';
  int _expenseCounter = 4;

  // ── Getters ───────────────────────────────────────────────────────────────
  List<ExpenseModel> get expenses {
    if (_searchQuery.trim().isEmpty) return List.from(_expenses);
    final q = _searchQuery.toLowerCase();
    return _expenses.where((e) {
      return e.category.toLowerCase().contains(q) ||
          e.id.toLowerCase().contains(q) ||
          e.expenseBy.toLowerCase().contains(q) ||
          e.description.toLowerCase().contains(q);
    }).toList();
  }

  double get totalExpenses =>
      _expenses.fold(0, (sum, e) => sum + e.amount);

  String get formattedTotal {
    final n = totalExpenses;
    if (n >= 1000) {
      final s = n.toStringAsFixed(0);
      final buffer = StringBuffer();
      for (int i = 0; i < s.length; i++) {
        if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
        buffer.write(s[i]);
      }
      return 'PKR ${buffer.toString()}';
    }
    return 'PKR ${n.toStringAsFixed(0)}';
  }

  String get searchQuery => _searchQuery;

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  String _nextId() {
    _expenseCounter++;
    return 'EXP${_expenseCounter.toString().padLeft(4, '0')}';
  }

  void addExpense({
    required String category,
    required double amount,
    required String expenseBy,
    String description = '',
  }) {
    _expenses.insert(
      0,
      ExpenseModel(
        id: _nextId(),
        category: category,
        amount: amount,
        expenseBy: expenseBy.trim().isEmpty ? 'System Administrator' : expenseBy.trim(),
        description: description.trim(),
        recordedAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void deleteExpense(String id) {
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}