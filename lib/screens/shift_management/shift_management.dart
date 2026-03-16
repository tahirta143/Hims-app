import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../custum widgets/drawer/base_scaffold.dart';
import '../../providers/shift_management/shift_management.dart';
import '../../custum widgets/custom_loader.dart';

class ShiftManagementScreen extends StatelessWidget {
  const ShiftManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ShiftProvider(),
      child: BaseScaffold(
        title: 'Shift Management',
        drawerIndex: 7,
        showNotificationIcon: false,
        actions: [const SizedBox(width: 8), _RefreshButton()],
        body: const _ShiftManagementBody(),
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
        context.read<ShiftProvider>().refresh();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Refreshed'),
          backgroundColor: const Color(0xFF00B5AD),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ));
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
class _ShiftManagementBody extends StatelessWidget {
  const _ShiftManagementBody();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShiftProvider>();
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final hp = (sw * 0.04).clamp(12.0, 24.0);
    final vp = (sh * 0.02).clamp(8.0, 16.0);

    return Container(
      color: const Color(0xFFF0F4F8),
      child: provider.isLoading
          ? const Center(
          child: CustomLoader(size: 60))
          : RefreshIndicator(
        color: const Color(0xFF00B5AD),
        onRefresh: () => provider.refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: hp, vertical: vp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _PageHeader(),
              SizedBox(height: sh * 0.02),

              // ── Error banner ───────────────────────────────────
              if (provider.errorMessage != null)
                _ErrorBanner(message: provider.errorMessage!),

              const _ActiveShiftCard(),
              SizedBox(height: sh * 0.015),
              const _ShiftDetailsCard(),
              SizedBox(height: sh * 0.015),
              const _ManualClosingCard(),
              SizedBox(height: sh * 0.015),
              const _ShiftHistoryCard(),
              SizedBox(height: sh * 0.03),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Error Banner ─────────────────────────────────────────────────────────────
class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE53E3E).withOpacity(0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.info_outline, color: Color(0xFFE53E3E), size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(message,
              style: const TextStyle(color: Color(0xFFE53E3E), fontSize: 13)),
        ),
        GestureDetector(
          onTap: () => context.read<ShiftProvider>().fetchCurrentShift(),
          child: const Text('Retry',
              style: TextStyle(
                  color: Color(0xFFE53E3E),
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
        )
      ]),
    );
  }
}

