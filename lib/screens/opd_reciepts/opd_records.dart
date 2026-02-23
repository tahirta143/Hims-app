import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../custum widgets/drawer/base_scaffold.dart'; // Add this import
import '../../providers/opd/opd_reciepts/opd_reciepts.dart';

class OpdRecordsScreen extends StatefulWidget {
  const OpdRecordsScreen({super.key});

  @override
  State<OpdRecordsScreen> createState() => _OpdRecordsScreenState();
}

class _OpdRecordsScreenState extends State<OpdRecordsScreen> {
  static const Color primary = Color(0xFF00B5AD);
  static const Color bgColor = Color(0xFFF0F4F8);

  // Add GlobalKey for drawer access
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // ── Filter controllers ──
  final _nameCtrl    = TextEditingController();
  final _mrCtrl      = TextEditingController();
  final _serviceCtrl = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedYear  = 'All';
  String _selectedMonth = 'All';

  // ── Active filters (applied on Search) ──
  String _fName    = '';
  String _fMr      = '';
  String _fService = '';
  DateTime? _fStart;
  DateTime? _fEnd;
  String _fYear  = 'All';
  String _fMonth = 'All';

  // MediaQuery
  late double _sw, _sh, _tp, _bp;
  bool get _isWide => _sw >= 700;

  double get _fs   => _sw < 360 ? 11.0 : 12.5;
  double get _fsS  => _sw < 360 ?  9.5 : 11.0;
  double get _fsXS => _sw < 360 ?  8.5 :  9.5;
  double get _pad  => _sw * 0.04;
  double get _sp   => _sw * 0.02;

  static const List<String> _years  = ['All','2024','2025','2026'];
  static const List<String> _months = [
    'All','January','February','March','April','May','June',
    'July','August','September','October','November','December'
  ];

  @override
  void dispose() {
    _nameCtrl.dispose(); _mrCtrl.dispose(); _serviceCtrl.dispose();
    super.dispose();
  }

