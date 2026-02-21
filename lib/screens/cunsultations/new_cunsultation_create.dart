import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/opd/consultation_provider/cunsultation_provider.dart';

class NewConsultationScreen extends StatefulWidget {
  const NewConsultationScreen({super.key});

  @override
  State<NewConsultationScreen> createState() => _NewConsultationScreenState();
}

class _NewConsultationScreenState extends State<NewConsultationScreen> {
  static const Color primaryColor = Color(0xFF00B5AD);
  static const Color darkTeal = Color(0xFF00897B);
  static const Color bgColor = Color(0xFFF0F4F8);

  final _formKey = GlobalKey<FormState>();

  Map<String, dynamic>? _selectedConsultant;
  DateTime _selectedDate = DateTime.now();
  String? _selectedSlot;
  String _selectedType = 'In-Person';
  bool _isFirstVisit = true;
  bool _patientFound = false;
  bool _patientNotFound = false;

  final _mrNoController = TextEditingController();
  final _patientNameController = TextEditingController();
  final _contactController = TextEditingController();
  final _addressController = TextEditingController();

  late DateTime _calendarMonth;

  // ── Media Query helpers (set once in build) ──
  late double _sw;   // screen width
  late double _sh;   // screen height
  late double _tp;   // top padding
  late bool _isWide; // tablet layout

  double get _sp => _sw * 0.03;   // standard spacing
  double get _rp => _sw * 0.04;   // outer padding
  double get _fs => _sw < 360 ? 11.0 : 13.0;   // base font size
  double get _fsTitle => _sw < 360 ? 14.0 : 16.0;
  double get _fsSmall => _sw < 360 ? 10.0 : 12.0;

  @override
  void initState() {
    super.initState();
    _calendarMonth = DateTime(_selectedDate.year, _selectedDate.month);
  }

  @override
  void dispose() {
    _mrNoController.dispose();
    _patientNameController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Format MR No for display (5 digits with leading zeros)
  String _formatMrNoForDisplay(String input) {
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return '';
    final number = int.tryParse(digits) ?? 0;
    return number.toString().padLeft(5, '0');
  }

  // ── MR No auto-fill with formatting ──
  void _onMrNoChanged(String value) {
    final formattedMrNo = _formatMrNoForDisplay(value);

    if (_mrNoController.text != formattedMrNo) {
      _mrNoController.value = TextEditingValue(
        text: formattedMrNo,
        selection: TextSelection.collapsed(offset: formattedMrNo.length),
      );
    }

    if (formattedMrNo.isEmpty) {
      setState(() {
        _patientFound = false;
        _patientNotFound = false;
        _patientNameController.clear();
        _contactController.clear();
        _addressController.clear();
        _isFirstVisit = true;
      });
      return;
    }

    final provider = Provider.of<ConsultationProvider>(context, listen: false);
    final patient = provider.lookupPatient(formattedMrNo);

    if (patient != null) {
      setState(() {
        _patientFound = true;
        _patientNotFound = false;
        _patientNameController.text = patient['name'] as String;
        _contactController.text = patient['contact'] as String;
        _addressController.text = patient['address'] as String;
        _isFirstVisit = patient['isFirstVisit'] as bool;
      });
    } else {
      setState(() {
        _patientFound = false;
        _patientNotFound = formattedMrNo.length >= 3;
        _patientNameController.clear();
        _contactController.clear();
        _addressController.clear();
        _isFirstVisit = true;
      });
    }
  }

  void _clearAll() {
    setState(() {
      _selectedConsultant = null;
      _selectedSlot = null;
      _selectedType = 'In-Person';
      _isFirstVisit = true;
      _selectedDate = DateTime.now();
      _calendarMonth = DateTime(_selectedDate.year, _selectedDate.month);
      _patientFound = false;
      _patientNotFound = false;
    });
    _mrNoController.clear();
    _patientNameController.clear();
    _contactController.clear();
    _addressController.clear();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedConsultant == null) {
      _showSnack('Please select a consultant', isError: true);
      return;
    }
    if (_selectedSlot == null) {
      _showSnack('Please select a time slot', isError: true);
      return;
    }
    if (_mrNoController.text.isEmpty) {
      _showSnack('Please enter MR No', isError: true);
      return;
    }
    if (_patientNameController.text.isEmpty) {
      _showSnack('Please enter patient name', isError: true);
      return;
    }
    if (_contactController.text.isEmpty) {
      _showSnack('Please enter contact number', isError: true);
      return;
    }

    final provider = Provider.of<ConsultationProvider>(context, listen: false);

    final formattedMrNo = _formatMrNoForDisplay(_mrNoController.text);

    provider.addAppointment(ConsultationAppointment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      consultantName: _selectedConsultant!['name'] as String,
      specialty: _selectedConsultant!['specialty'] as String,
      consultationFee: _selectedConsultant!['fee'] as String,
      followUpCharges: _selectedConsultant!['followUp'] as String,
      availableDays: List<String>.from(_selectedConsultant!['days'] as List),
      timings: _selectedConsultant!['timings'] as String,
      hospital: _selectedConsultant!['hospital'] as String,
      mrNo: formattedMrNo,
      patientName: _patientNameController.text.trim(),
      contactNo: _contactController.text.trim(),
      address: _addressController.text.trim(),
      isFirstVisit: _isFirstVisit,
      appointmentDate: _selectedDate,
      timeSlot: _selectedSlot!,
      type: _selectedType,
      status: 'Upcoming',
    ));

