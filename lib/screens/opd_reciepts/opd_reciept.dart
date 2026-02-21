import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/opd/opd_reciepts/opd_reciepts.dart';
// import 'opd_provider.dart'; // adjust import path as needed

// ════════════════════════════════════════════════════════
//  OPD RECEIPT SCREEN
// ════════════════════════════════════════════════════════
class OpdReceiptScreen extends StatefulWidget {
  const OpdReceiptScreen({super.key});

  @override
  State<OpdReceiptScreen> createState() => _OpdReceiptScreenState();
}

class _OpdReceiptScreenState extends State<OpdReceiptScreen>
    with SingleTickerProviderStateMixin {
  static const Color primary = Color(0xFF00B5AD);
  static const Color bgColor = Color(0xFFF0F4F8);

  late TabController _tabController;

  // Patient form
  final _mrNoCtrl        = TextEditingController();
  final _nameCtrl        = TextEditingController();
  final _phoneCtrl       = TextEditingController();
  final _ageCtrl         = TextEditingController();
  final _genderCtrl      = TextEditingController();
  final _addressCtrl     = TextEditingController();
  final _cityCtrl        = TextEditingController();
  final _discountCtrl    = TextEditingController(text: '0');
  final _amountPaidCtrl  = TextEditingController(text: '0');

  String? _selectedPanel;
  String? _selectedReference;
  bool _patientFound = false;
  bool _patientNotFound = false;

  // Service section
  String _activeCategoryId = 'opd';
  String _serviceSearch = '';
  int _summaryTab = 0; // 0=Summary, 1=Selected Services

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Pre-fill next MR No on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = Provider.of<OpdProvider>(context, listen: false);
      _mrNoCtrl.text = prov.nextMrNo;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _mrNoCtrl.dispose(); _nameCtrl.dispose(); _phoneCtrl.dispose();
    _ageCtrl.dispose(); _genderCtrl.dispose(); _addressCtrl.dispose();
    _cityCtrl.dispose(); _discountCtrl.dispose(); _amountPaidCtrl.dispose();
    super.dispose();
  }

  // ── MR No lookup ──
  void _onMrNoChanged(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    final formatted = digits.isEmpty
        ? ''
        : int.parse(digits).toString().padLeft(6, '0');

    if (_mrNoCtrl.text != formatted) {
      _mrNoCtrl.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    if (formatted.isEmpty) {
      _clearPatient();
      return;
    }

    final prov = Provider.of<OpdProvider>(context, listen: false);
    final patient = prov.lookupPatient(formatted);
    if (patient != null) {
      setState(() {
        _patientFound    = true;
        _patientNotFound = false;
        _nameCtrl.text    = patient.fullName;
        _phoneCtrl.text   = patient.phone;
        _ageCtrl.text     = patient.age;
        _genderCtrl.text  = patient.gender;
        _addressCtrl.text = patient.address;
        _cityCtrl.text    = patient.city;
        _selectedPanel     = patient.panel == 'None' ? null : patient.panel;
        _selectedReference = patient.reference;
      });
    } else {
      setState(() {
        _patientFound    = false;
        _patientNotFound = formatted.length >= 3;
        if (!_patientNotFound) _clearPatientFields();
      });
    }
  }

  void _clearPatient() {
    setState(() { _patientFound = false; _patientNotFound = false; });
    _clearPatientFields();
  }

  void _clearPatientFields() {
    _nameCtrl.clear(); _phoneCtrl.clear(); _ageCtrl.clear();
    _genderCtrl.clear(); _addressCtrl.clear(); _cityCtrl.clear();
    _selectedPanel = null; _selectedReference = null;
  }

  void _clearAll() {
    final prov = Provider.of<OpdProvider>(context, listen: false);
    _clearPatient();
    _mrNoCtrl.text = prov.nextMrNo;
    _discountCtrl.text = '0';
    _amountPaidCtrl.text = '0';
    prov.clearServices();
    setState(() { _activeCategoryId = 'opd'; _serviceSearch = ''; });
  }

  // ── Summary helpers ──
  double get _discount => double.tryParse(_discountCtrl.text) ?? 0;
  double get _amountPaid => double.tryParse(_amountPaidCtrl.text) ?? 0;

  void _rebuild() => setState(() {});

  void _saveAndExit() {
    final prov = Provider.of<OpdProvider>(context, listen: false);
    if (_nameCtrl.text.trim().isEmpty) {
      _snack('Please fill patient name', isError: true);
      return;
    }
    if (prov.selectedServices.isEmpty) {
      _snack('Please select at least one service', isError: true);
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
    prov.saveReceipt(
      patient: patient,
      services: prov.selectedServices.toList(),
      discount: _discount,
      amountPaid: _amountPaid,
    );
    _snack('Receipt saved!', isError: false);
    _mrNoCtrl.text = prov.nextMrNo;
    _clearAll();
  }

  void _snack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red.shade400 : primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final mq  = MediaQuery.of(context);
    final sw  = mq.size.width;
    final sh  = mq.size.height;
    final tp  = mq.padding.top;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(children: [
        _Header(sw: sw, sh: sh, tp: tp, primary: primary),
        Expanded(
          child: Consumer<OpdProvider>(
            builder: (_, prov, __) => _isWide(sw)
                ? _WideLayout(
              sw: sw, sh: sh, primary: primary, prov: prov,
              state: this,
            )
                : _NarrowLayout(
              sw: sw, sh: sh, primary: primary, prov: prov,
              state: this,
            ),
          ),
        ),
      ]),
    );
  }

  bool _isWide(double sw) => sw > 720;
}

