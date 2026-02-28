import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/role_tags.dart';
import '../../../core/constants/typography.dart';
import '../../../core/providers/providers.dart';

/// A bottom sheet that lets an admin pick a new role for a member.
/// Shows all ClubRoleTag values; current role is highlighted.
class RolePickerSheet extends ConsumerWidget {
  const RolePickerSheet({
    super.key,
    required this.clubId,
    required this.memberUid,
    required this.currentRole,
    required this.accentColor,
  });

  final String clubId;
  final String memberUid;
  final ClubRoleTag currentRole;
  final Color accentColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        color: NexusColors.surfaceElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: NexusColors.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text('Change Role', style: NexusText.cardTitle),
              ],
            ),
          ),
          const SizedBox(height: 8),

          ...ClubRoleTag.values.map((role) {
            final isCurrent = role == currentRole;
            return ListTile(
              onTap: isCurrent
                  ? null
                  : () {
                      ref
                          .read(demoMembersProvider(clubId).notifier)
                          .changeRole(memberUid, role);
                      Navigator.pop(context);
                    },
              leading: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: role.color,
                  boxShadow: [
                    BoxShadow(
                      color: role.color.withOpacity(0.35),
                      blurRadius: 6,
                    )
                  ],
                ),
              ),
              title: Text(
                role.label,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: isCurrent ? role.color : NexusColors.textPrimary,
                  fontWeight:
                      isCurrent ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              trailing: isCurrent
                  ? Icon(Icons.check_circle,
                      color: accentColor, size: 18)
                  : null,
              tileColor: isCurrent
                  ? role.color.withOpacity(0.06)
                  : Colors.transparent,
            );
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

void showRolePickerSheet(
  BuildContext context, {
  required String clubId,
  required String memberUid,
  required ClubRoleTag currentRole,
  required Color accentColor,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => RolePickerSheet(
      clubId: clubId,
      memberUid: memberUid,
      currentRole: currentRole,
      accentColor: accentColor,
    ),
  );
}
