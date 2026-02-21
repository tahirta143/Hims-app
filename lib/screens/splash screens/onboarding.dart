import 'package:flutter/material.dart';

import '../auth/login.dart';

class OnboardingData {
  final String title;
  final String subtitle;
  final String imagePath;

  const OnboardingData({
    required this.title,
    required this.subtitle,
    required this.imagePath,
  });
}

const List<OnboardingData> onboardingPages = [
  OnboardingData(
    title: 'Find Your Trusted\nSpecialist',
    subtitle: 'A wide network of certified doctors and specialists',
    imagePath: 'assets/images/onboard4.png',
  ),
  OnboardingData(
    title: 'Consult Anytime,\nAnywhere',
    subtitle: 'Connect with medical experts instantly via video call.',
    imagePath: 'assets/images/onboard2.png',
  ),
  OnboardingData(
    title: 'Easy Appointment\nBooking',
    subtitle: 'Schedule your visit with just a few taps, anytime.',
    imagePath: 'assets/images/onboard3.png',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _nextPage() {
    if (_currentPage < onboardingPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // Last page → navigate to login/home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SignInScreen()),
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ── MediaQuery ─────────────────────────────────────────────────────────
    final mq        = MediaQuery.of(context);
    final screenH   = mq.size.height;
    final screenW   = mq.size.width;

    // Responsive values derived from screen dimensions
    final hPad            = screenW * 0.06;    // horizontal page padding
    final navVPad         = screenH * 0.018;   // nav row vertical padding
    final btnSize         = screenW * 0.115;   // circle button diameter
    final btnIconSize     = screenW * 0.048;   // icon inside button
    final cardRadius      = screenW * 0.05;    // border radius for cards
    final titleFontSize   = screenW * 0.062;   // ~24 sp on 390 px screen
    final subtitleFontSize= screenW * 0.036;   // ~14 sp
    final cardHPad        = screenW * 0.06;
    final cardVPad        = screenH * 0.026;
    final gapBelowCard    = screenH * 0.025;
    final dotBarH         = screenH * 0.07;
    final dotH            = screenH * 0.011;
    final dotActiveW      = screenW * 0.065;
    final dotInactiveW    = screenW * 0.022;
    // ───────────────────────────────────────────────────────────────────────

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2), // light-grey app bg
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Navigation Row ─────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: hPad,
                vertical: navVPad,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleButton(
                    onTap: _prevPage,
                    filled: false,
                    size: btnSize,
                    child: Icon(
                      Icons.arrow_back,
                      color: const Color(0xFF00B5AD),
                      size: btnIconSize,
                    ),
                  ),
                  _CircleButton(
                    onTap: _nextPage,
                    filled: _currentPage == onboardingPages.length - 1,
                    size: btnSize,
                    child: Icon(
                      Icons.arrow_forward,
                      color: _currentPage == onboardingPages.length - 1
                          ? Colors.white
                          : const Color(0xFF00B5AD),
                      size: btnIconSize,
                    ),
                  ),
                ],
              ),
            ),

            // ── PageView ───────────────────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: onboardingPages.length,
                itemBuilder: (context, index) {
                  return _OnboardingPage(
                    data: onboardingPages[index],
                    hPad: hPad,
                    cardRadius: cardRadius,
                    cardHPad: cardHPad,
                    cardVPad: cardVPad,
                    gapBelowCard: gapBelowCard,
                    titleFontSize: titleFontSize,
                    subtitleFontSize: subtitleFontSize,
                    screenH: screenH,
                  );
                },
              ),
            ),

            // ── Dot Indicators ─────────────────────────────────────────────
            SizedBox(
              height: dotBarH,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  onboardingPages.length,
                      (i) => _DotIndicator(
                    isActive: i == _currentPage,
                    activeW: dotActiveW,
                    inactiveW: dotInactiveW,
                    height: dotH,
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

// ── Single Onboarding Page ─────────────────────────────────────────────────────
class _OnboardingPage extends StatelessWidget {
  final OnboardingData data;
  final double hPad;
  final double cardRadius;
  final double cardHPad;
  final double cardVPad;
  final double gapBelowCard;
  final double titleFontSize;
  final double subtitleFontSize;
  final double screenH;

  const _OnboardingPage({
    required this.data,
    required this.hPad,
    required this.cardRadius,
    required this.cardHPad,
    required this.cardVPad,
    required this.gapBelowCard,
    required this.titleFontSize,
    required this.subtitleFontSize,
    required this.screenH,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── White Speech-Bubble Card ──────────────────────────────────
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: cardHPad,
              vertical: cardVPad,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(cardRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title — teal bold
                Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF00B5AD),
                    height: 1.3,
                  ),
                ),
                SizedBox(height: screenH * 0.012),

                // Subtitle — grey
                Text(
                  data.subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: subtitleFontSize,
                    color: const Color(0xFFAAAAAA),
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: gapBelowCard),

          // ── Grey Image Placeholder ────────────────────────────────────
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFDFDFDF),
                borderRadius: BorderRadius.circular(cardRadius),
              ),
              clipBehavior: Clip.hardEdge,
              child: _AssetImageWithFallback(imagePath: data.imagePath),
            ),
          ),

          SizedBox(height: screenH * 0.02),
        ],
      ),
    );
  }
}

// ── Asset Image with Grey Fallback ────────────────────────────────────────────
class _AssetImageWithFallback extends StatelessWidget {
  final String imagePath;
  const _AssetImageWithFallback({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        // Shows the same grey box as in the mockup when image is missing
        return Container(
          color: const Color(0xFFDFDFDF),
          child: const Center(
            child: Icon(
              Icons.image_outlined,
              size: 64,
              color: Color(0xFFBBBBBB),
            ),
          ),
        );
      },
    );
  }
}

// ── Circle Button ─────────────────────────────────────────────────────────────
class _CircleButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  final bool filled;
  final double size;

  const _CircleButton({
    required this.onTap,
    required this.child,
    required this.size,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? const Color(0xFF00B5AD) : Colors.transparent,
          border: filled
              ? null
              : Border.all(color: const Color(0xFF00B5AD), width: 1.5),
        ),
        child: Center(child: child),
      ),
    );
  }
}

// ── Dot Indicator ─────────────────────────────────────────────────────────────
class _DotIndicator extends StatelessWidget {
  final bool isActive;
  final double activeW;
  final double inactiveW;
  final double height;

  const _DotIndicator({
    required this.isActive,
    required this.activeW,
    required this.inactiveW,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: inactiveW * 0.35),
      width: isActive ? activeW : inactiveW,
      height: height,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF00B5AD) : const Color(0xFFD0D0D0),
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }
}