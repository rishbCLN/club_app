import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
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

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _editMode = false;
  final _nameCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    if (kDemoMode) {
      ref.read(demoLoggedInProvider.notifier).state = false;
      ref.read(demoUserRoleProvider.notifier).state = UserRole.none;
      if (mounted) context.go('/auth/login');
      return;
    }
    await FirebaseAuth.instance.signOut();
    if (mounted) context.go('/auth/login');
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = ref.watch(isLoggedInProvider);
    final userAsync = ref.watch(userModelProvider);
    final myClubsAsync = ref.watch(myClubsProvider);

    if (!isLoggedIn) {
      return _NotLoggedInView();
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: userAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(
              color: NexusColors.cyan,
              strokeWidth: 1.5,
            ),
          ),
          error: (e, _) => Center(
            child: Text('Error loading profile.', style: NexusText.body),
          ),
          data: (user) {
            if (user == null) return _NotLoggedInView();
            return _buildProfile(user, myClubsAsync);
          },
        ),
      ),
    );
  }

  Widget _buildProfile(UserModel user, AsyncValue<List<ClubModel>> myClubsAsync) {
    return CustomScrollView(
      slivers: [
        // ── Header ────────────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Profile', style: NexusText.heroSubtitle)
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: -0.1, end: 0),
                IconButton(
                  onPressed: () => setState(() => _editMode = !_editMode),
                  icon: Icon(
                    _editMode ? Icons.close : Icons.edit_outlined,
                    color: NexusColors.textMuted,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Avatar Section ────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: myClubsAsync.when(
              loading: () => _AvatarRing(
                name: user.name,
                clubColors: const [],
              ),
              error: (_, __) => _AvatarRing(name: user.name, clubColors: const []),
              data: (clubs) => _AvatarRing(
                name: user.name,
                clubColors: clubs.map((c) => c.colorHex.toColor()).toList(),
              ),
            ),
          ).animate(delay: 100.ms).fadeIn().scaleXY(begin: 0.9, end: 1, curve: Curves.elasticOut),
        ),

        // ── Name & Roll ───────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                if (_editMode)
                  _EditNameField(
                    initialName: user.name,
                    onSaved: (newName) {
                      // TODO: update in Firestore
                      setState(() => _editMode = false);
                    },
                  )
                else ...[
                  Text(
                    user.name,
                    style: NexusText.heroSubtitle,
                    textAlign: TextAlign.center,
                  ).animate(delay: 150.ms).fadeIn(duration: 300.ms),
                  const SizedBox(height: 4),
                  Text(
                    user.rollNumber,
                    style: NexusText.mono.copyWith(
                      color: NexusColors.textMuted,
                      letterSpacing: 2,
                    ),
                  ).animate(delay: 180.ms).fadeIn(duration: 300.ms),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: NexusText.body.copyWith(color: NexusColors.textMuted, fontSize: 12),
                  ).animate(delay: 200.ms).fadeIn(duration: 300.ms),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // ── My Clubs ──────────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: myClubsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (clubs) {
              if (clubs.isEmpty) return const SizedBox.shrink();
              return _Section(
                title: 'My Clubs',
                child: SizedBox(
                  height: 90,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: clubs.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, i) => GestureDetector(
                      onTap: () => context.push('/club/${clubs[i].id}'),
                      child: ClubOrb(
                        clubColor: clubs[i].colorHex.toColor(),
                        clubName: clubs[i].name,
                        logoUrl: clubs[i].logoUrl,
                        size: 52,
                        showLabel: true,
                      ).animate(delay: Duration(milliseconds: i * 60)).fadeIn().slideY(begin: 0.15, end: 0),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // ── Role Tags ─────────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: myClubsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (clubs) {
              if (clubs.isEmpty) return const SizedBox.shrink();
              return _Section(
                title: 'My Role Tags',
                child: Consumer(
                  builder: (context, ref, _) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: clubs.asMap().entries.map((entry) {
                          final club = entry.value;
                          final roleAsync = ref.watch(memberRoleProvider(club.id));
                          return roleAsync.when(
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                            data: (member) {
                              if (member == null) return const SizedBox.shrink();
                              final roleTag = ClubRoleTag.fromString(member.roleTag);
                              return _RoleTagWithClub(
                                roleTag: roleTag,
                                clubName: club.name,
                                index: entry.key,
                              );
                            },
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),

        // ── Danger Zone ───────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 36, 24, 120),
            child: Column(
              children: [
                const Divider(color: NexusColors.border),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _logout,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: NexusColors.rose.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: NexusColors.rose.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout, color: NexusColors.rose, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Sign Out',
                          style: NexusText.button.copyWith(
                            color: NexusColors.rose,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate(delay: 300.ms).fadeIn(duration: 300.ms),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Avatar Ring ───────────────────────────────────────────────────────────────

class _AvatarRing extends StatefulWidget {
  const _AvatarRing({required this.name, required this.clubColors});
  final String name;
  final List<Color> clubColors;

  @override
  State<_AvatarRing> createState() => _AvatarRingState();
}

class _AvatarRingState extends State<_AvatarRing> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.clubColors.isEmpty
        ? [NexusColors.cyan, NexusColors.violet]
        : widget.clubColors;

    return Column(
      children: [
        AnimatedBuilder(
          animation: _ctrl,
          builder: (context, child) {
            return Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  startAngle: 0,
                  endAngle: 3.14159 * 2,
                  transform: GradientRotation(_ctrl.value * 3.14159 * 2),
                  colors: [
                    ...colors,
                    colors.first,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(3),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: NexusColors.bg,
                ),
                child: child,
              ),
            );
          },
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: NexusColors.surface,
            ),
            child: Center(
              child: Text(
                widget.name.initials,
                style: NexusText.heroSubtitle.copyWith(
                  fontSize: 28,
                  color: NexusColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Section Wrapper ───────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
            child: Text(title, style: NexusText.sectionLabel),
          ),
          child,
        ],
      ),
    );
  }
}

// ── Role Tag with Club Label ──────────────────────────────────────────────────

class _RoleTagWithClub extends StatelessWidget {
  const _RoleTagWithClub({
    required this.roleTag,
    required this.clubName,
    required this.index,
  });
  final ClubRoleTag roleTag;
  final String clubName;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: roleTag.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: roleTag.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            roleTag.displayLabel,
            style: NexusText.tag.copyWith(
              color: roleTag.color,
              letterSpacing: 1.0,
            ),
          ),
          Text(
            '@ $clubName',
            style: NexusText.tag.copyWith(
              color: roleTag.color.withOpacity(0.65),
              fontSize: 9,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: 60 * index))
        .fadeIn(duration: 300.ms)
        .scaleXY(begin: 0.9, end: 1, curve: Curves.elasticOut);
  }
}

// ── Edit Name Field ───────────────────────────────────────────────────────────

class _EditNameField extends StatefulWidget {
  const _EditNameField({required this.initialName, required this.onSaved});
  final String initialName;
  final void Function(String) onSaved;

  @override
  State<_EditNameField> createState() => _EditNameFieldState();
}

class _EditNameFieldState extends State<_EditNameField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: NexusColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: NexusColors.cyan.withOpacity(0.4)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(
            controller: _ctrl,
            autofocus: true,
            textAlign: TextAlign.center,
            style: NexusText.heroSubtitle.copyWith(fontSize: 22),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Your name',
            ),
          ),
        ),
        const SizedBox(height: 12),
        GlowingButton(
          label: 'Save',
          onTap: () => widget.onSaved(_ctrl.text.trim()),
          icon: Icons.check,
          color1: NexusColors.cyan,
          color2: NexusColors.violet,
        ),
      ],
    ).animate().fadeIn(duration: 250.ms);
  }
}

// ── Not Logged In View ────────────────────────────────────────────────────────

class _NotLoggedInView extends StatelessWidget {
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
                    color: NexusColors.cyan.withOpacity(0.08),
                    border: Border.all(color: NexusColors.cyan.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: NexusColors.cyan.withOpacity(0.15),
                        blurRadius: 40,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.person_outline, size: 48, color: NexusColors.cyan),
                )
                    .animate(onPlay: (ctrl) => ctrl.repeat(reverse: true))
                    .scaleXY(end: 1.05, duration: 2000.ms, curve: Curves.easeInOut),

                const SizedBox(height: 32),

                Text(
                  'Your profile awaits.',
                  style: NexusText.heroSubtitle,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 400.ms),

                const SizedBox(height: 10),

                Text(
                  'Sign in to manage your profile, view your role tags, and access private club spaces.',
                  style: NexusText.body,
                  textAlign: TextAlign.center,
                ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

                const SizedBox(height: 36),

                GlowingButton(
                  label: 'Sign In',
                  onTap: () => context.push('/auth/login'),
                  icon: Icons.login,
                  color1: NexusColors.cyan,
                  color2: NexusColors.violet,
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