// ════════════════════════════════════════════════════════
//  HEADER
// ════════════════════════════════════════════════════════
class _Header extends StatelessWidget {
  final double sw, sh, tp;
  final Color primary;
  const _Header({required this.sw, required this.sh, required this.tp, required this.primary});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')} ${now.hour < 12 ? 'AM' : 'PM'}';
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    final dateStr = '${days[now.weekday-1]}, ${months[now.month-1]} ${now.day}, ${now.year}';

    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(top: tp + sh * 0.012, bottom: sh * 0.014,
          left: sw * 0.04, right: sw * 0.04),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.maybePop(context),
          child: Container(
            padding: EdgeInsets.all(sw * 0.02),
            decoration: BoxDecoration(
              color: const Color(0xFF00B5AD).withOpacity(0.1),
              borderRadius: BorderRadius.circular(sw * 0.02),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded,
                color: const Color(0xFF00B5AD), size: sw * 0.04),
          ),
        ),
        SizedBox(width: sw * 0.025),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('OPD RECEIPT — COUNTER 01',
                style: TextStyle(fontSize: sw * 0.038, fontWeight: FontWeight.bold,
                    color: Colors.black87, letterSpacing: 0.3)),
            Text('New Patient Registration & Billing',
                style: TextStyle(fontSize: sw * 0.028, color: Colors.grey.shade500)),
          ]),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: sw * 0.025, vertical: sh * 0.007),
          decoration: BoxDecoration(
            color: const Color(0xFF00B5AD).withOpacity(0.1),
            borderRadius: BorderRadius.circular(sw * 0.025),
            border: Border.all(color: const Color(0xFF00B5AD).withOpacity(0.3)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(dateStr, style: TextStyle(fontSize: sw * 0.026,
                color: const Color(0xFF00B5AD), fontWeight: FontWeight.w600)),
            Text(timeStr, style: TextStyle(fontSize: sw * 0.026,
                color: Colors.grey.shade600)),
          ]),
        ),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════
//  NARROW LAYOUT (Mobile) — TabBar for Patient / Services / Billing
// ════════════════════════════════════════════════════════
class _NarrowLayout extends StatefulWidget {
  final double sw, sh;
  final Color primary;
  final OpdProvider prov;
  final _OpdReceiptScreenState state;
  const _NarrowLayout({required this.sw, required this.sh, required this.primary,
    required this.prov, required this.state});

  @override
  State<_NarrowLayout> createState() => _NarrowLayoutState();
}

