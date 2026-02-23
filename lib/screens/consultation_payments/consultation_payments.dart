import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../custum widgets/drawer/base_scaffold.dart';
import '../../providers/opd/opd_reciepts/opd_reciepts.dart';

class ConsultantPaymentsScreen extends StatefulWidget {
  const ConsultantPaymentsScreen({super.key});

  @override
  State<ConsultantPaymentsScreen> createState() => _ConsultantPaymentsScreenState();
}

class _ConsultantPaymentsScreenState extends State<ConsultantPaymentsScreen> {
  static const Color primary = Color(0xFF00B5AD);
  static const Color bgColor = Color(0xFFF0F4F8);
  static const Color cardBg = Colors.white;

  // Add GlobalKey for drawer access (same as OPD Receipt)
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Date filters
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();
  String _searchQuery = '';
  String _statusFilter = 'All'; // All, Paid, Unpaid

  // Doctor share percentage
  static const double DOCTOR_SHARE_PERCENTAGE = 20.0;

  // MediaQuery values — set every build (same as OPD Receipt)
  late double _sw, _sh, _tp, _bp;
  late bool _isWide;

  double get _pad => _sw * 0.04;
  double get _sp => _sw * 0.025;
  double get _fs => _sw < 360 ? 11.5 : 13.0;
  double get _fsS => _sw < 360 ? 10.0 : 11.5;
  double get _fsL => _sw < 360 ? 13.5 : 15.5;

  // Number formatter for PKR
  String _formatPKR(double amount) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    // Get MediaQuery values (same as OPD Receipt)
    final mq = MediaQuery.of(context);
    _sw = mq.size.width;
    _sh = mq.size.height;
    _tp = mq.padding.top;
    _bp = mq.padding.bottom;
    _isWide = _sw >= 900;

