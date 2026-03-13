import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../custum widgets/drawer/base_scaffold.dart';
import '../../models/consultation_model/appointment_model.dart';
import '../../models/consultation_model/doctor_model.dart';
import '../../providers/opd/consultation_provider/cunsultation_provider.dart';
import '../../providers/mr_provider/mr_provider.dart';
import '../../core/utils/date_formatter.dart';
import 'widgets/appointment_dialog.dart';

const Color _teal = Color(0xFF00B5AD);
const Color _textDark = Color(0xFF1A202C);

class ConsultationScreen extends StatefulWidget {
  const ConsultationScreen({super.key});
  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _todayLabel() {
    return AppDateFormatter.formatWithDay(DateTime.now());
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
            child: prov.isLoading
                ? const Center(child: CircularProgressIndicator())
                : prov.errorMessage != null
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: sw * 0.15, color: Colors.red.shade300),
                  SizedBox(height: sh * 0.02),
                  Text(prov.errorMessage!,
                      style: TextStyle(
                          fontSize: sw * 0.04,
                          color: Colors.red.shade400)),
                  SizedBox(height: sh * 0.02),
                  ElevatedButton.icon(
                    onPressed: () => prov.loadDoctors(),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _teal,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
                : SingleChildScrollView(
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
                          color: _teal, size: sw * 0.045),
                      SizedBox(width: sw * 0.02),
                      Text('Our Consultants',
                          style: TextStyle(
                              fontSize: sw * 0.042,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87)),
                    ]),
                  ),

                  // Doctor grid — 2 per row, column layout cards
                  prov.doctors.isEmpty
                      ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(sw * 0.1),
                      child: Text('No doctors available',
                          style: TextStyle(
                              fontSize: sw * 0.04,
                              color: Colors.grey.shade500)),
                    ),
                  )
                      : Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: sw * 0.04),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics:
                      const NeverScrollableScrollPhysics(),
                      itemCount: prov.doctors.length,
                      gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: sw * 0.03,
                        mainAxisSpacing: sw * 0.03,
                        // Column layout is taller — lower ratio = taller cells
                        childAspectRatio: sw >= 600
                            ? 0.72
                            : sw >= 400
                            ? 0.68
                            : 0.65,
                      ),
                      itemBuilder: (_, i) {
                        final doctor = prov.doctors[i];
                        final today = DateTime.now();
                        return _DoctorCard(
                          doctor: doctor,
                          bookedSlots: prov.bookedSlots(today, doctor.name).length,
                          availableSlots: prov.availableSlotsForDoctor(doctor.name, today),
                          onTap: () => _showDialog(context, prov, doctor, sw, sh),
                        );
                      },
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
        color: Color(0xFF00B5AD)
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
            icon: Icons.receipt_long_rounded, color: _teal, sw: sw),
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
      builder: (_) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: prov),
          ChangeNotifierProvider.value(value: context.read<MrProvider>()),
        ],
        child: AppointmentDialog(
          doctor: doctor,
          availableSlots: prov.availableSlotsForDoctor(doctor.name, DateTime.now()),
        ),
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
  final int bookedSlots;
  final int availableSlots;
  final VoidCallback onTap;

  const _DoctorCard({
    required this.doctor,
    required this.bookedSlots,
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
      String _formatTo12Hour(String timeRange) {
        try {
          final parts = timeRange.split('-');

          String convert(String time) {
            final t = time.trim().split(':');
            int hour = int.parse(t[0]);
            String minute = t[1];

            String period = hour >= 12 ? 'PM' : 'AM';
            hour = hour % 12;
            if (hour == 0) hour = 12;

            return '$hour:$minute $period';
          }

          return '${convert(parts[0])} - ${convert(parts[1])}';
        } catch (e) {
          return timeRange;
        }
      }
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
                        doctor.hospital, cw, doctor),
                    _detailRow(Icons.payments_rounded,
                        'PKR ${doctor.consultationFee}', cw, doctor),
                    // _detailRow(Icons.repeat_rounded,
                    //     'F/U: PKR ${doctor.followUpCharges}', cw),
                    _detailRow(
                      Icons.access_time_rounded,
                      _formatTo12Hour(doctor.timings),
                      cw,
                      doctor,
                    ),

                    // Stats
                    Divider(height: cw * 0.04, color: Colors.grey.shade100),
                    Row(children: [
                      Expanded(child: _miniStat(
                          bookedSlots.toString(),
                          'Booked', _textDark, cw)),
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

  Widget _detailRow(IconData icon, String text, double cw, DoctorInfo doctor) {
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