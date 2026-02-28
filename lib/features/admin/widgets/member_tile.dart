import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/role_tags.dart';
import '../../../core/constants/typography.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../shared/widgets/role_tag_chip.dart';
import 'role_picker_sheet.dart';

class AdminMemberTile extends ConsumerWidget {
  const AdminMemberTile({
    super.key,
    required this.member,
    required this.clubId,
    required this.accentColor,
    required this.index,
    required this.currentUserUid,
  });

  final ClubMemberModel member;
  final String clubId;
  final Color accentColor;
  final int index;
  final String currentUserUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ClubRoleTag.fromString(member.roleTag);
    final isSelf = member.uid == currentUserUid;

    return Column(
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: role.color.withOpacity(0.15),
                backgroundImage: member.avatarUrl != null
                    ? NetworkImage(member.avatarUrl!)
                    : null,
                child: member.avatarUrl == null
                    ? Text(
                        member.displayName.substring(0, 1).toUpperCase(),
                        style: GoogleFonts.syne(
                          fontWeight: FontWeight.w700,
                          color: role.color,
                          fontSize: 16,
                        ),
                      )
                    : null,
              ),
              // Role color ring
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: role.color.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          title: Row(
            children: [
              Flexible(
                child: Text(
                  member.displayName,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: NexusColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isSelf) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'YOU',
                    style: NexusText.tag.copyWith(
                        color: accentColor, fontSize: 8),
                  ),
                ),
              ]
            ],
          ),
          subtitle: Row(
            children: [
              Text(
                member.rollNo.isNotEmpty ? member.rollNo : '—',
                style: GoogleFonts.spaceMono(
                  fontSize: 11,
                  color: NexusColors.textMuted,
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RoleTagChip(roleTag: role, compact: true),
              const SizedBox(width: 4),
              if (!isSelf)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert,
                      color: NexusColors.textMuted, size: 20),
                  color: NexusColors.surfaceElevated,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'role',
                      child: Row(
                        children: [
                          const Icon(Icons.switch_account_outlined,
                              size: 16, color: NexusColors.textSecondary),
                          const SizedBox(width: 8),
                          Text('Change Role',
                              style: GoogleFonts.dmSans(
                                  color: NexusColors.textPrimary,
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'remove',
                      child: Row(
                        children: [
                          const Icon(Icons.person_remove_outlined,
                              size: 16, color: NexusColors.rose),
                          const SizedBox(width: 8),
                          Text('Remove from Club',
                              style: GoogleFonts.dmSans(
                                  color: NexusColors.rose, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'role') {
                      showRolePickerSheet(
                        context,
                        clubId: clubId,
                        memberUid: member.uid,
                        currentRole: role,
                        accentColor: accentColor,
                      );
                    } else if (value == 'remove') {
                      _confirmRemove(context, ref);
                    }
                  },
                ),
            ],
          ),
        ),
        const Divider(height: 1, indent: 20, color: NexusColors.border),
      ],
    )
        .animate(delay: Duration(milliseconds: index * 60))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.1, end: 0, duration: 300.ms);
  }

  void _confirmRemove(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NexusColors.surfaceElevated,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Remove Member?', style: NexusText.cardTitle),
        content: Text(
          'Remove ${member.displayName} from the club?\nThis cannot be undone.',
          style: NexusText.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: NexusText.button
                    .copyWith(color: NexusColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(demoMembersProvider(clubId).notifier)
                  .removeMember(member.uid);
              Navigator.pop(ctx);
            },
            child: Text('Remove',
                style: NexusText.button
                    .copyWith(color: NexusColors.rose)),
          ),
        ],
      ),
    );
  }
}
