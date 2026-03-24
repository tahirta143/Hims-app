import 'package:flutter/material.dart';
import '../../custum widgets/drawer/base_scaffold.dart';

// ─── Constants ────────────────────────────────────────────────────────────────
const kTeal = Color(0xFF00B5AD);
const kTealLight = Color(0xFFE0F7F5);
const kBorder = Color(0xFFCCECE9);
const kBg = Color(0xFFF8F9FA);
const kTextDark = Color(0xFF2D3748);
const kTextMid = Color(0xFF718096);
const kWhite = Colors.white;

// ─── Main Screen ─────────────────────────────────────────────────────────────
class PrescriptionScreen extends StatefulWidget {
  const PrescriptionScreen({super.key});

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Prescription',
      drawerIndex: 9,
      showNotificationIcon: true,
      body: _PrescriptionBody(tabController: _tabController),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────
class _PrescriptionBody extends StatelessWidget {
  final TabController tabController;
  const _PrescriptionBody({required this.tabController});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenW = mq.size.width;
    final isTablet = screenW > 600;
    final hPad = screenW * 0.04;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: hPad,
        right: hPad,
        top: mq.size.height * 0.015,
        bottom: mq.size.height * 0.12, // space for bottom nav bar
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Date strip ────────────────────────────────────────────────────
          _DateStrip(isTablet: isTablet),
          SizedBox(height: mq.size.height * 0.014),

          // ── Patient Info ──────────────────────────────────────────────────
          _PatientInfoCard(isTablet: isTablet, screenW: screenW),
          SizedBox(height: mq.size.height * 0.018),

          // ── Tabs ──────────────────────────────────────────────────────────
          _TabSection(tabController: tabController, isTablet: isTablet),
          SizedBox(height: mq.size.height * 0.022),

          // ── Save & Print Button (bottom, full width) ──────────────────────
          _SavePrintButton(isTablet: isTablet),
          SizedBox(height: mq.size.height * 0.01),
        ],
      ),
    );
  }
}

