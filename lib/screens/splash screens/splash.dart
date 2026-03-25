import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hims_app/core/providers/permission_provider.dart';
import 'package:hims_app/core/services/auth_storage_service.dart';
import '../../providers/mobile_auth_provider.dart';
import '../main_shell.dart';
import '../patient/patient_dashboard.dart';
import '../doctor/mobile_doctor_dashboard.dart';
import 'onboarding.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _circleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _circleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOut)));
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.2, 0.7, curve: Curves.elasticOut)));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.5, 1.0, curve: Curves.easeIn)));
    _controller.forward();

    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Wait for splash animation to be visible
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    try {
      final storage = AuthStorageService();
      final token = await storage.getToken().timeout(
        const Duration(seconds: 5),
        onTimeout: () => null,
      );
      final role = await storage.getRole().timeout(
        const Duration(seconds: 5),
        onTimeout: () => null,
      );

      if (!mounted) return;

      if (token != null && token.isNotEmpty) {
        final mobileProvider = context.read<MobileAuthProvider>();

        if (role == 'patient') {
          // Timeout auto-login — don't hang if server is unreachable
          await mobileProvider.tryAutoLogin().timeout(
            const Duration(seconds: 6),
            onTimeout: () {},
          );
          if (!mounted) return;
          _goTo(const PatientDashboard());

        } else if (role == 'doctor') {
          await mobileProvider.tryAutoLogin().timeout(
            const Duration(seconds: 6),
            onTimeout: () {},
          );
          if (!mounted) return;
          _goTo(const MobileDoctorDashboard());

        } else {
          final permProvider = context.read<PermissionProvider>();

          // Load cached permissions first (fast, local)
          await permProvider.loadFromStorage().timeout(
            const Duration(seconds: 3),
            onTimeout: () {},
          );

          // Sync from server with timeout — if it fails, cached perms are used
          try {
            await permProvider.syncFromServer().timeout(
              const Duration(seconds: 6),
            );
          } catch (_) {
            // Server unreachable — continue with cached permissions
          }

          if (!mounted) return;
          _goTo(const MainShell());
        }
      } else {
        _goTo(const OnboardingScreen());
      }
    } catch (e) {
      debugPrint('Splash Auth Error: $e');
      if (!mounted) return;
      _goTo(const OnboardingScreen());
    }
  }

  void _goTo(Widget screen) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00B5AD),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.scale(
                  scale: _circleAnimation.value,
                  child: Container(
                    width: 140,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: Center(
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: const Icon(Icons.emergency_outlined,
                            size: 70, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Text(
                    'HIMS',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}