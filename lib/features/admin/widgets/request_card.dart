import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../../../core/models/models.dart';
import '../providers/admin_providers.dart';

class RequestCard extends ConsumerStatefulWidget {
  const RequestCard({
    super.key,
    required this.request,
    required this.clubId,
    required this.accentColor,
    required this.index,
  });

  final JoinRequestModel request;
  final String clubId;
  final Color accentColor;
  final int index;

  @override
  ConsumerState<RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends ConsumerState<RequestCard> {
  bool _exiting = false;
  double _exitSlide = 0;
  bool _busy = false;

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays >= 1) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inMinutes}m ago';
    }
  }

  Future<void> _approve() async {
    setState(() => _busy = true);
    ref.read(demoJoinRequestsProvider(widget.clubId).notifier).approve(widget.request.id);
    setState(() {
      _exiting = true;
      _exitSlide = 1.0;
    });
  }

  Future<void> _reject() async {
    setState(() => _busy = true);
    ref.read(demoJoinRequestsProvider(widget.clubId).notifier).reject(widget.request.id);
    setState(() {
      _exiting = true;
      _exitSlide = -1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isReviewed = widget.request.status != JoinRequestStatus.pending;

    Widget card = Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NexusColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isReviewed
              ? NexusColors.border
              : NexusColors.amber.withOpacity(0.25),
          width: 1,
        ),
        boxShadow: isReviewed
            ? null
            : [
                BoxShadow(
                  color: NexusColors.amber.withOpacity(0.07),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
      ),
      child: Row(
        children: [
          // Avatar with pulsing ring (amber for pending)
          _AvatarWithRing(
            displayName: widget.request.displayName,
            avatarUrl: widget.request.avatarUrl,
            ringColor: isReviewed
                ? (widget.request.status == JoinRequestStatus.approved
                    ? NexusColors.emerald
                    : NexusColors.rose)
                : NexusColors.amber,
            pulse: !isReviewed,
          ),
          const SizedBox(width: 12),
          // Info column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.request.displayName,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: NexusColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      widget.request.collegeRollNo,
                      style: GoogleFonts.spaceMono(
                        fontSize: 11,
                        color: NexusColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '· ${_timeAgo(widget.request.requestedAt)}',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: NexusColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Action buttons or status badge
          if (isReviewed) ...[
            _StatusBadge(status: widget.request.status)
          ] else ...[
            // Reject outlined
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: NexusColors.rose, width: 1),
                foregroundColor: NexusColors.rose,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _busy ? null : _reject,
              child: Text(
                'Reject',
                style: GoogleFonts.spaceMono(
                    fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
            // Approve filled
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: NexusColors.emerald,
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                elevation: 0,
                shadowColor: NexusColors.emerald.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _busy ? null : _approve,
              child: Text(
                'Approve',
                style: GoogleFonts.spaceMono(
                    fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
    );

    // Entrance animation
    card = card
        .animate(delay: Duration(milliseconds: widget.index * 70))
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.12, end: 0, duration: 300.ms);

    // Exit animation on approve/reject
    if (_exiting) {
      card = card
          .animate()
          .slideX(begin: 0, end: _exitSlide, duration: 280.ms)
          .fadeOut(duration: 280.ms);
    }

    return card;
  }
}

class _AvatarWithRing extends StatelessWidget {
  const _AvatarWithRing({
    required this.displayName,
    required this.avatarUrl,
    required this.ringColor,
    required this.pulse,
  });

  final String displayName;
  final String? avatarUrl;
  final Color ringColor;
  final bool pulse;

  @override
  Widget build(BuildContext context) {
    Widget ring = Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ringColor.withOpacity(0.6), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: CircleAvatar(
          backgroundColor: ringColor.withOpacity(0.12),
          backgroundImage:
              avatarUrl != null ? NetworkImage(avatarUrl!) : null,
          child: avatarUrl == null
              ? Text(
                  displayName.substring(0, 1).toUpperCase(),
                  style: GoogleFonts.syne(
                    fontWeight: FontWeight.w700,
                    color: ringColor,
                    fontSize: 18,
                  ),
                )
              : null,
        ),
      ),
    );

    if (pulse) {
      ring = ring
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .custom(
            duration: 1200.ms,
            builder: (_, val, child) => DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: ringColor.withOpacity(0.15 + val * 0.25),
                    blurRadius: 12 + val * 8,
                    spreadRadius: val * 4,
                  )
                ],
              ),
              child: child!,
            ),
          );
    }

    return ring;
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final JoinRequestStatus status;

  @override
  Widget build(BuildContext context) {
    final isApproved = status == JoinRequestStatus.approved;
    final color = isApproved ? NexusColors.emerald : NexusColors.rose;
    final label = isApproved ? 'Approved' : 'Rejected';
    final icon = isApproved ? Icons.check_circle_outline : Icons.cancel_outlined;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.spaceMono(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
