import 'package:flutter/material.dart';
import 'package:hims_app/custum widgets/drawer/base_scaffold.dart';
import '../../custum widgets/bottombar/bottombar.dart';
import '../add_expenses/add_expenses.dart';
import '../cunsultations/cunsultations.dart';
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
class _DoctorCard extends StatelessWidget {
  final Map<String, dynamic> doctor;
  final bool isFeatured;
  final Color primaryColor;

  const _DoctorCard({
    required this.doctor,
    required this.isFeatured,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final double cardWidth = MediaQuery.of(context).size.width * 0.44;

    return Container(
      width: cardWidth,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: isFeatured ? primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border:
        isFeatured ? null : Border.all(color: Colors.grey.shade200),
        boxShadow: isFeatured
            ? null
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isFeatured
                    ? Colors.white.withOpacity(0.3)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: isFeatured
                      ? Colors.white.withOpacity(0.5)
                      : Colors.grey.shade400,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 14, right: 14, bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor['name'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isFeatured ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.medical_services,
                        size: 11,
                        color:
                        isFeatured ? Colors.white70 : Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        doctor['specialty'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          color: isFeatured
                              ? Colors.white70
                              : Colors.grey.shade500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, size: 13, color: Colors.amber),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        '${doctor['rating']} (${doctor['reviews']})',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color:
                          isFeatured ? Colors.white : Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      isFeatured ? Colors.white : primaryColor,
                      foregroundColor:
                      isFeatured ? primaryColor : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Appointment',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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

  final List<Map<String, dynamic>> doctors = [
    {
      'name': 'Dr. Greg Thorne',
      'specialty': 'General Doctor',
      'rating': '4.9',
      'reviews': '200+',
      'featured': true,
    },
    {
      'name': 'Dr. Sarah Wang',
      'specialty': 'General Doctor',
      'rating': '4.9',
      'reviews': '150+',
      'featured': false,
    },
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
              Text(
                'View all',
                style: TextStyle(
                  fontSize: 13,
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
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
              Text(
                'View all',
                style: TextStyle(
                  fontSize: 13,
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.014),

          SizedBox(
            height: screenHeight * 0.33,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                final doctor = doctors[index];
                return _DoctorCard(
                  doctor: doctor,
                  isFeatured: doctor['featured'] as bool,
                  primaryColor: primaryColor,
                );
              },
            ),
          ),
          SizedBox(height: screenHeight * 0.12),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  HOME SCREEN
// ─────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

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
    return _selectedIndex == 0
        ? BaseScaffold(
      title: _titles[_selectedIndex],
      drawerIndex: 0,
      bottomNavigationBar: CustomFluidBottomNavBar(
        currentIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
      body: _DashboardBody(),
    )
        : Scaffold(
      extendBody: true,
      body: _screens[_selectedIndex],
      bottomNavigationBar: CustomFluidBottomNavBar(
        currentIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }
}