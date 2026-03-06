import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../custum widgets/drawer/base_scaffold.dart';
import '../../providers/consultant_payments_provider/consultant_payments_provider.dart';
import '../../models/consultant_payment_model/consultant_payment_model.dart';

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

  //MediaQuery values — set every build (same as OPD Receipt)
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
      body: Consumer<ConsultantPaymentsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: primary));
          }

          return Column(
            children: [
              _buildHeader(), // Custom header with menu button only
              // Filters and Stats now outside header
              _buildFiltersAndStats(provider),
              Expanded(
                child: _isWide
                    ? _buildWideLayout(provider)
                    : _buildNarrowLayout(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    String? paid;
    if (_statusFilter == 'Paid') paid = 'Paid';
    if (_statusFilter == 'Unpaid') paid = 'Unpaid';

    Provider.of<ConsultantPaymentsProvider>(context, listen: false).loadDashboardData(
      fromDate: _fromDate,
      toDate: _toDate,
      paid: paid,
    );
  }

  List<DoctorBreakdownModel> _getFilteredBreakdown(List<DoctorBreakdownModel> list) {
    return list.where((d) =>
    d.doctorName.toLowerCase().contains(_searchQuery.toLowerCase()) &&
        (_statusFilter == 'All' || d.status.toLowerCase() == _statusFilter.toLowerCase())
    ).toList();
  }

  List<PayoutRecordModel> _getFilteredRecords(List<PayoutRecordModel> list) {
    return list.where((r) =>
    (r.doctorName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        r.patientName.toLowerCase().contains(_searchQuery.toLowerCase()))
    ).toList();
  }

  Widget _buildWideLayout(ConsultantPaymentsProvider prov) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(_pad, 0, _pad, _bp),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(height: _sh * 0.02),
              _buildDoctorBreakdown(prov.breakdown),
              SizedBox(height: _sh * 0.03),
              _buildRawRecords(prov.records),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(ConsultantPaymentsProvider prov) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(_pad, 0, _pad, _bp),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(height: _sh * 0.02),
              _buildDoctorBreakdown(prov.breakdown),
              SizedBox(height: _sh * 0.03),
              _buildRawRecords(prov.records),
            ]),
          ),
        ),
      ],
    );
  }

  // New widget combining filters and stats outside header
  Widget _buildFiltersAndStats(ConsultantPaymentsProvider provider) {
    return Container(
      color: bgColor, // Light background to separate from header
      padding: EdgeInsets.fromLTRB(_pad, _sh * 0.015, _pad, _sh * 0.01),
      child: Column(
        children: [
          // Stats cards
          _buildStatsRow(provider.analytics),
          SizedBox(height: _sh * 0.015),
          // Filters row
          _buildFiltersRow(),
        ],
      ),
    );
  }

  // Custom header with ONLY menu button and title - NO stats or filters
  Widget _buildHeader() {
    final now = DateTime.now();

    return Container(
      color: primary, // Teal background
      padding: EdgeInsets.only(
        top: _tp + _sh * 0.012,
        bottom: _sh * 0.014,
        left: _pad,
        right: _pad,
      ),
      child: Row(
        children: [
          // Menu button - opens drawer
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
              child: Icon(Icons.menu_rounded, color: Colors.white, size: _sw * 0.04),
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
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Doctor share tracking and management',
                  style: TextStyle(
                    fontSize: _fsS,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          // Date pill
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: _sw * 0.022,
              vertical: _sh * 0.007,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(_sw * 0.025),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: Colors.white,
                  size: _sw * 0.033,
                ),
                SizedBox(width: _sw * 0.012),
                Text(
                  DateFormat('MMM dd, yyyy').format(now),
                  style: TextStyle(
                    fontSize: _fsS,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(ConsultantPaymentAnalytics? analytics) {
    if (analytics == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildStatCard(
            icon: Icons.people_rounded,
            label: 'DOCTORS',
            value: analytics.totalDoctors.toString(),
            color: Colors.blue,
          ),
          SizedBox(width: _sp),
          _buildStatCard(
            icon: Icons.receipt_rounded,
            label: 'TOTAL AMOUNT',
            value: 'PKR ${_formatPKR(analytics.totalAmount)}',
            color: Colors.purple,
          ),
          SizedBox(width: _sp),
          _buildStatCard(
            icon: Icons.person_rounded,
            label: 'DOCTOR SHARE',
            value: 'PKR ${_formatPKR(analytics.totalDoctorShare)}',
            color: Colors.green,
          ),
          SizedBox(width: _sp),
          _buildStatCard(
            icon: Icons.local_hospital_rounded,
            label: 'HOSPITAL REVENUE',
            value: 'PKR ${_formatPKR(analytics.totalHospitalRevenue)}',
            color: Colors.orange,
          ),
          if (_isWide) ...[
            SizedBox(width: _sp),
            _buildStatCard(
              icon: Icons.calendar_today_rounded,
              label: 'APPOINTMENTS',
              value: analytics.totalAppointments.toString(),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(_sw * 0.02),
              border: Border.all(color: Colors.grey.shade200),
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
            setState(() => _fromDate = date); _loadData();
          }),
          SizedBox(width: _sp),
          _buildDatePicker('To', _toDate, (date) {
            setState(() => _toDate = date); _loadData();
          }),
          SizedBox(width: _sp),
          Container(
            padding: EdgeInsets.symmetric(horizontal: _sw * 0.02),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(_sw * 0.02),
              border: Border.all(color: Colors.grey.shade200),
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
          color: Colors.white,
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

  Widget _buildDoctorBreakdown(List<DoctorBreakdownModel> breakdown) {
    final filtered = _getFilteredBreakdown(breakdown);

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
                  if (filtered.isEmpty)
                    SizedBox(
                      width: _sw * 1.5,
                      child: _buildEmptyState('No doctor payments found'),
                    )
                  else
                    ...filtered.map((payment) {
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
                              child: _buildStatusButton(payment.status),
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

  Widget _buildRawRecords(List<PayoutRecordModel> records) {
    final filtered = _getFilteredRecords(records);
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
                        SizedBox(width: _sw * 0.25, child: Text('TIME', style: TextStyle(fontSize: _fsS, fontWeight: FontWeight.bold))),
                        SizedBox(width: _sw * 0.2,  child: Text('DOCTOR', style: TextStyle(fontSize: _fsS, fontWeight: FontWeight.bold))),
                        SizedBox(width: _sw * 0.2,  child: Text('PATIENT', style: TextStyle(fontSize: _fsS, fontWeight: FontWeight.bold))),
                        SizedBox(width: _sw * 0.35, child: Text('SERVICE', style: TextStyle(fontSize: _fsS, fontWeight: FontWeight.bold))),
                        SizedBox(width: _sw * 0.2,  child: Text('SHARE', style: TextStyle(fontSize: _fsS, fontWeight: FontWeight.bold))),
                        SizedBox(width: _sw * 0.2,  child: Text('TOTAL BILL', style: TextStyle(fontSize: _fsS, fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),

                  // Rows
                  if (filtered.isEmpty)
                    SizedBox(width: _sw * 1.5, child: _buildEmptyState('No share records found'))
                  else
                    ...filtered.map((record) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: _sw * 0.025, vertical: _sh * 0.02),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                        ),
                        child: Row(
                          children: [
                            SizedBox(width: _sw * 0.25, child: Text('${record.date} ${record.time}', style: TextStyle(fontSize: _fs))),
                            SizedBox(width: _sw * 0.2,  child: Text(record.doctorName, style: TextStyle(fontSize: _fs))),
                            SizedBox(width: _sw * 0.2,  child: Text(record.patientName, style: TextStyle(fontSize: _fs))),
                            SizedBox(width: _sw * 0.35, child: Text(record.serviceDetail, style: TextStyle(fontSize: _fsS), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            SizedBox(width: _sw * 0.2,  child: Text('PKR ${_formatPKR(record.doctorShare)}', style: TextStyle(fontSize: _fs, fontWeight: FontWeight.w600, color: Colors.green))),
                            SizedBox(width: _sw * 0.2,  child: Text('PKR ${_formatPKR(record.totalAmount)}', style: TextStyle(fontSize: _fs, color: Colors.grey))),
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

  Widget _buildStatusButton(String status) {
    final isPaid = status.toLowerCase() == 'paid' || status.toLowerCase() == 'completed';
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: _sw * 0.03, vertical: _sh * 0.008),
        decoration: BoxDecoration(
          color: isPaid ? Colors.green.withOpacity(0.1) : primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(_sw * 0.015),
          border: Border.all(color: isPaid ? Colors.green.withOpacity(0.3) : primary.withOpacity(0.3)),
        ),
        child: Text(
          status,
          style: TextStyle(
            fontSize: _fsS,
            fontWeight: FontWeight.w600,
            color: isPaid ? Colors.green : primary,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toUpperCase()) {
      case 'ACTIVE':
      case 'COMPLETED':
      case 'PAID':
        color = Colors.green;
        break;
      case 'PENDING':
      case 'UNPAID':
        color = Colors.orange;
        break;
      case 'CANCELLED':
      case 'REFUNDED':
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
}