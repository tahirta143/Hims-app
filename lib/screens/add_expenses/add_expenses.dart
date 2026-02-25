import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../custum widgets/drawer/base_scaffold.dart';
import '../../providers/add_expenses/add_expenses.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExpensesProvider(),
      child: BaseScaffold(
        title: 'HIMS Expenses',
        drawerIndex: 2,
        showNotificationIcon: false,
        actions: [_ShiftBadge(), const SizedBox(width: 8), _RefreshButton()],
        body: const _ExpensesBody(),
      ),
    );
  }
}

// ─── Shift Badge ──────────────────────────────────────────────────────────────
class _ShiftBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<ExpensesProvider>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFF00B5AD),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                'Active Shift: ${p.shiftName}',
                style: const TextStyle(
                  color: Color(0xFF1A202C),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            'Shift Date: ${p.shiftDate}',
            style: const TextStyle(color: Color(0xFF718096), fontSize: 9),
          ),
        ],
      ),
    );
  }
}

// ─── Refresh Button ───────────────────────────────────────────────────────────
class _RefreshButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<ExpensesProvider>().clearSearch();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Refreshed'),
            backgroundColor: const Color(0xFF00B5AD),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.4)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.refresh_rounded, color: Colors.white, size: 15),
            SizedBox(width: 5),
            Text('Refresh',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────
// Uses Column (NOT SingleChildScrollView) so the transactions card
// can take all remaining space and scroll only its rows internally.
class _ExpensesBody extends StatelessWidget {
  const _ExpensesBody();

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final isWide = screenW > 800;
    final p = screenW < 400 ? 10.0 : 16.0;

    return Container(
      color: const Color(0xFFF0F4F8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Fixed top section ────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(p, p, p, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PageHeader(isWide: isWide),
                SizedBox(height: isWide ? 18 : 14),
                isWide
                    ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _TotalExpensesCard()),
                    const SizedBox(width: 14),
                    _AddExpenseCard(),
                  ],
                )
                    : Column(children: [
                  _TotalExpensesCard(),
                  const SizedBox(height: 12),
                  _AddExpenseCard(),
                ]),
                SizedBox(height: isWide ? 16 : 12),
              ],
            ),
          ),

          // ── Transactions card — fills remaining height ────────────────────
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(p, 0, p, p),
              child: const _RecentTransactionsCard(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Page Header ──────────────────────────────────────────────────────────────
class _PageHeader extends StatelessWidget {
  final bool isWide;
  const _PageHeader({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF00B5AD).withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.account_balance_wallet_outlined,
              color: Color(0xFF00B5AD), size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HIMS Expenses Management',
                style: TextStyle(
                    fontSize: isWide ? 22 : 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A202C)),
              ),
              const SizedBox(height: 2),
              // const Text(
              //   'Record and manage hospital expenses for the current shift',
              //   style: TextStyle(fontSize: 12, color: Color(0xFF718096)),
              // ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Total Expenses Card ──────────────────────────────────────────────────────
class _TotalExpensesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final total = context.watch<ExpensesProvider>().formattedTotal;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: const Border(
            bottom: BorderSide(color: Color(0xFF00B5AD), width: 3)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SHIFT TOTAL EXPENSES',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF718096),
                      letterSpacing: 0.8),
                ),
                const SizedBox(height: 8),
                Text(total,
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A202C))),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF00B5AD).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.account_balance_wallet_outlined,
                color: Color(0xFF00B5AD), size: 24),
          ),
        ],
      ),
    );
  }
}

// ─── Add Expense Card ─────────────────────────────────────────────────────────
class _AddExpenseCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF00B5AD),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF00B5AD).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add New Expense',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                Text('Record a new transaction',
                    style: TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<ExpensesProvider>(),
        child: const _AddExpenseDialog(),
      ),
    );
  }
}

// ─── Add Expense Dialog ───────────────────────────────────────────────────────
class _AddExpenseDialog extends StatefulWidget {
  const _AddExpenseDialog();

