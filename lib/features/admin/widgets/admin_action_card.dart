import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/colors.dart';

class AdminActionCard extends StatefulWidget {
  const AdminActionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.accentColor,
    required this.onTap,
    this.badgeCount,
    this.index = 0,
    this.fullWidth = false,
  });

  final IconData icon;
  final String label;
  final String sublabel;
  final Color accentColor;
  final VoidCallback onTap;
  final int? badgeCount;
  final int index;
  final bool fullWidth;

  @override
  State<AdminActionCard> createState() => _AdminActionCardState();
}

class _AdminActionCardState extends State<AdminActionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            color: NexusColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.accentColor.withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: widget.accentColor.withOpacity(0.06),
                blurRadius: 16,
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                splashColor: widget.accentColor.withOpacity(0.12),
                highlightColor: widget.accentColor.withOpacity(0.06),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon with glow
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: widget.accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.accentColor.withOpacity(0.2),
                                  blurRadius: 12,
                                )
                              ],
                            ),
                            child: Icon(
                              widget.icon,
                              size: 22,
                              color: widget.accentColor,
                            ),
                          ),
                          const Spacer(),
                          // Badge
                          if (widget.badgeCount != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: NexusColors.orange,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: NexusColors.orange.withOpacity(0.35),
                                    blurRadius: 8,
                                  )
                                ],
                              ),
                              child: Text(
                                '${widget.badgeCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        widget.label,
                        style: GoogleFonts.syne(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: NexusColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.sublabel,
                        style: GoogleFonts.spaceMono(
                          fontSize: 10,
                          color: NexusColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: widget.index * 70))
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.2, end: 0, duration: 350.ms);
  }
}
