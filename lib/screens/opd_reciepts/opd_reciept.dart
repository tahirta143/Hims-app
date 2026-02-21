import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/opd/opd_reciepts/opd_reciepts.dart';

class OpdReceiptScreen extends StatefulWidget {
  const OpdReceiptScreen({super.key});

  @override
  State<OpdReceiptScreen> createState() => _OpdReceiptScreenState();
}

class _OpdReceiptScreenState extends State<OpdReceiptScreen> {
  static const Color primary = Color(0xFF00B5AD);
  static const Color bgColor = Color(0xFFF0F4F8);
  static const Color cardBg  = Colors.white;

  // ── controllers ──
  final _mrNoCtrl       = TextEditingController();
  final _nameCtrl       = TextEditingController();
  final _phoneCtrl      = TextEditingController();
  final _ageCtrl        = TextEditingController();
  final _genderCtrl     = TextEditingController();
  final _addressCtrl    = TextEditingController();
  final _cityCtrl       = TextEditingController();
  final _discountCtrl   = TextEditingController(text: '0');
  final _amountPaidCtrl = TextEditingController(text: '0');

  String? _selectedPanel;
  String? _selectedReference;
  bool _patientFound    = false;
  bool _patientNotFound = false;

  // services state
  String _activeCat  = 'opd';
  String _svcSearch  = '';
  int    _billingTab = 0; // 0=Summary 1=Selected Services

  // MediaQuery values — set every build
  late double _sw, _sh, _tp, _bp;
  late bool   _isWide;    // >= 720
  late bool   _isMedium;  // >= 480