  @override
  State<_AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<_AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _expenseByCtrl =
  TextEditingController(text: 'System Administrator');
  final _descCtrl = TextEditingController();
  String _category = ExpensesProvider.categories.first;
  bool _isSaving = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _expenseByCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 400));
    context.read<ExpensesProvider>().addExpense(
      category: _category,
      amount: double.parse(_amountCtrl.text.trim()),
      expenseBy: _expenseByCtrl.text,
      description: _descCtrl.text,
    );
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Row(children: [
          Icon(Icons.check_circle, color: Colors.white),
          SizedBox(width: 10),
          Text('Expense saved successfully!'),
        ]),
        backgroundColor: const Color(0xFF00B5AD),
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return Dialog(
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: EdgeInsets.symmetric(
          horizontal: sw < 500 ? 16 : 40, vertical: 24),
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B5AD).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add_card_outlined,
                        color: Color(0xFF00B5AD), size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Add New Expense',
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A202C))),
                        Text('Record a new transaction',
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFF718096))),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded,
                        color: Color(0xFF718096)),
                  ),
                ]),
                const SizedBox(height: 20),
                const Divider(color: Color(0xFFF0F0F0)),
                const SizedBox(height: 16),

                // Category
                _lbl('Expense Category / Name', required: true),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _category,
                  isExpanded: true,
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF1A202C)),
                  decoration: _deco(icon: Icons.description_outlined),
                  items: ExpensesProvider.categories
                      .map((c) =>
                      DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _category = v!),
                ),
                const SizedBox(height: 16),

                // Amount
                _lbl('Amount (PKR)', required: true),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  style: const TextStyle(fontSize: 14),
                  decoration: _deco(hint: '0.00', icon: Icons.calculate_outlined),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Amount is required';
                    if (double.tryParse(v.trim()) == null)
                      return 'Enter a valid number';
                    if (double.parse(v.trim()) <= 0)
                      return 'Must be greater than 0';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Expense By
                _lbl('Expense By', required: true),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _expenseByCtrl,
                  style: const TextStyle(fontSize: 14),
                  decoration: _deco(icon: Icons.person_outline),
                  validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Description
                _lbl('Description / Remarks'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Add more details about this expense...',
                    hintStyle: const TextStyle(
                        color: Color(0xFFBDBDBD), fontSize: 13),
                    contentPadding: const EdgeInsets.all(14),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                        const BorderSide(color: Color(0xFFE2E8F0))),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                        const BorderSide(color: Color(0xFFE2E8F0))),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: Color(0xFF00B5AD), width: 1.5)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),

                // Save
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _save,
                    icon: _isSaving
                        ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.check_circle_outline, size: 18),
                    label: Text(
                      _isSaving ? 'Saving...' : 'Save Expense',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B5AD),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _lbl(String t, {bool required = false}) => RichText(
    text: TextSpan(
      text: t,
      style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF4A5568)),
      children: required
          ? const [
        TextSpan(
            text: ' *',
            style: TextStyle(color: Color(0xFFE53E3E)))
      ]
          : [],
    ),
  );

  InputDecoration _deco({String hint = '', IconData? icon}) =>
      InputDecoration(
        hintText: hint,
        hintStyle:
        const TextStyle(color: Color(0xFFBDBDBD), fontSize: 13),
        prefixIcon: icon != null
            ? Icon(icon, color: const Color(0xFFCBD5E0), size: 18)
            : null,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
            const BorderSide(color: Color(0xFF00B5AD), width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE53E3E))),
        filled: true,
        fillColor: Colors.white,
      );
}

// ─── Recent Transactions Card ─────────────────────────────────────────────────
// Card is a Column — header + table-header are FIXED, only ListView scrolls.
class _RecentTransactionsCard extends StatelessWidget {
  const _RecentTransactionsCard();

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 700;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Card title + search — FIXED ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: isCompact
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _title(),
                const SizedBox(height: 12),
                _SearchBar(),
              ],
            )
                : Row(children: [
              Expanded(child: _title()),
              const SizedBox(width: 16),
              SizedBox(width: 240, child: _SearchBar()),
            ]),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),

          // ── Table column headers — FIXED ──────────────────────────────────
          _TableHeader(isCompact: isCompact),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),

          // ── Only the rows scroll ──────────────────────────────────────────
          Expanded(
            child: _TransactionList(isCompact: isCompact),
          ),
        ],
      ),
    );
  }

  Widget _title() => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Recent Transactions',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A202C))),
      SizedBox(height: 2),
      Text('Summary of expenses recorded in this shift',
          style: TextStyle(fontSize: 12, color: Color(0xFF718096))),
    ],
  );
}

