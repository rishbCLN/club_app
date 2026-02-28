import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';

class NexusBottomNav extends StatelessWidget {
  const NexusBottomNav({super.key, required this.currentIndex});

  final int currentIndex;

  static const _tabs = [
    _TabItem(icon: Icons.explore_outlined, activeIcon: Icons.explore, label: 'Explore', path: '/home/explore'),
    _TabItem(icon: Icons.event_outlined, activeIcon: Icons.event, label: 'Events', path: '/home/events'),
    _TabItem(icon: Icons.groups_outlined, activeIcon: Icons.groups, label: 'My Clubs', path: '/home/my-clubs'),
    _TabItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile', path: '/home/profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.paddingOf(context).bottom + 12,
        top: 8,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: NexusColors.surfaceElevated.withOpacity(0.85),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withOpacity(0.07),
                width: 1,
              ),
            ),
            child: Row(
              children: List.generate(_tabs.length, (index) {
                final tab = _tabs[index];
                final isActive = currentIndex == index;
                return Expanded(
                  child: _TabButton(
                    tab: tab,
                    isActive: isActive,
                    onTap: () => context.go(tab.path),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.tab,
    required this.isActive,
    required this.onTap,
  });

  final _TabItem tab;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isActive
                  ? NexusColors.cyan.withOpacity(0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isActive ? tab.activeIcon : tab.icon,
              size: 22,
              color: isActive ? NexusColors.cyan : NexusColors.textMuted,
            ),
          )
              .animate(target: isActive ? 1.0 : 0.0)
              .scaleXY(begin: 1.0, end: 1.15, duration: 200.ms, curve: Curves.elasticOut),
          const SizedBox(height: 2),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: NexusText.tag.copyWith(
              fontSize: 9,
              color: isActive ? NexusColors.cyan : NexusColors.textMuted,
            ),
            child: Text(tab.label),
          ),
          const SizedBox(height: 2),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: isActive ? 18 : 0,
            height: 2,
            decoration: BoxDecoration(
              color: NexusColors.cyan,
              borderRadius: BorderRadius.circular(1),
              boxShadow: isActive
                  ? [BoxShadow(color: NexusColors.cyan.withOpacity(0.5), blurRadius: 4)]
                  : [],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabItem {
  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.path,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String path;
}
