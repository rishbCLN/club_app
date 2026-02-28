import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';

class ReactionPicker extends StatelessWidget {
  const ReactionPicker({
    super.key,
    required this.onReact,
    this.onDismiss,
  });

  final ValueChanged<String> onReact;
  final VoidCallback? onDismiss;

  static const _emojis = ['👍', '❤️', '🔥', '🎉', '😮', '😂', '💯', '🚀'];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: NexusColors.surfaceElevated,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: NexusColors.border),
          boxShadow: [
            BoxShadow(
              color: NexusColors.cyan.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: _emojis.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => onReact(entry.value),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  entry.value,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            )
                .animate(delay: Duration(milliseconds: entry.key * 30))
                .fadeIn(duration: 200.ms)
                .scaleXY(begin: 0.5, end: 1.0, duration: 200.ms, curve: Curves.elasticOut);
          }).toList(),
        ),
      ),
    );
  }
}

// ── Reaction overlay shown on long-press ──────────────────────────────────────

void showReactionPicker(
  BuildContext context, {
  required Offset tapPosition,
  required ValueChanged<String> onReact,
}) {
  showDialog(
    context: context,
    barrierColor: Colors.transparent,
    builder: (ctx) => Stack(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(ctx),
          behavior: HitTestBehavior.translucent,
          child: const SizedBox.expand(),
        ),
        Positioned(
          top: tapPosition.dy - 60,
          left: (tapPosition.dx - 160).clamp(8.0, MediaQuery.sizeOf(ctx).width - 340),
          child: ReactionPicker(
            onReact: (emoji) {
              Navigator.pop(ctx);
              onReact(emoji);
            },
            onDismiss: () => Navigator.pop(ctx),
          ),
        ),
      ],
    ),
  );
}
