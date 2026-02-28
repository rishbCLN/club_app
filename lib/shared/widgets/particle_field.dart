import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';

class ParticleField extends StatefulWidget {
  const ParticleField({super.key, this.child});
  final Widget? child;

  @override
  State<ParticleField> createState() => _ParticleFieldState();
}

class _ParticleFieldState extends State<ParticleField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
    _initParticles();
  }

  void _initParticles() {
    _particles = List.generate(65, (_) => _Particle(_random));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (_, __) => RepaintBoundary(
            child: CustomPaint(
              painter: _ParticlePainter(
                particles: _particles,
                progress: _controller.value,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class _Particle {
  _Particle(math.Random rng) {
    x = rng.nextDouble();
    y = rng.nextDouble();
    radius = 1.0 + rng.nextDouble() * 2.0;
    speedX = (rng.nextDouble() - 0.5) * 0.0006;
    speedY = (rng.nextDouble() - 0.5) * 0.0006;
    phase = rng.nextDouble() * math.pi * 2;
    color = NexusColors.accents[rng.nextInt(NexusColors.accents.length)];
    baseOpacity = 0.15 + rng.nextDouble() * 0.35;
  }

  late double x;
  late double y;
  late double radius;
  late double speedX;
  late double speedY;
  late double phase;
  late Color color;
  late double baseOpacity;

  void update(double progress) {
    x = (x + speedX) % 1.0;
    y = (y + speedY) % 1.0;
    if (x < 0) x += 1.0;
    if (y < 0) y += 1.0;
  }

  double opacityAt(double progress) {
    return baseOpacity *
        (0.5 + 0.5 * math.sin(progress * math.pi * 2 * 3 + phase));
  }
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({
    required this.particles,
    required this.progress,
  });

  final List<_Particle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      p.update(progress);
      final paint = Paint()
        ..color = p.color.withOpacity(p.opacityAt(progress))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => true;
}
