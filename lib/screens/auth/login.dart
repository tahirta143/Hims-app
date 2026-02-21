import 'package:flutter/material.dart';
import 'package:hims_app/screens/auth/sign_up.dart';
import '../dashboard/dashboard.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // User type selection
  bool _isDoctor = false;
  bool _isPatient = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onUserTypeChanged(String type, bool? value) {
    setState(() {
      if (type == 'doctor') {
        _isDoctor = value ?? false;
        if (_isDoctor) {
          _isPatient = false;
        }
      } else if (type == 'patient') {
        _isPatient = value ?? false;
        if (_isPatient) {
          _isDoctor = false;
        }
      }
    });
  }

  void _handleSignUpNavigation() {
    if (_isPatient) {
      // Navigate to sign up if patient is selected
      Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SignUpScreen())
      );
    } else {
      // Show message if doctor is selected or no selection
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isDoctor
                ? 'Doctor sign up is not available. Please contact administration.'
                : 'Please select Patient to sign up',
            style: const TextStyle(fontSize: 14),
          ),
          backgroundColor: _isDoctor ? Colors.orange : const Color(0xFF00B5AD),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenW = mq.size.width;
    final screenH = mq.size.height;

    final hPad = screenW * 0.07;
    final headerH = screenH * 0.30;
    final logoSize = screenW * 0.18;
    final logoIconSize = screenW * 0.10;
    final titleFontSize = screenW * 0.062;
    final inputFontSize = screenW * 0.038;
    final btnFontSize = screenW * 0.042;
    final socialBtnSize = screenW * 0.13;

    return Scaffold(
      backgroundColor: const Color(0xFF00B5AD),
      body: Column(
        children: [
          // ── Teal Header ─────────────────────────────────────────────
          SizedBox(
            height: headerH,
            child: SafeArea(
              bottom: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo icon circle
                    Container(
                      width: logoSize,
                      height: logoSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.20),
                      ),
                      child: Center(
                        child: CustomPaint(
                          size: Size(logoIconSize, logoIconSize),
                          painter: _BandagePainter(),
                        ),
                      ),
                    ),
                    SizedBox(height: screenH * 0.012),
                    Text(
                      'HIMS',
                      style: TextStyle(
                        fontSize: screenW * 0.055,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── White Body ───────────────────────────────────────────────
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: hPad, vertical: screenH * 0.035),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    Text(
                      'Sign in',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF00B5AD),
                      ),
                    ),
                    SizedBox(height: screenH * 0.020),

                    // ── User Type Selection (Doctor/Patient) ──
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenW * 0.02,
                        vertical: screenH * 0.012,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Checkbox(
                                  value: _isDoctor,
                                  onChanged: (value) => _onUserTypeChanged('doctor', value),
                                  activeColor: const Color(0xFF00B5AD),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Login as Doctor',
                                    style: TextStyle(
                                      fontSize: inputFontSize,
                                      color: Colors.black87,
                                      fontWeight: _isDoctor ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Checkbox(
                                  value: _isPatient,
                                  onChanged: (value) => _onUserTypeChanged('patient', value),
                                  activeColor: const Color(0xFF00B5AD),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Login as Patient',
                                    style: TextStyle(
                                      fontSize: inputFontSize,
                                      color: Colors.black87,
                                      fontWeight: _isPatient ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenH * 0.020),

                    // Email Field
                    _InputField(
                      controller: _emailController,
                      hint: 'Email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      fontSize: inputFontSize,
                    ),
                    SizedBox(height: screenH * 0.016),

                    // Password Field
                    _InputField(
                      controller: _passwordController,
                      hint: 'Password',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      fontSize: inputFontSize,
                      suffixIcon: GestureDetector(
                        onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                        child: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: Colors.grey,
                          size: screenW * 0.045,
                        ),
                      ),
                    ),
                    SizedBox(height: screenH * 0.010),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          // Handle forgot password
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontSize: inputFontSize,
                            color: const Color(0xFF00B5AD),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenH * 0.028),

                    // Sign In Button
                    SizedBox(
                      height: screenH * 0.062,
                      child: ElevatedButton(
                        onPressed: () {
                          // Validate user type selection
                          if (!_isDoctor && !_isPatient) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Please select user type (Doctor or Patient)'),
                                backgroundColor: const Color(0xFF00B5AD),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                margin: EdgeInsets.all(hPad),
                              ),
                            );
                            return;
                          }

                          // Navigate to dashboard
                          Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const HomeScreen())
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B5AD),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: btnFontSize,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenH * 0.022),

                    // Don't have account
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have account? ",
                          style: TextStyle(
                            fontSize: inputFontSize,
                            color: Colors.grey,
                          ),
                        ),
                        GestureDetector(
                          onTap: _handleSignUpNavigation,
                          child: Text(
                            'Sign up',
                            style: TextStyle(
                              fontSize: inputFontSize,
                              color: const Color(0xFF00B5AD),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenH * 0.028),

                    // Divider
                    Row(
                      children: [
                        const Expanded(child: Divider(color: Color(0xFFE0E0E0))),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: screenW * 0.03),
                          child: Text(
                            'Or Sign In with',
                            style: TextStyle(
                              fontSize: inputFontSize * 0.9,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider(color: Color(0xFFE0E0E0))),
                      ],
                    ),
                    SizedBox(height: screenH * 0.024),

                    // Social Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SocialButton(label: 'f', size: socialBtnSize, fontSize: inputFontSize * 1.1),
                        SizedBox(width: screenW * 0.04),
                        _SocialButton(label: 'G', size: socialBtnSize, fontSize: inputFontSize * 1.1),
                        SizedBox(width: screenW * 0.04),
                        _SocialButton(label: 'X', size: socialBtnSize, fontSize: inputFontSize * 1.1),
                      ],
                    ),
                    SizedBox(height: screenH * 0.02),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable Input Field ───────────────────────────────────────────────────────
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final double fontSize;
  final Widget? suffixIcon;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    required this.fontSize,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: fontSize),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: fontSize),
        prefixIcon: Icon(prefixIcon, color: Colors.grey.shade400, size: fontSize * 1.3),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00B5AD), width: 1.5),
        ),
      ),
    );
  }
}

// ── Social Button ─────────────────────────────────────────────────────────────
class _SocialButton extends StatelessWidget {
  final String label;
  final double size;
  final double fontSize;

  const _SocialButton({
    required this.label,
    required this.size,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
          color: Colors.white,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Bandage Icon Painter ───────────────────────────────────────────────────────
class _BandagePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final dotPaint = Paint()
      ..color = const Color(0xFF1ABC9C)
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(45 * 3.14159265 / 180);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: size.width * 0.32, height: size.height * 0.82),
        Radius.circular(size.width * 0.16),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: size.width * 0.82, height: size.height * 0.32),
        Radius.circular(size.height * 0.16),
      ),
      paint,
    );
    canvas.restore();

    final r = size.width * 0.04;
    final o = size.width * 0.22;
    for (final pt in [
      Offset(cx - o, cy - o * 0.5), Offset(cx - o * 0.5, cy - o),
      Offset(cx + o, cy - o * 0.5), Offset(cx + o * 0.5, cy - o),
      Offset(cx - o, cy + o * 0.5), Offset(cx - o * 0.5, cy + o),
      Offset(cx + o, cy + o * 0.5), Offset(cx + o * 0.5, cy + o),
    ]) {
      canvas.drawCircle(pt, r, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}