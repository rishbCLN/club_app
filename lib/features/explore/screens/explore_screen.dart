import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/utils/extensions.dart';
import '../../../shared/widgets/club_orb.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../widgets/event_card.dart';
import '../widgets/filter_chips.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubsAsync = ref.watch(clubsProvider);
    final eventsAsync = ref.watch(eventsProvider);
    final filter = ref.watch(selectedFilterProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // ── Hero Section ────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'NEXUS',
                          style: NexusText.appBarTitle.copyWith(
                            color: NexusColors.cyan,
                            letterSpacing: 4,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: NexusColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: NexusColors.border),
                          ),
                          child: const Icon(
                            Icons.search,
                            color: NexusColors.textMuted,
                            size: 20,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Hero text
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Every club.\n',
                            style: NexusText.heroTitle,
                          ),
                          WidgetSpan(
                            child: _ShimmerGradientText(
                              text: 'One place.',
                              style: NexusText.heroTitle,
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: 0.15, end: 0, duration: 600.ms),

                    const SizedBox(height: 10),

                    Text(
                      'No more lost WhatsApp groups.',
                      style: NexusText.body,
                    )
                        .animate(delay: 200.ms)
                        .fadeIn(duration: 500.ms),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),

            // ── Club Orbs Row ────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'CLUBS ON CAMPUS',
                      style: NexusText.sectionLabel,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 100,
                    child: clubsAsync.when(
                      loading: () => ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: 6,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, __) => const ClubOrbShimmer(size: 64),
                      ),
                      error: (e, _) => const SizedBox.shrink(),
                      data: (clubs) => ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: clubs.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final club = clubs[index];
                          return ClubOrb(
                            clubColor: club.colorHex.toColor(),
                            clubName: club.name,
                            logoUrl: club.logoUrl,
                            size: 60,
                            isPulsing: true,
                            showLabel: true,
                            onTap: () => context.push('/club/${club.id}'),
                          )
                              .animate(
                                  delay: Duration(milliseconds: index * 80))
                              .fadeIn(duration: 400.ms)
                              .slideY(
                                  begin: 0.3,
                                  end: 0,
                                  duration: 400.ms,
                                  curve: Curves.easeOut);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),

            // ── Filter Chips ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text('EVENTS', style: NexusText.sectionLabel),
                  ),
                  const SizedBox(height: 12),
                  const FilterChipsRow(),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // ── Events Masonry Grid ───────────────────────────────────────────
            eventsAsync.when(
              loading: () => SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => const EventCardShimmer(),
                    childCount: 5,
                  ),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Text(
                      'Could not load events.',
                      style: NexusText.body,
                    ),
                  ),
                ),
              ),
              data: (events) {
                final filtered = filter == 'All'
                    ? events
                    : events.where((e) {
                        return e.clubName.toLowerCase().contains(filter.toLowerCase()) ||
                            e.eventType.toLowerCase().contains(filter.toLowerCase()) ||
                            e.tags.any((t) => t.toLowerCase() == filter.toLowerCase());
                      }).toList();

                if (filtered.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(48.0),
                      child: Column(
                        children: [
                          Icon(Icons.event_busy_outlined,
                              color: NexusColors.textMuted, size: 48),
                          const SizedBox(height: 12),
                          Text('No events found for "$filter"',
                              style: NexusText.body, textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                  sliver: SliverMasonryGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childCount: filtered.length,
                    itemBuilder: (context, index) => EventCard(
                      event: filtered[index],
                      index: index,
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

// ── Shimmer Gradient Text ─────────────────────────────────────────────────────

class _ShimmerGradientText extends StatefulWidget {
  const _ShimmerGradientText({required this.text, required this.style});

  final String text;
  final TextStyle style;

  @override
  State<_ShimmerGradientText> createState() => _ShimmerGradientTextState();
}

class _ShimmerGradientTextState extends State<_ShimmerGradientText>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _animation = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final t = _animation.value;
        final colors = NexusColors.accents;
        final idx = (t * colors.length).floor();
        final c1 = colors[idx % colors.length];
        final c2 = colors[(idx + 1) % colors.length];
        final frac = (t * colors.length) - idx;

        return ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [c1, c2, c1],
            stops: [0.0, frac, 1.0],
            tileMode: TileMode.clamp,
          ).createShader(bounds),
          child: Text(widget.text, style: widget.style.copyWith(color: Colors.white)),
        );
      },
    );
  }
}
