import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../custum widgets/drawer/base_scaffold.dart';
import '../../providers/opd/consultation_provider/cunsultation_provider.dart';

class ConsultationScreen extends StatefulWidget {
  const ConsultationScreen({super.key});
  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  static const Color primary = Color(0xFF00B5AD);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _todayLabel() {
    final now = DateTime.now();
    const months = ['January','February','March','April','May','June',
      'July','August','September','October','November','December'];
    const wdays = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    return '${wdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ConsultationProvider>(context);
    final sw   = MediaQuery.of(context).size.width;
    final sh   = MediaQuery.of(context).size.height;
    final tp   = MediaQuery.of(context).padding.top;

    return BaseScaffold(
      scaffoldKey: _scaffoldKey,
      title: 'Consultations',
      drawerIndex: 1,
      showAppBar: false,
      body: Column(
        children: [
          // ── STICKY HEADER — outside scroll, never moves ──
          _buildHeader(sw, sh, tp),

          // ── SCROLLABLE BODY ──
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary cards
                  _buildSummary(prov, sw, sh),

                  // Section heading
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        sw * 0.04, sh * 0.018, sw * 0.04, sh * 0.012),
                    child: Row(children: [
                      Icon(Icons.people_alt_rounded,
                          color: primary, size: sw * 0.045),
                      SizedBox(width: sw * 0.02),
                      Text('Our Consultants',
                          style: TextStyle(fontSize: sw * 0.042,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87)),
                    ]),
                  ),

                  // Doctor grid — 2 per row, column layout cards
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: sw * 0.04),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: prov.doctors.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: sw * 0.03,
                        mainAxisSpacing:  sw * 0.03,
                        // Column layout is taller — lower ratio = taller cells
                        childAspectRatio: sw >= 600 ? 0.72
                            : sw >= 400 ? 0.68 : 0.65,
                      ),
                      itemBuilder: (_, i) => _DoctorCard(
                        doctor: prov.doctors[i],
                        availableSlots: prov.availableSlotsForDoctor(
                            prov.doctors[i].name, DateTime.now()),
                        onTap: () => _showDialog(
                            context, prov, prov.doctors[i], sw, sh),
                      ),
                    ),
                  ),

                  SizedBox(height: sh * 0.04),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════
  //  STICKY HEADER
  // ════════════════════════════════════════
  Widget _buildHeader(double sw, double sh, double tp) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00B5AD), Color(0xFF00897B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.only(
          top: tp + sh * 0.016,
          left: sw * 0.04,
          right: sw * 0.04,
          bottom: sh * 0.022),
      child: Row(children: [
        GestureDetector(
          onTap: () => _scaffoldKey.currentState?.openDrawer(),
          child: Container(
            padding: EdgeInsets.all(sw * 0.022),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(sw * 0.025),
            ),
            child: Icon(Icons.menu_rounded, color: Colors.white, size: sw * 0.05),
          ),
        ),
        SizedBox(width: sw * 0.03),
        Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Appointments',
              style: TextStyle(color: Colors.white, fontSize: sw * 0.055,
                  fontWeight: FontWeight.bold, letterSpacing: 0.2)),
          SizedBox(height: sh * 0.003),
          Text(_todayLabel(),
              style: TextStyle(color: Colors.white70, fontSize: sw * 0.028,
                  fontWeight: FontWeight.w500)),
        ])),
        Container(
          padding: EdgeInsets.all(sw * 0.022),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(sw * 0.025),
          ),
          child: Icon(Icons.notifications_outlined,
              color: Colors.white, size: sw * 0.05),
        ),
      ]),
    );
  }

  // ════════════════════════════════════════
  //  SUMMARY CARDS
  // ════════════════════════════════════════
  Widget _buildSummary(ConsultationProvider prov, double sw, double sh) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
          horizontal: sw * 0.04, vertical: sh * 0.018),
      child: Row(children: [
        _SummaryCard(label: 'Total\nConsultations',
            value: prov.totalConsultations.toString(),
            icon: Icons.receipt_long_rounded, color: primary, sw: sw),
        SizedBox(width: sw * 0.025),
        _SummaryCard(label: 'Upcoming\nAppointments',
            value: prov.upcomingAppointments.toString(),
            icon: Icons.schedule_rounded,
            color: const Color(0xFF1E88E5), sw: sw),
        SizedBox(width: sw * 0.025),
        _SummaryCard(label: 'Completed\nAppointments',
            value: prov.completedAppointments.toString(),
            icon: Icons.check_circle_rounded,
            color: const Color(0xFF43A047), sw: sw),
      ]),
    );
  }

  void _showDialog(BuildContext context, ConsultationProvider prov,
      DoctorInfo doctor, double sw, double sh) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => ChangeNotifierProvider.value(
        value: prov,
        child: _AppointmentDialog(doctor: doctor),
      ),
    );
  }
}

