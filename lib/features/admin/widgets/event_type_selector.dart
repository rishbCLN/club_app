import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/role_tags.dart';
import '../../../core/constants/typography.dart';

/// Horizontal scrollable chip selector for EventType.
/// Tapping a chip selects it (single selection). recruitmentDrive shows
/// an extra "Open to all students?" toggle below.
class EventTypeSelector extends StatelessWidget {
  const EventTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.accentColor,
    this.recruitmentOpenToAll = false,
    this.onRecruitmentToggle,
  });

  final EventType? selected;
  final ValueChanged<EventType> onChanged;
  final Color accentColor;
  final bool recruitmentOpenToAll;
  final ValueChanged<bool>? onRecruitmentToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: EventType.values.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final type = EventType.values[i];
              final isSelected = selected == type;
              final color = type.color;
              return GestureDetector(
                onTap: () => onChanged(type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withOpacity(0.18) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? color.withOpacity(0.7) : NexusColors.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: color.withOpacity(0.25), blurRadius: 10)]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        type.icon,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? color : NexusColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        type.label,
                        style: NexusText.tag.copyWith(
                          color: isSelected ? color : NexusColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  .animate(delay: Duration(milliseconds: i * 40))
                  .fadeIn(duration: 250.ms)
                  .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
            },
          ),
        ),
        if (selected == EventType.recruitmentDrive && onRecruitmentToggle != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: NexusColors.rose.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: NexusColors.rose.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.people_outline,
                    size: 16, color: NexusColors.rose),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Open for all students?',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: NexusColors.textPrimary,
                    ),
                  ),
                ),
                Switch(
                  value: recruitmentOpenToAll,
                  onChanged: onRecruitmentToggle,
                  activeColor: NexusColors.rose,
                  inactiveThumbColor: NexusColors.textMuted,
                  inactiveTrackColor: NexusColors.border,
                ),
              ],
            ),
          ).animate().fadeIn(duration: 250.ms).slideY(begin: -0.1),
        ],
      ],
    );
  }
}
