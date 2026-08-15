import 'package:flutter/material.dart';
import 'package:higherground/i18n/strings.g.dart';
import 'package:higherground/providers/AppStateManager.dart';
import 'package:higherground/screens/InitPage.dart';
import 'package:provider/provider.dart';

class _PageData {
  final IconData iconData;
  final Color iconColor;
  final String title;
  final String hint;

  const _PageData({
    required this.iconData,
    required this.iconColor,
    required this.title,
    required this.hint,
  });
}

class OnboardingPage extends StatefulWidget {
  static const routeName = "/onboarding";
  const OnboardingPage();

  @override
  OnboarderPageState createState() => OnboarderPageState();
}

class OnboarderPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _entryController;
  late Animation<double> _entryFade;
  int _currentPage = 0;

  static const List<Color> _accentColors = [
    Color(0xFF6366f1),
    Color(0xFF8b5cf6),
    Color(0xFF10b981),
    Color(0xFF3b82f6),
  ];

  static const List<IconData> _icons = [
    Icons.favorite_rounded,
    Icons.menu_book_rounded,
    Icons.play_circle_rounded,
    Icons.person_add_rounded,
  ];

  List<_PageData> _pages = [];

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _entryFade =
        CurvedAnimation(parent: _entryController, curve: Curves.easeOut);

    final titles = t.onboardingpagetitles;
    final hints = t.onboardingpagehints;
    _pages = List.generate(
      titles.length.clamp(0, 4),
      (i) => _PageData(
        iconData: _icons[i],
        iconColor: _accentColors[i],
        title: titles[i],
        hint: hints[i],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _finish() {
    Provider.of<AppStateManager>(context, listen: false)
        .setUserSeenOnboardingPage(true);
    Navigator.of(context).pushReplacementNamed(InitPage.routeName);
  }

  @override
  Widget build(BuildContext context) {
    if (_pages.isEmpty) return const SizedBox.shrink();

    final accent = _accentColors[_currentPage];
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFF0d1117),
      body: FadeTransition(
        opacity: _entryFade,
        child: Stack(
          children: [
            // Background accent blobs
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              top: -90,
              right: -70,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(alpha:0.10),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              bottom: 140,
              left: -110,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(alpha:0.06),
                ),
              ),
            ),
            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Skip button
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4, right: 8),
                      child: TextButton(
                        onPressed: _finish,
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha:0.45),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Pages
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      itemCount: _pages.length,
                      itemBuilder: (context, index) =>
                          _buildPage(_pages[index]),
                    ),
                  ),
                  // Bottom navigation
                  _buildBottomBar(accent, isLast),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_PageData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          // Icon
          Container(
            width: 136,
            height: 136,
            decoration: BoxDecoration(
              color: data.iconColor.withValues(alpha:0.13),
              borderRadius: BorderRadius.circular(44),
              border: Border.all(
                color: data.iconColor.withValues(alpha:0.28),
                width: 1.5,
              ),
            ),
            child: Icon(data.iconData, color: data.iconColor, size: 68),
          ),
          const SizedBox(height: 44),
          // Title
          Text(
            data.title.replaceAll(r'\n', '\n'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w700,
              height: 1.25,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 18),
          // Hint
          Text(
            data.hint,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha:0.52),
              fontSize: 15,
              height: 1.65,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(Color accent, bool isLast) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        children: [
          // Animated dots
          Row(
            children: List.generate(_pages.length, (i) {
              final isActive = i == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.only(right: 7),
                width: isActive ? 26 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive
                      ? accent
                      : Colors.white.withValues(alpha:0.18),
                  borderRadius: BorderRadius.circular(99),
                ),
              );
            }),
          ),
          const Spacer(),
          // Next / Get Started button
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 0),
                padding: EdgeInsets.symmetric(
                  horizontal: isLast ? 26 : 18,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(99),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isLast ? 'Get Started' : 'Next',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  if (!isLast) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
