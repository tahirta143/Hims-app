import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final Function(int) onMenuItemTap;
  final int selectedIndex;

  static const Color primaryColor = Color(0xFF00B5AD);
  static const Color darkTeal = Color(0xFF00897B);

  const CustomDrawer({
    super.key,
    required this.onMenuItemTap,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double topPadding = MediaQuery.of(context).padding.top;

    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // ── Header ──
            Container(
              padding: EdgeInsets.fromLTRB(
                20,
                topPadding + 24,
                20,
                24,
              ),
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white24,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  const Text(
                    'John Doe',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'john.doe@email.com',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // ── Menu Items ──
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildDrawerItem(
                    icon: Icons.dashboard_rounded,
                    title: 'Dashboard',
                    index: 0,
                  ),
                  _buildDrawerItem(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'Consultation Appointment',
                    index: 1,
                  ),
                  // _buildDrawerItem(
                  //   icon: Icons.calendar_today_rounded,
                  //   title: 'Appointment',
                  //   index: 2,
                  // ),

                  // Divider for separation
                  // const Padding(
                  //   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  //   child: Divider(),
                  // ),

                  // Patient MR No
                  _buildDrawerItem(
                    icon: Icons.money,
                    title: 'Add Expenses',
                    index: 2,
                  ),

                  // OPD Receipt
                  _buildDrawerItem(
                    icon: Icons.receipt_rounded,
                    title: 'OPD Receipt',
                    index: 3,
                  ),_buildDrawerItem(
                    icon: Icons.receipt_rounded,
                    title: 'OPD Records',
                    index: 4,
                  ),
                  // Emergency Treatment
                  _buildDrawerItem(
                    icon: Icons.local_hospital_rounded,
                    title: 'Emergency Treatment',
                    index: 5,
                  ),

                  // Consultation Payments
                  _buildDrawerItem(
                    icon: Icons.payment_rounded,
                    title: 'Consultation Payments',
                    index: 6,
                  ),
                  _buildDrawerItem(
                    icon: Icons.filter_tilt_shift,
                    title: 'Shift Management',
                    index: 7,
                  ),
                  _buildDrawerItem(
                    icon: Icons.person_outline_rounded, // or Icons.medical_services_outlined
                    title: 'MR Details',
                    index: 8,
                  ),
                  _buildDrawerItem(
                    icon: Icons.visibility_outlined, // or Icons.remove_red_eye_outlined
                    title: 'MR View',
                    index: 9,
                  ), _buildDrawerItem(
                    icon: Icons.visibility_outlined, // or Icons.remove_red_eye_outlined
                    title: 'Discount Voucher',
                    index: 10,
                  ),
                ],
              ),
            ),

            // ── Footer ──
            Container(
              padding: const EdgeInsets.all(16),
              child: _buildDrawerItem(
                icon: Icons.logout_rounded,
                title: 'Logout',
                index: -1,
                isLogout: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required int index,
    bool isLogout = false,
  }) {
    final bool isSelected = selectedIndex == index && !isLogout;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: isSelected ? primaryColor.withOpacity(0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryColor.withOpacity(0.15)
                : isLogout
                ? Colors.red.withOpacity(0.08)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isSelected
                ? primaryColor
                : isLogout
                ? Colors.red.shade400
                : Colors.grey.shade500,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected
                ? primaryColor
                : isLogout
                ? Colors.red.shade400
                : Colors.black87,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
        trailing: isSelected
            ? Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(4),
          ),
        )
            : null,
        onTap: () => onMenuItemTap(index),
      ),
    );
  }
}
