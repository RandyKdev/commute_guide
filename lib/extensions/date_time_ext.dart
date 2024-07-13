import 'package:intl/intl.dart';

extension DateTimeExt on DateTime {
  String get dateToReadableString {
    return DateFormat('dd/MM/yyyy').format(this);
  }

  String get durationPast {
    final now = DateTime.now();
    final duration = now.difference(this);
    final years = duration.inDays ~/ 365;
    final months = duration.inDays ~/ 30;
    final weeks = duration.inDays ~/ 7;
    final days = duration.inDays;
    final hours = duration.inHours;
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds;

    if (years > 0) {
      return '$years yr${years > 1 ? 's' : ''} ago';
    }

    if (months > 0) {
      return '$months mth${months > 1 ? 's' : ''} ago';
    }

    if (weeks > 0) {
      return '$weeks wk${weeks > 1 ? 's' : ''} ago';
    }

    if (days > 0) {
      return '$days day${days > 1 ? 's' : ''} ago';
    }

    if (hours > 0) {
      return '$hours hr${hours > 1 ? 's' : ''} ago';
    }

    if (minutes > 0) {
      return '$minutes min${minutes > 1 ? 's' : ''} ago';
    }

    if (seconds > 0) {
      return '$seconds sec${seconds > 1 ? 's' : ''} ago';
    }

    return 'Now';
  }

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
