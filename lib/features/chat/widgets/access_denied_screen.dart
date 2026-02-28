import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../../../shared/widgets/glowing_button.dart';
import '../../../shared/widgets/particle_field.dart';

class AccessDeniedScreen extends StatefulWidget {
  const AccessDeniedScreen({super.key, required this.clubName});

  final String clubName;

  @override
  State<AccessDeniedScreen> createState() => _AccessDeniedScreenState();
}

class _AccessDeniedScreenState extends State<AccessDeniedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _lockController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _lockController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _lockController, curve: Curves.easeInOut));

    // Play shake once on load
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _lockController.forward();
    });
  }

  @override
  void dispose() {
    _lockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexusColors.bg,
      body: ParticleField(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated lock
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (_, child) => Transform.translate(
                    offset: Offset(_shakeAnimation.value, 0),
                    child: child,
                  ),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: NexusColors.rose.withOpacity(0.1),
                      border: Border.all(
                        color: NexusColors.rose.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: NexusColors.rose.withOpacity(0.2),
                          blurRadius: 40,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lock_outlined,
                      size: 44,
                      color: NexusColors.rose,
                    ),
                  ),
                ).animate().scaleXY(begin: 0.3, end: 1.0, duration: 600.ms, curve: Curves.elasticOut),

                const SizedBox(height: 32),

                Text(
                  'Access Denied',
                  style: NexusText.heroSubtitle.copyWith(color: NexusColors.rose),
                  textAlign: TextAlign.center,
                ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: 10),

                Text(
                  'You need to be a verified member of\n${widget.clubName}\nto access this chat.',
                  style: NexusText.body,
                  textAlign: TextAlign.center,
                ).animate(delay: 300.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: 12),

                Text(
                  'Contact the club admin to request membership.',
                  style: NexusText.bodySmall.copyWith(
                    color: NexusColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ).animate(delay: 400.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: 40),

                GlowingButton(
                  label: 'Go Back',
                  onTap: () => context.pop(),
                  icon: Icons.arrow_back,
                  isOutlined: true,
                  color1: NexusColors.rose,
                  color2: NexusColors.rose,
                ).animate(delay: 500.ms).fadeIn(duration: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
