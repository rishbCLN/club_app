import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../admin/providers/admin_providers.dart';
import '../../../core/utils/extensions.dart';
import '../../../shared/widgets/club_orb.dart';
import '../../../shared/widgets/shimmer_loader.dart';
import '../widgets/access_denied_screen.dart';
import '../widgets/composer_bar.dart';
import '../widgets/message_bubble.dart';

class ClubChatScreen extends ConsumerStatefulWidget {
  const ClubChatScreen({super.key, required this.clubId});

  final String clubId;

  @override
  ConsumerState<ClubChatScreen> createState() => _ClubChatScreenState();
}

class _ClubChatScreenState extends ConsumerState<ClubChatScreen> {
  final _listKey = GlobalKey<AnimatedListState>();
  final _scrollController = ScrollController();
  bool? _isMember;
  ClubMemberModel? _myMembership;
  bool _accessChecked = false;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    if (kDemoMode) {
      final isLoggedIn = ref.read(isLoggedInProvider);
      if (!isLoggedIn) {
        if (mounted) context.go('/auth/login');
        return;
      }
      final uid = ref.read(currentUidProvider);
      final members = kMockMembers[widget.clubId] ?? [];
      ClubMemberModel? membership;
      try {
        membership = members.firstWhere((m) => m.uid == uid);
      } catch (_) {
        membership = null;
      }
      if (mounted) {
        setState(() {
          _isMember = membership != null;
          _myMembership = membership;
          _accessChecked = true;
        });
      }
      return;
    }
    // --- production path ---
    if (mounted) setState(() => _accessChecked = true);
  }

  Future<void> _sendMessage(String text) async {
    if (_myMembership == null) return;

    final clubAsync = ref.read(clubProvider(widget.clubId));
    final accentHex = clubAsync.valueOrNull?.colorHex ?? '#00FFCC';

    final msg = MessageModel(
      id: 'demo_${DateTime.now().millisecondsSinceEpoch}',
      senderUid: _myMembership!.uid,
      senderName: _myMembership!.displayName,
      senderTag: _myMembership!.roleTag,
      senderAvatarUrl: _myMembership!.avatarUrl,
      senderAccentColor: accentHex,
      text: text,
      type: 'text',
      timestamp: DateTime.now(),
    );

    if (kDemoMode) {
      demoSendMessage(widget.clubId, msg);
    }

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clubAsync = ref.watch(clubProvider(widget.clubId));

    if (!_accessChecked) {
      return const Scaffold(
        backgroundColor: NexusColors.bg,
        body: Center(
          child: CircularProgressIndicator(color: NexusColors.cyan),
        ),
      );
    }

    if (_isMember == false) {
      return AccessDeniedScreen(
        clubName: clubAsync.valueOrNull?.name ?? 'this club',
      );
    }

    return clubAsync.when(
      loading: () => const Scaffold(
        backgroundColor: NexusColors.bg,
        body: Center(child: CircularProgressIndicator(color: NexusColors.cyan)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: NexusColors.bg,
        appBar: AppBar(backgroundColor: NexusColors.bg),
        body: Center(child: Text('Error loading club chat.', style: NexusText.body)),
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
        final isAdmin = ref.watch(isClubAdminProvider(widget.clubId));

        return Scaffold(
          backgroundColor: NexusColors.bg,
          resizeToAvoidBottomInset: true,
          extendBodyBehindAppBar: true,
          appBar: _ChatAppBar(club: club, accentColor: accentColor, isAdmin: isAdmin),
          body: Column(
            children: [
              // Messages
              Expanded(
                child: _MessageList(
                  clubId: widget.clubId,
                  scrollController: _scrollController,
                  currentUid: ref.read(currentUidProvider) ?? '',
                ),
              ),

              // Composer bar
              ComposerBar(
                onSend: _sendMessage,
                accentColor: accentColor,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Chat App Bar ───────────────────────────────────────────────────────────────

class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ChatAppBar({
    required this.club,
    required this.accentColor,
    this.isAdmin = false,
  });

  final ClubModel club;
  final Color accentColor;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: AppBar(
          backgroundColor: NexusColors.bg.withOpacity(0.80),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: NexusColors.textSecondary),
            onPressed: () => context.pop(),
          ),
          title: Row(
            children: [
              ClubOrb(
                clubColor: accentColor,
                clubName: club.name,
                logoUrl: club.logoUrl,
                size: 32,
                isPulsing: true,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(club.name, style: NexusText.cardTitle.copyWith(fontSize: 15)),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: NexusColors.emerald,
                            boxShadow: [
                              BoxShadow(
                                color: NexusColors.emerald.withOpacity(0.6),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        )
                            .animate(onPlay: (ctrl) => ctrl.repeat(reverse: true))
                            .scaleXY(end: 1.3, duration: 1000.ms),
                        const SizedBox(width: 4),
                        Text(
                          'Live · ${club.memberCount} members',
                          style: NexusText.bodySmall.copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: NexusColors.textMuted),
              color: NexusColors.surfaceElevated,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (value) {
                if (value == 'admin') {
                  context.push('/club/${club.id}/admin');
                }
                // TODO: implement other menu actions
              },
              itemBuilder: (_) => [
                if (isAdmin)
                  _menuItem('admin', Icons.shield_outlined, 'Admin Panel'),
                _menuItem('members', Icons.group_outlined, 'Members'),
                _menuItem('pinned', Icons.push_pin_outlined, 'Pinned'),
                _menuItem('settings', Icons.settings_outlined, 'Settings'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String label) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 16, color: NexusColors.textSecondary),
          const SizedBox(width: 8),
          Text(label, style: NexusText.body),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// ── Message List ───────────────────────────────────────────────────────────────

class _MessageList extends ConsumerWidget {
  const _MessageList({
    required this.clubId,
    required this.scrollController,
    required this.currentUid,
  });

  final String clubId;
  final ScrollController scrollController;
  final String currentUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(messagesProvider(clubId));

    return messagesAsync.when(
      loading: () => ListView.builder(
        reverse: true,
        itemCount: 8,
        itemBuilder: (_, i) => MessageBubbleShimmer(isOwn: i % 3 == 0),
      ),
      error: (e, _) => Center(
        child: Text('Could not load messages.', style: NexusText.body),
      ),
      data: (messages) {
        if (messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline,
                    color: NexusColors.textMuted, size: 48),
                const SizedBox(height: 12),
                Text('No messages yet.', style: NexusText.body),
                const SizedBox(height: 4),
                Text('Be the first to say something!', style: NexusText.bodySmall),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: scrollController,
          reverse: true,
          padding: const EdgeInsets.only(top: 100, bottom: 8),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isOwn = message.senderUid == currentUid;
            return MessageBubble(
              message: message,
              isOwn: isOwn,
              index: index,
              onLongPress: () {
                // TODO: show reaction picker at tap position
              },
            );
          },
        );
      },
    );
  }
}
