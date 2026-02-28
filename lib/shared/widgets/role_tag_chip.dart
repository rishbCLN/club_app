import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/role_tags.dart';

class RoleTagChip extends StatelessWidget {
  const RoleTagChip({
    super.key,
    required this.roleTag,
    this.compact = false,
  });

  final ClubRoleTag roleTag;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: roleTag.backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: roleTag.borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: roleTag.color.withOpacity(0.15),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Text(
        roleTag.displayLabel,
        style: GoogleFonts.spaceMono(
          fontSize: compact ? 8 : 10,
          fontWeight: FontWeight.w700,
          color: roleTag.color,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class RoleTagChipFromString extends StatelessWidget {
  const RoleTagChipFromString({super.key, required this.roleTagString, this.compact = false});

  final String roleTagString;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final roleTag = ClubRoleTag.fromString(roleTagString);
    return RoleTagChip(roleTag: roleTag, compact: compact);
  }
}
