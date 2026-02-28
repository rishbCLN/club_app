import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'particle_field.dart';
import 'nexus_bottom_nav.dart';
import '../../core/constants/colors.dart';

class NexusShell extends StatelessWidget {
  const NexusShell({super.key, required this.child});

  final Widget child;

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home/events')) return 1;
    if (location.startsWith('/home/my-clubs')) return 2;
    if (location.startsWith('/home/profile')) return 3;
    return 0; // explore
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexusColors.bg,
      extendBody: true,
      body: ParticleField(child: child),
      bottomNavigationBar: NexusBottomNav(
        currentIndex: _currentIndex(context),
      ),
    );
  }
}
