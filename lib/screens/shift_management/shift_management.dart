import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../custum widgets/drawer/base_scaffold.dart';
import '../../providers/shift_management/shift_management.dart';

class ShiftManagementScreen extends StatelessWidget {
  const ShiftManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ShiftProvider(),
      child: BaseScaffold(
        title: 'Shift Management',
        drawerIndex: 7, // Update to match your drawer index
        body: const _ShiftManagementBody(),
      ),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────
class _ShiftManagementBody extends StatelessWidget {
  const _ShiftManagementBody();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate responsive padding
    final horizontalPadding = screenWidth * 0.04; // 4% of screen width
    final verticalPadding = screenHeight * 0.02; // 2% of screen height

    return Container(
      color: const Color(0xFFF0F4F8),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding.clamp(12, 24), // Min 12, Max 24
          vertical: verticalPadding.clamp(8, 16), // Min 8, Max 16
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PageHeader(),
            SizedBox(height: screenHeight * 0.02), // Responsive spacing
            _ActiveShiftCard(),
            SizedBox(height: screenHeight * 0.015), // Responsive spacing
            _ShiftDetailsCard(),
            SizedBox(height: screenHeight * 0.015),
            _AmountRow(),
            SizedBox(height: screenHeight * 0.015),
            _ManualClosingCard(),
            SizedBox(height: screenHeight * 0.03),
          ],
        ),
      ),
    );
  }
}

// ─── Page Header ──────────────────────────────────────────────────────────────
class _PageHeader extends StatelessWidget {
  const _PageHeader();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive font sizes
    final titleFontSize = screenWidth * 0.06; // 6% of screen width
    final subtitleFontSize = screenWidth * 0.035; // 3.5% of screen width

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shift Management',
          style: TextStyle(
            fontSize: titleFontSize.clamp(20, 28), // Min 20, Max 28
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A202C),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Monitor active shifts and manage daily closing',
          style: TextStyle(
            fontSize: subtitleFontSize.clamp(12, 14), // Min 12, Max 14
            color: const Color(0xFF718096),
          ),
        ),
      ],
    );
  }
}

// ─── Active Shift Card ────────────────────────────────────────────────────────
class _ActiveShiftCard extends StatelessWidget {
  const _ActiveShiftCard();