class _NarrowLayoutState extends State<_NarrowLayout>
    with SingleTickerProviderStateMixin {
  late TabController _tc;

  @override
  void initState() {
    super.initState();
    _tc = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() { _tc.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final sw = widget.sw; final sh = widget.sh;

    return Column(children: [
      // Tab bar
      Container(
        color: Colors.white,
        child: TabBar(
          controller: _tc,
          labelColor: widget.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: widget.primary,
          indicatorWeight: 3,
          labelStyle: TextStyle(fontSize: sw * 0.03, fontWeight: FontWeight.bold),
          tabs: [
            Tab(icon: Icon(Icons.person_rounded, size: sw * 0.045), text: 'Patient'),
            Tab(icon: Icon(Icons.medical_services_rounded, size: sw * 0.045), text: 'Services'),
            Tab(icon: Icon(Icons.receipt_long_rounded, size: sw * 0.045), text: 'Billing'),
          ],
        ),
      ),
      Expanded(
        child: TabBarView(
          controller: _tc,
          children: [
            // Tab 1: Patient
            SingleChildScrollView(
              padding: EdgeInsets.all(sw * 0.04),
              physics: const BouncingScrollPhysics(),
              child: _PatientForm(sw: sw, sh: sh, primary: widget.primary, state: s),
            ),
            // Tab 2: Services
            _ServicesTab(sw: sw, sh: sh, primary: widget.primary, prov: widget.prov, state: s),
            // Tab 3: Billing
            SingleChildScrollView(
              padding: EdgeInsets.all(sw * 0.04),
              physics: const BouncingScrollPhysics(),
              child: _BillingPanel(sw: sw, sh: sh, primary: widget.primary, prov: widget.prov, state: s),
            ),
          ],
        ),
      ),
    ]);
  }
}

// ════════════════════════════════════════════════════════
//  WIDE LAYOUT (Tablet/Desktop) — side-by-side
// ════════════════════════════════════════════════════════
class _WideLayout extends StatelessWidget {
  final double sw, sh;
  final Color primary;
  final OpdProvider prov;
  final _OpdReceiptScreenState state;
  const _WideLayout({required this.sw, required this.sh, required this.primary,
    required this.prov, required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Left: Patient + Services
      Expanded(
        flex: 60,
        child: Column(children: [
          Expanded(
            flex: 40,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(sw * 0.02),
              child: _PatientForm(sw: sw, sh: sh, primary: primary, state: state),
            ),
          ),
          Expanded(
            flex: 60,
            child: _ServicesTab(sw: sw, sh: sh, primary: primary, prov: prov, state: state),
          ),
        ]),
      ),
      // Right: Billing panel
      SizedBox(
        width: sw * 0.32,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(sw * 0.018),
          child: _BillingPanel(sw: sw, sh: sh, primary: primary, prov: prov, state: state),
        ),
      ),
    ]);
  }
}

// ════════════════════════════════════════════════════════
//  PATIENT FORM
// ════════════════════════════════════════════════════════
class _PatientForm extends StatelessWidget {
  final double sw, sh;
  final Color primary;
  final _OpdReceiptScreenState state;
  const _PatientForm({required this.sw, required this.sh, required this.primary, required this.state});