  double get _fs  => _sw < 360 ? 11.5 : 13.0;
  double get _fsS => _sw < 360 ? 10.0 : 11.5;
  double get _fsL => _sw < 360 ? 13.5 : 15.5;
  double get _pad => _sw * 0.04;
  double get _sp  => _sw * 0.025;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = Provider.of<OpdProvider>(context, listen: false);
      _mrNoCtrl.text = prov.nextMrNo;
    });
  }

  @override
  void dispose() {
    _mrNoCtrl.dispose(); _nameCtrl.dispose(); _phoneCtrl.dispose();
    _ageCtrl.dispose();  _genderCtrl.dispose(); _addressCtrl.dispose();
    _cityCtrl.dispose(); _discountCtrl.dispose(); _amountPaidCtrl.dispose();
    super.dispose();
  }

  // ─── MR lookup ───
  void _onMrChanged(String raw) {
    final digits    = raw.replaceAll(RegExp(r'[^0-9]'), '');
    final formatted = digits.isEmpty ? '' : int.parse(digits).toString().padLeft(6, '0');
    if (_mrNoCtrl.text != formatted) {
      _mrNoCtrl.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    if (formatted.isEmpty) { _clearPatient(); return; }
    final prov    = Provider.of<OpdProvider>(context, listen: false);
    final patient = prov.lookupPatient(formatted);
    if (patient != null) {
      setState(() {
        _patientFound = true; _patientNotFound = false;
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
        if (!_patientNotFound) _clearFields();
      });
    }
  }

  void _clearPatient() {
    setState(() { _patientFound = false; _patientNotFound = false; });
    _clearFields();
  }

  void _clearFields() {
    _nameCtrl.clear(); _phoneCtrl.clear(); _ageCtrl.clear();
    _genderCtrl.clear(); _addressCtrl.clear(); _cityCtrl.clear();
    _selectedPanel = null; _selectedReference = null;
  }

  void _clearAll() {
    final prov = Provider.of<OpdProvider>(context, listen: false);
    _clearPatient();
    _mrNoCtrl.text       = prov.nextMrNo;
    _discountCtrl.text   = '0';
    _amountPaidCtrl.text = '0';
    prov.clearServices();
    setState(() { _activeCat = 'opd'; _svcSearch = ''; _billingTab = 0; });
  }

  double get _discountVal   => double.tryParse(_discountCtrl.text)   ?? 0;
  double get _amountPaidVal => double.tryParse(_amountPaidCtrl.text) ?? 0;

  void _saveAndExit() {
    final prov = Provider.of<OpdProvider>(context, listen: false);
    if (_nameCtrl.text.trim().isEmpty) { _snack('Please fill patient name',           err: true); return; }
    if (prov.selectedServices.isEmpty) { _snack('Please select at least one service', err: true); return; }
    final patient = OpdPatient(
      mrNo: _mrNoCtrl.text, fullName: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(), age: _ageCtrl.text.trim(),
      gender: _genderCtrl.text.trim(), address: _addressCtrl.text.trim(),
      city: _cityCtrl.text.trim(), panel: _selectedPanel ?? 'None',
      reference: _selectedReference ?? 'General Physician',
    );
    prov.saveReceipt(patient: patient, services: prov.selectedServices.toList(),
        discount: _discountVal, amountPaid: _amountPaidVal);
    _snack('Receipt saved!', err: false);
    _clearAll();
  }

  void _snack(String msg, {required bool err}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: err ? Colors.red.shade400 : primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.all(_pad),
    ));
  }

  // ════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    _sw = mq.size.width;
    _sh = mq.size.height;
    _tp = mq.padding.top;
    _bp = mq.padding.bottom;
    _isWide   = _sw >= 720;
    _isMedium = _sw >= 480;

    return Scaffold(
      backgroundColor: bgColor,
      body: Consumer<OpdProvider>(
        builder: (_, prov, __) => Column(children: [
          _buildHeader(),
          Expanded(
            child: _isWide ? _wideBody(prov) : _narrowBody(prov),
          ),
        ]),
      ),
    );
  }

  // ════════════════════════════════════════════
  //  HEADER
  // ════════════════════════════════════════════
  Widget _buildHeader() {
    final now = DateTime.now();
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    const wdays  = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    final h       = now.hour;
    final timeStr = '${h.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')} ${h < 12 ? 'AM' : 'PM'}';
    final dateStr = '${wdays[now.weekday-1]}, ${months[now.month-1]} ${now.day}, ${now.year}';

    return Container(
      color: cardBg,
      padding: EdgeInsets.only(
        top: _tp + _sh * 0.012, bottom: _sh * 0.014, left: _pad, right: _pad,
      ),
      child: Row(children: [
        // Back
        GestureDetector(
          onTap: () => Navigator.maybePop(context),
          child: Container(
            padding: EdgeInsets.all(_sw * 0.022),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(_sw * 0.022),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded, color: primary, size: _sw * 0.04),
          ),
        ),
        SizedBox(width: _sp),
        // Title
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('OPD RECEIPT — COUNTER 01',
              style: TextStyle(fontSize: _fsL, fontWeight: FontWeight.bold,
                  color: Colors.black87, letterSpacing: 0.2),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          Text('New Patient Registration & Billing',
              style: TextStyle(fontSize: _fsS, color: Colors.grey.shade500)),
        ])),
        // MR Data pill
        Container(
          margin: EdgeInsets.only(right: _sw * 0.02),
          padding: EdgeInsets.symmetric(horizontal: _sw * 0.022, vertical: _sh * 0.006),
          decoration: BoxDecoration(
            color: primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(_sw * 0.025),
            border: Border.all(color: primary.withOpacity(0.3)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.manage_accounts_rounded, color: primary, size: _sw * 0.036),
            SizedBox(width: _sw * 0.01),
            Text('MR Data',
                style: TextStyle(fontSize: _fsS, color: primary, fontWeight: FontWeight.w700)),
          ]),
        ),
        // Date pill
        Container(
          padding: EdgeInsets.symmetric(horizontal: _sw * 0.022, vertical: _sh * 0.007),
          decoration: BoxDecoration(
            color: primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(_sw * 0.025),
            border: Border.all(color: primary.withOpacity(0.25)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.calendar_today_rounded, color: primary, size: _sw * 0.033),
            SizedBox(width: _sw * 0.012),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(dateStr,
                  style: TextStyle(fontSize: _fsS, color: primary, fontWeight: FontWeight.w600)),
              Text(timeStr,
                  style: TextStyle(fontSize: _fsS * 0.88, color: Colors.grey.shade600)),
            ]),
          ]),
        ),
      ]),
    );
  }

  // ════════════════════════════════════════════
  //  WIDE BODY  (>= 720px) — 2 columns
  // ════════════════════════════════════════════
  Widget _wideBody(OpdProvider prov) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Left: Patient + Services
      Expanded(
        flex: 63,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(_pad, _pad, _pad * 0.5, _pad + _bp),
              sliver: SliverList(delegate: SliverChildListDelegate([
                _patientCard(prov),
                SizedBox(height: _pad),
                _servicesSection(prov),
              ])),
            ),
          ],
        ),
      ),
      // Right: Billing panel
      SizedBox(
        width: _sw * 0.34,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(_pad * 0.5, _pad, _pad, _pad + _bp),
              sliver: SliverList(delegate: SliverChildListDelegate([
                _billingCard(prov),
              ])),
            ),
          ],
        ),
      ),
    ]);
  }

  // ════════════════════════════════════════════
  //  NARROW BODY  (< 720px) — single column scroll
  // ════════════════════════════════════════════
  Widget _narrowBody(OpdProvider prov) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(_pad, _pad, _pad, _pad + _bp),
          sliver: SliverList(delegate: SliverChildListDelegate([
            _patientCard(prov),
            SizedBox(height: _pad),
            _servicesSection(prov),
            SizedBox(height: _pad),
            _billingCard(prov),
          ])),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════
  //  PATIENT CARD
  // ════════════════════════════════════════════
  Widget _patientCard(OpdProvider prov) {
    return _SectionCard(
      sw: _sw, icon: Icons.person_pin_rounded, title: 'Patient Information',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // MR No — full width
        _FieldLabel(label: 'MR No', req: true, fsS: _fsS, sh: _sh,
          child: TextField(
            controller: _mrNoCtrl,
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: _fs, fontWeight: FontWeight.bold, color: Colors.black87),
            decoration: _decor('e.g. 000001').copyWith(
              suffixIcon: _patientFound
                  ? const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20)
                  : _patientNotFound
                  ? Icon(Icons.search_off_rounded, color: Colors.orange.shade400, size: 20)
                  : Icon(Icons.badge_rounded, color: Colors.grey.shade400, size: 20),
              filled: true,
              fillColor: _patientFound ? Colors.green.withOpacity(0.04) : Colors.white,
            ),
            onChanged: _onMrChanged,
          ),
        ),
        if (_patientFound)
          _statusChip(Icons.check_circle_rounded, 'Patient found — fields auto-filled', Colors.green),
        if (_patientNotFound)
          _statusChip(Icons.info_rounded, 'Not found — fill manually', Colors.orange),
        SizedBox(height: _sh * 0.014),

        // Full Name + Phone
        _row2(
          _FieldLabel(label: 'Full Name', req: true, fsS: _fsS, sh: _sh,
              child: _tf(_nameCtrl, 'Enter Full Name')),
          _FieldLabel(label: 'Phone', req: true, fsS: _fsS, sh: _sh,
              child: _tf(_phoneCtrl, 'Enter Phone', type: TextInputType.phone)),
        ),
        SizedBox(height: _sh * 0.013),

        // Age + Gender
        _row2(
          _FieldLabel(label: 'Age', req: true, fsS: _fsS, sh: _sh,
              child: _tf(_ageCtrl, 'Age', type: TextInputType.number)),
          _FieldLabel(label: 'Gender', req: true, fsS: _fsS, sh: _sh,
              child: _tf(_genderCtrl, 'Male / Female')),
        ),
        SizedBox(height: _sh * 0.013),

        // Address + City
        _row2(
          _FieldLabel(label: 'Address', req: true, fsS: _fsS, sh: _sh,
              child: _tf(_addressCtrl, 'Address')),
          _FieldLabel(label: 'City', fsS: _fsS, sh: _sh,
              child: _tf(_cityCtrl, 'City')),
        ),
        SizedBox(height: _sh * 0.013),

        // Panel + Reference
        _row2(
          _FieldLabel(label: 'Panel', fsS: _fsS, sh: _sh,
            child: _DropDown(sw: _sw, fs: _fs, value: _selectedPanel,
                hint: 'Select Panel', items: prov.panels,
                onChanged: (v) => setState(() => _selectedPanel = v)),
          ),
          _FieldLabel(label: 'Reference', req: true, fsS: _fsS, sh: _sh,
            child: _DropDown(sw: _sw, fs: _fs, value: _selectedReference,
                hint: 'General Physician', items: prov.references,
                onChanged: (v) => setState(() => _selectedReference = v)),
          ),
        ),
      ]),
    );
  }

  // ════════════════════════════════════════════
  //  SERVICES SECTION
  // ════════════════════════════════════════════
  Widget _servicesSection(OpdProvider prov) {
    final cats    = prov.serviceCategories;
    final svcList = (prov.services[_activeCat] ?? []).where((s) =>
    _svcSearch.isEmpty ||
        s.name.toLowerCase().contains(_svcSearch.toLowerCase())).toList();

    // category tile width
    final catW = _isWide ? _sw * 0.095 : _sw * 0.185;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // ── Section header ──
      Row(children: [
        Icon(Icons.medical_services_rounded, color: primary, size: _sw * 0.048),
        SizedBox(width: _sw * 0.02),
        Text('OPD Services',
            style: TextStyle(fontSize: _fsL, fontWeight: FontWeight.bold, color: Colors.black87)),
        const Spacer(),
        Consumer<OpdProvider>(builder: (_, p, __) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: _sw * 0.028, vertical: _sh * 0.005),
          decoration: BoxDecoration(
            color: p.selectedServices.isEmpty
                ? Colors.grey.shade200
                : primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(_sw * 0.05),
          ),
          child: Text('${p.selectedServices.length} selected',
              style: TextStyle(fontSize: _fsS, fontWeight: FontWeight.w700,
                  color: p.selectedServices.isEmpty ? Colors.grey.shade500 : primary)),
        )),
      ]),
      SizedBox(height: _sh * 0.013),

      // ── Search bar ──
      Container(
        decoration: BoxDecoration(
          color: cardBg, borderRadius: BorderRadius.circular(_sw * 0.025),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
        ),
        child: TextField(
          onChanged: (v) => setState(() => _svcSearch = v),
          style: TextStyle(fontSize: _fs),
          decoration: InputDecoration(
            hintText: 'Search services by name or description...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: _fs * 0.93),
            prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400, size: _sw * 0.05),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: _sh * 0.013),
          ),
        ),
      ),
      SizedBox(height: _sh * 0.013),

      // ── Category horizontal strip ──
      SizedBox(
        height: _sh * (_isWide ? 0.095 : 0.108),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          separatorBuilder: (_, __) => SizedBox(width: _sw * 0.022),
          itemCount: cats.length,
          itemBuilder: (_, i) {
            final cat      = cats[i];
            final id       = cat['id'] as String;
            final isActive = id == _activeCat;
            final color    = cat['color'] as Color;
            return GestureDetector(
              onTap: () => setState(() { _activeCat = id; _svcSearch = ''; }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: catW,
                decoration: BoxDecoration(
                  color: isActive ? color : cardBg,
                  borderRadius: BorderRadius.circular(_sw * 0.03),
                  border: Border.all(
                      color: isActive ? color : Colors.grey.shade200, width: 2),
                  boxShadow: isActive
                      ? [BoxShadow(
                      color: color.withOpacity(0.38),
                      blurRadius: 8, offset: const Offset(0, 3))]
                      : [BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 5)],
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(cat['icon'] as IconData,
                      color: isActive ? Colors.white : color,
                      size: _sw * (_isWide ? 0.032 : 0.062)),
                  SizedBox(height: _sh * 0.004),
                  Text(cat['label'] as String,
                      style: TextStyle(
                        fontSize: _sw * (_isWide ? 0.017 : 0.023),
                        fontWeight: FontWeight.w700,
                        color: isActive ? Colors.white : Colors.black87,
                      ),
                      textAlign: TextAlign.center, maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ]),
              ),
            );
          },
        ),
      ),
      SizedBox(height: _sh * 0.013),

      // ── Service items ──
      if (svcList.isEmpty)
        Container(
          height: _sh * 0.09,
          alignment: Alignment.center,
          child: Text('No services found',
              style: TextStyle(color: Colors.grey.shade400, fontSize: _fs)),
        )
      else if (_isMedium)
      // Grid on medium+
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _isWide ? 3 : 2,
            mainAxisSpacing: _sh * 0.009,
            crossAxisSpacing: _sw * 0.025,
            childAspectRatio: _isWide ? 3.3 : 2.8,
          ),
          itemCount: svcList.length,
          itemBuilder: (_, i) => _svcTile(svcList[i], prov),
        )
      else
      // List on small
        Column(children: svcList.map((s) => Padding(
          padding: EdgeInsets.only(bottom: _sh * 0.009),
          child: _svcTile(s, prov),
        )).toList()),
    ]);
  }

  Widget _svcTile(OpdService svc, OpdProvider prov) {
    final isSel = prov.isSelected(svc.id);
    return GestureDetector(
      onTap: () { if (isSel) prov.removeService(svc.id); else prov.addService(svc); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: _sw * 0.03, vertical: _sh * 0.011),
        decoration: BoxDecoration(
          color: isSel ? svc.color.withOpacity(0.07) : cardBg,
          borderRadius: BorderRadius.circular(_sw * 0.025),
          border: Border.all(
              color: isSel ? svc.color : Colors.grey.shade200,
              width: isSel ? 1.5 : 1),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(isSel ? 0.05 : 0.03),
              blurRadius: 6)],
        ),
        child: Row(children: [
          Container(
            padding: EdgeInsets.all(_sw * 0.018),
            decoration: BoxDecoration(
              color: svc.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(_sw * 0.018),
            ),
            child: Icon(svc.icon, color: svc.color, size: _sw * 0.042),
          ),
          SizedBox(width: _sw * 0.022),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(svc.name,
                style: TextStyle(fontSize: _fs * 0.93, fontWeight: FontWeight.w600,
                    color: Colors.black87),
                maxLines: 2, overflow: TextOverflow.ellipsis),
            Text('PKR ${svc.price.toStringAsFixed(0)}',
                style: TextStyle(fontSize: _fsS, color: Colors.grey.shade500)),
          ])),
          Icon(isSel ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
              color: isSel ? svc.color : Colors.grey.shade400,
              size: _sw * 0.052),
        ]),
      ),
    );
  }

  // ════════════════════════════════════════════
  //  BILLING CARD
  // ════════════════════════════════════════════
  Widget _billingCard(OpdProvider prov) {
    final discount     = _discountVal;
    final totalPayable = (prov.servicesTotal - discount).clamp(0, double.infinity);
    final amountPaid   = _amountPaidVal;
    final balance      = amountPaid - totalPayable;

    return _SectionCard(
      sw: _sw, icon: Icons.receipt_long_rounded, title: 'Billing',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Sub-tab toggle ──
        Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(_sw * 0.025),
          ),
          padding: EdgeInsets.all(_sw * 0.008),
          child: Row(children: [
            _subTabBtn('Summary',           0),
            SizedBox(width: _sw * 0.008),
            _subTabBtn('Selected Services', 1),
          ]),
        ),
        SizedBox(height: _sh * 0.018),

        // ── Summary ──
        if (_billingTab == 0) ...[
          _BillRow(label: 'Services Total',
              value: 'PKR ${prov.servicesTotal.toStringAsFixed(2)}',
              sw: _sw, sh: _sh, fs: _fs),
          SizedBox(height: _sh * 0.012),

          // Discount row
          Row(children: [
            Expanded(child: Text('Discount',
                style: TextStyle(fontSize: _fs, color: Colors.black54))),
            SizedBox(width: _sw * 0.34, child: _amountInput(_discountCtrl)),
          ]),
          Divider(height: _sh * 0.03, color: Colors.grey.shade200),

          _BillRow(label: 'Total Payable',
              value: 'PKR ${totalPayable.toStringAsFixed(2)}',
              sw: _sw, sh: _sh, fs: _fs, bold: true, valueColor: primary),
          SizedBox(height: _sh * 0.012),

          // Amount Paid row
          Row(children: [
            Expanded(child: Text('Amount Paid',
                style: TextStyle(fontSize: _fs, color: Colors.black54))),
            SizedBox(width: _sw * 0.34, child: _amountInput(_amountPaidCtrl)),
          ]),
          SizedBox(height: _sh * 0.01),

          _BillRow(
            label: 'Balance',
            value: 'PKR ${balance.abs().toStringAsFixed(2)}'
                '${balance < 0 ? ' (Due)' : ''}',
            sw: _sw, sh: _sh, fs: _fs, bold: true,
            valueColor: balance < 0 ? Colors.red : Colors.green,
          ),
          SizedBox(height: _sh * 0.022),

          // Action buttons
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: _clearAll,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
                side: BorderSide(color: Colors.grey.shade300),
                padding: EdgeInsets.symmetric(vertical: _sh * 0.014),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_sw * 0.025)),
              ),
              icon: Icon(Icons.close_rounded, size: _sw * 0.042),
              label: Text('Save & Exit',
                  style: TextStyle(fontSize: _fs, fontWeight: FontWeight.w600)),
            )),
            SizedBox(width: _sp),
            Expanded(flex: 2, child: ElevatedButton.icon(
              onPressed: _saveAndExit,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: _sh * 0.014),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_sw * 0.025)),
              ),
              icon: Icon(Icons.print_rounded, size: _sw * 0.042),
              label: Text('Print Receipt',
                  style: TextStyle(fontSize: _fs, fontWeight: FontWeight.bold)),
            )),
          ]),
        ],

        // ── Selected Services list ──
        if (_billingTab == 1) ...[
          if (prov.selectedServices.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: _sh * 0.045),
              child: Center(child: Column(children: [
                Icon(Icons.inbox_rounded,
                    color: Colors.grey.shade300, size: _sw * 0.14),
                SizedBox(height: _sh * 0.01),
                Text('No services selected',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: _fs)),
              ])),
            )
          else
            ...prov.selectedServices.map((sel) => Container(
              margin: EdgeInsets.only(bottom: _sh * 0.009),
              padding: EdgeInsets.symmetric(
                  horizontal: _sw * 0.03, vertical: _sh * 0.011),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(_sw * 0.025),
                border: Border.all(color: sel.service.color.withOpacity(0.3)),
                boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.03), blurRadius: 5)],
              ),
              child: Row(children: [
                Container(
                  padding: EdgeInsets.all(_sw * 0.018),
                  decoration: BoxDecoration(
                    color: sel.service.color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(sel.service.icon,
                      color: sel.service.color, size: _sw * 0.046),
                ),
                SizedBox(width: _sp),
                Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(sel.service.name,
                      style: TextStyle(fontSize: _fs,
                          fontWeight: FontWeight.w600, color: Colors.black87)),
                  Text('PKR ${sel.service.price.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: _fsS, color: Colors.grey.shade500)),
                ])),
                GestureDetector(
                  onTap: () => prov.removeService(sel.service.id),
                  child: Container(
                    padding: EdgeInsets.all(_sw * 0.015),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(_sw * 0.018),
                    ),
                    child: Icon(Icons.delete_outline_rounded,
                        color: Colors.red.shade400, size: _sw * 0.042),
                  ),
                ),
              ]),
            )).toList(),
        ],
      ]),
    );
  }

  // ════════════════════════════════════════════
  //  SMALL HELPERS
  // ════════════════════════════════════════════
  Widget _subTabBtn(String label, int index) {
    final active = _billingTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _billingTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: EdgeInsets.symmetric(vertical: _sh * 0.012),
          decoration: BoxDecoration(
            color: active ? primary : Colors.transparent,
            borderRadius: BorderRadius.circular(_sw * 0.02),
          ),
          child: Center(child: Text(label,
              style: TextStyle(
                  fontSize: _fsS, fontWeight: FontWeight.w700,
                  color: active ? Colors.white : Colors.grey.shade500))),
        ),
      ),
    );
  }

  Widget _amountInput(TextEditingController ctrl) => TextField(
    controller: ctrl,
    keyboardType: TextInputType.number,
    textAlign: TextAlign.right,
    style: TextStyle(fontSize: _fs, fontWeight: FontWeight.w600),
    onChanged: (_) => setState(() {}),
    decoration: InputDecoration(
      prefixText: 'PKR ',
      prefixStyle: TextStyle(fontSize: _fs * 0.9, color: Colors.grey.shade500),
      contentPadding: EdgeInsets.symmetric(
          horizontal: _sw * 0.025, vertical: _sh * 0.01),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(_sw * 0.02),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(_sw * 0.02),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(_sw * 0.02),
          borderSide: const BorderSide(color: primary, width: 1.5)),
    ),
  );

  Widget _row2(Widget a, Widget b) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [Expanded(child: a), SizedBox(width: _sp), Expanded(child: b)],
  );

  Widget _tf(TextEditingController ctrl, String hint,
      {TextInputType type = TextInputType.text}) =>
      TextField(
        controller: ctrl, keyboardType: type,
        style: TextStyle(fontSize: _fs, color: Colors.black87),
        decoration: _decor(hint).copyWith(
          filled: true,
          fillColor: _patientFound ? Colors.green.withOpacity(0.04) : Colors.white,
        ),
      );

  InputDecoration _decor(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: _fs * 0.95),
    filled: true, fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(
        horizontal: _sw * 0.03, vertical: _sh * 0.013),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(_sw * 0.022),
        borderSide: BorderSide(color: Colors.grey.shade300)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(_sw * 0.022),
        borderSide: BorderSide(color: Colors.grey.shade300)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(_sw * 0.022),
        borderSide: const BorderSide(color: primary, width: 1.5)),
  );

  Widget _statusChip(IconData icon, String label, Color color) =>
      Padding(
        padding: EdgeInsets.only(top: _sh * 0.005),
        child: Row(children: [
          Icon(icon, color: color, size: 13),
          SizedBox(width: _sw * 0.01),
          Flexible(child: Text(label,
              style: TextStyle(fontSize: _fsS, color: color, fontWeight: FontWeight.w600))),
        ]),
      );
}

