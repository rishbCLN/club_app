import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/role_tags.dart';
import '../../../core/constants/typography.dart';
import '../../../core/providers/providers.dart';

class FilterChipsRow extends ConsumerWidget {
  const FilterChipsRow({super.key});

  static const _filters = ['All', 'Tech', 'Design', 'Cultural', 'Hackathon', 'Literary'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedFilterProvider);

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
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
              child: Text(
                filter,
                style: NexusText.tag.copyWith(
                  color: isActive ? color : NexusColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ),
          ).animate(delay: Duration(milliseconds: index * 60))
              .fadeIn(duration: 300.ms)
              .slideX(begin: 0.1, end: 0);
        },
      ),
    );
  }

  Color _colorForFilter(String filter) {
    return switch (filter) {
      'Tech' => NexusColors.cyan,
      'Design' => NexusColors.orange,
      'Cultural' => NexusColors.rose,
      'Hackathon' => NexusColors.emerald,
      'Literary' => NexusColors.violet,
      _ => NexusColors.textSecondary,
    };
  }
}