  @override
  Widget build(BuildContext context) {
    final s = state;
    final fs  = sw < 360 ? 11.0 : 13.0;
    final fsS = sw < 360 ? 10.0 : 11.5;

    return _Card(
      sw: sw,
      icon: Icons.person_pin_rounded,
      title: 'Patient Information',
      child: Column(children: [
        // MR No field
        _LabelField(
          label: 'MR No',
          required: true,
          fsS: fsS,
          sh: sh,
          child: TextField(
            controller: s._mrNoCtrl,
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: fs, fontWeight: FontWeight.bold, color: Colors.black87),
            decoration: _decor(sw, sh, 'e.g. 000001').copyWith(
              suffixIcon: s._patientFound
                  ? const Icon(Icons.check_circle_rounded, color: Colors.green, size: 18)
                  : s._patientNotFound
                  ? Icon(Icons.search_off_rounded, color: Colors.orange.shade400, size: 18)
                  : Icon(Icons.badge_rounded, color: Colors.grey.shade400, size: 18),
              filled: true,
              fillColor: s._patientFound ? Colors.green.withOpacity(0.04) : Colors.white,
            ),
            onChanged: s._onMrNoChanged,
          ),
        ),
        if (s._patientFound)
          _StatusChip(icon: Icons.check_circle_rounded, label: 'Patient found — fields auto-filled',
              color: Colors.green, sw: sw, sh: sh),
        if (s._patientNotFound)
          _StatusChip(icon: Icons.info_rounded, label: 'Not found — enter manually',
              color: Colors.orange, sw: sw, sh: sh),
        SizedBox(height: sh * 0.012),

        // Name + Phone
        Row(children: [
          Expanded(child: _LabelField(label: 'Full Name', required: true, fsS: fsS, sh: sh,
              child: _tf(sw, sh, s._nameCtrl, 'Enter Full Name', fs, s._patientFound))),
          SizedBox(width: sw * 0.025),
          Expanded(child: _LabelField(label: 'Phone', required: true, fsS: fsS, sh: sh,
              child: _tf(sw, sh, s._phoneCtrl, 'Enter Phone', fs, s._patientFound,
                  type: TextInputType.phone))),
        ]),
        SizedBox(height: sh * 0.012),

        // Age + Gender
        Row(children: [
          Expanded(child: _LabelField(label: 'Age', required: true, fsS: fsS, sh: sh,
              child: _tf(sw, sh, s._ageCtrl, 'Age', fs, s._patientFound,
                  type: TextInputType.number))),
          SizedBox(width: sw * 0.025),
          Expanded(child: _LabelField(label: 'Gender', required: true, fsS: fsS, sh: sh,
              child: _tf(sw, sh, s._genderCtrl, 'Male/Female', fs, s._patientFound))),
        ]),
        SizedBox(height: sh * 0.012),

        // Address + City
        Row(children: [
          Expanded(child: _LabelField(label: 'Address', required: true, fsS: fsS, sh: sh,
              child: _tf(sw, sh, s._addressCtrl, 'Address', fs, s._patientFound))),
          SizedBox(width: sw * 0.025),
          Expanded(child: _LabelField(label: 'City', fsS: fsS, sh: sh,
              child: _tf(sw, sh, s._cityCtrl, 'City', fs, s._patientFound))),
        ]),
        SizedBox(height: sh * 0.012),

        // Panel + Reference
        Consumer<OpdProvider>(builder: (_, prov, __) => Row(children: [
          Expanded(child: _LabelField(label: 'Panel', fsS: fsS, sh: sh,
              child: _DropdownField(
                sw: sw, sh: sh, fs: fs,
                value: s._selectedPanel,
                hint: 'Select Panel',
                items: prov.panels,
                onChanged: (v) { s._selectedPanel = v; s._rebuild(); },
              ))),
          SizedBox(width: sw * 0.025),
          Expanded(child: _LabelField(label: 'Reference', required: true, fsS: fsS, sh: sh,
              child: _DropdownField(
                sw: sw, sh: sh, fs: fs,
                value: s._selectedReference,
                hint: 'Select Reference',
                items: prov.references,
                onChanged: (v) { s._selectedReference = v; s._rebuild(); },
              ))),
        ])),
      ]),
    );
  }

  static Widget _tf(double sw, double sh, TextEditingController ctrl,
      String hint, double fs, bool found,
      {TextInputType type = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      style: TextStyle(fontSize: fs, color: Colors.black87),
      decoration: _decor(sw, sh, hint).copyWith(
        filled: true,
        fillColor: found ? Colors.green.withOpacity(0.04) : Colors.white,
      ),
    );
  }

  static InputDecoration _decor(double sw, double sh, String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: sw < 360 ? 11.0 : 13.0),
    filled: true, fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(horizontal: sw * 0.03, vertical: sh * 0.013),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(sw * 0.022),
        borderSide: BorderSide(color: Colors.grey.shade300)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(sw * 0.022),
        borderSide: BorderSide(color: Colors.grey.shade300)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(sw * 0.022),
        borderSide: const BorderSide(color: Color(0xFF00B5AD), width: 1.5)),
  );
}

// ════════════════════════════════════════════════════════
//  SERVICES TAB
// ════════════════════════════════════════════════════════
class _ServicesTab extends StatefulWidget {
  final double sw, sh;
  final Color primary;
  final OpdProvider prov;
  final _OpdReceiptScreenState state;
  const _ServicesTab({required this.sw, required this.sh, required this.primary,
    required this.prov, required this.state});

  @override
  State<_ServicesTab> createState() => _ServicesTabState();
}

class _ServicesTabState extends State<_ServicesTab> {
  String _activeCat = 'opd';
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final sw = widget.sw; final sh = widget.sh;
    final prov = widget.prov;
    final fs = sw < 360 ? 11.0 : 13.0;

    final cats = prov.serviceCategories;
    final allServicesInCat = prov.services[_activeCat] ?? [];
    final filtered = _search.isEmpty
        ? allServicesInCat
        : allServicesInCat.where((s) =>
        s.name.toLowerCase().contains(_search.toLowerCase())).toList();

