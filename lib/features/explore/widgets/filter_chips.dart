import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/role_tags.dart';
import '../../../core/constants/typography.dart';
import '../../../core/providers/providers.dart';

class FilterChipsRow extends ConsumerWidget {
  const FilterChipsRow({super.key});

  static List<String> get filters => [
        'All',
        ...EventType.values.map((e) => e.label),
      ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedFilterProvider);

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isActive = selected == filter;
          final color = _colorForFilter(filter);

          return GestureDetector(
            onTap: () {
              ref.read(selectedFilterProvider.notifier).state = filter;
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? color.withOpacity(0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? color.withOpacity(0.6) : NexusColors.border,
                  width: 1,
                ),
                boxShadow: isActive
                    ? [BoxShadow(color: color.withOpacity(0.2), blurRadius: 8)]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (filter != 'All') ...[
                    Text(
                      EventType.values
                          .firstWhere((e) => e.label == filter,
                              orElse: () => EventType.meetup)
                          .icon,
                      style: TextStyle(
                        fontSize: 10,
                        color: isActive ? color : NexusColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    filter,
                    style: NexusText.tag.copyWith(
                      color: isActive ? color : NexusColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ).animate(delay: Duration(milliseconds: index * 40))
              .fadeIn(duration: 300.ms)
              .slideX(begin: 0.1, end: 0);
        },
      ),
    );
  }

  Color _colorForFilter(String filter) {
    if (filter == 'All') return NexusColors.textSecondary;
    try {
      return EventType.values.firstWhere((e) => e.label == filter).color;
    } catch (_) {
      return NexusColors.textSecondary;
    }
  }
}

