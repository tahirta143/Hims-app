import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../core/utils/date_formatter.dart';
import '../../custum widgets/drawer/base_scaffold.dart';
import '../../global/global_api.dart';
import '../../providers/opd/opd_reciepts/opd_reciepts.dart';
import '../../providers/mr_provider/mr_provider.dart';
import '../../providers/shift_management/shift_management.dart';

// ─────────────────────────────────────────────────────────────────────────────
// THEME CONSTANTS
// ─────────────────────────────────────────────────────────────────────────────
const _teal = Color(0xFF00B5AD);
const _tealLight = Color(0xFFE6F7F6);
const _tealDark = Color(0xFF007A75);
const _bg = Color(0xFFF4F7FA);
const _card = Colors.white;
const _textDark = Color(0xFF1A202C);
const _textMid = Color(0xFF4A5568);
const _textLight = Color(0xFF718096);
const _border = Color(0xFFE2E8F0);
const _red = Color(0xFFE53E3E);
const _green = Color(0xFF38A169);

class OpdReceiptScreen extends StatefulWidget {
  const OpdReceiptScreen({super.key});

  @override
  State<OpdReceiptScreen> createState() => _OpdReceiptScreenState();
}

class _OpdReceiptScreenState extends State<OpdReceiptScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  // ── controllers ──
  final _mrNoCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _genderCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _discountCtrl = TextEditingController(text: '0');
  final _amountPaidCtrl = TextEditingController(text: '0');
  final _mrNoFocusNode = FocusNode();

  String? _selectedPanel;
  String? _selectedReference;
  bool _patientFound = false;
  bool _patientNotFound = false;
  bool _isSearching = false;

  // services state
  String _activeCat = 'opd';
  String _svcSearch = '';

  // Mobile step
  int _step = 0; // 0=patient, 1=services, 2=billing

  @override
  void initState() {
    super.initState();
    _mrNoFocusNode.addListener(() {
      if (!_mrNoFocusNode.hasFocus) {
        _padMr();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final opdProv = Provider.of<OpdProvider>(context, listen: false);
      _mrNoCtrl.text = opdProv.nextMrNo;
    });
  }

  void _padMr() {
    final raw = _mrNoCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (raw.isNotEmpty && raw.length < 5) {
      final padded = raw.padLeft(5, '0');
      _mrNoCtrl.text = padded;
      _onMrChanged(padded);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _mrNoCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _ageCtrl.dispose();
    _genderCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _discountCtrl.dispose();
    _amountPaidCtrl.dispose();
    _mrNoFocusNode.dispose();
    super.dispose();
  }

  void _onMrChanged(String val) async {
    final formatted = val.replaceAll(RegExp(r'[^0-9]'), '');

    if (formatted.isEmpty) {
      _clearPatient();
      return;
    }

    if (formatted.length >= 4) {
      setState(() {
        _isSearching = true;
        _patientFound = false;
        _patientNotFound = false;
      });

      final mrProv = Provider.of<MrProvider>(context, listen: false);
      final patient = await mrProv.findByMrNumber(formatted);

      setState(() {
        _isSearching = false;
      });

      if (patient != null) {
        setState(() {
          _patientFound = true;
          _patientNotFound = false;
          _nameCtrl.text = '${patient.firstName} ${patient.lastName}'.trim();
          _phoneCtrl.text = patient.phoneNumber;
          _ageCtrl.text = patient.age?.toString() ?? '';
          _genderCtrl.text = patient.gender;
          _addressCtrl.text = patient.address;
          _cityCtrl.text = patient.city;
        });
      } else {
        setState(() {
          _patientFound = false;
          _patientNotFound = true;
          _clearFields();
        });
      }
    } else {
      setState(() {
        _patientFound = false;
        _patientNotFound = false;
        _clearFields();
      });
    }
  }

  void _clearPatient() {
    setState(() {
      _patientFound = false;
      _patientNotFound = false;
      _isSearching = false;
    });
    _clearFields();
  }

  void _clearFields() {
    _nameCtrl.clear();
    _phoneCtrl.clear();
    _ageCtrl.clear();
    _genderCtrl.clear();
    _addressCtrl.clear();
    _cityCtrl.clear();
    _selectedPanel = null;
    _selectedReference = null;
  }

  void _clearAll() {
    final prov = Provider.of<OpdProvider>(context, listen: false);
    _clearPatient();
    _mrNoCtrl.text = prov.nextMrNo;
    _discountCtrl.text = '0';
    _amountPaidCtrl.text = '0';
    prov.clearServices();
    prov.emergencyAdmission = false;
    setState(() {
      _activeCat = 'opd';
      _svcSearch = '';
      _step = 0;
    });
  }

  double get _discountVal => double.tryParse(_discountCtrl.text) ?? 0;
  double get _amountPaidVal => double.tryParse(_amountPaidCtrl.text) ?? 0;

  void _onDiscountChanged() {
    final prov = Provider.of<OpdProvider>(context, listen: false);
    final total = prov.servicesTotal;
    final discount = _discountVal;
    final payable = (total - discount).clamp(0.0, double.infinity);
    _amountPaidCtrl.text = payable.toStringAsFixed(0);
    setState(() {});
  }

  void _saveAndExit() {
    final prov = Provider.of<OpdProvider>(context, listen: false);
    if (_nameCtrl.text.trim().isEmpty) {
      _snack('Please fill patient name', err: true);
      return;
    }
    if (prov.selectedServices.isEmpty) {
      _snack('Please select at least one service', err: true);
      return;
    }

    if (prov.emergencyAdmission && !prov.hasEmergencyService) {
      _snack('Please select an Emergency service to admit patient', err: true);
      return;
    }

    final patient = OpdPatient(
      mrNo: _mrNoCtrl.text,
      fullName: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      age: _ageCtrl.text.trim(),
      gender: _genderCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      panel: _selectedPanel ?? 'None',
      reference: _selectedReference ?? 'General Physician',
    );

    final shiftProv = Provider.of<ShiftProvider>(context, listen: false);

    prov
        .saveReceipt(
      patient: patient,
      services: prov.selectedServices.toList(),
      discount: _discountVal,
      amountPaid: _amountPaidVal,
      currentShift: shiftProv.shift,
    )
        .then((ok) {
      if (!ok) {
        _snack(
            prov.errorMessage ?? 'Failed to save OPD receipt. Please try again.',
            err: true);
        return;
      }
      
      // Success Dialog with Print Option
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(children: [
            Icon(Icons.check_circle_rounded, color: _green),
            SizedBox(width: 8),
            Text('Success'),
          ]),
          content: const Text('OPD Receipt has been saved successfully. Would you like to print it?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _clearAll();
              },
              child: Text('Don\'t Print', style: TextStyle(color: Colors.grey.shade600)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _printReceipt(prov, patient);
                _clearAll();
              },
              icon: const Icon(Icons.print_rounded, size: 18),
              label: const Text('Print Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _printReceipt(OpdProvider prov, OpdPatient patient) async {
    final pdf = pw.Document();
    final dateStr = AppDateFormatter.formatWithDay(DateTime.now());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text('HIMS - OPD RECEIPT',
                      style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                ),
                pw.SizedBox(height: 10),
                pw.Divider(),
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Date: $dateStr'),
                    pw.Text('MR #: ${patient.mrNo}'),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Text('Patient Details:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text('Name: ${patient.fullName}'),
                pw.Text('Phone: ${patient.phone}'),
                pw.Text('Age/Gender: ${patient.age} / ${patient.gender}'),
                pw.Text('City: ${patient.city}'),
                pw.SizedBox(height: 20),
                pw.Text('Services Requested:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Divider(),
                ...prov.selectedServices.map((s) => pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(s.service.name),
                    pw.Text('PKR ${s.service.price.toStringAsFixed(2)}'),
                  ],
                )),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('PKR ${prov.servicesTotal.toStringAsFixed(2)}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Discount:'),
                    pw.Text('PKR ${_discountVal.toStringAsFixed(2)}'),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Amount Paid:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text('PKR ${_amountPaidVal.toStringAsFixed(2)}',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  void _snack(String msg, {required bool err}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(err ? Icons.error_outline : Icons.check_circle,
            color: Colors.white, size: 16),
        const SizedBox(width: 8),
        Flexible(child: Text(msg, style: const TextStyle(fontSize: 12))),
      ]),
      backgroundColor: err ? _red : _teal,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 2),
    ));
  }

  // ════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 820;
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.viewInsets.bottom;

    return BaseScaffold(
      scaffoldKey: _scaffoldKey,
      title: 'OPD Receipt',
      drawerIndex: 3,
      showAppBar: false,
      body: isWide ? _buildWide() : _buildMobile(bottomPadding),
    );
  }

  // ════════════════════════════════════════════ WIDE LAYOUT ═══════════════════
  Widget _buildWide() {
    return Consumer2<OpdProvider, MrProvider>(
      builder: (_, opdProv, mrProv, __) => Column(children: [
        _buildWideHeader(),
        Expanded(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              flex: 63,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 8, 24),
                    sliver: SliverList(delegate: SliverChildListDelegate([
                      _patientCard(opdProv, mrProv),
                      const SizedBox(height: 16),
                      _servicesSection(opdProv),
                    ])),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.34,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(8, 16, 16, 24),
                    sliver: SliverList(delegate: SliverChildListDelegate([
                      _billingCard(opdProv),
                    ])),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  // ════════════════════════════════════════════ WIDE HEADER ═══════════════════
  Widget _buildWideHeader() {
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Container(
      color: _card,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        GestureDetector(
          onTap: () => _scaffoldKey.currentState?.openDrawer(),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _tealLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.menu_rounded, color: _teal, size: 20),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('OPD RECEIPT — COUNTER 01',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _textDark)),
            Text('New Patient Registration & Billing',
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _tealLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _teal.withOpacity(0.3)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.access_time_rounded, color: _teal, size: 14),
            const SizedBox(width: 4),
            Text(timeStr,
                style: TextStyle(
                    fontSize: 12,
                    color: _teal,
                    fontWeight: FontWeight.w600)),
          ]),
        ),
      ]),
    );
  }

  // ════════════════════════════════════════════ MOBILE LAYOUT ═════════════════
  Widget _buildMobile(double bottomPadding) {
    return Consumer2<OpdProvider, MrProvider>(
      builder: (_, opdProv, mrProv, __) => Column(
        children: [
          _buildMobileAppBar(),
          Expanded(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.only(bottom: bottomPadding + 20),
                child: Column(
                  children: [
                    _mobileHeader(opdProv, mrProv),
                    _stepContent(opdProv, mrProv),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Mobile App Bar with Status Bar Padding ────────────────────────────────
  Widget _buildMobileAppBar() {
    final mediaQuery = MediaQuery.of(context);

    return Container(
      padding: EdgeInsets.only(
        top: mediaQuery.padding.top + 8,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: _teal,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.menu_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'OPD Receipt',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.countertops_rounded, color: Colors.white, size: 14),
                SizedBox(width: 6),
                Text(
                  'Counter 01',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Mobile Header (MR Field Section) ─────────────────────────────────────
  Widget _mobileHeader(OpdProvider opdProv, MrProvider mrProv) {
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: _card,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Date/Time Row
        Row(
          children: [
            Icon(Icons.calendar_today_rounded, size: 12, color: _textLight),
            const SizedBox(width: 4),
            Text(
              '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}',
              style: TextStyle(fontSize: 11, color: _textLight),
            ),
            const SizedBox(width: 12),
            Icon(Icons.access_time_rounded, size: 12, color: _textLight),
            const SizedBox(width: 4),
            Text(
              timeStr,
              style: TextStyle(fontSize: 11, color: _textLight),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // MR Field
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: _patientFound ? _tealLight : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: _patientFound ? _teal : _border,
                width: _patientFound ? 1.5 : 1),
          ),
          child: Row(children: [
            const SizedBox(width: 12),
            Icon(Icons.badge_outlined,
                color: _patientFound ? _teal : _textLight,
                size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _mrNoCtrl,
                focusNode: _mrNoFocusNode,
                keyboardType: TextInputType.number,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _patientFound ? _tealDark : _textDark,
                    letterSpacing: 0.5),
                onChanged: _onMrChanged,
                onTap: () {
                  Future.delayed(const Duration(milliseconds: 300), () {
                    _scrollController.animateTo(
                      _scrollController.position.minScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  });
                },
                onFieldSubmitted: (val) {
                  _padMr();
                },
                decoration: InputDecoration(
                  hintText: 'MR Number — auto or search',
                  hintStyle: TextStyle(
                      color: _textLight.withOpacity(0.5),
                      fontSize: 13),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              ),
            ),
            _buildMrSuffix(),
          ]),
        ),

        // Status Chips
        if (_patientFound) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: _tealLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _teal.withOpacity(0.3))),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.check_circle_rounded, size: 12, color: _teal),
              SizedBox(width: 6),
              Text('Patient found — fields locked',
                  style: TextStyle(
                      fontSize: 11,
                      color: _teal,
                      fontWeight: FontWeight.w500)),
            ]),
          ),
        ] else if (_patientNotFound) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.withOpacity(0.3))),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.info_rounded, size: 12, color: Colors.orange),
              SizedBox(width: 6),
              Text('Not found — fill manually',
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.orange,
                      fontWeight: FontWeight.w500)),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _buildMrSuffix() {
    if (_isSearching) {
      return Container(
        width: 44,
        height: 50,
        alignment: Alignment.center,
        child: const SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: _teal)),
      );
    }
    return GestureDetector(
      onTap: _patientFound ? _clearAll : null,
      child: Container(
        width: 44,
        height: 50,
        decoration: BoxDecoration(
          color: _patientFound
              ? _teal.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: const BorderRadius.only(
              topRight: Radius.circular(11),
              bottomRight: Radius.circular(11)),
        ),
        child: Icon(
            _patientFound
                ? Icons.check_circle_rounded
                : Icons.search_rounded,
            color: _patientFound ? _teal : _textLight,
            size: 20),
      ),
    );
  }

  // ── Step Bar ─────────────────────────────────────────────────────────────
  Widget _stepBar() {
    const labels = ['Patient', 'Services', 'Billing'];
    return Container(
      color: _card,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        children: List.generate(labels.length, (i) {
          final active = i == _step;
          final done = i < _step;
          final isLast = i == labels.length - 1;
          return Expanded(
            child: Row(children: [
              if (i > 0)
                Expanded(
                    child: Container(
                        height: 2,
                        color: done ? _teal : _border.withOpacity(0.5))),
              GestureDetector(
                onTap: () => setState(() => _step = i),
                child: Column(children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                        color: active
                            ? _teal
                            : done
                            ? _tealLight
                            : const Color(0xFFF0F4F8),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: active || done ? _teal : _border,
                            width: 1.5)),
                    child: Center(
                      child: done
                          ? const Icon(Icons.check_rounded,
                          size: 14, color: _teal)
                          : Text('${i + 1}',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: active
                                  ? Colors.white
                                  : _textLight)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(labels[i],
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: active
                              ? FontWeight.w700
                              : FontWeight.normal,
                          color: active ? _teal : _textLight)),
                ]),
              ),
              if (!isLast)
                Expanded(
                    child: Container(
                        height: 2,
                        color: i < _step ? _teal : _border.withOpacity(0.5))),
            ]),
          );
        }),
      ),
    );
  }

  // ── Step Content ─────────────────────────────────────────────────────────
  Widget _stepContent(OpdProvider opdProv, MrProvider mrProv) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        children: [
          _stepPatientInfo(opdProv, mrProv),
          const SizedBox(height: 16),
          _stepServices(opdProv),
          const SizedBox(height: 16),
          _stepBilling(opdProv),
          const SizedBox(height: 24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  // ── Action Buttons ───────────────────────────────────────────────────────
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _clearAll,
            style: OutlinedButton.styleFrom(
              foregroundColor: _textLight,
              side: const BorderSide(color: _border),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh_rounded, size: 18),
                SizedBox(width: 8),
                Text('Clear', style: TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _saveAndExit,
            style: ElevatedButton.styleFrom(
              backgroundColor: _teal,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Save Receipt',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.save_rounded,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Step 0 – Patient Information
  Widget _stepPatientInfo(OpdProvider opdProv, MrProvider mrProv) {
    if (_patientFound) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stepTitle('Patient Selection', Icons.person_outline),
          const SizedBox(height: 16),
          _patientProfileCard(opdProv),
        ],
      );
    }

    if (!_patientNotFound) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle('Patient Information', Icons.person_outline),
        const SizedBox(height: 16),

        // Full Name & Phone
        Row(children: [
          Expanded(
            child: _field(
              ctrl: _nameCtrl,
              label: 'Full Name',
              required: true,
              icon: Icons.person_outline,
              readOnly: _patientFound,
              validator: (v) =>
              v == null || v.trim().isEmpty ? 'Required' : null,
              onTap: _scrollToTop,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _field(
              ctrl: _phoneCtrl,
              label: 'Phone',
              required: true,
              icon: Icons.phone_outlined,
              type: TextInputType.phone,
              readOnly: _patientFound,
              onTap: _scrollToTop,
            ),
          ),
        ]),
        const SizedBox(height: 12),

        // Age & Gender
        Row(children: [
          Expanded(
            child: _field(
              ctrl: _ageCtrl,
              label: 'Age',
              required: true,
              icon: Icons.numbers,
              type: TextInputType.number,
              readOnly: _patientFound,
              onTap: _scrollToTop,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _field(
              ctrl: _genderCtrl,
              label: 'Gender',
              required: true,
              icon: Icons.people_outline,
              readOnly: _patientFound,
              onTap: _scrollToTop,
            ),
          ),
        ]),
        const SizedBox(height: 12),

        // Address & City
        Row(children: [
          Expanded(
            flex: 2,
            child: _field(
              ctrl: _addressCtrl,
              label: 'Address',
              required: true,
              icon: Icons.location_on_outlined,
              readOnly: _patientFound,
              onTap: _scrollToTop,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _field(
              ctrl: _cityCtrl,
              label: 'City',
              icon: Icons.location_city_outlined,
              readOnly: _patientFound,
              onTap: _scrollToTop,
            ),
          ),
        ]),
        const SizedBox(height: 12),

        // Panel & Reference
        Row(children: [
          Expanded(
            child: _dropdown(
              label: 'Panel',
              value: _selectedPanel,
              items: opdProv.panels,
              hint: 'Select Panel',
              enabled: !_patientFound,
              onChanged: (v) => setState(() => _selectedPanel = v),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _dropdown(
              label: 'Reference',
              value: _selectedReference,
              items: opdProv.references,
              hint: 'General Physician',
              required: true,
              enabled: !_patientFound,
              onChanged: (v) => setState(() => _selectedReference = v),
            ),
          ),
        ]),
      ],
    );
  }

  Widget _patientProfileCard(OpdProvider prov) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _teal.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _teal.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _teal.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_rounded, color: _teal, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nameCtrl.text,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'MR#: ${_mrNoCtrl.text}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _teal,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_note_rounded, color: _teal),
                onPressed: () => setState(() => _patientFound = false),
                tooltip: 'Edit manually',
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              _profileItem(Icons.phone_iphone_rounded, 'Phone', _phoneCtrl.text),
              _profileItem(Icons.wc_rounded, 'Gender', _genderCtrl.text),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _profileItem(Icons.cake_rounded, 'Age', '${_ageCtrl.text} Years'),
              _profileItem(Icons.location_city_rounded, 'City', _cityCtrl.text),
            ],
          ),
          const SizedBox(height: 12),
          _profileItem(Icons.location_on_rounded, 'Address', _addressCtrl.text, isFull: true),
        ],
      ),
    );
  }

  Widget _profileItem(IconData icon, String label, String value, {bool isFull = false}) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: _textLight),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 11, color: _textLight)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value.isEmpty ? '-' : value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textDark),
        ),
      ],
    );

    if (isFull) return content;
    return Expanded(child: content);
  }


  void _scrollToTop() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  // Step 1 – Services
  Widget _stepServices(OpdProvider prov) {
    final List<Map<String, dynamic>> cats = prov.serviceCategories.isNotEmpty
        ? prov.serviceCategories
        : const [
      {'id': 'opd', 'label': 'OPD', 'icon': Icons.local_hospital_rounded, 'color': Color(0xFFE53935)},
      {'id': 'consultation', 'label': 'Consultation', 'icon': Icons.medical_information_rounded, 'color': Color(0xFF00B5AD)},
      {'id': 'xray', 'label': 'X-Ray', 'icon': Icons.radio_rounded, 'color': Color(0xFF1E88E5)},
      {'id': 'ctscan', 'label': 'CT-Scan', 'icon': Icons.document_scanner_rounded, 'color': Color(0xFF8E24AA)},
      {'id': 'mri', 'label': 'MRI', 'icon': Icons.blur_circular_rounded, 'color': Color(0xFF00ACC1)},
      {'id': 'ultrasound', 'label': 'Ultrasound', 'icon': Icons.sensors_rounded, 'color': Color(0xFF43A047)},
      {'id': 'laboratory', 'label': 'Laboratory', 'icon': Icons.biotech_rounded, 'color': Color(0xFFF4511E)},
      {'id': 'emergency', 'label': 'Emergency', 'icon': Icons.emergency_rounded, 'color': Color(0xFFE53935)},
    ];

    List<OpdService> categoryServices = [];
    if (prov.services.containsKey(_activeCat)) {
      categoryServices = prov.services[_activeCat] ?? [];
    } else if (cats.isNotEmpty) {
      _activeCat = cats.first['id'] as String;
      categoryServices = prov.services[_activeCat] ?? [];
    }

    final svcList = categoryServices.where((s) =>
    _svcSearch.isEmpty ||
        s.name.toLowerCase().contains(_svcSearch.toLowerCase())).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          _stepTitle('OPD Services', Icons.medical_services_rounded),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: prov.selectedServices.isEmpty
                  ? Colors.grey.shade200
                  : _tealLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('${prov.selectedServices.length} selected',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: prov.selectedServices.isEmpty
                        ? _textLight
                        : _teal)),
          ),
        ]),

        const SizedBox(height: 12),

        // Search field
        Container(
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _border),
          ),
          child: TextField(
            onChanged: (v) => setState(() => _svcSearch = v),
            style: const TextStyle(fontSize: 13),
            onTap: _scrollToTop,
            decoration: InputDecoration(
              hintText: 'Search services...',
              hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 12),
              prefixIcon: const Icon(Icons.search_rounded, size: 16, color: Color(0xFFBDBDBD)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Categories horizontal scroll
        SizedBox(
          height: 45,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemCount: cats.length,
            itemBuilder: (_, i) {
              final cat = cats[i];
              final id = cat['id'] as String;
              final isActive = id == _activeCat;
              final color = cat['color'] as Color;

              return GestureDetector(
                onTap: () => setState(() {
                  _activeCat = id;
                  _svcSearch = '';
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive ? color : _card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: isActive ? color : _border,
                        width: 1),
                  ),
                  child: Row(children: [
                    Icon(cat['icon'] as IconData,
                        color: isActive ? Colors.white : color,
                        size: 14),
                    const SizedBox(width: 4),
                    Text(cat['label'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isActive ? Colors.white : _textDark,
                        )),
                  ]),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // Services list
        if (svcList.isEmpty)
          Container(
            height: 150,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_rounded, color: Colors.grey.shade300, size: 40),
                const SizedBox(height: 8),
                Text('No services found',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemCount: svcList.length,
            itemBuilder: (_, i) => _mobileSvcTile(svcList[i], prov),
          ),

        const SizedBox(height: 12),

        // Emergency Admission Checkbox
        Consumer<OpdProvider>(builder: (_, p, __) {
          if (!p.hasEmergencyService) return const SizedBox.shrink();
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE53935).withOpacity(0.3)),
            ),
            child: Row(children: [
              Icon(Icons.emergency_rounded, color: const Color(0xFFE53935), size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Emergency Admission',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE53935))),
                      const Text('Admit to Emergency Ward',
                          style: TextStyle(fontSize: 10, color: Color(0xFFE53935))),
                    ]),
              ),
              Checkbox(
                value: p.emergencyAdmission,
                activeColor: const Color(0xFFE53935),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                onChanged: (val) => p.emergencyAdmission = val ?? false,
              ),
            ]),
          );
        }),
      ],
    );
  }

  Widget _mobileSvcTile(OpdService svc, OpdProvider prov) {
    final isSel = prov.isSelected(svc.id);
    return GestureDetector(
      onTap: () {
        if (isSel) {
          prov.removeService(svc.id);
        } else {
          prov.addService(svc);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSel ? svc.color.withOpacity(0.07) : _card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSel ? svc.color : _border,
              width: isSel ? 1.5 : 1),
        ),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: svc.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(svc.icon, color: svc.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(svc.name,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _textDark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text('PKR ${svc.price.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 12, color: _textLight)),
                ]),
          ),
          Icon(isSel ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
              color: isSel ? svc.color : Colors.grey.shade400,
              size: 26),
        ]),
      ),
    );
  }

  // Step 2 – Billing
  Widget _stepBilling(OpdProvider prov) {
    final discount = _discountVal;
    final totalPayable = (prov.servicesTotal - discount).clamp(0, double.infinity);
    final amountPaid = _amountPaidVal;
    final balance = amountPaid - totalPayable;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle('Billing Summary', Icons.receipt_long_rounded),
        const SizedBox(height: 16),

        // Services Total
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: [
            _billRow('Services Total', 'PKR ${prov.servicesTotal.toStringAsFixed(2)}'),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: Text('Discount',
                    style: const TextStyle(fontSize: 13, color: _textLight)),
              ),
              SizedBox(
                width: 130,
                child: TextField(
                  controller: _discountCtrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  onChanged: (_) => _onDiscountChanged(),
                  onTap: _scrollToTop,
                  decoration: InputDecoration(
                    prefixText: 'PKR ',
                    prefixStyle: const TextStyle(fontSize: 12, color: _textLight),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    isDense: true,
                  ),
                ),
              ),
            ]),
          ]),
        ),

        const SizedBox(height: 12),

        // Total Payable
        // Container(
        //   padding: const EdgeInsets.all(14),
        //   decoration: BoxDecoration(
        //     color: _tealLight,
        //     borderRadius: BorderRadius.circular(12),
        //   ),
        //   child: _billRow('Total Payable', 'PKR ${totalPayable.toStringAsFixed(2)}',
        //       bold: true, color: _teal),
        // ),

        // const SizedBox(height: 12),

        // Amount Paid
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(children: [
            const Text('Amount Paid',
                style: TextStyle(fontSize: 13, color: _textLight)),
            const Spacer(),
            SizedBox(
              width: 130,
              child: TextField(
                controller: _amountPaidCtrl,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                onChanged: (_) => setState(() {}),
                onTap: _scrollToTop,
                decoration: InputDecoration(
                  prefixText: 'PKR ',
                  prefixStyle: const TextStyle(fontSize: 12, color: _textLight),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  isDense: true,
                ),
              ),
            ),
          ]),
        ),

        const SizedBox(height: 10),

        // Balance
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: balance < 0 ? Colors.red.shade50 : _green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: balance < 0 ? Colors.red.shade200 : _green.withOpacity(0.3)),
          ),
          child: Row(children: [
            Icon(
                balance < 0 ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
                color: balance < 0 ? Colors.red : _green,
                size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Balance: PKR ${balance.abs().toStringAsFixed(2)}${balance < 0 ? ' (Due)' : ''}',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: balance < 0 ? Colors.red : _green),
              ),
            ),
          ]),
        ),

        const SizedBox(height: 16),

        // Selected Services Summary removed as per request

        // Emergency Admission indicator
        if (prov.emergencyAdmission) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE53935).withOpacity(0.3)),
            ),
            child: const Row(children: [
              Icon(Icons.emergency_rounded, color: Color(0xFFE53935), size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text('Will be admitted to Emergency Ward',
                    style: TextStyle(fontSize: 12, color: Color(0xFFE53935))),
              ),
            ]),
          ),
        ],
      ],
    );
  }

  // ── Helper Widgets ───────────────────────────────────────────────────────
  Widget _stepTitle(String title, IconData icon) {
    return Row(children: [
      Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
            color: _tealLight, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: _teal, size: 16),
      ),
      const SizedBox(width: 10),
      Text(title,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: _textDark)),
    ]);
  }

  Widget _field({
    required TextEditingController ctrl,
    required String label,
    IconData? icon,
    bool required = false,
    bool readOnly = false,
    TextInputType type = TextInputType.text,
    String? Function(String?)? validator,
    VoidCallback? onTap,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      RichText(
          text: TextSpan(
              text: label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _textMid),
              children: required
                  ? const [TextSpan(text: ' *', style: TextStyle(color: _red))]
                  : [])),
      const SizedBox(height: 6),
      TextFormField(
        controller: ctrl,
        readOnly: readOnly,
        keyboardType: type,
        validator: validator,
        onTap: onTap,
        style: TextStyle(
            fontSize: 14,
            color: readOnly ? _tealDark : _textDark,
            fontWeight: readOnly ? FontWeight.w600 : FontWeight.normal),
        decoration: InputDecoration(
          prefixIcon: icon != null
              ? Icon(icon, color: readOnly ? _teal : const Color(0xFFCBD5E0), size: 18)
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          isDense: true,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: readOnly ? _teal.withOpacity(0.3) : _border)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: readOnly ? _teal.withOpacity(0.3) : _border)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: readOnly ? _teal : _teal, width: 1.5)),
          filled: true,
          fillColor: readOnly ? _tealLight : Colors.white,
        ),
      ),
    ]);
  }

  Widget _dropdown({
    required String label,
    required String? value,
    required List<String> items,
    String hint = '',
    bool required = false,
    bool enabled = true,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      RichText(
          text: TextSpan(
              text: label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _textMid),
              children: required
                  ? const [TextSpan(text: ' *', style: TextStyle(color: _red))]
                  : [])),
      const SizedBox(height: 6),
      Container(
        decoration: BoxDecoration(
          color: enabled ? Colors.white : _tealLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: enabled ? _border : _teal.withOpacity(0.3)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            hint: Text(hint,
                style: const TextStyle(
                    color: Color(0xFFBDBDBD), fontSize: 13)),
            style: TextStyle(
                fontSize: 14,
                color: enabled ? _textDark : _tealDark,
                fontWeight: enabled ? FontWeight.normal : FontWeight.w600),
            icon: Icon(Icons.keyboard_arrow_down_rounded,
                color: enabled ? _textLight : _teal, size: 20),
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: enabled ? onChanged : null,
          ),
        ),
      ),
    ]);
  }

  Widget _billRow(String label, String value, {bool bold = false, Color? color}) {
    return Row(children: [
      Expanded(
        child: Text(label,
            style: TextStyle(
                fontSize: 13,
                color: bold ? _textDark : _textLight,
                fontWeight: bold ? FontWeight.w600 : FontWeight.normal)),
      ),
      Text(value,
          style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              color: color ?? _textDark)),
    ]);
  }

  // ════════════════════════════════════════════ WIDE COMPONENTS ═══════════════
  // ... (keep all your existing wide components - _patientCard, _servicesSection, _billingCard, etc.)
  // I'll keep them as they were in your original code

  Widget _patientCard(OpdProvider opdProv, MrProvider mrProv) {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: const Border(left: BorderSide(color: _teal, width: 4)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _tealLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.person_pin_rounded, color: _teal, size: 20),
          ),
          const SizedBox(width: 12),
          const Text('Patient Information',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _textDark)),
        ]),
        const SizedBox(height: 16),
        const Divider(height: 1, color: _border),
        const SizedBox(height: 16),

        // MR Field
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('MR No',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textLight)),
          const SizedBox(height: 4),
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: _patientFound ? _tealLight : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: _patientFound ? _teal : _border,
                  width: _patientFound ? 1.5 : 1),
            ),
            child: Row(children: [
              const SizedBox(width: 10),
              Icon(Icons.badge_outlined,
                  color: _patientFound ? _teal : _textLight,
                  size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _mrNoCtrl,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _patientFound ? _tealDark : _textDark),
                  onChanged: _onMrChanged,
                  decoration: InputDecoration(
                    hintText: 'MR Number — auto or search',
                    hintStyle: TextStyle(color: _textLight.withOpacity(0.5), fontSize: 13),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              _buildWideMrSuffix(),
            ]),
          ),
          if (_patientFound)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('Patient found — fields locked',
                  style: TextStyle(fontSize: 11, color: _teal)),
            )
          else if (_patientNotFound)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('Not found — fill manually',
                  style: TextStyle(fontSize: 11, color: Colors.orange)),
            ),
        ]),

        const SizedBox(height: 16),

        // Form fields
        Row(children: [
          Expanded(
            child: _wideField(
              ctrl: _nameCtrl,
              label: 'Full Name',
              required: true,
              readOnly: _patientFound,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _wideField(
              ctrl: _phoneCtrl,
              label: 'Phone',
              required: true,
              readOnly: _patientFound,
            ),
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: _wideField(
              ctrl: _ageCtrl,
              label: 'Age',
              required: true,
              readOnly: _patientFound,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _wideField(
              ctrl: _genderCtrl,
              label: 'Gender',
              required: true,
              readOnly: _patientFound,
            ),
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            flex: 2,
            child: _wideField(
              ctrl: _addressCtrl,
              label: 'Address',
              required: true,
              readOnly: _patientFound,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _wideField(
              ctrl: _cityCtrl,
              label: 'City',
              readOnly: _patientFound,
            ),
          ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: _wideDropdown(
              label: 'Panel',
              value: _selectedPanel,
              items: opdProv.panels,
              hint: 'Select Panel',
              enabled: !_patientFound,
              onChanged: (v) => setState(() => _selectedPanel = v),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _wideDropdown(
              label: 'Reference',
              value: _selectedReference,
              items: opdProv.references,
              hint: 'General Physician',
              required: true,
              enabled: !_patientFound,
              onChanged: (v) => setState(() => _selectedReference = v),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _buildWideMrSuffix() {
    if (_isSearching) {
      return Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        child: const SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: _teal)),
      );
    }
    return GestureDetector(
      onTap: _patientFound ? _clearAll : null,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: _patientFound ? _teal.withOpacity(0.12) : Colors.transparent,
          borderRadius: const BorderRadius.only(
              topRight: Radius.circular(9),
              bottomRight: Radius.circular(9)),
        ),
        child: Icon(
            _patientFound ? Icons.check_circle_rounded : Icons.search_rounded,
            color: _patientFound ? _teal : _textLight,
            size: 20),
      ),
    );
  }

  Widget _wideField({
    required TextEditingController ctrl,
    required String label,
    bool required = false,
    bool readOnly = false,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      RichText(
          text: TextSpan(
              text: label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _textLight),
              children: required
                  ? const [TextSpan(text: ' *', style: TextStyle(color: _red))]
                  : [])),
      const SizedBox(height: 4),
      TextFormField(
        controller: ctrl,
        readOnly: readOnly,
        style: TextStyle(
            fontSize: 13,
            color: readOnly ? _tealDark : _textDark,
            fontWeight: readOnly ? FontWeight.w600 : FontWeight.normal),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: readOnly ? _tealLight : Colors.white,
        ),
      ),
    ]);
  }

  Widget _wideDropdown({
    required String label,
    required String? value,
    required List<String> items,
    String hint = '',
    bool required = false,
    bool enabled = true,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      RichText(
          text: TextSpan(
              text: label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _textLight),
              children: required
                  ? const [TextSpan(text: ' *', style: TextStyle(color: _red))]
                  : [])),
      const SizedBox(height: 4),
      Container(
        decoration: BoxDecoration(
          color: enabled ? Colors.white : _tealLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: enabled ? _border : _teal.withOpacity(0.3)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            hint: Text(hint, style: const TextStyle(fontSize: 13, color: Color(0xFFBDBDBD))),
            style: TextStyle(
                fontSize: 13,
                color: enabled ? _textDark : _tealDark,
                fontWeight: enabled ? FontWeight.normal : FontWeight.w600),
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: enabled ? onChanged : null,
          ),
        ),
      ),
    ]);
  }

  Widget _servicesSection(OpdProvider prov) {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: const Border(left: BorderSide(color: _teal, width: 4)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _tealLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.medical_services_rounded, color: _teal, size: 20),
          ),
          const SizedBox(width: 12),
          const Text('OPD Services',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _textDark)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: prov.selectedServices.isEmpty ? Colors.grey.shade200 : _tealLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('${prov.selectedServices.length} selected',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: prov.selectedServices.isEmpty ? _textLight : _teal)),
          ),
        ]),
        const SizedBox(height: 16),
        const Divider(height: 1, color: _border),
        const SizedBox(height: 16),

        // Search field
        Container(
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _border),
          ),
          child: TextField(
            onChanged: (v) => setState(() => _svcSearch = v),
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search services...',
              prefixIcon: const Icon(Icons.search_rounded, size: 16, color: Color(0xFFBDBDBD)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Categories
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemCount: prov.serviceCategories.length,
            itemBuilder: (_, i) {
              final cat = prov.serviceCategories[i];
              final id = cat['id'] as String;
              final isActive = id == _activeCat;
              final color = cat['color'] as Color;

              return GestureDetector(
                onTap: () => setState(() {
                  _activeCat = id;
                  _svcSearch = '';
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive ? color : _card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isActive ? color : _border),
                  ),
                  child: Text(cat['label'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isActive ? Colors.white : _textDark,
                      )),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Services list
        ...prov.services[_activeCat]?.where((s) =>
        _svcSearch.isEmpty || s.name.toLowerCase().contains(_svcSearch.toLowerCase()))
            .map((s) => _wideSvcTile(s, prov)) ?? [],
      ]),
    );
  }

  Widget _wideSvcTile(OpdService svc, OpdProvider prov) {
    final isSel = prov.isSelected(svc.id);
    return GestureDetector(
      onTap: () {
        if (isSel) {
          prov.removeService(svc.id);
        } else {
          prov.addService(svc);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSel ? svc.color.withOpacity(0.07) : _card,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: isSel ? svc.color : _border,
              width: isSel ? 1.5 : 1),
        ),
        child: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: svc.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(svc.icon, color: svc.color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(svc.name,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _textDark)),
                  Text('PKR ${svc.price.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 11, color: _textLight)),
                ]),
          ),
          Icon(isSel ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
              color: isSel ? svc.color : Colors.grey.shade400,
              size: 22),
        ]),
      ),
    );
  }

  Widget _billingCard(OpdProvider prov) {
    final discount = _discountVal;
    final totalPayable = (prov.servicesTotal - discount).clamp(0.0, double.infinity);
    final amountPaid = _amountPaidVal;
    final balance = amountPaid - totalPayable;

    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: const Border(left: BorderSide(color: _teal, width: 4)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _tealLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.receipt_long_rounded, color: _teal, size: 20),
          ),
          const SizedBox(width: 12),
          const Text('Billing',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _textDark)),
        ]),
        const SizedBox(height: 16),
        const Divider(height: 1, color: _border),
        const SizedBox(height: 16),

        _billRow('Services Total', 'PKR ${prov.servicesTotal.toStringAsFixed(2)}'),
        const SizedBox(height: 8),
        Row(children: [
          const Text('Discount',
              style: TextStyle(fontSize: 13, color: _textLight)),
          const Spacer(),
          SizedBox(
            width: 100,
            child: TextField(
              controller: _discountCtrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              onChanged: (_) => _onDiscountChanged(),
              decoration: InputDecoration(
                prefixText: 'PKR ',
                prefixStyle: const TextStyle(fontSize: 12, color: _textLight),
                contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                isDense: true,
              ),
            ),
          ),
        ]),
        const Divider(height: 24, color: _border),
        _billRow('Total Payable', 'PKR ${totalPayable.toStringAsFixed(2)}',
            bold: true, color: _teal),
        const SizedBox(height: 8),
        Row(children: [
          const Text('Amount Paid',
              style: TextStyle(fontSize: 13, color: _textLight)),
          const Spacer(),
          SizedBox(
            width: 100,
            child: TextField(
              controller: _amountPaidCtrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                prefixText: 'PKR ',
                prefixStyle: const TextStyle(fontSize: 12, color: _textLight),
                contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                isDense: true,
              ),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.percent_rounded, color: Colors.orange, size: 16),
            const SizedBox(width: 8),
            const Text(
              'Refer to Discount',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _textDark,
              ),
            ),
            const Spacer(),
            Transform.scale(
              scale: 0.8,
              child: Switch(
                value: prov.isReferredToDiscount,
                onChanged: (val) => prov.setReferredToDiscount(val),
                activeColor: _teal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: balance < 0 ? Colors.red.shade50 : _green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: balance < 0 ? Colors.red.shade200 : _green.withOpacity(0.3)),
          ),
          child: Row(children: [
            Icon(
                balance < 0 ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
                color: balance < 0 ? Colors.red : _green,
                size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Balance: PKR ${balance.abs().toStringAsFixed(2)}${balance < 0 ? ' (Due)' : ''}',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: balance < 0 ? Colors.red : _green),
              ),
            ),
          ]),
        ),

        const SizedBox(height: 16),

        Row(children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _clearAll,
              style: OutlinedButton.styleFrom(
                foregroundColor: _textLight,
                side: const BorderSide(color: _border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Clear',
                  style: TextStyle(fontSize: 13)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _saveAndExit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _teal,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save_rounded, size: 16),
                  SizedBox(width: 6),
                  Text('Save Receipt',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ]),
      ]),
    );
  }
}