// ─── Date Strip ───────────────────────────────────────────────────────────────
class _DateStrip extends StatelessWidget {
  final bool isTablet;
  const _DateStrip({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: kTealLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today_outlined, color: kTeal, size: 15),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formattedDate(),
                style: TextStyle(
                  color: kTeal,
                  fontWeight: FontWeight.w600,
                  fontSize: isTablet ? 13 : 11,
                ),
              ),
              Text(
                _formattedTime(),
                style: TextStyle(
                  color: kTeal.withOpacity(0.8),
                  fontSize: isTablet ? 11 : 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formattedDate() {
    final now = DateTime.now();
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  String _formattedTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

// ─── Save & Print Button ──────────────────────────────────────────────────────
class _SavePrintButton extends StatelessWidget {
  final bool isTablet;
  const _SavePrintButton({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: isTablet ? 52 : 48,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.save_outlined, size: 18),
        label: Text(
          'Save & Print',
          style: TextStyle(
            fontSize: isTablet ? 15 : 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: kTeal,
          foregroundColor: kWhite,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

// ─── Patient Info Card ────────────────────────────────────────────────────────
class _PatientInfoCard extends StatelessWidget {
  final bool isTablet;
  final double screenW;
  const _PatientInfoCard({required this.isTablet, required this.screenW});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Row(
              children: [
                const Icon(Icons.person_outline, color: kTeal, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Patient Information',
                  style: TextStyle(
                    color: kTextDark,
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 14 : 13,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: kBorder, height: 1),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: isTablet ? _tabletGrid() : _mobileGrid(),
          ),
          const SizedBox(height: 14),
          // Vitals
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: _VitalsSection(isTablet: isTablet),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget _mobileGrid() {
    return Column(
      children: [
        _FieldRow(fields: [
          _FieldData('MR No.*', 'Enter MR no.', required: true),
          _FieldData('Patient Name', ''),
        ]),
        const SizedBox(height: 10),
        _FieldRow(fields: [
          _FieldData('Age / Gender', ''),
          _FieldData('Phone', ''),
        ]),
        const SizedBox(height: 10),
        _FieldRow(fields: [
          _FieldData('Father / Husband', ''),
          _FieldData('Address', ''),
        ]),
        const SizedBox(height: 10),
        _FieldRow(fields: [
          _FieldData('Consultant', 'Enter doctor name'),
          _FieldData('Receipt ID', 'Receipt ID'),
        ]),
      ],
    );
  }

  Widget _tabletGrid() {
    return Column(
      children: [
        Row(children: [
          Expanded(child: _InputField(label: 'MR No.*', hint: 'Enter MR no.', required: true)),
          const SizedBox(width: 12),
          Expanded(child: _InputField(label: 'Patient Name', hint: '')),
          const SizedBox(width: 12),
          Expanded(child: _InputField(label: 'Age / Gender', hint: '')),
          const SizedBox(width: 12),
          Expanded(child: _InputField(label: 'Phone', hint: '')),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _InputField(label: 'Father / Husband', hint: '')),
          const SizedBox(width: 12),
          Expanded(child: _InputField(label: 'Address', hint: '')),
          const SizedBox(width: 12),
          Expanded(child: _InputField(label: 'Consultant', hint: 'Enter doctor name')),
          const SizedBox(width: 12),
          Expanded(child: _InputField(label: 'Receipt ID', hint: 'Receipt ID')),
        ]),
      ],
    );
  }
}

// ─── Field Row (2 columns) ────────────────────────────────────────────────────
class _FieldData {
  final String label;
  final String hint;
  final bool required;
  const _FieldData(this.label, this.hint, {this.required = false});
}

class _FieldRow extends StatelessWidget {
  final List<_FieldData> fields;
  const _FieldRow({required this.fields});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: fields.asMap().entries.map((e) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: e.key > 0 ? 10 : 0),
            child: _InputField(
              label: e.value.label,
              hint: e.value.hint,
              required: e.value.required,
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Input Field ──────────────────────────────────────────────────────────────
class _InputField extends StatelessWidget {
  final String label;
  final String hint;
  final bool required;
  final int maxLines;

  const _InputField({
    required this.label,
    required this.hint,
    this.required = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final labelSize = isTablet ? 12.0 : 11.0;
    final inputSize = isTablet ? 13.0 : 12.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              color: kTextMid,
              fontSize: labelSize,
              fontWeight: FontWeight.w500,
              fontFamily: 'Roboto',
            ),
            children: required
                ? const [TextSpan(text: ' *', style: TextStyle(color: Colors.red))]
                : [],
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          maxLines: maxLines,
          style: TextStyle(fontSize: inputSize, color: kTextDark),
          decoration: InputDecoration(
            hintText: hint.isNotEmpty ? hint : null,
            hintStyle: TextStyle(
              color: kTextMid.withOpacity(0.55),
              fontSize: inputSize,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: maxLines > 1 ? 10 : 9,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: const BorderSide(color: kBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(7),
              borderSide: const BorderSide(color: kTeal, width: 1.5),
            ),
            filled: true,
            fillColor: kWhite,
            isDense: true,
          ),
        ),
      ],
    );
  }
}

// ─── Vitals Section ───────────────────────────────────────────────────────────
class _VitalsSection extends StatelessWidget {
  final bool isTablet;
  const _VitalsSection({required this.isTablet});

  static const _vitals = [
    ['Temp', '°F'],
    ['B.P.', '120/80'],
    ['Pulse', 'bpm'],
    ['Weight', 'kg'],
    ['Height', 'ft'],
    ['Blood', 'A+'],
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'VITALS',
            style: TextStyle(
              color: kTextMid,
              fontSize: isTablet ? 11 : 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          // Always 3 columns on mobile, 6 on tablet
          if (isTablet)
            Row(
              children: _vitals.asMap().entries.map((e) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: e.key > 0 ? 8 : 0),
                    child: _VitalField(label: e.value[0], hint: e.value[1]),
                  ),
                );
              }).toList(),
            )
          else ...[
            Row(
              children: _vitals.sublist(0, 3).asMap().entries.map((e) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: e.key > 0 ? 8 : 0),
                    child: _VitalField(label: e.value[0], hint: e.value[1]),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Row(
              children: _vitals.sublist(3).asMap().entries.map((e) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: e.key > 0 ? 8 : 0),
                    child: _VitalField(label: e.value[0], hint: e.value[1]),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _VitalField extends StatelessWidget {
  final String label;
  final String hint;
  const _VitalField({required this.label, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: kTextMid,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 3),
        TextField(
          style: const TextStyle(fontSize: 12, color: kTextDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: kTextMid.withOpacity(0.65),
              fontSize: 11,
            ),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: kBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: kTeal, width: 1.5),
            ),
            filled: true,
            fillColor: kWhite,
            isDense: true,
          ),
        ),
      ],
    );
  }
}

// ─── Tab Section ─────────────────────────────────────────────────────────────
class _TabSection extends StatelessWidget {
  final TabController tabController;
  final bool isTablet;
  const _TabSection({required this.tabController, required this.isTablet});

  static const _tabs = [
    [Icons.notes_outlined, 'Notes'],
    [Icons.medical_information_outlined, 'Diagnosis'],
    [Icons.science_outlined, 'Investigations'],
    [Icons.medication_outlined, 'Medicines'],
    [Icons.assignment_outlined, 'Instructions'],
    [Icons.history_outlined, 'Old Visits'],
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Tab bar
          Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: kBorder)),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: TabBar(
              controller: tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: kTeal,
              unselectedLabelColor: kTextMid,
              indicatorColor: kTeal,
              indicatorWeight: 2.5,
              dividerColor: Colors.transparent,
              labelStyle: TextStyle(
                fontSize: isTablet ? 13 : 11,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: isTablet ? 13 : 11,
                fontWeight: FontWeight.w400,
              ),
              padding: EdgeInsets.zero,
              tabs: _tabs
                  .map(
                    (t) => Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(t[0] as IconData,
                          size: isTablet ? 16 : 14),
                      const SizedBox(width: 5),
                      Text(t[1] as String),
                    ],
                  ),
                ),
              )
                  .toList(),
            ),
          ),

          // Tab views — intrinsic height via IndexedStack
          _TabViewBody(tabController: tabController, isTablet: isTablet),
        ],
      ),
    );
  }
}

