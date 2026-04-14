import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../global/global_api.dart';
import '../../providers/mobile_auth_provider.dart';
import '../../custum widgets/custom_loader.dart';
import '../auth/login.dart';
import 'doctor_booking_screen.dart';
import 'my_appointments_screen.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  List<dynamic> _doctors = [];
  List<String> _departments = [];
  String? _selectedDepartment;
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final authProvider = context.read<MobileAuthProvider>();
    final deptsResult = await authProvider.fetchDepartments();
    final docsResult = await authProvider.fetchDoctors();

    if (mounted) {
      setState(() {
        if (deptsResult['success'] == true) {
          _departments = List<String>.from(deptsResult['data']);
        }
        if (docsResult['success'] == true) {
          _doctors = docsResult['data'];
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _filterDoctors() async {
    setState(() => _isLoading = true);
    final authProvider = context.read<MobileAuthProvider>();
    final result = await authProvider.fetchDoctors(
      department: _selectedDepartment,
      search: _searchQuery.isEmpty ? null : _searchQuery,
    );
    if (mounted) {
      setState(() {
        if (result['success'] == true) {
          _doctors = result['data'];
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<MobileAuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00B5AD),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('HIMS Patient Portal', style: TextStyle(fontSize: 14, color: Colors.white70)),
            Text('Hello, ${user?.fullName ?? 'Patient'}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            tooltip: 'My Appointments',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyAppointmentsScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () {
              context.read<MobileAuthProvider>().logout();
              // Navigate back to the very first screen (Staff Login)
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const SignInScreen()), 
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search & Filter ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF00B5AD),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                TextField(
                  onChanged: (val) {
                    _searchQuery = val;
                    _filterDoctors();
                  },
                  decoration: InputDecoration(
                    hintText: 'Search doctors or specialties...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF00B5AD)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _FilterChip(
                        label: 'All Doctors',
                        isSelected: _selectedDepartment == null,
                        onTap: () {
                          setState(() => _selectedDepartment = null);
                          _filterDoctors();
                        },
                      ),
                      ..._departments.map((dept) => _FilterChip(
                        label: dept,
                        isSelected: _selectedDepartment == dept,
                        onTap: () {
                          setState(() => _selectedDepartment = dept);
                          _filterDoctors();
                        },
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          // ── Doctor List ────────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CustomLoader(size: 50, color: Color(0xFF00B5AD)))
                : RefreshIndicator(
                    onRefresh: _loadInitialData,
                    child: _doctors.isEmpty
                        ? const Center(child: Text('No doctors found'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _doctors.length,
                            itemBuilder: (context, index) {
                              final doctor = _doctors[index];
                              return _DoctorCard(
                                doctor: doctor,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DoctorBookingScreen(doctor: doctor),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white24,
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF00B5AD) : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final dynamic doctor;
  final VoidCallback onTap;

  const _DoctorCard({required this.doctor, required this.onTap});


  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final primaryColor = const Color(0xFF00B5AD);
    final String availableDays = doctor['available_days'] ?? '';
    final int slotsCount = doctor['available_slots_count'] ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor['doctor_name'] ?? 'Unknown Doctor',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          doctor['doctor_specialization'] ?? 'Specialist',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Rs. ${doctor['consultation_fee']}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Builder(
                      builder: (context) {
                        final url = GlobalApi.getImageUrl(doctor['image_url']);
                        if (url != null) {
                          return CachedNetworkImage(
                            imageUrl: url,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            placeholder: (context, _) => _buildAvatarFallback(primaryColor),
                            errorWidget: (context, _, __) => _buildAvatarFallback(primaryColor),
                          );
                        }
                        return _buildAvatarFallback(primaryColor);
                      },
                    ),
                  ),
                ],
              ),
              // const SizedBox(height: 16),
              // Row(
              //   children: [
              //     Icon(Icons.access_time, size: 16, color: slotsCount > 0 ? Colors.green : Colors.red),
              //     const SizedBox(width: 6),
              //     Text(
              //       slotsCount > 0 ? '$slotsCount Slots Available Today' : 'No Slots Today',
              //       style: TextStyle(
              //         fontSize: 13,
              //         color: slotsCount > 0 ? Colors.green : Colors.red,
              //         fontWeight: FontWeight.w600,
              //       ),
              //     ),
              //   ],
              // ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildDayChip('Mon', availableDays.contains('Mon')),
                  _buildDayChip('Tue', availableDays.contains('Tue')),
                  _buildDayChip('Wed', availableDays.contains('Wed')),
                  _buildDayChip('Thu', availableDays.contains('Thu')),
                  _buildDayChip('Fri', availableDays.contains('Fri')),
                  _buildDayChip('Sat', availableDays.contains('Sat')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarFallback(Color primaryColor) {
    return Container(
      width: 80,
      height: 80,
      color: primaryColor.withOpacity(0.1),
      child: Icon(Icons.person, size: 40, color: primaryColor),
    );
  }

  Widget _buildDayChip(String day, bool isAvailable) {
    final primaryColor = const Color(0xFF00B5AD);
    return Container(
      width: 45,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: isAvailable ? primaryColor : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          day,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isAvailable ? Colors.white : Colors.grey.shade500,
          ),
        ),
      ),
    );
  }
}
