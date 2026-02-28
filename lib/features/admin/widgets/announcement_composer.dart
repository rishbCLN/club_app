import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../shared/widgets/glowing_button.dart';
import '../../../shared/widgets/nexus_text_field.dart';

class AnnouncementComposerSheet extends ConsumerStatefulWidget {
  const AnnouncementComposerSheet({
    super.key,
    required this.clubId,
    required this.accentColor,
    required this.senderTag,
  });

  final String clubId;
  final Color accentColor;
  final String senderTag;

  @override
  ConsumerState<AnnouncementComposerSheet> createState() =>
      _AnnouncementComposerSheetState();
}

class _AnnouncementComposerSheetState
    extends ConsumerState<AnnouncementComposerSheet> {
  final _controller = TextEditingController();
  bool _highPriority = false;
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);

    final uid = ref.read(currentUidProvider) ?? 'demo_user_001';
    final msg = MessageModel(
      id: 'ann_${DateTime.now().millisecondsSinceEpoch}',
      senderUid: uid,
      senderName: kDemoMode ? 'Aryan Mehta' : uid,
      senderTag: widget.senderTag,
      senderAccentColor:
          '#${widget.accentColor.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
      text: text,
      type: 'announcement',
      timestamp: DateTime.now(),
    );

    demoSendMessage(widget.clubId, msg);

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline,
                color: NexusColors.emerald, size: 16),
            const SizedBox(width: 8),
            Text('Announcement sent',
                style: NexusText.body.copyWith(color: NexusColors.textPrimary)),
          ],
        ),
        backgroundColor: NexusColors.surface,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: NexusColors.emerald.withOpacity(0.4)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: NexusColors.surfaceElevated,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: NexusColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Row(
                children: [
                  const Icon(Icons.campaign_outlined,
                      color: NexusColors.rose, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Broadcast Announcement',
                    style: GoogleFonts.syne(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: NexusColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Text input
              NexusTextField(
                controller: _controller,
                label: 'What do you want the club to know?',
                hint: 'Write your announcement...',
                maxLines: 6,
                accentColor: widget.accentColor,
              ),
              const SizedBox(height: 16),

              // Priority toggle
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: NexusColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: NexusColors.border),
                ),
                child: Row(
                  children: [
                    Text('Mark as high priority',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: NexusColors.textPrimary,
                        )),
                    const Spacer(),
                    Switch(
                      value: _highPriority,
                      onChanged: (v) => setState(() => _highPriority = v),
                      activeColor: NexusColors.rose,
                      inactiveThumbColor: NexusColors.textMuted,
                      inactiveTrackColor: NexusColors.border,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Send button
              GlowingButton(
                label: 'Send to Club Chat',
                icon: Icons.send_outlined,
                color1: widget.accentColor,
                color2: NexusColors.violet,
                isLoading: _sending,
                fullWidth: true,
                onTap: _sending ? null : _send,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showAnnouncementComposer(
  BuildContext context, {
  required String clubId,
  required Color accentColor,
  required String senderTag,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AnnouncementComposerSheet(
      clubId: clubId,
      accentColor: accentColor,
      senderTag: senderTag,
    ),
  );
}