  // ── Filter logic ──
  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> all) {
    return all.where((r) {
      final name    = (r['patientName'] as String).toLowerCase();
      final mr      = (r['mrNo']        as String).toLowerCase();
      final svcList = (r['services']    as List).join(' ').toLowerCase();
      final date    = r['date']         as DateTime;

      if (_fName.isNotEmpty    && !name.contains(_fName.toLowerCase()))    return false;
      if (_fMr.isNotEmpty      && !mr.contains(_fMr.toLowerCase()))        return false;
      if (_fService.isNotEmpty && !svcList.contains(_fService.toLowerCase())) return false;
      if (_fStart != null      && date.isBefore(_fStart!))                 return false;
      if (_fEnd   != null      && date.isAfter(_fEnd!.add(const Duration(days: 1)))) return false;
      if (_fYear  != 'All'     && date.year.toString() != _fYear)          return false;
      if (_fMonth != 'All') {
        final mIdx = _months.indexOf(_fMonth);
        if (date.month != mIdx) return false;
      }
      return true;
    }).toList();
  }

  void _doSearch() {
    setState(() {
      _fName    = _nameCtrl.text.trim();
      _fMr      = _mrCtrl.text.trim();
      _fService = _serviceCtrl.text.trim();
      _fStart   = _startDate;
      _fEnd     = _endDate;
      _fYear    = _selectedYear;
      _fMonth   = _selectedMonth;
    });
  }

  void _doClear() {
    _nameCtrl.clear(); _mrCtrl.clear(); _serviceCtrl.clear();
    setState(() {
      _startDate = null; _endDate = null;
      _selectedYear = 'All'; _selectedMonth = 'All';
      _fName = ''; _fMr = ''; _fService = '';
      _fStart = null; _fEnd = null;
      _fYear = 'All'; _fMonth = 'All';
    });
  }

  // ── Date picker ──
  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() { if (isStart) _startDate = picked; else _endDate = picked; });
    }
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2,'0')} ${_months[d.month].substring(0,3)} ${d.year}';

  // ── Cancel / Refund actions on provider records ──
  void _cancelRecord(OpdProvider prov, int idx) {
    final rec = prov.receipts[idx];
    if (rec['status'] == 'Cancelled') return;
    prov.updateReceiptStatus(idx, 'Cancelled');
    _snack('Receipt cancelled');
  }

  void _refundRecord(OpdProvider prov, int idx) {
    final rec = prov.receipts[idx];
    if (rec['status'] == 'Cancelled') {
      _snack('Cannot refund a cancelled receipt', err: true); return;
    }
    prov.updateReceiptStatus(idx, 'Refunded');
    _snack('Refund processed');
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

  // ════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    _sw = mq.size.width; _sh = mq.size.height;
    _tp = mq.padding.top; _bp = mq.padding.bottom;

    return BaseScaffold(
      scaffoldKey: _scaffoldKey,
      title: 'OPD Records',
      drawerIndex: 4, // Index for OPD Records screen
      showAppBar: false, // We'll use custom header
      body: Consumer<OpdProvider>(builder: (_, prov, __) {
        final filtered = _applyFilters(prov.receipts.toList().reversed.toList());
        return Column(children: [
          _buildTopBar(),
          Expanded(child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: Padding(
                padding: EdgeInsets.all(_pad),
                child: Column(children: [
                  _filterCard(),
                  SizedBox(height: _pad * 0.8),
                  _statsBar(filtered.length),
                  SizedBox(height: _pad * 0.8),
                ]),
              )),
              filtered.isEmpty
                  ? SliverFillRemaining(child: _emptyState())
                  : _isWide
                  ? _wideTable(filtered, prov)
                  : _narrowList(filtered, prov),
              SliverToBoxAdapter(child: SizedBox(height: _bp + _pad)),
            ],
          )),
        ]);
      }),
    );
  }

  // ════════════════════════════════════
  //  TOP BAR - Modified to include menu button
  // ════════════════════════════════════
  Widget _buildTopBar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00B5AD), Color(0xFF00897B)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.only(
        top: _tp + _sh * 0.014, bottom: _sh * 0.018,
        left: _pad, right: _pad,
      ),
      child: Row(children: [
        // Menu button to open drawer
        GestureDetector(
          onTap: () {
            _scaffoldKey.currentState?.openDrawer();
          },
          child: Container(
            padding: EdgeInsets.all(_sw * 0.022),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(_sw * 0.022),
            ),
            child: Icon(Icons.menu_rounded, // Changed to menu icon
                color: Colors.white, size: _sw * 0.042),
          ),
        ),
        SizedBox(width: _sp),
        Container(
          padding: EdgeInsets.all(_sw * 0.022),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(_sw * 0.022),
          ),
          child: Icon(Icons.table_chart_rounded, color: Colors.white, size: _sw * 0.048),
        ),
        SizedBox(width: _sp),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Patient OPD Records',
              style: TextStyle(fontSize: _sw * 0.045, fontWeight: FontWeight.bold,
                  color: Colors.white, letterSpacing: 0.2)),
        ]),
      ]),
    );
  }

  // ════════════════════════════════════
  //  FILTER CARD
  // ════════════════════════════════════
  Widget _filterCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_sw * 0.04),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
            blurRadius: 10, offset: const Offset(0, 3))],
      ),
      padding: EdgeInsets.all(_pad),
      child: Column(children: [
        // Row 1: Name | MR/Receipt | Service
        _isWide
            ? Row(children: [
          Expanded(child: _filterField(_nameCtrl,    'Patient Name...',        Icons.person_outline_rounded)),
          SizedBox(width: _sp),
          Expanded(child: _filterField(_mrCtrl,      'MR or Receipt...',       Icons.tag_rounded)),
          SizedBox(width: _sp),
          Expanded(child: _filterField(_serviceCtrl, 'Service or Doctor name...', Icons.medical_services_outlined)),
        ])
            : Column(children: [
          _filterField(_nameCtrl,    'Patient Name...',        Icons.person_outline_rounded),
          SizedBox(height: _sp * 0.8),
          _filterField(_mrCtrl,      'MR or Receipt...',       Icons.tag_rounded),
          SizedBox(height: _sp * 0.8),
          _filterField(_serviceCtrl, 'Service or Doctor name...', Icons.medical_services_outlined),
        ]),
        SizedBox(height: _sp * 0.8),

        // Row 2: Date Range | Year | Month | Buttons
        _isWide
            ? Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Expanded(flex: 3, child: _dateRangeRow()),
          SizedBox(width: _sp),
          Expanded(child: _dropdownFilter('Year',  _years,  _selectedYear,
                  (v) => setState(() => _selectedYear = v!))),
          SizedBox(width: _sp),
          Expanded(child: _dropdownFilter('Month', _months, _selectedMonth,
                  (v) => setState(() => _selectedMonth = v!))),
          SizedBox(width: _sp),
          _actionButtons(),
        ])
            : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _dateRangeRow(),
          SizedBox(height: _sp * 0.8),
          Row(children: [
            Expanded(child: _dropdownFilter('Year',  _years,  _selectedYear,
                    (v) => setState(() => _selectedYear = v!))),
            SizedBox(width: _sp),
            Expanded(child: _dropdownFilter('Month', _months, _selectedMonth,
                    (v) => setState(() => _selectedMonth = v!))),
          ]),
          SizedBox(height: _sp * 0.8),
          _actionButtons(),
        ]),
      ]),
    );
  }

  Widget _filterField(TextEditingController ctrl, String hint, IconData icon) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (hint.contains('Name'))
        _filterLabel('Patient Name')
      else if (hint.contains('MR'))
        _filterLabel('MR / Receipt No')
      else
        _filterLabel('Service / Doctor'),
      SizedBox(height: _sh * 0.005),
      TextField(
        controller: ctrl,
        style: TextStyle(fontSize: _fs),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: _fs * 0.92),
          prefixIcon: Icon(icon, color: Colors.grey.shade400, size: _sw * 0.042),
          filled: true, fillColor: bgColor,
          contentPadding: EdgeInsets.symmetric(
              horizontal: _sw * 0.025, vertical: _sh * 0.012),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(_sw * 0.025),
              borderSide: BorderSide(color: Colors.grey.shade200)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(_sw * 0.025),
              borderSide: BorderSide(color: Colors.grey.shade200)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(_sw * 0.025),
              borderSide: const BorderSide(color: primary, width: 1.5)),
        ),
      ),
    ]);
  }

  Widget _filterLabel(String label) => Text(label,
      style: TextStyle(fontSize: _fsS, fontWeight: FontWeight.w600, color: Colors.black54));

  Widget _dateRangeRow() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _filterLabel('Date Range'),
      SizedBox(height: _sh * 0.005),
      Row(children: [
        Expanded(child: _dateTile(_startDate, 'Start Date', true)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: _sw * 0.015),
          child: Icon(Icons.arrow_forward_rounded, color: Colors.grey.shade400, size: _sw * 0.04),
        ),
        Expanded(child: _dateTile(_endDate, 'End Date', false)),
      ]),
    ]);
  }

  Widget _dateTile(DateTime? date, String hint, bool isStart) {
    return GestureDetector(
      onTap: () => _pickDate(isStart),
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: _sw * 0.025, vertical: _sh * 0.013),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(_sw * 0.025),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(children: [
          Expanded(child: Text(
            date != null ? _fmtDate(date) : hint,
            style: TextStyle(
              fontSize: _fs * 0.9,
              color: date != null ? Colors.black87 : Colors.grey.shade400,
            ),
          )),
          Icon(Icons.calendar_today_outlined,
              color: Colors.grey.shade400, size: _sw * 0.038),
        ]),
      ),
    );
  }

  Widget _dropdownFilter(String label, List<String> items, String val,
      ValueChanged<String?> onChange) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _filterLabel(label),
      SizedBox(height: _sh * 0.005),
      Container(
        padding: EdgeInsets.symmetric(horizontal: _sw * 0.025),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(_sw * 0.025),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: val, isExpanded: true,
            style: TextStyle(fontSize: _fs, color: Colors.black87),
            icon: Icon(Icons.keyboard_arrow_down_rounded,
                color: Colors.grey, size: _sw * 0.042),
            items: items.map((i) =>
                DropdownMenuItem(value: i, child: Text(i))).toList(),
            onChanged: onChange,
          ),
        ),
      ),
    ]);
  }

  Widget _actionButtons() {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      // Search
      ElevatedButton.icon(
        onPressed: _doSearch,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary, foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
              horizontal: _sw * 0.04, vertical: _sh * 0.014),
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_sw * 0.025)),
        ),
        icon: Icon(Icons.search_rounded, size: _sw * 0.042),
        label: Text('Search',
            style: TextStyle(fontSize: _fs, fontWeight: FontWeight.bold)),
      ),
      SizedBox(width: _sp * 0.6),
      // Clear
      OutlinedButton.icon(
        onPressed: _doClear,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.grey.shade600,
          side: BorderSide(color: Colors.grey.shade300),
          padding: EdgeInsets.symmetric(
              horizontal: _sw * 0.032, vertical: _sh * 0.014),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_sw * 0.025)),
        ),
        icon: Icon(Icons.refresh_rounded, size: _sw * 0.038),
        label: Text('Clear',
            style: TextStyle(fontSize: _fs, fontWeight: FontWeight.w600)),
      ),
      SizedBox(width: _sp * 0.6),
      // Print
      OutlinedButton.icon(
        onPressed: () => _snack('Printing...'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.grey.shade600,
          side: BorderSide(color: Colors.grey.shade300),
          padding: EdgeInsets.symmetric(
              horizontal: _sw * 0.032, vertical: _sh * 0.014),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_sw * 0.025)),
        ),
        icon: Icon(Icons.print_rounded, size: _sw * 0.038),
        label: Text('Print',
            style: TextStyle(fontSize: _fs, fontWeight: FontWeight.w600)),
      ),
    ]);
  }

  // ════════════════════════════════════
  //  STATS BAR
  // ════════════════════════════════════
  Widget _statsBar(int count) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: _pad, vertical: _sh * 0.016),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00B5AD), Color(0xFF00897B)],
          begin: Alignment.centerLeft, end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(_sw * 0.03),
      ),
      child: Row(children: [
        Container(
          padding: EdgeInsets.all(_sw * 0.022),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(_sw * 0.022),
          ),
          child: Icon(Icons.table_rows_rounded, color: Colors.white, size: _sw * 0.045),
        ),
        SizedBox(width: _sp),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('TOTAL RECORDS FOUND',
              style: TextStyle(fontSize: _fsXS, color: Colors.white70,
                  fontWeight: FontWeight.w600, letterSpacing: 0.5)),
          Text(count.toString().replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},'),
              style: TextStyle(fontSize: _sw * 0.055, fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ]),
        const Spacer(),
        Text('Showing page 1',
            style: TextStyle(fontSize: _fsS, color: Colors.white70)),
      ]),
    );
  }

  // ════════════════════════════════════
  //  WIDE TABLE
  // ════════════════════════════════════
  Widget _wideTable(List<Map<String, dynamic>> records, OpdProvider prov) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: _pad),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_sw * 0.025),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
                blurRadius: 10, offset: const Offset(0, 3))],
          ),
          child: Column(children: [
            // Table header
            _tableHeader(),
            Divider(height: _sh * 0.001, color: const Color(0xFFEEEEEE)),
            // Rows
            ...records.asMap().entries.map((e) =>
                _tableRow(e.key, e.value, prov, records)),
          ]),
        ),
      ),
    );
  }

  Widget _tableHeader() {
    final cols = ['Sr #','Receipt No','MR No','Date','Patient Name',
      'Service','Details','Total','Discount','Age','Gender',
      'Refund','Cancel'];
    final flexes = [1, 2, 2, 2, 3, 2, 3, 2, 2, 1, 1, 2, 2];
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: _pad, vertical: _sh * 0.014),
      child: Row(children: List.generate(cols.length, (i) => Expanded(
        flex: flexes[i],
        child: Text(cols[i],
            style: TextStyle(fontSize: _fsXS, fontWeight: FontWeight.w700,
                color: Colors.black54, letterSpacing: 0.3)),
      ))),
    );
  }

  Widget _tableRow(int index, Map<String, dynamic> rec,
      OpdProvider prov, List<Map<String, dynamic>> all) {
    final status    = rec['status'] as String? ?? 'Active';
    final isCancelled = status == 'Cancelled';
    final isRefunded  = status == 'Refunded';
    final services  = rec['services'] as List;
    final date      = rec['date'] as DateTime;

    return Column(children: [
      Container(
        color: index.isOdd ? bgColor.withOpacity(0.5) : Colors.white,
        padding: EdgeInsets.symmetric(
            horizontal: _pad, vertical: _sh * 0.013),
        child: Row(children: [
          // Sr #
          Expanded(flex: 1, child: Text('${index + 1}',
              style: TextStyle(fontSize: _fsS, color: Colors.black54))),
          // Receipt No
          Expanded(flex: 2, child: Text(rec['receiptNo'] ?? 'OPD${70000 + index}',
              style: TextStyle(fontSize: _fsS, fontWeight: FontWeight.w600,
                  color: Colors.black87))),
          // MR No
          Expanded(flex: 2, child: Text(rec['mrNo'] ?? '',
              style: TextStyle(fontSize: _fsS, color: Colors.black87))),
          // Date
          Expanded(flex: 2, child: Text(_fmtDate(date),
              style: TextStyle(fontSize: _fsS, color: Colors.black87))),
          // Patient Name
          Expanded(flex: 3, child: Text(
              (rec['patientName'] as String).toUpperCase(),
              style: TextStyle(fontSize: _fsS, fontWeight: FontWeight.bold,
                  color: Colors.black87),
              maxLines: 1, overflow: TextOverflow.ellipsis)),
          // Service
          Expanded(flex: 2, child: Text(
              services.isNotEmpty ? services.first : '',
              style: TextStyle(fontSize: _fsS, color: Colors.black87),
              maxLines: 1, overflow: TextOverflow.ellipsis)),
          // Details
          Expanded(flex: 3, child: Text(
              isCancelled
                  ? 'CANCELLED - ${services.isNotEmpty ? services.first : ''}'
                  : (services.isNotEmpty ? services.join(', ') : ''),
              style: TextStyle(fontSize: _fsS,
                  color: isCancelled ? Colors.red.shade400 : Colors.black54),
              maxLines: 2, overflow: TextOverflow.ellipsis)),
          // Total
          Expanded(flex: 2, child: Text(
              (rec['total'] as double).toStringAsFixed(2),
              style: TextStyle(fontSize: _fsS, fontWeight: FontWeight.bold,
                  color: primary))),
          // Discount
          Expanded(flex: 2, child: Text(
              (rec['discount'] as double).toStringAsFixed(0),
              style: TextStyle(fontSize: _fsS, color: Colors.black54))),
          // Age
          Expanded(flex: 1, child: Text(rec['age'] ?? '-',
              style: TextStyle(fontSize: _fsS, color: Colors.black87))),
          // Gender badge
          Expanded(flex: 1, child: _genderBadge(rec['gender'] ?? 'M')),
          // Refund button
          Expanded(flex: 2, child: _refundBtn(prov, rec, all)),
          // Cancel button
          Expanded(flex: 2, child: _cancelBtn(prov, rec, all, status)),
        ]),
      ),
      Divider(height: _sh * 0.001, color: const Color(0xFFF5F5F5)),
    ]);
  }

  // ════════════════════════════════════
  //  NARROW LIST (mobile cards)
  // ════════════════════════════════════
  Widget _narrowList(List<Map<String, dynamic>> records, OpdProvider prov) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: _pad),
      sliver: SliverList(delegate: SliverChildBuilderDelegate(
            (_, i) => _mobileCard(i, records[i], prov, records),
        childCount: records.length,
      )),
    );
  }

  Widget _mobileCard(int index, Map<String, dynamic> rec,
      OpdProvider prov, List<Map<String, dynamic>> all) {
    final status      = rec['status'] as String? ?? 'Active';
    final isCancelled = status == 'Cancelled';
    final services    = rec['services'] as List;
    final date        = rec['date'] as DateTime;

    return Container(
      margin: EdgeInsets.only(bottom: _sh * 0.012),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_sw * 0.03),
        border: Border(left: BorderSide(
            color: isCancelled ? Colors.red.shade300 : primary, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
            blurRadius: 8, offset: const Offset(0, 2))],
      ),
      padding: EdgeInsets.all(_sw * 0.038),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header row
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text((rec['patientName'] as String).toUpperCase(),
                style: TextStyle(fontSize: _fs, fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            SizedBox(height: _sh * 0.003),
            Text('${rec['receiptNo'] ?? 'OPD${70000+index}'}  •  MR: ${rec['mrNo']}',
                style: TextStyle(fontSize: _fsS, color: Colors.grey.shade500)),
          ])),
          // Status chip
          _statusBadge(status),
        ]),
        SizedBox(height: _sh * 0.01),
        Divider(height: _sh * 0.001, color: const Color(0xFFEEEEEE)),
        SizedBox(height: _sh * 0.01),

        // Info grid
        Wrap(spacing: _sw * 0.04, runSpacing: _sh * 0.007, children: [
          _infoChip(Icons.calendar_today_outlined, _fmtDate(date)),
          _infoChip(Icons.medical_services_outlined,
              services.isNotEmpty ? services.first : '-'),
          _infoChip(Icons.monetization_on_outlined,
              'PKR ${(rec['total'] as double).toStringAsFixed(0)}'),
          _infoChip(Icons.discount_outlined,
              'Disc: ${(rec['discount'] as double).toStringAsFixed(0)}'),
          _infoChip(Icons.person_outline_rounded,
              '${rec['gender'] ?? '-'} / ${rec['age'] ?? '-'}y'),
        ]),
        SizedBox(height: _sh * 0.012),

        // Action buttons
        Row(children: [
          Expanded(child: _refundBtn(prov, rec, all)),
          SizedBox(width: _sp * 0.6),
          Expanded(child: _cancelBtn(prov, rec, all, status)),
        ]),
      ]),
    );
  }

  // ════════════════════════════════════
  //  SHARED ROW WIDGETS
  // ════════════════════════════════════
  Widget _genderBadge(String gender) {
    final isM = gender.toUpperCase().startsWith('M');
    return Container(
      width: _sw * 0.06,
      height: _sw * 0.06,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: (isM ? Colors.blue : Colors.pink).withOpacity(0.12),
        border: Border.all(
            color: isM ? Colors.blue : Colors.pink, width: 1.5),
      ),
      child: Center(child: Text(isM ? 'M' : 'F',
          style: TextStyle(fontSize: _fsXS, fontWeight: FontWeight.bold,
              color: isM ? Colors.blue : Colors.pink))),
    );
  }

  Widget _refundBtn(OpdProvider prov, Map<String, dynamic> rec,
      List<Map<String, dynamic>> all) {
    final status = rec['status'] as String? ?? 'Active';
    final isRefunded = status == 'Refunded';
    final idx = prov.receipts.toList().reversed.toList().indexOf(rec);
    final realIdx = prov.receipts.length - 1 - idx;

    return OutlinedButton(
      onPressed: isRefunded ? null : () => _refundRecord(prov, realIdx),
      style: OutlinedButton.styleFrom(
        foregroundColor: isRefunded ? Colors.grey : primary,
        side: BorderSide(color: isRefunded ? Colors.grey.shade300 : primary),
        padding: EdgeInsets.symmetric(vertical: _sh * 0.009),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_sw * 0.02)),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(isRefunded ? 'Refunded' : 'Refund',
          style: TextStyle(fontSize: _fsS, fontWeight: FontWeight.w600)),
    );
  }

  Widget _cancelBtn(OpdProvider prov, Map<String, dynamic> rec,
      List<Map<String, dynamic>> all, String status) {
    final isCancelled = status == 'Cancelled';
    final idx = prov.receipts.toList().reversed.toList().indexOf(rec);
    final realIdx = prov.receipts.length - 1 - idx;

    return ElevatedButton(
      onPressed: isCancelled ? null : () => _cancelRecord(prov, realIdx),
      style: ElevatedButton.styleFrom(
        backgroundColor: isCancelled ? Colors.grey.shade300 : Colors.red,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey.shade200,
        disabledForegroundColor: Colors.grey,
        padding: EdgeInsets.symmetric(vertical: _sh * 0.009),
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_sw * 0.02)),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(isCancelled ? 'Cancelled' : 'Cancel',
          style: TextStyle(fontSize: _fsS, fontWeight: FontWeight.w600)),
    );
  }

  Widget _statusBadge(String status) {
    Color c; IconData icon;
    switch (status) {
      case 'Cancelled': c = Colors.red;    icon = Icons.cancel_rounded; break;
      case 'Refunded':  c = Colors.orange; icon = Icons.undo_rounded;   break;
      default:          c = primary;       icon = Icons.check_circle_rounded;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: _sw * 0.025, vertical: _sh * 0.004),
      decoration: BoxDecoration(
        color: c.withOpacity(0.1),
        borderRadius: BorderRadius.circular(_sw * 0.05),
        border: Border.all(color: c.withOpacity(0.4)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: c, size: _sw * 0.032),
        SizedBox(width: _sw * 0.01),
        Text(status, style: TextStyle(fontSize: _fsXS,
            color: c, fontWeight: FontWeight.w700)),
      ]),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: _sw * 0.033, color: Colors.grey.shade400),
      SizedBox(width: _sw * 0.01),
      Text(label, style: TextStyle(fontSize: _fsS, color: Colors.black54)),
    ]);
  }

  Widget _emptyState() {
    return Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.inbox_rounded, color: Colors.grey.shade300, size: _sw * 0.18),
        SizedBox(height: _sh * 0.015),
        Text('No records found', style: TextStyle(
            fontSize: _fs * 1.1, color: Colors.grey.shade400,
            fontWeight: FontWeight.w600)),
        SizedBox(height: _sh * 0.006),
        Text('Try adjusting your filters', style: TextStyle(
            fontSize: _fsS, color: Colors.grey.shade400)),
      ],
    ));
  }
}