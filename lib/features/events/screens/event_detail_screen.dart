import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/role_tags.dart';
import '../../../core/constants/typography.dart';
import '../../../core/providers/providers.dart';
import '../../../core/utils/extensions.dart';
import '../../../shared/widgets/club_orb.dart';
import '../../../shared/widgets/glassmorphic_card.dart';
import '../../../shared/widgets/glowing_button.dart';
import '../../../shared/widgets/shimmer_loader.dart';

class EventDetailScreen extends ConsumerWidget {
  const EventDetailScreen({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventProvider(eventId));

    return eventAsync.when(
      loading: () => const Scaffold(
        backgroundColor: NexusColors.bg,
        body: Center(child: CircularProgressIndicator(color: NexusColors.cyan)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: NexusColors.bg,
        body: Center(child: Text('Event not found.', style: NexusText.body)),
      ),
      data: (event) {
        if (event == null) {
          return Scaffold(
            backgroundColor: NexusColors.bg,
            appBar: AppBar(backgroundColor: NexusColors.bg),
            body: Center(child: Text('Event not found.', style: NexusText.body)),
          );
        }

        final accentColor = event.clubColorHex.toColor();
        final eventType = EventType.fromString(event.eventType);

        return Scaffold(
          backgroundColor: NexusColors.bg,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
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
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GlassmorphicCard(
                  padding: EdgeInsets.zero,
                  borderRadius: 12,
                  onTap: () {
                    Share.share(
                      '${event.title}\n${event.description}\n\nJoin us at ${event.venue} on ${event.startDate.friendlyDateTime}',
                    );
                  },
                  child: const SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(Icons.share_outlined, color: NexusColors.textPrimary, size: 20),
                  ),
                ),
              ),
            ],
          ),
          body: CustomScrollView(
            slivers: [
              // Banner
              SliverAppBar(
                expandedHeight: 260,
                automaticallyImplyLeading: false,
                backgroundColor: NexusColors.bg,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (event.bannerUrl != null)
                        CachedNetworkImage(
                          imageUrl: event.bannerUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(color: NexusColors.surface),
                          errorWidget: (_, __, ___) => _DefaultBanner(accentColor: accentColor),
                        )
                      else
                        _DefaultBanner(accentColor: accentColor),

                      // Gradient overlay
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              NexusColors.bg.withOpacity(0.6),
                              NexusColors.bg,
                            ],
                            stops: const [0.3, 0.7, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type + Collab badge row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: eventType.color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: eventType.color.withOpacity(0.3)),
                            ),
                            child: Text(
                              eventType.label.toUpperCase(),
                              style: NexusText.tag.copyWith(color: eventType.color),
                            ),
                          ),
                          if (event.hasCollaboration) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: NexusColors.violet.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: NexusColors.violet.withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.link, size: 12, color: NexusColors.violet),
                                  const SizedBox(width: 4),
                                  Text(
                                    'COLLABORATION',
                                    style: NexusText.tag.copyWith(
                                      color: NexusColors.violet,
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ).animate().fadeIn(duration: 400.ms),

                      const SizedBox(height: 14),

                      // Event title
                      Text(event.title, style: NexusText.heroSubtitle)
                          .animate(delay: 80.ms)
                          .fadeIn(duration: 500.ms)
                          .slideY(begin: 0.1, end: 0),

                      const SizedBox(height: 20),

                      // Organizer club
                      _InfoRow(
                        label: 'Organized by',
                        child: GestureDetector(
                          onTap: () => context.push('/club/${event.clubId}'),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClubOrb(
                                clubColor: accentColor,
                                clubName: event.clubName,
                                size: 28,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                event.clubName,
                                style: NexusText.cardSubtitle.copyWith(
                                  color: accentColor,
                                  decoration: TextDecoration.underline,
                                  decorationColor: accentColor.withOpacity(0.4),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.open_in_new, size: 12, color: accentColor.withOpacity(0.6)),
                            ],
                          ),
                        ),
                      ).animate(delay: 150.ms).fadeIn(duration: 400.ms),

                      const SizedBox(height: 16),

                      // Date & Time
                      _InfoRow(
                        label: 'Date & Time',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _GlowingInfoItem(
                              icon: Icons.calendar_today_outlined,
                              text: '${event.startDate.relativeLabel} — ${event.endDate.relativeLabel}',
                              glowColor: accentColor,
                            ),
                            const SizedBox(height: 4),
                            _GlowingInfoItem(
                              icon: Icons.access_time_outlined,
                              text: '${event.startDate.friendlyTime} – ${event.endDate.friendlyTime}',
                              glowColor: accentColor,
                            ),
                          ],
                        ),
                      ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

                      const SizedBox(height: 16),

                      // Venue
                      _InfoRow(
                        label: 'Venue',
                        child: _GlowingInfoItem(
                          icon: Icons.location_on_outlined,
                          text: event.venue,
                          glowColor: NexusColors.rose,
                        ),
                      ).animate(delay: 250.ms).fadeIn(duration: 400.ms),

                      const SizedBox(height: 24),

                      // Description
                      Text('About', style: NexusText.sectionLabel),
                      const SizedBox(height: 10),
                      Text(
                        event.description.isEmpty
                            ? 'No description provided.'
                            : event.description,
                        style: NexusText.body,
                      ).animate(delay: 300.ms).fadeIn(duration: 400.ms),

                      // Tags
                      if (event.tags.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: event.tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: NexusColors.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: NexusColors.border),
                              ),
                              child: Text(
                                '#$tag',
                                style: NexusText.tag.copyWith(color: NexusColors.textMuted),
                              ),
                            );
                          }).toList(),
                        ).animate(delay: 350.ms).fadeIn(duration: 400.ms),
                      ],

                      const SizedBox(height: 36),

                      // CTA
                      if (event.registrationLink != null)
                        TracingBorderButton(
                          label: 'Register Now',
                          icon: Icons.open_in_new,
                          color: accentColor,
                          onTap: () async {
                            final uri = Uri.parse(event.registrationLink!);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri,
                                  mode: LaunchMode.externalApplication);
                            }
                          },
                        ).animate(delay: 400.ms).fadeIn(duration: 400.ms)
                      else
                        GlowingButton(
                          label: 'Registration Link TBA',
                          onTap: null,
                          isOutlined: true,
                          fullWidth: true,
                          color1: NexusColors.textMuted,
                          color2: NexusColors.textMuted,
                        ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: NexusText.sectionLabel),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _GlowingInfoItem extends StatelessWidget {
  const _GlowingInfoItem({
    required this.icon,
    required this.text,
    required this.glowColor,
  });

  final IconData icon;
  final String text;
  final Color glowColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [glowColor, glowColor.withOpacity(0.6)],
          ).createShader(bounds),
          child: Icon(icon, size: 16, color: Colors.white),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(text, style: NexusText.cardSubtitle),
        ),
      ],
    );
  }
}

class _DefaultBanner extends StatelessWidget {
  const _DefaultBanner({required this.accentColor});

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.3),
          radius: 1.0,
          colors: [
            accentColor.withOpacity(0.25),
            NexusColors.surface,
          ],
        ),
      ),
    );
  }
}
