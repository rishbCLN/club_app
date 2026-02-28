import 'package:flutter/material.dart';

enum ClubRoleTag {
  seniorCore('Senior Core', '◈', 0xFFFF6B9D),
  juniorCore('Junior Core', '◇', 0xFFA78BFA),
  techHead('Tech Head', '⬡', 0xFF00FFCC),
  marketingHead('Marketing Head', '◉', 0xFFFBBF24),
  designLead('Design Lead', '◈', 0xFFF97316),
  eventHead('Event Head', '◎', 0xFF34D399),
  outreachLead('Outreach Lead', '○', 0xFF60A5FA),
  member('Member', '·', 0xFF94A3B8);

  const ClubRoleTag(this.label, this.icon, this.colorValue);

  final String label;
  final String icon;
  final int colorValue;

  Color get color => Color(colorValue);

  Color get backgroundColor => Color(colorValue).withOpacity(0.12);
  Color get borderColor => Color(colorValue).withOpacity(0.40);

  String get displayLabel => '$icon $label'.toUpperCase();

  static ClubRoleTag fromString(String value) {
    return ClubRoleTag.values.firstWhere(
      (e) => e.name == value || e.label == value,
      orElse: () => ClubRoleTag.member,
    );
  }
}

// ── Admin Roles ────────────────────────────────────────────────────────────────

/// Roles that grant access to the Admin Panel
const kAdminRoles = {
  ClubRoleTag.seniorCore,
  ClubRoleTag.techHead,
  ClubRoleTag.marketingHead,
  ClubRoleTag.designLead,
  ClubRoleTag.eventHead,
  ClubRoleTag.outreachLead,
};

// ── Event Types ───────────────────────────────────────────────────────────────

enum EventType {
  hackathon('Hackathon', '⬡', 0xFF00FFCC),
  workshop('Workshop', '◈', 0xFFA78BFA),
  cultural('Cultural', '◉', 0xFFFF6B9D),
  sports('Sports', '◎', 0xFF34D399),
  meetup('Meetup', '○', 0xFF60A5FA),
  fest('Fest', '◇', 0xFFFBBF24),

  // ── New ──────────────────────────────────────────────────────────────────
  recruitmentDrive('Recruitment Drive', '◈', 0xFFFF6B9D),
  interclubCollab('Inter-Club Collab', '⬡', 0xFF00FFCC),
  competition('Competition', '◉', 0xFFF97316),
  seminar('Seminar', '◇', 0xFF94A3B8),
  socialMixer('Social Mixer', '○', 0xFF34D399),
  exhibition('Exhibition', '◈', 0xFFFBBF24);

  const EventType(this.label, this.icon, this.colorValue);

  final String label;
  final String icon;
  final int colorValue;

  Color get color => Color(colorValue);

  static EventType fromString(String value) {
    return EventType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase() ||
             e.label.toLowerCase() == value.toLowerCase(),
      orElse: () => EventType.meetup,
    );
  }
}

// ── Club Types ─────────────────────────────────────────────────────────────────

enum ClubType {
  tech('Tech', 0xFF00FFCC),
  design('Design', 0xFFF97316),
  cultural('Cultural', 0xFFFF6B9D),
  literary('Literary', 0xFFA78BFA),
  hackathon('Hackathon', 0xFF34D399),
  sports('Sports', 0xFF60A5FA),
  other('Other', 0xFF94A3B8);

  const ClubType(this.label, this.colorValue);

  final String label;
  final int colorValue;

  Color get color => Color(colorValue);

  static ClubType fromString(String value) {
    return ClubType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase() ||
             e.label.toLowerCase() == value.toLowerCase(),
      orElse: () => ClubType.other,
    );
  }
}
