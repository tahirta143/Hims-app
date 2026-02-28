import 'package:flutter/material.dart';
import 'package:hims_app/screens/cunsultations/cunsultations.dart';
import 'package:hims_app/screens/discount_vouchers/discount_vouchers.dart';
import 'package:hims_app/screens/emergency_treatment/emergency_treatment.dart';
import 'package:hims_app/screens/mr_details/mr_details.dart';
import 'package:hims_app/screens/mr_details/mr_view/mr_view.dart';
import 'package:hims_app/screens/opd_reciepts/opd_reciept.dart';
import 'package:hims_app/screens/opd_reciepts/opd_records.dart';
import 'package:hims_app/screens/consultation_payments/consultation_payments.dart';
import 'package:hims_app/screens/shift_management/shift_management.dart';
import '../../screens/add_expenses/add_expenses.dart';
import '../../screens/dashboard/dashboard.dart';
import 'drawer.dart';

class BaseScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final int drawerIndex;
  final bool showAppBar;
  final bool showNotificationIcon;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  // Make this nullable and don't create it here
  final GlobalKey<ScaffoldState>? scaffoldKey;

  static const Color primaryColor = Color(0xFF00B5AD);

  BaseScaffold({
    super.key,
    required this.body,
    required this.title,
    required this.drawerIndex,
    this.showAppBar = true,
    this.showNotificationIcon = true,
    this.actions,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.scaffoldKey, // Add this parameter
  });

  @override
  @override
  Widget build(BuildContext context) {
    final effectiveKey = scaffoldKey ?? GlobalKey<ScaffoldState>();

    return Scaffold(
      key: effectiveKey,
      extendBody: true, // keep this

      drawer: CustomDrawer(
        selectedIndex: drawerIndex,
        onMenuItemTap: (index) {
          Navigator.pop(context);
          if (index != drawerIndex) {
            _navigateToScreen(context, index);
          }
        },
      ),

      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,

      // ✅ MOVE bottomNavigationBar HERE
      bottomNavigationBar: bottomNavigationBar,

      // ✅ REMOVE bottom nav from Column
      body: Column(
        children: [
          if (showAppBar) _buildHeader(context, effectiveKey),
          Expanded(child: body),
        ],
      ),
    );
  }
  Widget _buildHeader(BuildContext context, GlobalKey<ScaffoldState> scaffoldKey) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        bottom: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Menu button
              GestureDetector(
                onTap: () {
                  scaffoldKey.currentState?.openDrawer();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.menu_rounded,
                      color: Colors.white, size: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Custom actions or notification icon
              if (actions != null) ...actions!,
              if (showNotificationIcon && actions == null)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.notifications_outlined,
                      color: Colors.white, size: 22),
                ),
            ],
          ),
          if (title == 'Dashboard')
            Padding(
              padding: const EdgeInsets.only(left: 42, top: 4),
              child: Text(
                'Good morning, Dr. John 👋',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _navigateToScreen(BuildContext context, int index) {
    Widget screen;

    switch (index) {
      case 0:
        screen = const HomeScreen();
        break;
      case 1:
        screen = const ConsultationScreen();
        break;
      case 2:
        screen = const ExpensesScreen();
        break;
      case 3:
        screen = const OpdReceiptScreen();
        break;
      case 4:
        screen = const OpdRecordsScreen();
        break;
      case 5:
        screen = const EmergencyTreatmentScreen();
        break;
      case 6:
        screen = const ConsultantPaymentsScreen();
        break;
      case 7:
        screen = const ShiftManagementScreen();
        break;
      case 8:
        screen = const MrDetailsScreen();
        break;
      case 9:
        screen = const MrDataViewScreen();
        break;
      case 10:
        screen = const DiscountVoucherApprovalScreen();
        break;
      case -1: // Logout
        _showLogoutDialog(context);
        return;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Implement your logout logic here
                Navigator.pushReplacementNamed(context, '/SignInScreen');
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}