import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/role_tags.dart';
import '../../../core/constants/typography.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../admin/providers/admin_providers.dart';
import '../../../core/utils/extensions.dart';
import '../../../shared/widgets/club_orb.dart';
import '../../../shared/widgets/glassmorphic_card.dart';
import '../../../shared/widgets/glowing_button.dart';
import '../../../shared/widgets/role_tag_chip.dart';
import '../../../shared/widgets/shimmer_loader.dart';

class ClubProfileScreen extends ConsumerStatefulWidget {
  const ClubProfileScreen({super.key, required this.clubId});

  final String clubId;

  @override
  ConsumerState<ClubProfileScreen> createState() => _ClubProfileScreenState();
}

class _ClubProfileScreenState extends ConsumerState<ClubProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clubAsync = ref.watch(clubProvider(widget.clubId));
    final isMemberAsync = ref.watch(isMemberProvider(widget.clubId));

    return clubAsync.when(
      loading: () => const Scaffold(
        backgroundColor: NexusColors.bg,
        body: Center(child: CircularProgressIndicator(color: NexusColors.cyan)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: NexusColors.bg,
        appBar: AppBar(backgroundColor: NexusColors.bg),
        body: Center(child: Text('Club not found.', style: NexusText.body)),
      ),
      data: (club) {
        if (club == null) {
          return Scaffold(
            backgroundColor: NexusColors.bg,
            appBar: AppBar(backgroundColor: NexusColors.bg),
            body: Center(child: Text('Club not found.', style: NexusText.body)),
          );
        }

        final accentColor = club.colorHex.toColor();
        final isMember = isMemberAsync.valueOrNull ?? false;
        final isAdmin = ref.watch(isClubAdminProvider(widget.clubId));

        return Scaffold(
          backgroundColor: NexusColors.bg,
          extendBodyBehindAppBar: true,
          floatingActionButton: _ClubFAB(
            isMember: isMember,
            accentColor: accentColor,
            clubId: widget.clubId,
          ),
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              // Banner + club info
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: NexusColors.bg,
                elevation: innerBoxIsScrolled ? 4 : 0,
                actions: isAdmin
                    ? [
                        _AdminBadgeButton(
                          clubId: widget.clubId,
                          accentColor: accentColor,
                        ),
                      ]
                    : null,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: GlassmorphicCard(
                    padding: EdgeInsets.zero,
                    borderRadius: 12,
                    onTap: () => context.pop(),
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(Icons.arrow_back, color: NexusColors.textPrimary, size: 20),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (club.bannerUrl != null)
                        CachedNetworkImage(
                          imageUrl: club.bannerUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(color: NexusColors.surface),
                          errorWidget: (_, __, ___) => _DefaultClubBanner(accentColor: accentColor),
                        )
                      else
                        _DefaultClubBanner(accentColor: accentColor),

                      // Gradient overlay
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              NexusColors.bg.withOpacity(0.5),
                              NexusColors.bg,
                            ],
                            stops: const [0.2, 0.65, 1.0],
                          ),
                        ),
                      ),

                      // Club name overlay
                      Positioned(
                        bottom: 16,
                        left: 20,
                        right: 20,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ClubOrb(
                              clubColor: accentColor,
                              clubName: club.name,
                              logoUrl: club.logoUrl,
                              size: 56,
                              isPulsing: true,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(club.name, style: NexusText.heroSubtitle),
                                  const SizedBox(height: 2),
                                  Text(
                                    club.tagline,
                                    style: NexusText.body.copyWith(fontSize: 13),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      _ClubBadge(
                                        label: club.type.toUpperCase(),
                                        color: ClubType.fromString(club.type).color,
                                      ),
                                      const SizedBox(width: 6),
                                      _ClubBadge(
                                        label: '${club.memberCount} MEMBERS',
                                        color: NexusColors.textMuted,
                                      ),
                                      const SizedBox(width: 6),
                                      _ClubBadge(
                                        label: 'EST. ${club.foundedYear}',
                                        color: NexusColors.textMuted,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tab Bar
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(
                  tabBar: TabBar(
                    controller: _tabController,
                    indicatorColor: accentColor,
                    indicatorWeight: 2,
                    labelStyle: NexusText.tag.copyWith(fontSize: 10),
                    unselectedLabelStyle: NexusText.tag.copyWith(fontSize: 10),
                    labelColor: accentColor,
                    unselectedLabelColor: NexusColors.textMuted,
                    dividerColor: NexusColors.border,
                    tabs: const [
                      Tab(text: 'ABOUT'),
                      Tab(text: 'EVENTS'),
                      Tab(text: 'MEMBERS'),
                    ],
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _AboutTab(club: club),
                _EventsTab(clubId: widget.clubId, accentColor: accentColor),
                _MembersTab(clubId: widget.clubId, accentColor: accentColor),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── FAB ────────────────────────────────────────────────────────────────────────

class _ClubFAB extends StatelessWidget {
  const _ClubFAB({
    required this.isMember,
    required this.accentColor,
    required this.clubId,
  });

  final bool isMember;
  final Color accentColor;
  final String clubId;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
      child: isMember
          ? FloatingActionButton.extended(
              key: const ValueKey('chat'),
              onPressed: () => context.push('/club/$clubId/chat'),
              backgroundColor: accentColor,
              icon: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 20),
              label: Text('Open Chat', style: NexusText.button),
            )
          : FloatingActionButton.extended(
              key: const ValueKey('join'),
              onPressed: () {
                _showJoinDialog(context);
              },
              backgroundColor: NexusColors.surfaceElevated,
              foregroundColor: NexusColors.textPrimary,
              icon: const Icon(Icons.person_add, size: 20),
              label: Text('Join Club', style: NexusText.button),
            ),
    );
  }

  void _showJoinDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: NexusColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Join Request', style: NexusText.cardTitle),
        content: Text(
          'Contact the club admin or wait for an invitation to become a verified member.',
          style: NexusText.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Got it', style: NexusText.button.copyWith(color: accentColor)),
          ),
        ],
      ),
    );
  }
}

