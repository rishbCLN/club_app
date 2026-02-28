import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/role_tags.dart';
import '../../../core/constants/typography.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/utils/extensions.dart';
import '../../../shared/widgets/club_orb.dart';
import '../../../shared/widgets/glowing_button.dart';
import '../../../shared/widgets/role_tag_chip.dart';
import '../../../shared/widgets/shimmer_loader.dart';

class MyClubsScreen extends ConsumerWidget {
  const MyClubsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(isLoggedInProvider);
    final userAsync = ref.watch(userModelProvider);
    final myClubsAsync = ref.watch(myClubsProvider);

    // Not logged in
    if (!isLoggedIn) {
      return _NotLoggedInState();
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('My Clubs', style: NexusText.heroSubtitle)
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 4),
                    Text(
                      'Your active club memberships.',
                      style: NexusText.body,
                    ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
                  ],
                ),
              ),
            ),

            myClubsAsync.when(
              loading: () => SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, __) => Container(
                      decoration: BoxDecoration(
                        color: NexusColors.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    childCount: 4,
                  ),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text('Failed to load clubs.', style: NexusText.body),
                  ),
                ),
              ),
              data: (clubs) {
                if (clubs.isEmpty) {
                  return SliverToBoxAdapter(
                    child: _EmptyMyClubs(),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.82,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _MyClubCard(
                        club: clubs[index],
                        index: index,
                      ),
                      childCount: clubs.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── My Club Card ───────────────────────────────────────────────────────────────

class _MyClubCard extends ConsumerWidget {
  const _MyClubCard({required this.club, required this.index});

  final ClubModel club;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accentColor = club.colorHex.toColor();
    final memberRoleAsync = ref.watch(memberRoleProvider(club.id));

    return GestureDetector(
      onTap: () => context.push('/club/${club.id}/chat'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: NexusColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: accentColor.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                ClubOrb(
                  clubColor: accentColor,
                  clubName: club.name,
                  logoUrl: club.logoUrl,
                  size: 56,
                  isPulsing: true,
                ),
                // Unread badge placeholder
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: NexusColors.rose,
                      shape: BoxShape.circle,
                      border: Border.all(color: NexusColors.bg, width: 2),
                    ),
                    child: const SizedBox(width: 6, height: 6),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Text(
              club.name,
              style: NexusText.cardTitle.copyWith(fontSize: 14),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 6),

            memberRoleAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (member) {
                if (member == null) return const SizedBox.shrink();
                return RoleTagChip(
                  roleTag: ClubRoleTag.fromString(member.roleTag),
                  compact: true,
                );
              },
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: accentColor.withOpacity(0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 11, color: accentColor),
                  const SizedBox(width: 4),
                  Text(
                    'Open Chat',
                    style: NexusText.tag.copyWith(color: accentColor, fontSize: 9),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 100 + index * 80))
        .fadeIn(duration: 400.ms)
        .scaleXY(begin: 0.85, end: 1.0, duration: 400.ms, curve: Curves.elasticOut);
  }
}

// ── Not Logged In State ────────────────────────────────────────────────────────

class _NotLoggedInState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(36.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: NexusColors.violet.withOpacity(0.1),
                    border: Border.all(color: NexusColors.violet.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: NexusColors.violet.withOpacity(0.2),
                        blurRadius: 40,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.group_outlined,
                    size: 44,
                    color: NexusColors.violet,
                  ),
                )
                    .animate(onPlay: (ctrl) => ctrl.repeat(reverse: true))
                    .scaleXY(end: 1.05, duration: 2000.ms, curve: Curves.easeInOut),

                const SizedBox(height: 32),

                Text(
                  "You're not in yet.",
                  style: NexusText.heroSubtitle,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 400.ms),

                const SizedBox(height: 10),

                Text(
                  'Sign in to see your club memberships, role tags, and access private chats.',
                  style: NexusText.body,
                  textAlign: TextAlign.center,
                ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: 36),

                GlowingButton(
                  label: 'Sign In',
                  onTap: () => context.push('/auth/login'),
                  icon: Icons.login,
                  color1: NexusColors.violet,
                  color2: NexusColors.cyan,
                  fullWidth: true,
                ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Empty My Clubs State ───────────────────────────────────────────────────────

class _EmptyMyClubs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(36.0),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Icon(Icons.group_add_outlined, color: NexusColors.textMuted, size: 56)
              .animate(onPlay: (ctrl) => ctrl.repeat(reverse: true))
              .scaleXY(end: 1.06, duration: 2000.ms, curve: Curves.easeInOut),
          const SizedBox(height: 20),
          Text(
            "You haven't joined any clubs yet.",
            style: NexusText.cardTitle,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Browse clubs on the Explore tab and request to join.',
            style: NexusText.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GlowingButton(
            label: 'Explore Clubs',
            onTap: () => context.go('/home/explore'),
            isOutlined: true,
            color1: NexusColors.cyan,
            color2: NexusColors.cyan,
          ),
        ],
      ),
    );
  }
}
