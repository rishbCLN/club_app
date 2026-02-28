import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/constants/colors.dart';

class NexusShimmer extends StatelessWidget {
  const NexusShimmer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: NexusColors.shimmerBase,
      highlightColor: NexusColors.shimmerHighlight,
      period: const Duration(milliseconds: 1500),
      child: child,
    );
  }
}

// ── Shimmer shapes ─────────────────────────────────────────────────────────────

class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: NexusColors.shimmerBase,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class ShimmerCircle extends StatelessWidget {
  const ShimmerCircle({super.key, required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: NexusColors.shimmerBase,
        shape: BoxShape.circle,
      ),
    );
  }
}

// ── Pre-built shimmer layouts ──────────────────────────────────────────────────

class EventCardShimmer extends StatelessWidget {
  const EventCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return NexusShimmer(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: NexusColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(width: 80, height: 20, borderRadius: 10),
            const SizedBox(height: 12),
            ShimmerBox(width: double.infinity, height: 18),
            const SizedBox(height: 8),
            ShimmerBox(width: 140, height: 14),
            const SizedBox(height: 16),
            ShimmerBox(width: 100, height: 12),
          ],
        ),
      ),
    );
  }
}

class ClubOrbShimmer extends StatelessWidget {
  const ClubOrbShimmer({super.key, required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return NexusShimmer(child: ShimmerCircle(size: size));
  }
}

class MessageBubbleShimmer extends StatelessWidget {
  const MessageBubbleShimmer({super.key, required this.isOwn});
  final bool isOwn;

  @override
  Widget build(BuildContext context) {
    return NexusShimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          mainAxisAlignment:
              isOwn ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isOwn) ...[
              ShimmerCircle(size: 36),
              const SizedBox(width: 10),
            ],
            Column(
              crossAxisAlignment:
                  isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 80, height: 10, borderRadius: 5),
                const SizedBox(height: 8),
                ShimmerBox(width: 200, height: 40, borderRadius: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
