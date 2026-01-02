import 'package:flutter/material.dart';
import '../../../auth/presentation/pages/login_screen.dart';

Color _withOpacityColor(Color c, double o) {
  final int v = c.toARGB32();
  final int r = (v >> 16) & 0xFF;
  final int g = (v >> 8) & 0xFF;
  final int b = v & 0xFF;
  return Color.fromRGBO(r, g, b, o);
}

class OnboardingScreen extends StatefulWidget {
  static const String routeName = '/onboarding';
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const Color kPrimary = Color(0xFFF57C00);

  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<_OnboardData> _pages = const [
    _OnboardData(
      title: 'Track Every Parcel',
      description:
          'Pathau Now helps you follow your courier and parcels step by step.',
      icon: Icons.location_searching,
    ),
    _OnboardData(
      title: 'Real-time Updates',
      description:
          'See live status like picked, in-transit, and delivered in one place.',
      icon: Icons.update_rounded,
    ),
    _OnboardData(
      title: 'Safe & Easy Delivery',
      description:
          'Simple, fast and secure experience for both sender and receiver.',
      icon: Icons.verified_user_rounded,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, LoginScreen.routeName);
    }
  }

  void _skip() {
    Navigator.pushReplacementNamed(context, LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.shortestSide >= 600;

    final double maxWidth = isTablet ? 720 : double.infinity;
    final double iconSize = isTablet ? 210 : 150;
    final double titleSize = isTablet ? 30 : 22;
    final double descSize = isTablet ? 18 : 14;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromRGBO(245, 124, 0, 0.10),
              Colors.white,
              const Color(0xFFFFF3E0),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(245, 124, 0, 0.12),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Color.fromRGBO(245, 124, 0, 0.18),
                                ),
                              ),
                              child: Image.asset(
                                'assets/images/pathau_logo.png',
                                height: 28,
                                width: 28,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.local_shipping_rounded),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Pathau Now',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: _skip,
                          child: const Text(
                            'Skip',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _pages.length,
                      onPageChanged: (index) =>
                          setState(() => _currentIndex = index),
                      itemBuilder: (context, index) {
                        final page = _pages[index];

                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: _OnboardCard(
                            primary: kPrimary,
                            icon: page.icon,
                            title: page.title,
                            description: page.description,
                            iconSize: iconSize,
                            titleSize: titleSize,
                            descSize: descSize,
                          ),
                        );
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _DotsIndicator(
                          count: _pages.length,
                          index: _currentIndex,
                          primary: kPrimary,
                        ),
                        Row(
                          children: [
                            if (_currentIndex > 0)
                              TextButton(
                                onPressed: () {
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                child: const Text(
                                  'Back',
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                              ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _goNext,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 26 : 22,
                                  vertical: isTablet ? 14 : 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                _currentIndex == _pages.length - 1
                                    ? 'Get Started'
                                    : 'Next',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardCard extends StatelessWidget {
  final Color primary;
  final IconData icon;
  final String title;
  final String description;
  final double iconSize;
  final double titleSize;
  final double descSize;

  const _OnboardCard({
    required this.primary,
    required this.icon,
    required this.title,
    required this.description,
    required this.iconSize,
    required this.titleSize,
    required this.descSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x11000000)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: iconSize,
            width: iconSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  _withOpacityColor(primary, 0.18),
                  _withOpacityColor(primary, 0.06),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: _withOpacityColor(primary, 0.18)),
            ),
            child: Center(
              child: Icon(icon, size: iconSize * 0.50, color: primary),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: descSize,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  final int count;
  final int index;
  final Color primary;

  const _DotsIndicator({
    required this.count,
    required this.index,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (i) {
        final bool active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          margin: const EdgeInsets.only(right: 8),
          height: 8,
          width: active ? 22 : 8,
          decoration: BoxDecoration(
            color: active ? primary : Colors.grey[400],
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

class _OnboardData {
  final String title;
  final String description;
  final IconData icon;

  const _OnboardData({
    required this.title,
    required this.description,
    required this.icon,
  });
}
