import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';

class ComposerBar extends StatefulWidget {
  const ComposerBar({
    super.key,
    required this.onSend,
    required this.accentColor,
    this.onAttach,
  });

  final ValueChanged<String> onSend;
  final Color accentColor;
  final VoidCallback? onAttach;

  @override
  State<ComposerBar> createState() => _ComposerBarState();
}

class _ComposerBarState extends State<ComposerBar>
    with SingleTickerProviderStateMixin {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;
  late AnimationController _sendAnim;

  @override
  void initState() {
    super.initState();
    _sendAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _textController.addListener(() {
      final hasText = _textController.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _sendAnim.dispose();
    super.dispose();
  }

  void _send() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _sendAnim.forward().then((_) => _sendAnim.reverse());
    widget.onSend(text);
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.only(
            left: 12,
            right: 12,
            top: 10,
            bottom: MediaQuery.paddingOf(context).bottom + 10,
          ),
          decoration: BoxDecoration(
            color: NexusColors.bg.withOpacity(0.85),
            border: const Border(
              top: BorderSide(color: NexusColors.border, width: 1),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Attach button
              GestureDetector(
                onTap: () {
                  widget.onAttach?.call();
                  _showAttachSheet(context);
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: NexusColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: NexusColors.border),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: NexusColors.textSecondary,
                    size: 20,
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(width: 8),

              // Text input
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  decoration: BoxDecoration(
                    color: NexusColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: NexusColors.border),
                  ),
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    minLines: 1,
                    maxLines: 5,
                    textInputAction: TextInputAction.newline,
                    style: NexusText.chatMessage,
                    decoration: InputDecoration(
                      hintText: 'Message...',
                      hintStyle: NexusText.body.copyWith(
                        color: NexusColors.textMuted.withOpacity(0.6),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Send button
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: _hasText
                    ? GestureDetector(
                        key: const ValueKey('send'),
                        onTap: _send,
                        child: AnimatedBuilder(
                          animation: _sendAnim,
                          builder: (_, child) => Transform.scale(
                            scale: 1.0 + 0.15 * _sendAnim.value,
                            child: child,
                          ),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  widget.accentColor,
                                  widget.accentColor.withOpacity(0.6),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: widget.accentColor.withOpacity(0.4),
                                  blurRadius: 12,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        key: const ValueKey('idle'),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: NexusColors.surfaceElevated,
                          shape: BoxShape.circle,
                          border: Border.all(color: NexusColors.border),
                        ),
                        child: const Icon(
                          Icons.mic_none_outlined,
                          color: NexusColors.textMuted,
                          size: 18,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAttachSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: NexusColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 3,
              decoration: BoxDecoration(
                color: NexusColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text('Share Content', style: NexusText.cardTitle),
            const SizedBox(height: 20),
            Row(
              children: [
                _AttachOption(
                  icon: Icons.image_outlined,
                  label: 'Image',
                  color: NexusColors.violet,
                  onTap: () {
                    Navigator.pop(ctx);
                    // TODO: image picker
                  },
                ),
                const SizedBox(width: 12),
                _AttachOption(
                  icon: Icons.event_outlined,
                  label: 'Event',
                  color: NexusColors.emerald,
                  onTap: () {
                    Navigator.pop(ctx);
                    // TODO: event picker
                  },
                ),
                const SizedBox(width: 12),
                _AttachOption(
                  icon: Icons.campaign_outlined,
                  label: 'Announce',
                  color: NexusColors.amber,
                  onTap: () {
                    Navigator.pop(ctx);
                    // TODO: announcement
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _AttachOption extends StatelessWidget {
  const _AttachOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Expanded(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(label, style: NexusText.tag.copyWith(color: color, fontSize: 9)),
            ],
          ),
        ),
      ),
    );
  }
}
