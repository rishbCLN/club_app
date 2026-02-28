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
import '../../../shared/widgets/club_orb.dart';
import '../../../shared/widgets/particle_field.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_action_card.dart';
import '../widgets/announcement_composer.dart';

class ClubAdminDashboardScreen extends ConsumerWidget {
  const ClubAdminDashboardScreen({super.key, required this.clubId});
  final String clubId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubAsync = ref.watch(clubProvider(clubId));

    return clubAsync.when(
      loading: () => const Scaffold(
        backgroundColor: NexusColors.bg,
        body: Center(
          child: CircularProgressIndicator(color: NexusColors.cyan),
        ),
      ),
      error: (_, __) => const Scaffold(
        backgroundColor: NexusColors.bg,
        body: Center(child: Text('Error loading club')),
      ),
      data: (club) {
        if (club == null) {
          return const Scaffold(
            backgroundColor: NexusColors.bg,
            body: Center(child: Text('Club not found')),
          );
        }

        final clubColor = club.colorHex.toColor();
        final currentUid = ref.watch(currentUidProvider) ?? '';
        final members = ref.watch(demoMembersProvider(clubId));
        final requests = ref.watch(demoJoinRequestsProvider(clubId));
        final events = ref.watch(clubEventsProvider(clubId)).valueOrNull ?? [];
        final pendingCount = requests
            .where((r) => r.status.name == 'pending')
            .length;
        final myMember = members.cast<ClubMemberModel?>().firstWhere(
          (m) => m?.uid == currentUid, orElse: () => null);
        final senderTag = myMember?.roleTag ?? 'seniorCore';

        return Scaffold(
          backgroundColor: NexusColors.bg,
          body: Stack(
            children: [
              // Particle field background
              const Positioned.fill(
                child: ParticleField(),
              ),
              // Radial bloom
              Positioned(
                top: -80,
                left: -60,
                child: Container(
                  width: 340,
                  height: 340,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        clubColor.withOpacity(0.12),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: CustomScrollView(
                  slivers: [
                    // ── Header ──────────────────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                                  color: NexusColors.textSecondary, size: 18),
                              onPressed: () => context.pop(),
                            ),
                            const SizedBox(width: 6),
                            ClubOrb(
                                clubColor: clubColor,
                                clubName: club.name,
                                logoUrl: club.logoUrl,
                                size: 32),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                club.name.toUpperCase(),
                                style: GoogleFonts.syne(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: NexusColors.textPrimary,
                                  letterSpacing: 1.5,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Hexagon "ADMIN" badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: clubColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: clubColor.withOpacity(0.4)),
                              ),
                              child: Text(
                                'ADMIN',
                                style: GoogleFonts.spaceMono(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: clubColor,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // ── Glow rule ────────────────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Container(
                          height: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [clubColor.withOpacity(0.6), Colors.transparent],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // ── Hero text ────────────────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CONTROL\nROOM',
                              style: GoogleFonts.syne(
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                color: NexusColors.textPrimary,
                                height: 1.0,
                                letterSpacing: -1.0,
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 500.ms)
                                .slideY(begin: 0.2, end: 0, duration: 500.ms),
                            const SizedBox(height: 6),
                            Text(
                              '— ${club.name.toUpperCase()} · ADMIN PANEL',
                              style: GoogleFonts.spaceMono(
                                fontSize: 10,
                                color: clubColor,
                                letterSpacing: 1.5,
                              ),
                            )
                                .animate(delay: 150.ms)
                                .fadeIn(duration: 400.ms),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    // ── Action cards grid ────────────────────────────────────
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        delegate: SliverChildListDelegate([
                          AdminActionCard(
                            icon: Icons.rocket_launch_rounded,
                            label: 'Host Event',
                            sublabel: 'Create new event',
                            accentColor: clubColor,
                            index: 0,
                            onTap: () => context.go(
                                '/club/$clubId/admin/create-event'),
                          ),
                          AdminActionCard(
                            icon: Icons.event_note_rounded,
                            label: 'My Events',
                            sublabel: '${events.length} total',
                            accentColor: NexusColors.violet,
                            badgeCount: events.isEmpty ? null : events.length,
                            index: 1,
                            onTap: () {}, // TODO: event list screen
                          ),
                          AdminActionCard(
                            icon: Icons.groups_2_rounded,
                            label: 'Members',
                            sublabel: '${members.length} active',
                            accentColor: NexusColors.blue,
                            badgeCount: members.isEmpty ? null : members.length,
                            index: 2,
                            onTap: () => context.go(
                                '/club/$clubId/admin/members'),
                          ),
                          AdminActionCard(
                            icon: Icons.inbox_rounded,
                            label: 'Join Requests',
                            sublabel: pendingCount == 0
                                ? 'No pending'
                                : '$pendingCount pending',
                            accentColor: NexusColors.amber,
                            badgeCount: pendingCount == 0 ? null : pendingCount,
                            index: 3,
                            onTap: () => context.go(
                                '/club/$clubId/admin/requests'),
                          ),
                        ]),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.1,
                        ),
                      ),
                    ),
                    // ── Announce full-width card ──────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: GestureDetector(
                          onTap: () => showAnnouncementComposer(context,
                              clubId: clubId,
                              accentColor: clubColor,
                              senderTag: senderTag),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: NexusColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: NexusColors.amber.withOpacity(0.25),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: NexusColors.amber.withOpacity(0.07),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: NexusColors.amber.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.campaign_rounded,
                                    color: NexusColors.amber,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Post Announcement',
                                          style: NexusText.cardTitle
                                              .copyWith(fontSize: 15)),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Broadcast a message to all club members',
                                        style: NexusText.sectionLabel
                                            .copyWith(fontSize: 10),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded,
                                    color: NexusColors.textMuted),
                              ],
                            ),
                          ),
                        )
                            .animate(delay: 350.ms)
                            .fadeIn(duration: 300.ms)
                            .slideY(begin: 0.1, end: 0, duration: 300.ms),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