    return Column(children: [
      // Header row
      Padding(
        padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sh * 0.012),
        child: Row(children: [
          Icon(Icons.medical_services_rounded, color: widget.primary, size: sw * 0.045),
          SizedBox(width: sw * 0.02),
          Text('OPD Services',
              style: TextStyle(fontSize: sw * 0.038, fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const Spacer(),
          Consumer<OpdProvider>(builder: (_, p, __) => Container(
            padding: EdgeInsets.symmetric(horizontal: sw * 0.025, vertical: sh * 0.005),
            decoration: BoxDecoration(
              color: p.selectedServices.isEmpty ? Colors.grey.shade200 : widget.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(sw * 0.05),
            ),
            child: Text('${p.selectedServices.length} selected',
                style: TextStyle(fontSize: sw * 0.028, fontWeight: FontWeight.w700,
                    color: p.selectedServices.isEmpty ? Colors.grey : widget.primary)),
          )),
        ]),
      ),

      // Search bar
      Padding(
        padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
        child: TextField(
          onChanged: (v) => setState(() => _search = v),
          style: TextStyle(fontSize: fs),
          decoration: InputDecoration(
            hintText: 'Search services by name or description...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: fs * 0.95),
            prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400, size: sw * 0.045),
            filled: true, fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: sw * 0.03, vertical: sh * 0.012),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(sw * 0.025),
                borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(sw * 0.025),
                borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(sw * 0.025),
                borderSide: BorderSide(color: widget.primary, width: 1.5)),
          ),
        ),
      ),
      SizedBox(height: sh * 0.012),

      // Category horizontal scroll
      SizedBox(
        height: sh * 0.115,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
          separatorBuilder: (_, __) => SizedBox(width: sw * 0.025),
          itemCount: cats.length,
          itemBuilder: (_, i) {
            final cat = cats[i];
            final id = cat['id'] as String;
            final isActive = id == _activeCat;
            final color = cat['color'] as Color;
            return GestureDetector(
              onTap: () => setState(() { _activeCat = id; _search = ''; }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: sw * 0.2,
                decoration: BoxDecoration(
                  color: isActive ? color : Colors.white,
                  borderRadius: BorderRadius.circular(sw * 0.03),
                  border: Border.all(color: isActive ? color : Colors.grey.shade200, width: 2),
                  boxShadow: isActive ? [BoxShadow(color: color.withOpacity(0.35),
                      blurRadius: 8, offset: const Offset(0, 3))] : null,
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(cat['icon'] as IconData,
                      color: isActive ? Colors.white : color, size: sw * 0.07),
                  SizedBox(height: sh * 0.005),
                  Text(cat['label'] as String,
                      style: TextStyle(fontSize: sw * 0.025, fontWeight: FontWeight.w700,
                          color: isActive ? Colors.white : Colors.black87),
                      textAlign: TextAlign.center),
                ]),
              ),
            );
          },
        ),
      ),
      SizedBox(height: sh * 0.01),

      // Services list + selected panel side by side
      Expanded(
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Service list
          Expanded(
            child: filtered.isEmpty
                ? Center(child: Text('No services found',
                style: TextStyle(color: Colors.grey.shade400, fontSize: fs)))
                : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sh * 0.005),
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final svc = filtered[i];
                final isSel = prov.isSelected(svc.id);
                return GestureDetector(
                  onTap: () {
                    if (isSel) prov.removeService(svc.id);
                    else prov.addService(svc);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: EdgeInsets.only(bottom: sh * 0.008),
                    padding: EdgeInsets.symmetric(
                        horizontal: sw * 0.035, vertical: sh * 0.012),
                    decoration: BoxDecoration(
                      color: isSel ? svc.color.withOpacity(0.08) : Colors.white,
                      borderRadius: BorderRadius.circular(sw * 0.025),
                      border: Border.all(
                        color: isSel ? svc.color : Colors.grey.shade200,
                        width: isSel ? 1.5 : 1,
                      ),
                    ),
                    child: Row(children: [
                      Container(
                        padding: EdgeInsets.all(sw * 0.018),
                        decoration: BoxDecoration(
                          color: svc.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(sw * 0.02),
                        ),
                        child: Icon(svc.icon, color: svc.color, size: sw * 0.045),
                      ),
                      SizedBox(width: sw * 0.025),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(svc.name, style: TextStyle(fontSize: fs,
                              fontWeight: FontWeight.w600, color: Colors.black87)),
                          Text('PKR ${svc.price.toStringAsFixed(0)}',
                              style: TextStyle(fontSize: sw * 0.028,
                                  color: Colors.grey.shade500)),
                        ],
                      )),
                      Icon(isSel ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                          color: isSel ? svc.color : Colors.grey.shade400,
                          size: sw * 0.055),
                    ]),
                  ),
                );
              },
            ),
          ),

          // Selected services mini panel
          Consumer<OpdProvider>(builder: (_, p, __) {
            if (p.selectedServices.isEmpty) return const SizedBox.shrink();
            return Container(
              width: sw * 0.38,
              margin: EdgeInsets.only(right: sw * 0.03, bottom: sh * 0.01),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(sw * 0.03),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: sw * 0.03, vertical: sh * 0.01),
                  decoration: BoxDecoration(
                    color: widget.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(sw * 0.03),
                      topRight: Radius.circular(sw * 0.03),
                    ),
                  ),
                  child: Row(children: [
                    Icon(Icons.check_circle_rounded, color: widget.primary, size: sw * 0.035),
                    SizedBox(width: sw * 0.01),
                    Text('Selected', style: TextStyle(fontSize: sw * 0.028,
                        fontWeight: FontWeight.bold, color: widget.primary)),
                  ]),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(sw * 0.02),
                    itemCount: p.selectedServices.length,
                    itemBuilder: (_, i) {
                      final sel = p.selectedServices[i];
                      return Container(
                        margin: EdgeInsets.only(bottom: sh * 0.007),
                        padding: EdgeInsets.symmetric(
                            horizontal: sw * 0.025, vertical: sh * 0.008),
                        decoration: BoxDecoration(
                          color: sel.service.color.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(sw * 0.02),
                        ),
                        child: Row(children: [
                          Icon(sel.service.icon, color: sel.service.color, size: sw * 0.035),
                          SizedBox(width: sw * 0.015),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(sel.service.name,
                                  style: TextStyle(fontSize: sw * 0.026,
                                      fontWeight: FontWeight.w600, color: Colors.black87),
                                  maxLines: 2, overflow: TextOverflow.ellipsis),
                              Text('PKR ${sel.service.price.toStringAsFixed(0)}',
                                  style: TextStyle(fontSize: sw * 0.024,
                                      color: Colors.grey.shade500)),
                            ],
                          )),
                          GestureDetector(
                            onTap: () => p.removeService(sel.service.id),
                            child: Icon(Icons.close_rounded,
                                color: Colors.red.shade300, size: sw * 0.038),
                          ),
                        ]),
                      );
                    },
                  ),
                ),
              ]),
            );
          }),
        ]),
      ),
    ]);
  }
}

