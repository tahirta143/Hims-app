import 'package:flutter/material.dart';
import 'package:hims_app/core/permissions/permission_keys.dart';
import 'package:hims_app/core/providers/permission_provider.dart';
import 'package:hims_app/core/services/auth_storage_service.dart';
import 'package:hims_app/screens/auth/login.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatelessWidget {
  final Function(int) onMenuItemTap;
  final int selectedIndex;

  static const Color primaryColor = Color(0xFF00B5AD);
  static const Color darkTeal     = Color(0xFF00897B);

  const CustomDrawer({
    super.key,
    required this.onMenuItemTap,
    required this.selectedIndex,
  });

  Future<void> _handleLogout(BuildContext context) async {
    // Clear permissions from memory
    context.read<PermissionProvider>().clear();
    // Clear all stored data (token, user info, permissions)
    await AuthStorageService().clearAll();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double topPadding   = MediaQuery.of(context).padding.top;
    final perm = context.watch<PermissionProvider>();

    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(20, topPadding + 24, 20, 24),
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, darkTeal],
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
                      child: Icon(Icons.person, color: Colors.white, size: 35),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  // Show admin badge if super admin
                  if (perm.isAdmin)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '⭐ Super Admin',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  const Text(
                    'HIMS User',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Hospital Management System',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),

            // ── Menu Items ───────────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  // Dashboard — always visible
                  _buildDrawerItem(
                    icon: Icons.dashboard_rounded,
                    title: 'Dashboard',
                    index: 0,
                  ),

                  // Consultation Appointment — needs OPD patient read
                  if (perm.canAny([Perm.opdPatientRead, Perm.apptRead]))
                    _buildDrawerItem(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'Consultation Appointment',
                      index: 1,
                    ),

                  // Add Expenses
                  if (perm.canAny([Perm.expenseRead, Perm.expenseCreate]))
                    _buildDrawerItem(
                      icon: Icons.money,
                      title: 'Add Expenses',
                      index: 2,
                    ),

                  // OPD Receipt
                  if (perm.canAny([Perm.opdReceiptRead, Perm.opdReceiptCreate]))
                    _buildDrawerItem(
                      icon: Icons.receipt_rounded,
                      title: 'OPD Receipt',
                      index: 3,
                    ),

                  // OPD Records (Patient)
                  if (perm.can(Perm.opdPatientRead))
                    _buildDrawerItem(
                      icon: Icons.folder_shared_rounded,
                      title: 'OPD Records',
                      index: 4,
                    ),

                  // Emergency Treatment
                  if (perm.canAny([Perm.emergencyRead, Perm.emergencyCreate]))
                    _buildDrawerItem(
                      icon: Icons.local_hospital_rounded,
                      title: 'Emergency Treatment',
                      index: 5,
                    ),

                  // Consultation Payments
                  if (perm.canAny([Perm.consultantRead, Perm.consultantCreate]))
                    _buildDrawerItem(
                      icon: Icons.payment_rounded,
                      title: 'Consultation Payments',
                      index: 6,
                    ),

                  // Shift Management
                  if (perm.canAny([Perm.opdShiftRead, Perm.opdShiftCreate, Perm.opdShiftCashRead]))
                    _buildDrawerItem(
                      icon: Icons.filter_tilt_shift,
                      title: 'Shift Management',
                      index: 7,
                    ),

                  // MR Details
                  if (perm.canAny([Perm.mrRead, Perm.mrCreate]))
                    _buildDrawerItem(
                      icon: Icons.person_outline_rounded,
                      title: 'MR Details',
                      index: 8,
                    ),

                  // MR View
                  if (perm.can(Perm.mrRead))
                    _buildDrawerItem(
                      icon: Icons.visibility_outlined,
                      title: 'MR View',
                      index: 9,
                    ),

                  // Discount Voucher
                  if (perm.canAny([Perm.opdReceiptRead, Perm.setupDiscountTypeRead]))
                    _buildDrawerItem(
                      icon: Icons.discount_outlined,
                      title: 'Discount Voucher',
                      index: 10,
                    ),
                  if (perm.canAny([Perm.apptRead,]))
                    _buildDrawerItem(
                      icon: Icons.timelapse_outlined,
                      title: 'Appointment Reports',
                      index: 11,
                    ),

                ],
              ),
            ),

            // ── Footer / Logout ───────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              child: _buildLogoutItem(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutItem(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.logout_rounded, size: 20, color: Colors.red.shade400),
        ),
        title: Text(
          'Logout',
          style: TextStyle(
            color: Colors.red.shade400,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        onTap: () => _handleLogout(context),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    final bool isSelected = selectedIndex == index;

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
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isSelected ? primaryColor : Colors.grey.shade500,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? primaryColor : Colors.black87,
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
