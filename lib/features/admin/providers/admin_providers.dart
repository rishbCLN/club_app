import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/role_tags.dart';
import '../../../core/mock/mock_data.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';

// ── Admin access check ────────────────────────────────────────────────────────

/// Returns true if the current user has a head-level role in the given club.
final isClubAdminProvider = Provider.family<bool, String>((ref, clubId) {
  if (!kDemoMode) return false;
  final uid = ref.read(currentUidProvider);
  if (uid == null) return false;
  final members = kMockMembers[clubId] ?? [];
  try {
    final member = members.firstWhere((m) => m.uid == uid);
    return kAdminRoles.contains(ClubRoleTag.fromString(member.roleTag));
  } catch (_) {
    return false;
  }
});

// ── Join Requests (demo mode) ─────────────────────────────────────────────────

class JoinRequestNotifier extends StateNotifier<List<JoinRequestModel>> {
  final String clubId;
  final Ref _ref;

  JoinRequestNotifier(this.clubId, this._ref)
      : super(List<JoinRequestModel>.from(kMockJoinRequests[clubId] ?? []));

  void approve(String requestId) {
    // Update status to approved
    state = state.map((r) {
      if (r.id != requestId) return r;
      return r.copyWith(status: JoinRequestStatus.approved);
    }).toList();
    // Add the user to the club's member list
    final approved = state.firstWhere((r) => r.id == requestId);
    _ref.read(demoMembersProvider(clubId).notifier).addMember(
          ClubMemberModel(
            uid: approved.userId,
            displayName: approved.displayName,
            avatarUrl: approved.avatarUrl,
            roleTag: ClubRoleTag.member.name,
            joinedAt: DateTime.now(),
            isAdmin: false,
            rollNo: approved.collegeRollNo,
          ),
        );
  }

  void reject(String requestId) {
    state = state.map((r) {
      if (r.id != requestId) return r;
      return r.copyWith(status: JoinRequestStatus.rejected);
    }).toList();
  }
}

final demoJoinRequestsProvider = StateNotifierProvider.family<
    JoinRequestNotifier, List<JoinRequestModel>, String>(
  (ref, clubId) => JoinRequestNotifier(clubId, ref),
);