// ════════════════════════════════════════════════════════
//  BILLING PANEL
// ════════════════════════════════════════════════════════
class _BillingPanel extends StatefulWidget {
  final double sw, sh;
  final Color primary;
  final OpdProvider prov;
  final _OpdReceiptScreenState state;
  const _BillingPanel({required this.sw, required this.sh, required this.primary,
    required this.prov, required this.state});

  @override
  State<_BillingPanel> createState() => _BillingPanelState();
}

class _BillingPanelState extends State<_BillingPanel> {
  int _subTab = 0; // 0=Summary, 1=Selected

  @override
  Widget build(BuildContext context) {
    final sw = widget.sw; final sh = widget.sh;
    final prov = widget.prov;
    final s = widget.state;
    final fs = sw < 360 ? 11.0 : 13.0;

    final discount   = double.tryParse(s._discountCtrl.text) ?? 0;
    final totalPayable = (prov.servicesTotal - discount).clamp(0, double.infinity);
    final amountPaid = double.tryParse(s._amountPaidCtrl.text) ?? 0;
    final balance    = amountPaid - totalPayable;

    return Column(children: [
      // Sub-tabs: Summary | Selected Services
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(sw * 0.03),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
              blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(children: [
          Expanded(child: GestureDetector(
            onTap: () => setState(() => _subTab = 0),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: sh * 0.013),
              decoration: BoxDecoration(
                color: _subTab == 0 ? widget.primary : Colors.transparent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(sw * 0.03),
                  bottomLeft: Radius.circular(sw * 0.03),
                ),
              ),
              child: Center(child: Text('Summary',
                  style: TextStyle(fontSize: fs * 0.95, fontWeight: FontWeight.w600,
                      color: _subTab == 0 ? Colors.white : Colors.grey.shade600))),
            ),
          )),
          Expanded(child: GestureDetector(
            onTap: () => setState(() => _subTab = 1),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: sh * 0.013),
              decoration: BoxDecoration(
                color: _subTab == 1 ? widget.primary : Colors.transparent,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(sw * 0.03),
                  bottomRight: Radius.circular(sw * 0.03),
                ),
              ),
              child: Center(child: Text('Selected Services',
                  style: TextStyle(fontSize: fs * 0.95, fontWeight: FontWeight.w600,
                      color: _subTab == 1 ? Colors.white : Colors.grey.shade600))),
            ),
          )),
        ]),
      ),
      SizedBox(height: sh * 0.015),

      if (_subTab == 0) ...[
        // Summary section
        _Card(sw: sw, icon: Icons.receipt_long_rounded, title: 'Billing Summary', child: Column(children: [
          _BillRow(label: 'Services Total', value: 'PKR ${prov.servicesTotal.toStringAsFixed(2)}',
              sw: sw, sh: sh, fs: fs),
          SizedBox(height: sh * 0.012),
          // Discount input
          Row(children: [
            Expanded(child: Text('Discount', style: TextStyle(fontSize: fs, color: Colors.black54))),
            SizedBox(
              width: sw * 0.35,
              child: TextField(
                controller: s._discountCtrl,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: fs, fontWeight: FontWeight.w600),
                onChanged: (_) => setState((){}),
                decoration: InputDecoration(
                  prefixText: 'PKR ',
                  prefixStyle: TextStyle(fontSize: fs, color: Colors.grey.shade500),
                  contentPadding: EdgeInsets.symmetric(horizontal: sw * 0.025, vertical: sh * 0.009),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(sw * 0.02),
                      borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(sw * 0.02),
                      borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(sw * 0.02),
                      borderSide: BorderSide(color: widget.primary, width: 1.5)),
                ),
              ),
            ),
          ]),
          Divider(height: sh * 0.03, color: Colors.grey.shade200),
          _BillRow(label: 'Total Payable', value: 'PKR ${totalPayable.toStringAsFixed(2)}',
              sw: sw, sh: sh, fs: fs, bold: true, valueColor: widget.primary),
          SizedBox(height: sh * 0.012),
          // Amount Paid input
          Row(children: [
            Expanded(child: Text('Amount Paid', style: TextStyle(fontSize: fs, color: Colors.black54))),
            SizedBox(
              width: sw * 0.35,
              child: TextField(
                controller: s._amountPaidCtrl,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: fs, fontWeight: FontWeight.w600),
                onChanged: (_) => setState((){}),
                decoration: InputDecoration(
                  prefixText: 'PKR ',
                  prefixStyle: TextStyle(fontSize: fs, color: Colors.grey.shade500),
                  contentPadding: EdgeInsets.symmetric(horizontal: sw * 0.025, vertical: sh * 0.009),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(sw * 0.02),
                      borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(sw * 0.02),
                      borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(sw * 0.02),
                      borderSide: BorderSide(color: widget.primary, width: 1.5)),
                ),
              ),
            ),
          ]),
          SizedBox(height: sh * 0.01),
          _BillRow(
            label: 'Balance',
            value: 'PKR ${balance.abs().toStringAsFixed(2)}${balance < 0 ? ' (Due)' : ''}',
            sw: sw, sh: sh, fs: fs, bold: true,
            valueColor: balance < 0 ? Colors.red : Colors.green,
          ),
        ])),
        SizedBox(height: sh * 0.018),

        // Action buttons
        Row(children: [
          Expanded(child: OutlinedButton.icon(
            onPressed: s._clearAll,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade600,
              side: BorderSide(color: Colors.grey.shade300),
              padding: EdgeInsets.symmetric(vertical: sh * 0.015),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(sw * 0.025)),
            ),
            icon: Icon(Icons.close_rounded, size: sw * 0.04),
            label: Text('Clear', style: TextStyle(fontSize: fs, fontWeight: FontWeight.w600)),
          )),
          SizedBox(width: sw * 0.025),
          Expanded(flex: 2, child: ElevatedButton.icon(
            onPressed: s._saveAndExit,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: sh * 0.015),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(sw * 0.025)),
            ),
            icon: Icon(Icons.print_rounded, size: sw * 0.04),
            label: Text('Print Receipt', style: TextStyle(fontSize: fs, fontWeight: FontWeight.bold)),
          )),
        ]),
      ] else ...[
        // Selected Services list
        if (prov.selectedServices.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: sh * 0.06),
            child: Column(children: [
              Icon(Icons.inbox_rounded, color: Colors.grey.shade300, size: sw * 0.15),
              SizedBox(height: sh * 0.01),
              Text('No services selected', style: TextStyle(color: Colors.grey.shade400, fontSize: fs)),
            ]),
          )
        else
          ...prov.selectedServices.map((sel) => Container(
            margin: EdgeInsets.only(bottom: sh * 0.01),
            padding: EdgeInsets.all(sw * 0.035),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(sw * 0.025),
              border: Border.all(color: sel.service.color.withOpacity(0.3)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03),
                  blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Row(children: [
              Container(
                padding: EdgeInsets.all(sw * 0.02),
                decoration: BoxDecoration(
                  color: sel.service.color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(sel.service.icon, color: sel.service.color, size: sw * 0.05),
              ),
              SizedBox(width: sw * 0.025),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(sel.service.name,
                    style: TextStyle(fontSize: fs, fontWeight: FontWeight.w600,
                        color: Colors.black87)),
                Text('PKR ${sel.service.price.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: sw * 0.028, color: Colors.grey.shade500)),
              ])),
              GestureDetector(
                onTap: () => prov.removeService(sel.service.id),
                child: Container(
                  padding: EdgeInsets.all(sw * 0.015),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(sw * 0.02),
                  ),
                  child: Icon(Icons.delete_outline_rounded,
                      color: Colors.red.shade400, size: sw * 0.04),
                ),
              ),
            ]),
          )).toList(),
      ],
    ]);
  }
}

