import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../services/preferences_service.dart';
import '../../models/app_theme_model.dart';
import '../main_navigation.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 7; // 4 intro + 3 setup pages

  // Setup selections
  String? _selectedUsage;
  String? _selectedGoal;

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _completeOnboarding() async {
    await PreferencesService.setOnboardingCompleted(true);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MainNavigation(),
          transitionDuration: const Duration(milliseconds: 600),
          reverseTransitionDuration: const Duration(milliseconds: 600),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Fade animation for incoming page
            final fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
            ));

            // Scale animation for incoming page
            final scaleAnimation = Tween<double>(
              begin: 0.9,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
            ));

            return FadeTransition(
              opacity: fadeAnimation,
              child: ScaleTransition(
                scale: scaleAnimation,
                child: child,
              ),
            );
          },
        ),
      );
    }
  }

  void _nextPage() {
    if (_currentPage == _totalPages - 1) {
      _completeOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final colors = appProvider.currentThemeColors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Dots indicator at top
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _totalPages,
                  (index) => _buildDot(index, colors),
                ),
              ),
            ),

            // PageView
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: [
                  // Intro Pages (4)
                  _buildIntroPage(
                    icon: Icons.favorite_rounded,
                    title: 'Welcome to Miui',
                    description: 'Your daily companion for motivation, self-love, and personal growth. Start your journey to becoming your best self.',
                    gradient: [const Color(0xFFE8B4D0), const Color(0xFFF5D5E5)],
                    colors: colors,
                  ),
                  _buildIntroPage(
                    icon: Icons.auto_awesome_rounded,
                    title: 'Daily Motivation',
                    description: 'Get inspired every day with personalized motivational quotes and affirmations designed for you.',
                    gradient: [const Color(0xFFB8A9D4), const Color(0xFFD4C9E5)],
                    colors: colors,
                  ),
                  _buildIntroPage(
                    icon: Icons.star_rounded,
                    title: 'Track Your Goals',
                    description: 'Create vision boards, set goals, and track your progress. Visualize your dreams and make them reality.',
                    gradient: [const Color(0xFFFFB5A7), const Color(0xFFFFD4C9)],
                    colors: colors,
                  ),
                  _buildIntroPage(
                    icon: Icons.sentiment_satisfied_alt_rounded,
                    title: 'Monitor Your Mood',
                    description: 'Track your daily emotions and mental well-being. Reflect, journal, and grow stronger every day.',
                    gradient: [const Color(0xFFA8E6CF), const Color(0xFFC8F2DC)],
                    colors: colors,
                  ),

                  // Setup Pages (3)
                  _buildUsageSelectionPage(colors),
                  _buildGoalSelectionPage(colors),
                  _buildThemeSelectionPage(colors, appProvider),
                ],
              ),
            ),

            // Next/Get Started button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _currentPage == _totalPages - 1 ? 'Get Started' : 'Next',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
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

  Widget _buildIntroPage({
    required IconData icon,
    required String title,
    required String description,
    required List<Color> gradient,
    required colors,
  }) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with gradient background
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: gradient[0].withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 70,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 48),

          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: colors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUsageSelectionPage(colors) {
    final usageOptions = [
      {
        'icon': Icons.self_improvement_rounded,
        'title': 'Self-Love & Care',
        'description': 'Focus on personal wellness and self-care',
        'value': 'self_care',
      },
      {
        'icon': Icons.rocket_launch_rounded,
        'title': 'Goal Achievement',
        'description': 'Track and achieve your personal goals',
        'value': 'goals',
      },
      {
        'icon': Icons.psychology_rounded,
        'title': 'Mental Wellness',
        'description': 'Monitor mood and practice mindfulness',
        'value': 'mental_health',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'How would you like to use Miui?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Choose what matters most to you',
            style: TextStyle(
              fontSize: 15,
              color: colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          ...usageOptions.map((option) => _buildOptionCard(
                icon: option['icon'] as IconData,
                title: option['title'] as String,
                description: option['description'] as String,
                value: option['value'] as String,
                isSelected: _selectedUsage == option['value'],
                onTap: () {
                  setState(() {
                    _selectedUsage = option['value'] as String;
                  });
                },
                colors: colors,
              )),
        ],
      ),
    );
  }

  Widget _buildGoalSelectionPage(colors) {
    final goalOptions = [
      {
        'icon': Icons.favorite_border_rounded,
        'title': 'Feel Better Daily',
        'description': 'Improve mood and emotional well-being',
        'value': 'feel_better',
      },
      {
        'icon': Icons.star_border_rounded,
        'title': 'Achieve My Dreams',
        'description': 'Set and reach personal milestones',
        'value': 'achieve_dreams',
      },
      {
        'icon': Icons.spa_rounded,
        'title': 'Stay Organized',
        'description': 'Keep thoughts and plans structured',
        'value': 'stay_organized',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'What are your goals?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'We\'ll personalize your experience',
            style: TextStyle(
              fontSize: 15,
              color: colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          ...goalOptions.map((option) => _buildOptionCard(
                icon: option['icon'] as IconData,
                title: option['title'] as String,
                description: option['description'] as String,
                value: option['value'] as String,
                isSelected: _selectedGoal == option['value'],
                onTap: () {
                  setState(() {
                    _selectedGoal = option['value'] as String;
                  });
                },
                colors: colors,
              )),
        ],
      ),
    );
  }

  Widget _buildThemeSelectionPage(colors, AppProvider appProvider) {
    final themeGrid = [
      ['soft_rose', 'lavender_dreams', 'peachy_sunset'],
      ['mint_fresh', 'coral_blush', 'cherry_blossom'],
      ['pride_rainbow', 'ocean_breeze', 'forest_green'],
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Choose Your Vibe',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Pick a theme that resonates with you',
            style: TextStyle(
              fontSize: 15,
              color: colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: themeGrid.map((row) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: row.map((themeId) {
                        final themeColors = AppThemes.allThemes[themeId]!;
                        final themeName = AppThemes.themeNames[themeId]!;
                        final isSelected = appProvider.currentThemeId == themeId;

                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              appProvider.setTheme(themeId);
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    themeColors.primary,
                                    themeColors.primaryLight,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.transparent,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: themeColors.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Text(
                                      themeName.split(' ').first,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  if (isSelected)
                                    const Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Icon(
                                        Icons.check_circle_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String description,
    required String value,
    required bool isSelected,
    required VoidCallback onTap,
    required colors,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withOpacity(0.1)
              : colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colors.primary : colors.textSecondary.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.primary.withOpacity(0.2)
                    : colors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? colors.primary : colors.textSecondary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: colors.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index, colors) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? colors.primary : colors.textSecondary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradient;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
  });
}
