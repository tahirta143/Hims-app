import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../custum widgets/drawer/base_scaffold.dart';
import '../../../providers/mr_provider/mr_provider.dart';

class MrDataViewScreen extends StatelessWidget {
  const MrDataViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'MR Data View',
      drawerIndex: 9,
      body: const _MrDataViewBody(),
    );
  }
}

class _MrDataViewBody extends StatelessWidget {
  const _MrDataViewBody();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      color: const Color(0xFFF0F4F8), // Light background
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04, // Responsive padding
          vertical: screenHeight * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Teal sub-header (redesigned as card)
            _buildSubHeader(context),
            const SizedBox(height: 16),

            // Search bar card
            _buildSearchBar(context),
            const SizedBox(height: 16),

            // Stats card
            _buildStatsBar(context),
            const SizedBox(height: 16),

            // Table card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Table header with title
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Registered Patients',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A202C),
                      ),
                    ),
                  ),
                  Divider(height: 1, color: Color(0xFFE2E8F0)),
                  // Table
                  SizedBox(
                    height: 400, // Fixed height for mobile
                    child: _PatientTable(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSubHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00B5AD), Color(0xFF00897B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00B5AD).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.people_alt_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MR Data View',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Master Patient Index',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Text(
                  'View and search all registered patients',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Search Patients',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A202C),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SearchField(),
              ),
              const SizedBox(width: 8),
              _IconActionButton(
                icon: Icons.refresh_rounded,
                onTap: () => context.read<MrProvider>().clearSearch(),
              ),
              const SizedBox(width: 8),
              _IconActionButton(
                icon: Icons.print_outlined,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar(BuildContext context) {
    final provider = context.watch<MrProvider>();
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00B5AD), Color(0xFF00897B)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00B5AD).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.people_outline,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TOTAL PATIENTS',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                _formatNumber(provider.totalPatients),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Page 1',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000) {
      final s = n.toString();
      final thousands = s.substring(0, s.length - 3);
      final rest = s.substring(s.length - 3);
      return '$thousands,$rest';
    }
    return n.toString();
  }
}

// ─── Search Field ─────────────────────────────────────────────────────────────
class _SearchField extends StatefulWidget {
  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      onChanged: (v) => context.read<MrProvider>().setSearchQuery(v),
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Search by MR No, Name, Phone...',
        hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 13),
        prefixIcon: const Icon(Icons.search,
            color: Color(0xFFBDBDBD), size: 20),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: Color(0xFF00B5AD), width: 1.5),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}

// ─── Icon Action Button ───────────────────────────────────────────────────────
class _IconActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconActionButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF718096)),
      ),
    );
  }
}

// ─── Patient Table ────────────────────────────────────────────────────────────
class _PatientTable extends StatelessWidget {
  const _PatientTable();

