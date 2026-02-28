import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../../../core/models/models.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/constants/role_tags.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.index,
  });

  final EventModel event;
  final int index;

  @override
  Widget build(BuildContext context) {
    final accentColor = event.clubColorHex.toColor();
    final eventType = EventType.fromString(event.eventType);

    return GestureDetector(
      onTap: () => context.push('/event/${event.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: NexusColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(color: accentColor, width: 3),
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Club name tag
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: accentColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      event.clubName,
                      style: NexusText.tag.copyWith(
                        color: accentColor,
                        fontSize: 9,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Collab badge
                  if (event.hasCollaboration)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: NexusColors.violet.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: NexusColors.violet.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.link, size: 10, color: NexusColors.violet),
                          const SizedBox(width: 3),
                          Text(
                            '× ${event.collaboratingClubs.length} collab',
                            style: NexusText.tag.copyWith(
                              color: NexusColors.violet,
                              fontSize: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 10),

              // Event title
              Text(
                event.title,
                style: NexusText.cardTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // Date with glowing dot
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: event.isOngoing
                          ? NexusColors.emerald
                          : event.isUpcoming
                              ? accentColor
                              : NexusColors.textMuted,
                      boxShadow: [
                        BoxShadow(
                          color: (event.isOngoing ? NexusColors.emerald : accentColor)
                              .withOpacity(0.5),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    event.startDate.relativeLabel,
                    style: NexusText.bodySmall,
                  ),
                  if (event.isOngoing) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: NexusColors.emerald.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'LIVE',
                        style: NexusText.tag.copyWith(
                          color: NexusColors.emerald,
                          fontSize: 8,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 12),

              // Bottom row: event type + view details
              Row(
                children: [
                  // Event type chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: eventType.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: eventType.color.withOpacity(0.25),
                      ),
                    ),
                    child: Text(
                      eventType.label.toUpperCase(),
                      style: NexusText.tag.copyWith(
                        color: eventType.color,
                        fontSize: 8,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // View details ghost button
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View Details',
                        style: NexusText.bodySmall.copyWith(
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.arrow_forward,
                        size: 12,
                        color: accentColor,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 80))
        .fadeIn(duration: 400.ms, curve: Curves.easeOut)
        .slideY(begin: 0.15, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }
}
