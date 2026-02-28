import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

// ── Club Model ─────────────────────────────────────────────────────────────────

class ClubModel extends Equatable {
  const ClubModel({
    required this.id,
    required this.name,
    required this.tagline,
    required this.type,
    required this.colorHex,
    required this.glowColorHex,
    this.logoUrl,
    this.bannerUrl,
    required this.memberCount,
    required this.foundedYear,
    required this.adminUids,
    this.socialLinks = const {},
    this.description = '',
  });

  final String id;
  final String name;
  final String tagline;
  final String type;
  final String colorHex;
  final String glowColorHex;
  final String? logoUrl;
  final String? bannerUrl;
  final int memberCount;
  final int foundedYear;
  final List<String> adminUids;
  final Map<String, String> socialLinks;
  final String description;

  factory ClubModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClubModel(
      id: doc.id,
      name: data['name'] ?? '',
      tagline: data['tagline'] ?? '',
      type: data['type'] ?? 'Other',
      colorHex: data['colorHex'] ?? '#00FFCC',
      glowColorHex: data['glowColorHex'] ?? '#00FFCC',
      logoUrl: data['logoUrl'],
      bannerUrl: data['bannerUrl'],
      memberCount: data['memberCount'] ?? 0,
      foundedYear: data['foundedYear'] ?? DateTime.now().year,
      adminUids: List<String>.from(data['adminUids'] ?? []),
      socialLinks: Map<String, String>.from(data['socialLinks'] ?? {}),
      description: data['description'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'tagline': tagline,
    'type': type,
    'colorHex': colorHex,
    'glowColorHex': glowColorHex,
    'logoUrl': logoUrl,
    'bannerUrl': bannerUrl,
    'memberCount': memberCount,
    'foundedYear': foundedYear,
    'adminUids': adminUids,
    'socialLinks': socialLinks,
    'description': description,
  };

  @override
  List<Object?> get props => [id, name, colorHex];
}

// ── Club Member Model ──────────────────────────────────────────────────────────

class ClubMemberModel extends Equatable {
  const ClubMemberModel({
    required this.uid,
    required this.displayName,
    this.avatarUrl,
    required this.roleTag,
    required this.joinedAt,
    required this.isAdmin,
    this.rollNo = '',
  });

  final String uid;
  final String displayName;
  final String? avatarUrl;
  final String roleTag;
  final DateTime joinedAt;
  final bool isAdmin;
  final String rollNo;

  factory ClubMemberModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ClubMemberModel(
      uid: doc.id,
      displayName: data['displayName'] ?? '',
      avatarUrl: data['avatarUrl'],
      roleTag: data['roleTag'] ?? 'member',
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isAdmin: data['isAdmin'] ?? false,
    );
  }

  @override
  List<Object?> get props => [uid, roleTag];
}

// ── Chat Message Model ─────────────────────────────────────────────────────────

class MessageModel extends Equatable {
  const MessageModel({
    required this.id,
    required this.senderUid,
    required this.senderName,
    required this.senderTag,
    this.senderAvatarUrl,
    required this.senderAccentColor,
    required this.text,
    required this.type,
    this.attachmentUrl,
    this.pinnedBy,
    this.reactions = const {},
    required this.timestamp,
  });

  final String id;
  final String senderUid;
  final String senderName;
  final String senderTag;
  final String? senderAvatarUrl;
  final String senderAccentColor;
  final String text;
  final String type; // text | image | event_share | announcement
  final String? attachmentUrl;
  final String? pinnedBy;
  final Map<String, List<String>> reactions;
  final DateTime timestamp;

