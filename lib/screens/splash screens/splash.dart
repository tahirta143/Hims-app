import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _circleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    // Navigate to next screen after splash
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OnboardingScreen()));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00B5AD), // Teal/Mint color
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Circle with icon
                Transform.scale(
                  scale: _circleAnimation.value,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: const Center(
                        child: _MedicalCrossIcon(size: 90),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // App Name
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

/// Custom painter for the bandage/medical cross icon (matching Docare style)
class _MedicalCrossIcon extends StatelessWidget {
  final double size;
  const _MedicalCrossIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _BandagePainter(),
    );
  }
}

class _BandagePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final dotPaint = Paint()
      ..color = const Color(0xFF1ABC9C)
      ..style = PaintingStyle.fill;

    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;

    // Draw rotated bandage shape (X shape) — two rounded rectangles rotated 45 deg
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(45 * 3.14159265 / 180);

    // Vertical strip
    final RRect vertRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: w * 0.32, height: h * 0.82),
      Radius.circular(w * 0.16),
    );
    canvas.drawRRect(vertRect, paint);

    // Horizontal strip
    final RRect horizRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: w * 0.82, height: h * 0.32),
      Radius.circular(h * 0.16),
    );
    canvas.drawRRect(horizRect, paint);

    // Center square (overlap area)
    final RRect centerRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: w * 0.32, height: h * 0.32),
      Radius.circular(4),
    );
    canvas.drawRRect(centerRect, paint);

    canvas.restore();

    // Dots on the bandage strips
    final double dotR = w * 0.04;
    final double offset = w * 0.22;

    // Top-left dots
    canvas.drawCircle(Offset(cx - offset, cy - offset * 0.5), dotR, dotPaint);
    canvas.drawCircle(Offset(cx - offset * 0.5, cy - offset), dotR, dotPaint);

    // Top-right dots
    canvas.drawCircle(Offset(cx + offset, cy - offset * 0.5), dotR, dotPaint);
    canvas.drawCircle(Offset(cx + offset * 0.5, cy - offset), dotR, dotPaint);

    // Bottom-left dots
    canvas.drawCircle(Offset(cx - offset, cy + offset * 0.5), dotR, dotPaint);
    canvas.drawCircle(Offset(cx - offset * 0.5, cy + offset), dotR, dotPaint);

    // Bottom-right dots
    canvas.drawCircle(Offset(cx + offset, cy + offset * 0.5), dotR, dotPaint);
    canvas.drawCircle(Offset(cx + offset * 0.5, cy + offset), dotR, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}