// ════════════════════════════════════════════════════════
//  SHARED SMALL WIDGETS
// ════════════════════════════════════════════════════════

class _Card extends StatelessWidget {
  final double sw;
  final IconData icon;
  final String title;
  final Widget child;
  const _Card({required this.sw, required this.icon, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(sw * 0.04),
        border: const Border(left: BorderSide(color: Color(0xFF00B5AD), width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
            blurRadius: 10, offset: const Offset(0, 3))],
      ),
      padding: EdgeInsets.all(sw * 0.04),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: EdgeInsets.all(sw * 0.02),
            decoration: BoxDecoration(
              color: const Color(0xFF00B5AD).withOpacity(0.1),
              borderRadius: BorderRadius.circular(sw * 0.02),
            ),
            child: Icon(icon, color: const Color(0xFF00B5AD), size: sw * 0.045),
          ),
          SizedBox(width: sw * 0.02),
          Text(title, style: TextStyle(fontSize: sw * 0.038,
              fontWeight: FontWeight.bold, color: Colors.black87)),
        ]),
        SizedBox(height: sw * 0.035),
        const Divider(height: 1),
        SizedBox(height: sw * 0.035),
        child,
      ]),
    );
  }
}

class _LabelField extends StatelessWidget {
  final String label;
  final bool required;
  final double fsS, sh;
  final Widget child;
  const _LabelField({required this.label, this.required = false,
    required this.fsS, required this.sh, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      RichText(text: TextSpan(
        text: label,
        style: TextStyle(fontSize: fsS, fontWeight: FontWeight.w600, color: Colors.black54),
        children: required ? [TextSpan(text: ' *', style: TextStyle(color: Colors.red, fontSize: fsS))] : [],
      )),
      SizedBox(height: sh * 0.005),
      child,
    ]);
  }
}

