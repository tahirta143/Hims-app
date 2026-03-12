import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hims_app/custum widgets/drawer/base_scaffold.dart';
import '../../custum widgets/bottombar/bottombar.dart';
import '../../models/consultation_model/doctor_model.dart';
import '../../providers/opd/consultation_provider/cunsultation_provider.dart';
import '../../providers/mr_provider/mr_provider.dart';
import '../add_expenses/add_expenses.dart';
import '../cunsultations/cunsultations.dart';
import '../cunsultations/widgets/appointment_dialog.dart';
import '../emergency_treatment/emergency_treatment.dart';
import '../mr_details/mr_view/mr_view.dart';
// ─────────────────────────────────────────────
//  SUMMARY CARD WIDGET
// ─────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;
  final bool trendUp;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
    required this.trendUp,
  });

  @override
  Widget build(BuildContext context) {
    final double cardWidth =
        (MediaQuery.of(context).size.width - 48) / 2;

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: trendUp
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      trendUp
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 11,
                      color: trendUp ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      trend,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: trendUp ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  DOCTOR CARD WIDGET
// ─────────────────────────────────────────────
// ─────────────────────────────────────────────
//  DOCTOR CARD (EXACT MATCH FROM IMAGE)
// ─────────────────────────────────────────────
// ─────────────────────────────────────────────
//  DOCTOR CARD (Name, Fee Rs, Image Right, Slots, Specialist, Clickable)
// ─────────────────────────────────────────────
// ─────────────────────────────────────────────
//  DOCTOR CARD (Actual Image, Fee under Specialist, Larger Image, Minimized Slots)
// ─────────────────────────────────────────────
class _DoctorCard extends StatelessWidget {
  final DoctorInfo doctor;
  final int availableSlots;
  final Color primaryColor;
  final VoidCallback onTap;

  const _DoctorCard({
    required this.doctor,
    required this.availableSlots,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double cardWidth = screenSize.width * 0.9;
    final double horizontalPadding = screenSize.width * 0.04;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        margin: EdgeInsets.only(bottom: screenSize.height * 0.015),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(screenSize.width * 0.04),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor Info Row (Name left, Large Image right)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Name, Specialist and Fee (Left side)
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor.name,
                          style: TextStyle(
                            fontSize: screenSize.width * 0.045,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: screenSize.height * 0.003),
                        Text(
                          doctor.specialty,
                          style: TextStyle(
                            fontSize: screenSize.width * 0.035,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: screenSize.height * 0.008),
                        // Fee under specialist
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenSize.width * 0.02,
                            vertical: screenSize.height * 0.004,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(screenSize.width * 0.02),
                          ),
                          child: Text(
                            'Rs. ${doctor.consultationFee}',
                            style: TextStyle(
                              fontSize: screenSize.width * 0.04,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: screenSize.width * 0.03),

                  // Actual Doctor Image (Right side)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(screenSize.width * 0.05),
                    child: doctor.imageAsset.isNotEmpty
                        ? Image.network(
                            doctor.imageAsset,
                            width: screenSize.width * 0.28,
                            height: screenSize.width * 0.28,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildAvatarFallback(screenSize),
                          )
                        : _buildAvatarFallback(screenSize),
                  ),
                ],
              ),

              SizedBox(height: screenSize.height * 0.015),

              // Slots Available (Minimized size)
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: screenSize.width * 0.035,
                    color: Colors.green,
                  ),
                  SizedBox(width: screenSize.width * 0.01),
                  Text(
                    '$availableSlots Slots Available',
                    style: TextStyle(
                      fontSize: screenSize.width * 0.03,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              SizedBox(height: screenSize.height * 0.01),

              // Days Row with Dates
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   _buildDayChip('Mon', screenSize, doctor.availableDays.contains('Mon')),
                   _buildDayChip('Tue', screenSize, doctor.availableDays.contains('Tue')),
                   _buildDayChip('Wed', screenSize, doctor.availableDays.contains('Wed')),
                   _buildDayChip('Thu', screenSize, doctor.availableDays.contains('Thu')),
                   _buildDayChip('Fri', screenSize, doctor.availableDays.contains('Fri')),
                   _buildDayChip('Sat', screenSize, doctor.availableDays.contains('Sat')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarFallback(Size screenSize) {
    return Container(
      width: screenSize.width * 0.28,
      height: screenSize.width * 0.28,
      decoration: BoxDecoration(
        color: doctor.avatarColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(screenSize.width * 0.05),
      ),
      child: Center(
        child: Text(
          doctor.name.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join('').toUpperCase(),
          style: TextStyle(
            color: doctor.avatarColor,
            fontWeight: FontWeight.bold,
            fontSize: screenSize.width * 0.08,
          ),
        ),
      ),
    );
  }

  Widget _buildDayChip(String day, Size screenSize, bool isAvailable) {
    // Show current date for context or just "Available"
    final now = DateTime.now();
    // Simplified: we don't have real dates per day easily here, 
    // so we just show the day name and availability highlight
    return Container(
      width: screenSize.width * 0.12,
      padding: EdgeInsets.symmetric(
        vertical: screenSize.height * 0.008,
      ),
      decoration: BoxDecoration(
        color: isAvailable ? primaryColor : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(screenSize.width * 0.025),
      ),
      child: Center(
        child: Text(
          day,
          style: TextStyle(
            fontSize: screenSize.width * 0.03,
            fontWeight: FontWeight.bold,
            color: isAvailable ? Colors.white : Colors.grey.shade500,
          ),
        ),
      ),
    );
  }
}
// ─────────────────────────────────────────────
//  DASHBOARD BODY (extracted from HomeScreen)
// ─────────────────────────────────────────────
class _DashboardBody extends StatefulWidget {
  const _DashboardBody();

  @override
  State<_DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends State<_DashboardBody> {
  static const Color primaryColor = Color(0xFF00B5AD);
  static const Color darkTeal = Color(0xFF00897B);

  final List<Map<String, dynamic>> specialists = [
    {'icon': Icons.medical_services, 'label': 'General', 'selected': true},
    {'icon': Icons.remove_red_eye, 'label': 'Optics', 'selected': false},
    {'icon': Icons.vaccines, 'label': 'Dentist', 'selected': false},
    {'icon': Icons.monitor_heart, 'label': 'Immune', 'selected': false},
  ];
  final List<Map<String, dynamic>> summaryCards = [
    {
      'title': 'OPD Revenue',
      'value': '24,500',      // ← Changed from $ to ₨
      'icon': Icons.attach_money_rounded,
      'color': const Color(0xFF00BFA5),
      'trend': '12%',
      'trendUp': true,
    },
    {
      'title': 'Consultations',
      'value': '1,284',
      'icon': Icons.chat_bubble_rounded,
      'color': const Color(0xFF7C4DFF),
      'trend': '8%',
      'trendUp': true,
    },
    {
      'title': 'Patients',
      'value': '3,920',
      'icon': Icons.people_alt_rounded,
      'color': const Color(0xFF00ACC1),
      'trend': '5%',
      'trendUp': true,
    },
    {
      'title': 'Expenses',
      'value': '8,340',       // ← Changed from $ to ₨
      'icon': Icons.receipt_long_rounded,
      'color': const Color(0xFFFF6B6B),
      'trend': '3%',
      'trendUp': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Summary Cards ──
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: screenWidth * 0.04,
              mainAxisSpacing: screenWidth * 0.04,
              childAspectRatio: 1.2,
            ),
            itemCount: summaryCards.length,
            itemBuilder: (context, index) {
              final card = summaryCards[index];
              return _SummaryCard(
                title: card['title'] as String,
                value: card['value'] as String,
                icon: card['icon'] as IconData,
                color: card['color'] as Color,
                trend: card['trend'] as String,
                trendUp: card['trendUp'] as bool,
              );
            },
          ),
          // SizedBox(height: screenHeight * 0.025),

          // ── Find Specialist ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Find Specialist',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to Consultations tab (index 2 in HomeScreen)
                  final homeState = context.findAncestorStateOfType<HomeScreenState>();
                  if (homeState != null) homeState.onTabTapped(2);
                },
                child: Text(
                  'View all',
                  style: TextStyle(
                    fontSize: 13,
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.014),

          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: specialists.length,
              itemBuilder: (context, index) {
                final item = specialists[index];
                final isSelected = item['selected'] as bool;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      for (var s in specialists) {
                        s['selected'] = false;
                      }
                      specialists[index]['selected'] = true;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected
                            ? primaryColor
                            : Colors.grey.shade300,
                      ),
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          size: 16,
                          color: isSelected
                              ? Colors.white
                              : Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item['label'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: screenHeight * 0.02),

          // ── Banner ──
          Container(
            height: screenHeight * 0.17,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [primaryColor, darkTeal],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: screenWidth * 0.3,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  bottom: 10,
                  child: Container(
                    width: screenWidth * 0.25,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.health_and_safety_rounded,
                        size: 50, color: Colors.white54),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Quick Appointments,\nTrusted Care',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Start Now',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.025),

          // ── Available Doctors ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Available Doctor',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: () {
                  final homeState = context.findAncestorStateOfType<HomeScreenState>();
                  if (homeState != null) homeState.onTabTapped(2);
                },
                child: Text(
                  'View all',
                  style: TextStyle(
                    fontSize: 13,
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.014),

          Consumer<ConsultationProvider>(
            builder: (context, prov, child) {
              if (prov.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (prov.doctors.isEmpty) {
                return const Center(child: Text('No doctors available'));
              }
              
              // Only show top 3 on dashboard
              final topDocs = prov.doctors.take(3).toList();
              
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: topDocs.length,
                itemBuilder: (context, index) {
                  final doctor = topDocs[index];
                  return _DoctorCard(
                    doctor: doctor,
                    availableSlots: prov.availableSlotsForDoctor(doctor.name, DateTime.now()),
                    primaryColor: primaryColor,
                    onTap: () => _showDialog(context, prov, doctor),
                  );
                },
              );
            },
          ),
          SizedBox(height: screenHeight * 0.12),
        ],
      ),
    );

  }
  void _showDialog(BuildContext context, ConsultationProvider prov, DoctorInfo doctor) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: prov),
            ChangeNotifierProvider.value(value: context.read<MrProvider>()),
          ],
          child: AppointmentDialog(
            doctor: doctor,
            availableSlots: prov.availableSlotsForDoctor(doctor.name, DateTime.now()),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  HOME SCREEN
// ─────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // ── Page titles for the AppBar ──
  static const List<String> _titles = [
    'Dashboard',
    'Emergency',
    'Consultations',
    'MR View',
    'Expenses',
  ];

  // ── Screens list — built once, kept alive via IndexedStack ──
  static final List<Widget> _screens = [
    const _DashboardBody(),
    const EmergencyTreatmentScreen(),
    const ConsultationScreen(),
    const MrDataViewScreen(),
    const ExpensesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: _titles[_selectedIndex],
      drawerIndex: _getDrawerIndex(_selectedIndex),
      body: _screens[_selectedIndex],
    );
  }

  int _getDrawerIndex(int bottomIndex) {
    switch (bottomIndex) {
      case 0: return 0; // Dashboard
      case 1: return 5; // Emergency
      case 2: return 1; // Consultations
      case 3: return 9; // MR View (data view)
      case 4: return 2; // Expenses
      default: return 0;
    }
  }
}