// ════════════════════════════════════════════════
//  SHARED STATELESS WIDGETS
// ════════════════════════════════════════════════

class _SectionCard extends StatelessWidget {
  final double   sw;
  final IconData icon;
  final String   title;
  final Widget   child;
  const _SectionCard({
    required this.sw, required this.icon,
    required this.title, required this.child,
  });

  static const Color _p = Color(0xFF00B5AD);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(sw * 0.042),
        border: const Border(left: BorderSide(color: _p, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
            blurRadius: 12, offset: const Offset(0, 4))],
      ),
      padding: EdgeInsets.all(sw * 0.042),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: EdgeInsets.all(sw * 0.02),
            decoration: BoxDecoration(
              color: _p.withOpacity(0.1),
              borderRadius: BorderRadius.circular(sw * 0.02),
            ),
            child: Icon(icon, color: _p, size: sw * 0.046),
          ),
          SizedBox(width: sw * 0.022),
          Text(title, style: TextStyle(fontSize: sw * 0.04,
              fontWeight: FontWeight.bold, color: Colors.black87)),
        ]),
        SizedBox(height: sw * 0.035),
        const Divider(height: 1, color: Color(0xFFEEEEEE)),
        SizedBox(height: sw * 0.035),
        child,
      ]),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final bool   req;
  final double fsS, sh;
  final Widget child;
  const _FieldLabel({
    required this.label, this.req = false,
    required this.fsS, required this.sh, required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      RichText(text: TextSpan(
        text: label,
        style: TextStyle(fontSize: fsS, fontWeight: FontWeight.w600, color: Colors.black54),
        children: req
            ? [TextSpan(text: ' *', style: TextStyle(color: Colors.red, fontSize: fsS))]
            : [],
      )),
      SizedBox(height: sh * 0.005),
      child,
    ]);
  }
}

class _DropDown extends StatelessWidget {
  final double   sw, fs;
  final String?  value;
  final String   hint;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _DropDown({
    required this.sw, required this.fs,
    required this.value, required this.hint,
    required this.items, required this.onChanged,
  });

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
          value: value, isExpanded: true,
          hint: Text(hint, style: TextStyle(color: Colors.grey.shade400, fontSize: fs)),
          style: TextStyle(fontSize: fs, color: Colors.black87),
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: Colors.grey, size: sw * 0.046),
          items: items.map((i) =>
              DropdownMenuItem(value: i, child: Text(i))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _BillRow extends StatelessWidget {
  final String   label, value;
  final double   sw, sh, fs;
  final bool     bold;
  final Color?   valueColor;
  const _BillRow({
    required this.label, required this.value,
    required this.sw, required this.sh, required this.fs,
    this.bold = false, this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Text(label, style: TextStyle(
          fontSize: fs,
          color: bold ? Colors.black87 : Colors.black54,
          fontWeight: bold ? FontWeight.w700 : FontWeight.normal))),
      Text(value, style: TextStyle(
          fontSize: fs,
          fontWeight: bold ? FontWeight.bold : FontWeight.w500,
          color: valueColor ?? Colors.black87)),
    ]);
  }
}