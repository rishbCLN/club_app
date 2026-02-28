import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../shared/widgets/glowing_button.dart';
import '../../shared/widgets/particle_field.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardPage(
      icon: Icons.explore_outlined,
      accentColor: NexusColors.cyan,
      title: 'Discover\nEvery Club',
      subtitle:
          'Every campus club in one place. Browse, filter, and find your people — no group invites needed.',
    ),
    _OnboardPage(
      icon: Icons.event_outlined,
      accentColor: NexusColors.violet,
      title: 'Never Miss\nAn Event',
      subtitle:
          'Hackathons, workshops, cultural fests — all on one unified event feed. No more missed announcements.',
    ),
    _OnboardPage(
      icon: Icons.chat_bubble_outline,
      accentColor: NexusColors.rose,
      title: 'Private Club\nChats',
      subtitle:
          'Verified members get access to their club\'s private chat with role tags, reactions, and event sharing.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexusColors.bg,
      body: ParticleField(
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              SizedBox(
                height: 440,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemCount: _pages.length,
                  itemBuilder: (_, index) => _OnboardPageWidget(
                    page: _pages[index],
                    isActive: index == _currentPage,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Page dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (i) {
                  final isActive = i == _currentPage;
                  return AnimatedContainer(
                    duration: 300.ms,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 24 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive
                          ? _pages[_currentPage].accentColor
                          : NexusColors.border,
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: _pages[_currentPage]
                                    .accentColor
                                    .withOpacity(0.5),
                                blurRadius: 8,
                              )
                            ]
                          : [],
                    ),
                  );
                }),
              ),

              const Spacer(),

              // CTA buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Column(
                  children: [
                    GlowingButton(
                      label: _currentPage < _pages.length - 1
                          ? 'Continue'
                          : 'Get Started',
                      onTap: () {
                        if (_currentPage < _pages.length - 1) {
                          _pageController.nextPage(
                            duration: 400.ms,
                            curve: Curves.easeInOut,
                          );
                        } else {
                          context.go('/auth/login');
                        }
                      },
                      fullWidth: true,
                      color1: _pages[_currentPage].accentColor,
                      color2: _pages[_currentPage].accentColor.withOpacity(0.6),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.go('/home/explore'),
                      child: Text(
                        'Explore without account',
                        style: NexusText.body.copyWith(
                          color: NexusColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardPage {
  const _OnboardPage({
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color accentColor;
  final String title;
  final String subtitle;
}

class _OnboardPageWidget extends StatelessWidget {
  const _OnboardPageWidget({required this.page, required this.isActive});

  final _OnboardPage page;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: page.accentColor.withOpacity(0.1),
              border: Border.all(color: page.accentColor.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: page.accentColor.withOpacity(0.25),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(page.icon, size: 44, color: page.accentColor),
          ).animate(target: isActive ? 1.0 : 0.0)
              .scaleXY(begin: 0.8, end: 1.0, duration: 400.ms, curve: Curves.elasticOut),

          const SizedBox(height: 36),

          Text(
            page.title,
            style: NexusText.heroSubtitle,
            textAlign: TextAlign.center,
          ).animate(target: isActive ? 1.0 : 0.0)
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.15, end: 0, duration: 400.ms),

          const SizedBox(height: 16),

          Text(
            page.subtitle,
            style: NexusText.body,
            textAlign: TextAlign.center,
          ).animate(target: isActive ? 1.0 : 0.0)
              .fadeIn(duration: 400.ms, delay: 100.ms),
        ],
      ),
    );
  }
}