    return BaseScaffold(
      scaffoldKey: _scaffoldKey, // Pass the key to BaseScaffold
      title: 'Consultant Payments',
      drawerIndex: 6, // Match your drawer index
      showAppBar: false, // We'll use custom header (same as OPD Receipt)
      body: Consumer<OpdProvider>(
        builder: (context, provider, child) {
          final payments = _generatePaymentsFromReceipts(provider);

          return Column(
            children: [
              _buildHeader(), // Custom header with menu button
              Expanded(
                child: _isWide
                    ? _buildWideLayout(payments)
                    : _buildNarrowLayout(payments),
              ),
            ],
          );
        },
      ),
    );
  }

  List<ConsultantPayment> _generatePaymentsFromReceipts(OpdProvider provider) {
    Map<String, ConsultantPayment> paymentMap = {};

    for (var receipt in provider.receipts) {
      // Check for consultation services
      final services = receipt['services'] as List? ?? [];
      final isConsultation = services.any((service) {
        final serviceStr = service.toString().toLowerCase();
        return serviceStr.contains('consultation') ||
            serviceStr.contains('consult') ||
            serviceStr == 'consultation';
      });

      final details = receipt['details'] as String? ?? '';
      final hasDoctor = details.contains('Dr.');

      if (receipt['status'] == 'Active' && (isConsultation || hasDoctor)) {
        final doctorName = _extractDoctorName(details);
        final totalAmount = (receipt['total'] as num?)?.toDouble() ?? 0.0;
        final doctorShare = totalAmount * (DOCTOR_SHARE_PERCENTAGE / 100);
        final hospitalRevenue = totalAmount - doctorShare;

        if (!paymentMap.containsKey(doctorName)) {
          paymentMap[doctorName] = ConsultantPayment(
            doctorName: doctorName,
            appointments: 0,
            totalAmount: 0,
            doctorShare: 0,
            hospitalRevenue: 0,
            status: 'Unpaid',
            date: receipt['date'] as DateTime? ?? DateTime.now(),
            details: [],
          );
        }

        final payment = paymentMap[doctorName]!;
        payment.appointments += 1;
        payment.totalAmount += totalAmount;
        payment.doctorShare += doctorShare;
        payment.hospitalRevenue += hospitalRevenue;

        payment.details.add(PaymentDetail(
          time: receipt['date'] as DateTime? ?? DateTime.now(),
          doctor: doctorName,
          patientId: receipt['mrNo'] as String? ?? '',
          patientName: receipt['patientName'] as String? ?? '',
          service: details,
          amount: doctorShare,
          totalBill: totalAmount,
          sharePercentage: DOCTOR_SHARE_PERCENTAGE,
          status: 'ACTIVE',
        ));
      }
    }

    return paymentMap.values.toList();
  }

  String _extractDoctorName(String details) {
    if (details.contains('Dr.')) {
      final regex = RegExp(r'Dr\.\s*([^(]*)');
      final match = regex.firstMatch(details);
      if (match != null) {
        return 'Dr. ${match.group(1)?.trim() ?? ''}';
      }
    }

    if (details.contains('Tahir')) return 'Dr. Tahir';
    if (details.contains('Sara')) return 'Dr. Sara';
    if (details.contains('Raza')) return 'Dr. Raza';
    if (details.contains('Nida')) return 'Dr. Nida';

    return 'Dr. Tahir';
  }

  // Custom header with menu button (same pattern as OPD Receipt)
  Widget _buildHeader() {
    final now = DateTime.now();

    return Container(
      color: cardBg,
      padding: EdgeInsets.only(
        top: _tp + _sh * 0.012,
        bottom: _sh * 0.014,
        left: _pad,
        right: _pad,
      ),
      child: Column(
        children: [
          // Top row with menu button (exactly like OPD Receipt)
          Row(
            children: [
              // Menu button - opens drawer (same as OPD Receipt)
              GestureDetector(
                onTap: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
                child: Container(
                  padding: EdgeInsets.all(_sw * 0.022),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(_sw * 0.022),
                  ),
                  child: Icon(Icons.menu_rounded, color: primary, size: _sw * 0.04),
                ),
              ),
              SizedBox(width: _sp),
              // Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Consultant Payments',
                      style: TextStyle(
                        fontSize: _fsL,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Doctor share tracking and management',
                      style: TextStyle(
                        fontSize: _fsS,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              // Date pill (like OPD Receipt)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: _sw * 0.022,
                  vertical: _sh * 0.007,
                ),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(_sw * 0.025),
                  border: Border.all(color: primary.withOpacity(0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      color: primary,
                      size: _sw * 0.033,
                    ),
                    SizedBox(width: _sw * 0.012),
                    Text(
                      DateFormat('MMM dd, yyyy').format(now),
                      style: TextStyle(
                        fontSize: _fsS,
                        color: primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: _sh * 0.02),

          // Stats cards (horizontally scrollable)
          Consumer<OpdProvider>(
            builder: (context, provider, child) {
              final payments = _generatePaymentsFromReceipts(provider);
              return _buildStatsRow(payments);
            },
          ),
          SizedBox(height: _sh * 0.02),

          // Filters row
          _buildFiltersRow(),
        ],
      ),
    );
  }

  Widget _buildStatsRow(List<ConsultantPayment> payments) {
    final totalDoctors = payments.length;
    final totalAmount = payments.fold<double>(0, (sum, p) => sum + p.totalAmount);
    final totalDoctorShare = payments.fold<double>(0, (sum, p) => sum + p.doctorShare);
    final totalHospitalRevenue = payments.fold<double>(0, (sum, p) => sum + p.hospitalRevenue);
    final totalAppointments = payments.fold<int>(0, (sum, p) => sum + p.appointments);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildStatCard(
            icon: Icons.people_rounded,
            label: 'DOCTORS',
            value: totalDoctors.toString(),
            color: Colors.blue,
          ),
          SizedBox(width: _sp),
          _buildStatCard(
            icon: Icons.receipt_rounded,
            label: 'TOTAL AMOUNT',
            value: 'PKR ${_formatPKR(totalAmount)}',
            color: Colors.purple,
          ),
          SizedBox(width: _sp),
          _buildStatCard(
            icon: Icons.person_rounded,
            label: 'DOCTOR SHARE',
            value: 'PKR ${_formatPKR(totalDoctorShare)}',
            color: Colors.green,
          ),
          SizedBox(width: _sp),
          _buildStatCard(
            icon: Icons.local_hospital_rounded,
            label: 'HOSPITAL REVENUE',
            value: 'PKR ${_formatPKR(totalHospitalRevenue)}',
            color: Colors.orange,
          ),
          if (_isWide) ...[
            SizedBox(width: _sp),
            _buildStatCard(
              icon: Icons.calendar_today_rounded,
              label: 'APPOINTMENTS',
              value: totalAppointments.toString(),
              color: Colors.teal,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      width: _isWide ? _sw * 0.18 : _sw * 0.4,
      padding: EdgeInsets.symmetric(horizontal: _sw * 0.02, vertical: _sh * 0.012),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(_sw * 0.02),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(_sw * 0.01),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(_sw * 0.015),
                ),
                child: Icon(icon, color: color, size: _sw * 0.03),
              ),
              SizedBox(width: _sw * 0.01),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: _fsS * 0.9,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: _sh * 0.008),
          Text(
            value,
            style: TextStyle(
              fontSize: _fsL * 0.9,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Container(
            width: _isWide ? _sw * 0.4 : _sw * 0.6,
            padding: EdgeInsets.symmetric(horizontal: _sw * 0.02),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(_sw * 0.02),
            ),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: TextStyle(fontSize: _fs),
              decoration: InputDecoration(
                hintText: 'Search by doctor or patient...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: _fs * 0.93),
                prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400, size: _sw * 0.05),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: _sh * 0.01),
              ),
            ),
          ),
          SizedBox(width: _sp),
          _buildDatePicker('From', _fromDate, (date) {
            setState(() => _fromDate = date);
          }),
          SizedBox(width: _sp),
          _buildDatePicker('To', _toDate, (date) {
            setState(() => _toDate = date);
          }),
          SizedBox(width: _sp),
          Container(
            padding: EdgeInsets.symmetric(horizontal: _sw * 0.02),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(_sw * 0.02),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _statusFilter,
                isDense: true,
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade600),
                style: TextStyle(fontSize: _fs, color: Colors.black87),
                items: ['All', 'Paid', 'Unpaid'].map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _statusFilter = v!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime date, Function(DateTime) onSelected) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                primaryColor: primary,
                colorScheme: const ColorScheme.light(primary: primary),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) onSelected(picked);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: _sw * 0.02, vertical: _sh * 0.01),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(_sw * 0.02),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today_rounded, color: primary, size: _sw * 0.03),
            SizedBox(width: _sw * 0.01),
            Text(
              DateFormat('MM/dd/yyyy').format(date),
              style: TextStyle(fontSize: _fs, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWideLayout(List<ConsultantPayment> payments) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(_pad, 0, _pad, _bp),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(height: _sh * 0.02),
              _buildDoctorBreakdown(payments),
              SizedBox(height: _sh * 0.03),
              _buildRawRecords(payments),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(List<ConsultantPayment> payments) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(_pad, 0, _pad, _bp),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(height: _sh * 0.02),
              _buildDoctorBreakdown(payments),
              SizedBox(height: _sh * 0.03),
              _buildRawRecords(payments),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorBreakdown(List<ConsultantPayment> payments) {
    final filteredPayments = _filterPayments(payments);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.pie_chart_rounded, color: primary, size: _sw * 0.048),
            SizedBox(width: _sw * 0.02),
            Text(
              'Doctor Breakdown',
              style: TextStyle(
                fontSize: _fsL,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: _sh * 0.015),

        // Table with horizontal scroll - Entire table scrolls together
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(_sw * 0.02),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_sw * 0.02),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.1),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: _sw * 0.025, vertical: _sh * 0.015),
                    child: Row(
                      children: [
                        SizedBox(
                          width: _sw * 0.25,
                          child: Text('DOCTOR',
                            style: TextStyle(
                              fontSize: _fsS,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: _sw * 0.2,
                          child: Text('APPOINTMENTS',
                            style: TextStyle(
                              fontSize: _fsS,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: _sw * 0.2,
                          child: Text('TOTAL',
                            style: TextStyle(
                              fontSize: _fsS,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: _sw * 0.2,
                          child: Text('DOCTOR SHARE',
                            style: TextStyle(
                              fontSize: _fsS,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: _sw * 0.2,
                          child: Text('HOSPITAL',
                            style: TextStyle(
                              fontSize: _fsS,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: _sw * 0.2,
                          child: Text('ACTION',
                            style: TextStyle(
                              fontSize: _fsS,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Rows
                  if (filteredPayments.isEmpty)
                    SizedBox(
                      width: _sw * 1.5,
                      child: _buildEmptyState('No doctor payments found'),
                    )
                  else
                    ...filteredPayments.map((payment) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: _sw * 0.025, vertical: _sh * 0.02),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: _sw * 0.25,
                              child: Text(
                                payment.doctorName,
                                style: TextStyle(
                                  fontSize: _fs,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(
                              width: _sw * 0.2,
                              child: Text(
                                payment.appointments.toString(),
                                style: TextStyle(fontSize: _fs, color: Colors.black87),
                              ),
                            ),
                            SizedBox(
                              width: _sw * 0.2,
                              child: Text(
                                'PKR ${_formatPKR(payment.totalAmount)}',
                                style: TextStyle(fontSize: _fs, color: Colors.black87),
                              ),
                            ),
                            SizedBox(
                              width: _sw * 0.2,
                              child: Text(
                                'PKR ${_formatPKR(payment.doctorShare)}',
                                style: TextStyle(fontSize: _fs, color: Colors.black87),
                              ),
                            ),
                            SizedBox(
                              width: _sw * 0.2,
                              child: Text(
                                'PKR ${_formatPKR(payment.hospitalRevenue)}',
                                style: TextStyle(fontSize: _fs, color: Colors.black87),
                              ),
                            ),
                            SizedBox(
                              width: _sw * 0.2,
                              child: _buildStatusButton(payment),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRawRecords(List<ConsultantPayment> payments) {
    final allDetails = payments.expand((p) => p.details).toList();
    final filteredDetails = _filterDetails(allDetails);
    final today = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.history_rounded, color: primary, size: _sw * 0.048),
            SizedBox(width: _sw * 0.02),
            Text(
              'Raw Share Records (${DateFormat('dd MMM yyyy').format(today)})',
              style: TextStyle(
                fontSize: _fsL,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: _sh * 0.015),

        // Table with horizontal scroll - Entire table scrolls together
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(_sw * 0.02),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_sw * 0.02),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: _sw * 0.025, vertical: _sh * 0.015),
                    decoration: BoxDecoration(
                      color: bgColor,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: _sw * 0.25,
                          child: Text('TIME',
                            style: TextStyle(
                              fontSize: _fsS,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: _sw * 0.2,
                          child: Text('DOCTOR',
                            style: TextStyle(
                              fontSize: _fsS,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: _sw * 0.2,
                          child: Text('PATIENT',
                            style: TextStyle(
                              fontSize: _fsS,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: _sw * 0.25,
                          child: Text('SERVICE',
                            style: TextStyle(
                              fontSize: _fsS,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: _sw * 0.2,
                          child: Text('AMOUNT',
                            style: TextStyle(
                              fontSize: _fsS,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: _sw * 0.15,
                          child: Text('STATUS',
                            style: TextStyle(
                              fontSize: _fsS,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Records
                  if (filteredDetails.isEmpty)
                    SizedBox(
                      width: _sw * 1.5,
                      child: _buildEmptyState('No share records found'),
                    )
                  else
                    ...filteredDetails.map((detail) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: _sw * 0.025, vertical: _sh * 0.015),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: _sw * 0.25,
                                  child: Text(
                                    DateFormat('dd MMM yyyy HH:mm').format(detail.time),
                                    style: TextStyle(fontSize: _fs, color: Colors.black87),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(
                                  width: _sw * 0.2,
                                  child: Text(
                                    detail.doctor,
                                    style: TextStyle(fontSize: _fs, color: Colors.black87),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(
                                  width: _sw * 0.2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        detail.patientName,
                                        style: TextStyle(fontSize: _fs, color: Colors.black87),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        detail.patientId,
                                        style: TextStyle(fontSize: _fsS * 0.9, color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: _sw * 0.25,
                                  child: Text(
                                    detail.service,
                                    style: TextStyle(fontSize: _fs, color: Colors.black87),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(
                                  width: _sw * 0.2,
                                  child: Text(
                                    'PKR ${_formatPKR(detail.amount)}',
                                    style: TextStyle(
                                      fontSize: _fs,
                                      color: primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: _sw * 0.15,
                                  child: _buildStatusChip(detail.status),
                                ),
                              ],
                            ),
                            SizedBox(height: _sh * 0.005),
                            // Share info row - aligned with content
                            Padding(
                              padding: EdgeInsets.only(left: _sw * 0.25),
                              child: Text(
                                'SHARE: ${detail.sharePercentage.toStringAsFixed(2)}% | Total: ${_formatPKR(detail.totalBill)}',
                                style: TextStyle(
                                  fontSize: _fsS * 0.9,
                                  color: Colors.grey.shade600,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(_pad * 2),
        child: Column(
          children: [
            Icon(Icons.inbox_rounded, color: Colors.grey.shade300, size: _sw * 0.1),
            SizedBox(height: _sh * 0.02),
            Text(
              message,
              style: TextStyle(color: Colors.grey.shade400, fontSize: _fs),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(ConsultantPayment payment) {
    final isPaid = payment.status == 'Paid';
    return GestureDetector(
      onTap: () {
        if (!isPaid) {
          _showMarkPaidDialog(payment);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: _sw * 0.02, vertical: _sh * 0.008),
        decoration: BoxDecoration(
          color: isPaid ? Colors.green.withOpacity(0.1) : primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(_sw * 0.015),
          border: Border.all(
            color: isPaid ? Colors.green : primary,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            isPaid ? 'Paid' : 'Mark Paid',
            style: TextStyle(
              fontSize: _fsS,
              fontWeight: FontWeight.w600,
              color: isPaid ? Colors.green : primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'ACTIVE':
        color = Colors.green;
        break;
      case 'PENDING':
        color = Colors.orange;
        break;
      case 'CANCELLED':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: _sw * 0.02, vertical: _sh * 0.005),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(_sw * 0.015),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: _fsS * 0.9,
          fontWeight: FontWeight.w600,
          color: color,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  List<ConsultantPayment> _filterPayments(List<ConsultantPayment> payments) {
    return payments.where((payment) {
      if (_statusFilter != 'All' && payment.status != _statusFilter) {
        return false;
      }

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesDoctor = payment.doctorName.toLowerCase().contains(query);
        final matchesPatient = payment.details.any((d) =>
        d.patientName.toLowerCase().contains(query) ||
            d.patientId.contains(query));
        if (!matchesDoctor && !matchesPatient) return false;
      }

      return true;
    }).toList();
  }

  List<PaymentDetail> _filterDetails(List<PaymentDetail> details) {
    return details.where((detail) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return detail.doctor.toLowerCase().contains(query) ||
            detail.patientName.toLowerCase().contains(query) ||
            detail.patientId.contains(query);
      }
      return true;
    }).toList();
  }

  void _showMarkPaidDialog(ConsultantPayment payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_sw * 0.04)),
        title: Row(
          children: [
            Icon(Icons.payment_rounded, color: primary, size: _sw * 0.06),
            SizedBox(width: _sp),
            Text(
              'Mark Payment as Paid',
              style: TextStyle(fontSize: _fsL, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Doctor: ${payment.doctorName}',
              style: TextStyle(fontSize: _fs, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: _sh * 0.01),
            Text(
              'Amount: PKR ${_formatPKR(payment.doctorShare)}',
              style: TextStyle(fontSize: _fs, color: primary, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: _sh * 0.02),
            Text(
              'This will mark all pending payments for this doctor as paid. Continue?',
              style: TextStyle(fontSize: _fs, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                payment.status = 'Paid';
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Payment marked as paid successfully'),
                  backgroundColor: primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_sw * 0.02)),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class ConsultantPayment {
  String doctorName;
  int appointments;
  double totalAmount;
  double doctorShare;
  double hospitalRevenue;
  String status;
  DateTime date;
  List<PaymentDetail> details;

  ConsultantPayment({
    required this.doctorName,
    required this.appointments,
    required this.totalAmount,
    required this.doctorShare,
    required this.hospitalRevenue,
    required this.status,
    required this.date,
    required this.details,
  });
}

class PaymentDetail {
  final DateTime time;
  final String doctor;
  final String patientId;
  final String patientName;
  final String service;
  final double amount;
  final double totalBill;
  final double sharePercentage;
  final String status;

  PaymentDetail({
    required this.time,
    required this.doctor,
    required this.patientId,
    required this.patientName,
    required this.service,
    required this.amount,
    required this.totalBill,
    required this.sharePercentage,
    required this.status,
  });
}