  @override
  Widget build(BuildContext context) {
    final shift = context.watch<ShiftProvider>().shift;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive padding
    final cardPadding = screenWidth * 0.04; // 4% of screen width
    final iconSize = screenWidth * 0.055; // 5.5% of screen width
    final titleFontSize = screenWidth * 0.04; // 4% of screen width
    final subtitleFontSize = screenWidth * 0.035; // 3.5% of screen width

    return Container(
      padding: EdgeInsets.all(cardPadding.clamp(12, 20)), // Min 12, Max 20
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: iconSize.clamp(36, 48), // Min 36, Max 48
            height: iconSize.clamp(36, 48),
            decoration: BoxDecoration(
              color: const Color(0xFF00B5AD).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.monitor_heart_outlined,
              color: const Color(0xFF00B5AD),
              size: iconSize.clamp(18, 24), // Min 18, Max 24
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Active Shift',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: titleFontSize.clamp(14, 18), // Min 14, Max 18
                    color: const Color(0xFF1A202C),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Shift ID: ${shift.shiftId} (${shift.shiftType})',
                  style: TextStyle(
                    fontSize: subtitleFontSize.clamp(12, 14), // Min 12, Max 14
                    color: const Color(0xFF718096),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.02, // 2% of screen width
              vertical: screenWidth * 0.015, // 1.5% of screen width
            ).clamp(const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF00B5AD)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: screenWidth * 0.015, // 1.5% of screen width
                  height: screenWidth * 0.015,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00B5AD),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: screenWidth * 0.01), // 1% of screen width
                Text(
                  'LIVE STATUS',
                  style: TextStyle(
                    color: const Color(0xFF00B5AD),
                    fontSize: screenWidth * 0.025, // 2.5% of screen width
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ).copyWith(fontSize: (screenWidth * 0.025).clamp(10, 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shift Details Card ───────────────────────────────────────────────────────
// ─── Shift Details Card ───────────────────────────────────────────────────────
class _ShiftDetailsCard extends StatelessWidget {
  const _ShiftDetailsCard();

  @override
  Widget build(BuildContext context) {
    final shift = context.watch<ShiftProvider>().shift;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive padding
    final horizontalPadding = screenWidth * 0.04; // 4% of screen width
    final verticalPadding = screenWidth * 0.045; // 4.5% of screen width

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding.clamp(12, 20), // Min 12, Max 20
        vertical: verticalPadding.clamp(14, 24), // Min 14, Max 24
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shift ID
              SizedBox(
                width: screenWidth * 0.2, // Fixed width based on screen
                child: _DetailColumn(
                  label: 'SHIFT ID',
                  value: shift.shiftId.toString(),
                ),
              ),

              // Vertical divider
              Container(
                width: 1,
                height: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                color: const Color(0xFFE2E8F0),
              ),

              // Shift Type
              SizedBox(
                width: screenWidth * 0.2,
                child: _DetailColumn(
                  label: 'SHIFT TYPE',
                  value: shift.shiftType,
                ),
              ),

              // Vertical divider
              Container(
                width: 1,
                height: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                color: const Color(0xFFE2E8F0),
              ),

              // Start Date
              SizedBox(
                width: screenWidth * 0.25,
                child: _DetailColumn(
                  label: 'START DATE',
                  value: shift.startDate,
                ),
              ),

              // Vertical divider
              Container(
                width: 1,
                height: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                color: const Color(0xFFE2E8F0),
              ),

              // Opened By
              SizedBox(
                width: screenWidth * 0.3,
                child: _DetailColumn(
                  label: 'OPENED BY',
                  value: shift.openedBy,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _DetailColumn extends StatelessWidget {
  final String label;
  final String value;

  const _DetailColumn({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: screenWidth * 0.025, // 2.5% of screen width
            color: const Color(0xFF718096),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ).copyWith(fontSize: (screenWidth * 0.025).clamp(9, 11)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: screenWidth * 0.035, // 3.5% of screen width
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A202C),
          ).copyWith(fontSize: (screenWidth * 0.035).clamp(12, 16)),
        ),
      ],
    );
  }
}

// ─── Amount Row ───────────────────────────────────────────────────────────────
class _AmountRow extends StatelessWidget {
  const _AmountRow();

  String _formatAmount(double amount) {
    if (amount >= 1000) {
      final thousands = (amount / 1000).floor();
      final remainder = (amount % 1000).toInt().toString().padLeft(3, '0');
      return '$thousands,$remainder';
    }
    return amount.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final shift = context.watch<ShiftProvider>().shift;
    final screenWidth = MediaQuery.of(context).size.width;

    // For very narrow screens, stack vertically
    if (screenWidth < 400) {
      return Column(
        children: [
          _AmountCard(
            label: 'GROSS AMOUNT',
            amount: 'PKR ${_formatAmount(shift.grossAmount)}',
            subtitle: '${shift.receiptCount} Receipts (${shift.receiptsRange})',
            icon: Icons.receipt_long_outlined,
            isHighlighted: false,
          ),
          const SizedBox(height: 12),
          _AmountCard(
            label: 'TOTAL COLLECTED',
            amount: 'PKR ${_formatAmount(shift.totalCollected)}',
            icon: Icons.account_balance_wallet_outlined,
            isHighlighted: true,
          ),
        ],
      );
    }

    // Normal row layout
    return Row(
      children: [
        Expanded(
          child: _AmountCard(
            label: 'GROSS AMOUNT',
            amount: 'PKR ${_formatAmount(shift.grossAmount)}',
            subtitle: '${shift.receiptCount} Receipts (${shift.receiptsRange})',
            icon: Icons.receipt_long_outlined,
            isHighlighted: false,
          ),
        ),
        SizedBox(width: screenWidth * 0.03), // 3% of screen width
        Expanded(
          child: _AmountCard(
            label: 'TOTAL COLLECTED',
            amount: 'PKR ${_formatAmount(shift.totalCollected)}',
            icon: Icons.account_balance_wallet_outlined,
            isHighlighted: true,
          ),
        ),
      ],
    );
  }
}

class _AmountCard extends StatelessWidget {
  final String label;
  final String amount;
  final String? subtitle;
  final IconData icon;
  final bool isHighlighted;

  const _AmountCard({
    required this.label,
    required this.amount,
    this.subtitle,
    required this.icon,
    required this.isHighlighted,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive padding
    final cardPadding = screenWidth * 0.04; // 4% of screen width
    final iconSize = screenWidth * 0.045; // 4.5% of screen width

    return Container(
      padding: EdgeInsets.all(cardPadding.clamp(12, 20)), // Min 12, Max 20
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isHighlighted
            ? const Border(
            left: BorderSide(color: Color(0xFF00B5AD), width: 3))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: screenWidth * 0.025, // 2.5% of screen width
                    fontWeight: FontWeight.w700,
                    color: isHighlighted
                        ? const Color(0xFF00B5AD)
                        : const Color(0xFF718096),
                    letterSpacing: 0.5,
                  ).copyWith(fontSize: (screenWidth * 0.025).clamp(9, 11)),
                ),
                const SizedBox(height: 6),
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: screenWidth * 0.05, // 5% of screen width
                    fontWeight: FontWeight.bold,
                    color: isHighlighted
                        ? const Color(0xFF00B5AD)
                        : const Color(0xFF1A202C),
                  ).copyWith(fontSize: (screenWidth * 0.05).clamp(16, 24)),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: screenWidth * 0.028, // 2.8% of screen width
                      color: const Color(0xFF718096),
                    ).copyWith(fontSize: (screenWidth * 0.028).clamp(10, 12)),
                  ),
                ],
              ],
            ),
          ),
          Container(
            width: iconSize.clamp(28, 40), // Min 28, Max 40
            height: iconSize.clamp(28, 40),
            decoration: BoxDecoration(
              color: const Color(0xFF00B5AD).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF00B5AD),
              size: iconSize.clamp(14, 20), // Min 14, Max 20
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Manual Closing Card ──────────────────────────────────────────────────────
class _ManualClosingCard extends StatefulWidget {
  const _ManualClosingCard();

  @override
  State<_ManualClosingCard> createState() => _ManualClosingCardState();
}

class _ManualClosingCardState extends State<_ManualClosingCard> {
  final TextEditingController _closedByCtrl =
  TextEditingController(text: 'Admin');
  final TextEditingController _cashCtrl = TextEditingController();

  @override
  void dispose() {
    _closedByCtrl.dispose();
    _cashCtrl.dispose();
    super.dispose();
  }

  void _onCloseShiftTapped() {
    final cash = double.tryParse(_cashCtrl.text) ?? 0.0;
    final closedBy = _closedByCtrl.text.trim().isEmpty
        ? 'Admin'
        : _closedByCtrl.text.trim();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CloseShiftDialog(
        closedBy: closedBy,
        cashInHand: cash,
        onConfirm: () {
          context.read<ShiftProvider>().closeShift(closedBy, cash);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 10),
                  Text('Shift closed successfully!'),
                ],
              ),
              backgroundColor: const Color(0xFF00B5AD),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isClosed = context.watch<ShiftProvider>().isClosed;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE53E3E).withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Red tinted header
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04, // 4% of screen width
              vertical: screenHeight * 0.015, // 1.5% of screen height
            ).clamp(const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5F5),
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(
                bottom: BorderSide(
                    color: const Color(0xFFE53E3E).withOpacity(0.2)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53E3E).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.stop_circle_outlined,
                    color: Color(0xFFE53E3E),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Manual Closing',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.04, // 4% of screen width
                    color: const Color(0xFF1A202C),
                  ).copyWith(fontSize: (screenWidth * 0.04).clamp(14, 18)),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04).clamp(
                const EdgeInsets.all(12),
                const EdgeInsets.all(20)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Enter cash in hand to close the shift',
                  style: TextStyle(
                    fontSize: screenWidth * 0.035, // 3.5% of screen width
                    color: const Color(0xFF718096),
                  ).copyWith(fontSize: (screenWidth * 0.035).clamp(12, 14)),
                ),
                SizedBox(height: screenHeight * 0.02), // 2% of screen height
                if (isClosed)
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.035).clamp(
                        const EdgeInsets.all(10),
                        const EdgeInsets.all(16)
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B5AD).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFF00B5AD).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline,
                            color: Color(0xFF00B5AD)),
                        SizedBox(width: screenWidth * 0.02),
                        Expanded(
                          child: Text(
                            'Shift has been successfully closed.',
                            style: TextStyle(
                              color: const Color(0xFF00B5AD),
                              fontWeight: FontWeight.w600,
                              fontSize: screenWidth * 0.035,
                            ).copyWith(fontSize: (screenWidth * 0.035).clamp(12, 14)),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // For very narrow screens, stack vertically
                      if (constraints.maxWidth < 500) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildTextField(
                              controller: _closedByCtrl,
                              label: 'CLOSED BY',
                              hint: 'Admin',
                              readOnly: true,
                            ),
                            SizedBox(height: screenHeight * 0.015),
                            _buildTextField(
                              controller: _cashCtrl,
                              label: 'ACTUAL CASH IN HAND *',
                              hint: '0.00',
                              keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _onCloseShiftTapped,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1A202C),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                  padding: EdgeInsets.symmetric(
                                    vertical: screenHeight * 0.02,
                                  ),
                                ),
                                child: const Text(
                                  'Close Shift',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      // Normal row layout
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _closedByCtrl,
                              label: 'CLOSED BY',
                              hint: 'Admin',
                              readOnly: true,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          Expanded(
                            child: _buildTextField(
                              controller: _cashCtrl,
                              label: 'ACTUAL CASH IN HAND *',
                              hint: '0.00',
                              keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          SizedBox(
                            height: screenHeight * 0.07, // 7% of screen height
                            child: ElevatedButton(
                              onPressed: _onCloseShiftTapped,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1A202C),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.04,
                                ),
                              ),
                              child: Text(
                                'Close Shift',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: screenWidth * 0.035,
                                ).copyWith(fontSize: (screenWidth * 0.035).clamp(12, 14)),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: screenWidth * 0.025, // 2.5% of screen width
            fontWeight: FontWeight.w700,
            color: const Color(0xFF718096),
            letterSpacing: 0.5,
          ).copyWith(fontSize: (screenWidth * 0.025).clamp(9, 11)),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: screenWidth * 0.035, // 3.5% of screen width
          ).copyWith(fontSize: (screenWidth * 0.035).clamp(13, 15)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
            contentPadding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.035,
              vertical: screenWidth * 0.035,
            ).clamp(
              const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
              const BorderSide(color: Color(0xFF00B5AD), width: 1.5),
            ),
            filled: true,
            fillColor: readOnly ? const Color(0xFFF7FAFC) : Colors.white,
          ),
        ),
      ],
    );
  }
}

