import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension ColorHexExtension on Color {
  String toHex() => '#${value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

  Color darken([double amount = 0.2]) {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  Color lighten([double amount = 0.2]) {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }
}

extension StringExtension on String {
  Color toColor() {
    final hex = replaceAll('#', '');
    final value = int.parse(hex.length == 6 ? 'FF$hex' : hex, radix: 16);
    return Color(value);
  }

  String get initials {
    final parts = trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0].substring(0, parts[0].length.clamp(0, 2)).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  String get capitalizeFirst =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}

extension DateTimeExtension on DateTime {
  String get friendlyDate => DateFormat('MMM d, yyyy').format(this);
  String get friendlyTime => DateFormat('h:mm a').format(this);
  String get friendlyDateTime => DateFormat('MMM d · h:mm a').format(this);

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }

  bool get isPast => isBefore(DateTime.now());
  bool get isFuture => isAfter(DateTime.now());

  String get relativeLabel {
    if (isToday) return 'Today';
    if (isTomorrow) return 'Tomorrow';
    return friendlyDate;
  }
}

extension ContextExtension on BuildContext {
  double get width => MediaQuery.sizeOf(this).width;
  double get height => MediaQuery.sizeOf(this).height;
  bool get isMobile => width < 600;
  EdgeInsets get padding => MediaQuery.paddingOf(this);
  double get bottomPadding => MediaQuery.paddingOf(this).bottom;
}

extension ListExtension<T> on List<T> {
  List<T> separatedBy(T separator) {
    if (isEmpty) return this;
    return [
      for (int i = 0; i < length; i++) ...[
        this[i],
        if (i < length - 1) separator,
      ],
    ];
  }
}
