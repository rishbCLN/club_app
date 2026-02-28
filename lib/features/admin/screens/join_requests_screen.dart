import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/utils/extensions.dart';
import '../providers/admin_providers.dart';
import '../widgets/request_card.dart';

class JoinRequestsScreen extends ConsumerStatefulWidget {
  const JoinRequestsScreen({super.key, required this.clubId});
  final String clubId;

  @override
  ConsumerState<JoinRequestsScreen> createState() => _JoinRequestsScreenState();
}

class _JoinRequestsScreenState extends ConsumerState<JoinRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clubAsync = ref.watch(clubProvider(widget.clubId));
    final requests = ref.watch(demoJoinRequestsProvider(widget.clubId));

    final pending = requests
        .where((r) => r.status == JoinRequestStatus.pending)
        .toList();
    final reviewed = requests
        .where((r) => r.status != JoinRequestStatus.pending)
        .toList();

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
                      '— JOIN REQUESTS',
                      style: NexusText.sectionLabel
                          .copyWith(color: clubColor, fontSize: 12),
                    ),
                  ),
                  if (pending.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: NexusColors.amber.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: NexusColors.amber.withOpacity(0.4)),
                      ),
                      child: Text(
                        '${pending.length} PENDING',
                        style: GoogleFonts.spaceMono(
                          fontSize: 9,
                          color: NexusColors.amber,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // ── Tab row ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 38,
                decoration: BoxDecoration(
                  color: NexusColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Pending',
                              style: GoogleFonts.spaceMono(fontSize: 11)),
                          if (pending.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: NexusColors.amber,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${pending.length}',
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),
                    Tab(
                      child: Text('Reviewed',
                          style: GoogleFonts.spaceMono(fontSize: 11)),
                    ),
                  ],
                  indicatorColor: clubColor,
                  labelColor: NexusColors.textPrimary,
                  unselectedLabelColor: NexusColors.textMuted,
                  indicatorWeight: 2,
                  dividerColor: Colors.transparent,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // ── Content ───────────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _RequestList(
                    items: pending,
                    clubId: widget.clubId,
                    accentColor: clubColor,
                    emptyIcon: Icons.inbox_outlined,
                    emptyLabel: 'No pending requests',
                  ),
                  _RequestList(
                    items: reviewed,
                    clubId: widget.clubId,
                    accentColor: clubColor,
                    emptyIcon: Icons.check_circle_outline,
                    emptyLabel: 'No reviewed requests',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestList extends StatelessWidget {
  const _RequestList({
    required this.items,
    required this.clubId,
    required this.accentColor,
    required this.emptyIcon,
    required this.emptyLabel,
  });

  final List<JoinRequestModel> items;
  final String clubId;
  final Color accentColor;
  final IconData emptyIcon;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon, color: NexusColors.textMuted, size: 48),
            const SizedBox(height: 12),
            Text(emptyLabel, style: NexusText.cardSubtitle),
          ],
        )
            .animate()
            .fadeIn(duration: 400.ms)
            .scale(
                begin: const Offset(0.85, 0.85),
                end: const Offset(1, 1),
                duration: 400.ms),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: items.length,
      itemBuilder: (_, i) => RequestCard(
        request: items[i],
        clubId: clubId,
        accentColor: accentColor,
        index: i,
      ),
    );
  }
}