// ─── Page Header ──────────────────────────────────────────────────────────────
class _PageHeader extends StatelessWidget {
  const _PageHeader();

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text('Shift Management',
        //     style: TextStyle(
        //         fontSize: (sw * 0.06).clamp(20, 28),
        //         fontWeight: FontWeight.bold,
        //         color: const Color(0xFF1A202C))),
        // const SizedBox(height: 4),
        // Text('Monitor active shifts and manage daily closing',
        //     style: TextStyle(
        //         fontSize: (sw * 0.035).clamp(12, 14),
        //         color: const Color(0xFF718096))),
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
    final sw = MediaQuery.of(context).size.width;
    final cp = (sw * 0.04).clamp(12.0, 20.0);

    return Container(
      padding: EdgeInsets.all(cp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: (sw * 0.055).clamp(36, 48),
            height: (sw * 0.055).clamp(36, 48),
            decoration: BoxDecoration(
              color: const Color(0xFF00B5AD).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.monitor_heart_outlined,
                color: const Color(0xFF00B5AD),
                size: (sw * 0.055).clamp(18, 24)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Active Shift',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: (sw * 0.04).clamp(14, 18),
                        color: const Color(0xFF1A202C))),
                const SizedBox(height: 2),
                Text(
                  shift.shiftId == 0
                      ? 'No active shift'
                      : 'Shift ID: ${shift.shiftId} · ${shift.shiftType} · ${shift.startDate}',
                  style: TextStyle(
                      fontSize: (sw * 0.035).clamp(12, 14),
                      color: const Color(0xFF718096)),
                ),
              ],
            ),
          ),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              border: Border.all(
                  color: shift.isClosed
                      ? const Color(0xFFE53E3E)
                      : const Color(0xFF00B5AD)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: shift.isClosed
                        ? const Color(0xFFE53E3E)
                        : const Color(0xFF00B5AD),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  shift.isClosed ? 'CLOSED' : 'LIVE',
                  style: TextStyle(
                      color: shift.isClosed
                          ? const Color(0xFFE53E3E)
                          : const Color(0xFF00B5AD),
                      fontSize: (sw * 0.025).clamp(10, 12),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5),
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
class _ShiftDetailsCard extends StatelessWidget {
  const _ShiftDetailsCard();

  @override
  Widget build(BuildContext context) {
    final shift = context.watch<ShiftProvider>().shift;
    final sw = MediaQuery.of(context).size.width;
    final hp = (sw * 0.04).clamp(12.0, 20.0);
    final vp = (sw * 0.045).clamp(14.0, 24.0);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hp, vertical: vp),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                  width: sw * 0.2,
                  child: _DetailColumn(
                      label: 'SHIFT ID',
                      value: shift.shiftId == 0
                          ? '--'
                          : shift.shiftId.toString())),
              _vDivider(),
              SizedBox(
                  width: sw * 0.2,
                  child: _DetailColumn(
                      label: 'SHIFT TYPE', value: shift.shiftType)),
              _vDivider(),
              SizedBox(
                  width: sw * 0.25,
                  child: _DetailColumn(
                      label: 'START DATE', value: shift.startDate)),
              _vDivider(),
              SizedBox(
                  width: sw * 0.25,
                  child: _DetailColumn(
                      label: 'START TIME',
                      value: shift.shiftId == 0
                          ? '--'
                          : shift.startTimeFormatted)),
              _vDivider(),
              SizedBox(
                  width: sw * 0.3,
                  child: _DetailColumn(
                      label: 'OPENED BY', value: shift.openedBy)),
              if (shift.isClosed) ...[
                _vDivider(),
                SizedBox(
                    width: sw * 0.3,
                    child: _DetailColumn(
                        label: 'CLOSED BY',
                        value: shift.closedBy ?? '--')),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _vDivider() => Container(
    width: 1,
    height: double.infinity,
    margin: const EdgeInsets.symmetric(horizontal: 12),
    color: const Color(0xFFE2E8F0),
  );
}

class _DetailColumn extends StatelessWidget {
  final String label;
  final String value;
  const _DetailColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: (sw * 0.025).clamp(9, 11),
                color: const Color(0xFF718096),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: (sw * 0.035).clamp(12, 16),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A202C))),
      ],
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
  final _closedByCtrl = TextEditingController(text: 'Admin');
  final _cashCtrl = TextEditingController();

  @override
  void dispose() {
    _closedByCtrl.dispose();
    _cashCtrl.dispose();
    super.dispose();
  }

  void _onCloseShiftTapped() {
    final cash = double.tryParse(_cashCtrl.text) ?? 0.0;
    final closedBy =
    _closedByCtrl.text.trim().isEmpty ? 'Admin' : _closedByCtrl.text.trim();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CloseShiftDialog(
        closedBy: closedBy,
        cashInHand: cash,
        onConfirm: () async {
          final success =
          await context.read<ShiftProvider>().closeShift(closedBy, cash);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Row(children: [
                Icon(
                    success ? Icons.check_circle : Icons.error_outline,
                    color: Colors.white),
                const SizedBox(width: 10),
                Text(success
                    ? 'Shift closed successfully!'
                    : 'Failed to close shift. Please try again.'),
              ]),
              backgroundColor:
              success ? const Color(0xFF00B5AD) : const Color(0xFFE53E3E),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ));
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShiftProvider>();
    final isClosed = provider.isClosed;
    final isClosing = provider.isClosing;
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE53E3E).withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Red header ──────────────────────────────────────────────
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: (sw * 0.04).clamp(12, 20),
                vertical: (sh * 0.015).clamp(10, 16)),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5F5),
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(12)),
              border: Border(
                  bottom: BorderSide(
                      color: const Color(0xFFE53E3E).withOpacity(0.2))),
            ),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53E3E).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.stop_circle_outlined,
                    color: Color(0xFFE53E3E), size: 18),
              ),
              const SizedBox(width: 10),
              Text('Manual Closing',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: (sw * 0.04).clamp(14, 18),
                      color: const Color(0xFF1A202C))),
            ]),
          ),

          Padding(
            padding: EdgeInsets.all((sw * 0.04).clamp(12, 20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Enter cash in hand to close the shift',
                    style: TextStyle(
                        fontSize: (sw * 0.035).clamp(12, 14),
                        color: const Color(0xFF718096))),
                SizedBox(height: sh * 0.02),

                // ── Already closed ───────────────────────────────────
                if (isClosed)
                  Container(
                    padding: EdgeInsets.all((sw * 0.035).clamp(10, 16)),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B5AD).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFF00B5AD).withOpacity(0.3)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.check_circle_outline,
                          color: Color(0xFF00B5AD)),
                      SizedBox(width: sw * 0.02),
                      Expanded(
                        child: Text(
                          'This shift has been closed by ${provider.shift.closedBy ?? "Admin"}.',
                          style: TextStyle(
                              color: const Color(0xFF00B5AD),
                              fontWeight: FontWeight.w600,
                              fontSize: (sw * 0.035).clamp(12, 14)),
                        ),
                      ),
                    ]),
                  )

                // ── Close form ───────────────────────────────────────
                else
                  LayoutBuilder(
                    builder: (_, constraints) {
                      final isNarrow = constraints.maxWidth < 500;
                      final fields = [
                        _buildTextField(
                            controller: _closedByCtrl,
                            label: 'CLOSED BY',
                            hint: 'Admin',
                            readOnly: true),
                        if (isNarrow) SizedBox(height: sh * 0.015),
                        _buildTextField(
                            controller: _cashCtrl,
                            label: 'ACTUAL CASH IN HAND *',
                            hint: '0.00',
                            keyboardType:
                            const TextInputType.numberWithOptions(
                                decimal: true)),
                      ];

                      final closeBtn = SizedBox(
                        width: isNarrow ? double.infinity : null,
                        height: isNarrow ? null : sh * 0.07,
                        child: ElevatedButton(
                          onPressed: isClosing ? null : _onCloseShiftTapped,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A202C),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                            padding: isNarrow
                                ? EdgeInsets.symmetric(vertical: sh * 0.02)
                                : EdgeInsets.symmetric(
                                horizontal: sw * 0.04),
                          ),
                          child: isClosing
                              ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CustomLoader(
                                  size: 18))
                              : Text('Close Shift',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                  (sw * 0.035).clamp(12, 14))),
                        ),
                      );

                      if (isNarrow) {
                        return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ...fields,
                              SizedBox(height: sh * 0.02),
                              closeBtn,
                            ]);
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(child: fields[0]),
                          SizedBox(width: sw * 0.03),
                          Expanded(child: fields[1]),
                          SizedBox(width: sw * 0.03),
                          closeBtn,
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
    final sw = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: (sw * 0.025).clamp(9, 11),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF718096),
                letterSpacing: 0.5)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: (sw * 0.035).clamp(13, 15)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 14),
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
            fillColor:
            readOnly ? const Color(0xFFF7FAFC) : Colors.white,
          ),
        ),
      ],
    );
  }
}

