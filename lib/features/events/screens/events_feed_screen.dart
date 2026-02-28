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
import '../../../shared/widgets/shimmer_loader.dart';
import '../../explore/widgets/filter_chips.dart';

class EventsFeedScreen extends ConsumerStatefulWidget {
  const EventsFeedScreen({super.key});

  @override
  ConsumerState<EventsFeedScreen> createState() => _EventsFeedScreenState();
}

class _EventsFeedScreenState extends ConsumerState<EventsFeedScreen>
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
    final eventsAsync = ref.watch(eventsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Events', style: NexusText.heroSubtitle)
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 4),
                  Text(
                    'Workshops, hackathons, fests and more.',
                    style: NexusText.body,
                  ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
                ],
              ),
            ),

            // Tab bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 40,
              decoration: BoxDecoration(
                color: NexusColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: NexusColors.border),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: NexusColors.cyan.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: NexusColors.cyan.withOpacity(0.4)),
                ),
                labelStyle: NexusText.tag.copyWith(fontSize: 10),
                unselectedLabelStyle: NexusText.tag.copyWith(fontSize: 10),
                labelColor: NexusColors.cyan,
                unselectedLabelColor: NexusColors.textMuted,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'UPCOMING'),
                  Tab(text: 'ONGOING'),
                  Tab(text: 'PAST'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Event type filter chips
            const FilterChipsRow(),

            const SizedBox(height: 12),

            // Event lists
            Expanded(
              child: eventsAsync.when(
                loading: () => ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: 5,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, __) => const EventCardShimmer(),
                ),
                error: (e, _) => Center(
                  child: Text('Failed to load events.', style: NexusText.body),
                ),
                data: (events) {
                  final filter = ref.watch(selectedFilterProvider);
                  List<EventModel> applyFilter(List<EventModel> list) {
                    if (filter == 'All') return list;
                    return list.where((e) {
                      final typeLabel =
                          EventType.fromString(e.eventType).label.toLowerCase();
                      return typeLabel == filter.toLowerCase();
                    }).toList();
                  }

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _EventList(
                        events: applyFilter(events.where((e) => e.isUpcoming).toList()),
                        emptyMessage: 'No upcoming events',
                      ),
                      _EventList(
                        events: applyFilter(events.where((e) => e.isOngoing).toList()),
                        emptyMessage: 'No ongoing events',
                      ),
                      _EventList(
                        events: applyFilter(
                            events.where((e) => !e.isUpcoming && !e.isOngoing).toList()),
                        emptyMessage: 'No past events',
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventList extends StatelessWidget {
  const _EventList({required this.events, required this.emptyMessage});

  final List<EventModel> events;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_outlined, color: NexusColors.textMuted, size: 48),
            const SizedBox(height: 12),
            Text(emptyMessage, style: NexusText.body),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
      itemCount: events.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _FullEventCard(
        event: events[index],
        index: index,
      ),
    );
  }
}

class _FullEventCard extends StatelessWidget {
  const _FullEventCard({required this.event, required this.index});

  final EventModel event;
  final int index;

  @override
  Widget build(BuildContext context) {
    final accentColor = event.clubColorHex.toColor();
    final eventType = EventType.fromString(event.eventType);

    return GestureDetector(
      onTap: () => context.push('/event/${event.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: NexusColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: NexusColors.border),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event type color bar
            Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accentColor, accentColor.withOpacity(0.2)],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Club tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          event.clubName,
                          style: NexusText.tag.copyWith(color: accentColor, fontSize: 9),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: eventType.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          eventType.label.toUpperCase(),
                          style: NexusText.tag.copyWith(color: eventType.color, fontSize: 9),
                        ),
                      ),
                      if (event.eventType == EventType.recruitmentDrive.name) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: NexusColors.rose.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: NexusColors.rose.withOpacity(0.4)),
                          ),
                          child: Text(
                            'HIRING',
                            style: NexusText.tag.copyWith(color: NexusColors.rose, fontSize: 9),
                          ),
                        ),
                      ],
                      if (event.hasCollaboration) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: NexusColors.violet.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'COLLAB',
                            style: NexusText.tag.copyWith(
                              color: NexusColors.violet,
                              fontSize: 8,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(event.title, style: NexusText.cardTitle, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Text(
                    event.description,
                    style: NexusText.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.access_time_outlined,
                          size: 13, color: NexusColors.textMuted),
                      const SizedBox(width: 4),
                      Text(event.startDate.friendlyDateTime, style: NexusText.bodySmall),
                      const Spacer(),
                      const Icon(Icons.location_on_outlined,
                          size: 13, color: NexusColors.textMuted),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          event.venue,
                          style: NexusText.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 80))
        .fadeIn(duration: 400.ms, curve: Curves.easeOut)
        .slideY(begin: 0.15, end: 0, duration: 400.ms);
  }
}