// ─── Tab View Body ────────────────────────────────────────────────────────────
class _TabViewBody extends StatefulWidget {
  final TabController tabController;
  final bool isTablet;
  const _TabViewBody(
      {required this.tabController, required this.isTablet});

  @override
  State<_TabViewBody> createState() => _TabViewBodyState();
}

class _TabViewBodyState extends State<_TabViewBody> {
  @override
  void initState() {
    super.initState();
    widget.tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!widget.tabController.indexIsChanging) setState(() {});
  }

  @override
  void dispose() {
    widget.tabController.removeListener(_onTabChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.tabController.index,
      children: [
        _NotesTab(isTablet: widget.isTablet),
        _PlaceholderTab(label: 'Diagnosis'),
        _PlaceholderTab(label: 'Investigations'),
        _PlaceholderTab(label: 'Medicines'),
        _PlaceholderTab(label: 'Instructions'),
        _PlaceholderTab(label: 'Old Visits'),
      ],
    );
  }
}

// ─── Notes Tab ────────────────────────────────────────────────────────────────
class _NotesTab extends StatelessWidget {
  final bool isTablet;
  const _NotesTab({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final gap = mq.size.height * 0.016;

    return Padding(
      padding: EdgeInsets.all(mq.size.width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TextAreaField(label: 'History / Examination', hint: 'Enter history...'),
          SizedBox(height: gap),
          _TextAreaField(label: 'Treatment', hint: 'Treatment plan...'),
          SizedBox(height: gap),
          _TextAreaField(label: 'Consultant Notes', hint: 'Notes...'),
          SizedBox(height: gap),
          _TextAreaField(label: 'Remarks', hint: 'Remarks...'),
          SizedBox(height: gap),
          _ReferToField(isTablet: isTablet),
        ],
      ),
    );
  }
}

class _TextAreaField extends StatelessWidget {
  final String label;
  final String hint;
  const _TextAreaField({required this.label, required this.hint});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final fontSize = isTablet ? 13.0 : 12.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: kTextDark,
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          maxLines: 3,
          minLines: 3,
          style: TextStyle(fontSize: fontSize, color: kTextDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: kTextMid.withOpacity(0.55),
              fontSize: fontSize,
            ),
            contentPadding: const EdgeInsets.all(12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: kTeal, width: 1.5),
            ),
            filled: true,
            fillColor: kWhite,
          ),
        ),
      ],
    );
  }
}

class _ReferToField extends StatelessWidget {
  final bool isTablet;
  const _ReferToField({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final fontSize = isTablet ? 13.0 : 12.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Refer To',
          style: TextStyle(
            color: kTextDark,
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: TextField(
            style: TextStyle(fontSize: fontSize, color: kTextDark),
            decoration: InputDecoration(
              hintText: 'Refer to...',
              hintStyle: TextStyle(
                color: kTextMid.withOpacity(0.55),
                fontSize: fontSize,
              ),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: kBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: kTeal, width: 1.5),
              ),
              filled: true,
              fillColor: kWhite,
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Placeholder Tab ──────────────────────────────────────────────────────────
class _PlaceholderTab extends StatelessWidget {
  final String label;
  const _PlaceholderTab({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.construction_outlined,
              color: kTeal.withOpacity(0.35),
              size: 36,
            ),
            const SizedBox(height: 10),
            Text(
              '$label section',
              style: const TextStyle(color: kTextMid, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}