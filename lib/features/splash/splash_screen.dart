import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';
import '../../shared/widgets/particle_field.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _hexController;
  late AnimationController _pulseController;
  late AnimationController _revealController;

  @override
  void initState() {
    super.initState();

    _hexController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    await _hexController.forward();
    await Future.delayed(const Duration(milliseconds: 1500));
    _revealController.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) context.go('/home/explore');
  }

  @override
  void dispose() {
    _hexController.dispose();
    _pulseController.dispose();
    _revealController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexusColors.bg,
      body: ParticleField(
        child: AnimatedBuilder(
          animation: _revealController,
          builder: (context, child) {
            return ClipPath(
              clipper: _RadialRevealClipper(progress: _revealController.value),
              child: Container(
                color: NexusColors.bg,
                child: child,
              ),
            );
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hexagonal logo assembly
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (_, child) {
                    final glow = 0.3 + 0.25 * _pulseController.value;
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: NexusColors.cyan.withOpacity(glow),
                            blurRadius: 60,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: child,
                    );
                  },
                  child: AnimatedBuilder(
                    animation: _hexController,
                    builder: (_, __) {
                      return CustomPaint(
                        size: const Size(120, 120),
                        painter: _HexAssemblyPainter(
                          progress: _hexController.value,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 28),

                // NEXUS letter-by-letter stagger
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: 'NEXUS'.split('').asMap().entries.map((e) {
                    return Text(
                      e.value,
                      style: NexusText.heroTitle.copyWith(
                        fontSize: 42,
                        letterSpacing: 8,
                      ),
                    )
                        .animate(delay: Duration(milliseconds: 800 + e.key * 80))
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.3, end: 0, duration: 400.ms, curve: Curves.easeOut);
                  }).toList(),
                ),

                const SizedBox(height: 8),

                Text(
                  'COLLEGE CLUB HUB',
                  style: NexusText.sectionLabel.copyWith(
                    color: NexusColors.cyan.withOpacity(0.6),
                  ),
                )
                    .animate(delay: 1300.ms)
                    .fadeIn(duration: 500.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Hexagon Assembly Painter ───────────────────────────────────────────────────

class _HexAssemblyPainter extends CustomPainter {
  _HexAssemblyPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final R = size.width / 2 * 0.85;

    // 6 triangles, each flies in from a direction
    for (int i = 0; i < 6; i++) {
      final startAngle = (i * math.pi / 3) - math.pi / 6;
      final midAngle = startAngle + math.pi / 6;

      // Flight offset per triangle
      final progress2 = (progress * 1.5 - i * 0.08).clamp(0.0, 1.0);
      final eased = Curves.elasticOut.transform(progress2.clamp(0.0, 1.0));

      final flyOffset = Offset(
        math.cos(midAngle) * (1 - eased) * 80,
        math.sin(midAngle) * (1 - eased) * 80,
      );

      final opacity = eased.clamp(0.0, 1.0);

      // Triangle vertices
      final v0 = center + flyOffset;
      final v1 = Offset(
        center.dx + R * math.cos(startAngle),
        center.dy + R * math.sin(startAngle),
      ) + flyOffset;
      final v2 = Offset(
        center.dx + R * math.cos(startAngle + math.pi / 3),
        center.dy + R * math.sin(startAngle + math.pi / 3),
      ) + flyOffset;

      final paint = Paint()
        ..color = NexusColors.cyan.withOpacity(opacity * 0.6)
        ..style = PaintingStyle.fill;

      final strokePaint = Paint()
        ..color = NexusColors.cyan.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      final path = Path()
        ..moveTo(v0.dx, v0.dy)
        ..lineTo(v1.dx, v1.dy)
        ..lineTo(v2.dx, v2.dy)
        ..close();

      canvas.drawPath(path, paint);
      canvas.drawPath(path, strokePaint);
    }
  }

  @override
  bool shouldRepaint(_HexAssemblyPainter old) => old.progress != progress;
}

// ── Radial Reveal Clipper ──────────────────────────────────────────────────────

class _RadialRevealClipper extends CustomClipper<Path> {
  _RadialRevealClipper({required this.progress});
  final double progress;

  @override
  Path getClip(Size size) {
    // When progress == 0 → show nothing (expand from center outward)
    // We invert: when progress == 0, full screen; when progress == 1, clip to nothing
    // Actually: we want the screen to DO radial reveal OUT as we navigate away
    // So progress 0 = full visible, progress 1 = fully clipped
    if (progress == 0) return Path()..addRect(Rect.largest);

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.sqrt(
      size.width * size.width + size.height * size.height,
    );
    // Reveal contracts: as progress → 1, the visible circle shrinks
    // Actually let's do expansion reveal for page coming in (not used here)
    // For splash exit: we'll just fade — remove clipping complexity
    return Path()..addRect(Rect.largest);
  }

  @override
  bool shouldReclip(_RadialRevealClipper old) => old.progress != progress;
}