  bool get isPinned => pinnedBy != null;
  bool get isAnnouncement => type == 'announcement';
  bool get isEventShare => type == 'event_share';

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final rawReactions = data['reactions'] as Map<String, dynamic>? ?? {};
    final reactions = rawReactions.map(
      (k, v) => MapEntry(k, List<String>.from(v as List)),
    );
    return MessageModel(
      id: doc.id,
      senderUid: data['senderUid'] ?? '',
      senderName: data['senderName'] ?? '',
      senderTag: data['senderTag'] ?? 'member',
      senderAvatarUrl: data['senderAvatarUrl'],
      senderAccentColor: data['senderAccentColor'] ?? '#00FFCC',
      text: data['text'] ?? '',
      type: data['type'] ?? 'text',
      attachmentUrl: data['attachmentUrl'],
      pinnedBy: data['pinnedBy'],
      reactions: reactions,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, timestamp];
}

// ── Event Model ────────────────────────────────────────────────────────────────

class EventModel extends Equatable {
  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.clubId,
    required this.clubName,
    required this.clubColorHex,
    required this.eventType,
    required this.startDate,
    required this.endDate,
    required this.venue,
    this.bannerUrl,
    this.registrationLink,
    this.collaboratingClubs = const [],
    this.tags = const [],
    this.isPublic = true,
  });

  final String id;
  final String title;
  final String description;
  final String clubId;
  final String clubName;
  final String clubColorHex;
  final String eventType;
  final DateTime startDate;
  final DateTime endDate;
  final String venue;
  final String? bannerUrl;
  final String? registrationLink;
  final List<String> collaboratingClubs;
  final List<String> tags;
  final bool isPublic;

  bool get hasCollaboration => collaboratingClubs.isNotEmpty;
  bool get isUpcoming => startDate.isAfter(DateTime.now());
  bool get isOngoing =>
      startDate.isBefore(DateTime.now()) && endDate.isAfter(DateTime.now());

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      clubId: data['clubId'] ?? '',
      clubName: data['clubName'] ?? '',
      clubColorHex: data['clubColorHex'] ?? '#00FFCC',
      eventType: data['eventType'] ?? 'Meetup',
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      venue: data['venue'] ?? '',
      bannerUrl: data['bannerUrl'],
      registrationLink: data['registrationLink'],
      collaboratingClubs: List<String>.from(data['collaboratingClubs'] ?? []),
      tags: List<String>.from(data['tags'] ?? []),
      isPublic: data['isPublic'] ?? true,
    );
  }

  @override
  List<Object?> get props => [id, title, startDate];
}

// ── User Model ─────────────────────────────────────────────────────────────────

class UserModel extends Equatable {
  const UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    this.avatarUrl,
    this.collegeRollNo = '',
    this.clubMemberships = const [],
    required this.createdAt,
  });

  final String uid;
  final String displayName;
  final String email;
  final String? avatarUrl;
  final String collegeRollNo;
  final List<String> clubMemberships;
  final DateTime createdAt;

  /// Convenience getters used throughout the UI
  String get name => displayName;
  String get rollNumber => collegeRollNo;

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      displayName: data['displayName'] ?? '',
      email: data['email'] ?? '',
      avatarUrl: data['avatarUrl'],
      collegeRollNo: data['collegeRollNo'] ?? '',
      clubMemberships: List<String>.from(data['clubMemberships'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'uid': uid,
    'displayName': displayName,
    'email': email,
    'avatarUrl': avatarUrl,
    'collegeRollNo': collegeRollNo,
    'clubMemberships': clubMemberships,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  @override
  List<Object?> get props => [uid, email];
}

// ── Join Request Model ─────────────────────────────────────────────────────────

enum JoinRequestStatus { pending, approved, rejected }

class JoinRequestModel extends Equatable {
  const JoinRequestModel({
    required this.id,
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.collegeRollNo,
    required this.requestedAt,
    required this.status,
  });

  final String id;
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final String collegeRollNo;
  final DateTime requestedAt;
  final JoinRequestStatus status;

  JoinRequestModel copyWith({JoinRequestStatus? status}) => JoinRequestModel(
        id: id,
        userId: userId,
        displayName: displayName,
        avatarUrl: avatarUrl,
        collegeRollNo: collegeRollNo,
        requestedAt: requestedAt,
        status: status ?? this.status,
      );

  @override
  List<Object?> get props => [id, status];
}