// ── About Tab ─────────────────────────────────────────────────────────────────

class _AboutTab extends StatelessWidget {
  const _AboutTab({required this.club});

  final ClubModel club;

  @override
  Widget build(BuildContext context) {
    final accentColor = club.colorHex.toColor();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ABOUT', style: NexusText.sectionLabel),
          const SizedBox(height: 10),
          Text(
            club.description.isEmpty ? 'No description added yet.' : club.description,
            style: NexusText.body,
          ).animate().fadeIn(duration: 400.ms),

          if (club.socialLinks.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('LINKS', style: NexusText.sectionLabel),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: club.socialLinks.entries.map((entry) {
                return GestureDetector(
                  onTap: () async {
                    final uri = Uri.parse(entry.value);
                    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: accentColor.withOpacity(0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_iconForLink(entry.key), size: 14, color: accentColor),
                        const SizedBox(width: 6),
                        Text(
                          entry.key.capitalizeFirst,
                          style: NexusText.tag.copyWith(color: accentColor, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
          ],
        ],
      ),
    );
  }

  IconData _iconForLink(String key) {
    return switch (key.toLowerCase()) {
      'instagram' => Icons.camera_alt_outlined,
      'linkedin' => Icons.work_outline,
      'github' => Icons.code,
      'twitter' || 'x' => Icons.close,
      'website' => Icons.language,
      _ => Icons.link,
    };
  }
}

// ── Events Tab ─────────────────────────────────────────────────────────────────

class _EventsTab extends ConsumerWidget {
  const _EventsTab({required this.clubId, required this.accentColor});

  final String clubId;
  final Color accentColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(clubEventsProvider(clubId));

    return eventsAsync.when(
      loading: () => ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, __) => const EventCardShimmer(),
      ),
      error: (e, _) => Center(child: Text('Failed to load events.', style: NexusText.body)),
      data: (events) {
        if (events.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_outlined, color: NexusColors.textMuted, size: 48),
                const SizedBox(height: 12),
                Text('No events from this club yet.', style: NexusText.body),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          itemCount: events.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final event = events[index];
            return GestureDetector(
              onTap: () => context.push('/event/${event.id}'),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: NexusColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: NexusColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 3,
                      height: 48,
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [BoxShadow(color: accentColor.withOpacity(0.4), blurRadius: 6)],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(event.title, style: NexusText.cardTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(event.startDate.friendlyDate, style: NexusText.bodySmall),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 14, color: NexusColors.textMuted),
                  ],
                ),
              ).animate(delay: Duration(milliseconds: index * 60)).fadeIn(duration: 300.ms),
            );
          },
        );
      },
    );
  }
}

// ── Members Tab ────────────────────────────────────────────────────────────────

class _MembersTab extends ConsumerWidget {
  const _MembersTab({required this.clubId, required this.accentColor});

  final String clubId;
  final Color accentColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(clubMembersProvider(clubId));

    return membersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: NexusColors.cyan)),
      error: (e, _) => Center(child: Text('Failed to load members.', style: NexusText.body)),
      data: (members) {
        if (members.isEmpty) {
          return Center(child: Text('No members listed.', style: NexusText.body));
        }

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.9,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index];
            final roleTag = ClubRoleTag.fromString(member.roleTag);
            return Container(
              decoration: BoxDecoration(
                color: NexusColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: NexusColors.border),
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClubOrb(
                    clubColor: roleTag.color,
                    clubName: member.displayName,
                    logoUrl: member.avatarUrl,
                    size: 52,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    member.displayName,
                    style: NexusText.cardSubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  RoleTagChip(roleTag: roleTag, compact: true),
                ],
              ),
            ).animate(delay: Duration(milliseconds: index * 60)).fadeIn(duration: 300.ms);
          },
        );
      },
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────

class _ClubBadge extends StatelessWidget {
  const _ClubBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        label,
        style: NexusText.tag.copyWith(color: color, fontSize: 8),
      ),
    );
  }
}

class _DefaultClubBanner extends StatelessWidget {
  const _DefaultClubBanner({required this.accentColor});

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 1.2,
          colors: [accentColor.withOpacity(0.3), NexusColors.surface],
        ),
      ),
    );
  }
}

// ── Admin Badge Button ────────────────────────────────────────────────────────

class _AdminBadgeButton extends StatelessWidget {
  const _AdminBadgeButton({
    required this.clubId,
    required this.accentColor,
  });

  final String clubId;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Admin Panel',
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: GestureDetector(
          onTap: () => context.go('/club/$clubId/admin'),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: accentColor.withOpacity(0.4)),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(
              Icons.shield_outlined,
              color: accentColor,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate({required this.tabBar});

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: NexusColors.bg,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate old) => false;
}
