import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/typography.dart';

// ── Primary Glowing Button ─────────────────────────────────────────────────────

class GlowingButton extends StatefulWidget {
  const GlowingButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.color1 = NexusColors.cyan,
    this.color2 = NexusColors.violet,
    this.isLoading = false,
    this.isOutlined = false,
    this.fullWidth = false,
    this.height = 52.0,
    this.borderRadius = 14.0,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color color1;
  final Color color2;
  final bool isLoading;
  final bool isOutlined;
  final bool fullWidth;
  final double height;
  final double borderRadius;

  @override
  State<GlowingButton> createState() => _GlowingButtonState();
}

class _GlowingButtonState extends State<GlowingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scale;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    if (widget.onTap == null) return;
    setState(() => _pressed = true);
    _scaleController.forward();
  }

  void _onTapUp(_) {
    setState(() => _pressed = false);
    _scaleController.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    setState(() => _pressed = false);
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      colors: [widget.color1, widget.color2],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: 18, color: NexusColors.textPrimary),
          const SizedBox(width: 8),
        ],
        if (widget.isLoading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: NexusColors.textPrimary,
            ),
          )
        else
          Text(widget.label, style: NexusText.button),
      ],
    );

    Widget button;

    if (widget.isOutlined) {
      button = Container(
        height: widget.height,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: widget.color1.withOpacity(0.6),
            width: 1.5,
          ),
          color: widget.color1.withOpacity(0.08),
        ),
        child: Center(child: content),
      );
    } else {
      button = Container(
        height: widget.height,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: [
            BoxShadow(
              color: widget.color1.withOpacity(_pressed ? 0.6 : 0.35),
              blurRadius: _pressed ? 30 : 20,
              spreadRadius: _pressed ? 3 : 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(child: content),
      );
    }

    if (widget.fullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: button,
      ),
    );
  }
}

// ── Animated Border Trace Button (for CTA / Register) ─────────────────────────

class TracingBorderButton extends StatefulWidget {
  const TracingBorderButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color = NexusColors.cyan,
    this.icon,
  });

  final String label;
  final VoidCallback? onTap;
  final Color color;
  final IconData? icon;

  @override
  State<TracingBorderButton> createState() => _TracingBorderButtonState();
}

class _TracingBorderButtonState extends State<TracingBorderButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) {
          return CustomPaint(
            painter: _BorderTracePainter(
              progress: _controller.value,
              color: widget.color,
            ),
            child: child,
          );
        },
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 28),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 18, color: widget.color),
                const SizedBox(width: 8),
              ],
              Text(widget.label, style: NexusText.button.copyWith(color: widget.color)),
            ],
          ),
        ),
      ),
    );
  }
}

class _BorderTracePainter extends CustomPainter {
  _BorderTracePainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const r = 14.0;
    final perimeter = 2 * (size.width + size.height - 4 * r) + 2 * math.pi * r;
    final traceLength = perimeter * 0.25;
    final start = progress * perimeter;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(14),
      ));

    final pathMetrics = path.computeMetrics().first;
    final traceStart = start % pathMetrics.length;
    final traceEnd = traceStart + traceLength;

    final tracePath = pathMetrics.extractPath(
      traceStart,
      traceEnd.clamp(0, pathMetrics.length),
    );

    if (traceEnd > pathMetrics.length) {
      final wrap = pathMetrics.extractPath(0, traceEnd - pathMetrics.length);
      canvas.drawPath(wrap, _paint(color));
    }

    canvas.drawPath(tracePath, _paint(color));
  }

  Paint _paint(Color c) => Paint()
    ..color = c.withOpacity(0.85)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0
    ..strokeCap = StrokeCap.round
    ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4.0);

  @override
  bool shouldRepaint(_BorderTracePainter old) => old.progress != progress;
}
