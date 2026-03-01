import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../../../core/providers/providers.dart';
import '../../../shared/widgets/glowing_button.dart';
import '../../../shared/widgets/particle_field.dart';

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: NexusColors.bg,
      body: ParticleField(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),

                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Admin Panel',
                      style: NexusText.heroTitle,
                    ).animate().fadeIn(duration: 500.ms),
                    GestureDetector(
                      onTap: () {
                        // Logout
                        ref.read(demoLoggedInProvider.notifier).state = false;
                        ref.read(demoUserRoleProvider.notifier).state = UserRole.none;
                        context.go('/auth/login');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: NexusColors.rose.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: NexusColors.rose.withOpacity(0.3),
                          ),
                        ),
                        child: const Icon(
                          Icons.logout,
                          color: NexusColors.rose,
                          size: 20,
                        ),
                      ),
                    ).animate(delay: 100.ms).fadeIn(duration: 500.ms),
                  ],
                ),

                const SizedBox(height: 16),

                Text(
                  'Manage all clubs and events',
                  style: NexusText.body.copyWith(
                    color: NexusColors.textMuted,
                  ),
                ).animate(delay: 100.ms).fadeIn(duration: 500.ms),

                const SizedBox(height: 48),

                // Admin options grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _AdminCard(
                      icon: Icons.groups_outlined,
                      title: 'Clubs',
                      subtitle: 'Manage clubs',
                      color: NexusColors.cyan,
                      delay: 200,
                      onTap: () {
                        // TODO: navigate to clubs management
                      },
                    ),
                    _AdminCard(
                      icon: Icons.event_outlined,
                      title: 'Events',
                      subtitle: 'Manage events',
                      color: NexusColors.emerald,
                      delay: 280,
                      onTap: () {
                        // TODO: navigate to events management
                      },
                    ),
                    _AdminCard(
                      icon: Icons.people_outline,
                      title: 'Users',
                      subtitle: 'User management',
                      color: NexusColors.violet,
                      delay: 360,
                      onTap: () {
                        // TODO: navigate to users management
                      },
                    ),
                    _AdminCard(
                      icon: Icons.assessment_outlined,
                      title: 'Analytics',
                      subtitle: 'View statistics',
                      color: NexusColors.rose,
                      delay: 440,
                      onTap: () {
                        // TODO: navigate to analytics
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 48),

                // Logout button
                GlowingButton(
                  label: 'Logout',
                  onTap: () {
                    ref.read(demoLoggedInProvider.notifier).state = false;
                    ref.read(demoUserRoleProvider.notifier).state = UserRole.none;
                    context.go('/auth/login');
                  },
                  isOutlined: true,
                  fullWidth: true,
                  icon: Icons.logout,
                )
                    .animate(delay: 520.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.2, end: 0),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminCard extends StatefulWidget {
  const _AdminCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.delay,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final int delay;
  final VoidCallback onTap;

  @override
  State<_AdminCard> createState() => _AdminCardState();
}

class _AdminCardState extends State<_AdminCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(_isHovered ? 0.1 : 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.color.withOpacity(_isHovered ? 0.4 : 0.2),
              width: _isHovered ? 1.5 : 1,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.3),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                widget.icon,
                color: widget.color,
                size: 32,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: NexusText.cardTitle.copyWith(
                      color: widget.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle,
                    style: NexusText.bodySmall.copyWith(
                      color: NexusColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: widget.delay))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.2, end: 0);
  }
}