// ════════════════════════════════════════════════
//  SUMMARY CARD
// ════════════════════════════════════════════════
class _SummaryCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  final double sw;
  const _SummaryCard({required this.label, required this.value,
    required this.icon, required this.color, required this.sw});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(sw * 0.03),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(sw * 0.035),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: EdgeInsets.all(sw * 0.018),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(sw * 0.02),
            ),
            child: Icon(icon, color: color, size: sw * 0.038),
          ),
          SizedBox(height: sw * 0.018),
          Text(value, style: TextStyle(fontSize: sw * 0.052,
              fontWeight: FontWeight.bold, color: color)),
          SizedBox(height: sw * 0.004),
          Text(label, style: TextStyle(fontSize: sw * 0.023,
              color: color.withOpacity(0.75),
              fontWeight: FontWeight.w600, height: 1.3),
              maxLines: 2),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════
//  DOCTOR CARD — column layout, NO book button
// ════════════════════════════════════════════════
class _DoctorCard extends StatelessWidget {
  final DoctorInfo doctor;
  final int availableSlots;
  final VoidCallback onTap;

  const _DoctorCard({
    required this.doctor,
    required this.availableSlots,
    required this.onTap,
  });

  String _initials(String name) {
    final parts = name.replaceAll('Dr. ', '').split(' ');
    return parts.length >= 2 ? '${parts[0][0]}${parts[1][0]}' : parts[0][0];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final cw   = constraints.maxWidth;
      final pad  = cw * 0.06;
      final avSz = cw * 0.30; // avatar diameter

      return GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(cw * 0.06),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07),
                blurRadius: 14, offset: const Offset(0, 4))],
          ),
          child: Column(children: [

            // ── Colored top band: avatar + name + specialty ──
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(pad, pad, pad, pad * 0.8),
              decoration: BoxDecoration(
                color: doctor.avatarColor.withOpacity(0.09),
                borderRadius: BorderRadius.only(
                  topLeft:  Radius.circular(cw * 0.06),
                  topRight: Radius.circular(cw * 0.06),
                ),
              ),
              child: Column(children: [
                // Avatar circle
                Container(
                  width: avSz, height: avSz,
                  decoration: BoxDecoration(
                    color: doctor.avatarColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [BoxShadow(
                        color: doctor.avatarColor.withOpacity(0.4),
                        blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Center(
                    child: Text(_initials(doctor.name),
                        style: TextStyle(color: Colors.white,
                            fontSize: avSz * 0.32,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(height: cw * 0.03),

                // Doctor name
                Text(doctor.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: cw * 0.073,
                        fontWeight: FontWeight.bold, color: Colors.black87),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                SizedBox(height: cw * 0.022),

                // Specialty badge
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: cw * 0.04, vertical: cw * 0.018),
                  decoration: BoxDecoration(
                    color: doctor.avatarColor,
                    borderRadius: BorderRadius.circular(cw * 0.07),
                  ),
                  child: Text(doctor.specialty,
                      style: TextStyle(fontSize: cw * 0.054,
                          fontWeight: FontWeight.w700, color: Colors.white),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ]),
            ),

            // ── Details section ──
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: pad * 0.9, vertical: pad * 0.5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _detailRow(Icons.local_hospital_rounded,
                        doctor.hospital, cw),
                    _detailRow(Icons.payments_rounded,
                        'PKR ${doctor.consultationFee}', cw),
                    _detailRow(Icons.repeat_rounded,
                        'F/U: PKR ${doctor.followUpCharges}', cw),
                    _detailRow(Icons.access_time_rounded,
                        doctor.timings, cw),

                    // Stats
                    Divider(height: cw * 0.04, color: Colors.grey.shade100),
                    Row(children: [
                      Expanded(child: _miniStat(
                          doctor.totalAppointments.toString(),
                          'Total', doctor.avatarColor, cw)),
                      Container(width: 1, height: cw * 0.1,
                          color: Colors.grey.shade200),
                      Expanded(child: _miniStat(
                          availableSlots.toString(),
                          'Free', const Color(0xFF43A047), cw)),
                    ]),
                  ],
                ),
              ),
            ),
          ]),
        ),
      );
    });
  }

  Widget _detailRow(IconData icon, String text, double cw) {
    return Row(children: [
      Icon(icon, size: cw * 0.055, color: doctor.avatarColor.withOpacity(0.7)),
      SizedBox(width: cw * 0.025),
      Expanded(child: Text(text,
          style: TextStyle(fontSize: cw * 0.052,
              color: Colors.black54, fontWeight: FontWeight.w500),
          maxLines: 1, overflow: TextOverflow.ellipsis)),
    ]);
  }

  Widget _miniStat(String val, String label, Color color, double cw) {
    return Column(children: [
      Text(val, style: TextStyle(fontSize: cw * 0.065,
          fontWeight: FontWeight.bold, color: color)),
      Text(label, style: TextStyle(fontSize: cw * 0.048,
          color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
    ]);
  }
}

// ════════════════════════════════════════════════
//  APPOINTMENT DIALOG
// ════════════════════════════════════════════════
class _AppointmentDialog extends StatefulWidget {
  final DoctorInfo doctor;
  const _AppointmentDialog({required this.doctor});
  @override
  State<_AppointmentDialog> createState() => _AppointmentDialogState();
}

class _AppointmentDialogState extends State<_AppointmentDialog> {
  static const Color primary = Color(0xFF00B5AD);

  DateTime _selectedDate  = DateTime.now();
  String?  _selectedSlot;
  String   _selectedType  = 'In-Person';
  bool _isFirstVisit    = true;
  bool _patientFound    = false;
  bool _patientNotFound = false;

  final _mrCtrl      = TextEditingController();
  final _nameCtrl    = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  @override
  void dispose() {
    _mrCtrl.dispose(); _nameCtrl.dispose();
    _contactCtrl.dispose(); _addressCtrl.dispose();
    super.dispose();
  }

  void _onMrChanged(String val) {
    final digits    = val.replaceAll(RegExp(r'[^0-9]'), '');
    final formatted = digits.isEmpty
        ? '' : int.parse(digits).toString().padLeft(5, '0');
    if (_mrCtrl.text != formatted) {
      _mrCtrl.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length));
    }
    if (formatted.isEmpty) {
      setState(() { _patientFound = false; _patientNotFound = false; });
      _nameCtrl.clear(); _contactCtrl.clear(); _addressCtrl.clear();
      return;
    }
    final prov    = Provider.of<ConsultationProvider>(context, listen: false);
    final patient = prov.lookupPatient(formatted);
    if (patient != null) {
      setState(() { _patientFound = true; _patientNotFound = false;
      _isFirstVisit = patient['isFirstVisit'] as bool; });
      _nameCtrl.text    = patient['name']    as String;
      _contactCtrl.text = patient['contact'] as String;
      _addressCtrl.text = patient['address'] as String;
    } else {
      setState(() { _patientFound = false;
      _patientNotFound = formatted.length >= 3; });
      _nameCtrl.clear(); _contactCtrl.clear(); _addressCtrl.clear();
    }
  }

  Future<void> _pickDate() async {
    DateTime tempMonth = DateTime(_selectedDate.year, _selectedDate.month);
    DateTime tempDate  = _selectedDate;
    final picked = await showDialog<DateTime>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, sd) {
        final firstDay     = DateTime(tempMonth.year, tempMonth.month, 1);
        final daysInMonth  = DateTime(tempMonth.year, tempMonth.month + 1, 0).day;
        final startWeekday = firstDay.weekday % 7;
        const dayNames = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
        final today = DateTime.now();

        final cells = <Widget>[];
        for (int i = 0; i < startWeekday; i++) cells.add(const SizedBox());
        for (int d = 1; d <= daysInMonth; d++) {
          final date    = DateTime(tempMonth.year, tempMonth.month, d);
          final dayName = dayNames[date.weekday % 7];
          final isAvail = widget.doctor.availableDays.contains(dayName);
          final isPast  = date.isBefore(DateTime(today.year, today.month, today.day));
          final isSel   = date.year == tempDate.year &&
              date.month == tempDate.month && date.day == tempDate.day;
          final isToday = date.year == today.year &&
              date.month == today.month && date.day == today.day;
          cells.add(GestureDetector(
            onTap: isAvail && !isPast ? () => sd(() => tempDate = date) : null,
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isSel ? primary
                    : isToday ? primary.withOpacity(0.15)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Center(child: Text('$d', style: TextStyle(
                fontSize: 13,
                fontWeight: isSel || isToday
                    ? FontWeight.bold : FontWeight.normal,
                color: isSel ? Colors.white
                    : isPast || !isAvail
                    ? Colors.grey.shade300 : Colors.black87,
              ))),
            ),
          ));
        }
        const months = ['January','February','March','April','May','June',
          'July','August','September','October','November','December'];

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                const Icon(Icons.calendar_month_rounded, color: primary, size: 22),
                const SizedBox(width: 8),
                const Text('Select Date',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Spacer(),
                GestureDetector(onTap: () => Navigator.pop(ctx),
                    child: const Icon(Icons.close_rounded, color: Colors.grey)),
              ]),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                GestureDetector(
                  onTap: () => sd(() => tempMonth =
                      DateTime(tempMonth.year, tempMonth.month - 1)),
                  child: Container(padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.chevron_left_rounded, color: primary)),
                ),
                Text('${months[tempMonth.month - 1]} ${tempMonth.year}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                GestureDetector(
                  onTap: () => sd(() => tempMonth =
                      DateTime(tempMonth.year, tempMonth.month + 1)),
                  child: Container(padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.chevron_right_rounded, color: primary)),
                ),
              ]),
              const SizedBox(height: 10),
              Row(children: ['Sun','Mon','Tue','Wed','Thu','Fri','Sat']
                  .map((d) => Expanded(child: Center(child: Text(d,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                      color: Colors.grey.shade500)))))
                  .toList()),
              const SizedBox(height: 4),
              GridView.count(crossAxisCount: 7, shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1, children: cells),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, tempDate),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: primary, foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13)),
                  child: const Text('Confirm Date',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ]),
          ),
        );
      }),
    );
    if (picked != null) {
      setState(() { _selectedDate = picked; _selectedSlot = null; });
    }
  }

  void _submit() {
    if (_mrCtrl.text.isEmpty)      { _snack('Please enter MR No',       err: true); return; }
    if (_nameCtrl.text.isEmpty)    { _snack('Please enter patient name', err: true); return; }
    if (_contactCtrl.text.isEmpty) { _snack('Please enter contact no',   err: true); return; }
    if (_selectedSlot == null)     { _snack('Please select a time slot', err: true); return; }

    final prov = Provider.of<ConsultationProvider>(context, listen: false);
    prov.addAppointment(ConsultationAppointment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      consultantName:   widget.doctor.name,
      specialty:        widget.doctor.specialty,
      consultationFee:  widget.doctor.consultationFee,
      followUpCharges:  widget.doctor.followUpCharges,
      availableDays:    widget.doctor.availableDays,
      timings:          widget.doctor.timings,
      hospital:         widget.doctor.hospital,
      mrNo:             _mrCtrl.text,
      patientName:      _nameCtrl.text.trim(),
      contactNo:        _contactCtrl.text.trim(),
      address:          _addressCtrl.text.trim(),
      isFirstVisit:     _isFirstVisit,
      appointmentDate:  _selectedDate,
      timeSlot:         _selectedSlot!,
      type:             _selectedType,
      status:           'Upcoming',
    ));
    Navigator.pop(context);
    _snack('Appointment booked!', err: false);
  }

  void _snack(String msg, {required bool err}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: err ? Colors.red.shade400 : primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  String _initials(String name) {
    final parts = name.replaceAll('Dr. ', '').split(' ');
    return parts.length >= 2 ? '${parts[0][0]}${parts[1][0]}' : parts[0][0];
  }

  String _dateLabel(DateTime d) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'];
    const wdays  = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return '${wdays[d.weekday - 1]}, ${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final sw   = MediaQuery.of(context).size.width;
    final sh   = MediaQuery.of(context).size.height;
    final prov = Provider.of<ConsultationProvider>(context);
    final allSlots        = prov.generateTimeSlots(widget.doctor.timings);
    final booked          = prov.bookedSlots(_selectedDate, widget.doctor.name);
    final dayAppointments = prov.appointmentsForDoctorOnDate(
        widget.doctor.name, _selectedDate);

    final double fs   = sw < 360 ? 11.5 : 13.0;
    final double fsS  = sw < 360 ? 10.0 : 11.5;
    final double fsXS = sw < 360 ?  9.0 : 10.5;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
          horizontal: sw >= 720 ? sw * 0.08 : sw * 0.025,
          vertical: sh * 0.025),
      child: Container(
        constraints: BoxConstraints(maxHeight: sh * 0.92),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F4F8),
          borderRadius: BorderRadius.circular(sw * 0.05),
        ),
        child: Column(children: [

          // Dialog header
          Container(
            padding: EdgeInsets.all(sw * 0.04),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF00B5AD), Color(0xFF00897B)]),
              borderRadius: BorderRadius.only(
                topLeft:  Radius.circular(sw * 0.05),
                topRight: Radius.circular(sw * 0.05),
              ),
            ),
            child: Row(children: [
              Icon(Icons.event_note_rounded,
                  color: Colors.white, size: sw * 0.048),
              SizedBox(width: sw * 0.02),
              Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Appointment Schedule',
                    style: TextStyle(color: Colors.white, fontSize: sw * 0.042,
                        fontWeight: FontWeight.bold)),
                Text('Book with ${widget.doctor.name}',
                    style: TextStyle(color: Colors.white70, fontSize: fsS)),
              ])),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.all(sw * 0.018),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle),
                  child: Icon(Icons.close_rounded,
                      color: Colors.white, size: sw * 0.042),
                ),
              ),
            ]),
          ),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(sw * 0.035),
              child: Column(children: [

                // DATE PICKER ROW
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: sw * 0.04, vertical: sh * 0.013),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(sw * 0.03),
                      border: Border.all(color: primary.withOpacity(0.3)),
                      boxShadow: [BoxShadow(
                          color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                    ),
                    child: Row(children: [
                      Container(
                        padding: EdgeInsets.all(sw * 0.02),
                        decoration: BoxDecoration(
                            color: primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(sw * 0.02)),
                        child: Icon(Icons.calendar_today_rounded,
                            color: primary, size: sw * 0.042),
                      ),
                      SizedBox(width: sw * 0.025),
                      Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Appointment Date', style: TextStyle(
                                fontSize: fsXS, color: Colors.grey.shade500,
                                fontWeight: FontWeight.w600)),
                            Text(_dateLabel(_selectedDate), style: TextStyle(
                                fontSize: fs, fontWeight: FontWeight.bold,
                                color: Colors.black87)),
                          ])),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: sw * 0.025, vertical: sh * 0.006),
                        decoration: BoxDecoration(color: primary,
                            borderRadius: BorderRadius.circular(sw * 0.02)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.edit_calendar_rounded,
                              color: Colors.white, size: sw * 0.032),
                          SizedBox(width: sw * 0.008),
                          Text('Change', style: TextStyle(
                              color: Colors.white, fontSize: fsXS,
                              fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    ]),
                  ),
                ),
                SizedBox(height: sw * 0.03),
                // DOCTOR INFO CARD
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(sw * 0.03),
                    border: Border(left: BorderSide(
                        color: widget.doctor.avatarColor, width: 4)),
                    boxShadow: [BoxShadow(
                        color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                  ),
                  padding: EdgeInsets.all(sw * 0.035),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(widget.doctor.name,
                              style: TextStyle(fontSize: sw * 0.038,
                                  fontWeight: FontWeight.bold, color: Colors.black87)),
                          SizedBox(height: sh * 0.004),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: sw * 0.02, vertical: sh * 0.003),
                            decoration: BoxDecoration(
                              color: widget.doctor.avatarColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(sw * 0.04),
                            ),
                            child: Text(widget.doctor.specialty,
                                style: TextStyle(fontSize: fsS,
                                    color: widget.doctor.avatarColor,
                                    fontWeight: FontWeight.w700)),
                          ),
                          // SizedBox(height: sh * 0.01),
                          // _infoRow(Icons.local_hospital_rounded,
                          //     widget.doctor.hospital, fsS, sw),
                          // _infoRow(Icons.payments_rounded,
                          //     'Fee: PKR ${widget.doctor.consultationFee}', fsS, sw),
                          // _infoRow(Icons.repeat_rounded,
                          //     'Follow-up: PKR ${widget.doctor.followUpCharges}', fsS, sw),
                          // _infoRow(Icons.access_time_rounded,
                          //     widget.doctor.timings, fsS, sw),
                          SizedBox(height: sh * 0.008),
                          Wrap(spacing: sw * 0.015, runSpacing: sh * 0.005,
                              children: widget.doctor.availableDays.map((d) =>
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: sw * 0.022, vertical: sh * 0.003),
                                    decoration: BoxDecoration(
                                      color: widget.doctor.avatarColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(sw * 0.04),
                                    ),
                                    child: Text(d, style: TextStyle(
                                        fontSize: fsXS, fontWeight: FontWeight.w700,
                                        color: widget.doctor.avatarColor)),
                                  )).toList()),
                        ])),
                        SizedBox(width: sw * 0.025),
                        Container(
                          width: sw * 0.16, height: sw * 0.16,
                          decoration: BoxDecoration(
                            color: widget.doctor.avatarColor,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(
                                color: widget.doctor.avatarColor.withOpacity(0.35),
                                blurRadius: 12, offset: const Offset(0, 4))],
                          ),
                          child: Column(mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person_rounded,
                                    color: Colors.white, size: sw * 0.065),
                                Text(_initials(widget.doctor.name),
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: sw * 0.022,
                                        fontWeight: FontWeight.bold)),
                              ]),
                        ),
                      ]),
                ),
                SizedBox(height: sw * 0.03),

                // TIME SLOT DROPDOWN
                // TIME SLOT DROPDOWN - EXTRA SMALL WITH VERTICAL SCROLL AND MIN WIDTH
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(sw * 0.018),
                    boxShadow: [BoxShadow(
                        color: Colors.black.withOpacity(0.03), blurRadius: 4)],
                  ),
                  padding: EdgeInsets.all(sw * 0.02),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Icon(Icons.schedule_rounded, color: primary, size: sw * 0.03),
                      SizedBox(width: sw * 0.008),
                      Text('Select Time Slots', style: TextStyle(
                          fontSize: fs * 0.85, fontWeight: FontWeight.w600,
                          color: Colors.black87)),
                      const Spacer(),
                      if (allSlots.isNotEmpty) ...[
                        // AVAILABLE BADGE - HIGHLIGHTED
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: sw * 0.025, vertical: sw * 0.012),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF43A047),
                                const Color(0xFF2E7D32),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(sw * 0.025),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF43A047).withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_rounded,
                                  color: Colors.white, size: sw * 0.022),
                              SizedBox(width: sw * 0.006),
                              Text('${allSlots.length - booked.length} Available',
                                  style: TextStyle(
                                      fontSize: fsXS * 0.85,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.3)),
                            ],
                          ),
                        ),
                        SizedBox(width: sw * 0.008),
                        // BOOKED BADGE - HIGHLIGHTED
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: sw * 0.025, vertical: sw * 0.012),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.red.shade600,
                                Colors.red.shade800,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(sw * 0.025),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.shade600.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.event_busy_rounded,
                                  color: Colors.white, size: sw * 0.022),
                              SizedBox(width: sw * 0.006),
                              Text('${booked.length} Booked',
                                  style: TextStyle(
                                      fontSize: fsXS * 0.85,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.3)),
                            ],
                          ),
                        ),
                      ],
                    ]),
                    SizedBox(height: sh * 0.006),

                    // SMALL DROPDOWN WITH VERTICAL SCROLL AND MIN WIDTH
                    if (allSlots.isEmpty)
                      Center(child: Padding(
                        padding: EdgeInsets.symmetric(vertical: sh * 0.006),
                        child: Text('No slots available',
                            style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: fsS * 0.9,
                                fontWeight: FontWeight.w500)),
                      ))
                    else
                      Container(
                        constraints: BoxConstraints(
                          minWidth: sw * 0.25,
                        ),
                        height: sh * 0.04, // Slightly increased height for better touch target
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(sw * 0.014),
                          border: Border.all(
                              color: _selectedSlot != null
                                  ? primary : Colors.grey.shade400,
                              width: _selectedSlot != null ? 1.5 : 1),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: sw * 0.015),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedSlot,
                            isExpanded: true,
                            hint: Row(children: [
                              Icon(Icons.schedule_rounded,
                                  color: Colors.grey.shade500, size: sw * 0.026),
                              SizedBox(width: sw * 0.008),
                              Text('Choose time', style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: fs * 0.8,
                                  fontWeight: FontWeight.w500)),
                            ]),
                            icon: Container(
                              padding: EdgeInsets.all(sw * 0.004),
                              decoration: BoxDecoration(
                                color: _selectedSlot != null
                                    ? primary.withOpacity(0.1)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(sw * 0.02),
                              ),
                              child: Icon(Icons.keyboard_arrow_down_rounded,
                                  color: _selectedSlot != null ? primary : Colors.grey.shade500,
                                  size: sw * 0.03),
                            ),

                            dropdownColor: Colors.white,
                            menuMaxHeight: sh * 0.3,
                            borderRadius: BorderRadius.circular(sw * 0.02),
                            menuWidth: sw * 0.45,

                            items: allSlots
                                .where((slot) => !booked.contains(slot))
                                .map((slot) {
                              return DropdownMenuItem<String>(
                                value: slot,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: sw * 0.02,
                                      vertical: sh * 0.006),
                                  constraints: BoxConstraints(
                                    minWidth: sw * 0.4,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(sw * 0.01),
                                  ),
                                  child: Row(children: [
                                    Container(
                                      padding: EdgeInsets.all(sw * 0.006),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF43A047).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(sw * 0.01),
                                      ),
                                      child: Icon(Icons.access_time_rounded,
                                          size: sw * 0.022,
                                          color: const Color(0xFF43A047)),
                                    ),
                                    SizedBox(width: sw * 0.015),
                                    Expanded(
                                      child: Text(slot,
                                          style: TextStyle(
                                              fontSize: fs * 0.85,
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w500)),
                                    ),
                                    // Container(
                                    //   padding: EdgeInsets.symmetric(
                                    //       horizontal: sw * 0.018,
                                    //       vertical: sh * 0.003),
                                    //   decoration: BoxDecoration(
                                    //     gradient: LinearGradient(
                                    //       colors: [
                                    //         const Color(0xFF43A047),
                                    //         const Color(0xFF2E7D32),
                                    //       ],
                                    //     ),
                                    //     borderRadius: BorderRadius.circular(sw * 0.02),
                                    //     boxShadow: [
                                    //       BoxShadow(
                                    //         color: const Color(0xFF43A047).withOpacity(0.2),
                                    //         blurRadius: 4,
                                    //         offset: const Offset(0, 1),
                                    //       ),
                                    //     ],
                                    //   ),
                                    //   child: Text('Free',
                                    //       style: TextStyle(
                                    //           fontSize: fsXS * 0.7,
                                    //           color: Colors.white,
                                    //           fontWeight: FontWeight.w700)),
                                    // ),
                                  ]),
                                ),
                              );
                            }).toList(),

                            onChanged: (v) {
                              if (v != null) setState(() => _selectedSlot = v);
                            },
                          ),
                        ),
                      ),

                    if (_selectedSlot != null) ...[
                      SizedBox(height: sh * 0.006),
                      Container(
                        constraints: BoxConstraints(
                          minWidth: sw * 0.25,
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: sw * 0.02, vertical: sh * 0.004),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primary.withOpacity(0.1),
                              primary.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(sw * 0.016),
                          border: Border.all(color: primary.withOpacity(0.3)),
                        ),
                        child: Row(children: [
                          Container(
                            padding: EdgeInsets.all(sw * 0.004),
                            decoration: BoxDecoration(
                              color: primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.check_rounded,
                                color: Colors.white, size: sw * 0.016),
                          ),
                          SizedBox(width: sw * 0.01),
                          Expanded(
                            child: Text('$_selectedSlot',
                                style: TextStyle(
                                    fontSize: fs * 0.85,
                                    color: primary,
                                    fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1),
                          ),
                        ]),
                      ),
                    ],
                  ]),
                ),
                SizedBox(height: sw * 0.03),

                // PATIENT INFORMATION
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(sw * 0.03),
                    boxShadow: [BoxShadow(
                        color: Colors.black.withOpacity(0.04), blurRadius: 8)],
                  ),
                  padding: EdgeInsets.all(sw * 0.035),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Icon(Icons.person_pin_rounded,
                          color: primary, size: sw * 0.04),
                      SizedBox(width: sw * 0.015),
                      Text('Patient Information', style: TextStyle(
                          fontSize: fs, fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                    ]),
                    SizedBox(height: sw * 0.03),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    SizedBox(height: sw * 0.03),

                    _lbl('MR No', fsS, sw),
                    TextField(
                      controller: _mrCtrl,
                      keyboardType: TextInputType.number,
                      style: TextStyle(fontSize: fs, fontWeight: FontWeight.bold),
                      decoration: _dec('e.g. 00001', sw, fs).copyWith(
                        suffixIcon: _patientFound
                            ? const Icon(Icons.check_circle_rounded,
                            color: Colors.green, size: 20)
                            : _patientNotFound
                            ? Icon(Icons.search_off_rounded,
                            color: Colors.orange.shade400, size: 20)
                            : Icon(Icons.badge_rounded,
                            color: Colors.grey.shade400, size: 20),
                        filled: true,
                        fillColor: _patientFound
                            ? Colors.green.withOpacity(0.04) : Colors.white,
                      ),
                      onChanged: _onMrChanged,
                    ),
                    if (_patientFound) _chipMsg(Icons.check_circle_rounded,
                        'Patient found — fields auto-filled', Colors.green, fsXS, sw),
                    if (_patientNotFound) _chipMsg(Icons.info_rounded,
                        'Not found — fill manually', Colors.orange, fsXS, sw),
                    SizedBox(height: sw * 0.025),

                    _lbl('Patient Name *', fsS, sw),
                    _tf(_nameCtrl, 'Enter full name', fs, sw,
                        filled: _patientFound),
                    SizedBox(height: sw * 0.025),

                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _lbl('Contact No *', fsS, sw),
                        _tf(_contactCtrl, '03XX-XXXXXXX', fs, sw,
                            type: TextInputType.phone, filled: _patientFound),
                      ])),
                      SizedBox(width: sw * 0.025),
                      Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _lbl('Address', fsS, sw),
                        _tf(_addressCtrl, 'Enter address', fs, sw,
                            filled: _patientFound),
                      ])),
                    ]),
                    SizedBox(height: sw * 0.025),

                    Row(children: [
                      Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, children: [
                      ])),
                      SizedBox(width: sw * 0.025),
                      Column(children: [
                        _lbl('First Visit', fsS, sw),
                        Transform.scale(
                          scale: 0.9,
                          child: Switch(
                              value: _isFirstVisit,
                              onChanged: (v) => setState(() => _isFirstVisit = v),
                              activeColor: primary),
                        ),
                      ]),
                    ]),
                  ]),
                ),
                SizedBox(height: sw * 0.04),

                // ACTION BUTTONS
                Row(children: [
                  Expanded(child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade600,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: EdgeInsets.symmetric(vertical: sh * 0.015),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(sw * 0.025)),
                    ),
                    icon: Icon(Icons.close_rounded, size: sw * 0.04),
                    label: Text('Cancel', style: TextStyle(
                        fontSize: fs, fontWeight: FontWeight.w600)),
                  )),
                  SizedBox(width: sw * 0.025),
                  Expanded(flex: 2, child: ElevatedButton.icon(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: sh * 0.015),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(sw * 0.025)),
                    ),
                    icon: Icon(Icons.check_rounded, size: sw * 0.04),
                    label: Text('Book Appointment',
                        style: TextStyle(fontSize: fs,
                            fontWeight: FontWeight.bold)),
                  )),
                ]),
                SizedBox(height: sw * 0.02),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, double fsS, double sw) {
    return Padding(
      padding: EdgeInsets.only(bottom: sw * 0.012),
      child: Row(children: [
        Icon(icon, size: sw * 0.032, color: Colors.grey.shade500),
        SizedBox(width: sw * 0.015),
        Flexible(child: Text(text,
            style: TextStyle(fontSize: fsS, color: Colors.black54))),
      ]),
    );
  }

  Widget _slotBadge(String label, Color color, double fsXS, double sw) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: sw * 0.028, vertical: sw * 0.020),
      decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(sw * 0.05)),
      child: Text(label, style: TextStyle(
          fontSize: fsXS, fontWeight: FontWeight.w700, color: color)),
    );
  }

  Widget _chipMsg(IconData icon, String msg, Color color,
      double fsXS, double sw) {
    return Padding(
      padding: EdgeInsets.only(top: sw * 0.012),
      child: Row(children: [
        Icon(icon, color: color, size: 13),
        SizedBox(width: sw * 0.012),
        Flexible(child: Text(msg, style: TextStyle(
            fontSize: fsXS, color: color, fontWeight: FontWeight.w600))),
      ]),
    );
  }

  Widget _lbl(String text, double fsS, double sw) {
    return Padding(
      padding: EdgeInsets.only(bottom: sw * 0.012),
      child: Text(text, style: TextStyle(
          fontSize: fsS, fontWeight: FontWeight.w600, color: Colors.black54)),
    );
  }

  Widget _tf(TextEditingController ctrl, String hint, double fs, double sw,
      {TextInputType type = TextInputType.text, bool filled = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      style: TextStyle(fontSize: fs, color: Colors.black87),
      decoration: _dec(hint, sw, fs).copyWith(
        filled: true,
        fillColor: filled ? Colors.green.withOpacity(0.04) : Colors.white,
      ),
    );
  }

  InputDecoration _dec(String hint, double sw, double fs) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: fs * 0.95),
    filled: true, fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(
        horizontal: sw * 0.03, vertical: sw * 0.032),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(sw * 0.022),
        borderSide: BorderSide(color: Colors.grey.shade300)),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(sw * 0.022),
        borderSide: BorderSide(color: Colors.grey.shade300)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(sw * 0.022),
        borderSide: const BorderSide(color: primary, width: 1.5)),
  );
}