// ─── Shift History Card ───────────────────────────────────────────────────────
class _ShiftHistoryCard extends StatelessWidget {
  const _ShiftHistoryCard();

  @override
  Widget build(BuildContext context) {
    final shifts = context.watch<ShiftProvider>().activeShifts;
    final sw = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
                (sw * 0.04).clamp(12, 20),
                (sw * 0.04).clamp(12, 18),
                (sw * 0.04).clamp(12, 20),
                0),
            child: Row(children: [
              const Text('Shift History',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A202C))),
              const SizedBox(width: 8),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF00B5AD).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${shifts.length} shifts',
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF00B5AD))),
              ),
            ]),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),

          // ── Table header ──────────────────────────────────────────
          Container(
            color: const Color(0xFFF7FAFC),
            padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(children: [
              _th('SHIFT ID', flex: 2),
              _th('TYPE', flex: 2),
              _th('DATE', flex: 3),
              _th('OPENED BY', flex: 3),
              _th('STATUS', flex: 2, center: true),
            ]),
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),

          // ── Rows ──────────────────────────────────────────────────
          if (shifts.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text('No shifts found',
                    style: TextStyle(color: Color(0xFF718096))),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: shifts.length,
              separatorBuilder: (_, __) =>
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              itemBuilder: (_, i) =>
                  _ShiftRow(shift: shifts[i], isEven: i % 2 == 0),
            ),
        ],
      ),
    );
  }

  Widget _th(String t, {int flex = 1, bool center = false}) => Expanded(
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

// ─── Shift Row ────────────────────────────────────────────────────────────────
class _ShiftRow extends StatelessWidget {
  final ShiftModel shift;
  final bool isEven;

  const _ShiftRow({required this.shift, required this.isEven});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return Container(
      color: isEven ? Colors.white : const Color(0xFFFAFAFA),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Shift ID
          Expanded(
            flex: 2,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF00B5AD).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(shift.shiftId.toString(),
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00B5AD))),
            ),
          ),

          // Type
          Expanded(
            flex: 2,
            child: Text(shift.shiftType,
                style: TextStyle(
                    fontSize: (sw * 0.032).clamp(11, 13),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A202C))),
          ),

          // Date
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(shift.shiftDate,
                    style: TextStyle(
                        fontSize: (sw * 0.03).clamp(10, 12),
                        color: const Color(0xFF1A202C))),
                Text(shift.startTimeFormatted,
                    style: const TextStyle(
                        fontSize: 10, color: Color(0xFF718096))),
              ],
            ),
          ),

          // Opened by
          Expanded(
            flex: 3,
            child: Text(shift.openedBy,
                style: TextStyle(
                    fontSize: (sw * 0.03).clamp(10, 12),
                    color: const Color(0xFF4A5568)),
                overflow: TextOverflow.ellipsis),
          ),

          // Status badge
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: shift.isClosed
                      ? const Color(0xFFE53E3E).withOpacity(0.08)
                      : const Color(0xFF00B5AD).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  shift.isClosed ? 'Closed' : 'Active',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: shift.isClosed
                          ? const Color(0xFFE53E3E)
                          : const Color(0xFF00B5AD)),
                ),
              ),
            ),
          ),
        ],
      ),
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
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;
    final dp = (sw * 0.06).clamp(16.0, 28.0);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(dp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: (sw * 0.15).clamp(48, 64),
              height: (sw * 0.15).clamp(48, 64),
              decoration: BoxDecoration(
                color: const Color(0xFFE53E3E).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.warning_amber_rounded,
                  color: const Color(0xFFE53E3E),
                  size: (sw * 0.08).clamp(24, 36)),
            ),
            SizedBox(height: sh * 0.02),
            Text('Close Shift?',
                style: TextStyle(
                    fontSize: (sw * 0.05).clamp(18, 24),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A202C))),
            SizedBox(height: sh * 0.01),
            Text(
              'This action will close the current shift and cannot be undone.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: (sw * 0.035).clamp(12, 14),
                  color: const Color(0xFF718096)),
            ),
            SizedBox(height: sh * 0.025),

            // Summary box
            Container(
              width: double.infinity,
              padding: EdgeInsets.all((sw * 0.035).clamp(10, 16)),
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
                      sw: sw),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(height: 1, color: Color(0xFFE2E8F0)),
                  ),
                  _SummaryRow(
                      label: 'Cash in Hand',
                      value: 'PKR ${cashInHand.toStringAsFixed(2)}',
                      valueColor: const Color(0xFF00B5AD),
                      sw: sw),
                ],
              ),
            ),
            SizedBox(height: sh * 0.03),

            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF718096),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding:
                    EdgeInsets.symmetric(vertical: sh * 0.015),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              SizedBox(width: sw * 0.03),
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
                    padding:
                    EdgeInsets.symmetric(vertical: sh * 0.015),
                  ),
                  child: const Text('Confirm Close',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ]),
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
  final double sw;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor = const Color(0xFF1A202C),
    required this.sw,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: (sw * 0.035).clamp(12, 14),
                color: const Color(0xFF718096))),
        Text(value,
            style: TextStyle(
                fontSize: (sw * 0.035).clamp(12, 14),
                fontWeight: FontWeight.bold,
                color: valueColor)),
      ],
    );
  }
}