  @override
  Widget build(BuildContext context) {
    final patients = context.watch<MrProvider>().patients;

    if (patients.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded,
                size: 56, color: Color(0xFFCBD5E0)),
            SizedBox(height: 12),
            Text(
              'No patients found',
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: Color(0xFF718096)),
            ),
          ],
        ),
      );
    }

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          children: [
            // Fixed header that doesn't scroll vertically
            Container(
              color: const Color(0xFFF7FAFC),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 1000, // Reduced width for mobile
                  child: const Row(
                    children: [
                      _HeaderCell('#', flex: 1),
                      _HeaderCell('MR No', flex: 2),
                      _HeaderCell('Patient', flex: 3),
                      _HeaderCell('Guardian', flex: 2),
                      _HeaderCell('Phone', flex: 2),
                      _HeaderCell('CNIC', flex: 2),
                      _HeaderCell('Age', flex: 1),
                      _HeaderCell('Gender', flex: 1),
                      _HeaderCell('City', flex: 2),
                      _HeaderCell('Actions', flex: 2, align: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ),
        
            // Scrollable content (both vertical and horizontal)
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: 1000, // Match header width
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: patients.asMap().entries.map(
                            (e) => _PatientRow(
                          index: e.key + 1,
                          patient: e.value,
                          isEven: e.key % 2 == 0,
                        ),
                      ).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header Cell ─────────────────────────────────────────────────────────────
class _HeaderCell extends StatelessWidget {
  final String text;
  final int flex;
  final TextAlign align;

  const _HeaderCell(this.text,
      {this.flex = 1, this.align = TextAlign.left});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: align,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF718096),
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ─── Table Row ────────────────────────────────────────────────────────────────
class _PatientRow extends StatelessWidget {
  final int index;
  final PatientModel patient;
  final bool isEven;

  const _PatientRow({
    required this.index,
    required this.patient,
    required this.isEven,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isEven ? Colors.white : const Color(0xFFFAFAFA),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          // Sr #
          Expanded(
            flex: 1,
            child: Text('$index',
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF718096))),
          ),

          // MR Number
          Expanded(
            flex: 2,
            child: Text(
              patient.mrNumber,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A202C),
              ),
            ),
          ),

          // Patient Name
          Expanded(
            flex: 3,
            child: Text(
              patient.fullName.isEmpty ? '-' : patient.fullName,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A202C),
              ),
            ),
          ),

          // Guardian Name
          Expanded(
            flex: 2,
            child: Text(
              patient.guardianName.isEmpty ? '-' : patient.guardianName,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF4A5568)),
            ),
          ),

          // Phone
          Expanded(
            flex: 2,
            child: Text(
              patient.phoneNumber.isEmpty ? '-' : patient.phoneNumber,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF4A5568)),
            ),
          ),

          // CNIC
          Expanded(
            flex: 2,
            child: Text(
              patient.cnic.isEmpty ? '-' : patient.cnic,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF4A5568)),
            ),
          ),

          // Age
          Expanded(
            flex: 1,
            child: Text(
              patient.age != null ? patient.age.toString() : '-',
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF4A5568)),
            ),
          ),

          // Gender badge
          Expanded(
            flex: 1,
            child: _GenderBadge(gender: patient.gender),
          ),

          // City
          Expanded(
            flex: 2,
            child: Text(
              patient.city.isEmpty ? '-' : patient.city,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF4A5568)),
            ),
          ),

          // Actions
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ActionIcon(
                  icon: Icons.visibility_outlined,
                  color: const Color(0xFF00B5AD),
                  onTap: () => _showPatientDetails(context, patient),
                ),
                const SizedBox(width: 4),
                _ActionIcon(
                  icon: Icons.delete_outline_rounded,
                  color: const Color(0xFFE53E3E),
                  onTap: () => _confirmDelete(context, patient),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPatientDetails(BuildContext context, PatientModel p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B5AD).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.person_outline,
                        color: Color(0xFF00B5AD), size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.fullName.isEmpty ? p.mrNumber : p.fullName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text('MR Number: ${p.mrNumber}',
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFF718096))),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFFE2E8F0)),
            // Details
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildDetailTile(Icons.person, 'Gender', p.gender),
                  _buildDetailTile(Icons.cake, 'Age', p.age?.toString() ?? '-'),
                  _buildDetailTile(Icons.phone, 'Phone', p.phoneNumber.isEmpty ? '-' : p.phoneNumber),
                  _buildDetailTile(Icons.badge, 'CNIC', p.cnic.isEmpty ? '-' : p.cnic),
                  _buildDetailTile(Icons.family_restroom, 'Guardian', p.guardianName.isEmpty ? '-' : p.guardianName),
                  _buildDetailTile(Icons.location_city, 'City', p.city.isEmpty ? '-' : p.city),
                  _buildDetailTile(Icons.bloodtype, 'Blood Group', p.bloodGroup.isEmpty ? '-' : p.bloodGroup),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF718096)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF718096),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A202C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, PatientModel p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Patient?'),
        content: Text(
            'Are you sure you want to remove ${p.fullName.isEmpty ? p.mrNumber : p.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF718096),
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<MrProvider>().deletePatient(p.mrNumber);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Patient removed successfully'),
                  backgroundColor: const Color(0xFF00B5AD),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53E3E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ─── Gender Badge ─────────────────────────────────────────────────────────────
class _GenderBadge extends StatelessWidget {
  final String gender;

  const _GenderBadge({required this.gender});

  @override
  Widget build(BuildContext context) {
    final isFemale = gender.toLowerCase() == 'female' || gender.toLowerCase() == 'f';
    final isMale = gender.toLowerCase() == 'male' || gender.toLowerCase() == 'm';

    Color color;
    if (isFemale) {
      color = const Color(0xFFED64A6);
    } else if (isMale) {
      color = const Color(0xFF00B5AD);
    } else {
      color = const Color(0xFF718096);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        gender.isEmpty ? '-' : gender,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ─── Action Icon ──────────────────────────────────────────────────────────────
class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}