// ─── Search Bar ───────────────────────────────────────────────────────────────
class _SearchBar extends StatefulWidget {
  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      onChanged: (v) {
        setState(() {});
        context.read<ExpensesProvider>().setSearchQuery(v);
      },
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: 'Search expenses...',
        hintStyle:
        const TextStyle(color: Color(0xFFBDBDBD), fontSize: 12),
        prefixIcon:
        const Icon(Icons.search, color: Color(0xFFBDBDBD), size: 18),
        suffixIcon: _ctrl.text.isNotEmpty
            ? IconButton(
          icon: const Icon(Icons.clear,
              color: Color(0xFFBDBDBD), size: 16),
          onPressed: () {
            _ctrl.clear();
            setState(() {});
            context.read<ExpensesProvider>().clearSearch();
          },
        )
            : null,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
            const BorderSide(color: Color(0xFF00B5AD), width: 1.5)),
        filled: true,
        fillColor: const Color(0xFFF7FAFC),
      ),
    );
  }
}

// ─── Table Header ─────────────────────────────────────────────────────────────
class _TableHeader extends StatelessWidget {
  final bool isCompact;
  const _TableHeader({required this.isCompact});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7FAFC),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(children: [
        _h('ID', flex: 2),
        _h('EXPENSE DETAILS', flex: 4),
        _h('AMOUNT', flex: 2),
        if (!isCompact) _h('RECORDED BY', flex: 3),
        _h('ACTIONS', flex: 1, center: true),
      ]),
    );
  }

  Widget _h(String t, {int flex = 1, bool center = false}) => Expanded(
    flex: flex,
    child: Text(t,
        textAlign: center ? TextAlign.center : TextAlign.left,
        style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFF718096),
            letterSpacing: 0.5)),
  );
}

// ─── Transaction List (ListView only) ────────────────────────────────────────
class _TransactionList extends StatelessWidget {
  final bool isCompact;
  const _TransactionList({required this.isCompact});

  @override
  Widget build(BuildContext context) {
    final expenses = context.watch<ExpensesProvider>().expenses;

    if (expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            const Text('No expenses found',
                style: TextStyle(
                    color: Color(0xFF718096),
                    fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: expenses.length,
      itemBuilder: (_, i) => _TransactionRow(
        expense: expenses[i],
        isEven: i % 2 == 0,
        isCompact: isCompact,
      ),
    );
  }
}

// ─── Transaction Row ──────────────────────────────────────────────────────────
class _TransactionRow extends StatelessWidget {
  final ExpenseModel expense;
  final bool isEven;
  final bool isCompact;

  const _TransactionRow({
    required this.expense,
    required this.isEven,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isEven ? Colors.white : const Color(0xFFFAFAFA),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ID badge
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF00B5AD).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(expense.id,
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00B5AD))),
            ),
          ),

          // Details
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense.category,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A202C))),
                const SizedBox(height: 2),
                Row(children: [
                  const Icon(Icons.access_time,
                      size: 11, color: Color(0xFF718096)),
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text(expense.formattedTime,
                        style: const TextStyle(
                            fontSize: 10, color: Color(0xFF718096)),
                        overflow: TextOverflow.ellipsis),
                  ),
                ]),
                if (expense.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(expense.description,
                      style: const TextStyle(
                          fontSize: 10, color: Color(0xFFA0AEC0)),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1),
                ],
              ],
            ),
          ),

          // Amount
          Expanded(
            flex: 2,
            child: Text(expense.formattedAmount,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A202C))),
          ),

          // Recorded by
          if (!isCompact)
            Expanded(
              flex: 3,
              child: Row(children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00B5AD).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      expense.expenseBy.isNotEmpty
                          ? expense.expenseBy[0].toUpperCase()
                          : 'S',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00B5AD)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(expense.expenseBy,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF4A5568)),
                      overflow: TextOverflow.ellipsis),
                ),
              ]),
            ),

          // Delete
          Expanded(
            flex: 1,
            child: Center(
              child: GestureDetector(
                onTap: () => _del(context, expense),
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53E3E).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Icon(Icons.delete_outline_rounded,
                      color: Color(0xFFE53E3E), size: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _del(BuildContext context, ExpenseModel e) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Delete Expense?'),
        content: Text(
            'Remove ${e.category} — ${e.formattedAmount}? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF718096))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ExpensesProvider>().deleteExpense(e.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53E3E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}