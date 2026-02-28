import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/role_tags.dart';
import '../../../core/constants/typography.dart';
import '../../../core/models/models.dart';
import '../../../core/utils/extensions.dart';
import '../../../shared/widgets/role_tag_chip.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isOwn,
    required this.index,
    this.onReact,
    this.onLongPress,
  });

  final MessageModel message;
  final bool isOwn;
  final int index;
  final VoidCallback? onReact;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    if (message.isAnnouncement) return _AnnouncementBubble(message: message, index: index);
    if (message.isEventShare) return _EventShareBubble(message: message, index: index);

    return _StandardBubble(
      message: message,
      isOwn: isOwn,
      index: index,
      onLongPress: onLongPress,
    );
  }
}

// ── Standard Text Bubble ───────────────────────────────────────────────────────

class _StandardBubble extends StatelessWidget {
  const _StandardBubble({
    required this.message,
    required this.isOwn,
    required this.index,
    this.onLongPress,
  });

  final MessageModel message;
  final bool isOwn;
  final int index;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final accentColor = message.senderAccentColor.toColor();
    final roleTag = ClubRoleTag.fromString(message.senderTag);

    return GestureDetector(
      onLongPress: () {
        HapticFeedback.mediumImpact();
        onLongPress?.call();
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: isOwn ? 64 : 16,
          right: isOwn ? 16 : 64,
          bottom: 4,
        ),
        child: Column(
          crossAxisAlignment:
              isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Sender info (only for others)
            if (!isOwn) ...[
              Padding(
                padding: const EdgeInsets.only(left: 46.0, bottom: 3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message.senderName,
                      style: NexusText.bodySmall.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 6),
                    RoleTagChip(roleTag: roleTag, compact: true),
                  ],
                ),
              ),
            ],

            Row(
              mainAxisAlignment:
                  isOwn ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Avatar (not-own)
                if (!isOwn) ...[
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor.withOpacity(0.15),
                      border: Border.all(
                        color: roleTag.color.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        message.senderName.initials,
                        style: NexusText.tag.copyWith(
                          color: accentColor,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                // Bubble
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isOwn
                          ? accentColor.withOpacity(0.12)
                          : NexusColors.surfaceElevated,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isOwn ? const Radius.circular(16) : Radius.zero,
                        bottomRight: isOwn ? Radius.zero : const Radius.circular(16),
                      ),
                      border: Border.all(
                        color: isOwn
                            ? accentColor.withOpacity(0.3)
                            : NexusColors.border,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: isOwn
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(message.text, style: NexusText.chatMessage),
                        const SizedBox(height: 4),
                        Text(
                          message.timestamp.friendlyTime,
                          style: NexusText.tag.copyWith(
                            fontSize: 9,
                            color: NexusColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Reactions
            if (message.reactions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 46, top: 4),
                child: Wrap(
                  spacing: 4,
                  children: message.reactions.entries.map((entry) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: NexusColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: NexusColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(entry.key, style: const TextStyle(fontSize: 13)),
                          const SizedBox(width: 3),
                          Text(
                            '${entry.value.length}',
                            style: NexusText.tag.copyWith(fontSize: 9),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 20))
        .fadeIn(duration: 200.ms)
        .slideX(
          begin: isOwn ? 0.05 : -0.05,
          end: 0,
          duration: 200.ms,
          curve: Curves.easeOut,
        );
  }
}

// ── Announcement Bubble ────────────────────────────────────────────────────────

class _AnnouncementBubble extends StatelessWidget {
  const _AnnouncementBubble({required this.message, required this.index});

  final MessageModel message;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: NexusColors.amber.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: NexusColors.amber.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.campaign_outlined, color: NexusColors.amber, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ANNOUNCEMENT',
                    style: NexusText.tag.copyWith(color: NexusColors.amber, fontSize: 9),
                  ),
                  const SizedBox(height: 4),
                  Text(message.text, style: NexusText.chatMessage),
                  const SizedBox(height: 4),
                  Text(
                    '${message.senderName} · ${message.timestamp.friendlyTime}',
                    style: NexusText.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: index * 20)).fadeIn(duration: 300.ms);
  }
}

// ── Event Share Bubble ─────────────────────────────────────────────────────────

class _EventShareBubble extends StatelessWidget {
  const _EventShareBubble({required this.message, required this.index});

  final MessageModel message;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: NexusColors.emerald.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: NexusColors.emerald.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.event_outlined, color: NexusColors.emerald, size: 14),
                const SizedBox(width: 6),
                Text(
                  'EVENT SHARED',
                  style: NexusText.tag.copyWith(color: NexusColors.emerald, fontSize: 9),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(message.text, style: NexusText.cardTitle),
            const SizedBox(height: 6),
            Text(
              'shared by ${message.senderName}',
              style: NexusText.bodySmall,
            ),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: index * 20)).fadeIn(duration: 300.ms);
  }
}