    Navigator.pop(context);
    _showSnack('Appointment added successfully!', isError: false);
  }

  void _showSnack(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(
          isError ? Icons.error_rounded : Icons.check_circle_rounded,
          color: Colors.white,
          size: 16,
        ),
        const SizedBox(width: 8),
        Flexible(child: Text(msg, style: TextStyle(fontSize: _fs))),
      ]),
      backgroundColor: isError ? Colors.red.shade400 : primaryColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.all(_rp),
    ));
  }

  // ── Date Picker Popup (same calendar logic, shown in a dialog) ──
  Future<void> _showDatePickerPopup() async {
    DateTime tempMonth = DateTime(_selectedDate.year, _selectedDate.month);
    DateTime tempDate = _selectedDate;

    final availableDays = _selectedConsultant != null
        ? List<String>.from(_selectedConsultant!['days'] as List)
        : <String>[];

    final picked = await showDialog<DateTime>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setDialogState) {
          final firstDay = DateTime(tempMonth.year, tempMonth.month, 1);
          final daysInMonth =
              DateTime(tempMonth.year, tempMonth.month + 1, 0).day;
          final startWeekday = firstDay.weekday % 7;
          final today = DateTime.now();
          const dayNames = [
            'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'
          ];

          final cells = <Widget>[];
          for (int i = 0; i < startWeekday; i++) {
            cells.add(const SizedBox());
          }
          for (int d = 1; d <= daysInMonth; d++) {
            final date = DateTime(tempMonth.year, tempMonth.month, d);
            final dayName = dayNames[date.weekday % 7];
            final isAvailable =
                availableDays.isEmpty || availableDays.contains(dayName);
            final isPast = date.isBefore(
                DateTime(today.year, today.month, today.day));
            final isSelected = date.year == tempDate.year &&
                date.month == tempDate.month &&
                date.day == tempDate.day;
            final isToday = date.year == today.year &&
                date.month == today.month &&
                date.day == today.day;

            cells.add(GestureDetector(
              onTap: isAvailable && !isPast
                  ? () => setDialogState(() => tempDate = date)
                  : null,
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primaryColor
                      : isToday
                      ? primaryColor.withOpacity(0.15)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$d',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected || isToday
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? Colors.white
                          : isPast || !isAvailable
                          ? Colors.grey.shade300
                          : Colors.black87,
                    ),
                  ),
                ),
              ),
            ));
          }

          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dialog Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.calendar_month_rounded,
                            color: primaryColor, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Select Date',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: const Icon(Icons.close_rounded,
                            color: Colors.grey, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  // Month navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => setDialogState(() {
                          tempMonth = DateTime(
                              tempMonth.year, tempMonth.month - 1);
                        }),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.chevron_left_rounded,
                              color: primaryColor, size: 22),
                        ),
                      ),
                      Text(
                        _monthYearLabel(tempMonth),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black87),
                      ),
                      GestureDetector(
                        onTap: () => setDialogState(() {
                          tempMonth = DateTime(
                              tempMonth.year, tempMonth.month + 1);
                        }),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.chevron_right_rounded,
                              color: primaryColor, size: 22),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Day headers
                  Row(
                    children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                        .map((d) => Expanded(
                      child: Center(
                        child: Text(d,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade500)),
                      ),
                    ))
                        .toList(),
                  ),
                  const SizedBox(height: 6),

                  // Calendar grid
                  GridView.count(
                    crossAxisCount: 7,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1,
                    children: cells,
                  ),
                  const SizedBox(height: 10),

                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _dialogLegendDot(primaryColor, 'Available'),
                      const SizedBox(width: 14),
                      _dialogLegendDot(Colors.red.shade400, 'Full'),
                      const SizedBox(width: 14),
                      _dialogLegendDot(Colors.grey.shade300, 'Off Day'),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Confirm button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, tempDate),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding:
                        const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Confirm Date',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _calendarMonth =
            DateTime(_selectedDate.year, _selectedDate.month);
        _selectedSlot = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    _sw = mq.size.width;
    _sh = mq.size.height;
    _tp = mq.padding.top;
    _isWide = _sw > 700;

    final provider = Provider.of<ConsultationProvider>(context);
    final slots = _selectedConsultant != null
        ? provider.generateTimeSlots(
        _selectedConsultant!['timings'] as String)
        : <String>[];
    final booked = _selectedConsultant != null
        ? provider.bookedSlots(
        _selectedDate, _selectedConsultant!['name'] as String)
        : <String>[];

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Form(
              key: _formKey,
              child: _isWide
                  ? _buildWideLayout(provider, slots, booked)
                  : _buildNarrowLayout(provider, slots, booked),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  HEADER
  // ─────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.only(
        top: _tp + _sh * 0.016,
        left: _sw * 0.04,
        right: _sw * 0.04,
        bottom: _sh * 0.022,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(_sw * 0.022),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(_sw * 0.025),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: _sw * 0.045),
            ),
          ),
          SizedBox(width: _sw * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('New Consultation',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: _sw * 0.05,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: _sh * 0.003),
                Text('Book an appointment',
                    style: TextStyle(
                        color: Colors.white70, fontSize: _sw * 0.03)),
              ],
            ),
          ),
          // Selected date badge — tappable to open picker
          GestureDetector(
            onTap: _showDatePickerPopup,
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: _sw * 0.03, vertical: _sh * 0.007),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(_sw * 0.05),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today_rounded,
                      color: Colors.white, size: _sw * 0.035),
                  SizedBox(width: _sw * 0.015),
                  Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: _sw * 0.03,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(width: _sw * 0.01),
                  Icon(Icons.arrow_drop_down_rounded,
                      color: Colors.white70, size: _sw * 0.04),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  //  LAYOUTS
  // ─────────────────────────────────────────
  Widget _buildWideLayout(ConsultationProvider provider,
      List<String> slots, List<String> booked) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 55,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(_sw * 0.02),
            physics: const BouncingScrollPhysics(),
            child: Column(children: [
              _buildConsultantCard(provider),
              SizedBox(height: _sw * 0.02),
              _buildPatientCard(),
              SizedBox(height: _sw * 0.02),
              _buildActionButtons(),
            ]),
          ),
        ),
        Expanded(
          flex: 45,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(_sw * 0.02),
            physics: const BouncingScrollPhysics(),
            child: Column(children: [
              _buildDatePickerCard(),
              SizedBox(height: _sw * 0.02),
              _buildTimeSlotsCard(slots, booked),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(ConsultationProvider provider,
      List<String> slots, List<String> booked) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(_rp),
      physics: const BouncingScrollPhysics(),
      child: Column(children: [
        _buildConsultantCard(provider),
        SizedBox(height: _sh * 0.02),
        _buildDatePickerCard(),
        SizedBox(height: _sh * 0.02),
        _buildTimeSlotsCard(slots, booked),
        SizedBox(height: _sh * 0.02),
        _buildPatientCard(),
        SizedBox(height: _sh * 0.02),
        _buildActionButtons(),
        SizedBox(height: _sh * 0.03),
      ]),
    );
  }

  // ─────────────────────────────────────────
  //  DATE PICKER CARD (replaces calendar card)
  // ─────────────────────────────────────────
  Widget _buildDatePickerCard() {
    return _FormCard(
      icon: Icons.calendar_month_rounded,
      title: 'Select Date',
      sw: _sw,
      child: GestureDetector(
        onTap: _showDatePickerPopup,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
              horizontal: _sw * 0.04, vertical: _sh * 0.018),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_sw * 0.025),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(_sw * 0.022),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(_sw * 0.02),
                ),
                child: Icon(Icons.event_rounded,
                    color: primaryColor, size: _sw * 0.05),
              ),
              SizedBox(width: _sw * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Appointment Date',
                        style: TextStyle(
                            fontSize: _fsSmall,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500)),
                    SizedBox(height: _sh * 0.004),
                    Text(
                      '${_selectedDate.day} ${_monthName(_selectedDate.month)} ${_selectedDate.year}',
                      style: TextStyle(
                          fontSize: _fs + 1,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    SizedBox(height: _sh * 0.002),
                    Text(
                      _dayName(_selectedDate.weekday),
                      style: TextStyle(
                          fontSize: _fsSmall,
                          color: primaryColor,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: _sw * 0.03, vertical: _sh * 0.008),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(_sw * 0.02),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_calendar_rounded,
                        color: Colors.white, size: _sw * 0.035),
                    SizedBox(width: _sw * 0.01),
                    Text('Change',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: _fsSmall,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  //  TIME SLOTS CARD — now a dropdown
  // ─────────────────────────────────────────
  Widget _buildTimeSlotsCard(List<String> slots, List<String> booked) {
    final freeSlots = slots.where((s) => !booked.contains(s)).toList();

    return _FormCard(
      icon: Icons.access_time_rounded,
      title: 'Time Slots',
      subtitle:
      '${_selectedDate.year}-${_pad(_selectedDate.month)}-${_pad(_selectedDate.day)}'
          '  •  ${_selectedConsultant == null ? 'Select consultant first' : 'Pick a slot'}',
      sw: _sw,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedConsultant != null) ...[
            Wrap(
              spacing: _sw * 0.02,
              runSpacing: _sh * 0.006,
              children: [
                _slotBadge('${slots.length} Total', Colors.grey.shade600),
                _slotBadge('${freeSlots.length} Free', Colors.green),
                _slotBadge('${booked.length} Booked', Colors.red),
              ],
            ),
            SizedBox(height: _sh * 0.015),
          ],
          if (slots.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: _sh * 0.025),
                child: Text(
                  _selectedConsultant == null
                      ? 'Select a consultant to view slots'
                      : 'No slots available',
                  style: TextStyle(
                      color: Colors.grey.shade400, fontSize: _fs),
                ),
              ),
            )
          else
          // Dropdown for time slots
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(_sw * 0.025),
                border: Border.all(
                  color: _selectedSlot != null
                      ? primaryColor
                      : Colors.grey.shade300,
                  width: _selectedSlot != null ? 1.5 : 1,
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: _sw * 0.03),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedSlot,
                  isExpanded: true,
                  hint: Row(children: [
                    Icon(Icons.schedule_rounded,
                        color: Colors.grey.shade400, size: _sw * 0.04),
                    SizedBox(width: _sw * 0.02),
                    Text('Select a time slot',
                        style: TextStyle(
                            color: Colors.grey.shade400, fontSize: _fs)),
                  ]),
                  icon: Icon(Icons.keyboard_arrow_down_rounded,
                      color: _selectedSlot != null
                          ? primaryColor
                          : Colors.grey,
                      size: _sw * 0.05),
                  style: TextStyle(fontSize: _fs, color: Colors.black87),
                  items: slots.map((slot) {
                    final isBooked = booked.contains(slot);
                    return DropdownMenuItem<String>(
                      value: slot,
                      enabled: !isBooked,
                      child: Row(
                        children: [
                          Icon(
                            isBooked
                                ? Icons.block_rounded
                                : Icons.schedule_rounded,
                            size: _sw * 0.038,
                            color: isBooked
                                ? Colors.red.shade300
                                : Colors.green.shade500,
                          ),
                          SizedBox(width: _sw * 0.02),
                          Text(
                            slot,
                            style: TextStyle(
                              fontSize: _fs,
                              color: isBooked
                                  ? Colors.grey.shade400
                                  : Colors.black87,
                              decoration: isBooked
                                  ? TextDecoration.lineThrough
                                  : null,
                              fontWeight: isBooked
                                  ? FontWeight.normal
                                  : FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          if (isBooked)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: _sw * 0.018,
                                  vertical: _sh * 0.003),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius:
                                BorderRadius.circular(_sw * 0.03),
                              ),
                              child: Text('Booked',
                                  style: TextStyle(
                                      fontSize: _fsSmall - 1,
                                      color: Colors.red.shade400,
                                      fontWeight: FontWeight.w600)),
                            )
                          else
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: _sw * 0.018,
                                  vertical: _sh * 0.003),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius:
                                BorderRadius.circular(_sw * 0.03),
                              ),
                              child: Text('Free',
                                  style: TextStyle(
                                      fontSize: _fsSmall - 1,
                                      color: Colors.green.shade600,
                                      fontWeight: FontWeight.w600)),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedSlot = val);
                  },
                ),
              ),
            ),
          // Show selected slot confirmation
          if (_selectedSlot != null) ...[
            SizedBox(height: _sh * 0.012),
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: _sw * 0.03, vertical: _sh * 0.01),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(_sw * 0.025),
                border: Border.all(color: primaryColor.withOpacity(0.3)),
              ),
              child: Row(children: [
                Icon(Icons.check_circle_rounded,
                    color: primaryColor, size: _sw * 0.04),
                SizedBox(width: _sw * 0.02),
                Text('Selected: $_selectedSlot',
                    style: TextStyle(
                        fontSize: _fs,
                        color: primaryColor,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _slotBadge(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: _sw * 0.025, vertical: _sh * 0.005),
      decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(_sw * 0.05)),
      child: Text(label,
          style: TextStyle(
              fontSize: _fsSmall,
              fontWeight: FontWeight.w700,
              color: color)),
    );
  }

  // ─────────────────────────────────────────
  //  CONSULTANT CARD
  // ─────────────────────────────────────────
  Widget _buildConsultantCard(ConsultationProvider provider) {
    return _FormCard(
      icon: Icons.person_rounded,
      title: 'Consultant Information',
      sw: _sw,
      child: Column(children: [
        // Row 1: Consultant dropdown + Specialty
        _isWide
            ? Row(children: [
          Expanded(
            child: _label(
                'Consultant *',
                _dropdown(
                  value: _selectedConsultant?['name'] as String?,
                  hint: 'Select consultant',
                  items: provider.consultants
                      .map((c) => c['name'] as String)
                      .toList(),
                  onChanged: (val) => setState(() {
                    _selectedConsultant = provider.consultants
                        .firstWhere((c) => c['name'] == val);
                    _selectedSlot = null;
                  }),
                )),
          ),
          SizedBox(width: _sp),
          Expanded(
            child: _label('Speciality',
                _readonly(_selectedConsultant?['specialty'] ?? '')),
          ),
        ])
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(
                'Consultant *',
                _dropdown(
                  value: _selectedConsultant?['name'] as String?,
                  hint: 'Select consultant',
                  items: provider.consultants
                      .map((c) => c['name'] as String)
                      .toList(),
                  onChanged: (val) => setState(() {
                    _selectedConsultant = provider.consultants
                        .firstWhere((c) => c['name'] == val);
                    _selectedSlot = null;
                  }),
                )),
            SizedBox(height: _sh * 0.015),
            _label('Speciality',
                _readonly(_selectedConsultant?['specialty'] ?? '')),
          ],
        ),
        SizedBox(height: _sh * 0.015),

        // Row 2: Fee + Follow-up
        Row(children: [
          Expanded(
              child: _label('Consultation Fee',
                  _readonly(_selectedConsultant?['fee'] ?? ''))),
          SizedBox(width: _sp),
          Expanded(
              child: _label('Follow-Up Charges',
                  _readonly(_selectedConsultant?['followUp'] ?? ''))),
        ]),
        SizedBox(height: _sh * 0.015),

        // Row 3: Days + Timings + Hospital
        _isWide
            ? Row(children: [
          Expanded(
            flex: 3,
            child: _label(
                'Available Days',
                _daysWidget(_selectedConsultant != null
                    ? List<String>.from(
                    _selectedConsultant!['days'] as List)
                    : [])),
          ),
          SizedBox(width: _sw * 0.02),
          Expanded(
            flex: 3,
            child: _label('Timings',
                _readonly(_selectedConsultant?['timings'] ?? '')),
          ),
          SizedBox(width: _sw * 0.02),
          Expanded(
            flex: 2,
            child: _label('Hospital',
                _readonly(_selectedConsultant?['hospital'] ?? '')),
          ),
        ])
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label(
                'Available Days',
                _daysWidget(_selectedConsultant != null
                    ? List<String>.from(
                    _selectedConsultant!['days'] as List)
                    : [])),
            SizedBox(height: _sh * 0.015),
            Row(children: [
              Expanded(
                  child: _label(
                      'Timings',
                      _readonly(
                          _selectedConsultant?['timings'] ?? ''))),
              SizedBox(width: _sp),
              Expanded(
                  child: _label(
                      'Hospital',
                      _readonly(
                          _selectedConsultant?['hospital'] ?? ''))),
            ]),
          ],
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────
  //  PATIENT CARD
  // ─────────────────────────────────────────
  Widget _buildPatientCard() {
    return _FormCard(
      icon: Icons.groups_rounded,
      title: 'Patient Information',
      subtitle: 'MR No auto-formats to 5 digits (e.g., 2 → 00002)',
      sw: _sw,
      child: Column(children: [
        // MR No + Patient Name
        _isWide
            ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _mrNoField()),
              SizedBox(width: _sp),
              Expanded(child: _patientNameField()),
            ])
            : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _mrNoField(),
              SizedBox(height: _sh * 0.015),
              _patientNameField(),
            ]),
        SizedBox(height: _sh * 0.015),

        // Contact + Address
        Row(children: [
          Expanded(
            child: _label(
              'Contact No *',
              TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                style: TextStyle(fontSize: _fs, color: Colors.black87),
                decoration: _decor('03XX-XXXXXXX').copyWith(
                  filled: true,
                  fillColor: _patientFound
                      ? Colors.green.withOpacity(0.05)
                      : Colors.white,
                ),
                validator: (v) =>
                v == null || v.isEmpty ? 'Required' : null,
              ),
            ),
          ),
          SizedBox(width: _sp),
          Expanded(
            child: _label(
              'Address',
              TextFormField(
                controller: _addressController,
                style: TextStyle(fontSize: _fs, color: Colors.black87),
                decoration: _decor('Enter address').copyWith(
                  filled: true,
                  fillColor: _patientFound
                      ? Colors.green.withOpacity(0.05)
                      : Colors.white,
                ),
              ),
            ),
          ),
        ]),
        SizedBox(height: _sh * 0.015),

        // Type selector + First Visit
        _isWide
            ? Row(children: [
          Expanded(child: _typeSelector()),
          SizedBox(width: _sw * 0.04),
          _firstVisitToggle(),
        ])
            : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _typeSelector(),
              SizedBox(height: _sh * 0.012),
              _firstVisitToggle(),
            ]),
      ]),
    );
  }

  Widget _mrNoField() {
    return _label(
      'MR No (Auto-formats to 5 digits)',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _mrNoController,
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: _fs, color: Colors.black87),
            decoration: _decor('Enter number (e.g., 2 → 00002)').copyWith(
              suffixIcon: _patientFound
                  ? const Icon(Icons.check_circle_rounded,
                  color: Colors.green, size: 20)
                  : _patientNotFound
                  ? Icon(Icons.cancel_rounded,
                  color: Colors.red.shade400, size: 20)
                  : const Icon(Icons.badge_rounded,
                  color: Colors.grey, size: 20),
            ),
            onChanged: _onMrNoChanged,
            validator: (v) =>
            v == null || v.isEmpty ? 'MR No is required' : null,
          ),
          if (_patientFound)
            Padding(
              padding: EdgeInsets.only(top: _sh * 0.005),
              child: Row(children: [
                const Icon(Icons.check_circle_rounded,
                    color: Colors.green, size: 13),
                SizedBox(width: _sw * 0.01),
                Text('Patient found — fields auto-filled',
                    style: TextStyle(
                        fontSize: _fsSmall,
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
          if (_patientNotFound)
            Padding(
              padding: EdgeInsets.only(top: _sh * 0.005),
              child: Row(children: [
                Icon(Icons.info_rounded,
                    color: Colors.orange.shade400, size: 13),
                SizedBox(width: _sw * 0.01),
                Text('MR No not found — fill manually',
                    style: TextStyle(
                        fontSize: _fsSmall,
                        color: Colors.orange.shade600,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
          if (_mrNoController.text.isNotEmpty &&
              !_patientFound &&
              !_patientNotFound)
            Padding(
              padding: EdgeInsets.only(top: _sh * 0.005),
              child: Row(children: [
                Icon(Icons.info_rounded,
                    color: Colors.blue.shade400, size: 13),
                SizedBox(width: _sw * 0.01),
                Text('Formatting: ${_mrNoController.text}',
                    style: TextStyle(
                        fontSize: _fsSmall,
                        color: Colors.blue.shade600,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
        ],
      ),
    );
  }

  Widget _patientNameField() {
    return _label(
      'Patient Name *',
      TextFormField(
        controller: _patientNameController,
        style: TextStyle(fontSize: _fs, color: Colors.black87),
        decoration: _decor('Enter patient name').copyWith(
          filled: true,
          fillColor: _patientFound
              ? Colors.green.withOpacity(0.05)
              : Colors.white,
        ),
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _typeSelector() {
    return _label(
      'Appointment Type',
      Row(
        children: ['In-Person', 'Video Call'].map((t) {
          final isSel = _selectedType == t;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedType = t),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: EdgeInsets.only(
                    right: t == 'In-Person' ? _sw * 0.015 : 0),
                padding: EdgeInsets.symmetric(vertical: _sh * 0.012),
                decoration: BoxDecoration(
                  color: isSel ? primaryColor : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(_sw * 0.025),
                  border: Border.all(
                      color: isSel ? primaryColor : Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      t == 'Video Call'
                          ? Icons.videocam_rounded
                          : Icons.local_hospital_rounded,
                      size: _sw * 0.035,
                      color: isSel ? Colors.white : Colors.grey.shade500,
                    ),
                    SizedBox(width: _sw * 0.012),
                    Text(t,
                        style: TextStyle(
                            fontSize: _sw * 0.03,
                            fontWeight: FontWeight.w600,
                            color: isSel
                                ? Colors.white
                                : Colors.grey.shade600)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _firstVisitToggle() {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Transform.scale(
        scale: _sw < 360 ? 0.8 : 1.0,
        child: Switch(
          value: _isFirstVisit,
          onChanged: (v) => setState(() => _isFirstVisit = v),
          activeColor: primaryColor,
        ),
      ),
      Text('First Visit',
          style: TextStyle(
              fontSize: _fs,
              fontWeight: FontWeight.w500,
              color: Colors.black87)),
    ]);
  }

  // ─────────────────────────────────────────
  //  ACTION BUTTONS
  // ─────────────────────────────────────────
  Widget _buildActionButtons() {
    return Row(children: [
      Expanded(
        child: OutlinedButton.icon(
          onPressed: _clearAll,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.grey.shade600,
            side: BorderSide(color: Colors.grey.shade300),
            padding: EdgeInsets.symmetric(vertical: _sh * 0.016),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_sw * 0.03)),
          ),
          icon: Icon(Icons.close_rounded,
              size: _sw * 0.045, color: Colors.grey.shade600),
          label: Text('Clear All',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                  fontSize: _fs)),
        ),
      ),
      SizedBox(width: _sw * 0.03),
      Expanded(
        flex: 2,
        child: ElevatedButton.icon(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: _sh * 0.016),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_sw * 0.03)),
            elevation: 0,
          ),
          icon: Icon(Icons.add_rounded, size: _sw * 0.045),
          label: Text('Add Appointment',
              style:
              TextStyle(fontWeight: FontWeight.bold, fontSize: _fs)),
        ),
      ),
    ]);
  }

  // ─────────────────────────────────────────
  //  SHARED HELPERS
  // ─────────────────────────────────────────
  Widget _label(String labelText, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: labelText.replaceAll(' *', ''),
            style: TextStyle(
                fontSize: _fsSmall,
                fontWeight: FontWeight.w600,
                color: Colors.black54),
            children: labelText.contains('*')
                ? [
              TextSpan(
                  text: ' *',
                  style: TextStyle(
                      color: Colors.red, fontSize: _fsSmall))
            ]
                : [],
          ),
        ),
        SizedBox(height: _sh * 0.006),
        child,
      ],
    );
  }

  Widget _dropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_sw * 0.025),
          border: Border.all(color: Colors.grey.shade300)),
      padding: EdgeInsets.symmetric(horizontal: _sw * 0.03),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint,
              style:
              TextStyle(color: Colors.grey.shade400, fontSize: _fs)),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: Colors.grey, size: _sw * 0.05),
          style: TextStyle(fontSize: _fs, color: Colors.black87),
          items: items
              .map((i) => DropdownMenuItem(value: i, child: Text(i)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _readonly(String value) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
          horizontal: _sw * 0.03, vertical: _sh * 0.014),
      decoration: BoxDecoration(
          color: value.isEmpty ? Colors.grey.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(_sw * 0.025),
          border: Border.all(color: Colors.grey.shade300)),
      child: Text(
        value.isEmpty ? 'Auto-filled' : value,
        style: TextStyle(
            fontSize: _fs,
            color: value.isEmpty ? Colors.grey.shade400 : Colors.black87),
      ),
    );
  }

  Widget _daysWidget(List<String> days) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
          horizontal: _sw * 0.025, vertical: _sh * 0.01),
      decoration: BoxDecoration(
          color: days.isEmpty ? Colors.grey.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(_sw * 0.025),
          border: Border.all(color: Colors.grey.shade300)),
      child: days.isEmpty
          ? Text('Auto-filled',
          style:
          TextStyle(fontSize: _fs, color: Colors.grey.shade400))
          : Wrap(
        spacing: _sw * 0.015,
        runSpacing: _sh * 0.005,
        children: days
            .map((d) => Container(
          padding: EdgeInsets.symmetric(
              horizontal: _sw * 0.025,
              vertical: _sh * 0.004),
          decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.12),
              borderRadius:
              BorderRadius.circular(_sw * 0.05)),
          child: Text(d,
              style: TextStyle(
                  fontSize: _sw * 0.028,
                  fontWeight: FontWeight.w700,
                  color: primaryColor)),
        ))
            .toList(),
      ),
    );
  }

  InputDecoration _decor(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: _fs),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(
          horizontal: _sw * 0.03, vertical: _sh * 0.014),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_sw * 0.025),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_sw * 0.025),
          borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_sw * 0.025),
          borderSide: const BorderSide(color: primaryColor, width: 1.5)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_sw * 0.025),
          borderSide: BorderSide(color: Colors.red.shade300)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_sw * 0.025),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5)),
    );
  }

  String _monthYearLabel(DateTime d) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[d.month - 1]} ${d.year}';
  }

  String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  String _dayName(int weekday) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    return days[weekday - 1];
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  Widget _dialogLegendDot(Color color, String label) {
    return Row(children: [
      Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Text(label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
    ]);
  }
}

// ─────────────────────────────────────────────
//  FORM CARD
// ─────────────────────────────────────────────
class _FormCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget child;
  final double sw;

  const _FormCard({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.child,
    required this.sw,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(sw * 0.045),
        border: const Border(
            left: BorderSide(color: Color(0xFF00B5AD), width: 4)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      padding: EdgeInsets.all(sw * 0.045),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: EdgeInsets.all(sw * 0.022),
              decoration: BoxDecoration(
                  color: const Color(0xFF00B5AD).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(sw * 0.025)),
              child: Icon(icon,
                  color: const Color(0xFF00B5AD), size: sw * 0.05),
            ),
            SizedBox(width: sw * 0.025),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: sw * 0.04,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: TextStyle(
                            fontSize: sw * 0.028,
                            color: Colors.grey.shade500)),
                ],
              ),
            ),
          ]),
          SizedBox(height: sw * 0.04),
          const Divider(height: 1),
          SizedBox(height: sw * 0.04),
          child,
        ],
      ),
    );
  }
}