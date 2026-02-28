import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../../../core/providers/providers.dart';
import '../../../core/utils/extensions.dart';
import '../widgets/member_tile.dart';

class AdminMembersScreen extends ConsumerStatefulWidget {
  const AdminMembersScreen({super.key, required this.clubId});
  final String clubId;

  @override
  ConsumerState<AdminMembersScreen> createState() => _AdminMembersScreenState();
}

class _AdminMembersScreenState extends ConsumerState<AdminMembersScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clubAsync = ref.watch(clubProvider(widget.clubId));
    final members = ref.watch(demoMembersProvider(widget.clubId));
    final currentUid = ref.watch(currentUidProvider) ?? '';

    final filtered = _query.isEmpty
        ? members
        : members.where((m) {
            final q = _query.toLowerCase();
            return m.displayName.toLowerCase().contains(q) ||
                m.rollNo.toLowerCase().contains(q) ||
                m.roleTag.toLowerCase().contains(q);
          }).toList();

    final club = clubAsync.valueOrNull;
    final clubColor = club != null ? club.colorHex.toColor() : NexusColors.cyan;

    return Scaffold(
      backgroundColor: NexusColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: NexusColors.textSecondary, size: 18),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '— MEMBERS',
                      style: NexusText.sectionLabel
                          .copyWith(color: clubColor, fontSize: 12),
                    ),
                  ),
                  Text(
                    '${members.length} TOTAL',
                    style: GoogleFonts.spaceMono(
                      fontSize: 10,
                      color: NexusColors.textMuted,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // ── Search bar ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: NexusColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: NexusColors.border),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _query = v),
                  style: GoogleFonts.dmSans(
                      color: NexusColors.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search members…',
                    hintStyle: NexusText.sectionLabel.copyWith(fontSize: 12),
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: NexusColors.textMuted, size: 18),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded,
                                color: NexusColors.textMuted, size: 16),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms)
                .slideY(begin: -0.1, end: 0, duration: 300.ms),
            // ── Member list ──────────────────────────────────────────────────
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.person_search_outlined,
                              color: NexusColors.textMuted, size: 48),
                          const SizedBox(height: 12),
                          Text('No members found',
                              style: NexusText.cardSubtitle),
                        ],
                      )
                          .animate()
                          .fadeIn(duration: 300.ms)
                          .scale(begin: const Offset(0.9, 0.9)),
                    )
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, i) => AdminMemberTile(
                        member: filtered[i],
                        clubId: widget.clubId,
                        accentColor: clubColor,
                        index: i,
                        currentUserUid: currentUid,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