class _DropdownField extends StatelessWidget {
  final double sw, sh, fs;
  final String? value;
  final String hint;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _DropdownField({required this.sw, required this.sh, required this.fs,
    required this.value, required this.hint, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.025),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(sw * 0.022),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(hint, style: TextStyle(color: Colors.grey.shade400, fontSize: fs)),
          style: TextStyle(fontSize: fs, color: Colors.black87),
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey, size: sw * 0.045),
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final double sw, sh;
  const _StatusChip({required this.icon, required this.label,
    required this.color, required this.sw, required this.sh});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: sh * 0.005),
      child: Row(children: [
        Icon(icon, color: color, size: 13),
        SizedBox(width: sw * 0.01),
        Text(label, style: TextStyle(fontSize: sw < 360 ? 10.0 : 11.5,
            color: color, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _BillRow extends StatelessWidget {
  final String label, value;
  final double sw, sh, fs;
  final bool bold;
  final Color? valueColor;
  const _BillRow({required this.label, required this.value, required this.sw,
    required this.sh, required this.fs, this.bold = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Text(label, style: TextStyle(fontSize: fs,
          color: bold ? Colors.black87 : Colors.black54,
          fontWeight: bold ? FontWeight.w700 : FontWeight.normal))),
      Text(value, style: TextStyle(fontSize: fs,
          fontWeight: bold ? FontWeight.bold : FontWeight.w500,
          color: valueColor ?? Colors.black87)),
    ]);
  }
}

// ════════════════════════════════════════════════════════
//  STUB CLASSES (copy from your opd_provider.dart)
//  Remove these if you import the actual provider file
// ════════════════════════════════════════════════════════
// (All provider classes are in opd_provider.dart)