// ─── Close Shift Dialog ───────────────────────────────────────────────────────
class _CloseShiftDialog extends StatelessWidget {
  final String closedBy;
  final double cashInHand;
  final VoidCallback onConfirm;

  const _CloseShiftDialog({
    required this.closedBy,
    required this.cashInHand,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive dialog padding
    final dialogPadding = screenWidth * 0.06; // 6% of screen width

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(dialogPadding.clamp(16, 28)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: screenWidth * 0.15, // 15% of screen width
              height: screenWidth * 0.15,
              decoration: BoxDecoration(
                color: const Color(0xFFE53E3E).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: const Color(0xFFE53E3E),
                size: screenWidth * 0.08, // 8% of screen width
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              'Close Shift?',
              style: TextStyle(
                fontSize: screenWidth * 0.05, // 5% of screen width
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A202C),
              ).copyWith(fontSize: (screenWidth * 0.05).clamp(18, 24)),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              'This action will close the current shift and cannot be undone. Please confirm the details below.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: screenWidth * 0.035, // 3.5% of screen width
                color: const Color(0xFF718096),
              ).copyWith(fontSize: (screenWidth * 0.035).clamp(12, 14)),
            ),
            SizedBox(height: screenHeight * 0.025),

            // Summary
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(screenWidth * 0.035).clamp(
                  const EdgeInsets.all(10),
                  const EdgeInsets.all(16)
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SummaryRow(
                    label: 'Closed By',
                    value: closedBy,
                    screenWidth: screenWidth,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(height: 1, color: Color(0xFFE2E8F0)),
                  ),
                  _SummaryRow(
                    label: 'Cash in Hand',
                    value: 'PKR ${cashInHand.toStringAsFixed(2)}',
                    valueColor: const Color(0xFF00B5AD),
                    screenWidth: screenWidth,
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.03),

            // Buttons - stack vertically on very narrow screens
            if (screenWidth < 350)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF718096),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.015,
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53E3E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.015,
                        ),
                      ),
                      child: const Text(
                        'Confirm Close',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF718096),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.015,
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53E3E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.015,
                        ),
                      ),
                      child: const Text(
                        'Confirm Close',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final double screenWidth;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor = const Color(0xFF1A202C),
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: screenWidth * 0.035, // 3.5% of screen width
            color: const Color(0xFF718096),
          ).copyWith(fontSize: (screenWidth * 0.035).clamp(12, 14)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: screenWidth * 0.035, // 3.5% of screen width
            fontWeight: FontWeight.bold,
            color: valueColor,
          ).copyWith(fontSize: (screenWidth * 0.035).clamp(12, 14)),
        ),
      ],
    );
  }
}

