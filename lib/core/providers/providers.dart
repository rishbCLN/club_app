// ─────────────────────────────────────────────────────────────────────────────
// providers.dart  ·  NEXUS
//
// kDemoMode = true  →  no Firebase, all data comes from mock_data.dart
// kDemoMode = false →  live Firestore / Firebase Auth (production)
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../mock/mock_data.dart';

// ── Demo flag ──────────────────────────────────────────────────────────────────

const kDemoMode = true;

// ── Demo login state (toggled by login / logout buttons in demo) ───────────────

final demoLoggedInProvider = StateProvider<bool>((ref) => true);

// ── "Is logged in" — single source of truth for all screens ───────────────────

final isLoggedInProvider = Provider<bool>((ref) {
  if (kDemoMode) return ref.watch(demoLoggedInProvider);
  return false;
});

// ── Current user UID ───────────────────────────────────────────────────────────

final currentUidProvider = Provider<String?>((ref) {
  if (!ref.watch(isLoggedInProvider)) return null;
  if (kDemoMode) return kDemoUser.uid;
  return null;
});

// ── User model ─────────────────────────────────────────────────────────────────

final userModelProvider = StreamProvider.autoDispose<UserModel?>((ref) {
  if (kDemoMode) {
    final loggedIn = ref.watch(demoLoggedInProvider);
    return Stream.value(loggedIn ? kDemoUser : null);
  }
  return Stream.value(null);
});

// ── Clubs ──────────────────────────────────────────────────────────────────────

final clubsProvider = StreamProvider.autoDispose<List<ClubModel>>((ref) {
  if (kDemoMode) return Stream.value(kMockClubs);
  return Stream.value([]);
});

final clubProvider =
    StreamProvider.autoDispose.family<ClubModel?, String>((ref, clubId) {
  if (kDemoMode) {
    final club = kMockClubs.cast<ClubModel?>().firstWhere(
          (c) => c?.id == clubId,
          orElse: () => null,
        );
    return Stream.value(club);
  }
  return Stream.value(null);
});

// ── Club Members ───────────────────────────────────────────────────────────────

final clubMembersProvider =
    StreamProvider.autoDispose.family<List<ClubMemberModel>, String>((ref, clubId) {
  if (kDemoMode) return Stream.value(kMockMembers[clubId] ?? []);
  return Stream.value([]);
});

final isMemberProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, clubId) async {
  if (kDemoMode) {
    final uid = ref.watch(currentUidProvider);
    if (uid == null) return false;
    return (kMockMembers[clubId] ?? []).any((m) => m.uid == uid);
  }
  return false;
});

final memberRoleProvider =
    FutureProvider.autoDispose.family<ClubMemberModel?, String>((ref, clubId) async {
  if (kDemoMode) {
    final uid = ref.watch(currentUidProvider);
    if (uid == null) return null;
    final members = kMockMembers[clubId] ?? [];
    try {
      return members.firstWhere((m) => m.uid == uid);
    } catch (_) {
      return null;
    }
  }
  return null;
});

// ── Events ─────────────────────────────────────────────────────────────────────

final eventsProvider = StreamProvider.autoDispose<List<EventModel>>((ref) {
  if (kDemoMode) return Stream.value(kMockEvents);
  return Stream.value([]);
});

final eventProvider =
    StreamProvider.autoDispose.family<EventModel?, String>((ref, eventId) {
  if (kDemoMode) {
    final event = kMockEvents.cast<EventModel?>().firstWhere(
          (e) => e?.id == eventId,
          orElse: () => null,
        );
    return Stream.value(event);
  }
  return Stream.value(null);
});

final clubEventsProvider =
    StreamProvider.autoDispose.family<List<EventModel>, String>((ref, clubId) {
  if (kDemoMode) {
    return Stream.value(kMockEvents.where((e) => e.clubId == clubId).toList());
  }
  return Stream.value([]);
});

// ── Messages — mutable in-memory so "send" works live during the demo ──────────

// Simple per-club broadcast stream for demo message delivery.
final _msgStreams = <String, StreamController<List<MessageModel>>>{};
final _msgLists = <String, List<MessageModel>>{};

StreamController<List<MessageModel>> _getMsgController(String clubId) {
  if (!_msgStreams.containsKey(clubId)) {
    _msgLists[clubId] = List<MessageModel>.from(kMockMessages[clubId] ?? []);
    _msgStreams[clubId] = StreamController<List<MessageModel>>.broadcast();
  }
  return _msgStreams[clubId]!;
}

final messagesProvider =
    StreamProvider.autoDispose.family<List<MessageModel>, String>((ref, clubId) {
  if (kDemoMode) {
    final ctrl = _getMsgController(clubId);
    return Stream<List<MessageModel>>.multi((controller) {
      // Emit the current list immediately
      controller.add(_msgLists[clubId]!);
      final sub = ctrl.stream.listen(controller.add);
      controller.onCancel = sub.cancel;
    });
  }
  return Stream.value([]);
});

/// Call this in demo mode to append a sent message; all listeners update live.
void demoSendMessage(String clubId, MessageModel msg) {
  final ctrl = _getMsgController(clubId);
  _msgLists[clubId]!.add(msg);
  ctrl.add(List<MessageModel>.from(_msgLists[clubId]!));
}

// ── Filter State ───────────────────────────────────────────────────────────────

final selectedFilterProvider = StateProvider<String>((ref) => 'All');

// ── My Clubs ──────────────────────────────────────────────────────────────────

final myClubsProvider = StreamProvider.autoDispose<List<ClubModel>>((ref) {
  if (kDemoMode) {
    final loggedIn = ref.watch(demoLoggedInProvider);
    if (!loggedIn) return Stream.value([]);
    final ids = kDemoUser.clubMemberships;
    return Stream.value(kMockClubs.where((c) => ids.contains(c.id)).toList());
  }
  return Stream.value([]);
});
