import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../custum widgets/drawer/base_scaffold.dart'; // Add this import
import '../../providers/emergency_treatment_provider/emergency_provider.dart';

class EmergencyTreatmentScreen extends StatefulWidget {
  const EmergencyTreatmentScreen({super.key});
  @override
  State<EmergencyTreatmentScreen> createState() => _EmergencyTreatmentScreenState();
}

class _EmergencyTreatmentScreenState extends State<EmergencyTreatmentScreen>
    with SingleTickerProviderStateMixin {

  // Add GlobalKey for drawer access
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ── Colors (matching screenshot) ──
  static const Color primary   = Color(0xFF00B5AD);   // teal
  static const Color danger    = Color(0xFFE53935);   // red
  static const Color bgColor   = Color(0xFFF5F6FA);   // light grey bg
  static const Color cardColor = Colors.white;

  // ── MediaQuery (updated every build) ──
  late double _sw, _sh, _tp, _bp;
  bool get _wide => _sw >= 720;

  double get _fs   => _sw < 360 ? 11.5 : 13.0;
  double get _fsS  => _sw < 360 ?  9.5 : 11.0;
  double get _fsXS => _sw < 360 ?  8.0 :  9.5;
  double get _fsL  => _sw < 360 ? 14.0 : 16.5;
  double get _pad  => _sw * 0.04;
  double get _sp   => _sw * 0.025;
  double get _r    => _sw * 0.028;

  // ── Form controllers ──
  final _mrCtrl       = TextEditingController();
  final _nameCtrl     = TextEditingController();
  final _ageCtrl      = TextEditingController();
  final _genderCtrl   = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _addressCtrl  = TextEditingController();
  final _moCtrl       = TextEditingController();
  final _bedCtrl      = TextEditingController();
  final _admCtrl      = TextEditingController(text: 'Auto-filled from Emergency Receipt');
  final _pulseCtrl    = TextEditingController();
  final _tempCtrl     = TextEditingController();
  final _bpCtrl       = TextEditingController();
  final _respCtrl     = TextEditingController();
  final _spo2Ctrl     = TextEditingController();
  final _weightCtrl   = TextEditingController();
  final _heightCtrl   = TextEditingController();
  final _complainCtrl = TextEditingController();
  final _notesCtrl    = TextEditingController();

  bool _patientFound = false;

  // ── Right-panel state ──
  late TabController _rightTab; // 0 = Investigations, 1 = Medicines
  String _invType = 'X-Rays';   // Lab | Ultra Sound | X-Rays

  // ── Discharge ──
  String _disOpt     = 'After Treatment';
  bool   _discharged = false;

  @override
  void initState() {
    super.initState();
    _rightTab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _rightTab.dispose();
    for (final c in [
      _mrCtrl,_nameCtrl,_ageCtrl,_genderCtrl,_phoneCtrl,_addressCtrl,
      _moCtrl,_bedCtrl,_admCtrl,_pulseCtrl,_tempCtrl,_bpCtrl,
      _respCtrl,_spo2Ctrl,_weightCtrl,_heightCtrl,_complainCtrl,_notesCtrl,
    ]) c.dispose();
    super.dispose();
  }

  // ────────────────────────────────────────
  //  MR AUTO-FORMAT + LOOKUP
  //  User types "1" → field shows "000001" → auto-fills patient info
  // ────────────────────────────────────────
  void _onMrTyped(String raw, EmergencyProvider prov) {
    final formatted = EmergencyProvider.formatMr(raw);

    // Rewrite field to formatted value (only if different to avoid loop)
    if (_mrCtrl.text != formatted) {
      _mrCtrl.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    if (formatted.isEmpty) { _resetPatient(); return; }

    final p = prov.lookupPatient(formatted);
    if (p != null) {
      _fillPatient(p);
    } else {
      if (_patientFound) _resetPatient();
    }
  }

  void _fillPatient(EmergencyPatient p) {
    setState(() {
      _patientFound     = true;
      _mrCtrl.text      = p.mrNo;
      _nameCtrl.text    = p.name;
      _ageCtrl.text     = p.age;
      _genderCtrl.text  = p.gender;
      _phoneCtrl.text   = p.phone;
      _addressCtrl.text = p.address;
      _admCtrl.text     = _fmtDt(p.admittedSince);
    });
  }

  void _resetPatient() {
    setState(() { _patientFound = false; });
    _nameCtrl.clear(); _ageCtrl.clear(); _genderCtrl.clear();
    _phoneCtrl.clear(); _addressCtrl.clear();
    _admCtrl.text = 'Auto-filled from Emergency Receipt';
  }

  String _fmtDt(DateTime d) =>
      '${_d2(d.day)}/${_d2(d.month)}/${d.year}  ${_d2(d.hour)}:${_d2(d.minute)}';

  String _d2(int n) => n.toString().padLeft(2, '0');

  // ────────────────────────────────────────
  //  CLEAR / SAVE
  // ────────────────────────────────────────
  void _clearAll(EmergencyProvider prov) {
    for (final c in [
      _mrCtrl,_nameCtrl,_ageCtrl,_genderCtrl,_phoneCtrl,_addressCtrl,
      _moCtrl,_bedCtrl,_pulseCtrl,_tempCtrl,_bpCtrl,_respCtrl,
      _spo2Ctrl,_weightCtrl,_heightCtrl,_complainCtrl,_notesCtrl,
    ]) c.clear();
    _admCtrl.text = 'Auto-filled from Emergency Receipt';
    setState(() { _patientFound = false; _disOpt = 'After Treatment'; _discharged = false; });
    prov.clearAll();
  }

  void _saveAndPrint(EmergencyProvider prov) {
    if (_nameCtrl.text.trim().isEmpty) { _snack('Please fill patient name', err: true); return; }
    prov.saveRecord(
      mrNo: _mrCtrl.text, name: _nameCtrl.text, age: _ageCtrl.text,
      gender: _genderCtrl.text, phone: _phoneCtrl.text, address: _addressCtrl.text,
      mo: _moCtrl.text, bed: _bedCtrl.text,
      complaint: _complainCtrl.text, moNotes: _notesCtrl.text,
      dischargeOpt: _disOpt,
      services: prov.selectedServices.toList(),
      investigations: prov.addedInvestigations.toList(),
      medicines: prov.prescribedMedicines.toList(),
    );
    _snack('Record saved & printing...');
    _clearAll(prov);
  }

  void _snack(String msg, {bool err = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: err ? Colors.red.shade400 : primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_sw * 0.03)),
      margin: EdgeInsets.all(_pad),
    ));
  }

  // ════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    _sw = mq.size.width; _sh = mq.size.height;
    _tp = mq.padding.top; _bp = mq.padding.bottom;

    return Consumer<EmergencyProvider>(
      builder: (_, prov, __) => BaseScaffold(
        scaffoldKey: _scaffoldKey,
        title: 'Emergency Treatment',
        drawerIndex: 5, // Index for Emergency Treatment screen
        showAppBar: false, // We'll use custom header
        body: Column(children: [
          _header(prov),
          Expanded(child: _wide ? _wideLayout(prov) : _narrowLayout(prov)),
        ]),
      ),
    );
  }

  // ════════════════════════════════════════
  //  HEADER — Modified to include menu button
  // ════════════════════════════════════════
  Widget _header(EmergencyProvider prov) {
    final now = DateTime.now();
    const mo = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final h   = now.hour;
    final h12 = h == 0 ? 12 : h > 12 ? h - 12 : h;
    final ampm = h < 12 ? 'AM' : 'PM';
    final dateStr = '${now.day} ${mo[now.month-1]} ${now.year}'
        '  ${_d2(h12)}:${_d2(now.minute)}:${_d2(now.second)} $ampm';

    return Container(
      color: cardColor,
      padding: EdgeInsets.only(
          top: _tp + _sh * 0.013, bottom: _sh * 0.013,
          left: _pad, right: _pad),
      child: Row(children: [
        // Menu button to open drawer (replaced hospital icon)
        GestureDetector(
          onTap: () {
            _scaffoldKey.currentState?.openDrawer();
          },
          child: Container(
            padding: EdgeInsets.all(_sw * 0.022),
            decoration: BoxDecoration(
              color: danger.withOpacity(0.12),
              borderRadius: BorderRadius.circular(_sw * 0.022),
            ),
            child: Icon(Icons.menu_rounded, // Changed to menu icon
                color: danger, size: _sw * 0.048),
          ),
        ),
        SizedBox(width: _sp * 0.7),
        // Title
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Emergency Treatment',
              style: TextStyle(fontSize: _fsL, fontWeight: FontWeight.bold, color: Colors.black87),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          Text('Manage emergency patient treatments',
              style: TextStyle(fontSize: _fsS, color: Colors.grey.shade500)),
        ])),
        // Queue badge (narrow only)
        if (!_wide) ...[
          GestureDetector(
            onTap: () => _openSheet(prov),
            child: Container(
              margin: EdgeInsets.only(right: _sw * 0.018),
              padding: EdgeInsets.all(_sw * 0.02),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(_sw * 0.02),
              ),
              child: Stack(clipBehavior: Clip.none, children: [
                Icon(Icons.people_alt_rounded, color: primary, size: _sw * 0.048),
                if (prov.queueCount > 0) Positioned(
                  right: -_sw * 0.01, top: -_sw * 0.01,
                  child: Container(
                    width: _sw * 0.03, height: _sw * 0.03,
                    decoration: const BoxDecoration(color: danger, shape: BoxShape.circle),
                    child: Center(child: Text('${prov.queueCount}',
                        style: TextStyle(color: Colors.white, fontSize: _sw * 0.016,
                            fontWeight: FontWeight.bold))),
                  ),
                ),
              ]),
            ),
          ),
        ],
        // Date-time badge
        Container(
          padding: EdgeInsets.symmetric(horizontal: _sw * 0.022, vertical: _sh * 0.007),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4F8),
            borderRadius: BorderRadius.circular(_sw * 0.022),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.access_time_rounded, color: Colors.grey.shade500, size: _sw * 0.032),
            SizedBox(width: _sw * 0.01),
            Text(dateStr, style: TextStyle(fontSize: _fsXS, color: Colors.grey.shade600)),
          ]),
        ),
      ]),
    );
  }

  // ════════════════════════════════════════
  //  WIDE layout
  // ════════════════════════════════════════
  Widget _wideLayout(EmergencyProvider prov) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(flex: 64, child: _leftForm(prov)),
      SizedBox(
        width: _sw * 0.33,
        child: _rightPanel(prov),
      ),
    ],
  );

  Widget _narrowLayout(EmergencyProvider prov) => _leftForm(prov);

  // ════════════════════════════════════════
  //  LEFT FORM
  // ════════════════════════════════════════
  Widget _leftForm(EmergencyProvider prov) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
              _pad, _sh * 0.012,
              _wide ? _pad * 0.5 : _pad,
              _bp + _pad * 2),
          sliver: SliverList(delegate: SliverChildListDelegate([
            _patientInfoCard(prov),
            SizedBox(height: _sh * 0.014),
            _moCard(),
            SizedBox(height: _sh * 0.014),
            _vitalsCard(),
            SizedBox(height: _sh * 0.014),
            _servicesCard(prov),
            SizedBox(height: _sh * 0.014),
            _notesCard(),
            SizedBox(height: _sh * 0.014),
            _dischargeCard(),
            SizedBox(height: _sh * 0.014),
            _bottomBtns(prov),
          ])),
        ),
      ],
    );
  }

  // ──────────────────────────────────────
  //  1. PATIENT INFORMATION CARD
  // ──────────────────────────────────────
  Widget _patientInfoCard(EmergencyProvider prov) {
    return _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // ── Header row ──
      Row(children: [
        Icon(Icons.person_rounded, color: danger, size: _sw * 0.042),
        SizedBox(width: _sw * 0.018),
        Text('Patient Information',
            style: TextStyle(fontSize: _fs, fontWeight: FontWeight.bold, color: danger)),
        const Spacer(),
        // MR # label
        Text('MR #', style: TextStyle(fontSize: _fsS, color: Colors.black54, fontWeight: FontWeight.w600)),
        SizedBox(width: _sw * 0.012),
        // MR input — auto-formats on every keystroke
        SizedBox(width: _sw * 0.26,
          child: TextField(
            controller: _mrCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(fontSize: _fs, fontWeight: FontWeight.bold, color: Colors.black87),
            decoration: _dec('Enter MR').copyWith(
              contentPadding: EdgeInsets.symmetric(horizontal: _sw * 0.025, vertical: _sh * 0.009),
              suffixIcon: _patientFound
                  ? Icon(Icons.check_circle_rounded, color: Colors.green, size: _sw * 0.038) : null,
            ),
            onChanged: (v) => _onMrTyped(v, prov),
          ),
        ),
        SizedBox(width: _sw * 0.012),
        // Search icon button
        GestureDetector(
          onTap: () => _onMrTyped(_mrCtrl.text, prov),
          child: Container(
            padding: EdgeInsets.all(_sw * 0.02),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(_sw * 0.02),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Icon(Icons.search_rounded, color: Colors.grey.shade600, size: _sw * 0.04),
          ),
        ),
      ]),
      SizedBox(height: _sh * 0.013),
      Divider(height: _sh * 0.001, color: const Color(0xFFEEEEEE)),
      SizedBox(height: _sh * 0.012),

      // Name
      _lbl('Name'), _tf(_nameCtrl, filled: _patientFound),
      SizedBox(height: _sh * 0.01),

      // Age + Gender
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _lbl('Age'), _tf(_ageCtrl, type: TextInputType.number, filled: _patientFound),
        ])),
        SizedBox(width: _sp),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _lbl('Gender'), _tf(_genderCtrl, filled: _patientFound),
        ])),
      ]),
      SizedBox(height: _sh * 0.01),

      // Phone + Address
      if (_wide)
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _lbl('Phone'), _tf(_phoneCtrl, type: TextInputType.phone, filled: _patientFound),
          ])),
          SizedBox(width: _sp),
          Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _lbl('Address'), _tf(_addressCtrl, filled: _patientFound),
          ])),
        ])
      else ...[
        _lbl('Phone'), _tf(_phoneCtrl, type: TextInputType.phone, filled: _patientFound),
        SizedBox(height: _sh * 0.01),
        _lbl('Address'), _tf(_addressCtrl, filled: _patientFound),
      ],

      // Found indicator
      if (_patientFound) ...[
        SizedBox(height: _sh * 0.009),
        Row(children: [
          Icon(Icons.check_circle_rounded, color: Colors.green.shade600, size: _sw * 0.032),
          SizedBox(width: _sw * 0.01),
          Text('Patient found — all fields auto-filled',
              style: TextStyle(fontSize: _fsXS, color: Colors.green.shade700, fontWeight: FontWeight.w600)),
        ]),
      ],
    ]));
  }

  // ──────────────────────────────────────
  //  2. MO / BED / ADMITTED SINCE
  // ──────────────────────────────────────
  Widget _moCard() => _card(
    _wide
        ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: _labeled('MO (Medical Officer)', _moCtrl, hint: 'Enter MO')),
      SizedBox(width: _sp),
      Expanded(child: _labeled('Bed', _bedCtrl, hint: 'Bed #', type: TextInputType.number)),
      SizedBox(width: _sp),
      Expanded(flex: 2, child: _admittedWidget()),
    ])
        : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _labeled('MO (Medical Officer)', _moCtrl, hint: 'Enter MO'),
      SizedBox(height: _sh * 0.01),
      _labeled('Bed', _bedCtrl, hint: 'Bed #', type: TextInputType.number),
      SizedBox(height: _sh * 0.01),
      _admittedWidget(),
    ]),
  );

  Widget _labeled(String label, TextEditingController ctrl,
      {String hint = '', TextInputType type = TextInputType.text}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _lbl(label), _tf(ctrl, hint: hint, type: type),
      ]);

  Widget _admittedWidget() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _lbl('Admitted Since'),
    Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: _sw * 0.028, vertical: _sh * 0.013),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDE7),
        borderRadius: BorderRadius.circular(_sw * 0.022),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Text(_admCtrl.text,
          style: TextStyle(fontSize: _fs * 0.86, color: Colors.amber.shade800,
              fontFamily: 'monospace')),
    ),
  ]);

  // ──────────────────────────────────────
  //  3. VITALS
  // ──────────────────────────────────────
  Widget _vitalsCard() {
    final fields = [
      ('Pulse',     _pulseCtrl,  TextInputType.number),
      ('Temp',      _tempCtrl,   TextInputType.number),
      ('B.P.',      _bpCtrl,     TextInputType.text),
      ('Resp Rate', _respCtrl,   TextInputType.number),
      ('SPO₂',      _spo2Ctrl,   TextInputType.number),
      ('Weight',    _weightCtrl, TextInputType.number),
      ('Height',    _heightCtrl, TextInputType.number),
    ];
    final cols = _wide ? 7 : (_sw < 400 ? 3 : 4);

    return _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.favorite_rounded, color: danger, size: _sw * 0.042),
        SizedBox(width: _sw * 0.018),
        Text('Vitals', style: TextStyle(fontSize: _fs, fontWeight: FontWeight.bold, color: Colors.black87)),
      ]),
      SizedBox(height: _sh * 0.011),
      Divider(height: _sh * 0.001, color: const Color(0xFFEEEEEE)),
      SizedBox(height: _sh * 0.011),
      GridView.count(
        crossAxisCount: cols,
        mainAxisSpacing: _sh * 0.01,
        crossAxisSpacing: _sw * 0.02,
        childAspectRatio: _wide ? 2.5 : (_sw < 400 ? 2.0 : 2.3),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: fields.map((f) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _lbl(f.$1),
            Expanded(child: _tf(f.$2, type: f.$3, compact: true)),
          ],
        )).toList(),
      ),
    ]));
  }

  // ──────────────────────────────────────
  //  4. EMERGENCY SERVICES
  // ──────────────────────────────────────
  Widget _servicesCard(EmergencyProvider prov) {
    final cols = _wide ? 8 : (_sw < 400 ? 3 : 4);

    return _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(Icons.emergency_share_rounded, color: danger, size: _sw * 0.042),
        SizedBox(width: _sw * 0.018),
        Text('Emergency Services',
            style: TextStyle(fontSize: _fs, fontWeight: FontWeight.bold, color: Colors.black87)),
        const Spacer(),
        // PKR total badge
        Consumer<EmergencyProvider>(builder: (_, p, __) => Container(
          padding: EdgeInsets.symmetric(horizontal: _sw * 0.028, vertical: _sh * 0.005),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(_sw * 0.04),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text('PKR ${p.servicesTotalPrice.toStringAsFixed(0)}',
              style: TextStyle(fontSize: _fsS, fontWeight: FontWeight.w700, color: Colors.black87)),
        )),
      ]),
      SizedBox(height: _sh * 0.011),
      Divider(height: _sh * 0.001, color: const Color(0xFFEEEEEE)),
      SizedBox(height: _sh * 0.011),
      GridView.count(
        crossAxisCount: cols,
        mainAxisSpacing: _sh * 0.01,
        crossAxisSpacing: _sw * 0.02,
        childAspectRatio: _wide ? 0.9 : (_sw < 400 ? 0.82 : 0.88),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: prov.emergencyServices.map((svc) {
          final sel = prov.isServiceSelected(svc.id);
          return GestureDetector(
            onTap: () => prov.toggleService(svc),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              decoration: BoxDecoration(
                color: sel ? svc.color.withOpacity(0.09) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(_sw * 0.022),
                border: Border.all(color: sel ? svc.color : Colors.grey.shade200, width: sel ? 1.5 : 1),
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  padding: EdgeInsets.all(_sw * 0.02),
                  decoration: BoxDecoration(color: svc.color.withOpacity(0.12), shape: BoxShape.circle),
                  child: Icon(svc.icon, color: svc.color, size: _sw * 0.052),
                ),
                SizedBox(height: _sh * 0.005),
                Text(svc.name,
                    style: TextStyle(fontSize: _fsXS, fontWeight: FontWeight.w600, color: Colors.black87),
                    textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('Rs ${svc.price.toStringAsFixed(0)}',
                    style: TextStyle(fontSize: _fsXS * 0.88, color: Colors.grey.shade500)),
              ]),
            ),
          );
        }).toList(),
      ),
    ]));
  }

  // ──────────────────────────────────────
  //  5. COMPLAINT + MO NOTES
  // ──────────────────────────────────────
  Widget _notesCard() => _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _lbl('Complaint'),
    _tf(_complainCtrl, hint: 'Patient complaint...'),
    SizedBox(height: _sh * 0.013),
    _lbl('MO Notes'),
    TextField(
      controller: _notesCtrl,
      maxLines: 3,
      style: TextStyle(fontSize: _fs, color: Colors.black87),
      decoration: _dec('Medical officer notes...'),
    ),
  ]));

  // ──────────────────────────────────────
  //  6. DISCHARGE ROW
  // ──────────────────────────────────────
  Widget _dischargeCard() {
    final opts = ['After Treatment','Refer to Admission','Refer to Other Hospital','Patient Expired'];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: _sw * 0.035, vertical: _sh * 0.012),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(_r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0,2))],
      ),
      child: _wide
          ? Row(children: [
        Expanded(child: Wrap(spacing: _sw * 0.005, children: opts.map(_radioOpt).toList())),
        _disCheck(),
      ])
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: _sw * 0.004, runSpacing: _sh * 0.004, children: opts.map(_radioOpt).toList()),
        SizedBox(height: _sh * 0.009),
        _disCheck(),
      ]),
    );
  }

  Widget _radioOpt(String label) => GestureDetector(
    onTap: () => setState(() => _disOpt = label),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Radio<String>(
        value: label, groupValue: _disOpt, activeColor: primary,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        onChanged: (v) => setState(() => _disOpt = v!),
      ),
      Text(label, style: TextStyle(fontSize: _fsS, color: Colors.black87)),
    ]),
  );

  Widget _disCheck() => Row(mainAxisSize: MainAxisSize.min, children: [
    Checkbox(
      value: _discharged, activeColor: primary,
      onChanged: (v) => setState(() => _discharged = v ?? false),
    ),
    Text('Discharge Patient',
        style: TextStyle(fontSize: _fs, fontWeight: FontWeight.w700, color: Colors.black87)),
  ]);

  // ──────────────────────────────────────
  //  7. CLEAR + SAVE & PRINT
  // ──────────────────────────────────────
  Widget _bottomBtns(EmergencyProvider prov) => Row(children: [
    Expanded(child: OutlinedButton(
      onPressed: () => _clearAll(prov),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black54,
        side: BorderSide(color: Colors.grey.shade300),
        padding: EdgeInsets.symmetric(vertical: _sh * 0.016),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_sw * 0.025)),
      ),
      child: Text('Clear', style: TextStyle(fontSize: _fs, fontWeight: FontWeight.w600)),
    )),
    SizedBox(width: _sp),
    Expanded(flex: 2, child: ElevatedButton.icon(
      onPressed: () => _saveAndPrint(prov),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFEF9A9A),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: _sh * 0.016),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_sw * 0.025)),
      ),
      icon: Icon(Icons.print_rounded, size: _sw * 0.042),
      label: Text('Save & Print', style: TextStyle(fontSize: _fs, fontWeight: FontWeight.bold)),
    )),
  ]);

  // ════════════════════════════════════════
  //  RIGHT PANEL
  // ════════════════════════════════════════
  Widget _rightPanel(EmergencyProvider prov) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, _sh * 0.012, _pad * 0.5, _bp + _pad),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(children: [
          _queueCard(prov),
          SizedBox(height: _sh * 0.012),
          _invMedCard(prov),
        ]),
      ),
    );
  }

  // ──────────────────────────────────────
  //  EMERGENCY PATIENTS QUEUE CARD
  // ──────────────────────────────────────
  Widget _queueCard(EmergencyProvider prov) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(_r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0,2))],
      ),
      child: Column(children: [
        // Dark header
        Container(
          padding: EdgeInsets.symmetric(horizontal: _sw * 0.028, vertical: _sh * 0.012),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(_r), topRight: Radius.circular(_r)),
          ),
          child: Row(children: [
            Icon(Icons.emergency_rounded, color: danger, size: _sw * 0.035),
            SizedBox(width: _sw * 0.012),
            Expanded(child: Text('Emergency Patients',
                style: TextStyle(fontSize: _fsS, fontWeight: FontWeight.bold, color: Colors.white))),
            Container(
              padding: EdgeInsets.symmetric(horizontal: _sw * 0.018, vertical: _sh * 0.003),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.14),
                borderRadius: BorderRadius.circular(_sw * 0.04),
              ),
              child: Text('${prov.queueCount} in queue',
                  style: TextStyle(fontSize: _fsXS, color: Colors.white70)),
            ),
          ]),
        ),
        // Column headers: MR# | SINCE | PATIENT
        Padding(
          padding: EdgeInsets.symmetric(horizontal: _sw * 0.028, vertical: _sh * 0.009),
          child: Row(children: [
            Expanded(flex: 2, child: Text('MR #', style: TextStyle(fontSize: _fsXS, fontWeight: FontWeight.w700, color: Colors.black54))),
            Expanded(flex: 3, child: Text('SINCE', style: TextStyle(fontSize: _fsXS, fontWeight: FontWeight.w700, color: Colors.black54))),
            Expanded(flex: 4, child: Text('PATIENT', style: TextStyle(fontSize: _fsXS, fontWeight: FontWeight.w700, color: Colors.black54))),
          ]),
        ),
        Divider(height: _sh * 0.001, color: const Color(0xFFEEEEEE)),
        // Rows
        prov.queue.isEmpty
            ? Padding(
          padding: EdgeInsets.symmetric(vertical: _sh * 0.024),
          child: Center(child: Text('No emergency patients in queue',
              style: TextStyle(fontSize: _fsS, color: Colors.grey.shade400, fontStyle: FontStyle.italic))),
        )
            : Column(children: prov.queue.map((p) {
          final diff = DateTime.now().difference(p.admittedSince);
          final since = diff.inMinutes < 60 ? '${diff.inMinutes}m ago' : '${diff.inHours}h ${diff.inMinutes.remainder(60)}m';
          return GestureDetector(
            onTap: () => _fillPatient(p),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: _sw * 0.028, vertical: _sh * 0.009),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5)))),
              child: Row(children: [
                Expanded(flex: 2, child: Text(p.mrNo, style: TextStyle(fontSize: _fsXS, color: Colors.black87))),
                Expanded(flex: 3, child: Text(since, style: TextStyle(fontSize: _fsXS, color: Colors.grey.shade500))),
                Expanded(flex: 4, child: Text(p.name,
                    style: TextStyle(fontSize: _fsXS, fontWeight: FontWeight.w600, color: Colors.black87),
                    maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
            ),
          );
        }).toList()),
        Divider(height: _sh * 0.001, color: const Color(0xFFEEEEEE)),
        TextButton.icon(
          onPressed: () => prov.refresh(),
          icon: Icon(Icons.refresh_rounded, size: _sw * 0.032, color: Colors.grey.shade500),
          label: Text('Refresh', style: TextStyle(fontSize: _fsS, color: Colors.grey.shade600)),
        ),
      ]),
    );
  }

  // ──────────────────────────────────────
  //  INVESTIGATIONS + MEDICINES TABBED CARD
  // ──────────────────────────────────────
  Widget _invMedCard(EmergencyProvider prov) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(_r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0,2))],
      ),
      child: Column(children: [
        // Tab bar: INVESTIGATIONS | MEDICINES (matches screenshot exactly)
        TabBar(
          controller: _rightTab,
          labelColor: danger,
          unselectedLabelColor: Colors.grey.shade500,
          indicatorColor: danger,
          indicatorWeight: _sw * 0.006,
          labelStyle: TextStyle(fontSize: _fsS, fontWeight: FontWeight.w700, letterSpacing: 0.3),
          unselectedLabelStyle: TextStyle(fontSize: _fsS, fontWeight: FontWeight.w600),
          tabs: const [Tab(text: 'INVESTIGATIONS'), Tab(text: 'MEDICINES')],
        ),
        Divider(height: _sh * 0.001, color: const Color(0xFFEEEEEE)),
        SizedBox(
          height: _sh * 0.56,
          child: TabBarView(
            controller: _rightTab,
            children: [
              _investigationsView(prov),
              _medicinesView(prov),
            ],
          ),
        ),
      ]),
    );
  }

  // ── INVESTIGATIONS TAB ──
  Widget _investigationsView(EmergencyProvider prov) {
    final types = ['Lab', 'Ultra Sound', 'X-Rays'];
    final items = prov.investigations[_invType] ?? [];

    return Column(children: [
      // Radio: Lab | Ultra Sound | X-Rays
      Padding(
        padding: EdgeInsets.symmetric(horizontal: _sw * 0.02, vertical: _sh * 0.007),
        child: Row(children: types.map((t) => Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _invType = t),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Radio<String>(
                value: t, groupValue: _invType, activeColor: danger,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                onChanged: (v) => setState(() => _invType = v!),
              ),
              Flexible(child: Text(t,
                  style: TextStyle(fontSize: _fsXS, color: Colors.black87),
                  overflow: TextOverflow.ellipsis)),
            ]),
          ),
        )).toList()),
      ),
      Divider(height: _sh * 0.001, color: const Color(0xFFEEEEEE)),

      // Scrollable list
      Expanded(child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: items.length,
        itemBuilder: (_, i) {
          final item = items[i];
          final added = prov.addedInvestigations.any((a) => a.name == item);
          return GestureDetector(
            onTap: () => prov.addInvestigation(_invType, item),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: _sw * 0.028, vertical: _sh * 0.0095),
              decoration: BoxDecoration(
                color: added ? primary.withOpacity(0.06) : Colors.transparent,
                border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
              ),
              child: Row(children: [
                Expanded(child: Text(item, style: TextStyle(fontSize: _fsS, color: Colors.black87))),
                if (added) Icon(Icons.check_rounded, color: primary, size: _sw * 0.033),
              ]),
            ),
          );
        },
      )),

      // Added table
      Divider(height: _sh * 0.001, color: const Color(0xFFEEEEEE)),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: _sw * 0.028, vertical: _sh * 0.008),
        child: Row(children: [
          Expanded(child: Text('TYPE', style: TextStyle(fontSize: _fsXS, fontWeight: FontWeight.w700, color: Colors.black54))),
          Expanded(flex: 2, child: Text('NAME', style: TextStyle(fontSize: _fsXS, fontWeight: FontWeight.w700, color: Colors.black54))),
        ]),
      ),
      Divider(height: _sh * 0.001, color: const Color(0xFFEEEEEE)),
      prov.addedInvestigations.isEmpty
          ? Padding(
        padding: EdgeInsets.symmetric(vertical: _sh * 0.012),
        child: Text('Click an item above to add',
            style: TextStyle(fontSize: _fsS, color: Colors.grey.shade400, fontStyle: FontStyle.italic)),
      )
          : Column(children: prov.addedInvestigations.map((inv) => Container(
        padding: EdgeInsets.symmetric(horizontal: _sw * 0.028, vertical: _sh * 0.007),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
        child: Row(children: [
          Expanded(child: Text(inv.type, style: TextStyle(fontSize: _fsXS, color: Colors.grey.shade600))),
          Expanded(flex: 2, child: Text(inv.name, style: TextStyle(fontSize: _fsXS, color: Colors.black87),
              maxLines: 2, overflow: TextOverflow.ellipsis)),
          GestureDetector(
            onTap: () => prov.removeInvestigation(inv.name),
            child: Icon(Icons.close_rounded, color: Colors.red.shade300, size: _sw * 0.032),
          ),
        ]),
      )).toList()),
      SizedBox(height: _sh * 0.008),
    ]);
  }

  // ── MEDICINES TAB ──
  Widget _medicinesView(EmergencyProvider prov) {
    return Column(children: [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: _sw * 0.028, vertical: _sh * 0.009),
        child: Row(children: [
          Text('Select Medicines', style: TextStyle(fontSize: _fsS, fontWeight: FontWeight.w600, color: Colors.black54)),
          const Spacer(),
          Consumer<EmergencyProvider>(builder: (_, p, __) => Container(
            padding: EdgeInsets.symmetric(horizontal: _sw * 0.02, vertical: _sh * 0.003),
            decoration: BoxDecoration(color: primary.withOpacity(0.1), borderRadius: BorderRadius.circular(_sw * 0.04)),
            child: Text('${p.prescribedMedicines.length} added',
                style: TextStyle(fontSize: _fsXS, color: primary, fontWeight: FontWeight.w700)),
          )),
        ]),
      ),
      Divider(height: _sh * 0.001, color: const Color(0xFFEEEEEE)),
      Expanded(child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: prov.medicinesList.length,
        itemBuilder: (_, i) {
          final med = prov.medicinesList[i];
          final presc = prov.isMedicinePrescribed(med.name);
          return GestureDetector(
            onTap: () => prov.toggleMedicine(med),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              padding: EdgeInsets.symmetric(horizontal: _sw * 0.028, vertical: _sh * 0.009),
              decoration: BoxDecoration(
                color: presc ? primary.withOpacity(0.06) : Colors.transparent,
                border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
              ),
              child: Row(children: [
                Icon(presc ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    color: presc ? primary : Colors.grey.shade400, size: _sw * 0.036),
                SizedBox(width: _sw * 0.014),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(med.name, style: TextStyle(fontSize: _fsS, fontWeight: FontWeight.w600, color: Colors.black87)),
                  Text('${med.dose}  •  ${med.route}',
                      style: TextStyle(fontSize: _fsXS, color: Colors.grey.shade500)),
                ])),
              ]),
            ),
          );
        },
      )),
    ]);
  }

  // ════════════════════════════════════════
  //  NARROW: bottom sheet for right panel
  // ════════════════════════════════════════
  void _openSheet(EmergencyProvider prov) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: prov,
        child: Container(
          height: _sh * 0.88,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(_sw * 0.06)),
          ),
          child: Column(children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: _sh * 0.012),
              width: _sw * 0.1, height: _sh * 0.005,
              decoration: BoxDecoration(color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(_sw * 0.01)),
            ),
            Expanded(child: SingleChildScrollView(
              padding: EdgeInsets.all(_pad),
              physics: const BouncingScrollPhysics(),
              child: Consumer<EmergencyProvider>(builder: (_, p, __) => Column(children: [
                _queueCard(p),
                SizedBox(height: _sh * 0.012),
                _invMedCard(p),
                SizedBox(height: _bp + _pad),
              ])),
            )),
          ]),
        ),
      ),
    );
  }

  // ════════════════════════════════════════
  //  SHARED HELPERS
  // ════════════════════════════════════════
  Widget _card(Widget child) => Container(
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(_r),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0,2))],
    ),
    padding: EdgeInsets.all(_sw * 0.038),
    child: child,
  );

  Widget _lbl(String t) => Padding(
    padding: EdgeInsets.only(bottom: _sh * 0.004),
    child: Text(t, style: TextStyle(fontSize: _fsS, color: Colors.black54, fontWeight: FontWeight.w500)),
  );

  Widget _tf(TextEditingController ctrl, {
    String hint = '',
    TextInputType type = TextInputType.text,
    bool filled = false,
    bool compact = false,
  }) =>
      TextField(
        controller: ctrl,
        keyboardType: type,
        style: TextStyle(fontSize: _fs, color: Colors.black87),
        decoration: _dec(hint, filled: filled, compact: compact),
      );

  InputDecoration _dec(String hint, {bool filled = false, bool compact = false}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: _fs * 0.92),
        filled: true,
        fillColor: filled ? Colors.green.withOpacity(0.04) : Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(
          horizontal: _sw * 0.028,
          vertical: compact ? _sh * 0.008 : _sh * 0.013,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(_sw * 0.022),
            borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(_sw * 0.022),
            borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(_sw * 0.022),
            borderSide: const BorderSide(color: primary, width: 1.5)),
      );
}